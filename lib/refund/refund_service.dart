import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pos_app/api/api_client.dart';
import 'package:pos_app/company/company_provider.dart';
import 'package:pos_app/auth/auth_provider.dart';

const _pendingRefundsKey = 'pending_refunds';

// ── Models ────────────────────────────────────────────────────────────────────

class DocumentItemDto {
  final int productId;
  final String productName;
  final double quantity;
  final double price;
  final double total;

  const DocumentItemDto({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.total,
  });

  factory DocumentItemDto.fromJson(Map<String, dynamic> j) => DocumentItemDto(
        productId:   j['productId'] as int,
        productName: j['productName'] as String? ?? '',
        quantity:    (j['quantity'] as num).toDouble(),
        price:       (j['priceBeforeTaxAfterDiscount'] as num? ?? j['price'] as num? ?? 0).toDouble(),
        total:       (j['totalAfterDocumentDiscount'] as num? ?? j['total'] as num? ?? 0).toDouble(),
      );
}

class FetchedDocument {
  final int id;
  final String number;
  final double total;
  final List<DocumentItemDto> items;

  const FetchedDocument({
    required this.id,
    required this.number,
    required this.total,
    required this.items,
  });
}

class RefundPayload {
  final String originalDocumentNumber;
  final int refundPaymentTypeId;
  final int warehouseId;
  final List<Map<String, dynamic>> items;

  const RefundPayload({
    required this.originalDocumentNumber,
    required this.refundPaymentTypeId,
    required this.warehouseId,
    required this.items,
  });

  Map<String, dynamic> toJson() => {
        'originalDocumentNumber': originalDocumentNumber,
        'refundPaymentTypeId':    refundPaymentTypeId,
        'warehouseId':            warehouseId,
        'items':                  items,
      };
}

// ── Service ───────────────────────────────────────────────────────────────────

class RefundService {
  final Ref _ref;
  RefundService(this._ref);

  int get _companyId => _ref.read(selectedCompanyProvider)?.id ?? 0;
  int get _userId    => _ref.read(currentUserProvider)?.id ?? 0;

  // Fetch the original receipt from the API.
  // Returns null if not found; throws on network error.
  Future<FetchedDocument?> fetchDocument(String receiptNumber) async {
    final dio = createDio();
    final Response response;
    try {
      response = await dio.get(
        '/Document/GetByNumber',
        queryParameters: {
          'number':    receiptNumber.trim(),
          'companyId': _companyId,
        },
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }

    if (response.data == null) return null;
    final data = response.data as Map<String, dynamic>;

    // Fetch the document items
    final itemsResponse = await dio.get(
      '/DocumentItems/GetByDocumentId',
      queryParameters: {
        'documentId': data['id'],
        'companyId':  _companyId,
      },
    );

    final rawItems = (itemsResponse.data as List? ?? []);
    final items = rawItems
        .map((j) => DocumentItemDto.fromJson(j as Map<String, dynamic>))
        .toList();

    return FetchedDocument(
      id:     data['id'] as int,
      number: data['number'] as String? ?? receiptNumber,
      total:  (data['total'] as num).toDouble(),
      items:  items,
    );
  }

  // Submit a refund. If offline, queues to shared_preferences for later sync.
  Future<({String refundNumber, bool queued})> submitRefund(
      RefundPayload payload) async {
    final dio = createDio();
    try {
      final response = await dio.post(
        '/Document/Refund',
        queryParameters: {
          'companyId': _companyId,
          'userId':    _userId,
        },
        data: payload.toJson(),
      );
      final result = response.data as Map<String, dynamic>;
      return (
        refundNumber: result['refundDocumentNumber'] as String? ?? '',
        queued: false,
      );
    } on DioException catch (e) {
      // Network unavailable — queue for later sync
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        await _enqueueRefund(payload);
        return (refundNumber: '(queued)', queued: true);
      }
      rethrow;
    }
  }

  Future<void> _enqueueRefund(RefundPayload payload) async {
    final prefs = await SharedPreferences.getInstance();
    final queue = prefs.getStringList(_pendingRefundsKey) ?? [];
    queue.add(jsonEncode({
      ...payload.toJson(),
      'companyId': _companyId,
      'userId':    _userId,
      'queuedAt':  DateTime.now().toIso8601String(),
    }));
    await prefs.setStringList(_pendingRefundsKey, queue);
  }

  // Call this on app start or when connectivity is restored.
  Future<void> syncPendingRefunds() async {
    final prefs = await SharedPreferences.getInstance();
    final queue = prefs.getStringList(_pendingRefundsKey) ?? [];
    if (queue.isEmpty) return;

    final dio      = createDio();
    final remaining = <String>[];

    for (final raw in queue) {
      try {
        final json      = jsonDecode(raw) as Map<String, dynamic>;
        final companyId = json['companyId'] as int;
        final userId    = json['userId'] as int;
        await dio.post(
          '/Document/Refund',
          queryParameters: {'companyId': companyId, 'userId': userId},
          data: json,
        );
      } catch (_) {
        remaining.add(raw); // Keep failed ones for next attempt
      }
    }

    await prefs.setStringList(_pendingRefundsKey, remaining);
  }
}

final refundServiceProvider = Provider<RefundService>((ref) => RefundService(ref));

final pendingRefundsCountProvider = FutureProvider<int>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return (prefs.getStringList(_pendingRefundsKey) ?? []).length;
});

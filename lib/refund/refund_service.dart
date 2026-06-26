import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:pos_app/api/api_client.dart';
import 'package:pos_app/company/company_provider.dart';
import 'package:pos_app/auth/auth_provider.dart';
import 'package:pos_app/database/app_database.dart';
import 'package:pos_app/database/database_provider.dart';
import 'package:pos_app/document/document_type_constants.dart';
import 'package:pos_app/settings/device_identity.dart';

const _pendingRefundsKey = 'pending_refunds';

/// Server `DocumentTypeConstants.Refund`. Refund documents written locally must
/// carry this type so the documents list / reports classify them correctly and
/// the duplicate-refund lock can find them.
const kRefundDocumentTypeId = 4;

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
  final int warehouseId;
  final List<DocumentItemDto> items;
  // Carried over to the refund so it inherits the original sale's customer and
  // order reference instead of showing "-"/"N/A".
  final int? customerId;
  final String? orderNumber;

  const FetchedDocument({
    required this.id,
    required this.number,
    required this.total,
    required this.warehouseId,
    required this.items,
    this.customerId,
    this.orderNumber,
  });
}

class RefundPayload {
  final String originalDocumentNumber;
  final int refundPaymentTypeId;
  final int warehouseId;
  final List<Map<String, dynamic>> items;

  /// Blind return: this terminal never had the original receipt (sold on
  /// another POS while both offline). No original document is verified; a
  /// manager authorised it and item prices ride along in [items] as 'price'.
  final bool isBlind;

  /// The manager (accessLevel 0) whose PIN authorised a blind return.
  final int? approvedByUserId;

  const RefundPayload({
    required this.originalDocumentNumber,
    required this.refundPaymentTypeId,
    required this.warehouseId,
    required this.items,
    this.isBlind = false,
    this.approvedByUserId,
  });

  Map<String, dynamic> toJson() => {
        'originalDocumentNumber': originalDocumentNumber,
        'refundPaymentTypeId':    refundPaymentTypeId,
        'warehouseId':            warehouseId,
        'items':                  items,
        'isBlind':                isBlind,
        if (approvedByUserId != null) 'approvedByUserId': approvedByUserId,
      };
}

// ── Service ───────────────────────────────────────────────────────────────────

class RefundService {
  final Ref _ref;
  RefundService(this._ref);

  int get _companyId => _ref.read(selectedCompanyProvider)?.id ?? 0;
  int get _userId    => _ref.read(currentUserProvider)?.id ?? 0;

  /// Verifies a manager PIN for blind-return authorisation, fully offline.
  /// Returns the authorising manager's userId when [pin] matches the cached
  /// PIN hash of an *enabled admin* (accessLevel 0) in this company; else null.
  /// Mirrors the login hash: base64( SHA-256( UTF-8(pin) ) ).
  Future<int?> verifyManagerPin(String pin) async {
    if (pin.trim().isEmpty) return null;
    final db = _ref.read(appDatabaseProvider);
    final hash = base64Encode(sha256.convert(utf8.encode(pin.trim())).bytes);
    final managers = await (db.select(db.usersTable)
          ..where((t) => t.companyId.equals(_companyId))
          ..where((t) => t.role.equals(0))
          ..where((t) => t.isEnabled.equals(true)))
        .get();
    for (final m in managers) {
      if (m.pinHash != null && m.pinHash!.isNotEmpty && m.pinHash == hash) {
        return m.id;
      }
    }
    return null;
  }

  // Fetch the original receipt from the API.
  // Returns null if not found; throws on network error.
  /// Looks up a receipt + its items in the local Drift cache by document number.
  /// Returns null when the number isn't in the local DB (then the caller falls
  /// back to the API). Product names come from the local product cache.
  Future<FetchedDocument?> _fetchLocalDocument(String number) async {
    if (number.isEmpty) return null;
    final db = _ref.read(appDatabaseProvider);

    final docs = await (db.select(db.documentsTable)
          ..where((t) => t.companyId.equals(_companyId))
          ..where((t) => t.number.equals(number))
          ..limit(1))
        .get();
    if (docs.isEmpty) return null;
    final doc = docs.first;

    final items = await (db.select(db.documentItemsTable)
          ..where((t) => t.documentId.equals(doc.localId)))
        .get();

    final ids = items.map((i) => i.productId).toSet().toList();
    final products = ids.isEmpty
        ? const <ProductsTableData>[]
        : await (db.select(db.productsTable)..where((t) => t.id.isIn(ids))).get();
    final nameById = {for (final p in products) p.id: p.name};

    return FetchedDocument(
      id: doc.serverId ?? 0,
      number: doc.number ?? number,
      total: doc.total,
      warehouseId: doc.warehouseId,
      customerId: doc.customerId,
      orderNumber: doc.orderNumber,
      items: items
          .map((i) => DocumentItemDto(
                productId: i.productId,
                productName: nameById[i.productId] ?? '',
                quantity: i.quantity,
                // After-discount unit price — what the customer actually paid
                // per unit. `unitPrice` is the pre-discount price, so a
                // discounted line would over-refund. `total` is the stored
                // after-discount line total, matching the server's
                // PriceBeforeTaxAfterDiscount used by the verified refund.
                price: i.quantity != 0 ? i.total / i.quantity : i.unitPrice,
                total: i.total,
              ))
          .toList(),
    );
  }

  Future<FetchedDocument?> fetchDocument(String receiptNumber) async {
    // Offline-first: look the receipt up in the LOCAL DB first. The number is
    // stamped at checkout, so a sale made on this terminal (and its items) is
    // found with zero network — offline refunds work. Fall back to the API only
    // for receipts not in the local cache (e.g. issued on another terminal that
    // has since synced).
    final local = await _fetchLocalDocument(receiptNumber.trim());
    if (local != null) return local;

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
      id:          data['id'] as int,
      number:      data['number'] as String? ?? receiptNumber,
      total:       (data['total'] as num).toDouble(),
      warehouseId: (data['warehouseId'] as num?)?.toInt() ?? 0,
      customerId:  (data['customerId'] as num?)?.toInt(),
      orderNumber: data['orderNumber'] as String?,
      items:       items,
    );
  }

  // Submit a refund. Writes the refund Document/items/payment to local Drift
  // first (instant visibility on the Documents screen) then pushes to the
  // server. If offline, the local row stays 'pending' and the API payload is
  // queued to shared_preferences; [syncPendingRefunds] flips it to 'synced'.
  Future<({String refundNumber, bool queued})> submitRefund(
    RefundPayload payload, {
    FetchedDocument? source,
  }) async {
    final db = _ref.read(appDatabaseProvider);
    // Device-local refund number, issued offline (220 series) so the refund is
    // numbered + scannable the instant it's created — even with no network. The
    // server keeps it verbatim (via clientDocumentNumber) so it never changes.
    final deviceName = await getDeviceName();
    final refundNumber = await db.nextDocumentNumber(
      companyId: _companyId,
      deviceName: deviceName,
      docTypeCode: DocumentTypes.refundCode,
    );
    final data = {...payload.toJson(), 'clientDocumentNumber': refundNumber};

    final dio = createDio();
    final refundLocalId = const Uuid().v4();
    try {
      await dio.post(
        '/Document/Refund',
        queryParameters: {
          'companyId': _companyId,
          'userId':    _userId,
        },
        data: data,
      );
      await _saveRefundLocally(
        localId: refundLocalId,
        payload: payload,
        source: source,
        number: refundNumber,
        synced: true,
      );
      await _restoreLocalStock(payload);
      return (refundNumber: refundNumber, queued: false);
    } on DioException catch (e) {
      // Network unavailable — persist locally as pending + queue for later sync.
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        await _saveRefundLocally(
          localId: refundLocalId,
          payload: payload,
          source: source,
          number: refundNumber,
          synced: false,
        );
        await _enqueueRefund(payload, localId: refundLocalId, number: refundNumber);
        await _restoreLocalStock(payload);
        return (refundNumber: refundNumber, queued: true);
      }
      rethrow;
    }
  }

  /// Writes the refund as a local Document (+ items + negative payment) so it
  /// shows up on the Documents screen immediately, mirroring the offline-first
  /// checkout pattern in PaymentCheckoutDialog. Totals and quantities are stored
  /// negative to mark the document as a refund; the server keeps its own
  /// (positive) copy, reconciled by number in SyncManager.pullDocuments.
  Future<void> _saveRefundLocally({
    required String localId,
    required RefundPayload payload,
    required FetchedDocument? source,
    required String? number,
    required bool synced,
  }) async {
    final db = _ref.read(appDatabaseProvider);
    final now = DateTime.now().toUtc();
    final status = synced ? 'synced' : 'pending';

    // Verified refund: prices come from the original receipt. Blind return:
    // there's no source, so each item carries its own 'price' in the payload.
    final priceById = {for (final i in source?.items ?? const []) i.productId: i.price};

    double refundTotal = 0;
    final items = <DocumentItemsTableCompanion>[];
    for (final raw in payload.items) {
      final productId = raw['productId'] as int;
      final qty = (raw['quantity'] as num).toDouble();
      final price = (raw['price'] as num?)?.toDouble() ?? priceById[productId] ?? 0;
      final lineTotal = price * qty;
      refundTotal += lineTotal;
      items.add(DocumentItemsTableCompanion(
        localId:    Value(const Uuid().v4()),
        documentId: Value(localId),
        productId:  Value(productId),
        quantity:   Value(-qty),
        unitPrice:  Value(price),
        total:      Value(-lineTotal),
        syncStatus: Value(status),
      ));
    }

    await db.insertOfflineDocument(
      document: DocumentsTableCompanion(
        localId:                 Value(localId),
        companyId:               Value(_companyId),
        documentTypeId:          const Value(kRefundDocumentTypeId),
        number:                  Value(number),
        userId:                  Value(_userId),
        warehouseId:             Value(payload.warehouseId),
        total:                   Value(-refundTotal),
        // Inherit the original sale's customer + order reference (from the
        // document this refund points at) so the refund row isn't "-"/"N/A".
        customerId:              Value(source?.customerId),
        orderNumber:             Value(source?.orderNumber),
        referenceDocumentNumber: Value(payload.originalDocumentNumber),
        paidStatus:              const Value(1),
        date:                    Value(now),
        syncStatus:              Value(status),
        lastModified:            Value(now),
      ),
      items: items,
      payment: PaymentsTableCompanion(
        localId:       Value(const Uuid().v4()),
        documentId:    Value(localId),
        paymentTypeId: Value(payload.refundPaymentTypeId),
        amount:        Value(-refundTotal),
        userId:        Value(_userId),
        date:          Value(now),
        companyId:     Value(_companyId),
        dateCreated:   Value(now),
        syncStatus:    Value(status),
      ),
    );
  }

  /// Returns the refunded quantities to the local Drift stock cache so the POS
  /// menu reflects the freed inventory immediately (offline-first — the server
  /// restock won't reach the local DB until the next master-data pull).
  /// Reuses [deductStockForCheckout] with negated quantities (it computes
  /// `current - quantity`, so a negative quantity adds back).
  Future<void> _restoreLocalStock(RefundPayload payload) async {
    final db = _ref.read(appDatabaseProvider);
    final items = payload.items
        .map((i) => (
              productId: i['productId'] as int,
              quantity: -((i['quantity'] as num).toDouble()),
              warehouseId: payload.warehouseId,
              isService: false,
              productName: '',
            ))
        .toList();
    await db.deductStockForCheckout(items: items, allowNegative: true);
  }

  Future<void> _enqueueRefund(
    RefundPayload payload, {
    required String localId,
    required String number,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final queue = prefs.getStringList(_pendingRefundsKey) ?? [];
    queue.add(jsonEncode({
      ...payload.toJson(),
      // The device-local refund number the server must keep verbatim on replay.
      'clientDocumentNumber': number,
      'companyId':       _companyId,
      'userId':          _userId,
      // Local Drift Document.localId so syncPendingRefunds can flip the row to
      // 'synced' (and stamp its server number) once the queued push succeeds.
      'localId':         localId,
      'queuedAt':        DateTime.now().toIso8601String(),
    }));
    await prefs.setStringList(_pendingRefundsKey, queue);
  }

  // Call this on app start or when connectivity is restored. Pushes the queued
  // /Document/Refund payloads and, on success, marks the matching local Drift
  // refund Document 'synced' with its server-assigned number.
  Future<void> syncPendingRefunds() async {
    final prefs = await SharedPreferences.getInstance();
    final queue = prefs.getStringList(_pendingRefundsKey) ?? [];
    if (queue.isEmpty) return;

    final dio       = createDio();
    final db        = _ref.read(appDatabaseProvider);
    final remaining = <String>[];

    for (final raw in queue) {
      try {
        final json      = jsonDecode(raw) as Map<String, dynamic>;
        final companyId = json['companyId'] as int;
        final userId    = json['userId'] as int;
        final localId   = json['localId'] as String?;
        await dio.post(
          '/Document/Refund',
          queryParameters: {'companyId': companyId, 'userId': userId},
          data: json,
        );
        // Flip the local row to 'synced'. The number is the device-local one we
        // already stamped (the server kept it verbatim via clientDocumentNumber),
        // so we leave it untouched — pullDocuments reconciles by number.
        if (localId != null) {
          await (db.update(db.documentsTable)
                ..where((t) => t.localId.equals(localId)))
              .write(DocumentsTableCompanion(
            syncStatus:   const Value('synced'),
            lastModified: Value(DateTime.now().toUtc()),
          ));
        }
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

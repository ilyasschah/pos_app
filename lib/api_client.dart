import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'checkout_models.dart';

Dio createDio() {
  final dio = Dio();

  dio.options.baseUrl = 'http://192.168.11.103:5002/api';
  dio.options.connectTimeout = const Duration(seconds: 10);
  dio.options.receiveTimeout = const Duration(seconds: 10);

  if (!kIsWeb) {
    (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      if (kDebugMode) {
        client.badCertificateCallback = (cert, host, port) => true;
      }
      return client;
    };
  }
  return dio;
}

class ApiClient {
  late final Dio _dio;

  ApiClient() {
    _dio = createDio();
  }
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  Future<List<MenuCategory>> getFullMenu(int companyId, int warehouseId) async {
    try {
      final response = await _dio.get(
        '/Menu',
        queryParameters: {'companyId': companyId, 'warehouseId': warehouseId},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => MenuCategory.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load menu. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching menu: $e');
    }
  }

  Future<bool> bulkAddPosOrderItems(int companyId, List<CartItem> items) async {
    try {
      final List<Map<String, dynamic>> jsonList = items
          .map((item) => item.toJson())
          .toList();

      final response = await _dio.post(
        '/PosOrderItem/BulkAdd',
        queryParameters: {'companyId': companyId},
        data: jsonList,
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to save cart. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error saving cart: $e');
    }
  }

  Future<bool> checkoutPosOrder(
    int companyId,
    int userId,
    CheckoutRequest request,
  ) async {
    try {
      final response = await _dio.post(
        '/PosOrder/Checkout',
        queryParameters: {'companyId': companyId, 'userId': userId},
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Checkout failed. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error during checkout: $e');
    }
  }

  Future<int> createPosOrder(
    int companyId,
    int userId,
    int serviceType,
    int floorPlanTableId,
  ) async {
    try {
      final response = await _dio.post(
        '/PosOrder/Create',
        queryParameters: {'companyId': companyId},
        data: {
          "userId": userId,
          "number": "ORD-TEMP",
          "discount": 0.0,
          "discountType": 0,
          "total": 0.0,
          "customerId": null,
          "serviceType": serviceType,
          "serviceStatus": 1,
          "floorPlanTableId": floorPlanTableId,
          "bookingId": null,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data is int) return data;
        if (data['id'] != null) return data['id'];
        if (data['Id'] != null) return data['Id'];

        throw Exception('Could not find Order ID in response');
      } else {
        throw Exception(
          'Failed to create order. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error creating order: $e');
    }
  }

  Future<Map<String, dynamic>?> getActiveOrderForTable(
    int companyId,
    int tableId,
  ) async {
    try {
      final response = await _dio.get(
        '/PosOrder/GetAll',
        queryParameters: {'companyId': companyId},
      );
      if (response.statusCode == 200) {
        final List<dynamic> orders = response.data;
        orders.sort((a, b) {
          final idA = a['id'] ?? a['Id'] ?? 0;
          final idB = b['id'] ?? b['Id'] ?? 0;
          return idB.compareTo(idA);
        });

        return orders.firstWhere(
          (o) =>
              (o['floorPlanTableId'] ?? o['FloorPlanTableId']) == tableId &&
              (o['serviceStatus'] ?? o['ServiceStatus']) == 1,
          orElse: () => null,
        );
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch active order: $e');
    }
  }

  Future<List<dynamic>> getOrderItems(int companyId, int posOrderId) async {
    try {
      final response = await _dio.get(
        '/PosOrderItem/GetByOrderId',
        queryParameters: {'posOrderId': posOrderId, 'companyId': companyId},
      );
      return response.data as List<dynamic>;
    } catch (e) {
      throw Exception('Failed to fetch order items: $e');
    }
  }

  Future<bool> deletePosOrder(int companyId, int posOrderId) async {
    try {
      final response = await _dio.delete(
        '/PosOrder/Delete',
        queryParameters: {'id': posOrderId, 'companyId': companyId},
      );
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to delete order: $e');
    }
  }

  Future<List<dynamic>> getKitchenOrders(int companyId) async {
    try {
      final response = await _dio.get(
        '/PosOrder/GetKitchenOrders',
        queryParameters: {'companyId': companyId},
      );
      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      }
      return [];
    } on DioException catch (e) {
      throw Exception('Failed to fetch kitchen orders: ${e.message}');
    }
  }

  Future<List<dynamic>> getAllActiveOrders(int companyId) async {
    try {
      final response = await _dio.get(
        '/PosOrder/GetAll',
        queryParameters: {'companyId': companyId},
      );
      if (response.statusCode == 200) {
        final List<dynamic> orders = response.data;
        final activeOrders = orders
            .where((o) => (o['serviceStatus'] ?? o['ServiceStatus']) == 1)
            .toList();
        activeOrders.sort((a, b) {
          final idA = a['id'] ?? a['Id'] ?? 0;
          final idB = b['id'] ?? b['Id'] ?? 0;
          return (idB as int).compareTo(idA as int);
        });
        return activeOrders;
      }
      return [];
    } on DioException catch (e) {
      throw Exception('Failed to fetch active orders: ${e.message}');
    }
  }
}

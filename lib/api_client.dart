// lib/api_client.dart

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'checkout_models.dart'; // Make sure this matches your file name!

// SHARED DIO INSTANCE CREATOR
Dio createDio() {
  final dio = Dio();

  // Configure Base Options
  dio.options.baseUrl = 'https://localhost:7002/api';
  dio.options.connectTimeout = const Duration(seconds: 10);
  dio.options.receiveTimeout = const Duration(seconds: 10);

  // SSL Certificate Handling for Local Development
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

  // Optional: Call this when a user logs in so all future requests are authenticated
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  // ==========================================
  // NEW POS WORKFLOW ENDPOINTS
  // ==========================================

  // 1. Fetch the Ultimate Menu (Lightning fast single request)
  Future<List<MenuCategory>> getFullMenu(int companyId, int warehouseId) async {
    try {
      final response = await _dio.get(
        '/Menu',
        queryParameters: {
          'companyId': companyId,
          'warehouseId': warehouseId,
        },
      );

      if (response.statusCode == 200) {
        // Dio automatically decodes the JSON!
        final List<dynamic> data = response.data;
        return data.map((json) => MenuCategory.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load menu. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching menu: $e');
    }
  }

  // 2. Bulk Add Cart Items (Saves the whole cart in one database transaction)
  Future<bool> bulkAddPosOrderItems(int companyId, List<CartItem> items) async {
    try {
      // Map our Dart objects into simple maps for Dio
      final List<Map<String, dynamic>> jsonList =
          items.map((item) => item.toJson()).toList();

      final response = await _dio.post(
        '/PosOrderItem/BulkAdd',
        queryParameters: {'companyId': companyId},
        data: jsonList, // Dio automatically converts this to a JSON string!
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

  // 3. Checkout & Pay (Converts cart to document, frees the table!)
  Future<bool> checkoutPosOrder(
      int companyId, int userId, CheckoutRequest request) async {
    try {
      final response = await _dio.post(
        '/PosOrder/Checkout',
        queryParameters: {
          'companyId': companyId,
          'userId': userId,
        },
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
      int companyId, int userId, int serviceType, int floorPlanTableId) async {
    try {
      final response = await _dio.post(
        '/PosOrder/Create',
        queryParameters: {'companyId': companyId},
        data: {
          "userId": userId,
          "serviceType": serviceType, // e.g., 1 for Dine-in
          "floorPlanTableId": floorPlanTableId,
          "customerId": null
        },
      );

      if (response.statusCode == 200) {
        return response.data['id'];
      } else {
        throw Exception('Failed to create order.');
      }
    } catch (e) {
      throw Exception('Error creating order: $e');
    }
  }
}

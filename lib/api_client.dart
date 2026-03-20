// lib/api_client.dart

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

// SHARED DIO INSTANCE CREATOR
Dio createDio() {
  final dio = Dio();

  // Configure Base Options (Optional but helpful)
  dio.options.baseUrl = 'https://localhost:7002/api';
  dio.options.connectTimeout = const Duration(seconds: 10);
  dio.options.receiveTimeout = const Duration(seconds: 10);

  // SSL Certificate Handling for Local Development
  if (!kIsWeb) {
    (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      client.badCertificateCallback =
          (cert, host, port) => true; // Bypass SSL errors
      return client;
    };
  }
  return dio;
}

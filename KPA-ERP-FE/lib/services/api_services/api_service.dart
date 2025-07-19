import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:kpa_erp/constants/api_constant.dart';
import 'package:kpa_erp/services/api_services/api_exception.dart';

class ApiService {
  static Map<String, String> _getHeadersWithAuth(dynamic body) {
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
    };

    String? token;
    if (body != null && body.containsKey('token')) {
      token = body['token'];
    }

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  static Map<String, dynamic> _prepareRequestBody(dynamic body) {
    if (body == null) return {};
    return Map<String, dynamic>.from(body);
  }

  /// ✅ Updated GET with Query Params ✅
  static Future<dynamic> get(String endpoint, Map<String, String> params) async {
    try {
      Map<String, String> headers = _getHeadersWithAuth(params);

      final uri = Uri.parse('${ApiConstant.baseUrl}$endpoint').replace(queryParameters: params);

      if (kDebugMode) {
        debugPrint('🔍 ApiService GET Debug:');
        debugPrint('URL: $uri');
        debugPrint('Headers: $headers');
      }

      final response = await http.get(uri, headers: headers);

      if (kDebugMode) {
        debugPrint('📥 Response Status: ${response.statusCode}');
        debugPrint('📥 Response Headers: ${response.headers}');
        debugPrint('📥 Response Body: ${response.body}');
      }

      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(500, 'Network error: ${e.toString()}');
    }
  }

  static Future<dynamic> post(String endpoint, dynamic body) async {
    try {
      Map<String, String> headers = _getHeadersWithAuth(body);
      Map<String, dynamic> requestBody = _prepareRequestBody(body);

      if (kDebugMode) {
        debugPrint('🔍 ApiService POST Debug:');
        debugPrint('URL: ${ApiConstant.baseUrl}$endpoint');
        debugPrint('Headers: $headers');
        debugPrint('Body: ${jsonEncode(requestBody)}');
      }

      final response = await http.post(
        Uri.parse('${ApiConstant.baseUrl}$endpoint'),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      if (kDebugMode) {
        debugPrint('📥 Response Status: ${response.statusCode}');
        debugPrint('📥 Response Headers: ${response.headers}');
        debugPrint('📥 Response Body: ${response.body}');
      }

      return _handleResponse(response);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ ApiService POST Error: $e');
      }
      if (e is ApiException) rethrow;
      throw ApiException(500, 'Network error: ${e.toString()}');
    }
  }

  static Future<dynamic> put(String endpoint, dynamic body) async {
    try {
      Map<String, String> headers = _getHeadersWithAuth(body);
      Map<String, dynamic> requestBody = _prepareRequestBody(body);

      final response = await http.put(
        Uri.parse('${ApiConstant.baseUrl}$endpoint'),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(500, 'Network error: ${e.toString()}');
    }
  }

  static Future<dynamic> delete(String endpoint, dynamic body) async {
    try {
      Map<String, String> headers = _getHeadersWithAuth(body);
      Map<String, dynamic> requestBody = _prepareRequestBody(body);

      final response = await http.delete(
        Uri.parse('${ApiConstant.baseUrl}$endpoint'),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(500, 'Network error: ${e.toString()}');
    }
  }

  static dynamic _handleResponse(http.Response response) {
    if (response.headers['content-type']?.contains('application/pdf') ?? false) {
      return response.bodyBytes;
    } else if (response.statusCode == 204) {
      return "deleted successfully";
    } else {
      try {
        final jsonResponse = json.decode(response.body);
        if (response.statusCode >= 200 && response.statusCode < 300) {
          return jsonResponse;
        } else {
          if (jsonResponse.containsKey('details')) {
            throw DetailedApiException.fromJson(response.statusCode, jsonResponse);
          } else {
            throw ApiException.fromJson(response.statusCode, jsonResponse);
          }
        }
      } catch (e) {
        if (e is ApiException) rethrow;
        throw ApiException(response.statusCode, 'Failed to parse response: ${response.body}');
      }
    }
  }
}

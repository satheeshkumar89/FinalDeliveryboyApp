import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_response.dart';
import 'api_exception.dart';
import '../utils/navigator_service.dart';
import '../../routes/app_routes.dart';

class ApiClient {
  final String baseUrl;
  final http.Client _client;
  String? _authToken;

  ApiClient({required this.baseUrl, http.Client? client})
    : _client = client ?? http.Client();

  // Set authentication token
  void setAuthToken(String token) {
    _authToken = token;
  }

  // Clear authentication token
  void clearAuthToken() {
    _authToken = null;
  }

  // Get default headers
  Map<String, String> _getHeaders({Map<String, String>? additionalHeaders}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }

    return headers;
  }

  // Generic GET request
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final uri = Uri.parse(
        '$baseUrl$endpoint',
      ).replace(queryParameters: queryParameters);

      final response = await _client.get(
        uri,
        headers: _getHeaders(additionalHeaders: headers),
      );

      return _handleResponse<T>(response, fromJson);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  // Generic POST request
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final uri = Uri.parse(
        '$baseUrl$endpoint',
      ).replace(queryParameters: queryParameters);

      final response = await _client.post(
        uri,
        headers: _getHeaders(additionalHeaders: headers),
        body: body != null ? jsonEncode(body) : null,
      );

      return _handleResponse<T>(response, fromJson);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  // Generic PUT request
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');

      final response = await _client.put(
        uri,
        headers: _getHeaders(additionalHeaders: headers),
        body: body != null ? jsonEncode(body) : null,
      );

      return _handleResponse<T>(response, fromJson);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  // Generic DELETE request
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    Map<String, String>? headers,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');

      final response = await _client.delete(
        uri,
        headers: _getHeaders(additionalHeaders: headers),
      );

      return _handleResponse<T>(response, fromJson);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  // Handle API response
  ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(dynamic)? fromJson,
  ) {
    final statusCode = response.statusCode;
    final body = response.body;

    // Parse JSON response
    dynamic jsonResponse;
    try {
      jsonResponse = jsonDecode(body);
    } catch (e) {
      throw ApiException(
        message: 'Failed to parse response',
        statusCode: statusCode,
      );
    }

    // Handle authentication errors globally
    if (statusCode == 401 ||
        statusCode == 403 ||
        (jsonResponse is Map<String, dynamic> &&
            jsonResponse['detail'] == 'Invalid authentication credentials')) {
      print("🚨 Auth Error Detected: Redirecting to Login");

      // Clear token if stored locally (optional, but good practice if you have access to storage here)
      _authToken = null;

      // Use the global navigator key to redirect
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        AppRoutes.phoneLogin,
        (route) => false,
      );

      throw ApiException(
        message: 'Session expired. Please login again.',
        statusCode: statusCode,
      );
    }

    // Handle successful responses (200-299)
    if (statusCode >= 200 && statusCode < 300) {
      print("✅ API SUCCESS [$statusCode] => ${response.request?.url}");
      print("🔵 Response Body: $jsonResponse");
      // Check if response follows the standard wrapper format
      if (jsonResponse is Map<String, dynamic> &&
          jsonResponse.containsKey('success')) {
        return ApiResponse<T>.fromJson(jsonResponse, fromJson);
      }

      // If not wrapped, treat the entire response as data
      // and assume success since status code is 2xx
      return ApiResponse<T>(
        success: true,
        message: 'Success',
        data: fromJson != null ? fromJson(jsonResponse) : jsonResponse as T?,
      );
    }

    // Handle error responses
    print("❌ API ERROR [$statusCode] => ${response.request?.url}");
    print("🔴 Error Body: $jsonResponse");

    // Handle error responses
    throw ApiException(
      message:
          jsonResponse['message'] ??
          jsonResponse['detail'] ??
          'Unknown error occurred',
      statusCode: statusCode,
      errors: jsonResponse['errors'],
    );
  }

  // Dispose client
  void dispose() {
    _client.close();
  }
}

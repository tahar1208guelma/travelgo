import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'api_result.dart';

/// Secure Enterprise API Client for TRAVELGO
/// Handles authentication headers, idempotency keys, timeout control, and error translation.
class ApiClient {
  final String baseUrl;
  final Duration timeout;
  String? _authToken;

  ApiClient({
    this.baseUrl = 'https://api.travelgo.com/v1',
    this.timeout = const Duration(seconds: 15),
  });

  void setAuthToken(String? token) {
    _authToken = token;
  }

  Map<String, String> _buildHeaders({String? idempotencyKey, Map<String, String>? extraHeaders}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Client-Platform': Platform.operatingSystem,
      'X-App-Version': '1.0.0',
    };

    if (_authToken != null && _authToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    if (idempotencyKey != null && idempotencyKey.isNotEmpty) {
      headers['Idempotency-Key'] = idempotencyKey;
    }

    if (extraHeaders != null) {
      headers.addAll(extraHeaders);
    }

    return headers;
  }

  /// Executes GET request with query parameters
  Future<ApiResult<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic json) responseParser,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = _buildUri(path, queryParameters);
      debugPrint('[ApiClient] GET $uri');

      // Simulate robust network call or execute HttpClient
      final client = HttpClient();
      client.connectionTimeout = timeout;

      final request = await client.getUrl(uri).timeout(timeout);
      _buildHeaders(extraHeaders: headers).forEach((k, v) => request.headers.set(k, v));

      final response = await request.close().timeout(timeout);
      final responseBody = await response.transform(utf8.decoder).join();
      client.close();

      return _processResponse<T>(response.statusCode, responseBody, responseParser);
    } on TimeoutException {
      return const ApiFailure('Request timed out. Please check your internet connection.', code: 'TIMEOUT');
    } on SocketException catch (e) {
      return ApiFailure('Network connection failed: ${e.message}', code: 'NETWORK_ERROR');
    } catch (e) {
      debugPrint('[ApiClient] Error in GET $path: $e');
      return ApiFailure('Unexpected error: $e', code: 'UNKNOWN');
    }
  }

  /// Executes POST request with JSON payload and Idempotency Key
  Future<ApiResult<T>> post<T>(
    String path, {
    Map<String, dynamic>? body,
    String? idempotencyKey,
    required T Function(dynamic json) responseParser,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = _buildUri(path, null);
      debugPrint('[ApiClient] POST $uri (Idempotency: $idempotencyKey)');

      final client = HttpClient();
      client.connectionTimeout = timeout;

      final request = await client.postUrl(uri).timeout(timeout);
      _buildHeaders(idempotencyKey: idempotencyKey, extraHeaders: headers)
          .forEach((k, v) => request.headers.set(k, v));

      if (body != null) {
        final jsonPayload = jsonEncode(body);
        request.add(utf8.encode(jsonPayload));
      }

      final response = await request.close().timeout(timeout);
      final responseBody = await response.transform(utf8.decoder).join();
      client.close();

      return _processResponse<T>(response.statusCode, responseBody, responseParser);
    } on TimeoutException {
      return const ApiFailure('Connection timed out. Please retry.', code: 'TIMEOUT');
    } on SocketException catch (e) {
      return ApiFailure('Connection failed: ${e.message}', code: 'NETWORK_ERROR');
    } catch (e) {
      debugPrint('[ApiClient] Error in POST $path: $e');
      return ApiFailure('Unexpected error: $e', code: 'UNKNOWN');
    }
  }

  Uri _buildUri(String path, Map<String, dynamic>? queryParameters) {
    final fullUrl = path.startsWith('http') ? path : '$baseUrl$path';
    final parsed = Uri.parse(fullUrl);

    if (queryParameters != null && queryParameters.isNotEmpty) {
      final stringParams = queryParameters.map((k, v) => MapEntry(k, v.toString()));
      return parsed.replace(queryParameters: {...parsed.queryParameters, ...stringParams});
    }

    return parsed;
  }

  ApiResult<T> _processResponse<T>(
    int statusCode,
    String responseBody,
    T Function(dynamic json) responseParser,
  ) {
    if (statusCode >= 200 && statusCode < 300) {
      try {
        final dynamic decoded = responseBody.isNotEmpty ? jsonDecode(responseBody) : {};
        final parsedData = responseParser(decoded);
        return ApiSuccess(parsedData);
      } catch (e) {
        return ApiFailure('Failed to parse server response: $e', statusCode: statusCode);
      }
    }

    // Error handling
    try {
      final decoded = jsonDecode(responseBody);
      final errorMsg = decoded['message'] ?? decoded['error'] ?? 'Server error ($statusCode)';
      final errorCode = decoded['code'] as String?;
      return ApiFailure(errorMsg, code: errorCode, statusCode: statusCode);
    } catch (_) {
      return ApiFailure('Request failed with HTTP status $statusCode', statusCode: statusCode);
    }
  }
}

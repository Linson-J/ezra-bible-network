import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// Thin JSON-over-HTTP client for the backend contract in the README.
class ApiClient {
  ApiClient({required this.baseUrl, http.Client? client, this.timeout = const Duration(seconds: 15)})
      : _client = client ?? http.Client();

  final String baseUrl;
  final Duration timeout;
  final http.Client _client;

  static const _headers = {'Accept': 'application/json', 'Content-Type': 'application/json'};

  Uri _uri(String path, [Map<String, String>? query]) =>
      Uri.parse('$baseUrl$path').replace(queryParameters: query);

  Future<dynamic> get(String path, {Map<String, String>? query}) async {
    final res = await _client.get(_uri(path, query), headers: _headers).timeout(timeout);
    return _decode(res);
  }

  Future<dynamic> post(String path, Map<String, dynamic> body) async {
    final res = await _client
        .post(_uri(path), headers: _headers, body: jsonEncode(body))
        .timeout(timeout);
    return _decode(res);
  }

  dynamic _decode(http.Response res) {
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ApiException('HTTP ${res.statusCode} for ${res.request?.url}', statusCode: res.statusCode);
    }
    if (res.body.isEmpty) return null;
    return jsonDecode(utf8.decode(res.bodyBytes));
  }

  void close() => _client.close();
}

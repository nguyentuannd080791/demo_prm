import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../error/app_exception.dart';
import 'api_endpoints.dart';

typedef TokenReader = Future<String?> Function();

class ApiClient {
  ApiClient({
    required this.httpClient,
    required this.readToken,
    this.onUnauthorized,
  });

  static const _timeout = Duration(seconds: 15);

  final http.Client httpClient;
  final TokenReader readToken;
  final void Function()? onUnauthorized;

  Future<dynamic> get(String path, {Map<String, String>? queryParameters}) =>
      _send('GET', path, queryParameters: queryParameters);

  Future<dynamic> post(String path, {Map<String, dynamic>? body}) =>
      _send('POST', path, body: body);

  Future<dynamic> put(String path, {Map<String, dynamic>? body}) =>
      _send('PUT', path, body: body);

  Future<dynamic> delete(String path) => _send('DELETE', path);

  Future<dynamic> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParameters,
  }) async {
    final token = await readToken();
    var uri = Uri.parse('${ApiEndpoints.baseUrl}$path');
    if (queryParameters != null && queryParameters.isNotEmpty) {
      uri = uri.replace(queryParameters: queryParameters);
    }
    final request = http.Request(method, uri)
      ..headers['Content-Type'] = 'application/json'
      ..headers['Accept'] = 'application/json';
    if (token != null) request.headers['Authorization'] = 'Bearer $token';
    if (body != null) request.body = jsonEncode(body);

    final http.Response response;
    try {
      final streamed = await httpClient.send(request).timeout(_timeout);
      response = await http.Response.fromStream(streamed);
    } on SocketException {
      throw const AppException('Không thể kết nối máy chủ');
    } on TimeoutException {
      throw const AppException('Máy chủ phản hồi quá lâu, vui lòng thử lại');
    }
    return _handle(response, hadToken: token != null);
  }

  dynamic _handle(http.Response response, {required bool hadToken}) {
    final data = _decodeBody(response);
    final isSuccess = response.statusCode >= 200 && response.statusCode < 300;
    if (isSuccess) return data;
    // 401 khi chưa có token là sai thông tin đăng nhập, không phải hết phiên.
    if (response.statusCode == 401 && hadToken) {
      onUnauthorized?.call();
      throw const UnauthorizedException();
    }
    throw AppException(_errorMessage(data, response.statusCode));
  }

  dynamic _decodeBody(http.Response response) {
    if (response.bodyBytes.isEmpty) return null;
    try {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException {
      return null;
    }
  }

  String _errorMessage(dynamic data, int statusCode) {
    if (data is Map && data['message'] is String) {
      return data['message'] as String;
    }
    return 'Yêu cầu thất bại (mã $statusCode)';
  }
}

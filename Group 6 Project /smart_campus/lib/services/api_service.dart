import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ApiService {
  static String? _token;

  String? get token => _token;

  void setToken(String? token) {
    _token = token;
  }

  Map<String, String> _getHeaders() {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (_token != null && _token!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  Uri _buildUri(String endpoint) {
    if (endpoint.startsWith('http://') || endpoint.startsWith('https://')) {
      return Uri.parse(endpoint);
    }
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    return Uri.parse('${ApiConfig.baseUrl}$cleanEndpoint');
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isNotEmpty) {
        return jsonDecode(response.body);
      }
      return null;
    } else {
      String errorMessage = 'Request failed with status: ${response.statusCode}';
      try {
        final errorBody = jsonDecode(response.body);
        if (errorBody is Map && errorBody.containsKey('message')) {
          errorMessage = errorBody['message'];
        } else if (errorBody is Map && errorBody.containsKey('error')) {
          errorMessage = errorBody['error'];
        }
      } catch (_) {
        // Fallback to default message
      }
      throw Exception(errorMessage);
    }
  }

  Future<dynamic> get(String endpoint) async {
    final url = _buildUri(endpoint);
    final response = await http.get(url, headers: _getHeaders());
    return _handleResponse(response);
  }

  Future<dynamic> post(String endpoint, [dynamic body]) async {
    final url = _buildUri(endpoint);
    final response = await http.post(
      url,
      headers: _getHeaders(),
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  Future<dynamic> put(String endpoint, [dynamic body]) async {
    final url = _buildUri(endpoint);
    final response = await http.put(
      url,
      headers: _getHeaders(),
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  Future<dynamic> delete(String endpoint) async {
    final url = _buildUri(endpoint);
    final response = await http.delete(url, headers: _getHeaders());
    return _handleResponse(response);
  }
}

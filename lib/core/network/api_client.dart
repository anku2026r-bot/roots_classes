import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../services/session_service.dart';
import '../utils/app_logger.dart';
import 'api_constants.dart';
import 'api_exceptions.dart';

class ApiClient {
  final http.Client _client;
  final SessionService _sessionService;

  ApiClient({
    http.Client? client,
    required SessionService sessionService,
  })  : _client = client ?? http.Client(),
        _sessionService = sessionService;

  Map<String, String> _buildHeaders({Map<String, String>? extraHeaders}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final token = _sessionService.getSessionToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    if (extraHeaders != null) {
      headers.addAll(extraHeaders);
    }
    return headers;
  }

  static String? _verifiedBaseUrl;
  static DateTime? _lastUnreachableTimestamp;
  static const Duration _offlineCooldown = Duration(seconds: 15);

  List<String> get _candidateBaseUrls {
    final primary = ApiConstants.baseUrl;
    final urls = <String>[];
    if (_verifiedBaseUrl != null) {
      urls.add(_verifiedBaseUrl!);
    }
    if (!urls.contains(primary)) {
      urls.add(primary);
    }
    if (primary.contains('localhost')) {
      final lan = primary.replaceAll('localhost', '192.168.1.26');
      final loopback = primary.replaceAll('localhost', '10.0.2.2');
      if (!urls.contains(lan)) urls.add(lan);
      if (!urls.contains(loopback)) urls.add(loopback);
    }
    return urls;
  }

  /// Sends a GET request
  Future<dynamic> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    final now = DateTime.now();
    if (_lastUnreachableTimestamp != null &&
        now.difference(_lastUnreachableTimestamp!) < _offlineCooldown &&
        _verifiedBaseUrl == null) {
      // Backend was unreachable a moment ago; fast fail immediately so offline/cached data loads in 0ms
      throw NetworkException('Backend currently unreachable (fast-fail mode)');
    }

    final requestHeaders = _buildHeaders(extraHeaders: headers);
    final stopwatch = Stopwatch()..start();
    final candidateBases = _candidateBaseUrls;

    Object? lastError;
    for (int i = 0; i < candidateBases.length; i++) {
      final base = candidateBases[i];
      final fullUrl = endpoint.startsWith('http') ? endpoint : '$base$endpoint';
      Uri uri = Uri.parse(fullUrl);
      if (queryParameters != null && queryParameters.isNotEmpty) {
        final stringParams = queryParameters.map((k, v) => MapEntry(k, v.toString()));
        uri = uri.replace(queryParameters: stringParams);
      }

      AppLogger.logRequest(
        method: 'GET',
        uri: uri,
        headers: requestHeaders,
      );

      try {
        final response = await _client
            .get(uri, headers: requestHeaders)
            .timeout(ApiConstants.receiveTimeout);

        AppLogger.logResponse(
          method: 'GET',
          uri: uri,
          statusCode: response.statusCode,
          duration: stopwatch.elapsed,
          body: response.body,
        );

        _verifiedBaseUrl = base;
        _lastUnreachableTimestamp = null;
        if (base != ApiConstants.baseUrl && !endpoint.startsWith('http')) {
          ApiConstants.baseUrl = base;
        }

        return _handleResponse(response);
      } on SocketException catch (e) {
        lastError = e;
        AppLogger.logHttpError(method: 'GET', uri: uri, error: e);
      } on TimeoutException catch (e) {
        lastError = e;
        AppLogger.logHttpError(method: 'GET', uri: uri, error: e);
      } on http.ClientException catch (e) {
        lastError = e;
        AppLogger.logHttpError(method: 'GET', uri: uri, error: e);
      } catch (e) {
        AppLogger.logHttpError(method: 'GET', uri: uri, error: e);
        rethrow;
      }
    }

    _lastUnreachableTimestamp = DateTime.now();
    _verifiedBaseUrl = null;

    if (lastError is TimeoutException) {
      throw TimeoutException();
    }
    throw NetworkException('Unable to reach backend server at ${ApiConstants.baseUrl}.');
  }

  /// Sends a POST request
  Future<dynamic> post(
    String endpoint, {
    dynamic body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    final now = DateTime.now();
    if (_lastUnreachableTimestamp != null &&
        now.difference(_lastUnreachableTimestamp!) < _offlineCooldown &&
        _verifiedBaseUrl == null) {
      // Backend was unreachable a moment ago; fast fail immediately so offline/cached data loads in 0ms
      throw NetworkException('Backend currently unreachable (fast-fail mode)');
    }

    final requestHeaders = _buildHeaders(extraHeaders: headers);
    final stopwatch = Stopwatch()..start();
    final candidateBases = _candidateBaseUrls;

    Object? lastError;
    for (int i = 0; i < candidateBases.length; i++) {
      final base = candidateBases[i];
      final fullUrl = endpoint.startsWith('http') ? endpoint : '$base$endpoint';
      Uri uri = Uri.parse(fullUrl);
      if (queryParameters != null && queryParameters.isNotEmpty) {
        final stringParams = queryParameters.map((k, v) => MapEntry(k, v.toString()));
        uri = uri.replace(queryParameters: stringParams);
      }

      AppLogger.logRequest(
        method: 'POST',
        uri: uri,
        headers: requestHeaders,
        body: body,
      );

      try {
        final response = await _client
            .post(
              uri,
              headers: requestHeaders,
              body: body != null ? jsonEncode(body) : null,
            )
            .timeout(ApiConstants.receiveTimeout);

        AppLogger.logResponse(
          method: 'POST',
          uri: uri,
          statusCode: response.statusCode,
          duration: stopwatch.elapsed,
          body: response.body,
        );

        _verifiedBaseUrl = base;
        _lastUnreachableTimestamp = null;
        if (base != ApiConstants.baseUrl && !endpoint.startsWith('http')) {
          ApiConstants.baseUrl = base;
        }

        return _handleResponse(response);
      } on SocketException catch (e) {
        lastError = e;
        AppLogger.logHttpError(method: 'POST', uri: uri, error: e);
      } on TimeoutException catch (e) {
        lastError = e;
        AppLogger.logHttpError(method: 'POST', uri: uri, error: e);
      } on http.ClientException catch (e) {
        lastError = e;
        AppLogger.logHttpError(method: 'POST', uri: uri, error: e);
      } catch (e) {
        AppLogger.logHttpError(method: 'POST', uri: uri, error: e);
        rethrow;
      }
    }

    _lastUnreachableTimestamp = DateTime.now();
    _verifiedBaseUrl = null;

    if (lastError is TimeoutException) {
      throw TimeoutException();
    }
    throw NetworkException('Unable to reach backend server at ${ApiConstants.baseUrl}.');
  }

  dynamic _handleResponse(http.Response response) {
    final int code = response.statusCode;
    dynamic body;

    try {
      if (response.body.isNotEmpty) {
        body = jsonDecode(response.body);
      }
    } catch (_) {
      body = response.body;
    }

    if (code >= 200 && code < 300) {
      return body;
    }

    switch (code) {
      case 400:
        throw ApiException(
          body is Map && body['message'] != null
              ? body['message']
              : 'Bad Request. Please check your parameters.',
          statusCode: 400,
          details: body,
        );
      case 401:
        throw UnauthorizedException(
          body is Map && body['message'] != null
              ? body['message']
              : 'Unauthorized access. Please login again.',
        );
      case 404:
        throw NotFoundException(
          body is Map && body['message'] != null
              ? body['message']
              : 'Requested resource not found.',
        );
      case 500:
      case 502:
      case 503:
        throw ServerException(
          body is Map && body['message'] != null
              ? body['message']
              : 'Server error occurred. Please try again later.',
        );
      default:
        throw ApiException(
          body is Map && body['message'] != null
              ? body['message']
              : 'Unexpected error occurred ($code).',
          statusCode: code,
          details: body,
        );
    }
  }
}

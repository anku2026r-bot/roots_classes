class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic details;

  ApiException(this.message, {this.statusCode, this.details});

  @override
  String toString() => message;
}

class NetworkException extends ApiException {
  NetworkException([super.message = 'Unable to connect to server. Please check your internet connection.']);
}

class TimeoutException extends NetworkException {
  TimeoutException([super.message = 'Connection timed out. Please try again.']);
}

class UnauthorizedException extends ApiException {
  UnauthorizedException([super.message = 'Your session has expired. Please sign in again.'])
      : super(statusCode: 401);
}

class NotFoundException extends ApiException {
  NotFoundException([super.message = 'Requested resource not found.'])
      : super(statusCode: 404);
}

class ServerException extends ApiException {
  ServerException([super.message = 'Internal server error occurred. Please try again later.'])
      : super(statusCode: 500);
}

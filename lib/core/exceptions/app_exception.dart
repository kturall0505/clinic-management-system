class AppException implements Exception {
  final String message;
  final dynamic cause;

  const AppException(this.message, [this.cause]);

  @override
  String toString() => 'AppException: $message${cause != null ? '\nCaused by: $cause' : ''}';
}

class ValidationException extends AppException {
  const ValidationException(String message) : super(message);
}

class NetworkException extends AppException {
  const NetworkException(String message, [dynamic cause]) : super(message, cause);
}

class StorageException extends AppException {
  const StorageException(String message, [dynamic cause]) : super(message, cause);
}

class AuthException extends AppException {
  const AuthException(String message) : super(message);
}

class LicenseException extends AppException {
  const LicenseException(String message) : super(message);
}

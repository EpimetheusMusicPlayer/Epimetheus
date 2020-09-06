import 'dart:io';

abstract class PandoraException implements Exception {
  final String errorString;
  final String message;
  final int errorCode;

  const PandoraException({this.errorString, this.message, this.errorCode});

  @override
  String toString() => 'Pandora API error $errorCode: $errorString: $message.';
}

void throwException(String errorString, String message, int errorCode, [int statusCode, String apiCall]) {
  switch (errorString) {
    case InvalidRequestException.normalErrorString:
      throw InvalidRequestException(message, errorCode);
    case InvalidAuthException.normalErrorString:
      throw InvalidAuthException(message, errorCode);
    case LocationException.normalErrorString:
      throw LocationException();
    default:
      print('UNKNOWN PANDORA ERROR: $statusCode, $apiCall, $errorString, $message, $errorCode');
      throw UnknownPandoraErrorException(statusCode, apiCall, errorString, message, errorCode);
  }
}

class UnknownPandoraErrorException extends PandoraException {
  final int statusCode;
  final String apiCall;

  const UnknownPandoraErrorException(this.statusCode, this.apiCall, String errorString, String message, int errorCode)
      : super(
          errorString: errorString ?? (statusCode == HttpStatus.internalServerError ? 'Internal server error - API: $apiCall' : 'Unknown HTTP error - API: $apiCall, HTTP: $statusCode'),
          message: message,
          errorCode: errorCode,
        );
}

class InvalidRequestException extends PandoraException {
  static const String normalErrorString = 'INVALID_REQUEST';

  const InvalidRequestException(String message, int errorCode) : super(errorString: normalErrorString, message: message, errorCode: errorCode);
}

class InvalidAuthException extends PandoraException {
  static const String normalErrorString = 'AUTH_INVALID_USERNAME_PASSWORD';

  const InvalidAuthException(String message, int errorCode) : super(errorString: normalErrorString, message: message, errorCode: errorCode);
}

class LocationException extends PandoraException {
  static const String normalErrorString = 'INVALID_LOCATION';

  const LocationException() : super(errorString: normalErrorString, message: 'Cannot stream to this location.', errorCode: 0);
}

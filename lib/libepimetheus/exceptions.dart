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
  if (errorString == InvalidRequestException.ERROR_STRING) {
    throw InvalidRequestException(message, errorCode);
  }

  throw UnknownPandoraErrorException(statusCode, apiCall, errorString, message, errorCode);
}

class UnknownPandoraErrorException extends PandoraException {
  final int statusCode;
  final String apiCall;

  const UnknownPandoraErrorException(this.statusCode, this.apiCall, String errorString, String message, int errorCode)
      : super(
          errorString: errorString ?? statusCode == HttpStatus.internalServerError ? 'Internal server error - API: $apiCall' : 'Unknown HTTP error - API: $apiCall, HTTP: $statusCode',
          message: message,
          errorCode: errorCode,
        );
}

class InvalidRequestException extends PandoraException {
  static const String ERROR_STRING = 'INVALID_REQUEST';

  const InvalidRequestException(String message, int errorCode) : super(errorString: ERROR_STRING, message: message, errorCode: errorCode);
}

class LocationException extends PandoraException {
  static const String ERROR_STRING = 'INVALID_LOCATION';

  const LocationException() : super(errorString: ERROR_STRING, message: 'Cannot stream to this location.', errorCode: 0);
}

abstract class PandoraException implements Exception {
  final String errorString;
  final String message;
  final int errorCode;

  PandoraException({this.errorString, this.message, this.errorCode});

  @override
  String toString() => 'Pandora API error $errorCode: $errorString: $message.';
}

void throwException(String errorString, String message, int errorCode) {
//  print("$errorString, $message, $errorCode");
  if (errorString == InvalidRequestException.ERROR_STRING) {
    throw InvalidRequestException(message, errorCode);
  }
}

class InvalidRequestException extends PandoraException {
  static const String ERROR_STRING = 'INVALID_REQUEST';

  InvalidRequestException(String message, int errorCode) : super(errorString: ERROR_STRING, message: message, errorCode: errorCode);
}

class LocationException extends PandoraException {
  static const String ERROR_STRING = 'INVALID_LOCAATION';

  LocationException() : super(errorString: ERROR_STRING, message: 'Cannot stream to this location.', errorCode: 0);
}

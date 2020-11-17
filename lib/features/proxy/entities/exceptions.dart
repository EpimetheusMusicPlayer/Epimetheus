abstract class ProxyException implements Exception {
  const ProxyException();
}

class ProxyNetworkException extends ProxyException {
  const ProxyNetworkException();
}

class ProxyAuthException extends ProxyException {
  const ProxyAuthException();
}

class ProxyNoneFoundException extends ProxyException {
  const ProxyNoneFoundException();
}

class ProxyUnknownException extends ProxyException {
  const ProxyUnknownException();
}

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart';

/// This class can XOR Pandora encrypted playlist media byte-by-byte,
/// or chunk-by-chunk.
class XORDecoder {
  final List<int> key;

  XORDecoder(this.key);

  int keyIndex = 0;

  int decodeNextByte(int byte) {
    if (keyIndex == key.length) keyIndex = 0;
    return byte ^ key[keyIndex++];
  }

  Uint8List decodeNextBytes(List<int> bytes) {
    final output = Uint8List(bytes.length);

    for (var i = 0; i < output.length; ++i) {
      if (keyIndex == key.length) keyIndex = 0;
      output[i] = bytes[i] ^ key[keyIndex++];
    }

    return output;
  }

  Stream<List<int>> mapStream(ByteStream stream) {
    return stream.map(_streamMapper);
  }

  Uint8List _streamMapper(List<int> bytes) => decodeNextBytes(bytes);

  /// A method to xor an entire list
  static Uint8List xor(List<int> input, List<int> key) {
    final output = Uint8List(input.length);

    int keyIndex = 0;
    for (var i = 0; i < output.length; ++i) {
      output[i] = input[i] ^ key[keyIndex++];
      if (keyIndex == key.length) keyIndex = 0;
    }

    return output;
  }
}

/// This class handles decryption of XOR encrypted media.
/// It provides a proxy server that acts as middleware
/// between audio plugins and Pandora's servers,
/// decrypting data on-the-fly.
class XORDecryptionProxy {
  // Content type used in responses.
  static final _contentType = ContentType.parse('audio/mp4');

  // Create a client to make requests with.
  static final _client = Client();

  // The HTTP server.
  HttpServer _server;

  // These maps hold data about CDN hostnames and decryption
  // keys against a token unique to each encrypted track media
  // URL.
  final _keyMap = <String, String>{};
  final _cdnHostMap = <String, String>{};

  // Save a remote URL CDN hostname and decryption key
  // against it's unique token.
  Uri addUrl(String url, String key) {
    final remoteUri = Uri.parse(url);

    final localUri = remoteUri.replace(
      scheme: 'http',
      host: InternetAddress.loopbackIPv4.address,
      port: _server.port,
    );

    final token = remoteUri.queryParameters['token'];

    _cdnHostMap[token] = remoteUri.host;
    _keyMap[token] = key;

    return localUri;
  }

  void clearAllExceptUrl(String url) {
    final token = Uri.parse(url).queryParameters['token'];
    print('REMOVING, ALL OTHER THAN: $token');
    removeUrlWhere((existingToken) => existingToken != token);
  }

  void removeUrlWhere(bool predicate(String token)) {
    _cdnHostMap.removeWhere((token, host) => predicate(token));
    _keyMap.removeWhere((token, key) => predicate(token));
  }

  void clearUrls() {
    print('CLEARING URLS');
    _cdnHostMap.clear();
    _keyMap.clear();
  }

  // Starts the server.
  Future<void> start() async {
    // Start an HTTP server on a port decided by the OS.
    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);

    // Handle requests.
    _server.listen((request) async {
      // Record a token unique to each URI.
      final token = request.uri.queryParameters['token'];

      // Check if the token is known and the request is GET.
      if (_keyMap.containsKey(token) && request.method == 'GET') {
        // Create a request for the real, encrypted, media.
        final response = await _client.send(
          await Request(
            'GET',
            request.uri.replace(
              scheme: 'https',
              host: _cdnHostMap[token],
              port: HttpClient.defaultHttpsPort,
            ),
          ),
        );

        // Set some HTTP properties.
        request.response.headers.contentType = _contentType;
        request.response.contentLength = response.contentLength;
        request.response.statusCode = response.statusCode;

        // Create the decoder, which can decrypt the encrypted data stream.
        final decoder = XORDecoder(base64Decode(_keyMap[token]));

        // Map the encrypted data stream to a decrypted stream, and pipe it
        // to the response of the original HTTP request.
        decoder.mapStream(response.stream).pipe(request.response);
      } else {
        print('${request.method}, TOKEN NOT FOUND: ${request.uri.queryParameters['name']}');
        // If it's not either of those things, 404.
        request.response.statusCode = HttpStatus.notFound;
        request.response.contentLength = 0;
        request.response.close();
      }
    });
  }

  // Closes the server.
  Future stop() => _server.close();
}

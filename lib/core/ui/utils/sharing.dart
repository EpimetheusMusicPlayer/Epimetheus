import 'dart:io';
import 'dart:typed_data';

import 'package:epimetheus/core/api_utils/sharing.dart';
import 'package:epimetheus_nullable/mobx/api/api_store.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:iapetus/iapetus.dart';
import 'package:mime/mime.dart';
import 'package:pedantic/pedantic.dart';

/// The project's homepage.
const _epimetheusHomepageUrl = 'https://epimetheus.tk';

/// An invitation to use the project, appended to the share message.
const _epimetheusInvitation =
    'Listen with the Epimetheus app: $_epimetheusHomepageUrl';

/// Attempts to fetch an item's shareable URL and copy it to the clipboard.
/// Does nothing, and returns false, if the operation is unsuccessful.
///
/// A [BuildContext] may be provided to show a snackbar based on the
/// success.
Future<bool> shareMedia(
  Shareable shareable, [
  BuildContext? context,
]) async {
  // Find the scaffold messenger.
  final scaffoldMessenger =
      context == null ? null : ScaffoldMessenger.of(context);

  // Remove any existing snackbars, and show a loading one.
  scaffoldMessenger?.hideCurrentSnackBar();
  scaffoldMessenger?.showSnackBar(
    SnackBar(
      content: Text('Sharing "${shareable.shareName}"...'),
    ),
  );

  // Generate the share URL.
  var shareUrl = await tryGetShareableUrl(shareable);

  // Detect platform share support (only on Android and iOS).
  final hasPlatformShareSupport =
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  // Download the image, if a URI is provided by the [Shareable].
  late final Uint8List? shareImageBytes;
  final shareImageUri = shareable.shareImageUri;
  if (hasPlatformShareSupport && shareImageUri != null) {
    try {
      shareImageBytes =
          (await GetIt.instance<ApiStore>().api.client.get(shareImageUri))
              .bodyBytes;
    } on SocketException {
      shareImageBytes = null;
    } on HttpException {
      shareImageBytes = null;
    }
  } else {
    shareImageBytes = null;
  }

  // Hide the loading snackbar in preparation to show the next one.
  scaffoldMessenger?.hideCurrentSnackBar();

  // If the generation was unsuccessful, show an error message and return false.
  if (shareUrl == null) {
    // TODO error catching isn't working
    scaffoldMessenger?.showSnackBar(
      SnackBar(
        content: Text('Could not share "${shareable.shareName}".'),
        action: SnackBarAction(
          label: 'Retry',
          onPressed: () => shareMedia(shareable, context),
        ),
      ),
    );

    return false;
  }

  if (hasPlatformShareSupport) {
    // If there's platform share support, use it.
    if (shareImageBytes == null) {
      // If there's no image, just share the text.
      Share.text(
        shareable.shareName,
        '${shareable.shareMessage}\n$shareUrl\n\n$_epimetheusInvitation',
        'text/plain',
      );
    } else {
      // Otherwise, share the image with the text.
      // Find the extension, used in the file name and to generate the mime type.
      late final String imageExtension;
      final imageUriPathSegments = shareImageUri!.pathSegments;
      if (imageUriPathSegments.isEmpty) {
        imageExtension = 'jpg';
      } else {
        final imageName = imageUriPathSegments.last;
        imageExtension = imageName.substring(imageName.lastIndexOf('.') + 1);
      }
      // Share.
      unawaited(
        Share.file(
          shareable.shareName,
          '${shareable.shareName}.$imageExtension',
          shareImageBytes,
          lookupMimeType(imageExtension),
          text:
              '${shareable.shareMessage}\n$shareUrl\n\n$_epimetheusInvitation',
        ),
      );
    }
  } else {
    // If there's no platform share support, copy the link to the clipboard and
    // show a snackbar to notify the user.
    await Clipboard.setData(ClipboardData(text: shareUrl));
    scaffoldMessenger?.showSnackBar(
      SnackBar(
        content: Text(
          'Link to "${shareable.shareName}" copied to the clipboard.',
        ),
      ),
    );
  }

  return true;
}

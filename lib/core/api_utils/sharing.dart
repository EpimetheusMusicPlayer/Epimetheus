import 'package:iapetus/iapetus.dart';

/// Attempts to get a shareable url, catching errors.
/// Will return null if there's a problem.
Future<String?> tryGetShareableUrl(Shareable shareable) async {
  try {
    return await shareable.getShareableUrl();
  } on IapetusNetworkException {
    return null;
  }
}

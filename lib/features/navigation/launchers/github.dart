import 'package:epimetheus/app_info.dart';
import 'package:iapetus/iapetus.dart';
import 'package:url_launcher/url_launcher.dart';

void launchApiGithubIssue(PandoraException exception) {
  final uri = Uri(
    scheme: 'https',
    host: 'github.com',
    path: '$appGithubPath/issues/new',
    queryParameters: {
      'title':
          'Pandora API error (${exception.errorCode}: ${exception.message}) when <doing action>',
      'labels': [
        'Pandora API error ${exception.errorCode}',
        'Pandora API error',
      ],
      'assignees': 'hacker1024',
      'body':
          // language=Markdown
          '''
<!-- Please fill in any <template properties> before submitting. -->
<!-- Do not remove any of the error data. -->
<!-- Search for other issues containing the error message before submitting this issue. -->

**Pandora API error details**
Error string: ${exception.errorString}
Error message: ${exception.message}
Error code: ${exception.errorCode}

**What action causes this error? Be specific.**

**Screenshots**
<!-- Add any screenshots here. -->
'''
    },
  );

  launch(uri.toString());
}

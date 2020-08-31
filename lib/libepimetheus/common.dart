import 'package:epimetheus/libepimetheus/authentication.dart';
import 'package:epimetheus/libepimetheus/networking.dart';

Future<Map<String, dynamic>> getAnnotations(User user, List<String> pandoraIds) {
  return makeApiRequest(
    version: 'v4',
    endpoint: 'catalog/annotateObjectsSimple',
    requestData: {
      'pandoraIds': pandoraIds,
    },
    user: user,
  );
}

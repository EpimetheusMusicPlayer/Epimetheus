import 'package:epimetheus/libepimetheus/authentication.dart';
import 'package:epimetheus/libepimetheus/structures/pandora_entity.dart';

abstract class CollectionProvider<T extends PandoraEntity> {
  /// Ask for the collection to be downloaded in the background.
  /// If the collection is paged, the first page should be downloaded.
  /// Returns true if already downloaded.
  bool getAsync(User user);

  /// Returns the downloaded items
  List<T> get downloaded;

  /// Clears any downloaded collection items.
  void clear();
}

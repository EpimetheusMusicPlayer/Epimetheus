import 'package:epimetheus/libepimetheus/authentication.dart';
import 'package:epimetheus/models/collection/station_collection_provider.dart';
import 'package:epimetheus/models/collection/track_collection_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:scoped_model/scoped_model.dart';

class CollectionModel extends Model {
  final _cacheManager = DefaultCacheManager();

  StationCollectionProvider _stationCollectionProvider;
  StationCollectionProvider get stationCollectionProvider => _stationCollectionProvider;

  TrackCollectionProvider _trackCollectionProvider;
  TrackCollectionProvider get trackCollectionProvider => _trackCollectionProvider;

  void fetchAll(User user) {
    _stationCollectionProvider.getAsync(user);
    _trackCollectionProvider.getAsync(user);
  }

  void clear() {
    _stationCollectionProvider.clear();
    _trackCollectionProvider.clear();
    notifyListeners();
  }

  CollectionModel() {
    _stationCollectionProvider = StationCollectionProvider(notifyListeners, _cacheManager);
    _trackCollectionProvider = TrackCollectionProvider(notifyListeners, _cacheManager);
  }

  static CollectionModel of(BuildContext context) => ScopedModel.of<CollectionModel>(context);
}

import 'package:epimetheus/audio/audio_task.dart';
import 'package:epimetheus/audio/music_provider.dart';
import 'package:epimetheus/libepimetheus/authentication.dart';
import 'package:epimetheus/libepimetheus/stations.dart';
import 'package:flutter/widgets.dart';
import 'package:scoped_model/scoped_model.dart';

class EpimetheusModel extends Model {
  User _user;
  User get user => _user;
  set user(user) {
    _user = user;
  }

  List<Station> _stations;
  List<Station> get stations => _stations;
  set stations(stations) {
    _stations = stations;
    notifyListeners();
  }

  MusicProvider _currentMusicProvider;
  MusicProvider get currentMusicProvider => _currentMusicProvider;
  set currentMusicProvider(musicProvider) {
    launchMusicProvider(user, musicProvider);
    _currentMusicProvider = musicProvider;
    notifyListeners();
  }

  static EpimetheusModel of(BuildContext context) => ScopedModel.of<EpimetheusModel>(context);
}

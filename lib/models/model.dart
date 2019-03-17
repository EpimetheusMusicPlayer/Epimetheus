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

  Color _inheritedAlbumArtColor;

  Color get inheritedAlbumArtColor => _inheritedAlbumArtColor;

  set inheritedAlbumArtColor(color) {
    _inheritedAlbumArtColor = color;
    notifyListeners();
  }

  Color _inheritedAlbumArtBodyColor;

  Color get inheritedAlbumArtBodyColor => _inheritedAlbumArtColor;

  set inheritedAlbumArtBodyColor(color) {
    _inheritedAlbumArtBodyColor = color;
    notifyListeners();
  }

  void updateColors({
    @required Color inheritedAlbumArtColor,
    @required Color inheritedAlbumArtBodyColor,
  }) {
    _inheritedAlbumArtColor = inheritedAlbumArtColor;
    _inheritedAlbumArtBodyColor = inheritedAlbumArtBodyColor;
    notifyListeners();
  }

  static EpimetheusModel of(BuildContext context, {bool rebuildOnChange = false}) => ScopedModel.of<EpimetheusModel>(context, rebuildOnChange: rebuildOnChange);
}

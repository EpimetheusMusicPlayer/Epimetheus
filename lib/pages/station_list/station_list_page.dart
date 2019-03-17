import 'package:epimetheus/audio/station_music_provider.dart';
import 'package:epimetheus/dialogs/no_connection_dialog.dart';
import 'package:epimetheus/libepimetheus/stations.dart';
import 'package:epimetheus/models/model.dart';
import 'package:epimetheus/pages/now_playing/now_playing_page.dart';
import 'package:epimetheus/widgets/dynamic_app_bar.dart';
import 'package:epimetheus/widgets/navigation_drawer_widget.dart';
import 'package:epimetheus/widgets/station_list_tile_widget.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class StationListPage extends StatefulWidget {
  @override
  _StationListPageState createState() => _StationListPageState();
}

class _StationListPageState extends State<StationListPage> {
  Future<void> loadStations() {
    final model = EpimetheusModel.of(context);
    return getStations(model.user, true).then(
      (stations) {
        stations.sort((Station station1, Station station2) {
          if (station1.isShuffle)
            return -2;
          else if (station2.isShuffle)
            return 2;
          else if (station1.isThumbprint)
            return -1;
          else if (station2.isThumbprint)
            return 1;
          else
            return Comparable.compare(station1.title, station2.title);
        });
        model.stations = stations;
      },
    ).catchError(
      (e) {
        showDialog(
          context: context,
          builder: noConnectionDialog(
            () {
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    if (EpimetheusModel.of(context).stations == null) loadStations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DynamicAppBar('Stations'),
      drawer: const NavigationDrawerWidget('/station_list'),
      body: ScopedModelDescendant<EpimetheusModel>(
        builder: (context, child, model) {
          if (model.stations == null) return child;
          return RefreshIndicator(
            onRefresh: loadStations,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              separatorBuilder: (context, index) => Divider(height: 0, indent: 88),
              itemBuilder: (context, index) {
                final int lastItemIndex = model.stations.length - 1;
                return Container(
                  margin: EdgeInsets.only(
                    top: index == 0 ? 8 : 0,
                    bottom: index == lastItemIndex ? 8 : 0,
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (BuildContext context) {
                            EpimetheusModel model = EpimetheusModel.of(context);
                            return NowPlayingPage(
                              model.user,
                              StationMusicProvider(model.stations, index),
                            );
                          },
                        ),
                      );
                    },
                    child: StationListTile(model.stations[index]),
                  ),
                );
              },
              itemCount: model.stations.length,
            ),
          );
        },
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}

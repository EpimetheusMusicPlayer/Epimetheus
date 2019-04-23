import 'package:epimetheus/audio/station_music_provider.dart';
import 'package:epimetheus/dialogs/no_connection_dialog.dart';
import 'package:epimetheus/libepimetheus/stations.dart';
import 'package:epimetheus/models/model.dart';
import 'package:epimetheus/pages/now_playing/now_playing_page.dart';
import 'package:epimetheus/widgets/media_control_widget.dart';
import 'package:epimetheus/widgets/navigation_drawer_widget.dart';
import 'package:epimetheus/widgets/station_list_tile_widget.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class StationListPage extends StatefulWidget {
  @override
  _StationListPageState createState() => _StationListPageState();
}

class _StationListPageState extends State<StationListPage> {
  Offset _stationMenuPosition;

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

  void _storeStationMenuPosition(TapDownDetails details) {
    _stationMenuPosition = details.globalPosition;
  }

  void _showStationMenu(Station station) {
    showMenu<String>(
      context: context,
      position:
          RelativeRect.fromRect(_stationMenuPosition & const Size(40, 40), Offset.zero & (Overlay.of(context).context.findRenderObject() as RenderBox).size),
      items: [
        PopupMenuItem<String>(
          value: 'feedback',
          child: const Text('Feedback'),
        ),
        if (station.canRename)
          PopupMenuItem<String>(
            value: 'rename',
            child: const Text('Rename station'),
          ),
        if (station.canDelete)
          PopupMenuItem<String>(
            value: 'delete',
            child: const Text('Delete station'),
          ),
      ],
    ).then((value) {
      switch (value) {
        case 'feedback':
          print('Feedback!');
          break;
        case 'rename':
          print('Rename!');
          break;
        case 'delete':
          print('Delete!');
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stations'),
      ),
      drawer: const NavigationDrawerWidget('/station_list'),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ScopedModelDescendant<EpimetheusModel>(
              builder: (context, child, model) {
                if (model.stations == null) return child;
                return RefreshIndicator(
                  onRefresh: loadStations,
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    separatorBuilder: (context, index) => Divider(height: 0, indent: 88),
                    itemBuilder: (context, index) {
                      final station = model.stations[index];
                      final int lastItemIndex = model.stations.length - 1;
                      return Container(
                        margin: EdgeInsets.only(
                          top: index == 0 ? 8 : 0,
                          bottom: index == lastItemIndex ? 8 : 0,
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).pushReplacement(
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
                          onTapDown: _storeStationMenuPosition,
                          onLongPress: () {
                            _showStationMenu(station);
                          },
                          child: StationListTile(station),
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
          ),
          MediaControlWidget(),
        ],
      ),
    );
  }
}

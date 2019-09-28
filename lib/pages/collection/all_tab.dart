import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:epimetheus/libepimetheus/exceptions.dart';
import 'package:epimetheus/libepimetheus/stations.dart';
import 'package:epimetheus/models/collection.dart';
import 'package:epimetheus/models/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:transparent_image/transparent_image.dart';

class AllTab extends StatefulWidget {
  @override
  _AllTabState createState() => _AllTabState();
}

class _AllTabState extends State<AllTab> with AutomaticKeepAliveClientMixin<AllTab> {
  @override
  bool get wantKeepAlive => true;

  List<Station> _stations;

  Future<bool> _loadData() async {
    try {
      _stations = await CollectionModel.of(context).getStations(UserModel.of(context).user);
      return true;
    } on SocketException {
      return false;
    } on PandoraException {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder<bool>(
      future: _loadData(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          if (snapshot.data) {
            return ListView(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(
                    top: 16,
                    left: 16,
                    right: 16,
                  ),
                  child: const Text(
                    'Stations',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ),
                StationCarousel(stations: _stations),
              ],
            );
          } else {
            return Center(
              child: const Text(
                'There was an error fetching your stuff. Please try again.',
              ),
            );
          }
        }
      },
    );
  }
}

class StationCarousel extends StatelessWidget {
  final List<Station> stations;

  StationCarousel({
    @required this.stations,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          height: 204,
          padding: const EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 8,
          ),
          child: Row(
            children: <Widget>[
              for (Station station in stations)
                SizedBox(
                  width: 164,
                  child: StationTile(
                    station: station,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class StationTile extends StatefulWidget {
  final Station station;

  const StationTile({this.station});

  @override
  _StationTileState createState() => _StationTileState();
}

class _StationTileState extends State<StationTile> {
  PaletteGenerator _palette;

  Future<PaletteGenerator> getPalette() async {
    return _palette ??= await PaletteGenerator.fromImageProvider(NetworkImage(widget.station.getArtUrl(0)));
  }

  @override
  Widget build(BuildContext context) {
    Widget getCard(PaletteGenerator palette) {
      return Card(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          color: palette?.dominantColor?.color ?? Colors.black87,
          padding: const EdgeInsets.all(8),
          child: Column(
            children: <Widget>[
              Expanded(
                child: Stack(
                  children: <Widget>[
                    FadeInImage(
                      placeholder: MemoryImage(kTransparentImage),
                      image: CachedNetworkImageProvider(widget.station.getArtUrl(156)),
                      fadeOutDuration: const Duration(milliseconds: 1),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.station.title,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: TextStyle(
                    color: (palette?.dominantColor?.color?.computeLuminance() ?? 0) < 0.5 ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return _palette == null
        ? FutureBuilder<PaletteGenerator>(
            future: getPalette(),
            builder: (context, snapshot) => getCard(snapshot.data),
          )
        : getCard(_palette);
  }
}

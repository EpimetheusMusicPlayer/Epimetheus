import 'package:epimetheus/libepimetheus/songs.dart';
import 'package:epimetheus/models/user.dart';
import 'package:flutter/material.dart';

class TracksTab extends StatefulWidget {
  @override
  _TracksTabState createState() => _TracksTabState();
}

class _TracksTabState extends State<TracksTab> {
  String response = '';

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: <Widget>[
          RaisedButton(
              child: const Text('Test'),
              onPressed: () async {
                final tracks = await getTracks(
                  user: UserModel.of(context).user,
                  sortOrder: TrackSortOrder.dateAdded,
                  offset: 0,
                  pageSize: 100,
                );

                String responseString = '';
                for (Track track in tracks) {
                  responseString += (track.title + '\n');
                }

                setState(() {
                  response = responseString;
                });
              }),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Text(
                response,
                softWrap: false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

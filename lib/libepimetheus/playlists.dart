import 'package:epimetheus/libepimetheus/authentication.dart';
import 'package:epimetheus/libepimetheus/networking.dart';
import 'package:epimetheus/libepimetheus/structures/art/thor_art_item.dart';
import 'package:epimetheus/libepimetheus/structures/collection/paged_collection_list.dart';
import 'package:epimetheus/libepimetheus/structures/collection/playlist_entity_creator.dart';
import 'package:epimetheus/libepimetheus/structures/collection/track_entity_creator.dart';
import 'package:epimetheus/libepimetheus/structures/pandora_entity.dart';
import 'package:epimetheus/libepimetheus/tracks.dart';
import 'package:flutter/foundation.dart';

class Playlist extends PandoraEntity with ThorArtItem {
  final String thorLayers;
  final String name;
  final String description;
  final Duration duration;
  final int addedTime;
  final int updatedTime;
  final bool editable;

  Playlist({
    @required String pandoraId,
    @required this.thorLayers,
    @required this.name,
    @required this.description,
    @required this.duration,
    @required this.addedTime,
    @required this.updatedTime,
    @required this.editable,
  }) : super(pandoraId, PandoraEntityType.playlist);

  static PagedCollectionList<Playlist> _createListFromMap(Map<String, dynamic> map) {
    return PagedCollectionList<Playlist>.createFromMap(map, PlaylistEntityCreator(map['annotations'], map['items']));
  }

  static Future<PagedCollectionList<Playlist>> getPlaylists({
    @required User user,
    @required PagedCollectionListSortOrder sortOrder,
    @required int limit,
    @required int offset,
  }) async {
    return Playlist._createListFromMap(
      await makeApiRequest(
        version: 'v6',
        endpoint: 'collections/getSortedPlaylists',
        requestData: {
          'allowedTypes': [
            'TR',
            'AM',
          ],
          'isRecentModifiedPlaylists': false,
          'request': {
            'annotationLimit': limit,
            'limit': limit,
            'offset': offset,
            'sortOrder': PagedCollectionList.sortOrderNames[sortOrder],
          },
        },
        user: user,
      ),
    );
  }

  /// Note: the returned list's version must be saved and reused with future calls.
  static Future<PlaylistTrackList> getTracksFromId({
    @required String pandoraId,
    @required User user,
    @required int limit,
    @required int offset,
    @required int version,
  }) async {
    return PlaylistTrackList._createFromMap(
      await makeApiRequest(
        version: 'v7',
        endpoint: 'playlists/getTracks',
        requestData: {
          'request': {
            'pandoraId': pandoraId,
            'allowedTypes': [PandoraEntity.typeNames[PandoraEntityType.track]],
            'offset': offset,
            'limit': limit,
            'annotationLimit': limit,
            'bypassPrivacyRules': true, // Just mimicking the web app here; I have no idea what this does
            'playlistVersion': version,
          },
        },
        user: user,
      ),
      limit,
    );
  }

  /// Note: the returned list's version must be saved and reused with future calls.
  Future<PlaylistTrackList> getTracks({
    @required User user,
    @required int limit,
    @required int offset,
    @required int version,
  }) =>
      getTracksFromId(
        pandoraId: pandoraId,
        user: user,
        limit: limit,
        offset: offset,
        version: version,
      );
}

class PlaylistTrackList extends PagedCollectionList<Track> with ThorArtItem {
  final String pandoraId;
  final String thorLayers;
  final String name;
  final String description;
  final Duration duration;
  final int version;

  PlaylistTrackList._internal({
    this.pandoraId,
    this.thorLayers,
    this.name,
    this.description,
    this.duration,
    this.version,
    int offset,
    int limit,
    int totalTracks,
    List<Track> tracks,
    List<PandoraEntity> relatedItems,
    ListenerIdInfo listenerIdInfo,
  }) : super(
          type: PandoraEntityType.track,
          listenerIdInfo: listenerIdInfo,
          offset: offset,
          limit: limit,
          totalCount: totalTracks,
          items: tracks,
          relatedItems: relatedItems,
        );

  factory PlaylistTrackList._createFromMap(Map<String, dynamic> map, int limit) {
    final pagedCollectionList = PagedCollectionList<Track>.createFromMap(
      map,
      PlaylistTrackItemEntityCreator(map['annotations'], map['tracks']),
    );

    return PlaylistTrackList._internal(
      pandoraId: map['pandoraId'],
      thorLayers: map['thorLayers'],
      name: map['name'],
      description: map['description'],
      duration: Duration(seconds: map['duration']),
      version: map['version'],
      totalTracks: pagedCollectionList.totalCount,
      offset: pagedCollectionList.offset,
      limit: limit,
      tracks: pagedCollectionList.items,
      relatedItems: pagedCollectionList.items,
      listenerIdInfo: pagedCollectionList.listenerIdInfo,
    );
  }

  @override
  PagedCollectionList<Track> operator +(PagedCollectionList<Track> newList) {
    assert(newList is PlaylistTrackList);
    final newPlaylistTrackList = (newList as PlaylistTrackList);
    return PlaylistTrackList._internal(
      pandoraId: pandoraId,
      thorLayers: newPlaylistTrackList.thorLayers,
      name: newPlaylistTrackList.name,
      description: newPlaylistTrackList.description,
      duration: newPlaylistTrackList.duration,
      version: newPlaylistTrackList.version,
      totalTracks: newPlaylistTrackList.totalCount,
      offset: newPlaylistTrackList.offset,
      limit: newPlaylistTrackList.limit,
      tracks: items + newPlaylistTrackList.items,
      relatedItems: relatedItems + newPlaylistTrackList.relatedItems,
      listenerIdInfo: newPlaylistTrackList.listenerIdInfo,
    );
  }
}

import 'package:epimetheus/libepimetheus/authentication.dart';
import 'package:epimetheus/libepimetheus/networking.dart';
import 'package:epimetheus/libepimetheus/playable_media/tracks.dart';
import 'package:epimetheus/libepimetheus/playlists.dart';

const _deviceUuid = '1880';

extension PlaybackMethods on PlaylistTrackList {
  /// Starts the playlist.
  Future<PlayableTrack> begin({
    User user,
    bool shuffle,
    int index,
  }) async {
    return PlayableTrack.createFromMap(
      await makeApiRequest(
        version: 'v1',
        endpoint: 'playback/source',
        requestData: {
          'deviceProperties': _generateDeviceProperties(user: user, listenerId: listenerIdInfo.id),
          'deviceUuid': _deviceUuid,
          'includeItem': true,
          if (index != null) 'index': index,
          'repeat': null,
          'shuffle': shuffle,
          'skipExplicitCheck': true, // TODO check if this needs to change based on profile settings
          'sortOrder': null,
          'sourceId': pandoraId,
        },
        user: user,
        needsProxy: true,
      ),
    );
  }

  /// Gets the playlist's currently playing track.
  Future<PlayableTrack> current({User user}) async {
    return PlayableTrack.createFromMap(
      await makeApiRequest(
        version: 'v1',
        endpoint: 'playback/current',
        requestData: {
          'deviceProperties': _generateDeviceProperties(user: user, listenerId: listenerIdInfo.id),
          'deviceUuid': _deviceUuid,
          'sourceId': pandoraId,
        },
        user: user,
        needsProxy: true,
      ),
    );
  }

  /// Gets the upcoming track.
  Future<PlayableTrack> peek({User user}) async {
    return PlayableTrack.createFromMap(
      await makeApiRequest(
        version: 'v1',
        endpoint: 'playback/peek',
        requestData: {
          'deviceProperties': _generateDeviceProperties(user: user, listenerId: listenerIdInfo.id),
          'deviceUuid': _deviceUuid,
          'sourceId': pandoraId,
        },
        user: user,
        needsProxy: true,
      ),
    );
  }

  /// Tells Pandora that the track has ended, and fetches the next one.
  Future<void> notifyEnded({
    User user,
    int oldIndex,
  }) async {
    await makeApiRequest(
      version: 'v1',
      endpoint: 'event/ended',
      requestData: {
        'deviceProperties': _generateDeviceProperties(user: user, listenerId: listenerIdInfo.id),
        'deviceUuid': _deviceUuid,
        'elapsedTime': 0,
        'includeItem': true,
        'index': oldIndex,
        'reason': 'NORMAL',
        'sourceId': pandoraId,
      },
      user: user,
      needsProxy: true,
    );
  }

  /// Tells Pandora that the track was skipped, and receives the next one.
  /// Functionally the same as [notifyEnded] + [current] together, but uses one less API request and
  /// may also affect recommendations.
  Future<PlayableTrack> skip({
    User user,
    int oldIndex,
  }) async {
    return PlayableTrack.createFromMap(
      await makeApiRequest(
        version: 'v1',
        endpoint: 'action/skip',
        requestData: {
          'checkOnly': false,
          'deviceProperties': _generateDeviceProperties(user: user, listenerId: listenerIdInfo.id),
          'deviceUuid': _deviceUuid,
          'elapsedTime': 103.902, // Random number - may actually randomise in the future to avoid detection
          'includeItem': true,
          'index': oldIndex,
          'sourceId': pandoraId,
        },
        user: user,
        needsProxy: true,
      ),
    );
  }

  /// Like [skip], but goes the other direction.
  Future<PlayableTrack> previous({
    User user,
    int oldIndex,
  }) async {
    return PlayableTrack.createFromMap(
      await makeApiRequest(
        version: 'v1',
        endpoint: 'action/previous',
        requestData: {
          'deviceProperties': _generateDeviceProperties(user: user, listenerId: listenerIdInfo.id),
          'deviceUuid': _deviceUuid,
          'elapsedTime': 103.902, // Random number - may actually randomise in the future to avoid detection
          'includeItem': true,
          'index': oldIndex,
          'sourceId': pandoraId,
        },
        user: user,
        needsProxy: true,
      ),
    );
  }

  /// Enables and disables shuffle.
  Future<void> toggleShuffle({User user, bool enabled}) async {
    await makeApiRequest(
      version: 'v1',
      endpoint: 'action/shuffle',
      requestData: {
        'deviceProperties': _generateDeviceProperties(user: user, listenerId: listenerIdInfo.id),
        'deviceUuid': _deviceUuid,
        'enabled': enabled,
        'sourceId': pandoraId,
      },
      user: user,
      needsProxy: true,
    );
  }
}

Map<String, dynamic> _generateDeviceProperties({
  User user,
  int listenerId,
}) {
  final time = DateTime.now();
  final timeStamp = time.millisecondsSinceEpoch.toString();
  return {
    'app_version': user.webClientVersion,
    'browser_id': 'Firefox',
    'browser': 'Firefox',
    'client_timestamp': timeStamp,
    'date_recorded': timeStamp,
    'day': '${time.year.toString()}-${time.month.toString().padLeft(2, '0')}-${time.day.toString().padLeft(2, '0')}', // Note: this may break in the year 10,000. Must remember to check then.
    'device_code': _deviceUuid,
    'device_id': _deviceUuid,
    'device_os': 'Mac OS',
    'is_on_demand_user': 'true',
    'listener_id': listenerId,
    'music_playing': 'true',
    'backgrounded': 'false',
    'page_view': 'playlist',
    'site_version': user.webClientVersion,
    'vendor_id': 100,
    'promo_code': '',
    'campaign_id': null,
    'tuner_var_flags': 'F',
    'artist_collaborations_enabled': true,
  };
}

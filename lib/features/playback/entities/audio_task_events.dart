class AndroidAudioSessionIdChanged {
  final int? id;

  const AndroidAudioSessionIdChanged(this.id);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AndroidAudioSessionIdChanged &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

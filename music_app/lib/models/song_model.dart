class SongModel {
  String uuid;
  String albumUUID;
  String name;
  String artist;
  int duration;
  int currentDuration;

  SongModel({
    this.uuid = '',
    this.albumUUID = '',
    this.name = 'Unknown Title',
    this.artist = 'Unknown Artist',
    this.duration = 0,
    this.currentDuration = 0,
  });
}

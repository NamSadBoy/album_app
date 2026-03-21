import 'dart:typed_data';

class Album {
  int? id;
  String name;

  Album({this.id, required this.name});

  Map<String, dynamic> toMap() => {'id': id, 'name': name};
  factory Album.fromMap(Map<String, dynamic> map) =>
      Album(id: map['id'], name: map['name']);
}

class Photo {
  int? id;
  int albumId;
  String title;
  String description;
  String dateAdded;
  Uint8List imageBytes;

  Photo({
    this.id,
    required this.albumId,
    required this.title,
    required this.description,
    required this.dateAdded,
    required this.imageBytes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'albumId': albumId,
      'title': title,
      'description': description,
      'dateAdded': dateAdded,
      'imageBytes': imageBytes,
    };
  }

  factory Photo.fromMap(Map<String, dynamic> map) {
    return Photo(
      id: map['id'],
      albumId: map['albumId'],
      title: map['title'],
      description: map['description'],
      dateAdded: map['dateAdded'] ?? 'Chưa xác định',
      imageBytes: map['imageBytes'],
    );
  }
}

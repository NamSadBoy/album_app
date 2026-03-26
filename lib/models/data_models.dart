class Album {
  String? id;
  String name;
  String dateCreated;
  bool isFavorite; // MỚI
  bool isHidden; // MỚI

  Album({
    this.id,
    required this.name,
    required this.dateCreated,
    this.isFavorite = false,
    this.isHidden = false,
  });

  factory Album.fromMap(Map<String, dynamic> map) {
    return Album(
      id: map['id'].toString(),
      name: map['name'],
      dateCreated: map['date_created'] ?? '',
      isFavorite: map['is_favorite'] ?? false,
      isHidden: map['is_hidden'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'date_created': dateCreated,
      'is_favorite': isFavorite,
      'is_hidden': isHidden,
    };
  }
}

class Photo {
  String? id;
  String albumId;
  String title;
  String description;
  String dateAdded;
  String imageUrl;

  Photo({
    this.id,
    required this.albumId,
    required this.title,
    required this.description,
    required this.dateAdded,
    required this.imageUrl,
  });

  factory Photo.fromMap(Map<String, dynamic> map) {
    return Photo(
      id: map['id'].toString(),
      albumId: map['album_id'].toString(),
      title: map['title'],
      description: map['description'] ?? '',
      dateAdded: map['date_added'] ?? '',
      imageUrl: map['image_url'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'album_id': albumId,
      'title': title,
      'description': description,
      'date_added': dateAdded,
      'image_url': imageUrl,
    };
  }
}

class ImagesModel {
  final String imageID;
  final String url;
  final String name;

  ImagesModel({required this.imageID, required this.url, required this.name});

  factory ImagesModel.fromFirestore(Map<String, dynamic> json, String imageID) {
    return ImagesModel(
      imageID: imageID,
      url: json['url'] ?? '',
      name: json['name'] ?? '',
    );
  }
  Map<String, dynamic> toFirestore() {
    return {
      'url': url,
      'name': name,
    };
  }
  
}
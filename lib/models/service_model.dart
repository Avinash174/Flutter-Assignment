class ServiceModel {
  final String id;
  final String serviceName;
  final String categoryName;
  final int price;
  final int duration;
  final String imageUrl;

  ServiceModel({
    required this.id,
    required this.serviceName,
    required this.categoryName,
    required this.price,
    required this.duration,
    required this.imageUrl,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    String cName = '';
    if (json['category'] != null && json['category'] is Map) {
      cName = json['category']['name'] ?? '';
    }

    return ServiceModel(
      id: json['_id'] ?? '',
      serviceName: json['serviceName'] ?? '',
      categoryName: cName,
      price: json['price'] ?? 0,
      duration: json['duration'] ?? 0,
      imageUrl:
          json['image'] != null && json['image'].toString().startsWith('http')
          ? json['image']
          : 'https://picsum.photos/seed/${json['_id'] ?? "random"}/100/100', // fallback to valid placeholder if not real URL
    );
  }
}

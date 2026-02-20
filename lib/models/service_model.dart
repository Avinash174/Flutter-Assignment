class ServiceModel {
  final String id;
  final String serviceName;
  final String categoryName;
  final String categoryId;
  final String subCategoryName;
  final String subCategoryId;
  final String description;
  final int price;
  final int duration;
  final String imageUrl;

  ServiceModel({
    required this.id,
    required this.serviceName,
    required this.categoryName,
    required this.categoryId,
    required this.subCategoryName,
    required this.subCategoryId,
    required this.description,
    required this.price,
    required this.duration,
    required this.imageUrl,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    String cName = '';
    String cId = '';
    if (json['category'] != null && json['category'] is Map) {
      cName = json['category']['name'] ?? '';
      cId = json['category']['_id'] ?? '';
    }

    String scName = '';
    String scId = '';
    if (json['subCategory'] != null && json['subCategory'] is Map) {
      scName = json['subCategory']['name'] ?? '';
      scId = json['subCategory']['_id'] ?? '';
    }

    return ServiceModel(
      id: json['_id'] ?? '',
      serviceName: json['serviceName'] ?? '',
      categoryName: cName,
      categoryId: cId,
      subCategoryName: scName,
      subCategoryId: scId,
      description: json['description'] ?? '',
      price: json['price'] ?? 0,
      duration: json['duration'] ?? 0,
      imageUrl:
          json['image'] != null && json['image'].toString().startsWith('http')
          ? json['image']
          : 'https://picsum.photos/seed/${json['_id'] ?? "random"}/100/100', // fallback to valid placeholder if not real URL
    );
  }
}

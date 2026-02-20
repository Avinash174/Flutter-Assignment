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

  final String startTime;
  final String endTime;

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
    this.startTime = '',
    this.endTime = '',
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
      imageUrl: _parseImageUrl(json['image']),
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
    );
  }

  static String _parseImageUrl(dynamic image) {
    if (image == null) return '';
    String url = image.toString();
    if (url.isEmpty || url == 'null') return '';

    // If it's a full URL or a Base64 string, use it directly.
    if (url.startsWith('http') || url.startsWith('data:image')) {
      return url;
    }

    // If it's just a filename, it might be legacy or broken, so we default to empty
    // and let the UI show a nice placeholder icon.
    return '';
  }
}

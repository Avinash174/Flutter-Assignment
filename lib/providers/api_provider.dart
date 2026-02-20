import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import '../models/category_model.dart';
import '../models/sub_category_model.dart';
import '../models/service_model.dart';
import '../utils/app_constants.dart';
import '../utils/pref_manager.dart';

/// A singleton-like utility class responsible for all HTTP REST API interactions.
class ApiProvider {
  // The assignment token, kept as a fallback.
  static const _fallbackToken =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY5ODFjY2ViMjQ2MzI4M2MzOTc5ODIwYiIsInJvbGUiOiJwcm92aWRlciIsImlhdCI6MTc3MTQ4ODg4OSwiZXhwIjoxNzcyMDkzNjg5fQ.v7KHJfWDXh72hC14BDPwZ1Lp1mrlAFiTxIpcvfIdZGg';

  /// Gets the auth token from SharedPreferences, falling back to the
  /// hardcoded assignment token if it's not available.
  static Future<String> _getToken() async {
    final t = (await PrefManager.getToken()).trim();
    return t.isEmpty ? _fallbackToken : t;
  }

  /// Builds headers for JSON requests. Token is included in the header.
  static Future<Map<String, String>> _jsonHeaders() async {
    final token = await _getToken();
    log('Token: ${token.substring(0, 15)}...');
    return {
      'token': token,
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  /// Resolves the image field value for the API payload.
  /// Per the machine test spec, `image` is sent as a filename string.
  /// We cannot Base64-encode because the server's JSON body-parser has a
  /// size limit (~100KB) which rejects large payloads with a 413 error.
  static Future<String> _resolveImage(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) return 'image.png';
    // If it's an existing server URL, pass it through unchanged
    if (imagePath.startsWith('http')) return imagePath;
    // For a local file path, extract just the filename (e.g. "image.jpg")
    return imagePath.split('/').last;
  }

  /// Fetches a list of parent categories from the Node Backend.
  static Future<List<CategoryModel>> getCategories() async {
    try {
      final url = Uri.parse(AppConstants.categoriesUrl);
      final headers = await _jsonHeaders();
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return (data['data'] as List)
              .map((e) => CategoryModel.fromJson(e))
              .toList();
        }
      }
    } catch (e) {
      log('Error fetching categories: $e');
    }
    return [];
  }

  /// Uses the specific [categoryId] to retrieve nested sub-categories.
  static Future<List<SubCategoryModel>> getSubCategories(
    String categoryId,
  ) async {
    try {
      final url = Uri.parse('${AppConstants.categoriesUrl}/$categoryId');
      final headers = await _jsonHeaders();
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success'] == true &&
            data['data'] != null &&
            data['data']['subCategories'] != null) {
          return (data['data']['subCategories'] as List)
              .map((e) => SubCategoryModel.fromJson(e))
              .toList();
        }
      }
    } catch (e) {
      log('Error fetching subcategories: $e');
    }
    return [];
  }

  /// Fetches the user's specific services.
  static Future<List<ServiceModel>> getServices() async {
    try {
      final url = Uri.parse(AppConstants.servicesUrl);
      final headers = await _jsonHeaders();
      final response = await http.get(url, headers: headers);
      log('GET Services ${response.statusCode}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return (data['data'] as List)
              .map((e) => ServiceModel.fromJson(e))
              .toList();
        }
      }
    } catch (e) {
      log('Error fetching services: $e');
    }
    return [];
  }

  /// Creates a new service.
  /// Sends as application/json with token in BOTH header and body.
  static Future<bool> createService(Map<String, dynamic> serviceData) async {
    try {
      final url = Uri.parse(AppConstants.servicesUrl);
      final token = await _getToken();
      final headers = {
        'token': token,
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      final imageValue = await _resolveImage(
        serviceData['imagePath'] as String?,
      );

      final Map<String, dynamic> body = {
        'token': token,
        'serviceName': serviceData['serviceName'] ?? '',
        'description': serviceData['description'] ?? '',
        'category': serviceData['category'] ?? '',
        'subCategory': serviceData['subCategory'] ?? '',
        'price': int.tryParse(serviceData['price'].toString()) ?? 0,
        'duration': int.tryParse(serviceData['duration'].toString()) ?? 0,
        'startTime': serviceData['startTime'] ?? '09:00 AM',
        'endTime': serviceData['endTime'] ?? '05:00 PM',
        'availability': serviceData['availability'] ?? [],
        'image': imageValue,
      };

      log('POST $url');
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      log('Response ${response.statusCode}: ${response.body}');
      return (response.statusCode == 200 || response.statusCode == 201);
    } catch (e) {
      log('Error creating service: $e');
    }
    return false;
  }

  /// Updates an existing service.
  /// Sends as application/json with token in BOTH header and body.
  static Future<bool> updateService(
    String id,
    Map<String, dynamic> serviceData,
  ) async {
    try {
      final url = Uri.parse('${AppConstants.servicesUrl}/$id');
      final token = await _getToken();
      final headers = {
        'token': token,
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      final imageValue = await _resolveImage(
        serviceData['imagePath'] as String?,
      );

      final Map<String, dynamic> body = {
        'token': token,
        'serviceName': serviceData['serviceName'] ?? '',
        'description': serviceData['description'] ?? '',
        'category': serviceData['category'] ?? '',
        'subCategory': serviceData['subCategory'] ?? '',
        'price': int.tryParse(serviceData['price'].toString()) ?? 0,
        'duration': int.tryParse(serviceData['duration'].toString()) ?? 0,
        'startTime': serviceData['startTime'] ?? '09:00 AM',
        'endTime': serviceData['endTime'] ?? '05:00 PM',
        'availability': serviceData['availability'] ?? [],
        'image': imageValue,
      };

      log('PUT $url');
      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      log('Response ${response.statusCode}: ${response.body}');
      return (response.statusCode == 200 || response.statusCode == 201);
    } catch (e) {
      log('Error updating service: $e');
    }
    return false;
  }

  /// Removes a service matching the [id] from the database.
  static Future<bool> deleteService(String id) async {
    try {
      final url = Uri.parse('${AppConstants.servicesUrl}/$id');
      final headers = await _jsonHeaders();
      log('DELETE $url');
      final response = await http.delete(url, headers: headers);
      return (response.statusCode == 200 || response.statusCode == 201);
    } catch (e) {
      log('Error deleting service: $e');
    }
    return false;
  }
}

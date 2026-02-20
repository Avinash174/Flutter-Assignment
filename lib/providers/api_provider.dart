import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import '../models/category_model.dart';
import '../models/sub_category_model.dart';
import '../models/service_model.dart';

/// A singleton-like utility class responsible for all HTTP REST API interactions.
/// We centralize API requests here so that our ViewModels remain clean and only
/// govern state and business logic.
class ApiProvider {
  static const String baseUrl = 'https://velvook-node.creatamax.in';
  static const String token =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY5ODFjY2ViMjQ2MzI4M2MzOTc5ODIwYiIsInJvbGUiOiJwcm92aWRlciIsImlhdCI6MTc3MTQ4ODg4OSwiZXhwIjoxNzcyMDkzNjg5fQ.v7KHJfWDXh72hC14BDPwZ1Lp1mrlAFiTxIpcvfIdZGg';

  /// Internal helper to generate headers. Notice the hardcoded [token] for the
  /// purpose of this assignment is passed dynamically to every request.
  static Map<String, String> get headers => {
    'token': token,
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  };

  /// Fetches a list of parent categories from the Node Backend.
  /// Returns an empty list if there's a network error or missing data.
  static Future<List<CategoryModel>> getCategories() async {
    try {
      final url = Uri.parse('$baseUrl/api/categories');
      log('GET $url');
      final response = await http.get(url);
      log('Response ${response.statusCode}: ${response.body}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return (data['data'] as List)
              .map((e) => CategoryModel.fromJson(e))
              .toList();
        }
      }
    } catch (e) {
      log('Error fetching categories: $e', error: e);
    }
    return [];
  }

  /// Uses the specific [categoryId] to retrieve nested sub-categories
  /// associated with that parent category. Important for cascaded dropdowns.
  static Future<List<SubCategoryModel>> getSubCategories(
    String categoryId,
  ) async {
    try {
      final url = Uri.parse('$baseUrl/api/categories/$categoryId');
      log('GET $url');
      final response = await http.get(url);
      log('Response ${response.statusCode}: ${response.body}');
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
      log('Error fetching subcategories: $e', error: e);
    }
    return [];
  }

  /// Fetches the user's specific services.
  /// Used by [ManageServicesViewModel] to populate the main UI.
  static Future<List<ServiceModel>> getServices() async {
    try {
      final url = Uri.parse('$baseUrl/api/providers/services');
      log('GET $url');
      final response = await http.get(url, headers: headers);
      log('Response ${response.statusCode}: ${response.body}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return (data['data'] as List)
              .map((e) => ServiceModel.fromJson(e))
              .toList();
        }
      }
    } catch (e) {
      log('Error fetching services: $e', error: e);
    }
    return [];
  }

  /// Creates a completely new service.
  /// Takes a complete parsed [serviceData] map from [BookingCalendarViewModel].
  static Future<bool> createService(Map<String, dynamic> serviceData) async {
    try {
      final url = Uri.parse('$baseUrl/api/providers/services');
      final request = http.MultipartRequest('POST', url);

      // We must drop our default 'application/json' Content-Type
      // because MultipartRequest auto-generates a multipart/form-data header with boundary metadata
      final Map<String, String> customHeaders = Map.from(headers);
      customHeaders.remove('Content-Type');
      request.headers.addAll(customHeaders);

      // Bind all standard fields
      serviceData.forEach((key, value) {
        if (key == 'imagePath' || key == 'id') return; // Handled separately
        if (value is List || value is Map) {
          // Flatten structures back into valid JSON strings so Form-Data can transport them safely
          request.fields[key] = jsonEncode(value);
        } else {
          request.fields[key] = value.toString();
        }
      });

      // Bind the Image natively if valid
      final String? imagePath = serviceData['imagePath'] as String?;
      if (imagePath != null &&
          imagePath.isNotEmpty &&
          !imagePath.startsWith('http')) {
        request.files.add(
          await http.MultipartFile.fromPath('image', imagePath),
        );
      }

      log('POST MULTIPART $url');
      log('Fields: ${request.fields}');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      log('Create Service Status Code: ${response.statusCode}');
      log('Create Service Response: ${response.body}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
    } catch (e) {
      log('Error creating service: $e', error: e);
    }
    return false;
  }

  /// Updates an existing service by submitting a PUT request against its specific [id].
  /// Differentiates from [createService] specifically through the usage of http.put instead of http.post.
  static Future<bool> updateService(
    String id,
    Map<String, dynamic> serviceData,
  ) async {
    try {
      final url = Uri.parse('$baseUrl/api/providers/services/$id');
      final request = http.MultipartRequest('PUT', url);

      final Map<String, String> customHeaders = Map.from(headers);
      customHeaders.remove('Content-Type');
      request.headers.addAll(customHeaders);

      serviceData.forEach((key, value) {
        if (key == 'imagePath' || key == 'id') return;
        if (value is List || value is Map) {
          request.fields[key] = jsonEncode(value);
        } else {
          request.fields[key] = value.toString();
        }
      });

      final String? imagePath = serviceData['imagePath'] as String?;
      if (imagePath != null &&
          imagePath.isNotEmpty &&
          !imagePath.startsWith('http')) {
        request.files.add(
          await http.MultipartFile.fromPath('image', imagePath),
        );
      }

      log('PUT MULTIPART $url');
      log('Fields: ${request.fields}');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      log('Update Service Status Code: ${response.statusCode}');
      log('Update Service Response: ${response.body}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
    } catch (e) {
      log('Error updating service: $e', error: e);
    }
    return false;
  }

  /// Removes a service matching the [id] from the database.
  static Future<bool> deleteService(String id) async {
    try {
      final url = Uri.parse('$baseUrl/api/providers/services/$id');
      log('DELETE $url');
      final response = await http.delete(url, headers: headers);
      log('Delete ${response.statusCode}: ${response.body}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
    } catch (e) {
      log('Error deleting service: $e', error: e);
    }
    return false;
  }
}

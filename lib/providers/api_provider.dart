import 'dart:convert';
import 'dart:developer';
import 'dart:io';
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

      final postBody = Map<String, dynamic>.from(serviceData);

      // Process local image into base64 data URI if present
      final String? imagePath = postBody['imagePath'] as String?;
      if (imagePath != null &&
          imagePath.isNotEmpty &&
          !imagePath.startsWith('http')) {
        try {
          final file = File(imagePath);
          final bytes = await file.readAsBytes();
          final base64Image = base64Encode(bytes);
          // Assuming JPEG for now, but could infer from file extension if needed
          postBody['image'] = 'data:image/jpeg;base64,$base64Image';
          postBody.remove(
            'imagePath',
          ); // Remove the local path, replace with base64 data
        } catch (e) {
          log('Error reading image file for creation: $e', error: e);
          postBody.remove('imagePath'); // Remove path if file cannot be read
        }
      } else if (imagePath != null && imagePath.startsWith('http')) {
        // If it's an existing URL, keep it as 'image'
        postBody['image'] = imagePath;
        postBody.remove('imagePath');
      } else {
        // No image path or empty path, ensure 'image' key is not present if it was 'imagePath'
        postBody.remove('imagePath');
      }

      // Ensure other fields are correctly formatted for JSON
      postBody.remove('id'); // ID is not needed for creation

      log('POST $url');
      log('Body: ${jsonEncode(postBody)}');

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(postBody),
      );

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

      final postBody = Map<String, dynamic>.from(serviceData);

      final String? imagePath = postBody['imagePath'] as String?;
      if (imagePath != null &&
          imagePath.isNotEmpty &&
          !imagePath.startsWith('http')) {
        try {
          final file = File(imagePath);
          final bytes = await file.readAsBytes();
          final base64Image = base64Encode(bytes);
          postBody['image'] = 'data:image/jpeg;base64,$base64Image';
          postBody.remove('imagePath');
        } catch (e) {
          log('Error reading image for update: $e', error: e);
          postBody.remove('imagePath');
        }
      } else if (imagePath != null && imagePath.startsWith('http')) {
        postBody['image'] = imagePath;
        postBody.remove('imagePath');
      } else {
        postBody.remove('imagePath');
      }

      postBody.remove('id');

      log('PUT $url');
      log('Body: ${jsonEncode(postBody)}');

      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode(postBody),
      );

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

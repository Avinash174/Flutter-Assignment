import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/category_model.dart';
import '../models/sub_category_model.dart';
import '../models/service_model.dart';
import '../utils/app_constants.dart';
import '../utils/pref_manager.dart';

/// A singleton-like utility class responsible for all HTTP REST API interactions.
class ApiProvider {
  /// Internal helper to generate headers by fetching the token from Shared Preferences.
  static Future<Map<String, String>> _getHeaders() async {
    String token = await PrefManager.getToken();

    // Fallback for assignment robustness if token is empty
    if (token.isEmpty) {
      log(
        'Warning: Auth token is empty in SharedPrefs. Falling back to default assignment token.',
      );
      token =
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY5ODFjY2ViMjQ2MzI4M2MzOTc5ODIwYiIsInJvbGUiOiJwcm92aWRlciIsImlhdCI6MTc3MTQ4ODg4OSwiZXhwIjoxNzcyMDkzNjg5fQ.v7KHJfWDXh72hC14BDPwZ1Lp1mrlAFiTxIpcvfIdZGg';
    }

    return {
      'token': token,
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  /// Fetches a list of parent categories from the Node Backend.
  static Future<List<CategoryModel>> getCategories() async {
    try {
      final url = Uri.parse(AppConstants.categoriesUrl);
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

  /// Uses the specific [categoryId] to retrieve nested sub-categories.
  static Future<List<SubCategoryModel>> getSubCategories(
    String categoryId,
  ) async {
    try {
      final url = Uri.parse('${AppConstants.categoriesUrl}/$categoryId');
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
  static Future<List<ServiceModel>> getServices() async {
    try {
      final url = Uri.parse(AppConstants.servicesUrl);
      final headers = await _getHeaders();
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

  /// Creates a completely new service using application/json.
  static Future<bool> createService(Map<String, dynamic> serviceData) async {
    try {
      final url = Uri.parse(AppConstants.servicesUrl);
      final headers = await _getHeaders();

      final postBody = Map<String, dynamic>.from(serviceData);

      // Handle image: convert to Base64 if it's a local file path
      final String? imagePath = postBody['imagePath'] as String?;
      if (imagePath != null &&
          imagePath.isNotEmpty &&
          !imagePath.startsWith('http')) {
        try {
          final file = File(imagePath);
          final bytes = await file.readAsBytes();
          final base64Image = base64Encode(bytes);
          postBody['image'] = 'data:image/jpeg;base64,$base64Image';
        } catch (e) {
          log('Error reading image file for creation: $e', error: e);
          postBody['image'] = '';
        }
      } else if (imagePath != null && imagePath.startsWith('http')) {
        postBody['image'] = imagePath;
      } else {
        postBody['image'] = '';
      }
      postBody.remove('imagePath');
      postBody.remove('id');

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

  /// Updates an existing service using application/json.
  static Future<bool> updateService(
    String id,
    Map<String, dynamic> serviceData,
  ) async {
    try {
      final url = Uri.parse('${AppConstants.servicesUrl}/$id');
      final headers = await _getHeaders();

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
        } catch (e) {
          log('Error reading image for update: $e', error: e);
        }
      } else if (imagePath != null && imagePath.startsWith('http')) {
        postBody['image'] = imagePath;
      }
      postBody.remove('imagePath');
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
      final url = Uri.parse('${AppConstants.servicesUrl}/$id');
      final headers = await _getHeaders();
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

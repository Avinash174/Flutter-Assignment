import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import '../models/category_model.dart';
import '../models/sub_category_model.dart';
import '../models/service_model.dart';

class ApiProvider {
  static const String baseUrl = 'https://velvook-node.creatamax.in';
  static const String token =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY5ODFjY2ViMjQ2MzI4M2MzOTc5ODIwYiIsInJvbGUiOiJwcm92aWRlciIsImlhdCI6MTc3MTQ4ODg4OSwiZXhwIjoxNzcyMDkzNjg5fQ.v7KHJfWDXh72hC14BDPwZ1Lp1mrlAFiTxIpcvfIdZGg';

  static Map<String, String> get headers => {
    'token': token,
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  };

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

  static Future<bool> createService(Map<String, dynamic> serviceData) async {
    try {
      final url = Uri.parse('$baseUrl/api/providers/services');

      // Ensure local Image path is stripped or handled if backend expects URL. We'll pass it as 'image'
      final postBody = Map<String, dynamic>.from(serviceData);
      postBody['image'] = serviceData['imagePath'] ?? 'image.png';
      postBody.remove('imagePath');

      log('POST JSON $url');
      log('Fields: $postBody');

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

  static Future<bool> updateService(
    String id,
    Map<String, dynamic> serviceData,
  ) async {
    try {
      final url = Uri.parse('$baseUrl/api/providers/services/$id');

      final postBody = Map<String, dynamic>.from(serviceData);
      postBody['image'] = serviceData['imagePath'] ?? 'image.png';
      postBody.remove('imagePath');

      log('PUT JSON $url');
      log('Fields: $postBody');

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

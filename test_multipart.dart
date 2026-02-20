import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final url = Uri.parse(
    'https://velvook-node.creatamax.in/api/providers/services',
  );
  final token =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY5ODFjY2ViMjQ2MzI4M2MzOTc5ODIwYiIsInJvbGUiOiJwcm92aWRlciIsImlhdCI6MTc3MTQ4ODg4OSwiZXhwIjoxNzcyMDkzNjg5fQ.v7KHJfWDXh72hC14BDPwZ1Lp1mrlAFiTxIpcvfIdZGg';

  // Test 1: Multipart
  final req = http.MultipartRequest('POST', url);
  req.headers['token'] = token;
  req.headers['Authorization'] = 'Bearer $token';

  req.fields['serviceName'] = 'Test Multipart';
  req.fields['price'] = '100';
  req.fields['duration'] = '60';
  req.fields['startTime'] = '06:00 AM';
  req.fields['endTime'] = '12:00 PM';
  req.fields['description'] = 'Multipart test';
  req.fields['category'] = '6981defc96493f72a622c9ed';
  req.fields['subCategory'] = '6983375871cec2a365ce73c3';

  // availability is a list
  req.fields['availability'] = jsonEncode([
    {"date": "2026-02-21T00:00:00.000Z"},
  ]);

  final res = await req.send();
  final respData = await http.Response.fromStream(res);
  print('Multipart Status: ${respData.statusCode}');
  print('Multipart Body: ${respData.body}');
}

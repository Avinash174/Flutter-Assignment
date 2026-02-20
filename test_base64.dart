import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final baseUrl = 'https://velvook-node.creatamax.in';
  final token =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY5ODFjY2ViMjQ2MzI4M2MzOTc5ODIwYiIsInJvbGUiOiJwcm92aWRlciIsImlhdCI6MTc3MTQ4ODg4OSwiZXhwIjoxNzcyMDkzNjg5fQ.v7KHJfWDXh72hC14BDPwZ1Lp1mrlAFiTxIpcvfIdZGg';

  // Test if it accepts base64
  final url = Uri.parse('$baseUrl/api/providers/services');
  final body = {
    'serviceName': 'Base64 test',
    'price': 100,
    'duration': 60,
    'startTime': '06:00 AM',
    'endTime': '12:00 PM',
    'description': 'Base64 test',
    'category': '6981defc96493f72a622c9ed',
    'subCategory': '6983375871cec2a365ce73c3',
    'availability': [
      {"date": "2026-02-21T00:00:00.000Z"},
    ],
    'image':
        'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
  };

  final res = await http.post(
    url,
    headers: {
      'token': token,
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode(body),
  );
  print('Base64 Upload Status: ${res.statusCode}');
  print('Base64 Upload Body: ${res.body}');
}

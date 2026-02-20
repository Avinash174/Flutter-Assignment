import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final url = Uri.parse('https://velvook-node.creatamax.in/api/upload');
  final token =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY5ODFjY2ViMjQ2MzI4M2MzOTc5ODIwYiIsInJvbGUiOiJwcm92aWRlciIsImlhdCI6MTc3MTQ4ODg4OSwiZXhwIjoxNzcyMDkzNjg5fQ.v7KHJfWDXh72hC14BDPwZ1Lp1mrlAFiTxIpcvfIdZGg';

  final req = http.MultipartRequest('POST', url);
  req.headers['token'] = token;
  req.headers['Authorization'] = 'Bearer $token';

  // Just passing a dummy text file to see if endpoint exists
  req.fields['test'] = 'test';

  final res = await req.send();
  final respData = await http.Response.fromStream(res);
  print('Upload Status: ${respData.statusCode}');
  print('Upload Body: ${respData.body}');
}

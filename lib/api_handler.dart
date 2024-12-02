import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:rodis_service/models/record.dart';
import 'package:cross_file/cross_file.dart';

class ApiHandler {
  static const baseUrl = "http://188.245.190.233";
  static const apiUrl = "$baseUrl/api";
  static const photoUrl = "$baseUrl/media/images";
  Map<String, String> headers = {
    'Content-Type': 'application/json; charset=UTF-8',
  };

  Future<http.Response> _get(Uri uri) async {
    return http.get(uri, headers: headers);
  }

  Future<http.Response> _post(Uri uri, {Object? body}) async {
    final response = await http.post(uri, headers: headers, body: body);
    final rawCookie = response.headers['set-cookie'];
    if (rawCookie != null) {
      int index = rawCookie.indexOf(';');
      headers.addAll({
        'cookie': (index == -1) ? rawCookie : rawCookie.substring(0, index),
      });
    }
    return response;
  }

  Future<http.Response> _put(Uri uri, {Object? body}) async {
    return http.put(uri, headers: headers, body: body);
  }

  Future<http.Response> _delete(Uri uri, {Object? body}) async {
    return http.delete(uri, headers: headers, body: body);
  }

  Future<Map<String, dynamic>> getSuggestions() async {
    final response = await _get(Uri.parse("$apiUrl/suggestions"));
    final json = (jsonDecode(response.body) as Map<String, dynamic>)
        .cast<String, List<dynamic>>();
    return json.map(
      (key, value) => MapEntry(
        key,
        {for (var item in value) item['id'] as int: item['onoma'] as String},
      ),
    );
  }

  Future<List<Record>> getRecordsBy(int id) async {
    final url = id == 0 ? "$apiUrl/records/all" : "$apiUrl/records/by/$id";
    final response = await _get(Uri.parse(url));
    final json =
        (jsonDecode(response.body) as List).cast<Map<String, dynamic>>();
    return json.map((element) => Record.fromJSON(element)).toList();
  }

  Future<Map<String, dynamic>?> postLogin(
    String username,
    String password,
  ) async {
    final response = await _post(
      Uri.parse("$apiUrl/login"),
      body: jsonEncode({
        "username": username,
        "password": password,
      }),
    );
    if (response.statusCode != 200) return null;
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>?> postRecord(Map<String, Object?> record) async {
    final response =
        await _post(Uri.parse("$apiUrl/records/new"), body: jsonEncode(record));
    if (response.statusCode != 200) return null;
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>?> putRecord(
    int id,
    Map<String, Object?> record,
  ) async {
    final response = await _put(
      Uri.parse("$apiUrl/records/$id"),
      body: jsonEncode(record),
    );
    if (response.statusCode != 200) return null;
    return jsonDecode(response.body);
  }

  Future<bool> deleteRecord(int id) async {
    final response = await _delete(Uri.parse("$apiUrl/records/$id"));
    if (response.statusCode != 200) return false;
    return true;
  }

  Future<String?> postPhoto(XFile file) async {
    final request = http.MultipartRequest('POST', Uri.parse("$apiUrl/media"))
      ..headers.addAll(headers);

    if (kIsWeb) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          await file.readAsBytes(),
          filename: file.name,
        ),
      );
    } else {
      request.files.add(await http.MultipartFile.fromPath('file', file.path));
    }
    final response = await http.Response.fromStream(await request.send());
    if (response.statusCode != 200) return null;
    return response.body;
  }
}

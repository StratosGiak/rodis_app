import 'dart:convert';

import 'package:rodis_service/constants.dart';
import 'package:rodis_service/models/record.dart';
import 'package:http/http.dart' as http;

Future<List<Record>> getRecords(int id) async {
  final response = await http.get(Uri.parse('$apiUrl/records/by/$id'));
  final json = (jsonDecode(response.body) as List).cast<Map<String, dynamic>>();
  return json.map((element) => Record.fromJSON(element)).toList();
}

Future<Map<String, dynamic>> getSuggestions() async {
  final response = await http.get(Uri.parse('$apiUrl/suggestions'));
  final json = (jsonDecode(response.body) as Map<String, dynamic>)
      .cast<String, List<dynamic>>();
  return json.map(
    (key, value) => MapEntry(
      key,
      {for (var item in value) item['id'] as int: item['onoma'] as String},
    ),
  );
}

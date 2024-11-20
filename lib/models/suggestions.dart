import 'package:flutter/material.dart';

class Suggestions extends ChangeNotifier {
  Suggestions({
    required this.products,
    required this.manufacturers,
    required this.statuses,
  });

  Map<int, String> products;
  Map<int, String> manufacturers;
  Map<int, String> statuses;

  Suggestions.fromJSON(Map<String, dynamic> map)
      : products = map['products'],
        manufacturers = map['manufacturers'],
        statuses = map['statuses'];

  void setAll(Map<String, dynamic> map) {
    bool dirty = false;
    if (products != map['products']) {
      products = map['products'];
      dirty = true;
    }
    if (manufacturers != map['manufacturers']) {
      manufacturers = map['manufacturers'];
      dirty = true;
    }
    if (statuses != map['statuses']) {
      statuses = map['statuses'];
      dirty = true;
    }
    if (dirty) notifyListeners();
  }
}

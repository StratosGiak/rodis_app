import 'package:flutter/material.dart';

class Suggestions extends ChangeNotifier {
  Suggestions({
    required this.products,
    required this.manufacturers,
    required this.statuses,
    required this.stores,
  });

  Map<int, String> products;
  Map<int, String> manufacturers;
  Map<int, String> statuses;
  Map<int, String> stores;

  Suggestions.fromJSON(Map<String, dynamic> map)
      : products = map['products'],
        manufacturers = map['manufacturers'],
        statuses = map['statuses'],
        stores = map['stores'];

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
    if (stores != map['stores']) {
      stores = map['stores'];
      dirty = true;
    }
    if (dirty) notifyListeners();
  }
}

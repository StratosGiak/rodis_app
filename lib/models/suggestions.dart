import 'package:flutter/material.dart';

class Suggestions extends ChangeNotifier {
  Suggestions({
    required this.products,
    required this.manufacturers,
    required this.statuses,
    required this.mechanics,
    required this.stores,
    required this.damages,
  });

  Map<int, String> products;
  Map<int, String> manufacturers;
  Map<int, String> statuses;
  Map<int, String> mechanics;
  Map<int, String> stores;
  Map<int, String> damages;

  Suggestions.fromJSON(Map<String, dynamic> map)
      : products = map['products'],
        manufacturers = map['manufacturers'],
        statuses = map['statuses'],
        mechanics = map['mechanics'],
        stores = map['stores'],
        damages = map['damages'];

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
    if (mechanics != map['mechanics']) {
      mechanics = map['mechanics'];
      dirty = true;
    }
    if (stores != map['stores']) {
      stores = map['stores'];
      dirty = true;
    }
    if (damages != map['damages']) {
      damages = map['damages'];
      dirty = true;
    }
    if (dirty) notifyListeners();
  }
}

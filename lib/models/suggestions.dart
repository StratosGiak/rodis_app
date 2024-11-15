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
}

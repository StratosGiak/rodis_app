import 'package:flutter/material.dart';
import 'package:rodis_service/constants.dart';

class Records extends ChangeNotifier {
  List<Record> records = [];

  Records({List<Record>? records}) : records = records ?? [];

  void add(Record record) {
    records.add(record);
    notifyListeners();
  }

  void removeRecord(int index) {
    records.removeWhere((e) => e.id == index);
    notifyListeners();
  }

  void addAll(List<Record> records) {
    this.records.addAll(records);
    notifyListeners();
  }

  void setRecord(Record record) {
    final index = records.indexWhere((e) => e.id == record.id);
    if (index < 0) throw Error();
    records[index] = record;
    notifyListeners();
  }

  void setAll(List<Record> records) {
    this.records = records;
    notifyListeners();
  }
}

class Record extends ChangeNotifier {
  int id;
  DateTime date;
  String name;
  String? phoneHome;
  String phoneMobile;
  String? email;
  String? postalCode;
  String? city;
  String? area;
  String? address;
  String notesReceived;
  String? notesRepaired;
  String? fee;
  String advance;
  String? serial;
  String product;
  String? manufacturer;
  List<String> photos;
  int mechanic;
  bool hasWarranty;
  DateTime? warrantyDate;
  int status;
  int store;
  List<History> history;

  Record({
    required this.id,
    required this.date,
    required this.name,
    required this.phoneHome,
    required this.phoneMobile,
    required this.email,
    required this.postalCode,
    required this.city,
    required this.area,
    required this.address,
    required this.notesReceived,
    required this.notesRepaired,
    required this.fee,
    required this.advance,
    required this.serial,
    required this.product,
    required this.manufacturer,
    required this.photos,
    required this.mechanic,
    required this.hasWarranty,
    required this.warrantyDate,
    required this.status,
    required this.store,
    required this.history,
  });

  Map<String, dynamic> toJSON() => {
        "id": id,
        "date": date,
        "name": name,
        "phoneHome": phoneHome,
        "phoneMobile": phoneMobile,
        "email": email,
        "postalCode": postalCode,
        "city": city,
        "area": area,
        "address": address,
        "notesReceived": notesReceived,
        "notesRepaired": notesRepaired,
        "fee": fee,
        "advance": advance,
        "serial": serial,
        "product": product,
        "manufacturer": manufacturer,
        "photos": photos,
        "mechanic": mechanic,
        "hasWarranty": hasWarranty,
        "warrantyDate": warrantyDate,
        "status": status,
        "store": store,
        "history": history,
      };

  Record.fromJSON(Map<String, dynamic> map)
      : id = map['id'],
        date = map['date'] != null
            ? DateTime.tryParse(map['date']) ??
                DateTime.fromMillisecondsSinceEpoch(0)
            : DateTime.fromMillisecondsSinceEpoch(0),
        name = map['name'],
        phoneHome =
            map['phoneHome'] == null || (map['phoneHome'] as String).isEmpty
                ? null
                : map['phoneHome'],
        phoneMobile = map['phoneMobile'],
        email = map['email'] == null || (map['email'] as String).isEmpty
            ? null
            : map['email'],
        postalCode =
            map['postalCode'] == null || (map['postalCode'] as String).isEmpty
                ? null
                : map['postalCode'],
        city = map['city'] == null || (map['city'] as String).isEmpty
            ? null
            : map['city'],
        area = map['area'] == null || (map['area'] as String).isEmpty
            ? null
            : map['area'],
        address = map['address'] == null || (map['address'] as String).isEmpty
            ? null
            : map['address'],
        notesReceived = map['notesReceived'],
        notesRepaired = map['notesRepaired'] == null ||
                (map['notesRepaired'] as String).isEmpty
            ? null
            : map['notesRepaired'],
        fee = map['fee'],
        advance = map['advance'],
        serial = map['serial'] == null || (map['serial'] as String).isEmpty
            ? null
            : map['serial'],
        product = map['product'],
        manufacturer = map['manufacturer'] == null ||
                (map['manufacturer'] as String).isEmpty
            ? null
            : map['manufacturer'],
        photos = (map['photos'] as List).cast<String>(),
        mechanic = map['mechanic'],
        hasWarranty = map['hasWarranty'] == 1,
        warrantyDate = map['warrantyDate'] != null
            ? DateTime.tryParse(map['warrantyDate']) ??
                DateTime.fromMillisecondsSinceEpoch(0)
            : null,
        status = map['status'],
        store = map['store'],
        history =
            ((map['history'] as List).map((e) => History.fromJSON(e)).toList()
              ..sort(
                (a, b) => b.date.compareTo(a.date),
              ));
}

class History {
  DateTime date;
  String notes;

  History({
    required this.date,
    required this.notes,
  });

  History.fromJSON(Map<String, dynamic> map)
      : date = map['date'] != null
            ? DateTime.tryParse(map['date']) ??
                DateTime.fromMillisecondsSinceEpoch(0)
            : DateTime.fromMillisecondsSinceEpoch(0),
        notes = map['notes'];

  Map<String, dynamic> toJSON() => {
        "date": dateTimeFormatDB.format(date),
        "notes": notes,
      };
}

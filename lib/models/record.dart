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
  String postalCode;
  String city;
  String area;
  String address;
  String? notesReceived;
  String? notesRepaired;
  String? fee;
  String? advance;
  String? serial;
  String product;
  String manufacturer;
  String? photo;
  int mechanic;
  bool hasWarranty;
  DateTime? warrantyDate;
  int status;
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
    required this.photo,
    required this.mechanic,
    required this.hasWarranty,
    required this.warrantyDate,
    required this.status,
    required this.history,
  });

  Map<String, dynamic> toJSON() => {
        "id": id,
        "datek": date,
        "onomatep": name,
        "tilefono": phoneHome,
        "kinito": phoneMobile,
        "email": email,
        "tk": postalCode,
        "poli": city,
        "perioxi": area,
        "odos": address,
        "paratiriseis_para": notesReceived,
        "paratiriseis_epi": notesRepaired,
        "pliromi": fee,
        "prokatavoli": advance,
        "serialnr": serial,
        "eidos": product,
        "marka": manufacturer,
        "photo": photo,
        "mastoras_p": mechanic,
        "warranty": hasWarranty,
        "datekwarr": warrantyDate,
        "katastasi_p": status,
      };

  Record.fromJSON(Map<String, dynamic> map)
      : id = map['id'],
        date = map['datek'] != null
            ? DateTime.tryParse(map['datek']) ??
                DateTime.fromMillisecondsSinceEpoch(0)
            : DateTime.fromMillisecondsSinceEpoch(0),
        name = map['onomatep'],
        phoneHome = map['tilefono'],
        phoneMobile = map['kinito'],
        email = map['email'],
        postalCode = map['tk'],
        city = map['poli'],
        area = map['perioxi'],
        address = map['odos'],
        notesReceived = map['paratiriseis_para'],
        notesRepaired = map['paratiriseis_epi'],
        fee = map['pliromi'],
        advance = map['prokatavoli'],
        serial = map['serialnr'],
        product = map['eidos'],
        manufacturer = map['marka'],
        photo = map['photo'],
        mechanic = map['mastoras_p'],
        hasWarranty = map['warranty'] == 1,
        warrantyDate = map['datekwarr'] != null
            ? DateTime.tryParse(map['datekwarr']) ??
                DateTime.fromMillisecondsSinceEpoch(0)
            : null,
        status = map['katastasi_p'],
        history =
            ((map['istorika'] as List).map((e) => History.fromJSON(e)).toList()
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
      : date = map['datek'] != null
            ? DateTime.tryParse(map['datek']) ??
                DateTime.fromMillisecondsSinceEpoch(0)
            : DateTime.fromMillisecondsSinceEpoch(0),
        notes = map['paratiriseis'];

  Map<String, dynamic> toJSON() => {
        "date": dateTimeFormatDB.format(date),
        "notes": notes,
      };
}

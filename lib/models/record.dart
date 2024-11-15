import 'package:flutter/material.dart';
import 'package:indevche/constants.dart';

class Records extends ChangeNotifier {
  List<Record> records = [];

  Records({List<Record>? records}) : records = records ?? [];

  void addRecord(Record record) {
    records.add(record);
    notifyListeners();
  }

  void removeRecord(int index) {
    records.removeWhere((e) => e.id == index);
    notifyListeners();
  }

  void addRecords(List<Record> records) {
    this.records.addAll(records);
    notifyListeners();
  }

  void setRecord(Record record) {
    final index = records.indexWhere((e) => e.id == record.id);
    if (index < 0) throw Error();
    records[index] = record;
    notifyListeners();
  }

  void setRecords(List<Record> records) {
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
  DateTime warrantyDate;
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
      : id = map['id'] as int,
        date = map['datek'] != null
            ? DateTime.tryParse(map['datek']) ?? DateTime.now()
            : DateTime.now(),
        name = map['onomatep'] as String,
        phoneHome = map['tilefono'] as String?,
        phoneMobile = map['kinito'] as String,
        email = map['email'] as String?,
        postalCode = map['tk'] as String,
        city = map['poli'] as String,
        area = map['perioxi'] as String,
        address = map['odos'] as String,
        notesReceived = map['paratiriseis_para'] as String?,
        notesRepaired = map['paratiriseis_epi'] as String?,
        fee = map['pliromi'] as String?,
        advance = map['prokatavoli'] as String?,
        serial = map['serialnr'] as String?,
        product = map['eidos'] as String,
        manufacturer = map['marka'] as String,
        photo = map['photo'] as String?,
        mechanic = map['mastoras_p'] as int,
        hasWarranty = map['warranty'] == 1,
        warrantyDate = map['datekwarr'] != null
            ? DateTime.tryParse(map['datekwarr']) ?? DateTime.now()
            : DateTime.now(),
        status = map['katastasi_p'] as int,
        history = map['istorika'] != null
            ? ((map['istorika'] as List)
                .map((e) => History.fromJSON(e))
                .toList()
              ..sort(
                (a, b) => b.date.compareTo(a.date),
              ))
            : [];
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
            ? DateTime.tryParse(map['datek']) ?? DateTime.now()
            : DateTime.now(),
        notes = map['paratiriseis'] as String;

  Map<String, dynamic> toJSON() => {
        "date": dateTimeFormatDB.format(date),
        "notes": notes,
      };
}

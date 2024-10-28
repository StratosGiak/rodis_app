import 'package:flutter/material.dart';

class Records extends ChangeNotifier {
  List<Record> records = [];

  Records({List<Record>? records}) : records = records ?? [];

  void addRecord(Record record) {
    records.add(record);
    notifyListeners();
  }

  void removeRecord(int index) {
    records.removeAt(index);
    notifyListeners();
  }

  void addRecords(List<Record> records) {
    this.records.addAll(records);
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
  String phoneHome;
  String phoneMobile;
  String email;
  String postalCode;
  String city;
  String area;
  String address;
  String comments;
  String serial;
  String product;
  String manufacturer;
  String photo;
  String mechanic;
  bool hasWarranty;
  DateTime warrantyDate;
  String status;

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
    required this.comments,
    required this.serial,
    required this.product,
    required this.manufacturer,
    required this.photo,
    required this.mechanic,
    required this.hasWarranty,
    required this.warrantyDate,
    required this.status,
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
        "paratiriseis": comments,
        "serialnr": serial,
        "eidos_p": product,
        "marka_p": manufacturer,
        "photo1": photo,
        "mastoras_p": mechanic,
        "warranty": hasWarranty,
        "datekwarr": warrantyDate,
        "katastasi_p": status,
      };

  Record.fromJSON(Map<String, dynamic> map)
      : id = map['id'] as int,
        date = (map['datek'] ?? DateTime.now()) as DateTime,
        name = map['onomatep'] as String,
        phoneHome = map['tilefono'] as String,
        phoneMobile = map['kinito'] as String,
        email = map['email'] as String,
        postalCode = map['tk'] as String,
        city = map['poli'] as String,
        area = map['perioxi'] as String,
        address = map['odos'] as String,
        comments = map['paratiriseis'] as String,
        serial = map['serialnr'] as String,
        product = map['eidos'] as String,
        manufacturer = map['marka'] as String,
        photo = map['photo1'] as String,
        mechanic = map['mastoras'] as String,
        hasWarranty = map['warranty'] == 1,
        warrantyDate = (map['datekwarr'] ?? DateTime.now()) as DateTime,
        status = map['katastasi'] as String;
}

//Important: date, product type, status

enum COLUMN { name, phone, product, manufacturer, date, status }

class RecordView extends ChangeNotifier {
  RecordView();

  COLUMN column = COLUMN.date;
  bool reverse = true;
  Comparator<Record> sorterInner = (p0, p1) => p0.date.compareTo(p1.date);
  Comparator<Record> sorter = (p0, p1) => p1.date.compareTo(p0.date);
  String filterValue = '';
  COLUMN filterType = COLUMN.name;
  bool Function(Record, String) filter =
      (record, value) => record.name.toLowerCase().contains(value);

  void setSort(COLUMN column) {
    if (this.column == column) {
      reverse = !reverse;
    } else {
      this.column = column;
      reverse = false;
      switch (column) {
        case COLUMN.name:
          sorterInner = (p0, p1) => p0.name.compareTo(p1.name);
          break;
        case COLUMN.phone:
          sorterInner = (p0, p1) => p0.phoneMobile.compareTo(p1.phoneMobile);
          break;
        case COLUMN.product:
          sorterInner = (p0, p1) => p0.product.compareTo(p1.product);
          break;
        case COLUMN.manufacturer:
          sorterInner = (p0, p1) => p0.manufacturer.compareTo(p1.manufacturer);
          break;
        case COLUMN.date:
          sorterInner = (p0, p1) => p0.date.compareTo(p1.date);
          break;
        case COLUMN.status:
          sorterInner = (p0, p1) => p0.status.compareTo(p1.status);
          break;
      }
    }
    sorter = (a, b) {
      if (sorterInner(a, b) == 0) return b.date.compareTo(a.date);
      return reverse ? sorterInner(b, a) : sorterInner(a, b);
    };
    notifyListeners();
  }

  void setFilterValue(String filterValue) {
    this.filterValue = filterValue;
    notifyListeners();
  }

  void setFilterType(COLUMN filterType) {
    this.filterType = filterType;
    switch (filterType) {
      case COLUMN.name:
        filter = (record, value) => record.name.toLowerCase().contains(value);
        break;
      case COLUMN.phone:
        filter =
            (record, value) => record.phoneMobile.toLowerCase().contains(value);
        break;
      case COLUMN.product:
        filter =
            (record, value) => record.product.toLowerCase().contains(value);
        break;
      case COLUMN.manufacturer:
        filter = (record, value) =>
            record.manufacturer.toLowerCase().contains(value);
        break;
      case COLUMN.date:
        //filter = (record,value) => record.date.toLowerCase().contains(value);
        break;
      case COLUMN.status:
        filter = (record, value) => record.status.toLowerCase().contains(value);
        break;
    }
    if (filterValue.isNotEmpty) notifyListeners();
  }
}

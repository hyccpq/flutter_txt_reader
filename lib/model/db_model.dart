import 'package:flutter_txt_reader/db/document.dart';
import 'package:flutter_txt_reader/model/index_db_base.dart';

class DBModel {
  final DB db;
  final BookDBBase doc;

  const DBModel(this.db, this.doc);
}

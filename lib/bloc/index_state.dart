import 'package:equatable/equatable.dart';
import 'package:flutter_txt_reader/db/document.dart';
import 'package:flutter_txt_reader/model/index_db_base.dart';
import 'package:meta/meta.dart';

@immutable
abstract class IndexState extends Equatable {
  final String dbName; // 数据库名称
  final String keyName; // 此书的key
  final DB db;

  IndexState({this.dbName, this.keyName, this.db, props = const <dynamic>[]})
      : super([dbName, keyName, db]..addAll(props));
}

class TextIndexState extends IndexState {
  final int readPage;

  TextIndexState({this.readPage = 1, String dbName, String keyName})
      : super(dbName: dbName, keyName: keyName, props: [readPage]);

  @override
  String toString() => '当前初始化页码为$readPage';
}

class InitializationIsComplete extends IndexState {
  final DB db;
  final bool hasBeenInitialized;
  final List<BookDirectoryModel> dirModels;
  final int contentTotalPageLen;
  final int contentTextLen;
  final int lastReadPage;

  InitializationIsComplete(
      {this.db,
      this.hasBeenInitialized,
      this.contentTextLen,
      this.contentTotalPageLen,
      this.dirModels,
      this.lastReadPage})
      : super(db: db, props: [
          db,
          hasBeenInitialized,
          contentTextLen,
          contentTotalPageLen,
          dirModels,
          lastReadPage
        ]);
}

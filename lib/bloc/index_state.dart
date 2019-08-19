import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class IndexState extends Equatable {
  final String dbName; // 数据库名称
  final String keyName; // 此书的key

  IndexState({this.dbName, this.keyName, props = const <dynamic>[]})
      : super([dbName, keyName]..addAll(props));
}

class TextIndexState extends IndexState {
  final int readPage;

  TextIndexState({this.readPage = 1, String dbName, String keyName})
      : super(dbName: dbName, keyName: keyName, props: [readPage]);

  @override
  String toString() => '当前初始化页码为$readPage';
}

// class

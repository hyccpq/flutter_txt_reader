import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class IndexEvent extends Equatable {
  IndexEvent([List props = const <dynamic>[]]) : super(props);
}

class TextIndexEvent extends IndexEvent {
  final int readPage;

  TextIndexEvent(this.readPage) : super([readPage]);
}

class InitDBEvent extends IndexEvent {
  final String dbName;
  final String keyName;
  final String filePath;

  InitDBEvent(this.dbName, this.keyName, this.filePath)
      : super([dbName, keyName, filePath]);
}

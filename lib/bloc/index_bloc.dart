import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter_txt_reader/db/document.dart';
import 'package:flutter_txt_reader/db/write_db.dart';
import 'package:flutter_txt_reader/model/db_model.dart';
import 'package:flutter_txt_reader/model/index_db_base.dart';
import './bloc.dart';

class IndexBloc extends Bloc<IndexEvent, IndexState> {
  @override
  get initialState {
    dispatch(InitDBEvent());
    TextIndexState(readPage: 1);
  }

  @override
  Stream<IndexState> mapEventToState(
    IndexEvent event,
  ) async* {
    if (event is InitDBEvent) {
      DBModel dbModel = await _initTextSource(event);
      yield InitializationIsComplete(
          dirModels: bookMarksFromJson(dbModel.doc.book_dir),
          hasBeenInitialized: true,
          lastReadPage: dbModel.doc.last_read_page ?? 1,
          contentTextLen: dbModel.doc.total_size,
          contentTotalPageLen: dbModel.doc.total_page_num);
    }
  }

  Future<DBModel> _initTextSource(InitDBEvent initDBEvent) async {
    DB db = DB(initDBEvent.dbName);
    await db.initDB();
    BookDBBase doc = await db.getBookLastPage(initDBEvent.keyName);
    if (doc == null) {
      await _initDB(initDBEvent: initDBEvent, db: db);
      doc = await db.getBookLastPage(initDBEvent.keyName);
    } else {
      ComputedBook computedBook = await WriteDB().getPrime(
          keyName: initDBEvent.keyName, filePath: initDBEvent.filePath);
      computedBook.pages.forEach((item) => db.insertPageContent(
          initDBEvent.keyName, item.page, item.startIndex, item.content));
      await db.commitBatch();
      await db.insertBook(
          initDBEvent.keyName,
          computedBook.bookDBBase.total_page_num,
          computedBook.bookDBBase.total_size,
          dir: bookMarksToJson(computedBook.bookDirMs));
    }
    return DBModel(db, doc);
  }

  Future<void> _initDB({InitDBEvent initDBEvent, DB db}) async {}
}

import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter_txt_reader/db/document.dart';
import 'package:flutter_txt_reader/db/write_db.dart';
import 'package:flutter_txt_reader/model/index_db_base.dart';
import './bloc.dart';

class IndexBloc extends Bloc<IndexEvent, IndexState> {
  @override
  IndexState get initialState => TextIndexState(readPage: 1);

  @override
  Stream<IndexState> mapEventToState(
    IndexEvent event,
  ) async* {
    if (event is InitDBEvent) {
      await _initTextSource(event);
    }
    // TODO: Add Logic
  }

  Future<DB> _initTextSource(InitDBEvent initDBEvent) async {
    DB db = DB(initDBEvent.dbName);
    await db.initDB();
    BookDBBase doc = await db.getBookLastPage(initDBEvent.keyName);
    if (doc == null)
      await _initDB(initDBEvent: initDBEvent, db: db);
    else {
      ComputedBook computedBook = await WriteDB().getPrime(
          keyName: initDBEvent.keyName, filePath: initDBEvent.filePath);
      computedBook.pages.forEach((item) => db.insertPageContent(
              initDBEvent.keyName, item.page, item, content)
          // _setPageIndex(
          //     pageNum: item.page,
          //     startFontNum: item.startIndex,
          //     content: item.content)
          );
      await db.commitBatch();
      await db.insertBook(
          initDBEvent.keyName,
          computedBook.bookDBBase.total_page_num,
          computedBook.bookDBBase.total_size,
          dir: bookMarksToJson(computedBook.bookDirMs));
    }
  }

  Future<void> _initDB({InitDBEvent initDBEvent, DB db}) async {}
}

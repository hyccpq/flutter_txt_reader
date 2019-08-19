import 'package:flutter_txt_reader/model/index_db_base.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io';

const String BOOK = 'Book_test2';
const String PAGES = 'Page_test2';

class DB {
  final String name;
  final int version;
  Database _database;

  Batch insertPageContentBatch;

  DB(this.name, {this.version = 1});

  DB.reCreate(this.name, {Database database, this.version = 1}) {
    _database = database;
  }

  get dataBase => _database;

  Future<String> _initDBPath() async {
    String dataBasePath = await getDatabasesPath();
    String path = join(dataBasePath, name + '.db');
    try {
      if (!await Directory(dirname(path)).exists()) {
        await Directory(path).create(recursive: true);
      }

      return path;
    } catch (e, r) {
      print('$e \n $r');
    }
  }

  Future<Null> _createDataBase(Database db, int version) async {
    try {
      await db.execute('''
          CREATE TABLE IF NOT EXISTS $BOOK (
            id TEXT PRIMARY KEY, 
            last_read_pos INTEGER, 
            last_read_page INTEGER,
            total_page_num INTEGER,
            total_size INTEGER,
            book_dir TEXT
          );
          ''');
      await db.execute('''
          CREATE TABLE IF NOT EXISTS $PAGES (
            id INTEGER PRIMARY KEY AUTOINCREMENT, 
            book_id TEXT,
            page INTEGER,
            start_index INTEGER,
            content TEXT
          );
          ''');
    } catch (e, r) {
      throw e;
    }
  }

  Future<Database> initDB() async {
    try {
      String dbPath = await _initDBPath();
      print(dbPath);
      _database = await openDatabase(dbPath,
          version: version, onCreate: _createDataBase, singleInstance: false);
      return _database;
    } catch (e, r) {
      print('$e \n $r');
    }
  }

  Future<Null> insertBook(String id, int totalPageNum, int totalLen,
      {String dir = ''}) async {
    try {
      int count = await _database.rawInsert('''
        INSERT INTO $BOOK(id, total_page_num, total_size, book_dir) VALUES(?, ?, ?, ?);
      ''', [id, totalPageNum, totalLen, dir]);
      print('成功$count');
    } catch (e, r) {
      print('$e \n $r');
    }
  }

  Future<Null> updateBookDoc(
      String id, int lastReadPos, int lastReadPage) async {
    try {
      int count = await _database.rawUpdate('''
        UPDATE $BOOK SET last_read_page = ?, last_read_pos = ? WHERE id = ?;
      ''', [lastReadPage, lastReadPos, id]);
      print(count);
    } catch (e, r) {
      print('$e \n $r');
    }
  }

  /// 查询最后一次阅读位置, 书的总页数
  Future<BookDBBase> getBookLastPage(String id) async {
    try {
      var text = await _database.rawQuery('''
        SELECT * FROM $BOOK WHERE id = ?;
      ''', [id]);
      if (text.length == 0) return null;
      return BookDBBase.fromMap(text[0]);
    } catch (e, r) {
      print('$e \n $r');
    }
  }

  /// 查询书中含有某字符串的
  Future<List<IndexDBBase>> getBookPageHasOneTotal(
      String id, String omit) async {
    try {
      var pageContent = await _database.rawQuery('''
      SELECT * FROM $PAGES WHERE book_id = ? AND content LIKE '%$omit%';
    ''', [id]);
      return pageContent.map((x) => IndexDBBase.fromMap(x)).toList();
    } catch (e, r) {
      print('$e \n $r');
    }
  }

  Future<IndexDBBase> getPageContent(String book_id, int page) async {
    try {
      List pageContent = await _database.rawQuery('''
        SELECT * FROM $PAGES WHERE book_id = ? AND page = ?;
      ''', [book_id, page]);
      assert(pageContent.length != 0);
//      pageContent.forEach(print);
      return IndexDBBase.fromMap(pageContent[0]);
    } catch (e, r) {
      print('$e \n $r');
    }
  }

  /// 此处为批量操作，添加完毕后，记得调用commitBatch;
  void insertPageContent(
      String book_id, int page, int startIndex, String content) {
    if (insertPageContentBatch == null)
      insertPageContentBatch = _database.batch();
//    print('book_id $book_id, page $page, startIndex $startIndex');
    insertPageContentBatch.insert(PAGES, {
      'book_id': book_id,
      'page': page,
      'start_index': startIndex,
      'content': content
    });
//    insertPageContentBatch.rawInsert('''
//            INSERT INTO $PAGES(book_id, page, start_index, content) VALUES(?, ?, ?, ?);
//          ''', [book_id, page, startIndex, content]);
  }

  Future<Null> commitBatch() async {
    try {
      await insertPageContentBatch.commit();
    } catch (e, r) {
      print('$e \n $r');
    }
  }

  Future close() async => _database.close();
}

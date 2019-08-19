import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

// import 'package:flutter_reader/widget/model/index_db_base.dart';
// import 'package:flutter_reader/widget/my_painter.dart';
import 'package:flutter_txt_reader/model/index_db_base.dart';
import 'package:flutter_txt_reader/painter/my_painter.dart';

class WriteDB {
  static RegExp exp =
      RegExp(r'第[\\s0-9一二三四五六七八九十百千万壹贰叁肆伍陆柒捌玖零拾佰仟万]+[章节卷集部篇回].{0,9}');

  WriteDB();

  Future<ComputedBook> getPrime({String keyName, String filePath}) async {
    ReceivePort receivePort = ReceivePort();
    Isolate isolate = await Isolate.spawn<CrossIsolateMessage>(
        initDoc,
        CrossIsolateMessage(
            keyName: keyName,
            filePath: filePath,
            sendPort: receivePort.sendPort));

//    final sendPort = await receivePort.first as SendPort;
//    //接收訊息的ReceivePort
//    final answer = ReceivePort();
//    //傳送資料
//    sendPort
//        .send(CrossIsolateMessage(keyName: keyName, filePath: filePath, sendPort: answer.sendPort));
    final result = await receivePort.first as ComputedBook;
    receivePort.close();
    isolate?.kill();
    print(result);
    return result;
  }

  static initDoc(CrossIsolateMessage msg) async {
//    compute(callback, message)
//    ReceivePort receivePort = ReceivePort();
//    sendPort.send(receivePort.sendPort);
//    CrossIsolateMessage msg = await receivePort.first;
//    receivePort.close();
//    DB db = DB(msg.keyName);
//    await db.initDB();
    File file = await _getLocalFile(msg.filePath);
    ComputedBook computedBook = await _getTextIndex(file);
    msg.sendPort.send(computedBook);
  }

  static Future<File> _getLocalFile(String savePath) async {
    File file = new File(savePath);
    assert(savePath != null);
//    assert(await file.exists());
    return file;
  }

  static Future<ComputedBook> _getTextIndex(File file) async {
    try {
      Stream<List<int>> stream = file.openRead();
      int index = 0;
      int totalNumberWords = 0;
      String cur = ''; // 多余文字
      String curText = ''; // 当前页文字
      List<IndexDBBase> pages = <IndexDBBase>[];
      List<BookDirectoryModel> bookDirMs = <BookDirectoryModel>[];

      Stream<String> lines =
          stream.transform(utf8.decoder).transform<String>(LineSplitter());
      // 按行读取
      await for (String first in lines) {
//        first += '\n';
        first = '  ' + first + '\n';
        cur += first;
        if (cur.length >= LARGEST_NUMBER_WORDS /* 单页最多字数 */) {
//          print('字数 ==> ${cur.length}');
          int pageTextNum = MyPainter.rangStr(cur, maxLen: cur.length);

          curText = cur.substring(0, pageTextNum);
          List<BookDirectoryModel> bookDir = exp
              .allMatches(curText)
              .map((m) =>
                  BookDirectoryModel(title: m.group(0), pageNum: index + 1))
              .toList();
          bookDirMs.addAll(bookDir);
          pages.add(IndexDBBase(
              page: index + 1, startIndex: totalNumberWords, content: curText));
          totalNumberWords += pageTextNum;
          cur = cur.substring(pageTextNum);
//          print('剩余字数 ${cur.length} ==>> $cur');
          index++;
        }
      }
      print(cur);
      int totalWords = totalNumberWords + cur.length;
      List<BookDirectoryModel> bookDir = exp
          .allMatches(cur)
          .map((m) => BookDirectoryModel(title: m.group(0), pageNum: index + 1))
          .toList();
      bookDirMs.addAll(bookDir);
      pages.add(IndexDBBase(
          page: index + 1, startIndex: totalNumberWords, content: cur));
      BookDBBase bookDBBase =
          BookDBBase(total_size: totalWords, total_page_num: index + 1);
      print(bookDirMs);
      return ComputedBook(
          pages: pages, bookDBBase: bookDBBase, bookDirMs: bookDirMs);
//      await db.insertBook(keyName, index + 1, totalWords);
//      await db.commitBatch();
    } catch (e, s) {
      print(e);
      print('Stark trace:\n $s');
    }
  }
//      db.insertPageContent(keyName, pageNum, startFontNum, content);
}

class CrossIsolateMessage {
  final SendPort sendPort;
  final String keyName;
  final String filePath;

  CrossIsolateMessage({this.keyName, this.filePath, this.sendPort});
}

class ComputedBook {
  final List<IndexDBBase> pages;
  final BookDBBase bookDBBase;
  final List<BookDirectoryModel> bookDirMs;

  ComputedBook({
    this.bookDBBase,
    this.pages,
    this.bookDirMs = const <BookDirectoryModel>[],
  });
}

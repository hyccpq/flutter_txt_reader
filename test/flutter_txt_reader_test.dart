import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_txt_reader/flutter_txt_reader.dart';

void main() {
  const MethodChannel channel = MethodChannel('flutter_txt_reader');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await FlutterTxtReader.platformVersion, '42');
  });
}

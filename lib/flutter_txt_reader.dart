import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_txt_reader/bloc/bloc.dart';
import 'package:flutter_txt_reader/reader_index.dart';

class FlutterTxtReader extends StatelessWidget {
  static const MethodChannel _channel =
      const MethodChannel('flutter_txt_reader');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return BlocProvider<IndexBloc>(
      builder: (BuildContext context) => IndexBloc(),
      child: BlocBuilder<IndexBloc, IndexState>(
        builder: (BuildContext context, state) {
          return _FlutterTextReadIndex();
        },
      ),
    );
  }
}

class _FlutterTextReadIndex extends StatefulWidget {
  @override
  __FlutterTextReadIndexState createState() => __FlutterTextReadIndexState();
}

class __FlutterTextReadIndexState extends State<_FlutterTextReadIndex> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

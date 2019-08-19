import 'package:flutter/material.dart';

class Tool {
  static Future<bool> showAlert<bool>(
      {BuildContext context, @required String text, String cancelName = '取消', String confirmName = '确认'}) {
    return showDialog<bool>(
        context: context,
        builder: (BuildContext context) =>
            AlertDialog(
              content: Text(
                text,
                style: Theme
                    .of(context)
                    .textTheme
                    .subhead,
              ),
              actions: <Widget>[
                FlatButton(
                  child: const Text('取消'),
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                ),
                FlatButton(
                  child: const Text('确定'),
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                ),
              ],
            ),
    );
  }
}
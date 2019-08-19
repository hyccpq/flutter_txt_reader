import 'package:flutter/material.dart';

class FullScreenDiaLog extends StatelessWidget {
  final Widget child;
  final String title;
  final String rightTopBtn;
  final bool isShowRightBtn;
  final VoidCallback saveThis;
  final PreferredSizeWidget bottom;

  const FullScreenDiaLog({Key key,
    this.child,
    this.bottom,
    @required this.title,
    this.rightTopBtn = '保存',
    this.isShowRightBtn = true, this.saveThis})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(title: Text(title), bottom: bottom, actions: <Widget>[
          isShowRightBtn ? FlatButton(
            child: Text(
              rightTopBtn,
              style: TextStyle(
                  color: Theme
                      .of(context)
                      ?.primaryIconTheme
                      ?.color ??
                      Colors.white),
            ),
            onPressed: saveThis,
          ) : Container(),
        ]),
        body: child);
  }
}

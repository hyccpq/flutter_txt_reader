import 'package:flutter/material.dart';

class EditBar extends StatelessWidget {
  final bool isDeleteMode;
  final void Function(int val, BuildContext context) userEditMode;

  const EditBar({Key key, this.isDeleteMode = false, this.userEditMode})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      onTap: (int val) => userEditMode(val, context),
      fixedColor: Colors.black,
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
            icon: Icon(Icons.content_paste), title: const Text('复制')),
        isDeleteMode
            ? BottomNavigationBarItem(
                icon: Icon(Icons.delete), title: const Text('删除笔记'))
            : BottomNavigationBarItem(
                icon: Icon(Icons.library_books), title: const Text('记笔记')),
        BottomNavigationBarItem(
            icon: Icon(Icons.close), title: const Text('取消'))
      ],
      type: BottomNavigationBarType.fixed,
    );
  }
}

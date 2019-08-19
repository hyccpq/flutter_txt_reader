import 'package:flutter/material.dart';

class BarContent extends StatefulWidget {
  final Widget child;

  final String title;
  final MediaQueryData mediaQueryData;
  final bool isShowBar;
  final bool isAdvance;
  final bool isMarked;
  final ReadStatus readStatus;
  final void Function(ReadStatus) selectMode;
  final void Function(IntoDialog) intoNextDialog;
  final VoidCallback onChangeMark;

  BarContent(
      {this.child,
      this.title = '',
      @required this.mediaQueryData,
      this.isShowBar = false,
      this.readStatus = ReadStatus.readerMode,
      @required this.selectMode,
      @required this.intoNextDialog,
      @required this.isAdvance,
      this.isMarked = false,
      this.onChangeMark});

  @override
  _BarContentState createState() => _BarContentState();
}

class _BarContentState extends State<BarContent> with TickerProviderStateMixin {
  AnimationController _showBarController;
  Animation<double> _showBarAnimation;
  double topBarHeight;
  double bottomBarHeight;

  @override
  void didUpdateWidget(BarContent oldWidget) {
    if (widget.isShowBar != oldWidget.isShowBar && widget.isShowBar != null)
      widget.isShowBar
          ? _showBarController?.forward()
          : _showBarController?.reverse();

    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    super.initState();
    _showBarController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    _showBarAnimation = Tween(begin: -1.0, end: 0.0).animate(
        CurvedAnimation(parent: _showBarController, curve: Curves.easeIn))
      ..addListener(() {
        setState(() {});
      });
    topBarHeight = widget.mediaQueryData.size.height * 0.1 +
        widget.mediaQueryData.padding.top;
    bottomBarHeight = widget.mediaQueryData.size.height * 0.1 +
        widget.mediaQueryData.padding.bottom;
  }

  @override
  void dispose() {
    if (_showBarController?.isAnimating ?? false) _showBarController?.dispose();
    super.dispose();
  }

  void _clickBottomBar(int val) {
    if (!widget.isAdvance) {
      switch (val) {
        case 0:
          widget.intoNextDialog(IntoDialog.addFeel);
          break;
        case 1:
          widget.intoNextDialog(IntoDialog.viewResult);
          break;
      }
    } else {
      switch (val) {
        case 0:
          widget.intoNextDialog(IntoDialog.viewDirectory);
          break;
        case 1:
          widget.intoNextDialog(IntoDialog.addFeel);
          break;
        case 2:
          widget.intoNextDialog(IntoDialog.viewResult);
          break;
        case 3:
          widget.intoNextDialog(IntoDialog.viewBookmarks);
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        RepaintBoundary(
          child: widget.child,
        ),
        Positioned(
            top: _showBarAnimation.value * topBarHeight,
            left: 0.0,
            right: 0.0,
            child: Container(
              padding: EdgeInsets.only(top: widget.mediaQueryData.padding.top),
              color: Theme.of(context).primaryColor,
              child: SizedBox(
                child: AppBar(
                  title: Text(widget.title),
                  primary: false,
//                  leading: IconButton(
//                    icon: Icon(Icons.arrow_back_ios),
//                    onPressed: () {},
//                    tooltip: '返回',
//                  ),
                  actions: <Widget>[
                    widget.isAdvance
                        ? IconButton(
                            icon: widget.isMarked
                                ? Icon(Icons.bookmark)
                                : Icon(Icons.bookmark_border),
                            color: widget.isMarked
                                ? const Color(activeColor)
                                : Colors.white,
                            onPressed: widget.onChangeMark,
                          )
                        : Container(),
                    IconButton(
                      icon: Icon(Icons.title,
                          color: widget.readStatus == ReadStatus.selectMode
                              ? Color(activeColor)
                              : Colors.white),
                      onPressed: () => widget.selectMode(ReadStatus.selectMode),
                    ),
                    IconButton(
                      icon: Icon(Icons.search),
                      onPressed: () => widget.intoNextDialog(IntoDialog.search),
                    ),
                    IconButton(
                      icon: Icon(Icons.edit,
                          color: widget.readStatus == ReadStatus.noteModel
                              ? Color(activeColor)
                              : Colors.white),
                      onPressed: () => widget.selectMode(ReadStatus.noteModel),
                    )
                  ],
                ),
              ),
            )),
        !widget.isAdvance
            ? Positioned(
                bottom: _showBarAnimation.value * bottomBarHeight,
                left: 0.0,
                right: 0.0,
                child: BottomNavigationBar(
                  onTap: _clickBottomBar,
                  items: <BottomNavigationBarItem>[
                    BottomNavigationBarItem(
                        icon: Icon(Icons.playlist_add),
                        title: const Text('添加心得')),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.book), title: const Text('查看心得/笔记'))
                  ],
                  type: BottomNavigationBarType.fixed,
                ),
              )
            : Positioned(
                bottom: _showBarAnimation.value * bottomBarHeight,
                left: 0.0,
                right: 0.0,
                child: BottomNavigationBar(
                  onTap: _clickBottomBar,
                  currentIndex: 1,
                  items: <BottomNavigationBarItem>[
                    BottomNavigationBarItem(
                        icon: Icon(Icons.description),
                        title: const Text('查看目录')),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.playlist_add),
                        title: const Text('添加心得')),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.book), title: const Text('查看心得/笔记')),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.collections_bookmark),
                        title: const Text('查看书签')),
                  ],
                  type: BottomNavigationBarType.fixed,
                ),
              )
      ],
    );
  }
}

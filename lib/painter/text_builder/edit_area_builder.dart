part of edit_builder;

class EditAreaBuilder extends TextBuilder {
  EditAreaBuilder({
    eWidth,
    fontSize,
    eHeight,
    omitHeight,
    omitWidth,
    canvas,
    this.startEdit,
    this.endEdit,
    this.renderEditEnd,
    this.renderEditStart
  }) : super(
          eWidth: eWidth,
          fontSize: fontSize,
          eHeight: eHeight,
          omitHeight: omitHeight,
          omitWidth: omitWidth,
          canvas: canvas,
        );

  final int startEdit;
  final int endEdit;
  final int renderEditEnd;
  final int renderEditStart;

//  static int startIndex;
//  static int endIndex;
  String _curString = '';
  String _lastString = '';

  String get curString => _curString;
  String get lastString => _lastString;

  static Paint _paintCur = Paint()
    ..isAntiAlias = true
    ..style = PaintingStyle.fill //填充
    ..color = Color(deepEditColor); //背景

  static Paint _paintLast = Paint()
    ..isAntiAlias = true
    ..style = PaintingStyle.fill //填充
    ..color = Color(editColor); //背景

  @override
  void build(String char,
      {int row = 0, int column = 0, int fontIndex, bool breakLine}) {
    // TODO: implement build
    Offset offset = createOffset(row, column);
    if (renderEditStart != null &&
        renderEditEnd != null) {
      int boxIndex = row * COLUMN + column + 1;
      if (renderEditStart <= boxIndex && renderEditEnd >= boxIndex) {
        _lastString += char;
        canvas.drawRect(offset & Size(eWidth, eHeight), _paintLast);
      }
    }

    if (startEdit != null && endEdit != null) {
      int boxIndex = row * COLUMN + column + 1;
      if (boxIndex >= startEdit && boxIndex <= endEdit) {
        _curString += char;
        canvas.drawRect(offset & Size(eWidth, eHeight), _paintCur);
      }
    }
  }
}

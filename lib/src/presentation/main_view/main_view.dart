// ignore_for_file: must_be_immutable

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:stories_editor/src/domain/models/editable_items.dart';
import 'package:stories_editor/src/domain/models/painting_model.dart';
import 'package:stories_editor/src/domain/providers/notifiers/control_provider.dart';
import 'package:stories_editor/src/domain/providers/notifiers/draggable_widget_notifier.dart';
import 'package:stories_editor/src/domain/providers/notifiers/gradient_notifier.dart';
import 'package:stories_editor/src/domain/providers/notifiers/language_provider.dart';
import 'package:stories_editor/src/domain/providers/notifiers/painting_notifier.dart';
import 'package:stories_editor/src/domain/providers/notifiers/scroll_notifier.dart';
import 'package:stories_editor/src/domain/providers/notifiers/text_editing_notifier.dart';
import 'package:stories_editor/src/l18n/strings.dart';
import 'package:stories_editor/src/presentation/bar_tools/bottom_tools.dart';
import 'package:stories_editor/src/presentation/bar_tools/top_tools.dart';
import 'package:stories_editor/src/presentation/draggable_items/delete_item.dart';
import 'package:stories_editor/src/presentation/draggable_items/draggable_widget.dart';
import 'package:stories_editor/src/presentation/painting_view/painting.dart';
import 'package:stories_editor/src/presentation/painting_view/widgets/sketcher.dart';
import 'package:stories_editor/src/presentation/text_editor_view/TextEditor.dart';
import 'package:stories_editor/src/presentation/utils/constants/app_enums.dart';
import 'package:stories_editor/src/presentation/utils/modal_sheets.dart';

class MainView extends StatefulWidget {
  /// editor custom font families
  final List<String>? fontFamilyList;

  /// editor custom font families package
  final bool? isCustomFontList;

  /// giphy api key
  final String giphyKey;

  /// editor custom color gradients
  final List<List<Color>>? gradientColors;

  /// editor custom logo
  final Widget? middleBottomWidget;

  /// on done
  final Function(String, bool)? onDone;

  /// on done button Text
  final Widget? onDoneButtonStyle;

  /// on back pressed
  final Future<bool>? onBackPress;

  /// editor background color
  Color? editorBackgroundColor;

  /// gallery thumbnail quality
  final int? galleryThumbnailQuality;

  /// editor custom color palette list
  List<Color>? colorList;

  final String? initialImagePath;

  final bool? isInitialImageLocked;

  final String? onDoneButtonTitle;

  final String? showAddImageButtonTitle;

  final int? colorDefaultOffsetIndex;

  final Color? placeholderColor;

  final String languageCode;

  MainView({
    super.key,
    required this.giphyKey,
    required this.onDone,
    this.middleBottomWidget,
    this.colorList,
    this.isCustomFontList,
    this.fontFamilyList,
    this.gradientColors,
    this.onBackPress,
    this.onDoneButtonStyle,
    this.editorBackgroundColor,
    this.galleryThumbnailQuality,
    this.initialImagePath,
    this.isInitialImageLocked,
    this.onDoneButtonTitle,
    required this.showAddImageButtonTitle,
    this.colorDefaultOffsetIndex,
    this.placeholderColor,
    required this.languageCode,
  });

  @override
  MainViewState createState() => MainViewState();
}

class MainViewState extends State<MainView> {
  /// content container key
  final GlobalKey contentKey = GlobalKey();

  ///Editable item
  EditableItem? _activeItem;

  /// Gesture Detector listen changes
  Offset _initPos = const Offset(0, 0);
  Offset _currentPos = const Offset(0, 0);
  double _currentScale = 1;
  double _currentRotation = 0;

  /// delete position
  bool _isDeletePosition = false;
  bool _inAction = false;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      var control = Provider.of<ControlNotifier>(context, listen: false);
      var draggableWidgetProvider =
          Provider.of<DraggableWidgetNotifier>(context, listen: false);
      var language = Provider.of<LanguageProvider>(context, listen: false);

      /// initialize control variable provider
      control.giphyKey = widget.giphyKey;
      control.middleBottomWidget = widget.middleBottomWidget;
      control.isCustomFontList = widget.isCustomFontList ?? false;
      if (widget.gradientColors != null) {
        control.gradientColors = widget.gradientColors;
      }
      if (widget.fontFamilyList != null) {
        control.fontList = widget.fontFamilyList;
      }
      if (widget.colorList != null) {
        control.colorList = widget.colorList;
      }
      if (widget.initialImagePath != null) {
        control.mediaPath = widget.initialImagePath!;
        var editItem = EditableItem()
          ..type = ItemType.image
          ..position = const Offset(0.0, 0);
        if (widget.isInitialImageLocked == true) {
          editItem = editItem..isLock = true;
        }
        draggableWidgetProvider.draggableWidget.insert(
          0,
          editItem,
        );
      }
      language.strings = from(widget.languageCode);
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ScreenUtil screenUtil = ScreenUtil();
    return PopScope(
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) {
          return;
        }
        _popScope();
      },
      child: Material(
        color: widget.editorBackgroundColor == Colors.transparent
            ? Colors.black
            : widget.editorBackgroundColor ?? Colors.black,
        child: Consumer6<
            ControlNotifier,
            DraggableWidgetNotifier,
            ScrollNotifier,
            GradientNotifier,
            PaintingNotifier,
            TextEditingNotifier>(
          builder: (context, controlNotifier, itemProvider, scrollProvider,
              colorProvider, paintingProvider, editingProvider, child) {
            return SafeArea(
              //top: false,
              child: Column(
                children: [
                  Expanded(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        ///gradient container
                        /// this container will contain all widgets(image/texts/draws/sticker)
                        /// wrap this widget with coloredFilter
                        GestureDetector(
                          onScaleStart: _onScaleStart,
                          onScaleUpdate: _onScaleUpdate,
                          onTap: () {
                            controlNotifier.isTextEditing =
                                !controlNotifier.isTextEditing;
                          },
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(25),
                              child: SizedBox(
                                width: screenUtil.screenWidth,
                                child: RepaintBoundary(
                                  key: contentKey,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    decoration: BoxDecoration(
                                        gradient:
                                            controlNotifier.mediaPath.isEmpty
                                                ? LinearGradient(
                                                    colors: controlNotifier
                                                            .gradientColors![
                                                        controlNotifier
                                                            .gradientIndex],
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                  )
                                                : LinearGradient(
                                                    colors: [
                                                      colorProvider.color1,
                                                      colorProvider.color2
                                                    ],
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                  )),
                                    child: GestureDetector(
                                      onScaleStart: _onScaleStart,
                                      onScaleUpdate: _onScaleUpdate,
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          /// in this case photo view works as a main background container to manage
                                          /// the gestures of all movable items.
                                          PhotoView.customChild(
                                            backgroundDecoration:
                                                const BoxDecoration(
                                                    color: Colors.transparent),
                                            child: Container(),
                                          ),

                                          ///list items
                                          ...itemProvider.draggableWidget
                                              .map((editableItem) {
                                            return DraggableWidget(
                                              context: context,
                                              draggableWidget: editableItem,
                                              onPointerDown: (details) {
                                                _updateItemPosition(
                                                  editableItem,
                                                  details,
                                                );
                                              },
                                              onPointerUp: (details) {
                                                _deleteItemOnCoordinates(
                                                  editableItem,
                                                  details,
                                                );
                                              },
                                              onPointerMove: (details) {
                                                _deletePosition(
                                                  editableItem,
                                                  details,
                                                );
                                              },
                                            );
                                          }),

                                          /// finger paint
                                          IgnorePointer(
                                            ignoring: true,
                                            child: Align(
                                              alignment: Alignment.topCenter,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(25),
                                                ),
                                                child: RepaintBoundary(
                                                  child: SizedBox(
                                                    width:
                                                        screenUtil.screenWidth,
                                                    child: StreamBuilder<
                                                        List<PaintingModel>>(
                                                      stream: paintingProvider
                                                          .linesStreamController
                                                          .stream,
                                                      builder:
                                                          (context, snapshot) {
                                                        return CustomPaint(
                                                          painter: Sketcher(
                                                            lines:
                                                                paintingProvider
                                                                    .lines,
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        /// middle text
                        if (itemProvider.draggableWidget
                                .where((e) => !e.isLock)
                                .isEmpty &&
                            !controlNotifier.isTextEditing &&
                            paintingProvider.lines.isEmpty)
                          IgnorePointer(
                            ignoring: true,
                            child: Align(
                              alignment: const Alignment(0, -0.1),
                              child: Consumer<LanguageProvider>(
                                  builder: (context, provider, _) {
                                return Text(
                                  provider.strings.tapAndInput(),
                                  style: TextStyle(
                                    fontFamily: 'Alegreya',
                                    package: 'stories_editor',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 30,
                                    color: widget.placeholderColor ??
                                        Colors.white.withOpacity(0.5),
                                    shadows: <Shadow>[
                                      Shadow(
                                        offset: const Offset(1.0, 1.0),
                                        blurRadius: 3.0,
                                        color: Colors.black45.withOpacity(0.3),
                                      )
                                    ],
                                  ),
                                );
                              }),
                            ),
                          ),

                        /// top tools
                        Visibility(
                          visible: !controlNotifier.isTextEditing &&
                              !controlNotifier.isPainting,
                          child: Align(
                              alignment: Alignment.topCenter,
                              child: TopTools(
                                contentKey: contentKey,
                                context: context,
                              )),
                        ),

                        /// delete item when the item is in position
                        DeleteItem(
                          activeItem: _activeItem,
                          animationsDuration: const Duration(milliseconds: 300),
                          isDeletePosition: _isDeletePosition,
                        ),

                        /// show text editor
                        Visibility(
                          visible: controlNotifier.isTextEditing,
                          child: TextEditor(
                            context: context,
                            colorDefaultOffsetIndex:
                                widget.colorDefaultOffsetIndex,
                          ),
                        ),

                        /// show painting sketch
                        Visibility(
                          visible: controlNotifier.isPainting,
                          child: const Painting(),
                        ),
                      ],
                    ),
                  ),

                  /// bottom tools
                  if (!kIsWeb)
                    BottomTools(
                      contentKey: contentKey,
                      onDone: (bytes, nextEdit) {
                        setState(() {
                          widget.onDone!(bytes, nextEdit);
                        });
                      },
                      onDoneButtonStyle: widget.onDoneButtonStyle,
                      editorBackgroundColor: widget.editorBackgroundColor,
                      onDoneButtonTitle: widget.onDoneButtonTitle,
                      showAddImageButtonTitle: widget.showAddImageButtonTitle,
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// validate pop scope gesture
  Future<bool> _popScope() async {
    final controlNotifier =
        Provider.of<ControlNotifier>(context, listen: false);
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);

    /// change to false text editing
    if (controlNotifier.isTextEditing) {
      controlNotifier.isTextEditing = !controlNotifier.isTextEditing;
      return false;
    }

    /// change to false painting
    else if (controlNotifier.isPainting) {
      controlNotifier.isPainting = !controlNotifier.isPainting;
      return false;
    }

    /// show close dialog
    else if (!controlNotifier.isTextEditing && !controlNotifier.isPainting) {
      Future.microtask(() async {
        final ctxt = context;
        if (!ctxt.mounted) {
          return;
        }
        exitDialog(
          context: ctxt,
          contentKey: contentKey,
          languageProvider: languageProvider,
        );
      });
    }
    return false;
  }

  /// start item scale
  void _onScaleStart(ScaleStartDetails details) {
    if (_activeItem == null) {
      return;
    }
    if (_activeItem?.isLock == true) {
      return;
    }
    _initPos = details.focalPoint;
    _currentPos = _activeItem!.position;
    _currentScale = _activeItem!.scale;
    _currentRotation = _activeItem!.rotation;
  }

  /// update item scale
  void _onScaleUpdate(ScaleUpdateDetails details) {
    final ScreenUtil screenUtil = ScreenUtil();
    if (_activeItem == null) {
      return;
    }
    if (_activeItem?.isLock == true) {
      return;
    }
    final delta = details.focalPoint - _initPos;

    final left = (delta.dx / screenUtil.screenWidth) + _currentPos.dx;
    final top = (delta.dy / screenUtil.screenHeight) + _currentPos.dy;

    setState(() {
      _activeItem!.position = Offset(left, top);
      _activeItem!.rotation = details.rotation + _currentRotation;
      _activeItem!.scale = details.scale * _currentScale;
    });
  }

  /// active delete widget with offset position
  void _deletePosition(EditableItem item, PointerMoveEvent details) {
    if (item.type == ItemType.text &&
        item.position.dy >= 0.75.h &&
        item.position.dx >= -0.4.w &&
        item.position.dx <= 0.2.w) {
      setState(() {
        _isDeletePosition = true;
        item.deletePosition = true;
      });
    } else if (item.type == ItemType.gif &&
        item.position.dy >= 0.62.h &&
        item.position.dx >= -0.35.w &&
        item.position.dx <= 0.15) {
      setState(() {
        _isDeletePosition = true;
        item.deletePosition = true;
      });
    } else {
      setState(() {
        _isDeletePosition = false;
        item.deletePosition = false;
      });
    }
  }

  /// delete item widget with offset position
  void _deleteItemOnCoordinates(EditableItem item, PointerUpEvent details) {
    var itemProvider =
        Provider.of<DraggableWidgetNotifier>(context, listen: false)
            .draggableWidget;
    _inAction = false;
    if (item.type == ItemType.image) {
    } else if (item.type == ItemType.text &&
            item.position.dy >= 0.75.h &&
            item.position.dx >= -0.4.w &&
            item.position.dx <= 0.2.w ||
        item.type == ItemType.gif &&
            item.position.dy >= 0.62.h &&
            item.position.dx >= -0.35.w &&
            item.position.dx <= 0.15) {
      setState(() {
        itemProvider.removeAt(itemProvider.indexOf(item));
        HapticFeedback.heavyImpact();
      });
    } else {
      setState(() {
        _activeItem = null;
      });
    }
    setState(() {
      _activeItem = null;
    });
  }

  /// update item position, scale, rotation
  void _updateItemPosition(EditableItem item, PointerDownEvent details) {
    if (_inAction) {
      return;
    }

    _inAction = true;
    _activeItem = item;
    _initPos = details.position;
    _currentPos = item.position;
    _currentScale = item.scale;
    _currentRotation = item.rotation;

    /// set vibrate
    HapticFeedback.lightImpact();
  }
}

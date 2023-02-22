import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:stories_editor/src/domain/models/editable_items.dart';
import 'package:stories_editor/src/domain/providers/notifiers/control_provider.dart';
import 'package:stories_editor/src/domain/providers/notifiers/draggable_widget_notifier.dart';
import 'package:stories_editor/src/domain/providers/notifiers/scroll_notifier.dart';
import 'package:stories_editor/src/domain/sevices/save_as_image.dart';
import 'package:stories_editor/src/presentation/utils/constants/app_enums.dart';
import 'package:stories_editor/src/presentation/widgets/animated_onTap_button.dart';

class BottomTools extends StatefulWidget {
  final GlobalKey contentKey;
  final Function(String imageUri, bool nextEdit) onDone;
  final Widget? onDoneButtonStyle;
  final String? onDoneButtonTitle;
  final bool showAddImageButton;

  /// editor background color
  final Color? editorBackgroundColor;
  const BottomTools({
    Key? key,
    required this.contentKey,
    required this.onDone,
    this.onDoneButtonStyle,
    this.editorBackgroundColor,
    this.onDoneButtonTitle = 'とうこうする',
    required this.showAddImageButton,
  }) : super(key: key);

  @override
  State<BottomTools> createState() => _BottomToolsState();
}

class _BottomToolsState extends State<BottomTools> {
  var isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Consumer3<ControlNotifier, ScrollNotifier, DraggableWidgetNotifier>(
      builder: (_, controlNotifier, scrollNotifier, itemNotifier, __) {
        return Container(
          decoration: const BoxDecoration(color: Colors.transparent),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 40.h),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                /// preview gallery
                Container(
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    child: _preViewContainer(
                      /// if [model.imagePath] is null/empty return preview image
                      child: controlNotifier.mediaPath.isEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: GestureDetector(
                                onTap: () async {
                                  final picker = ImagePicker();
                                  final image = await picker.pickImage(
                                      source: ImageSource.gallery);
                                  controlNotifier.mediaPath = image!.path;
                                  if (controlNotifier.mediaPath.isNotEmpty) {
                                    itemNotifier.draggableWidget.insert(
                                      0,
                                      EditableItem()
                                        ..type = ItemType.image
                                        ..position = const Offset(0.0, 0),
                                    );
                                  }
                                },
                                child: const Icon(
                                  Icons.photo_library_outlined,
                                  color: Colors.white,
                                ),
                              ))

                          /// return clear [imagePath] provider
                          : GestureDetector(
                              onTap: () {
                                /// clear image url variable
                                controlNotifier.mediaPath = '';
                                itemNotifier.draggableWidget.removeAt(0);
                              },
                              child: Container(
                                height: 45,
                                width: 45,
                                color: Colors.transparent,
                                child: Transform.scale(
                                  scale: 0.7,
                                  child: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ),
                ),

                /// center logo
                if (controlNotifier.middleBottomWidget != null)
                  Expanded(
                    child: Center(
                      child: Container(
                          alignment: Alignment.bottomCenter,
                          child: controlNotifier.middleBottomWidget),
                    ),
                  ),

                /// save final image to gallery or edit next
                isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Row(
                        children: [
                          if (widget.showAddImageButton)
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: AnimatedOnTapButton(
                                onTap: () async => _onTapDone(true),
                                child: Container(
                                  padding: const EdgeInsets.only(
                                    left: 12,
                                    right: 5,
                                    top: 4,
                                    bottom: 4,
                                  ),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(
                                          color: Colors.white, width: 1.5)),
                                  child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Text(
                                          'がぞうついか',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(left: 5),
                                          child: Icon(
                                            Icons.add,
                                            color: Colors.white,
                                            size: 15,
                                          ),
                                        ),
                                      ]),
                                ),
                              ),
                            ),
                          AnimatedOnTapButton(
                            onTap: () async => _onTapDone(false),
                            child: widget.onDoneButtonStyle ??
                                Container(
                                  padding: const EdgeInsets.only(
                                      left: 12, right: 5, top: 4, bottom: 4),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(
                                          color: Colors.white, width: 1.5)),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        widget.onDoneButtonTitle ?? 'とうこうする',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.only(left: 5),
                                        child: Icon(
                                          Icons.arrow_forward_ios,
                                          color: Colors.white,
                                          size: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                          ),
                        ],
                      ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _preViewContainer({child}) {
    return Container(
      height: 45,
      width: 45,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(width: 1.4, color: Colors.white)),
      child: child,
    );
  }

  Future<void> _onTapDone(bool nextEdit) async {
    setState(() {
      isLoading = true;
    });

    String pngUri;
    await takePicture(
            contentKey: widget.contentKey,
            context: context,
            saveToGallery: false)
        .then((bytes) {
      if (bytes != null) {
        pngUri = bytes;
        widget.onDone(pngUri, nextEdit);
        setState(() {
          isLoading = false;
        });
      } else {}
    });
  }
}

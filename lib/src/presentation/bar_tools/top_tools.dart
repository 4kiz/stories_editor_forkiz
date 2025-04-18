import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:stories_editor/src/domain/providers/notifiers/control_provider.dart';
import 'package:stories_editor/src/domain/providers/notifiers/draggable_widget_notifier.dart';
import 'package:stories_editor/src/domain/providers/notifiers/language_provider.dart';
import 'package:stories_editor/src/domain/providers/notifiers/painting_notifier.dart';
import 'package:stories_editor/src/domain/sevices/save_as_image.dart';
import 'package:stories_editor/src/presentation/utils/modal_sheets.dart';
import 'package:stories_editor/src/presentation/widgets/animated_onTap_button.dart';
import 'package:stories_editor/src/presentation/widgets/tool_button.dart';

class TopTools extends StatefulWidget {
  final GlobalKey contentKey;
  final BuildContext context;
  const TopTools({super.key, required this.contentKey, required this.context});

  @override
  TopToolsState createState() => TopToolsState();
}

class TopToolsState extends State<TopTools> {
  @override
  Widget build(BuildContext context) {
    return Consumer4<ControlNotifier, PaintingNotifier, DraggableWidgetNotifier,
        LanguageProvider>(
      builder:
          (_, controlNotifier, paintingNotifier, itemNotifier, language, __) {
        return SafeArea(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 20.w),
            decoration: const BoxDecoration(color: Colors.transparent),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                /// close button
                ToolButton(
                  backGroundColor: Colors.black12,
                  onTap: () async {
                    var res = await exitDialog(
                      context: widget.context,
                      contentKey: widget.contentKey,
                      languageProvider: language,
                    );
                    if (context.mounted && res) {
                      Navigator.pop(context, true);
                    }
                  },
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                ),
                if (controlNotifier.mediaPath.isEmpty)
                  _selectColor(
                      controlProvider: controlNotifier,
                      onTap: () {
                        if (controlNotifier.gradientIndex >=
                            controlNotifier.gradientColors!.length - 1) {
                          setState(() {
                            controlNotifier.gradientIndex = 0;
                          });
                        } else {
                          setState(() {
                            controlNotifier.gradientIndex += 1;
                          });
                        }
                      }),
                ToolButton(
                  backGroundColor: Colors.black12,
                  onTap: () async {
                    if (paintingNotifier.lines.isNotEmpty ||
                        itemNotifier.draggableWidget.isNotEmpty) {
                      var response = await takePicture(
                          contentKey: widget.contentKey,
                          context: context,
                          saveToGallery: true);
                      if (response) {
                        Fluttertoast.showToast(msg: 'Successfully saved');
                      } else {
                        Fluttertoast.showToast(msg: 'Error');
                      }
                    }
                  },
                  child: const ImageIcon(
                    AssetImage('assets/icons/download.png',
                        package: 'stories_editor'),
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                // ToolButton(
                //   child: const ImageIcon(
                //     AssetImage('assets/icons/stickers.png',
                //         package: 'stories_editor'),
                //     color: Colors.white,
                //     size: 20,
                //   ),
                //   backGroundColor: Colors.black12,
                //   onTap: () => createGiphyItem(
                //       context: context, giphyKey: controlNotifier.giphyKey),
                // ),
                ToolButton(
                  backGroundColor: Colors.black12,
                  onTap: () {
                    controlNotifier.isPainting = true;
                    //createLinePainting(context: context);
                  },
                  child: const ImageIcon(
                    AssetImage('assets/icons/draw.png',
                        package: 'stories_editor'),
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                // ToolButton(
                //   child: ImageIcon(
                //     const AssetImage('assets/icons/photo_filter.png',
                //         package: 'stories_editor'),
                //     color: controlNotifier.isPhotoFilter ? Colors.black : Colors.white,
                //     size: 20,
                //   ),
                //   backGroundColor:  controlNotifier.isPhotoFilter ? Colors.white70 : Colors.black12,
                //   onTap: () => controlNotifier.isPhotoFilter =
                //   !controlNotifier.isPhotoFilter,
                // ),
                ToolButton(
                  backGroundColor: Colors.black12,
                  onTap: () => controlNotifier.isTextEditing =
                      !controlNotifier.isTextEditing,
                  child: const ImageIcon(
                    AssetImage('assets/icons/text.png',
                        package: 'stories_editor'),
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// gradient color selector
  Widget _selectColor({onTap, controlProvider}) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, right: 5, top: 8),
      child: AnimatedOnTapButton(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(2),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: controlProvider
                      .gradientColors![controlProvider.gradientIndex]),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

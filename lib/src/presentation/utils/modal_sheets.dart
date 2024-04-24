import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:stories_editor/src/domain/providers/notifiers/control_provider.dart';
import 'package:stories_editor/src/domain/providers/notifiers/draggable_widget_notifier.dart';
import 'package:stories_editor/src/domain/providers/notifiers/language_provider.dart';
import 'package:stories_editor/src/domain/providers/notifiers/painting_notifier.dart';
import 'package:stories_editor/src/domain/providers/notifiers/text_editing_notifier.dart';
import 'package:stories_editor/src/domain/sevices/save_as_image.dart';
import 'package:stories_editor/src/presentation/utils/Extensions/hexColor.dart';
import 'package:stories_editor/src/presentation/widgets/animated_onTap_button.dart';

/// custom exit dialog
Future<bool> exitDialog({
  required context,
  required contentKey,
  required LanguageProvider languageProvider,
}) async {
  return (await showDialog(
        context: context,
        barrierColor: Colors.black38,
        barrierDismissible: true,
        builder: (c) => Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetAnimationDuration: const Duration(milliseconds: 300),
          insetAnimationCurve: Curves.ease,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Container(
                padding: const EdgeInsets.only(
                    top: 25, bottom: 5, right: 20, left: 20),
                decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    color: HexColor.fromHex('#262626'),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.white10,
                          offset: Offset(0, 1),
                          blurRadius: 4),
                    ]),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    FittedBox(
                      child: Text(
                        languageProvider.strings.stopEditing(),
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      languageProvider.strings.editingErased(),
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: Colors.white54,
                          letterSpacing: 0.1),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(
                      height: 20,
                    ),

                    /// discard
                    AnimatedOnTapButton(
                      onTap: () async {
                        _resetDefaults(context: context);
                        Navigator.of(context).pop(true);
                      },
                      child: Text(
                        languageProvider.strings.yes(),
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.redAccent.shade200,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.1),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(
                      height: 22,
                      child: Divider(
                        color: Colors.white10,
                      ),
                    ),

                    /// save and exit
                    AnimatedOnTapButton(
                      onTap: () async {
                        final paintingProvider = Provider.of<PaintingNotifier>(
                            context,
                            listen: false);
                        final widgetProvider =
                            Provider.of<DraggableWidgetNotifier>(context,
                                listen: false);
                        if (paintingProvider.lines.isNotEmpty ||
                            widgetProvider.draggableWidget.isNotEmpty) {
                          /// save image
                          var response = await takePicture(
                              contentKey: contentKey,
                              context: context,
                              saveToGallery: true);
                          if (response) {
                            _dispose(
                                context: context,
                                message: 'Successfully saved');
                          } else {
                            _dispose(context: context, message: 'Error');
                          }
                        } else {
                          _dispose(context: context, message: 'Draft Empty');
                        }
                      },
                      child: Text(
                        languageProvider.strings.save(),
                        style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(
                      height: 22,
                      child: Divider(
                        color: Colors.white10,
                      ),
                    ),

                    ///cancel
                    AnimatedOnTapButton(
                      onTap: () {
                        Navigator.of(context).pop(false);
                      },
                      child: Text(
                        languageProvider.strings.cancel(),
                        style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                )),
          ),
        ),
      )) ??
      false;
}

_resetDefaults({required BuildContext context}) {
  final paintingProvider =
      Provider.of<PaintingNotifier>(context, listen: false);
  final widgetProvider =
      Provider.of<DraggableWidgetNotifier>(context, listen: false);
  final controlProvider = Provider.of<ControlNotifier>(context, listen: false);
  final editingProvider =
      Provider.of<TextEditingNotifier>(context, listen: false);
  paintingProvider.lines.clear();
  widgetProvider.draggableWidget.clear();
  widgetProvider.setDefaults();
  paintingProvider.resetDefaults();
  editingProvider.setDefaults();
  controlProvider.mediaPath = '';
}

_dispose({required context, required message}) {
  _resetDefaults(context: context);
  Fluttertoast.showToast(msg: message);
  Navigator.of(context).pop(true);
}

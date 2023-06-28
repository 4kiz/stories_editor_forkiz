import 'package:flutter/material.dart';
import 'package:stories_editor/src/l18n/strings.dart';
import 'package:stories_editor/src/l18n/strings_en.dart';

class LanguageProvider extends ChangeNotifier {
  Strings _strings = StringsEn();
  Strings get strings => _strings;
  set strings(Strings strings) {
    _strings = strings;
    notifyListeners();
  }
}

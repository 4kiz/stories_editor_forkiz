import 'package:stories_editor/src/l18n/strings_en.dart';
import 'package:stories_editor/src/l18n/strings_ja.dart';
import 'package:stories_editor/src/l18n/strings_ko.dart';

abstract class Strings {
  String tapAndInput();
  String post();
  String done();
  String stopEditing();
  String editingErased();
  String yes();
  String save();
  String cancel();
}

Strings from(String lang) {
  if (lang == 'ja') {
    return StringsJa();
  } else if (lang == 'en') {
    return StringsEn();
  } else if (lang == 'ko') {
    return StringsKo();
  } else {
    return StringsEn();
  }
}

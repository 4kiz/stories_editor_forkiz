import 'package:stories_editor/src/l18n/strings_en.dart';
import 'package:stories_editor/src/l18n/strings_id.dart';
import 'package:stories_editor/src/l18n/strings_ja.dart';
import 'package:stories_editor/src/l18n/strings_ko.dart';
import 'package:stories_editor/src/l18n/strings_th.dart';
import 'package:stories_editor/src/l18n/strings_vi.dart';

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
  } else if (lang == 'ko') {
    return StringsKo();
  } else if (lang == 'th') {
    return StringsTh();
  } else if (lang == 'vi') {
    return StringsVi();
  } else if (lang == 'id') {
    return StringsId();
  } else {
    return StringsEn();
  }
}

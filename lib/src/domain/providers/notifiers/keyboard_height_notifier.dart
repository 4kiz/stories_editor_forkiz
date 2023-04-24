import 'package:flutter/material.dart';

class KeyboardHeightNotifier extends ChangeNotifier {
  double _keyboardHeight = 0.0;
  double get keyboardHeight => _keyboardHeight;
  set keyboardHeight(double height) {
    if (_keyboardHeight == height) {
      return;
    }
    _keyboardHeight = height;
    notifyListeners();
  }
}

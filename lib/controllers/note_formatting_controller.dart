import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class NoteFormattingController extends ChangeNotifier {
  bool isBold = false;
  bool isItalic = false;
  bool isUnderline = false;
  bool isH1 = false;
  bool isH2 = false;
  bool isBulletedList = false;
  bool isNumberedList = false;
  bool isCheckbox = false;

  void toggleBold() {
    isBold = !isBold;
    debugPrint('Action: Toggled Bold -> $isBold');
    notifyListeners();
  }

  void toggleItalic() {
    isItalic = !isItalic;
    debugPrint('Action: Toggled Italic -> $isItalic');
    notifyListeners();
  }

  void toggleUnderline() {
    isUnderline = !isUnderline;
    debugPrint('Action: Toggled Underline -> $isUnderline');
    notifyListeners();
  }

  void toggleH1() {
    isH1 = !isH1;
    if (isH1) isH2 = false;
    debugPrint('Action: Toggled H1 -> $isH1');
    notifyListeners();
  }

  void toggleH2() {
    isH2 = !isH2;
    if (isH2) isH1 = false;
    debugPrint('Action: Toggled H2 -> $isH2');
    notifyListeners();
  }

  void toggleBulletedList() {
    isBulletedList = !isBulletedList;
    if (isBulletedList) {
      isNumberedList = false;
      isCheckbox = false;
    }
    debugPrint('Action: Toggled Bulleted List -> $isBulletedList');
    notifyListeners();
  }

  void toggleNumberedList() {
    isNumberedList = !isNumberedList;
    if (isNumberedList) {
      isBulletedList = false;
      isCheckbox = false;
    }
    debugPrint('Action: Toggled Numbered List -> $isNumberedList');
    notifyListeners();
  }

  void toggleCheckbox() {
    isCheckbox = !isCheckbox;
    if (isCheckbox) {
      isBulletedList = false;
      isNumberedList = false;
    }
    debugPrint('Action: Toggled Checkbox -> $isCheckbox');
    notifyListeners();
  }

  void handleImageAction() {
    debugPrint('Action: Pressed Image');
  }

  void handleLinkAction() {
    debugPrint('Action: Pressed Link');
  }
}

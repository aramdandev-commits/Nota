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

  // دالة سحرية لتحديث حالة الأزرار تلقائياً بناءً على مكان المؤشر في النص (للـ Web والـ Native)
  void updateFormats(Map<String, dynamic> activeFormats) {
    isBold = activeFormats['bold'] == true;
    isItalic = activeFormats['italic'] == true;
    isUnderline = activeFormats['underline'] == true;

    // التعامل مع العناوين
    isH1 = activeFormats['header'] == 1;
    isH2 = activeFormats['header'] == 2;

    // التعامل مع القوائم والـ Checkbox
    final listFormat = activeFormats['list'];
    isBulletedList = listFormat == 'bullet';
    isNumberedList = listFormat == 'ordered';
    isCheckbox = listFormat == 'unchecked' ||
        listFormat == 'checked'; // Quill بيخزن الـ Checkbox كـ list من النوع ده

    notifyListeners();
  }

  // التبديل اليدوي عند الضغط (تأكيد الحصريات)
  void toggleBold() {
    isBold = !isBold;
    notifyListeners();
  }

  void toggleItalic() {
    isItalic = !isItalic;
    notifyListeners();
  }

  void toggleUnderline() {
    isUnderline = !isUnderline;
    notifyListeners();
  }

  void toggleH1() {
    isH1 = !isH1;
    if (isH1) isH2 = false;
    notifyListeners();
  }

  void toggleH2() {
    isH2 = !isH2;
    if (isH2) isH1 = false;
    notifyListeners();
  }

  void toggleBulletedList() {
    isBulletedList = !isBulletedList;
    if (isBulletedList) {
      isNumberedList = false;
      isCheckbox = false;
    }
    notifyListeners();
  }

  void toggleNumberedList() {
    isNumberedList = !isNumberedList;
    if (isNumberedList) {
      isBulletedList = false;
      isCheckbox = false;
    }
    notifyListeners();
  }

  void toggleCheckbox() {
    isCheckbox = !isCheckbox;
    if (isCheckbox) {
      isBulletedList = false;
      isNumberedList = false;
    }
    notifyListeners();
  }
}

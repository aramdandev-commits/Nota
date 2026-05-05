import 'package:nota/model/settings_model.dart';

class SettingsController {
  SettingsModel settings = SettingsModel();

  Future<void> fetchSettings() async {
    await Future.delayed(const Duration(milliseconds: 500));
    // هنا API بعدين
  }

  Future<void> updateSettings(SettingsModel newSettings) async {
    settings = newSettings;
    // هنا API بعدين
  }
}

class SettingsModel {
  bool emailNotifications;
  bool pushNotifications;
  bool is2FAEnabled;
  String language;
  String appearance;

  SettingsModel({
    this.emailNotifications = true,
    this.pushNotifications = true,
    this.is2FAEnabled = false,
    this.language = 'English',
    this.appearance = 'Dark',
  });
}

class SettingItem {
  final String title;
  bool isEnabled; // Mutabile per gestire lo switch

  SettingItem({
    required this.title,
    this.isEnabled = false,
  });
}
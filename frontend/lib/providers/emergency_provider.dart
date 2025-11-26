import 'package:flutter/material.dart';

class EmergencyProvider extends ChangeNotifier {
  bool _isSendingSos = false;

  bool get isSendingSos => _isSendingSos;

  Future<void> sendSos() async {
    _isSendingSos = true;
    notifyListeners();

    // Simulazione chiamata SOS
    await Future.delayed(const Duration(seconds: 3));

    _isSendingSos = false;
    notifyListeners();
  }
}
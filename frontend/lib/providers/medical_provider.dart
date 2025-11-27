import 'package:flutter/material.dart';
import 'package:data_models/medical_item.dart';

class MedicalProvider extends ChangeNotifier {
  // Esempio di stato condiviso
  List<MedicalItem> _allergie = [];

  List<MedicalItem> get allergie => _allergie;

  void addAllergia(MedicalItem item) {
    _allergie.add(item);
    notifyListeners();
  }

  void removeAllergia(int index) {
    _allergie.removeAt(index);
    notifyListeners();
  }

// Aggiungi qui metodi per medicinali, contatti, ecc.
}
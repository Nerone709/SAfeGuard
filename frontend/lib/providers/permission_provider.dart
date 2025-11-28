import 'package:flutter/material.dart';
import 'package:data_models/Permesso.dart';
import '../repositories/profile_repository.dart';

class PermissionProvider extends ChangeNotifier {
  final ProfileRepository _profileRepository = ProfileRepository();

  Permesso _permessi = Permesso(); // Stato iniziale (tutto false)
  bool _isLoading = false;
  String? _errorMessage;

  Permesso get permessi => _permessi;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Carica i permessi all'avvio
  Future<void> loadPermessi() async {
    _isLoading = true;
    notifyListeners();
    try {
      _permessi = await _profileRepository.fetchPermessi();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Aggiorna i permessi (chiamato dagli switch)
  Future<void> updatePermessi(Permesso nuoviPermessi) async {
    // Aggiornamento ottimistico UI
    _permessi = nuoviPermessi;
    notifyListeners();

    try {
      await _profileRepository.updatePermessi(nuoviPermessi);
    } catch (e) {
      _errorMessage = "Errore salvataggio: $e";
      // Rollback in caso di errore
      await loadPermessi();
    }
  }
}
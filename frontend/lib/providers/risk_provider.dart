import 'package:flutter/material.dart';
import 'package:data_models/risk_hotspot.dart';
import '../repositories/risk_repository.dart';

class RiskProvider extends ChangeNotifier {
  final RiskRepository _riskRepository = RiskRepository();

  List<RiskHotspot> _hotspots = [];
  bool _isLoading = false;

  List<RiskHotspot> get hotspots => _hotspots;
  bool get isLoading => _isLoading;

  // Carica i dati all'avvio o su richiesta
  Future<void> loadHotspots() async {
    _isLoading = true;
    notifyListeners();

    try {
      _hotspots = await _riskRepository.getRiskHotspots();
    } catch (e) {
      print("Errore provider risk: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
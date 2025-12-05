import 'package:flutter/material.dart';
import '../repositories/report_repository.dart';

class ReportProvider extends ChangeNotifier {
  final ReportRepository _repository = ReportRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;
//Lista locale delle emergenze
  List<dynamic> _emergencies = [];
  List<dynamic> get emergencies => _emergencies;

  // Invia la segnalazione e gestisce lo stato di caricamento
  Future<bool> sendReport(String type, String description, double? lat, double? lng) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.createReport(type, description, lat, lng);
      _isLoading = false;
      notifyListeners();
      return true; // Successo
    } catch (e) {
      print("Errore invio report: $e");
      _isLoading = false;
      notifyListeners();
      return false; // Errore
    }
  }
  //Carica le emergenze
  Future<void> loadReports() async {
    _isLoading = true;
    notifyListeners();

    try {
      _emergencies = await _repository.getReports();
    } catch (e) {
      print("Errore fetch report: $e");
      _emergencies = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  //Risolvi emergenza
  Future<bool> resolveReport(String id) async {
    try {
      await _repository.closeReport(id);
      // Rimuovi localmente per aggiornare la UI istantaneamente
      _emergencies.removeWhere((item) => item['id'] == id);
      notifyListeners();
      return true;
    } catch (e) {
      print("Errore chiusura report: $e");
      return false;
    }
  }
}
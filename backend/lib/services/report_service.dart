import '../repositories/report_repository.dart';
import '../repositories/user_repository.dart';
import 'notification_service.dart';

class ReportService {
  final ReportRepository _repository = ReportRepository();
  final NotificationService _notificationService = NotificationService();
  final UserRepository _userRepo = UserRepository();

  Future<void> createReport({
    required int senderId,
    required bool isSenderRescuer, // Parametro che decide la direzione
    required String type,
    String? description,
    double? lat,
    double? lng,
  }) async {

    final reportData = {
      'rescuer_id': senderId,
      'type': type,
      'description': description ?? '',
      'status': 'active',
      'lat': lat,
      'lng': lng,
      'is_rescuer_report': isSenderRescuer, // Flag utile per il frontend
      'timestamp': DateTime.now().toIso8601String(),
    };

    // 1. Salva su DB
    await _repository.createReport(reportData);

    // 2. LOGICA DI NOTIFICA INVERSA
    if (isSenderRescuer) {
      // CASO A: Mittente = Soccorritore --> Destinatari = Cittadini
      print("📢 Logica: Invio notifica a TUTTI I CITTADINI...");
      await _notifyCitizens(type, description);
    } else {
      // CASO B: Mittente = Cittadino --> Destinatari = Soccorritori
      print("📢 Logica: Invio notifica ai SOCCORRITORI...");
      await _notifyRescuers(type, description);
    }
  }

  Future<List<Map<String, dynamic>>> getReports() async {
    return await _repository.getAllReports();
  }

  Future<void> closeReport(String id) async {
    await _repository.deleteReport(id);
  }

  // --- Metodo A: Notifica ai Soccorritori ---
  Future<void> _notifyRescuers(String type, String? description) async {
    try {
      // Recupera token con isSoccorritore: true
      List<String> tokens = await _userRepo.getRescuerTokens();

      if (tokens.isNotEmpty) {
        await _notificationService.sendBroadcastNotification(
            "ALLERTA CITTADINO: $type",
            description ?? "Richiesta di intervento inviata da un cittadino.",
            tokens
        );
      }
    } catch (e) {
      print("Errore notifica soccorritori: $e");
    }
  }

  // --- Metodo B: Notifica ai Cittadini ---
  Future<void> _notifyCitizens(String type, String? description) async {
    try {
      // Recupera token con isSoccorritore: false
      List<String> tokens = await _userRepo.getCitizenTokens();

      print("Trovati ${tokens.length} cittadini da allertare.");

      if (tokens.isNotEmpty) {
        await _notificationService.sendBroadcastNotification(
            "⚠️ AVVISO PROTEZIONE CIVILE: $type", // Titolo diverso per impatto
            description ?? "Comunicazione ufficiale di emergenza.",
            tokens
        );
      }
    } catch (e) {
      print("Errore notifica cittadini: $e");
    }
  }
}
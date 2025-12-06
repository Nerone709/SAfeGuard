import '../repositories/report_repository.dart';
import '../repositories/user_repository.dart';
import 'notification_service.dart';

class ReportService {
  final ReportRepository _repository = ReportRepository();
  final NotificationService _notificationService = NotificationService();
  // 2. Repository per gestire gli utenti (recupero token) -> CORREGGE L'ERRORE
  final UserRepository _userRepo = UserRepository();
  Future<void> createReport({
    required int rescuerId,
    required String type,
    String? description,
    double? lat,
    double? lng,
  }) async {
    // Qui prepariamo l'oggetto finale da salvare
    final reportData = {
      'rescuer_id': rescuerId,
      'type': type,
      'description': description ?? '',
      'status': 'active',
      'lat': lat,
      'lng': lng,
      'timestamp': DateTime.now().toIso8601String(),
    };

    await _repository.createReport(reportData);

    await _notifyCitizens(type, description);
  }

  Future<List<Map<String, dynamic>>> getReports() async {
    return await _repository.getAllReports();
  }

  Future<void> closeReport(String id) async {
    await _repository.deleteReport(id);
  }

  Future<void> _notifyCitizens(String type, String? description) async {
    try {
      print("Inizio recupero token destinatari...");

      // 1. Recupera i token REALI dal database tramite Repository
      List<String> tokens = await _userRepo.getCitizenTokens();

      print("Trovati ${tokens.length} utenti da notificare.");

      // 2. Invia solo se ci sono destinatari
      if (tokens.isNotEmpty) {
        await _notificationService.sendBroadcastNotification(
            "ALLERTA: $type", // Titolo
            description ?? "Nuova segnalazione di emergenza. Controlla l'app.", // Body
            tokens // Lista destinatari
        );
      }
    } catch (e) {
      print("Errore critico durante la notifica ai cittadini: $e");
    }
  }
}
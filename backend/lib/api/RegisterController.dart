import 'dart:convert';
import 'package:backend/services/VerificationService.dart';

import '../services/RegisterService.dart';
import '../repositories/UserRepository.dart';
import 'package:data_models/Utente.dart';
import 'package:data_models/Soccorritore.dart';
import '../services/VerificationService.dart';
import '../services/VerificationService.dart';
import '../services/SmsService.dart';

class RegisterController {
  // 1. Inizializzazione delle classi base (Repository e SmsService)
  final UserRepository _userRepository = UserRepository();
  final SmsService _smsService = SmsService();

  // 2. Inizializzazione del VerificationService (richiede Repository e SmsService)
  late final VerificationService _verificationService =
  VerificationService(_userRepository, _smsService);

  final RegisterService _registerService =
  RegisterService(
      UserRepository(), // Inietta UserRepository
      VerificationService(
          UserRepository(), // Inietta UserRepository (di nuovo)
          SmsService()      // Inietta SmsService
      ) // Inietta VerificationService
  );

  // Simula la gestione di una richiesta HTTP POST /api/register
  Future<String> handleRegisterRequest(String requestBodyJson) async {
    try {
      final Map<String, dynamic> requestData = jsonDecode(requestBodyJson);

      // La password è necessaria
      final password = requestData.remove('password') as String;

      // Il resto dei dati (inclusi email e telefono opzionali) va al service
      final user = await _registerService.register(requestData, password);

      // Controllo del tipo come prima (per la risposta)
      String tipoUtente;
      int assegnatoId;

      if (user is Soccorritore) {
        tipoUtente = 'Soccorritore';
        assegnatoId = user.id;
      } else if (user is Utente) {
        tipoUtente = 'Utente Standard';
        assegnatoId = user.id;
      } else {
        tipoUtente = 'Generico';
        assegnatoId = 0;
      }

      final responseBody = {
        'success': true,
        'message':
            'Registrazione avvenuta con successo. Tipo: $tipoUtente, ID assegnato: $assegnatoId',
        'user': user.toJson()..remove('passwordHash'),
      };
      return jsonEncode(responseBody);
    } on Exception catch (e) {
      final responseBody = {
        'success': false,
        'message': e.toString().replaceFirst('Exception: ', ''),
      };
      return jsonEncode(responseBody);
    } catch (e) {
      final responseBody = {
        'success': false,
        'message': 'Errore interno del server durante la registrazione.',
      };
      return jsonEncode(responseBody);
    }
  }
}

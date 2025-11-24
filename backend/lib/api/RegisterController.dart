import 'dart:convert';
import '../services/RegisterService.dart';
import '../services/VerificationService.dart';
import '../services/SmsService.dart';
import '../repositories/UserRepository.dart';

import 'package:data_models/Utente.dart';
import 'package:data_models/Soccorritore.dart';

class RegisterController {
  final RegisterService _registerService = RegisterService(
    UserRepository(),
    VerificationService(UserRepository(), SmsService()),
  );

  // Simula la gestione di una richiesta HTTP POST /api/register
  Future<String> handleRegisterRequest(String requestBodyJson) async {
    try {
      final Map<String, dynamic> requestData = jsonDecode(requestBodyJson);

      // 1. Recupero la password
      final password = requestData.remove('password') as String;

      // 2. RECUPERO E CONTROLLO LA CONFERMA PASSWORD (NUOVO CODICE)
      // Uso .remove così pulisco i dati prima di inviarli al service
      final confermaPassword = requestData.remove('confermaPassword');

      if (confermaPassword == null) {
        throw Exception('Il campo confermaPassword è obbligatorio');
      }

      if (password != confermaPassword) {
        throw Exception('Le password non coincidono');
      }

      // Il resto dei dati (inclusi email e telefono opzionali) va al service
      final user = await _registerService.register(requestData, password);

      // Controllo del tipo e recupero ID
      String tipoUtente;
      final int assegnatoId = user.id!;

      if (user is Soccorritore) {
        tipoUtente = 'Soccorritore';
      } else if (user is Utente) {
        tipoUtente = 'Utente Standard';
      } else {
        tipoUtente = 'Generico';
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

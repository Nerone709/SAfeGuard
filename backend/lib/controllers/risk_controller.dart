import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:http/http.dart' as http;

// Funzione helper per stampare stringhe lunghe nel terminale
void printLongString(String text) {
  final pattern = RegExp('.{1,800}'); // Spezza ogni 800 caratteri
  pattern.allMatches(text).forEach((match) => print(match.group(0)));
}

class RiskController {
  // L'URL del server Python che esegue l'analisi AI
  final String _aiServiceUrl = 'http://127.0.0.1:8000/api/v1/analyze';

  /* Il corpo della richiesta HTTP POST inviata dal frontend mobile
  DEVE rispettare il seguente schema.

  Esempio JSON atteso dal server AI:

  {
      "reports": [
          {
              "lat": 40.75899247,  // Latitudine del report (float)
              "lon": 14.65552131,  // Longitudine del report (float)
              "event_type": "Fire", // Tipo di evento (stringa)
              "severity": 5         // Gravità da 1 (bassa) a 5 (alta)
          },
          // Possono esserci più report in un'unica richiesta
          {
              "lat": 40.760000,
              "lon": 14.650000,
              "event_type": "Theft",
              "severity": 3
          }
      ]
  }*/

  Future<Response> handleRiskAnalysis(Request request) async {
    try {
      // 1. Legge il JSON inviato dall frontend mobile e lo decodifica.
      final String content = await request.readAsString();
      final Map<String, dynamic> payload = jsonDecode(content);

      print('📤 Dart invia dati al server AI...');

      // 2. Invia la richiesta POST al server Python.
      // Inoltra il 'payload' ricevuto direttamente, assicurando che sia ben formato.
      final aiResponse = await http.post(
        Uri.parse(_aiServiceUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      print('Risposta ricevuta da Python: ${aiResponse.statusCode}');

      if (aiResponse.statusCode == 200) {
        final data = jsonDecode(aiResponse.body);

        final jsonString = jsonEncode(data);

        print('----------------------------------------------------');
        print('Dati ricevuti dal Modulo AI Inizio');

        // Stampa i dati decodificati per il debug nel terminale Dart
        printLongString(jsonString);

        print('Dati ricevuti dal Modulo AI Fine');
        print('----------------------------------------------------');

        // 3. Restituisce il risultato dell'AI (incluso risk_score e hotspot_match) all frontend mobile
        return Response.ok(
          jsonEncode(data),
          headers: {'content-type': 'application/json'},
        );
      } else {
        // Gestione degli errori HTTP non-200 dal Microservizio AI
        print(
          'Errore dal servizio AI (${aiResponse.statusCode}): ${aiResponse.body}',
        );
        return Response.internalServerError(
          body: 'Errore dal servizio AI: ${aiResponse.body}',
        );
      }
    } catch (e) {
      // Gestione di errori di I/O, decodifica JSON o altri errori interni a Dart
      print('Errore nel RiskController: $e');
      return Response.internalServerError(
        body: 'Errore interno nel backend Dart: $e',
      );
    }
  }
}

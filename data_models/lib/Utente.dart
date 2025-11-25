// ** File: lib/data_models/Utente.dart **

import 'UtenteGenerico.dart';
import 'Permesso.dart';
import 'Condizione.dart';
import 'Notifica.dart';
import 'ContattoEmergenza.dart';

// MODIFICA ARCHITETTURALE:
// Utente ora estende UtenteGenerico. Questo ci permette di ereditare i campi base
// (ID, email, password, anagrafica) gestiti dal nuovo backend, aggiungendo però
// i campi complessi (liste, oggetti) necessari per la logica dell'app client.
class Utente extends UtenteGenerico {

  // --- CAMPI SPECIFICI (Dal vecchio progetto) ---
  final Permesso permessi;
  final Condizione condizioni;
  final Notifica notifiche;

  final List<String> allergie;
  final List<String> medicinali;
  final List<ContattoEmergenza> contattiEmergenza;

  // --- COSTRUTTORE UNIFICATO ---
  Utente({
    // Campi ereditati da UtenteGenerico (required ID, etc.)
    required int id,
    String? passwordHash,
    String? email,
    String? telefono,
    String? nome,
    String? cognome,
    DateTime? dataDiNascita,
    String? cittaDiNascita,
    String? iconaProfilo,

    // Campi specifici (Opzionali con Default)
    Permesso? permessi,
    Condizione? condizioni,
    Notifica? notifiche,
    List<String>? allergie,
    List<String>? medicinali,
    List<ContattoEmergenza>? contattiEmergenza,
  })  :
  // INIZIALIZZAZIONE SICURA:
  // Se questi oggetti arrivano null (es. DB parziale o nuovo utente),
  // li inizializziamo vuoti per evitare crash nell'interfaccia.
        this.permessi = permessi ?? Permesso(),
        this.condizioni = condizioni ?? Condizione(),
        this.notifiche = notifiche ?? Notifica(),
        this.allergie = allergie ?? const [],
        this.medicinali = medicinali ?? const [],
        this.contattiEmergenza = contattiEmergenza ?? const [],
  // Passiamo i dati base al costruttore del padre (UtenteGenerico)
        super(
        id: id,
        passwordHash: passwordHash,
        email: email,
        telefono: telefono,
        nome: nome,
        cognome: cognome,
        dataDiNascita: dataDiNascita,
        cittaDiNascita: cittaDiNascita,
        iconaProfilo: iconaProfilo,
      );

  // --- COPYWITH AVANZATO ---
  // Ho dovuto riscrivere il copyWith per gestire un mix di campi:
  // sia quelli locali (liste, permessi) sia quelli ereditati (nome, cognome).
  // Restituisce sempre un 'Utente' completo.
  Utente copyWith({
    int? id,
    String? email,
    String? telefono,
    String? passwordHash,
    String? nome,
    String? cognome,
    DateTime? dataDiNascita,
    String? cittaDiNascita,
    String? iconaProfilo,
    Permesso? permessi,
    Condizione? condizioni,
    Notifica? notifiche,
    List<String>? allergie,
    List<String>? medicinali,
    List<ContattoEmergenza>? contattiEmergenza,
  }) {
    return Utente(
      id: id ?? this.id!, // ID è obbligatorio
      email: email ?? this.email,
      telefono: telefono ?? this.telefono,
      passwordHash: passwordHash ?? this.passwordHash,
      nome: nome ?? this.nome,
      cognome: cognome ?? this.cognome,
      dataDiNascita: dataDiNascita ?? this.dataDiNascita,
      cittaDiNascita: cittaDiNascita ?? this.cittaDiNascita,
      iconaProfilo: iconaProfilo ?? this.iconaProfilo,
      permessi: permessi ?? this.permessi,
      condizioni: condizioni ?? this.condizioni,
      notifiche: notifiche ?? this.notifiche,
      allergie: allergie ?? this.allergie,
      medicinali: medicinali ?? this.medicinali,
      contattiEmergenza: contattiEmergenza ?? this.contattiEmergenza,
    );
  }

  // --- DESERIALIZZAZIONE IBRIDA (JSON -> Utente) ---
  factory Utente.fromJson(Map<String, dynamic> json) {
    // 1. Deleghiamo al padre il parsing dei campi comuni
    final utenteGenerico = UtenteGenerico.fromJson(json);

    // 2. Costruiamo l'Utente finale aggiungendo i pezzi mancanti
    return Utente(
      id: utenteGenerico.id!,
      passwordHash: utenteGenerico.passwordHash,
      email: utenteGenerico.email,
      telefono: utenteGenerico.telefono,
      nome: utenteGenerico.nome,
      cognome: utenteGenerico.cognome,
      dataDiNascita: utenteGenerico.dataDiNascita,
      cittaDiNascita: utenteGenerico.cittaDiNascita,
      iconaProfilo: utenteGenerico.iconaProfilo,

      // Parsing oggetti nidificati (con check null)
      permessi: json['permessi'] != null
          ? Permesso.fromJson(json['permessi'])
          : Permesso(),
      condizioni: json['condizioni'] != null
          ? Condizione.fromJson(json['condizioni'])
          : Condizione(),
      notifiche: json['notifiche'] != null
          ? Notifica.fromJson(json['notifiche'])
          : Notifica(),

      // Parsing Liste (Gestione null, casting stringhe e oggetti complessi)
      allergie: (json['allergie'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
      medicinali: (json['medicinali'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
      contattiEmergenza: (json['contattiEmergenza'] as List<dynamic>?)
          ?.map((e) => ContattoEmergenza.fromJson(e))
          .toList() ?? [],
    );
  }

  // --- SERIALIZZAZIONE COMPLETA (Utente -> JSON) ---
  @override
  Map<String, dynamic> toJson() {
    // 1. Ottieni la mappa base dal padre
    final Map<String, dynamic> data = super.toJson();

    // 2. Aggiungi i dati specifici di Utente
    data.addAll({
      'id': id,
      'permessi': permessi.toJson(),
      'condizioni': condizioni.toJson(),
      'notifiche': notifiche.toJson(),
      'allergie': allergie,
      'medicinali': medicinali,
      'contattiEmergenza': contattiEmergenza.map((c) => c.toJson()).toList(),
    });

    return data;
  }
}
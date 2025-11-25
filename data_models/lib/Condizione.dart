// ** Model: Condizione **
// Gestisce lo stato delle disabilità nel profilo utente.
// Usato principalmente nella schermata "Condizioni Fisiche".

class Condizione {
  final bool disabilitaMotorie;
  final bool disabilitaVisive;
  final bool disabilitaUditive;
  final bool disabilitaIntellettive;
  final bool disabilitaPsichiche;

  // Costruttore con valori di default a 'false'.
  // Questo previene errori null pointer se l'utente è appena stato creato e non ha ancora compilato il profilo.
  Condizione({
    this.disabilitaMotorie = false,
    this.disabilitaVisive = false,
    this.disabilitaUditive = false,
    this.disabilitaIntellettive = false,
    this.disabilitaPsichiche = false,
  });

  // Metodo copyWith: Fondamentale per la UI Flutter (Switch/Checkbox).
  // Dato che la classe è 'final' (immutabile), quando l'utente cambia una switch,
  // non modifichiamo l'oggetto corrente ma ne creiamo una copia identica con solo quel campo aggiornato.
  Condizione copyWith({
    bool? disabilitaMotorie,
    bool? disabilitaVisive,
    bool? disabilitaUditive,
    bool? disabilitaIntellettive,
    bool? disabilitaPsichiche,
  }) {
    return Condizione(
      disabilitaMotorie: disabilitaMotorie ?? this.disabilitaMotorie,
      disabilitaVisive: disabilitaVisive ?? this.disabilitaVisive,
      disabilitaUditive: disabilitaUditive ?? this.disabilitaUditive,
      disabilitaIntellettive: disabilitaIntellettive ?? this.disabilitaIntellettive,
      disabilitaPsichiche: disabilitaPsichiche ?? this.disabilitaPsichiche,
    );
  }

  // Serializzazione: Converte l'oggetto in Mappa per il salvataggio nel DB (tramite UserRepository).
  Map<String, dynamic> toJson() => {
    'disabilitaMotorie': disabilitaMotorie,
    'disabilitaVisive': disabilitaVisive,
    'disabilitaUditive': disabilitaUditive,
    'disabilitaIntellettive': disabilitaIntellettive,
    'disabilitaPsichiche': disabilitaPsichiche,
  };

  // Deserializzazione: Ricostruisce l'oggetto dal DB.
  // Nota: usiamo '?? false' per garantire robustezza anche se il campo manca nel JSON.
  factory Condizione.fromJson(Map<String, dynamic> json) {
    return Condizione(
      disabilitaMotorie: json['disabilitaMotorie'] ?? false,
      disabilitaVisive: json['disabilitaVisive'] ?? false,
      disabilitaUditive: json['disabilitaUditive'] ?? false,
      disabilitaIntellettive: json['disabilitaIntellettive'] ?? false,
      disabilitaPsichiche: json['disabilitaPsichiche'] ?? false,
    );
  }
}
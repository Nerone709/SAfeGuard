// ** Model: ContattoEmergenza **
// Oggetto semplice per gestire gli elementi della lista "Contatti SOS".
// Non contiene logica complessa, serve solo a strutturare nome e numero di telefono.

class ContattoEmergenza {
  final String nome;
  final String numero;

  ContattoEmergenza({required this.nome, required this.numero});

  // copyWith: Utile in futuro se implementeremo la modifica di un contatto esistente
  // invece di doverlo cancellare e ricreare.
  ContattoEmergenza copyWith({
    String? nome,
    String? numero,
  }) {
    return ContattoEmergenza(
      nome: nome ?? this.nome,
      numero: numero ?? this.numero,
    );
  }

  Map<String, dynamic> toJson() => {
    'nome': nome,
    'numero': numero,
  };

  factory ContattoEmergenza.fromJson(Map<String, dynamic> json) {
    return ContattoEmergenza(
      nome: json['nome'] ?? '',
      numero: json['numero'] ?? '',
    );
  }
}
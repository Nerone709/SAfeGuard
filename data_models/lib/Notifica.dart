// ** Model: Notifica **
// Gestisce le preferenze di notifica dell'utente.

class Notifica {
  final bool push;
  final bool sms;
  final bool silenzia; // Se true, l'app non deve emettere suoni
  final bool mail;
  final bool aggiornamenti;

  Notifica({
    // IMPORTANTE: I default per Push e SMS sono impostati a TRUE.
    // Trattandosi di un'app per la sicurezza/emergenza, è meglio essere "invadenti"
    // piuttosto che rischiare che l'utente perda un avviso critico.
    this.push = true,
    this.sms = true,
    this.silenzia = false,
    this.mail = true,
    this.aggiornamenti = true,
  });

  // Pattern standard copyWith per gestire gli switch nelle impostazioni
  Notifica copyWith({
    bool? push,
    bool? sms,
    bool? silenzia,
    bool? mail,
    bool? aggiornamenti,
  }) {
    return Notifica(
      push: push ?? this.push,
      sms: sms ?? this.sms,
      silenzia: silenzia ?? this.silenzia,
      mail: mail ?? this.mail,
      aggiornamenti: aggiornamenti ?? this.aggiornamenti,
    );
  }

  Map<String, dynamic> toJson() => {
    'push': push,
    'sms': sms,
    'silenzia': silenzia,
    'mail': mail,
    'aggiornamenti': aggiornamenti,
  };

  factory Notifica.fromJson(Map<String, dynamic> json) {
    return Notifica(
      push: json['push'] ?? true,
      sms: json['sms'] ?? true,
      silenzia: json['silenzia'] ?? false,
      mail: json['mail'] ?? true,
      aggiornamenti: json['aggiornamenti'] ?? true,
    );
  }
}
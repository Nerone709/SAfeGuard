// ** Model: Permesso **
// Questo model fa da ponte tra i permessi del Sistema Operativo (Android/iOS)
// e il nostro Database. Viene popolato dal Frontend tramite OsPermissionService.

class Permesso {
  final bool posizione;
  final bool contatti;
  final bool notificheSistema;
  final bool bluetooth;

  Permesso({
    this.posizione = false,
    this.contatti = false,
    this.notificheSistema = false,
    this.bluetooth = false,
  });

  // Permette di aggiornare un singolo stato (es. l'utente nega il GPS)
  // mantenendo gli altri inalterati.
  Permesso copyWith({
    bool? posizione,
    bool? contatti,
    bool? notificheSistema,
    bool? bluetooth,
  }) {
    return Permesso(
      posizione: posizione ?? this.posizione,
      contatti: contatti ?? this.contatti,
      notificheSistema: notificheSistema ?? this.notificheSistema,
      bluetooth: bluetooth ?? this.bluetooth,
    );
  }

  // Questo oggetto JSON verrà salvato nel campo 'permessi' dell'utente nel DB
  Map<String, dynamic> toJson() => {
    'posizione': posizione,
    'contatti': contatti,
    'notificheSistema': notificheSistema,
    'bluetooth': bluetooth,
  };

  factory Permesso.fromJson(Map<String, dynamic> json) {
    return Permesso(
      posizione: json['posizione'] ?? false,
      contatti: json['contatti'] ?? false,
      notificheSistema: json['notificheSistema'] ?? false,
      bluetooth: json['bluetooth'] ?? false,
    );
  }
}
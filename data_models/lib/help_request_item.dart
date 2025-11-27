class HelpRequestItem {
  final String title;
  final String time;
  final String status;
  final bool isComplete;
  // Nota: In un'app reale l'icona e il colore verrebbero dedotti dal "tipo" di richiesta.
  // Per ora li teniamo qui per semplicità di UI, o li mappiamo nella vista.
  final String type; // es. "ambulance", "earthquake", "fire"

  HelpRequestItem({
    required this.title,
    required this.time,
    required this.status,
    required this.isComplete,
    required this.type,
  });
}
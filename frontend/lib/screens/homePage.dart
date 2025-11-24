import 'package:flutter/material.dart';
import 'package:prova2/screens/confirmEmergencyScreen.dart';
import 'dart:math';

// Definiamo una HomePage (Stateless, visto che è una schermata statica)
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // Definizione dei colori usati nell'app per mantenere la coerenza
  static const Color darkBlue = Color(0xFF12345A);
  static const Color primaryRed = Color(0xFFE53935);
  static const Color amberOrange = Color(0xFFFF9800);

  @override
  Widget build(BuildContext context) {
    // Il Container principale avvolge tutto il corpo per impostare il colore di sfondo
    return Container(
      color: darkBlue,
      child: Scaffold(
        backgroundColor: Colors.transparent, // Rende trasparente lo Scaffold per mostrare il Container scuro

        // --- BODY: Il contenuto centrale della pagina ---
        body: SafeArea(
          child: SingleChildScrollView( // Permette lo scroll se lo schermo è piccolo
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  //Separatore
                  const SizedBox(height: 20),
                  // 1. NOTIFICA DI EMERGENZA (IN ALTO)
                  _buildEmergencyNotification(),
                  //Separatore
                  const SizedBox(height: 25),
                  // 2. MAPPA
                  _buildMapContainer(),
                  //Altro separatore
                  const SizedBox(height: 25),

                  // 3. BOTTONE "CONTATTI DI EMERGENZA"
                  _buildEmergencyContactsButton(),

                  const SizedBox(height: 10),

                  // 4. BOTTONE SOS GRANDE
                  _buildSosButton(context),

                  const SizedBox(height: 30), // Spazio extra prima della Bottom Nav Bar
                ],
              ),
            ),
          ),
        ),

        // --- BOTTOM NAVIGATION BAR ---
        bottomNavigationBar: _buildBottomNavBar(context),
      ),
    );
  }

  // --- WIDGET PER LA NOTIFICA DI EMERGENZA (ROSSE) ---
  Widget _buildEmergencyNotification() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      decoration: BoxDecoration(
        color: primaryRed, // Rosso
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Icona dell'Incendio
          Icon(Icons.house_siding_rounded, color: Colors.white, size: 28),
          SizedBox(width: 15),
          // Testo
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Incendio",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                "Incendio in Via Roma, 14",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- WIDGET PER IL CONTAINER DELLA MAPPA (SIMULAZIONE) ---
  Widget _buildMapContainer() {
    // Ho usato un Container decorato con un gradiente e un'immagine placeholder
    // per simulare l'aspetto della mappa centrata su Salerno.
    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 5),
          ),
        ],
        // Simulo un'immagine di sfondo per la mappa
        image: const DecorationImage(
          image: AssetImage('assets/salerno_map_placeholder.png'),
          fit: BoxFit.cover,
        ),
        // Se non hai l'immagine, puoi usare questo per un blocco grigio:
        // color: Colors.grey.shade300,
      ),
      // Puoi aggiungere un widget `ClipRRect` e `Image.asset` se vuoi
      // inserire l'immagine mostrata nel tuo screenshot in modo più preciso.
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        // Ho commentato l'Image.asset per non creare un errore
        // se l'utente non ha l'asset: 'assets/salerno_map.png'
        /* child: Image.asset(
          'assets/salerno_map.png',
          fit: BoxFit.cover,
          errorBuilder: (c, e, s) => const Center(child: Text("Mappa Placeholder", style: TextStyle(color: Colors.black))),
        ),
        */
      ),
    );
  }

  // --- WIDGET PER IL BOTTONE "CONTATTI DI EMERGENZA" (ARANCIONE) ---
  Widget _buildEmergencyContactsButton() {
    return ElevatedButton(
      onPressed: () {
        // Logica per aprire i contatti di emergenza
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: amberOrange, // Arancione
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        elevation: 5,
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min, // Occupa solo lo spazio necessario
        children: [
          Icon(Icons.person_pin_circle, color: darkBlue, size: 28),
          SizedBox(width: 10),
          Text(
            "Contatti di Emergenza",
            style: TextStyle(
              color: darkBlue,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }


  // --- WIDGET PER IL BOTTONE SOS GRANDE ---
  SosButton _buildSosButton(context) {
    final double buttonSize = MediaQuery.of(context).size.width * 0.60;
    return SosButton(size: buttonSize);
  }


  // --- WIDGET PER LA NAV BAR INFERIORE ---
  Widget _buildBottomNavBar(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: darkBlue,
      type: BottomNavigationBarType.fixed, // Per avere un background fisso
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white.withOpacity(0.6),
      currentIndex: 0, // Impostiamo la Home come selezionata
      showSelectedLabels: false,
      showUnselectedLabels: false,
      elevation: 0, // Rimuove l'ombra della barra
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_filled, size: 28),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.analytics_outlined, size: 28),
          label: 'Analytics',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.map_outlined, size: 28),
          label: 'Mappa',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications_none, size: 28),
          label: 'Notifiche',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_outlined, size: 28),
          label: 'Impostazioni',
        ),
      ],
      onTap: (index) {
        // Implementa la logica di navigazione qui
        // Esempio: print("Toccata icona: $index");
      },
    );
  }
}

// --- CLASSE MAIN PER TESTARE (OPZIONALE) ---
/*
void main() {
  // Aggiungi questo in un file separato (o usa il tuo file main.dart)
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafeGuard App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}
*/

class SosButton extends StatefulWidget {
  final double size;

  const SosButton({super.key, required this.size});

  @override
  State<SosButton> createState() => _SosButtonState();
}


//Questa classe è per costruire il bottone di SOS come oggetto stateful, così da
//lasciare la home stateless e creare l'effetto di caricamento
class _SosButtonState extends State<SosButton>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // tempo necessario per SOS
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onLongPressStart: (_) {
          _controller.forward(from: 0); // Avvia animazione
        },
        onLongPressEnd: (_) {
          if (_controller.value == 1.0) {
            //Qui andrà il ridirezionamento alla schermata di sos effettiva
            //Il push() sovrappone una pagina allo stack navigazionale, nella
            //prossima schermata, il pop() lo farà tornare a questa
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const ConfirmEmergencyScreen(),
              ),
            );
          }
          else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Tieni premuto più a lungo per attivare l'SOS!"),
                duration: Duration(seconds: 1),
              ),
            );
          }
          _controller.reset();
        },
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Tieni premuto per attivare l'SOS!"),
              duration: Duration(seconds: 1),
            ),
          );
        },
        child: Stack(
            alignment: Alignment.center,
            children: [
              // --- ANELLO ANIMATO ---
              AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  return CustomPaint(
                    size: Size(widget.size + 10, widget.size + 10),
                    painter: RingPainter(progress: _controller.value),
                  );
                },
              ),
              Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: const DecorationImage(
                    image: AssetImage('assets/sosbutton.png'),
                    fit: BoxFit.cover,
                  ),
                  border: Border.all(color: Colors.white, width: 1),
                ),
              )
            ]
        )
    );
  }
}


//Questa è la classe per il caricamento dell'SOS
//import 'dart:math'; fa funzionare questa classe (definizione di pi)
class RingPainter extends CustomPainter {
  final double progress;

  RingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 12.0;

    final rect = Offset.zero & size;
    final startAngle = -pi / 2;
    final sweepAngle = 2 * pi * progress;

    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      rect.deflate(strokeWidth),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant RingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

import 'package:flutter/material.dart';
import 'package:frontend/navigationBarSoccorritore.dart';

// Funzione per convertire la stringa Hex (senza alpha) in un oggetto Color.
Color hexToColor(String code) {
  String hexCode = code.toUpperCase().replaceAll("#", "");
  if (hexCode.length == 6) {
    hexCode = "FF$hexCode"; // Aggiunge Alpha 255 (opacità massima)
  }
  return Color(int.parse(hexCode, radix: 16));
}

// --- WIDGET PRINCIPALI (MyApp e MyHomePage) ---

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // colore di sfondo
    final Color mainBackgroundColor = hexToColor("ef923d");

    return MaterialApp(
      title: 'Gestione Permessi',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        fontFamily: 'Rubik',

        colorScheme: ColorScheme.fromSeed(seedColor: mainBackgroundColor),

        // tema dei testi
        textTheme: const TextTheme(
          // tema del titolo
          titleLarge: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.w900,
          ),
          // tema testi "normali"
          titleMedium: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      // Passiamo il colore dello sfondo principale alla Home Page
      home: MyHomePage(
        title: 'Gestione\nPermessi',
        backgroundColor: mainBackgroundColor,
      ),
    );
  }
}

// --- CLASSE DELLA PAGINA PRINCIPALE ---

class MyHomePage extends StatelessWidget {
  final String title;
  final Color backgroundColor;

  const MyHomePage({
    super.key,
    required this.title,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    // Colore del blocco centrale
    final Color cardColor = hexToColor("D65D01");

    return Scaffold(
      // Colore di sfondo preso da MyApp
      backgroundColor: backgroundColor,

      // La BottomNavigationBar e la parte superiore
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. HEADER (Freccia Indietro + Titolo)
              Padding(
                padding: const EdgeInsets.only(
                  top: 20.0,
                  left: 16.0,
                  bottom: 20.0,
                ),
                child: Row(
                  children: [
                    //const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 30),
                    // implementazione del pulsante indietro
                    InkWell(
                      onTap: () {
                        Navigator.pop(
                          context,
                        ); // tolgo questa pagina dallo stack di navigazione
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),

                    const SizedBox(width: 40),

                    // Icona e Titolo
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // Mettere icona che era nei mockup
                            const Icon(
                              Icons.verified_user,
                              color: Colors.blueAccent,
                              size: 40,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              // metto il titolo e gli assegno lo stile
                              title,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 2. SEZIONE PERMESSI (La "Card" Arancione Scuro)
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: cardColor, // Colore del blocco
                    borderRadius: BorderRadius.circular(
                      25.0,
                    ), // Bordo arrotondato
                  ),

                  child: const Column(
                    children: [
                      PermissionRow(
                        title: 'Accesso alla posizione',
                        initialValue: false,
                      ), // Funzione che ritorna nome e switch del permesso

                      PermissionRow(
                        title: 'Accesso ai contatti',
                        initialValue: false,
                      ),

                      PermissionRow(
                        title: 'Accesso alle notifiche di sistema',
                        initialValue: false,
                      ),

                      PermissionRow(
                        title: 'Accesso alla memoria',
                        initialValue: false,
                      ),

                      PermissionRow(
                        title: 'Accesso al Bluetooth',
                        initialValue: false,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: CustomBottomNavBar(),
    );
  }
}

// --- INIZIO RIGHE DI PERMESSO (QUESTA PARTE DI CODIDE E' RIUTILIZZABILE) ---

class PermissionRow extends StatefulWidget {
  final String title;
  final bool initialValue;

  const PermissionRow({
    super.key,
    required this.title,
    required this.initialValue,
  });

  @override
  State<PermissionRow> createState() => _PermissionRowState();
}

class _PermissionRowState extends State<PermissionRow> {
  late bool _isEnabled;

  @override
  void initState() {
    super.initState();
    _isEnabled = widget.initialValue;
  }

  // creo gli switch
  @override
  Widget build(BuildContext context) {
    // metto il padding tra di loro
    return Padding(
      // setto il padding tra di loro
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
      // creo una riga
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Testo del permesso
          Flexible(
            child: Text(
              widget
                  .title, // gli assegno il titolo, che è stato passato alla funzione e quindi ogni switch avrà il suo titolo
              style: Theme.of(
                context,
              ).textTheme.titleMedium, // assegno il tema del testo "normale"
              softWrap: true, // per mandare a capo se non c'è spazio
            ),
          ),

          // Interruttore (Switch)
          Transform.scale(
            // per ridurre le dimensioni dello switch
            scale: 0.9,

            child: Switch(
              value: _isEnabled,

              onChanged: (bool newValue) {
                // cambio dello stato
                setState(() {
                  _isEnabled = newValue;
                });

                // ci salviamo lo stato
                final String statusText = newValue ? 'attivato' : 'disattivato';

                // creo uno snackBar (widget della notifica)
                final snackBar = SnackBar(
                  // dò il titolo del permesso e il suo stato
                  content: Text('"${widget.title}" $statusText.'),
                  // durata dell'animazione
                  duration: Duration(milliseconds: 750),
                  //action: SnackBarAction(label: 'Chiudi', onPressed: () {ScaffoldMessenger.of(context).hideCurrentSnackBar();}),
                );

                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              },

              // Colori dello switch
              activeTrackColor: hexToColor(
                "12345a",
              ), // Blu per la traccia attiva
              inactiveThumbColor: Colors.white, // colore del pallino
              inactiveTrackColor:
                  Colors.grey.shade400, // Grigio chiaro per la traccia inattiva
            ),
          ),
        ],
      ),
    );
  }
}

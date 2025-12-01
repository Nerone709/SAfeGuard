import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // <--- LIBRERIA NUOVA

// Widget che visualizza una mappa OpenStreetMap interattiva.
class RealtimeMap extends StatefulWidget {
  const RealtimeMap({super.key});

  @override
  State<RealtimeMap> createState() => _RealtimeMapState();
}

class _RealtimeMapState extends State<RealtimeMap> {
  // Controller per muovere la mappa programmaticamente
  final MapController _mapController = MapController();

  // Riferimento alla collezione del database
  final CollectionReference _firestore = FirebaseFirestore.instance.collection('active_emergencies');

  // Coordinate di default (Roma) usate finché il GPS non risponde
  LatLng _center = const LatLng(41.9028, 12.4964);

  // Flag per sapere se abbiamo i permessi e il GPS attivo
  bool _isLocationServiceEnabled = false;

  // Limiti di zoom per evitare che l'utente vada troppo lontano o troppo vicino
  final double _minZoom = 5.0;
  final double _maxZoom = 18.0;

  // All'avvio, controlla i permessi GPS e inizializziamo la posizione
  @override
  void initState() {
    super.initState();
    _initLocationService();
  }

  // Pulisce il controller quando il widget viene distrutto
  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  // Verifica che il GPS sia acceso e che l'app abbia i permessi
  // Se tutto è ok, abilita la mappa e sposta la visuale sull'utente
  Future<void> _initLocationService() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    setState(() {
      _isLocationServiceEnabled = true;
    });
    // Sposta subito la camera sulla posizione reale
    _goToUserLocation();
  }

  // Ottiene la posizione corrente precisa e centra la mappa
  Future<void> _goToUserLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      final newCenter = LatLng(position.latitude, position.longitude);
      setState(() => _center = newCenter);
      _mapController.move(newCenter, 15.0);
    } catch (e) {
      debugPrint("Errore posizione: $e");
    }
  }

  // Funzione helper per gestire lo zoom dai pulsanti +/-
  void _animatedMapMove(double destZoom) {
    final center = _mapController.camera.center;
    _mapController.move(center, destZoom);
  }

  // Se non ha ancora il GPS, mostra un caricamento
  @override
  Widget build(BuildContext context) {
    if (!_isLocationServiceEnabled) {
      return Container(
        color: Colors.grey[900],
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    // Stack permette di sovrapporre i pulsanti alla mappa
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _center,
            initialZoom: 13.0,
            minZoom: _minZoom,
            maxZoom: _maxZoom,
            // Blocca la rotazione per evitare confusione
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),
          ),
          children: [
            // 1. TileLayer: Scarica e mostra le immagini della mappa (OpenStreetMap)
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.safeguard.frontend',
            ),

            // 2. StreamBuilder: Ascolta il database in tempo reale
            StreamBuilder<QuerySnapshot>(
              stream: _firestore.snapshots(),
              builder: (context, snapshot) {
                // Se non ci sono dati o sta caricando, mostra layer vuoto
                if (!snapshot.hasData) return const MarkerLayer(markers: []);

                // Mappa ogni documento del database con un Marker rosso sulla mappa
                final List<Marker> markers = snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final double lat = data['lat'] ?? 0.0;
                  final double lng = data['lng'] ?? 0.0;
                  final String type = data['type'] ?? 'Emergenza';

                  return Marker(
                    point: LatLng(lat, lng),
                    width: 50,
                    height: 50,
                    child: GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Emergenza: $type")),
                        );
                      },
                      child: const Icon(
                        Icons.location_on,
                        size: 50,
                        color: Colors.red,
                        shadows: [Shadow(blurRadius: 10, color: Colors.black)],
                      ),
                    ),
                  );
                }).toList();

                return MarkerLayer(markers: markers);
              },
            ),

            // 3. Marker Posizione Utente (Pallino Blu)
            MarkerLayer(
              markers: [
                Marker(
                  point: _center,
                  width: 20,
                  height: 20,
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: const [BoxShadow(blurRadius: 10, color: Colors.black26)]
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),

        // Pulsanti
        Positioned(
          bottom: 20,
          right: 20,
          child: Column(
            children: [
              FloatingActionButton(
                heroTag: null,
                onPressed: _goToUserLocation,
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                child: const Icon(Icons.my_location),
              ),
              const SizedBox(height: 20),

              // Pulsante Zoom In (+)
              FloatingActionButton.small(
                heroTag: null,
                onPressed: () {
                  if (_mapController.camera.zoom < _maxZoom) {
                    _animatedMapMove(_mapController.camera.zoom + 1);
                  }
                },
                backgroundColor: Colors.white,
                child: const Icon(Icons.add, color: Colors.black87),
              ),
              const SizedBox(height: 10),

              // Pulsante Zoom Out (-)
              FloatingActionButton.small(
                heroTag: null,
                onPressed: () {
                  if (_mapController.camera.zoom > _minZoom) {
                    _animatedMapMove(_mapController.camera.zoom - 1);
                  }
                },
                backgroundColor: Colors.white,
                child: const Icon(Icons.remove, color: Colors.black87),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';

class MapScreen extends StatefulWidget{
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  Widget build(BuildContext context)
    {
      return _buildMapPlaceholder();
    }

  Widget _buildMapPlaceholder() {
    return Container(
      height: 300,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(
          0xFF0E2A48, // Un blu leggermente più chiaro dello sfondo
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white54, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.map_outlined, color: Colors.white70, size: 60),
          SizedBox(height: 10),
          Text(
            "Mappa",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "(Implementazione futura)",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
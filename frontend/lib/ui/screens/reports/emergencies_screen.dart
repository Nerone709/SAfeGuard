import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/providers/report_provider.dart';
import 'package:frontend/ui/style/color_palette.dart';
import 'package:frontend/ui/widgets/emergency_card.dart';

class EmergencyGridPage extends StatefulWidget {
  const EmergencyGridPage({super.key});

  @override
  State<EmergencyGridPage> createState() => _EmergencyGridPageState();
}

class _EmergencyGridPageState extends State<EmergencyGridPage> {

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   Provider.of<ReportProvider>(context, listen: false).loadReports();
    // });
  }

  @override
  Widget build(BuildContext context) {
    final isRescuer = context.watch<AuthProvider>().isRescuer;
    final reportProvider = context.watch<ReportProvider>();

    return Scaffold(
      backgroundColor: !isRescuer ? ColorPalette.backgroundDarkBlue : ColorPalette.cardDarkOrange,

      appBar: AppBar(
        title: const Text("Emergenze Attive", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),

      body: Builder(
        builder: (context) {
          // 1. Loading
          if (reportProvider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }

          // 2. Lista vuota
          // CORREZIONE QUI SOTTO:
          if (true){//reportProvider.emergencies.isEmpty) { // controllo se ci sono o non ci sono le emergenze
            return const Center(
              child: Text(
                "Nessuna segnalazione presente",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            );
          }

          // 3. Griglia Dati Veri
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              // itemCount: reportProvider.emergencies.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
              itemBuilder: (context, index) {
                // final item = reportProvider.emergencies[index];


                return EmergencyCard(

                  title: "text" //(item is Map) ? item['type'] : item.type
                );
              },
            ),
          );
        },
      ),
    );
  }
}
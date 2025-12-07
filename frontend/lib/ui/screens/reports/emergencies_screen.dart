import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/providers/report_provider.dart';
import 'package:frontend/ui/style/color_palette.dart';
import 'package:frontend/ui/widgets/emergency_card.dart';
import '../../widgets/emergency_detail_dialog.dart';

class EmergencyGridPage extends StatefulWidget {
  const EmergencyGridPage({super.key});

  @override
  State<EmergencyGridPage> createState() => _EmergencyGridPageState();
}

class _EmergencyGridPageState extends State<EmergencyGridPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ReportProvider>(context, listen: false).loadReports();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isRescuer = context.watch<AuthProvider>().isRescuer;
    final reportProvider = context.watch<ReportProvider>();

    return Scaffold(
      backgroundColor: !isRescuer
          ? ColorPalette.backgroundDarkBlue
          : ColorPalette.primaryOrange,
      appBar: AppBar(
        title: const Text(
          "Emergenze Attive",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => reportProvider.loadReports(),
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (reportProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          if (reportProvider.emergencies.isEmpty) {
            return const Center(
              child: Text(
                "Nessuna segnalazione presente",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            );
          }

          // 1. Costruzione della griglia delle emergenze
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              itemCount: reportProvider.emergencies.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
              itemBuilder: (context, index) {
                final item = reportProvider.emergencies[index];

                return EmergencyCard(
                  data: item,
                  // Gestione chiusura emergenza
                  onClose: () async {
                    bool confirm =
                        await showDialog(
                          context: context,
                          builder: (c) => AlertDialog(
                            title: const Text("Conferma"),
                            content: const Text(
                              "Vuoi chiudere questa segnalazione?",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(c, false),
                                child: const Text("No"),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(c, true),
                                child: const Text("Si"),
                              ),
                            ],
                          ),
                        ) ??
                        false;

                    if (confirm) {
                      await reportProvider.resolveReport(item['id']);
                    }
                  },
                  // Apertura dettagli (Solo per soccorritori)
                  onTap: () {
                    if (isRescuer) {
                      showDialog(
                        context: context,
                        builder: (ctx) => EmergencyDetailDialog(item: item),
                      );
                    }
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}


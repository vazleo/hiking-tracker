import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hiking_tracker/models/hike_model.dart';
import 'package:hiking_tracker/screens/hike_detail_screen.dart';
import 'package:hiking_tracker/screens/new_hike_screen.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  // Função para formatar a duração de segundos para HH:mm:ss
  String _formatDuration(int totalSeconds) {
    final duration = Duration(seconds: totalSeconds);
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  // Função para formatar a distância de metros para km
  String _formatDistance(double distanceInMeters) {
    return '${(distanceInMeters / 1000).toStringAsFixed(2)} km';
  }

  @override
  Widget build(BuildContext context) {
    final hikeBox = Hive.box<Hike>('hikes');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Caminhadas'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: ValueListenableBuilder(
        // O ValueListenableBuilder escuta por mudanças na caixa do Hive
        // e reconstrói a UI automaticamente quando dados são adicionados/removidos.
        valueListenable: hikeBox.listenable(),
        builder: (context, Box<Hike> box, _) {
          final hikes = box.values.toList().cast<Hike>();

          if (hikes.isEmpty) {
            return const Center(
              child: Text(
                'Nenhuma caminhada registrada ainda.\nClique no botão + para começar!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          // Ordena as caminhadas da mais recente para a mais antiga
          hikes.sort((a, b) => b.startTime.compareTo(a.startTime));

          return ListView.builder(
            itemCount: hikes.length,
            itemBuilder: (context, index) {
              final hike = hikes[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: const Icon(Icons.directions_walk, color: Colors.teal),
                  title: Text(
                    // Formata a data para um formato legível
                    DateFormat('dd/MM/yyyy \'às\' HH:mm').format(hike.startTime),
                  ),
                  subtitle: Text(
                    'Duração: ${_formatDuration(hike.durationInSeconds)} | Distância: ${_formatDistance(hike.distanceInMeters)}',
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HikeDetailScreen(hike: hike),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NewHikeScreen()),
          );
        },
        label: const Text('Nova Caminhada'),
        icon: const Icon(Icons.add),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
    );
  }
}

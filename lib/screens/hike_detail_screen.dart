import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:hiking_tracker/models/hike_model.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

class HikeDetailScreen extends StatelessWidget {
  final Hike hike;

  const HikeDetailScreen({super.key, required this.hike});

  String _formatDuration(int totalSeconds) {
    final duration = Duration(seconds: totalSeconds);
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final points = hike.latLngPoints;
    
    // Calcula os limites do mapa para centralizar e dar zoom na rota
    final bounds = LatLngBounds.fromPoints(points);

    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes de ${DateFormat('dd/MM/yy').format(hike.startTime)}'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat('Distância', '${(hike.distanceInMeters / 1000).toStringAsFixed(2)} km'),
                _buildStat('Duração', _formatDuration(hike.durationInSeconds)),
              ],
            ),
          ),
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCameraFit: CameraFit.bounds(
                  bounds: bounds,
                  padding: const EdgeInsets.all(50.0), // Adiciona um respiro nas bordas
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.hiking_tracker',
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: points,
                      strokeWidth: 5.0,
                      color: Colors.blue,
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    // Marcador de início
                    Marker(
                      width: 80.0,
                      height: 80.0,
                      point: points.first,
                      child: const Icon(Icons.location_on, color: Colors.green, size: 40),
                    ),
                    // Marcador de fim
                    Marker(
                      width: 80.0,
                      height: 80.0,
                      point: points.last,
                      child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 16, color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

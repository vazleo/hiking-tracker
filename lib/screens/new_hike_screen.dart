import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import 'package:hiking_tracker/models/hike_model.dart';
import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';

class NewHikeScreen extends StatefulWidget {
  const NewHikeScreen({super.key});

  @override
  State<NewHikeScreen> createState() => _NewHikeScreenState();
}

class _NewHikeScreenState extends State<NewHikeScreen> {
  final MapController _mapController = MapController();
  
  // Temporizadores para controlar a lógica
  Timer? _durationTimer; // Para o cronômetro de duração
  Timer? _trackingTimer; // Para buscar a localização periodicamente

  // Estado da UI
  bool _isTracking = false;
  double _samplingInterval = 10.0; // Intervalo inicial em segundos
  
  // Dados da caminhada
  final List<LatLng> _points = [];
  double _totalDistance = 0.0;
  int _elapsedSeconds = 0;
  DateTime? _startTime;

  @override
  void dispose() {
    _durationTimer?.cancel();
    _trackingTimer?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Serviços de localização estão desabilitados. Por favor, habilite-os.')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (!mounted) return false;
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('A permissão de localização foi negada.')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('A permissão de localização foi negada permanentemente. Não podemos solicitar permissões.')));
      return false;
    }
    return true;
  }

  void _toggleTracking() {
    if (_isTracking) {
      _stopTracking();
    } else {
      _startTracking();
    }
  }

  void _startTracking() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;

    setState(() {
      _isTracking = true;
      _points.clear();
      _totalDistance = 0.0;
      _elapsedSeconds = 0;
      _startTime = DateTime.now();
    });

    // Inicia o cronômetro para a duração total
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
      });
    });

    // Inicia o temporizador para buscar a localização no intervalo do slider
    _trackingTimer = Timer.periodic(Duration(seconds: _samplingInterval.toInt()), (timer) {
      _updateLocation();
    });
    // Pega a primeira localização imediatamente
    _updateLocation();
  }

  Future<void> _updateLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      setState(() {
        final newPoint = LatLng(position.latitude, position.longitude);
        
        // Adiciona o ponto apenas se ele for diferente do anterior (evita pontos duplicados)
        if (_points.isEmpty || _points.last != newPoint) {
            if (_points.isNotEmpty) {
                _totalDistance += Geolocator.distanceBetween(
                    _points.last.latitude,
                    _points.last.longitude,
                    newPoint.latitude,
                    newPoint.longitude,
                );
            }
            _points.add(newPoint);
            _mapController.move(newPoint, 16.0);
        }
      });
    } catch (e) {
      print("Erro ao obter localização: $e");
    }
  }


  void _stopTracking() {
    setState(() {
      _isTracking = false;
    });
    _durationTimer?.cancel();
    _trackingTimer?.cancel();
    _saveHike();
  }

  void _saveHike() async {
    if (_points.length < 2 || _startTime == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Caminhada muito curta para ser salva.')),
      );
      return;
    }

    final hike = Hike(
      id: const Uuid().v4(), // Gera um ID único
      startTime: _startTime!,
      endTime: DateTime.now(),
      durationInSeconds: _elapsedSeconds,
      distanceInMeters: _totalDistance,
      points: _points.map((p) => {'latitude': p.latitude, 'longitude': p.longitude}).toList(),
    );

    final box = Hive.box<Hike>('hikes');
    await box.add(hike);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Caminhada salva com sucesso!')),
    );
    
    Navigator.of(context).pop();
  }

  String _formatDuration(int totalSeconds) {
    final duration = Duration(seconds: totalSeconds);
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Caminhada'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(-22.9068, -43.1729), // Centro do Rio de Janeiro
              initialZoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.hiking_tracker',
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: _points,
                    strokeWidth: 5.0,
                    color: Colors.blue,
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Text('Duração', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(_formatDuration(_elapsedSeconds), style: const TextStyle(fontSize: 18)),
                          ],
                        ),
                        Column(
                          children: [
                            const Text('Distância', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('${(_totalDistance / 1000).toStringAsFixed(2)} km', style: const TextStyle(fontSize: 18)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text('Intervalo de amostragem: ${_samplingInterval.toInt()}s'),
                    Slider(
                      value: _samplingInterval,
                      min: 5,
                      max: 60,
                      divisions: 11, // (60-5)/5 = 11 divisões
                      label: '${_samplingInterval.toInt()}s',
                      // O slider só pode ser ajustado ANTES de iniciar a caminhada
                      onChanged: _isTracking ? null : (value) {
                        setState(() {
                          _samplingInterval = value;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _toggleTracking,
                      icon: Icon(_isTracking ? Icons.stop : Icons.play_arrow),
                      label: Text(_isTracking ? 'PARAR E SALVAR' : 'INICIAR'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isTracking ? Colors.red : Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

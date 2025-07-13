import 'package:hive/hive.dart';
import 'package:latlong2/latlong.dart';

// Este comando deve ser rodado no terminal para gerar o arquivo .g.dart
// flutter packages pub run build_runner build
part 'hike_model.g.dart';

@HiveType(typeId: 0)
class Hike extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime startTime;

  @HiveField(2)
  final DateTime endTime;

  @HiveField(3)
  final int durationInSeconds;

  @HiveField(4)
  final double distanceInMeters;

  // O Hive não armazena LatLng diretamente, então salvamos uma lista de mapas.
  @HiveField(5)
  final List<Map<String, double>> points;

  Hike({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.durationInSeconds,
    required this.distanceInMeters,
    required this.points,
  });

  // Método getter para converter os mapas de volta para uma lista de LatLng para uso no mapa
  List<LatLng> get latLngPoints {
    return points.map((p) => LatLng(p['latitude']!, p['longitude']!)).toList();
  }
}

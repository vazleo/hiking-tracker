import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hiking_tracker/models/hike_model.dart';
import 'package:hiking_tracker/screens/history_screen.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  // Garante que os Widgets do Flutter foram inicializados antes de qualquer outra coisa.
  WidgetsFlutterBinding.ensureInitialized();

  // Obtém o diretório de documentos do aplicativo para armazenar o banco de dados.
  final appDocumentDir = await getApplicationDocumentsDirectory();
  
  // Inicializa o Hive nesse diretório.
  await Hive.initFlutter(appDocumentDir.path);

  // Registra o Adapter que geramos para a classe Hike.
  // Sem isso, o Hive não saberá como ler/escrever objetos Hike.
  Hive.registerAdapter(HikeAdapter());

  // Abre a "caixa" (tabela) onde as caminhadas serão armazenadas.
  await Hive.openBox<Hike>('hikes');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hiking Tracker',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.light,
        ),
      ),
      debugShowCheckedModeBanner: false,
      // A tela inicial será o histórico de caminhadas.
      home: const HistoryScreen(),
    );
  }
}

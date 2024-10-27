import 'package:flutter/material.dart';
import 'cadastro_page.dart';
import 'reconhecimento_page.dart';
import 'settings_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reconhecimento Facial de Alunos',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomePage(),
      routes: {
        '/save': (context) => const CadastroPage(),
        '/recognition': (context) => const ReconhecimentoPage(),
        '/settings': (context) => SettingsPage(),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _fetchPresences(BuildContext context) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? savedIP = prefs.getString('server_ip');

      final ip = savedIP ?? '10.0.2.2';
      final response = await http.get(Uri.parse('http://$ip:5000/api/presences'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _showPresencesDialog(context, data);
      } else {
        _showErrorDialog(context, 'Erro ao carregar presenças: ${response.body}');
      }
    } catch (e) {
      _showErrorDialog(context, 'Erro de conexão: $e');
    }
  }

  void _showPresencesDialog(BuildContext context, List<dynamic> presences) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Lista de Presenças',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: ListView.builder(
              itemCount: presences.length,
              itemBuilder: (context, index) {
                final presence = presences[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  elevation: 5,
                  child: ListTile(
                    leading: const Icon(Icons.check_circle, color: Colors.green),
                    title: Text('Classe: ${presence['class']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      'Data: ${presence['date']}\n'
                          'Presenças: ${presence['presences'].join(', ')}',
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Erro', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reconhecimento Facial'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/save');
              },
              child: const Text('Cadastrar Aluno'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/recognition');
              },
              child: const Text('Reconhecer Aluno'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _fetchPresences(context);
              },
              child: const Text('Listar Presenças'),
            ),
          ],
        ),
      ),
    );
  }
}

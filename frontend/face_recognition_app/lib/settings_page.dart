import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _ipController = TextEditingController();
  String _savedIP = '';

  @override
  void initState() {
    super.initState();
    _loadSavedIP();
  }

  Future<void> _loadSavedIP() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedIP = prefs.getString('server_ip') ?? '';
      _ipController.text = _savedIP;
    });
  }

  Future<void> _saveIP() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('server_ip', _ipController.text);
    setState(() {
      _savedIP = _ipController.text;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('IP do servidor salvo com sucesso!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _ipController,
              decoration: const InputDecoration(
                labelText: 'Endereço IP do Servidor',
                hintText: 'Ex: 192.168.0.1',
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveIP,
              child: Text('Salvar'),
            ),
            const SizedBox(height: 20),
            if (_savedIP.isNotEmpty)
              Text('IP salvo: $_savedIP', style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

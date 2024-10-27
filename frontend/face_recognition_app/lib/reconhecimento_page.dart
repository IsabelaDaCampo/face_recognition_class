import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';

class ReconhecimentoPage extends StatefulWidget {
  const ReconhecimentoPage({super.key});

  @override
  _ReconhecimentoPageState createState() => _ReconhecimentoPageState();
}

class _ReconhecimentoPageState extends State<ReconhecimentoPage> {
  File? _image;
  final picker = ImagePicker();
  bool _isUploading = false;
  String _className = ''; // Variável para armazenar o valor do campo de texto
  String _responseMessage = ''; // Variável para armazenar a resposta do backend

  Future<void> _getImage(ImageSource source) async {
    try {
      final pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
        print('Imagem selecionada com sucesso: ${_image?.path}');
      } else {
        print('Nenhuma imagem selecionada.');
      }
    } catch (e) {
      print('Erro ao selecionar imagem: $e');
    }
  }

  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Câmera'),
                onTap: () {
                  Navigator.of(context).pop();
                  _getImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeria'),
                onTap: () {
                  Navigator.of(context).pop();
                  _getImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _uploadImage(File image) async {
    if (_className.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Atenção!'),
            content: const Text('Por favor, insira o nome da classe.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? savedIP = prefs.getString('server_ip');

      final ip = savedIP ?? '10.0.2.2'; // Ajuste o IP conforme necessário
      final url = Uri.parse('http://$ip:5000/api/recognize');

      final request = http.MultipartRequest('POST', url);
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
      request.fields['class'] = _className; // Adiciona o valor da classe

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();

        final decodedResponse = jsonDecode(responseBody);
        final aluno = decodedResponse['aluno'] ?? 'Desconhecido';
        final confianca = (decodedResponse['confiança'] as double? ?? 0.0) * 100; // Transforma em porcentagem
        final status = decodedResponse['status'] ?? 'Status desconhecido';

        setState(() {
          _responseMessage = 'Aluno: $aluno\n'
              'Confiança: ${confianca.toStringAsFixed(2)}%\n'
              'Status: $status';
        });

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Resultado do Reconhecimento'),
              content: Text(_responseMessage),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        final errorBody = await response.stream.bytesToString();
        setState(() {
          _responseMessage = 'Erro no upload: $errorBody';
        });
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Erro'),
              content: Text('Falha ao enviar a imagem. Código de status: ${response.statusCode}. Detalhes: $_responseMessage'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
        developer.log('Erro (código ${response.statusCode}): $errorBody');
      }
    } catch (error) {
      setState(() {
        _responseMessage = 'Erro ao enviar a imagem: $error';
      });
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Erro'),
            content: Text(_responseMessage),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      developer.log('Erro ao enviar a imagem: $error');
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reconhecimento de Face'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _image == null
                    ? const Text('Nenhuma imagem selecionada.')
                    : Container(
                  constraints: const BoxConstraints(
                    maxHeight: 400, // Limitar a altura da imagem
                  ),
                  child: Image.file(_image!),
                ),
                const SizedBox(height: 20),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Classe (turma)',
                  ),
                  onChanged: (value) {
                    setState(() {
                      _className = value;
                    });
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _showImageSourceActionSheet, // Chama o método para mostrar a escolha
                  child: const Text('Selecionar Imagem'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_image != null) {
                      _uploadImage(_image!);
                    } else {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Atenção!'),
                            content: const Text('Por favor, selecione uma imagem.'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                  child: _isUploading
                      ? const CircularProgressIndicator()
                      : const Text('Enviar presença'),
                ),
                const SizedBox(height: 20),
                Text(_responseMessage),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  _CadastroPageState createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  File? _image;
  final picker = ImagePicker();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _classController = TextEditingController();

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

  Future<void> saveStudent(File image, String name, String classStudent) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? savedIP = prefs.getString('server_ip');

      final ip = savedIP ?? '10.0.2.4';
      final url = Uri.parse('http://$ip:5000/api/save-student');

      final request = http.MultipartRequest('POST', url);
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
      request.fields['name'] = name;
      request.fields['class'] = classStudent;

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Sucesso!'),
              content: const Text('Aluno cadastrado com sucesso.'),
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
        developer.log('Falha ao enviar a imagem. Código de status: ${response.statusCode}');
        final errorBody = await response.stream.bytesToString();
        print('Erro (código ${response.statusCode}): $errorBody');
      }
    } catch (error) {
      developer.log('Erro ao enviar a imagem: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro Aluno'),
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
                    maxHeight: 400,
                  ),
                  child: Image.file(_image!),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome do Aluno',
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _classController,
                  decoration: const InputDecoration(
                    labelText: 'Classe (turma)',
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _showImageSourceActionSheet,
                  child: const Text('Selecionar Imagem'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_image != null && _nameController.text.isNotEmpty && _classController.text.isNotEmpty) {
                      saveStudent(_image!, _nameController.text, _classController.text);
                    } else {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Atenção!'),
                            content: const Text('Por favor, selecione uma imagem e insira o nome.'),
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
                  child: const Text('Salvar Aluno'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

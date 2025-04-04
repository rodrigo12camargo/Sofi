import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Depurador de Código',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _codeController = TextEditingController();
  String _result = '';
  bool _isLoading = false;
  String _selectedLanguage = 'dart';

  Future<void> _debugCode() async {
    if (_codeController.text.isEmpty) {
      setState(() => _result = 'Por favor, ingresa código para depurar');
      return;
    }

    setState(() {
      _isLoading = true;
      _result = '🔍 Analizando código...';
    });

    try {
      final response = await http.post(
        Uri.parse('https://api-inference.huggingface.co/models/codellama/CodeLlama-7b-hf'),
        headers: {
          'Authorization': 'Bearer ${dotenv.env['HF_API_KEY']}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "inputs": """
          [INST] Eres un experto en análisis de código. 
          Analiza el siguiente código en $_selectedLanguage, identifica errores, 
          sugiere mejoras y explica cada problema encontrado.
          
          Proporciona la respuesta en formato Markdown con secciones claras.
          
          Código a analizar:
          ${_codeController.text}
          [/INST]
          """,
          "parameters": {
            "max_new_tokens": 1024,
            "temperature": 0.2,
            "return_full_text": false
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List && data.isNotEmpty && data[0]['generated_text'] != null) {
          setState(() {
            _result = data[0]['generated_text'];
          });
        } else {
          setState(() => _result = 'Error: Formato de respuesta inesperado');
        }
      } else if (response.statusCode == 503) {
        setState(() => _result = 'El modelo está cargando. Intenta nuevamente en 30 segundos.');
      } else {
        setState(() => _result = 'Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      setState(() => _result = 'Error de conexión: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Depurador de Código (CodeLlama)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Acerca de'),
                  content: const Text(
                    'Depurador de código usando CodeLlama de Hugging Face\n\n'
                    'Analiza código en múltiples lenguajes usando IA local.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cerrar'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButton<String>(
              value: _selectedLanguage,
              items: const [
                DropdownMenuItem(value: 'dart', child: Text('Dart')),
                DropdownMenuItem(value: 'python', child: Text('Python')),
                DropdownMenuItem(value: 'javascript', child: Text('JavaScript')),
                DropdownMenuItem(value: 'java', child: Text('Java')),
                DropdownMenuItem(value: 'csharp', child: Text('C#')),
                DropdownMenuItem(value: 'cpp', child: Text('C++')),
                DropdownMenuItem(value: 'go', child: Text('Go')),
                DropdownMenuItem(value: 'ruby', child: Text('Ruby')),
                DropdownMenuItem(value: 'php', child: Text('PHP')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedLanguage = value);
                }
              },
            ),
            const SizedBox(height: 12),
            
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: _codeController,
                  maxLines: null,
                  expands: true,
                  decoration: const InputDecoration(
                    hintText: 'Pega tu código aquí...',
                    contentPadding: EdgeInsets.all(12),
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(
                    fontFamily: 'RobotoMono',
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _debugCode,
                icon: const Icon(Icons.code),
                label: const Text('ANALIZAR CÓDIGO'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: SingleChildScrollView(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Text(
                          _result,
                          style: const TextStyle(
                            fontFamily: 'RobotoMono',
                            fontSize: 14,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
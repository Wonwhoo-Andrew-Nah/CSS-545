import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

String hashData(String data) {
  final bytes = utf8.encode(data); // String to bytes
  final digest = sha256.convert(bytes); // SHA256 hashing
  return digest.toString();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Paw Frame',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Home'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  final TextEditingController _zipController = TextEditingController();
  String? _animalType;
  double _animalAge = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkAndNavigateToListPage();
    _loadPreferences();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _zipController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _savePreferences();
    } else if (state == AppLifecycleState.resumed) {
      _loadPreferences();
    }
  }

  Future<void> _checkAndNavigateToListPage() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('zipCode')) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const AnimalListScreen()));
    }
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _animalType = 'Unknown (hashed)';
      _animalAge = 0.0;
      _zipController.text = 'Unknown (hashed)';
    });

    print('Animal Type Hash: ${prefs.getString('animalType')}');
    print('Animal Age Hash: ${prefs.getString('animalAge')}');
    print('ZIP Code Hash: ${prefs.getString('zipCode')}');
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();

    prefs.setString('animalType', hashData(_animalType!));
    prefs.setString('animalAge', hashData(_animalAge.toString()));
    prefs.setString('zipCode', hashData(_zipController.text));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            DropdownButton<String>(
              value: _animalType,
              items: <String>['Dog', 'Cat', 'Others'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _animalType = newValue;
                });
              },
            ),
            Column(
              children: [
                Text("Animal Age: ${_animalAge.toStringAsFixed(1)} years"),
                Slider(
                  value: _animalAge,
                  min: 0.0,
                  max: 20.0,
                  divisions: 20,
                  label: _animalAge.toStringAsFixed(1),
                  onChanged: (double value) {
                    setState(() {
                      _animalAge = value;
                    });
                  },
                ),
              ],
            ),
            TextField(
              controller: _zipController,
              decoration: const InputDecoration(labelText: "Enter ZIP Code"),
              keyboardType: TextInputType.number,
            ),
            ElevatedButton(
              onPressed: () async {
                await _savePreferences();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const AnimalListScreen(),
                  ),
                );
              },
              child: const Text('Save Preferences'),
            ),
          ],
        ),
      ),
    );
  }
}

class AnimalListScreen extends StatefulWidget {
  const AnimalListScreen({super.key});

  @override
  _AnimalListScreenState createState() => _AnimalListScreenState();
}

class _AnimalListScreenState extends State<AnimalListScreen> {
  List<dynamic> _animals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAnimals();
  }

  Future<void> _fetchAnimals() async {
    const String apiUrl = 'https://data.kingcounty.gov/resource/ytc8-tcih.json';
    const String apiToken = '6yAff0sPYQ6WXsPGlUkV1Gced';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Host': 'data.kingcounty.gov',
          'Accept': 'application/json',
          'X-App-Token': apiToken,
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _animals = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        print('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Available Animals')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _animals.length,
              itemBuilder: (context, index) {
                final animal = _animals[index];
                return _buildAnimalCard(animal);
              },
            ),
    );
  }

  Widget _buildAnimalCard(Map<String, dynamic> animal) {
    return Column(
      children: [
        Expanded(
          child: Image.network(
            animal['image'] ?? '',
            fit: BoxFit.cover,
            width: double.infinity,
            errorBuilder: (context, error, stackTrace) {
              return const Center(child: Text('Image not available'));
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                animal['name'] ?? 'Unknown',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(animal['description'] ?? 'No description available'),
            ],
          ),
        ),
      ],
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

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
      home: const AnimalListScreen(),
    );
  }
}

class PreferencePage extends StatefulWidget {
  const PreferencePage({super.key});

  @override
  State<PreferencePage> createState() => _PreferencePageState();
}

class _PreferencePageState extends State<PreferencePage> with WidgetsBindingObserver {
  final TextEditingController _zipController = TextEditingController();
  String? _animalType;
  double _animalAge = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadPreferences();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _zipController.dispose();
    super.dispose();
  }

  Future<void> _loadPreferences() async {
    String? animalType = await _secureStorage.read(key: 'animalType');
    String? animalAge = await _secureStorage.read(key: 'animalAge');
    String? zipCode = await _secureStorage.read(key: 'zipCode');

    setState(() {
      _animalType = animalType ?? 'Dog';
      _animalAge = double.tryParse(animalAge ?? '0.0') ?? 0.0;
      _zipController.text = zipCode ?? '00000';
    });
  }

  Future<void> _savePreferences() async {
    await _secureStorage.write(key: 'animalType', value: _animalType ?? 'Dog');
    await _secureStorage.write(key: 'animalAge', value: _animalAge.toString());
    await _secureStorage.write(key: 'zipCode', value: _zipController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preferences')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            DropdownButton<String>(
              value: _animalType,
              items: ['Dog', 'Cat', 'Others'].map((String value) {
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
  Set<String> _likedAnimals = {};

  @override
  void initState() {
    super.initState();
    _fetchAnimals();
    _loadLikedAnimals();
  }

  Future<void> _fetchAnimals() async {
    const String apiUrl = 'https://data.kingcounty.gov/resource/ytc8-tcih.json';
    const String apiToken = '6yAff0sPYQ6WXsPGlUkV1Gced';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'X-App-Token': apiToken},
      );

      if (response.statusCode == 200) {
        setState(() {
          _animals = jsonDecode(response.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  Future<void> _loadLikedAnimals() async {
    String? likedData = await _secureStorage.read(key: 'likedAnimals');
    setState(() {
      _likedAnimals = (jsonDecode(likedData ?? '[]') as List).toSet().cast<String>();
    });
  }

  Future<void> _toggleLike(String id) async {
    setState(() {
      if (_likedAnimals.contains(id)) {
        _likedAnimals.remove(id);
      } else {
        _likedAnimals.add(id);
      }
    });
    await _secureStorage.write(key: 'likedAnimals', value: jsonEncode(_likedAnimals.toList()));
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
                final id = animal['id'] ?? index.toString();
                return ListTile(
                  leading: IconButton(
                    icon: Icon(
                      _likedAnimals.contains(id) ? Icons.favorite : Icons.favorite_border,
                      color: _likedAnimals.contains(id) ? Colors.red : null,
                    ),
                    onPressed: () => _toggleLike(id),
                  ),
                  title: Text(animal['animal_name'] ?? 'No Name'),
                );
              },
            ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Preferences'),
          BottomNavigationBarItem(icon: Icon(Icons.pets), label: 'Animals'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorites'),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const PreferencePage()));
          } else if (index == 2) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const FavoritesPage()));
          }
        },
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorite Animals')),
      body: const Center(child: Text('List of liked animals will appear here.')),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      _savePreferences(); // Save preferences on app suspend
    } else if (state == AppLifecycleState.resumed) {
      _loadPreferences(); // Reload preferences on app resume
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
      _animalType = prefs.getString('animalType') ?? 'Dog';
      _animalAge = prefs.getDouble('animalAge') ?? 0;
      _zipController.text = prefs.getString('zipCode') ?? '';
    });
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('animalType', _animalType!);
    prefs.setDouble('animalAge', _animalAge);
    prefs.setString('zipCode', _zipController.text);
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
  final List<Map<String, dynamic>> _animals = [
    {
      'name': 'Buddy',
      'type': 'Dog',
      'age': 3,
      'description': 'Friendly and playful dog looking for a loving home.',
      'imageUrl': 'assets/images/Dog1.png',
      'isAdopted': false,
    },
    {
      'name': 'Mittens',
      'type': 'Cat',
      'age': 2,
      'description': 'Shy but affectionate cat who loves to snuggle.',
      'imageUrl': 'assets/images/Cat1.png',
      'isAdopted': false,
    },
    {
      'name': 'Max',
      'type': 'Dog',
      'age': 4,
      'description': 'Loyal and protective dog, great with families.',
      'imageUrl': 'assets/images/Dog2.png',
      'isAdopted': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadAdoptedStatus();
  }

  Future<void> _loadAdoptedStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      for (var animal in _animals) {
        animal['isAdopted'] = prefs.getBool(animal['name']) ?? false;
      }
    });
  }

  Future<void> _adoptAnimal(String animalName) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(animalName, true);

    setState(() {
      _animals.firstWhere((animal) => animal['name'] == animalName)['isAdopted'] = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Available Animals')),
      body: PageView.builder(
        itemCount: _animals.length,
        scrollDirection: Axis.vertical,
        itemBuilder: (context, index) {
          final animal = _animals[index];
          return Stack(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: _buildAnimalCard(animal),
              ),
              if (animal['isAdopted'])
                Positioned.fill(
                  child: Container(
                    color: Colors.black54,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.pets, color: Colors.white, size: 50),
                          const SizedBox(height: 8),
                          const Text(
                            'Adopted',
                            style: TextStyle(color: Colors.white, fontSize: 24),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAnimalCard(Map<String, dynamic> animal) {
    return GestureDetector(
      onTap: () => _adoptAnimal(animal['name']),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.asset(
                animal['imageUrl'],
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  animal['name'],
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  animal['description'],
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

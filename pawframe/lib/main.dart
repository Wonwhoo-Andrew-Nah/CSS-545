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

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _zipController = TextEditingController();
  String? _animalType;
  double _animalAge = 0.0;

  @override
  void initState() {
    super.initState();
    _checkAndNavigateToListPage();
    _loadPreferences();
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

    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const AnimalListScreen()));
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
              onPressed: _savePreferences,
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

  Future<void> _adoptAnimal(String animalName) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(animalName, true);

    setState(() {
      _animals.firstWhere((animal) => animal['name'] == animalName)['isAdopted'] = true;
    });
  }

  void _showAnimalDetails(BuildContext context, Map<String, dynamic> animal) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('Details of ${animal['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(animal['description']),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _adoptAnimal(animal['name']);
                Navigator.pop(context);
              },
              child: const Text('Adopt'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Available Animals')),
      body: ListView.builder(
        itemCount: _animals.length,
        itemBuilder: (context, index) {
          final animal = _animals[index];
          return GestureDetector(
            onTap: () => _showAnimalDetails(context, animal),
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        child: Image.asset(
                          animal['imageUrl'],
                          fit: BoxFit.cover,
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
              ),
            ),
          );
        },
      ),
    );
  }
}

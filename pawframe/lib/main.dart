import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
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

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

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
    _loadPreferences();
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
    prefs.setDouble('animalAge', _animalAge!);
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
              onPressed: _savePreferences,
              child: const Text('Save Preferences'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const AnimalSwipeScreen()));
              },
              child: const Text('Start Swiping'),
            ),
          ],
        ),
      ),
    );
  }
}

class AnimalSwipeScreen extends StatefulWidget {
  const AnimalSwipeScreen({super.key});

  @override
  _AnimalSwipeScreenState createState() => _AnimalSwipeScreenState();
}

class _AnimalSwipeScreenState extends State<AnimalSwipeScreen> {
  // Mock data
  final List<Map<String, dynamic>> _animals = [
    {'name': 'Buddy', 'type': 'Dog', 'isAdopted': false},
    {'name': 'Mittens', 'type': 'Cat', 'isAdopted': false},
    {'name': 'Max', 'type': 'Dog', 'isAdopted': false},
  ];

  // TODO: fix parameter into String ID
  Future<void> _adoptAnimal(String animalName) async {
    await FirebaseFirestore.instance
        .collection('adoptions')
        .doc(animalName)
        .set({
      'adopted': true,
      'timestamp': FieldValue.serverTimestamp(),
    });

    setState(() {
      _animals.firstWhere(
          (animal) => animal['name'] == animalName)['isAdopted'] = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Swipe Animals')),
      body: ListView.builder(
        itemCount: _animals.length,
        itemBuilder: (context, index) {
          final animal = _animals[index];
          return GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: Text('Adopt ${animal['name']}?'),
                  content: Text('Would you like to adopt ${animal['name']}?'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        _adoptAnimal(animal['name']);
                        Navigator.pop(context);
                      },
                      child: const Text('Adopt'),
                    ),
                  ],
                ),
              );
            },
            child: ListTile(
              title: Text(animal['name']),
              subtitle: Text('Type: ${animal['type']}'),
              trailing: animal['isAdopted']
                  ? const Text('Adopted')
                  : const Text('Available'),
            ),
          );
        },
      ),
    );
  }
}

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

  // 현재 페이지의 인덱스를 추적합니다.
  int _currentAnimalIndex = 0;

  void _adoptAnimal(String animalName) async {
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
        onPageChanged: (index) {
          setState(() {
            _currentAnimalIndex = index;
          });
        },
        itemBuilder: (context, index) {
          final animal = _animals[index];
          return AnimalCard(
            animal: animal,
            isCurrent: index == _currentAnimalIndex,
            onAdopt: () {
              _adoptAnimal(animal['name']);
              // 애니메이션과 함께 'adopted' 메시지 표시
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return Center(
                    child: Container(
                      color: Colors.black54,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.paw, size: 50, color: Colors.white),
                          const SizedBox(height: 8),
                          const Text(
                            'Adopted!',
                            style: TextStyle(fontSize: 24, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class AnimalCard extends StatefulWidget {
  final Map<String, dynamic> animal;
  final bool isCurrent;
  final VoidCallback onAdopt;

  const AnimalCard({
    super.key,
    required this.animal,
    required this.isCurrent,
    required this.onAdopt,
  });

  @override
  _AnimalCardState createState() => _AnimalCardState();
}

class _AnimalCardState extends State<AnimalCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFlipped = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleCard() {
    setState(() {
      _isFlipped = !_isFlipped;
      _isFlipped ? _controller.forward() : _controller.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleCard,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _isFlipped
            ? _buildAnimalDetails()
            : _buildAnimalView(),
      ),
    );
  }

  Widget _buildAnimalView() {
    return Card(
      key: ValueKey('front'),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.asset(
                widget.animal['imageUrl'],
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
                  widget.animal['name'],
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.animal['description'],
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimalDetails() {
    return Card(
      key: ValueKey('back'),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.animal['description'],
              style: const TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: widget.onAdopt,
              child: const Text('Adopt'),
            ),
          ],
        ),
      ),
    );
  }
}

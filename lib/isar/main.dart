import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'car.dart';

late Isar isar;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dir = await getApplicationDocumentsDirectory();
  isar = await Isar.open([CarSchema], directory: dir.path);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Isar CRUD',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CarPage(),
    );
  }
}

class CarPage extends StatefulWidget {
  @override
  State<CarPage> createState() => _CarPageState();
}

class _CarPageState extends State<CarPage> {
  final nameCtrl = TextEditingController();
  final colorCtrl = TextEditingController();
  List<Car> cars = [];

  @override
  void initState() {
    super.initState();
    loadCars();
  }

  Future<void> loadCars() async {
    final result = await isar.cars.where().findAll();
    setState(() {
      cars = result;
    });
  }

  Future<void> addCar() async {
  final name = nameCtrl.text.trim();
  final color = colorCtrl.text.trim();

  if (name.isEmpty || color.isEmpty) return;

  final car = Car()
    ..name = name
    ..color = color;

  await isar.writeTxn(() => isar.cars.put(car));
  nameCtrl.clear();
  colorCtrl.clear();
  loadCars();
}

  Future<void> deleteCar(int id) async {
    await isar.writeTxn(() => isar.cars.delete(id));
    loadCars();
  }

  Future<void> editCar(Car car) async {
    final editNameCtrl = TextEditingController(text: car.name);
    final editColorCtrl = TextEditingController(text: car.color);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Car'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: editNameCtrl,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: editColorCtrl,
                decoration: InputDecoration(labelText: 'Color'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                car.name = editNameCtrl.text;
                car.color = editColorCtrl.text;
                await isar.writeTxn(() => isar.cars.put(car));
                Navigator.pop(context);
                loadCars();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 221, 88, 248),
      appBar: AppBar(title: Text('CAR MODELS ISAR')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.lightBlue[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(labelText: 'Car Name'),
                  ),
                  TextField(
                    controller: colorCtrl,
                    decoration: InputDecoration(labelText: 'Car Color'),
                  ),
                  SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: addCar,
                    child: Text('Add Car'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: cars.length,
                itemBuilder: (_, index) {
                  final car = cars[index];
                  return Card(
                    color: Colors.white,
                    margin: EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      title: Text(car.name),
                      subtitle: Text('Color: ${car.color}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.orange),
                            onPressed: () => editCar(car),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => deleteCar(car.id),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

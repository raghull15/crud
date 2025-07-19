import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'student_model.dart';

void main() {
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  runApp(const StudentApp());
}

class StudentApp extends StatelessWidget {
  const StudentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Student Center',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const StudentScreen(),
    );
  }
}

class StudentScreen extends StatefulWidget {
  const StudentScreen({super.key});

  @override
  State<StudentScreen> createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _ageController;

  Database? _db;
  List<Student> _students = [];
  Student? _editingStudent;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _ageController = TextEditingController();
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    final Directory dir = await getApplicationDocumentsDirectory();
    final String path = join(dir.path, 'students.db');

    _db = await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE students (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL,
              age INTEGER NOT NULL
            )
          ''');
        },
      ),
    );

    await _fetchStudents();
  }

  Future<void> _fetchStudents() async {
    final List<Map<String, dynamic>> maps = await _db!.query('students');
    setState(() {
      _students = maps.map((map) => Student.fromMap(map)).toList();
    });
  }

  Future<void> _addOrUpdateStudent() async {
    final String name = _nameController.text.trim();
    final int? age = int.tryParse(_ageController.text.trim());

    if (name.isEmpty || age == null) return;

    final values = {'name': name, 'age': age};

    if (_editingStudent == null) {
      await _db!.insert('students', values);
    } else {
      await _db!.update(
        'students',
        values,
        where: 'id = ?',
        whereArgs: [_editingStudent!.id],
      );
    }

    _nameController.clear();
    _ageController.clear();
    _editingStudent = null;
    await _fetchStudents();
  }

  Future<void> _deleteStudent(int id) async {
    await _db!.delete('students', where: 'id = ?', whereArgs: [id]);
    await _fetchStudents();
  }

  void _editStudent(Student student) {
    setState(() {
      _editingStudent = student;
      _nameController.text = student.name;
      _ageController.text = student.age.toString();
    });
  }

  @override
  void dispose() {
    _db?.close();
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade50,
      appBar: AppBar(
        title: const Text('Student Center'),
        backgroundColor: Colors.teal,
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade100, Colors.teal.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _ageController,
              decoration: const InputDecoration(labelText: 'Age'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _addOrUpdateStudent,
              child: Text(_editingStudent == null ? 'Add Student' : 'Update Student'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _students.isEmpty
                  ? const Center(child: Text('No students found.'))
                  : ListView.builder(
                      itemCount: _students.length,
                      itemBuilder: (context, index) {
                        final student = _students[index];
                        return Card(
                          color: Colors.white,
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            title: Text("${student.name} (${student.age})"),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _editStudent(student),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteStudent(student.id!),
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

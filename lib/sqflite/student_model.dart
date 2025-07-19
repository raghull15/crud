class Student {
  final int? id;
  final String name;
  final int age;

  Student({this.id, required this.name, required this.age});

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'age': age,
      };

  factory Student.fromMap(Map<String, dynamic> map) => Student(
        id: map['id'],
        name: map['name'],
        age: map['age'],
      );
}

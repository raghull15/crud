import 'package:isar/isar.dart';

part 'car.g.dart';

@collection
class Car {
  Id id = Isar.autoIncrement;

  late String name;
  late String color;
}

import 'package:hive/hive.dart';

part 'task.g.dart';

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  String content;

  @HiveField(1)
  DateTime createdAt;

  Task({required this.content, required this.createdAt});
}

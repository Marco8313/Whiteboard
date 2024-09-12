import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/task.dart'; // Assurez-vous que Task est bien défini

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation de Hive avec Flutter
  await Hive.initFlutter();

  // Enregistrer l'adaptateur pour le modèle Task
  Hive.registerAdapter(TaskAdapter());

  // Ouvrir une boîte appelée 'tasksBox'
  await Hive.openBox<Task>('tasksBox');

  runApp(const WhiteboardApp());
}

class WhiteboardApp extends StatelessWidget {
  const WhiteboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Whiteboard App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const WhiteboardHome(),
    );
  }
}

class WhiteboardHome extends StatefulWidget {
  const WhiteboardHome({super.key});

  @override
  _WhiteboardHomeState createState() => _WhiteboardHomeState();
}

class _WhiteboardHomeState extends State<WhiteboardHome> {
  late Box<Task> taskBox;
  TextEditingController taskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Ouvrir la boîte ici
    _openBox();
  }

  Future<void> _openBox() async {
    // Ouvrir la boîte tasksBox pour stocker des objets de type Task
    taskBox = Hive.box<Task>('tasksBox');
    setState(() {}); // Rebuild l'UI après l'ouverture de la boîte
  }

  void _addTask(String taskContent) {
    final task = Task(content: taskContent, createdAt: DateTime.now());
    taskBox.add(task); // Sauvegarder la tâche dans Hive
    taskController.clear();
    setState(() {}); // Rebuild l'UI pour afficher les nouvelles tâches
  }

  void _archiveTask(int index) {
    final task = taskBox.getAt(index);
    task?.delete(); // Supprimer la tâche active
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Whiteboard avec persistance'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: taskController,
                    decoration:
                        const InputDecoration(hintText: 'Ajouter une tâche'),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (taskController.text.isNotEmpty) {
                      _addTask(taskController.text);
                    }
                  },
                  child: const Text('Ajouter'),
                ),
              ],
            ),
          ),

          // Affichage des tâches actives
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: Hive.box<Task>('tasksBox').listenable(),
              builder: (context, Box<Task> tasks, _) {
                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks.getAt(index);

                    // Vérification du type pour éviter des erreurs de casting
                    if (task is Task) {
                      return ListTile(
                        title: Text(task.content),
                        subtitle: Text('Créée le ${task.createdAt.toLocal()}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.check),
                          onPressed: () => _archiveTask(index),
                        ),
                      );
                    } else {
                      // Si ce n'est pas un `Task`, on affiche un message d'erreur
                      return ListTile(
                        title: const Text('Erreur : Donnée non valide'),
                        subtitle: Text('Type inattendu : ${task.runtimeType}'),
                      );
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

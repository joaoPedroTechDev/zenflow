import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task.dart';
import '../models/note.dart';
import 'database_service.dart';

class FirestoreDatabaseService implements DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  bool get isFirebaseBackend => true;

  @override
  Future<void> initialize() async {
    // A inicialização em si é feita no main.dart via Firebase.initializeApp()
    // Mas podemos rodar uma validação ou configurar persistência offline se necessário
    _firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }

  // OPERAÇÕES DE TAREFAS
  @override
  Stream<List<Task>> getTasksStream() {
    return _firestore
        .collection('tasks')
        .snapshots()
        .map((snapshot) {
          final tasks = snapshot.docs
              .map((doc) => Task.fromMap(doc.data(), doc.id))
              .toList();
          
          // Ordenar localmente para manter consistência exata com o modo Mock
          tasks.sort((a, b) {
            if (a.isCompleted != b.isCompleted) {
              return a.isCompleted ? 1 : -1;
            }
            int priorityValue(String p) {
              switch (p) {
                case 'high': return 0;
                case 'medium': return 1;
                case 'low': return 2;
                default: return 3;
              }
            }
            final comp = priorityValue(a.priority).compareTo(priorityValue(b.priority));
            if (comp != 0) return comp;
            return b.createdAt.compareTo(a.createdAt);
          });
          return tasks;
        });
  }

  @override
  Future<void> addTask(Task task) async {
    await _firestore.collection('tasks').doc(task.id).set(task.toMap());
  }

  @override
  Future<void> updateTask(Task task) async {
    await _firestore.collection('tasks').doc(task.id).update(task.toMap());
  }

  @override
  Future<void> deleteTask(String id) async {
    await _firestore.collection('tasks').doc(id).delete();
  }

  // OPERAÇÕES DE NOTAS
  @override
  Stream<List<Note>> getNotesStream() {
    return _firestore
        .collection('notes')
        .snapshots()
        .map((snapshot) {
          final notes = snapshot.docs
              .map((doc) => Note.fromMap(doc.data(), doc.id))
              .toList();

          // Ordenar: fixadas primeiro, depois por data de criação decrescente
          notes.sort((a, b) {
            if (a.isPinned != b.isPinned) {
              return a.isPinned ? -1 : 1;
            }
            return b.createdAt.compareTo(a.createdAt);
          });
          return notes;
        });
  }

  @override
  Future<void> addNote(Note note) async {
    await _firestore.collection('notes').doc(note.id).set(note.toMap());
  }

  @override
  Future<void> updateNote(Note note) async {
    await _firestore.collection('notes').doc(note.id).update(note.toMap());
  }

  @override
  Future<void> deleteNote(String id) async {
    await _firestore.collection('notes').doc(id).delete();
  }
}

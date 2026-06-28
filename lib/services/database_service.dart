import '../models/task.dart';
import '../models/note.dart';

abstract class DatabaseService {
  Future<void> initialize();
  
  // Operações de Tarefas
  Stream<List<Task>> getTasksStream();
  Future<void> addTask(Task task);
  Future<void> updateTask(Task task);
  Future<void> deleteTask(String id);
  
  // Operações de Notas
  Stream<List<Note>> getNotesStream();
  Future<void> addNote(Note note);
  Future<void> updateNote(Note note);
  Future<void> deleteNote(String id);
  
  // Propriedades do Banco
  bool get isFirebaseBackend;
}

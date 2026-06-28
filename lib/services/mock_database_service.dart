import 'dart:async';
import '../models/task.dart';
import '../models/note.dart';
import 'database_service.dart';

class MockDatabaseService implements DatabaseService {
  final List<Task> _tasks = [];
  final List<Note> _notes = [];

  final _tasksController = StreamController<List<Task>>.broadcast();
  final _notesController = StreamController<List<Note>>.broadcast();

  @override
  bool get isFirebaseBackend => false;

  @override
  Future<void> initialize() async {
    // Carrega dados iniciais fictícios para visualização premium imediata
    _tasks.addAll([
      Task(
        id: 'mock-task-1',
        title: 'Integrar Firebase ao ZenFlow ☁️',
        description: 'Configurar a sincronização em nuvem Firestore no painel de configurações.',
        priority: 'high',
        category: 'work',
        dueDate: DateTime.now().add(const Duration(days: 1)),
        isCompleted: false,
        createdAt: DateTime.now(),
      ),
      Task(
        id: 'mock-task-2',
        title: 'Estudar micro-animações no Flutter ⚡',
        description: 'Aprender a usar Implicit Animations e Hero widgets para criar transições mais suaves.',
        priority: 'medium',
        category: 'study',
        dueDate: DateTime.now().add(const Duration(days: 3)),
        isCompleted: false,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Task(
        id: 'mock-task-3',
        title: 'Meditação matinal 🧘',
        description: 'Praticar 10 minutos de mindfulness antes de começar a codificar.',
        priority: 'low',
        category: 'personal',
        dueDate: DateTime.now(),
        isCompleted: true,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Task(
        id: 'mock-task-4',
        title: 'Refatorar sistema de cores HSL 🎨',
        description: 'Garantir contraste perfeito para acessibilidade em telas AMOLED.',
        priority: 'high',
        category: 'work',
        dueDate: DateTime.now(),
        isCompleted: false,
        createdAt: DateTime.now(),
      ),
    ]);

    _notes.addAll([
      Note(
        id: 'mock-note-1',
        title: 'Inspiração do Dia ✨',
        content: 'A simplicidade é o último grau da sofisticação.\n- Leonardo da Vinci',
        colorHex: '#33FFB703', // Dourado fosco
        isPinned: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      Note(
        id: 'mock-note-2',
        title: 'Lista de Compras 🍏',
        content: '• Café especial moído\n• Chocolate amargo 80%\n• Pão artesanal de fermentação natural\n• Frutas vermelhas',
        colorHex: '#3300F5D4', // Ciano fosco
        isPinned: false,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Note(
        id: 'mock-note-3',
        title: 'Ideias de Features 🚀',
        content: '1. Sincronização automática em segundo plano\n2. Widgets interativos para a tela inicial\n3. Suporte a temas personalizados baseados em papéis de parede',
        colorHex: '#339D4EDD', // Roxo fosco
        isPinned: false,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ]);

    _emitTasks();
    _emitNotes();
  }

  void _emitTasks() {
    // Ordenar tarefas: pendentes primeiro, depois por prioridade/data
    final sortedTasks = List<Task>.from(_tasks)
      ..sort((a, b) {
        if (a.isCompleted != b.isCompleted) {
          return a.isCompleted ? 1 : -1;
        }
        // Prioridade high (0), medium (1), low (2)
        int priorityValue(String p) {
          switch (p) {
            case 'high': return 0;
            case 'medium': return 1;
            case 'low': return 2;
            default: return 3;
          }
        }
        return priorityValue(a.priority).compareTo(priorityValue(b.priority));
      });
    _tasksController.add(sortedTasks);
  }

  void _emitNotes() {
    // Ordenar notas: fixadas primeiro, depois por criação decrescente
    final sortedNotes = List<Note>.from(_notes)
      ..sort((a, b) {
        if (a.isPinned != b.isPinned) {
          return a.isPinned ? -1 : 1;
        }
        return b.createdAt.compareTo(a.createdAt);
      });
    _notesController.add(sortedNotes);
  }

  @override
  Stream<List<Task>> getTasksStream() {
    scheduleMicrotask(_emitTasks);
    return _tasksController.stream;
  }

  @override
  Future<void> addTask(Task task) async {
    _tasks.add(task);
    _emitTasks();
  }

  @override
  Future<void> updateTask(Task task) async {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
      _emitTasks();
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((t) => t.id == id);
    _emitTasks();
  }

  @override
  Stream<List<Note>> getNotesStream() {
    scheduleMicrotask(_emitNotes);
    return _notesController.stream;
  }

  @override
  Future<void> addNote(Note note) async {
    _notes.add(note);
    _emitNotes();
  }

  @override
  Future<void> updateNote(Note note) async {
    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      _notes[index] = note;
      _emitNotes();
    }
  }

  @override
  Future<void> deleteNote(String id) async {
    _notes.removeWhere((n) => n.id == id);
    _emitNotes();
  }
}

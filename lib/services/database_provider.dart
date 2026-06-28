import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../config/firebase_config.dart';
import '../models/task.dart';
import '../models/note.dart';
import 'database_service.dart';
import 'mock_database_service.dart';
import 'firestore_database_service.dart';

class DatabaseProvider with ChangeNotifier {
  late DatabaseService _currentService;
  bool _isFirebaseInitialized = false;
  String _statusMessage = "Carregando...";
  bool _useFirebase = false;

  DatabaseProvider() {
    _useFirebase = FirebaseConfig.isConfigured;
    _initializeService();
  }

  DatabaseService get currentService => _currentService;
  bool get isFirebaseInitialized => _isFirebaseInitialized;
  String get statusMessage => _statusMessage;
  bool get useFirebase => _useFirebase;
  bool get isFirebaseBackend => _currentService.isFirebaseBackend;

  Future<void> _initializeService() async {
    if (_useFirebase && FirebaseConfig.isConfigured) {
      try {
        _statusMessage = "Inicializando Firebase...";
        notifyListeners();
        
        // Verifica se o Firebase já está inicializado para evitar erros
        if (Firebase.apps.isEmpty) {
          await Firebase.initializeApp(
            options: FirebaseConfig.currentPlatform,
          );
        }
        
        _currentService = FirestoreDatabaseService();
        await _currentService.initialize();
        _isFirebaseInitialized = true;
        _statusMessage = "Conectado ao Firebase Cloud Firestore";
      } catch (e) {
        _isFirebaseInitialized = false;
        _statusMessage = "Erro ao conectar ao Firebase. Usando modo offline local.";
        _currentService = MockDatabaseService();
        await _currentService.initialize();
      }
    } else {
      _currentService = MockDatabaseService();
      await _currentService.initialize();
      _isFirebaseInitialized = false;
      _statusMessage = FirebaseConfig.isConfigured 
          ? "Rodando localmente (Modo Offline)" 
          : "Firebase não configurado. Adicione chaves em 'firebase_config.dart' para nuvem.";
    }
    notifyListeners();
  }

  Future<void> toggleMode(bool enableFirebase) async {
    _useFirebase = enableFirebase;
    await _initializeService();
  }

  // STREAMS
  Stream<List<Task>> get tasksStream => _currentService.getTasksStream();
  Stream<List<Note>> get notesStream => _currentService.getNotesStream();

  // OPERAÇÕES DE TAREFA (DELEGAÇÃO)
  Future<void> addTask(Task task) async {
    await _currentService.addTask(task);
  }

  Future<void> updateTask(Task task) async {
    await _currentService.updateTask(task);
  }

  Future<void> deleteTask(String id) async {
    await _currentService.deleteTask(id);
  }

  // OPERAÇÕES DE NOTA (DELEGAÇÃO)
  Future<void> addNote(Note note) async {
    await _currentService.addNote(note);
  }

  Future<void> updateNote(Note note) async {
    await _currentService.updateNote(note);
  }

  Future<void> deleteNote(String id) async {
    await _currentService.deleteNote(id);
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:zenflow/models/task.dart';
import 'package:zenflow/services/mock_database_service.dart';

void main() {
  group('Testes do MockDatabaseService', () {
    late MockDatabaseService service;

    setUp(() {
      service = MockDatabaseService();
    });

    test('Deve inicializar com dados pré-populados', () async {
      await service.initialize();

      // Aguarda as primeiras emissões nos streams
      final tasks = await service.getTasksStream().first;
      final notes = await service.getNotesStream().first;

      expect(tasks.isNotEmpty, true);
      expect(notes.isNotEmpty, true);
      expect(tasks.length, 4); // Espera 4 tarefas mockadas
      expect(notes.length, 3); // Espera 3 notas mockadas
    });

    test('Deve adicionar uma nova tarefa com sucesso', () async {
      await service.initialize();

      final newTask = Task(
        id: 'new-test-id',
        title: 'Tarefa de Teste',
        description: 'Testando fluxo de adição',
        priority: 'high',
        category: 'study',
        dueDate: DateTime.now(),
        createdAt: DateTime.now(),
      );

      await service.addTask(newTask);
      final tasks = await service.getTasksStream().first;

      expect(tasks.length, 5); // 4 iniciais + 1 nova
      expect(tasks.any((t) => t.id == 'new-test-id'), true);
      expect(tasks.firstWhere((t) => t.id == 'new-test-id').title, 'Tarefa de Teste');
    });

    test('Deve marcar tarefa como concluída e atualizar', () async {
      await service.initialize();

      final tasks = await service.getTasksStream().first;
      final firstTask = tasks.first;
      
      expect(firstTask.isCompleted, false);

      final updatedTask = firstTask.copyWith(isCompleted: true);
      await service.updateTask(updatedTask);

      final updatedTasks = await service.getTasksStream().first;
      final foundTask = updatedTasks.firstWhere((t) => t.id == firstTask.id);

      expect(foundTask.isCompleted, true);
    });

    test('Deve deletar uma tarefa com sucesso', () async {
      await service.initialize();

      final tasks = await service.getTasksStream().first;
      final targetId = tasks.first.id;

      await service.deleteTask(targetId);

      final remainingTasks = await service.getTasksStream().first;
      expect(remainingTasks.any((t) => t.id == targetId), false);
      expect(remainingTasks.length, 3); // 4 iniciais - 1 deletada
    });
  });
}

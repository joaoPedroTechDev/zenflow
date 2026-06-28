import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';
import '../services/database_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_container.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  String _selectedFilter = 'all'; // 'all', 'work', 'personal', 'study', 'other'

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'high':
        return AppTheme.neonPink;
      case 'medium':
        return AppTheme.neonGold;
      case 'low':
        return AppTheme.neonGreen;
      default:
        return AppTheme.textMuted;
    }
  }

  String _getCategoryEmoji(String category) {
    switch (category) {
      case 'work':
        return '💼';
      case 'personal':
        return '🧘';
      case 'study':
        return '📚';
      default:
        return '🎯';
    }
  }

  void _showTaskForm(BuildContext context, {Task? task}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TaskFormBottomSheet(task: task),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dbProvider = Provider.of<DatabaseProvider>(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TÍTULO E CABEÇALHO
            Padding(
              padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 24.0, bottom: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Tarefas",
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Organize e execute seu dia",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => _showTaskForm(context),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: AppTheme.accentGradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.neonPurple.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.add_rounded, color: Colors.white, size: 20),
                          SizedBox(width: 4),
                          Text(
                            "Nova",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // FILTROS DE CATEGORIA
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Row(
                children: [
                  _buildFilterChip('all', 'Todas'),
                  const SizedBox(width: 8),
                  _buildFilterChip('work', '💼 Trabalho'),
                  const SizedBox(width: 8),
                  _buildFilterChip('personal', '🧘 Pessoal'),
                  const SizedBox(width: 8),
                  _buildFilterChip('study', '📚 Estudo'),
                  const SizedBox(width: 8),
                  _buildFilterChip('other', '🎯 Outros'),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // LISTA DE TAREFAS (REATIVA)
            Expanded(
              child: StreamBuilder<List<Task>>(
                stream: dbProvider.tasksStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppTheme.neonPurple),
                    );
                  }

                  final tasks = snapshot.data ?? [];
                  
                  // Aplica o filtro selecionado
                  final filteredTasks = _selectedFilter == 'all'
                      ? tasks
                      : tasks.where((t) => t.category == _selectedFilter).toList();

                  if (filteredTasks.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.assignment_turned_in_outlined,
                            size: 64,
                            color: AppTheme.textMuted.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Nenhuma tarefa por aqui!",
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Clique no botão '+' para adicionar.",
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(left: 24, right: 24, bottom: 90),
                    itemCount: filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = filteredTasks[index];
                      final isOverdue = !task.isCompleted && task.dueDate.isBefore(DateTime.now().subtract(const Duration(days: 1)));

                      return Dismissible(
                        key: Key(task.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: AppTheme.neonPink.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppTheme.neonPink.withOpacity(0.4)),
                          ),
                          child: const Icon(Icons.delete_sweep_rounded, color: AppTheme.neonPink, size: 28),
                        ),
                        onDismissed: (direction) {
                          dbProvider.deleteTask(task.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Tarefa '${task.title}' excluída"),
                              backgroundColor: AppTheme.deepPurple,
                              action: SnackBarAction(
                                label: "Desfazer",
                                textColor: AppTheme.neonCyan,
                                onPressed: () {
                                  dbProvider.addTask(task);
                                },
                              ),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: GlassContainer(
                            padding: const EdgeInsets.all(16),
                            borderColor: task.isCompleted
                                ? Colors.white.withOpacity(0.04)
                                : _getPriorityColor(task.priority).withOpacity(0.2),
                            child: Row(
                              children: [
                                // Checkbox Interativo
                                GestureDetector(
                                  onTap: () {
                                    dbProvider.updateTask(
                                      task.copyWith(isCompleted: !task.isCompleted),
                                    );
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    height: 24,
                                    width: 24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: task.isCompleted
                                            ? AppTheme.neonGreen
                                            : _getPriorityColor(task.priority),
                                        width: 2,
                                      ),
                                      color: task.isCompleted
                                          ? AppTheme.neonGreen.withOpacity(0.2)
                                          : Colors.transparent,
                                    ),
                                    child: task.isCompleted
                                        ? const Icon(Icons.check_rounded, size: 16, color: AppTheme.neonGreen)
                                        : null,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                
                                // Texto da Tarefa
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => _showTaskForm(context, task: task),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          task.title,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: task.isCompleted ? AppTheme.textMuted : AppTheme.textPrimary,
                                            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                                          ),
                                        ),
                                        if (task.description.isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            task.description,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: task.isCompleted ? AppTheme.textMuted : AppTheme.textSecondary,
                                            ),
                                          ),
                                        ],
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Text(
                                              "${_getCategoryEmoji(task.category)} ${task.category.toUpperCase()}",
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: task.isCompleted ? AppTheme.textMuted : AppTheme.textSecondary,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Icon(
                                              Icons.calendar_month_rounded,
                                              size: 12,
                                              color: isOverdue ? AppTheme.neonPink : AppTheme.textMuted,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              DateFormat('dd MMM').format(task.dueDate),
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: isOverdue ? AppTheme.neonPink : AppTheme.textSecondary,
                                                fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                
                                // Botão de Opções Rápidas (Editar)
                                IconButton(
                                  icon: const Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted),
                                  onPressed: () => _showTaskForm(context, task: task),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String filterCode, String label) {
    final isSelected = _selectedFilter == filterCode;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = filterCode;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.neonPurple.withOpacity(0.25) : Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.neonCyan.withOpacity(0.4) : Colors.white10,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

// FORMULÁRIO DE CRIAÇÃO/EDIÇÃO EM BOTTOM SHEET
class _TaskFormBottomSheet extends StatefulWidget {
  final Task? task;

  const _TaskFormBottomSheet({this.task});

  @override
  State<_TaskFormBottomSheet> createState() => _TaskFormBottomSheetState();
}

class _TaskFormBottomSheetState extends State<_TaskFormBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _description;
  late String _priority;
  late String _category;
  late DateTime _dueDate;

  @override
  void initState() {
    super.initState();
    _title = widget.task?.title ?? '';
    _description = widget.task?.description ?? '';
    _priority = widget.task?.priority ?? 'medium';
    _category = widget.task?.category ?? 'work';
    _dueDate = widget.task?.dueDate ?? DateTime.now().add(const Duration(days: 1));
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.neonPurple,
              onPrimary: Colors.white,
              surface: AppTheme.deepPurple,
              onSurface: AppTheme.textPrimary,
            ),
            dialogBackgroundColor: AppTheme.spaceBlack,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final dbProvider = Provider.of<DatabaseProvider>(context, listen: false);

      if (widget.task == null) {
        // Criar
        final newTask = Task(
          id: const Uuid().v4(),
          title: _title,
          description: _description,
          priority: _priority,
          category: _category,
          dueDate: _dueDate,
          createdAt: DateTime.now(),
        );
        dbProvider.addTask(newTask);
      } else {
        // Editar
        final updatedTask = widget.task!.copyWith(
          title: _title,
          description: _description,
          priority: _priority,
          category: _category,
          dueDate: _dueDate,
        );
        dbProvider.updateTask(updatedTask);
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.task != null;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: GlassContainer(
        borderRadius: 24,
        blur: 30,
        opacity: 0.16,
        padding: const EdgeInsets.all(24),
        borderColor: Colors.white.withOpacity(0.2),
        color: AppTheme.deepPurple.withOpacity(0.85),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing ? "Editar Tarefa" : "Nova Tarefa",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.neonCyan,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppTheme.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
              const SizedBox(height: 16),

              // CAMPO TÍTULO
              TextFormField(
                initialValue: _title,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  labelText: "Título da Tarefa",
                  labelStyle: const TextStyle(color: AppTheme.textSecondary),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.neonPurple),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) => value == null || value.trim().isEmpty ? "Informe o título" : null,
                onSaved: (value) => _title = value!.trim(),
              ),
              const SizedBox(height: 16),

              // CAMPO DESCRIÇÃO
              TextFormField(
                initialValue: _description,
                maxLines: 2,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  labelText: "Descrição (Opcional)",
                  labelStyle: const TextStyle(color: AppTheme.textSecondary),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.neonPurple),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onSaved: (value) => _description = value?.trim() ?? '',
              ),
              const SizedBox(height: 16),

              // SELEÇÃO DE PRIORIDADE
              const Text("Prioridade", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildPriorityChip('low', 'Baixa', AppTheme.neonGreen),
                  const SizedBox(width: 8),
                  _buildPriorityChip('medium', 'Média', AppTheme.neonGold),
                  const SizedBox(width: 8),
                  _buildPriorityChip('high', 'Alta', AppTheme.neonPink),
                ],
              ),
              const SizedBox(height: 16),

              // SELEÇÃO DE CATEGORIA
              const Text("Categoria", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildCategoryChip('work', 'Trabalho'),
                    const SizedBox(width: 8),
                    _buildCategoryChip('personal', 'Pessoal'),
                    const SizedBox(width: 8),
                    _buildCategoryChip('study', 'Estudo'),
                    const SizedBox(width: 8),
                    _buildCategoryChip('other', 'Outros'),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // DATA LIMITE E SALVAR
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Botão de Data
                  InkWell(
                    onTap: _selectDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_month_rounded, color: AppTheme.neonCyan, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat('dd/MM/yyyy').format(_dueDate),
                            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
                          )
                        ],
                      ),
                    ),
                  ),
                  
                  // Botão Salvar
                  ElevatedButton(
                    onPressed: _saveTask,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                    ).copyWith(
                      elevation: ButtonStyleButton.allOrNull(0),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: AppTheme.accentGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isEditing ? "Salvar" : "Adicionar",
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityChip(String pCode, String label, Color color) {
    final isSelected = _priority == pCode;
    return GestureDetector(
      onTap: () => setState(() => _priority = pCode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.white10,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String cCode, String label) {
    final isSelected = _category == cCode;
    return GestureDetector(
      onTap: () => setState(() => _category = cCode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.neonPurple.withOpacity(0.2) : Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.neonCyan : Colors.white10,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

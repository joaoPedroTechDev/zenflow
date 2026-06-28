import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../models/note.dart';
import '../services/database_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_container.dart';

class DashboardScreen extends StatelessWidget {
  final Function(int) navigateToTab;

  const DashboardScreen({super.key, required this.navigateToTab});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return "Bom dia 🌅";
    } else if (hour < 18) {
      return "Boa tarde ☀️";
    } else {
      return "Boa noite 🌙";
    }
  }

  @override
  Widget build(BuildContext context) {
    final dbProvider = Provider.of<DatabaseProvider>(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // CABEÇALHO DO USUÁRIO
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getGreeting(),
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              fontSize: 28,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Bem-vindo ao seu espaço ZenFlow",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => navigateToTab(3), // Vai para configurações
                    child: Hero(
                      tag: 'avatar_hero',
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppTheme.neonGradient,
                        ),
                        child: CircleAvatar(
                          radius: 22,
                          backgroundColor: AppTheme.spaceBlack,
                          child: Icon(
                            dbProvider.isFirebaseBackend 
                                ? Icons.cloud_circle_rounded 
                                : Icons.account_circle_rounded,
                            color: AppTheme.neonCyan,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // STREAM DE DADOS PARA TAREFAS (GRÁFICO DE PROGRESSO)
              StreamBuilder<List<Task>>(
                stream: dbProvider.tasksStream,
                builder: (context, snapshot) {
                  final tasks = snapshot.data ?? [];
                  final totalTasks = tasks.length;
                  final completedTasks = tasks.where((t) => t.isCompleted).length;
                  final completionRate = totalTasks > 0 ? completedTasks / totalTasks : 0.0;

                  return GlassContainer(
                    padding: const EdgeInsets.all(24),
                    borderColor: Colors.white.withOpacity(0.12),
                    child: Row(
                      children: [
                        // Gráfico de Círculo Glow
                        SizedBox(
                          height: 90,
                          width: 90,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              ShaderMask(
                                shaderCallback: (rect) {
                                  return AppTheme.neonGradient.createShader(rect);
                                },
                                child: CircularProgressIndicator(
                                  value: totalTasks > 0 ? completionRate : 0.05,
                                  strokeWidth: 8,
                                  backgroundColor: Colors.white10,
                                  strokeCap: StrokeCap.round,
                                ),
                              ),
                              Text(
                                "${(completionRate * 100).toInt()}%",
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textPrimary,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Progresso Diário",
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                totalTasks == 0
                                    ? "Nenhuma tarefa para hoje."
                                    : "$completedTasks de $totalTasks tarefas concluídas.",
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppTheme.textSecondary,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: totalTasks > 0 ? completionRate : 0.0,
                                color: AppTheme.neonCyan,
                                backgroundColor: Colors.white10,
                                minHeight: 4,
                                borderRadius: BorderRadius.circular(4),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // SEÇÃO DE ATALHOS RÁPIDOS
              Text(
                "Acesso Rápido",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildQuickActionCard(
                      context,
                      title: "Nova Tarefa",
                      subtitle: "Criar afazer",
                      icon: Icons.add_task_rounded,
                      color: AppTheme.neonPurple,
                      onTap: () => navigateToTab(1),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildQuickActionCard(
                      context,
                      title: "Nova Nota",
                      subtitle: "Anotar ideia",
                      icon: Icons.note_add_rounded,
                      color: AppTheme.neonCyan,
                      onTap: () => navigateToTab(2),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // STREAM DE NOTAS FIXADAS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Notas Fixadas",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  TextButton(
                    onPressed: () => navigateToTab(2),
                    child: const Text(
                      "Ver todas",
                      style: TextStyle(color: AppTheme.neonCyan, fontSize: 13),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 8),
              StreamBuilder<List<Note>>(
                stream: dbProvider.notesStream,
                builder: (context, snapshot) {
                  final notes = (snapshot.data ?? []).where((n) => n.isPinned).toList();

                  if (notes.isEmpty) {
                    return GlassContainer(
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(Icons.push_pin_outlined, color: AppTheme.textMuted, size: 28),
                            const SizedBox(height: 8),
                            Text(
                              "Nenhuma nota fixada no topo.",
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return SizedBox(
                    height: 130,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: notes.length,
                      itemBuilder: (context, index) {
                        final note = notes[index];
                        final noteColor = note.colorHex.startsWith('#')
                            ? Color(int.parse(note.colorHex.replaceFirst('#', '0x')))
                            : Colors.white10;

                        return Container(
                          width: 180,
                          margin: const EdgeInsets.only(right: 16),
                          child: GlassContainer(
                            color: noteColor.withOpacity(0.15),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        note.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.push_pin_rounded,
                                      size: 14,
                                      color: AppTheme.neonGold,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Expanded(
                                  child: Text(
                                    note.content,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 80), // Margem para barra de navegação flutuante
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        borderColor: color.withOpacity(0.2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/note.dart';
import '../services/database_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_container.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  String _searchQuery = '';
  final _searchController = TextEditingController();

  final List<Map<String, dynamic>> _noteColors = [
    {'name': 'Neutral', 'value': '#1AFFFFFF'},
    {'name': 'Roxo', 'value': '#339D4EDD'},
    {'name': 'Ciano', 'value': '#3300F5D4'},
    {'name': 'Dourado', 'value': '#33FFB703'},
    {'name': 'Rosa', 'value': '#33FF007F'},
    {'name': 'Verde', 'value': '#3339FF14'},
  ];

  Color _parseHexColor(String hex) {
    if (hex.startsWith('#')) {
      return Color(int.parse(hex.replaceFirst('#', '0x')));
    }
    return Colors.white12;
  }

  void _showNoteForm(BuildContext context, {Note? note}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _NoteFormBottomSheet(note: note, noteColors: _noteColors),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
            // CABEÇALHO
            Padding(
              padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 24.0, bottom: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Notas",
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Grave ideias e insights",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => _showNoteForm(context),
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
                          Icon(Icons.edit_note_rounded, color: Colors.white, size: 22),
                          SizedBox(width: 4),
                          Text(
                            "Anotar",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // BARRA DE PESQUISA
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: GlassContainer(
                borderRadius: 16,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: InputDecoration(
                    hintText: "Pesquisar notas...",
                    hintStyle: const TextStyle(color: AppTheme.textMuted),
                    icon: const Icon(Icons.search_rounded, color: AppTheme.neonCyan),
                    border: InputBorder.none,
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, color: AppTheme.textMuted, size: 20),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.trim().toLowerCase();
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),

            // GRELHA DE NOTAS (REATIVA)
            Expanded(
              child: StreamBuilder<List<Note>>(
                stream: dbProvider.notesStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppTheme.neonPurple),
                    );
                  }

                  final notes = snapshot.data ?? [];
                  final filteredNotes = notes.where((note) {
                    return note.title.toLowerCase().contains(_searchQuery) ||
                        note.content.toLowerCase().contains(_searchQuery);
                  }).toList();

                  if (filteredNotes.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.lightbulb_outline_rounded,
                            size: 64,
                            color: AppTheme.textMuted.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isNotEmpty 
                                ? "Nenhuma nota encontrada" 
                                : "Seu mural de ideias está vazio!",
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _searchQuery.isNotEmpty 
                                ? "Tente outro termo de pesquisa." 
                                : "Clique em 'Anotar' para registrar algo novo.",
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.only(left: 24, right: 24, bottom: 90, top: 12),
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 220,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: filteredNotes.length,
                    itemBuilder: (context, index) {
                      final note = filteredNotes[index];
                      final cardBg = _parseHexColor(note.colorHex);

                      return GestureDetector(
                        onTap: () => _showNoteForm(context, note: note),
                        child: GlassContainer(
                          color: cardBg.withOpacity(0.12),
                          padding: const EdgeInsets.all(16),
                          borderColor: note.isPinned 
                              ? AppTheme.neonGold.withOpacity(0.4) 
                              : Colors.white.withOpacity(0.1),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Título e Fixador
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      note.title.isEmpty ? "Sem Título" : note.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: note.title.isEmpty ? AppTheme.textMuted : AppTheme.textPrimary,
                                      ),
                                    ),
                                  ),
                                  if (note.isPinned)
                                    const Icon(
                                      Icons.push_pin_rounded,
                                      size: 14,
                                      color: AppTheme.neonGold,
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // Conteúdo
                              Expanded(
                                child: Text(
                                  note.content,
                                  maxLines: 5,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.textSecondary,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                              // Rodapé (Deletar rápido)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      dbProvider.deleteNote(note.id);
                                    },
                                    child: Icon(
                                      Icons.delete_outline_rounded,
                                      size: 16,
                                      color: AppTheme.textMuted.withOpacity(0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ],
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
}

// FORMULÁRIO DE NOTAS EM BOTTOM SHEET
class _NoteFormBottomSheet extends StatefulWidget {
  final Note? note;
  final List<Map<String, dynamic>> noteColors;

  const _NoteFormBottomSheet({this.note, required this.noteColors});

  @override
  State<_NoteFormBottomSheet> createState() => _NoteFormBottomSheetState();
}

class _NoteFormBottomSheetState extends State<_NoteFormBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _content;
  late String _colorHex;
  late bool _isPinned;

  @override
  void initState() {
    super.initState();
    _title = widget.note?.title ?? '';
    _content = widget.note?.content ?? '';
    _colorHex = widget.note?.colorHex ?? '#1AFFFFFF';
    _isPinned = widget.note?.isPinned ?? false;
  }

  void _saveNote() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final dbProvider = Provider.of<DatabaseProvider>(context, listen: false);

      if (widget.note == null) {
        // Criar
        final newNote = Note(
          id: const Uuid().v4(),
          title: _title,
          content: _content,
          colorHex: _colorHex,
          isPinned: _isPinned,
          createdAt: DateTime.now(),
        );
        dbProvider.addNote(newNote);
      } else {
        // Editar
        final updatedNote = widget.note!.copyWith(
          title: _title,
          content: _content,
          colorHex: _colorHex,
          isPinned: _isPinned,
        );
        dbProvider.updateNote(updatedNote);
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.note != null;

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
                    isEditing ? "Editar Nota" : "Nova Anotação",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.neonCyan,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          _isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                          color: _isPinned ? AppTheme.neonGold : AppTheme.textMuted,
                        ),
                        onPressed: () => setState(() => _isPinned = !_isPinned),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: AppTheme.textSecondary),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 16),

              // CAMPO TÍTULO
              TextFormField(
                initialValue: _title,
                style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  labelText: "Título da Nota (Opcional)",
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
                onSaved: (value) => _title = value?.trim() ?? '',
              ),
              const SizedBox(height: 16),

              // CAMPO CONTEÚDO
              TextFormField(
                initialValue: _content,
                maxLines: 6,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  labelText: "O que você está pensando?",
                  labelStyle: const TextStyle(color: AppTheme.textSecondary),
                  alignLabelWithHint: true,
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
                validator: (value) => value == null || value.trim().isEmpty ? "Escreva algum conteúdo para a nota" : null,
                onSaved: (value) => _content = value!.trim(),
              ),
              const SizedBox(height: 16),

              // SELETOR DE CORES
              const Text("Cor do Cartão", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.noteColors.length,
                  itemBuilder: (context, index) {
                    final colorMap = widget.noteColors[index];
                    final String colorVal = colorMap['value'];
                    final Color color = Color(int.parse(colorVal.replaceFirst('#', '0x')));
                    final isSelected = _colorHex == colorVal;

                    return GestureDetector(
                      onTap: () => setState(() => _colorHex = colorVal),
                      child: Container(
                        width: 40,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color.withOpacity(0.4),
                          border: Border.all(
                            color: isSelected ? AppTheme.neonCyan : Colors.white24,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(Icons.check_rounded, color: AppTheme.neonCyan, size: 18)
                            : null,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // BOTÃO SALVAR
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: _saveNote,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                    ).copyWith(
                      elevation: ButtonStyleButton.allOrNull(0),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: AppTheme.accentGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isEditing ? "Salvar Nota" : "Adicionar Nota",
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

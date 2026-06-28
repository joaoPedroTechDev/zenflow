class Note {
  final String id;
  final String title;
  final String content;
  final String colorHex; // Hex string for customizable glass card colors, e.g. '#FF7B2CBF'
  final bool isPinned;
  final DateTime createdAt;

  Note({
    required this.id,
    required this.title,
    required this.content,
    this.colorHex = '#1AFFFFFF', // default transparent white
    this.isPinned = false,
    required this.createdAt,
  });

  Note copyWith({
    String? id,
    String? title,
    String? content,
    String? colorHex,
    bool? isPinned,
    DateTime? createdAt,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      colorHex: colorHex ?? this.colorHex,
      isPinned: isPinned ?? this.isPinned,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'colorHex': colorHex,
      'isPinned': isPinned,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Note.fromMap(Map<String, dynamic> map, String documentId) {
    return Note(
      id: documentId,
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      colorHex: map['colorHex'] ?? '#1AFFFFFF',
      isPinned: map['isPinned'] ?? false,
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt']) 
          : DateTime.now(),
    );
  }
}

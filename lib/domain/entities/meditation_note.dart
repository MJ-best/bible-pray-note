/// 묵상 노트 엔티티
/// 순수한 비즈니스 로직 객체 (프레임워크 독립적)
class MeditationNote {
  final String? id;
  final String verse;
  final String thought;
  final String memo;
  final String prayer;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const MeditationNote({
    this.id,
    required this.verse,
    required this.thought,
    required this.memo,
    required this.prayer,
    required this.createdAt,
    this.updatedAt,
  });

  /// 노트 복사본 생성 (불변성 유지)
  MeditationNote copyWith({
    String? id,
    String? verse,
    String? thought,
    String? memo,
    String? prayer,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MeditationNote(
      id: id ?? this.id,
      verse: verse ?? this.verse,
      thought: thought ?? this.thought,
      memo: memo ?? this.memo,
      prayer: prayer ?? this.prayer,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MeditationNote &&
        other.id == id &&
        other.verse == verse &&
        other.thought == thought &&
        other.memo == memo &&
        other.prayer == prayer &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        verse.hashCode ^
        thought.hashCode ^
        memo.hashCode ^
        prayer.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}

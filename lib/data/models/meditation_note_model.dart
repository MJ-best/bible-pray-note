import '../../domain/entities/meditation_note.dart';

/// 묵상 노트 데이터 모델
/// 데이터베이스와 Entity 간 변환 담당
class MeditationNoteModel extends MeditationNote {
  const MeditationNoteModel({
    super.id,
    required super.verse,
    required super.thought,
    required super.memo,
    required super.prayer,
    required super.createdAt,
    super.updatedAt,
  });

  /// Entity로부터 Model 생성
  factory MeditationNoteModel.fromEntity(MeditationNote entity) {
    return MeditationNoteModel(
      id: entity.id,
      verse: entity.verse,
      thought: entity.thought,
      memo: entity.memo,
      prayer: entity.prayer,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// 데이터베이스 맵으로부터 Model 생성
  factory MeditationNoteModel.fromMap(Map<String, dynamic> map) {
    return MeditationNoteModel(
      id: map['id'] as String?,
      verse: map['verse'] as String,
      thought: map['thought'] as String,
      memo: map['memo'] as String,
      prayer: map['prayer'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  /// Model을 데이터베이스 맵으로 변환
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'verse': verse,
      'thought': thought,
      'memo': memo,
      'prayer': prayer,
      'created_at': createdAt.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  /// Entity로 변환
  MeditationNote toEntity() {
    return MeditationNote(
      id: id,
      verse: verse,
      thought: thought,
      memo: memo,
      prayer: prayer,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

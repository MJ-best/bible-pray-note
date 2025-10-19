import '../../domain/entities/bible_verse.dart';

/// 성경 구절 데이터 모델
class BibleVerseModel extends BibleVerse {
  const BibleVerseModel({
    required super.id,
    required super.version,
    required super.book,
    required super.chapter,
    required super.verse,
    required super.text,
  });

  /// 데이터베이스 맵으로부터 Model 생성
  factory BibleVerseModel.fromMap(Map<String, dynamic> map) {
    return BibleVerseModel(
      id: map['id'] as int,
      version: map['version'] as String,
      book: map['book'] as String,
      chapter: map['chapter'] as int,
      verse: map['verse'] as int,
      text: map['text'] as String,
    );
  }

  /// Model을 데이터베이스 맵으로 변환
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'version': version,
      'book': book,
      'chapter': chapter,
      'verse': verse,
      'text': text,
    };
  }

  /// Entity로 변환
  BibleVerse toEntity() {
    return BibleVerse(
      id: id,
      version: version,
      book: book,
      chapter: chapter,
      verse: verse,
      text: text,
    );
  }
}

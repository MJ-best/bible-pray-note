/// 성경 구절 엔티티
class BibleVerse {
  final int id;
  final String version; // KOREAN_REFORMED or NIV
  final String book;
  final int chapter;
  final int verse;
  final String text;

  const BibleVerse({
    required this.id,
    required this.version,
    required this.book,
    required this.chapter,
    required this.verse,
    required this.text,
  });

  /// 구절 참조 형식 (예: "마태복음 1:13")
  String get reference => '$book $chapter:$verse';

  /// 전체 텍스트 (참조 + 본문)
  String get fullText => '$reference $text';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BibleVerse &&
        other.id == id &&
        other.version == version &&
        other.book == book &&
        other.chapter == chapter &&
        other.verse == verse &&
        other.text == text;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        version.hashCode ^
        book.hashCode ^
        chapter.hashCode ^
        verse.hashCode ^
        text.hashCode;
  }
}

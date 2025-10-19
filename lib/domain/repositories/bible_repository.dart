import '../entities/bible_verse.dart';

/// 성경 Repository 인터페이스
abstract class BibleRepository {
  /// 성경 구절 참조로 조회 (예: "마태복음 1:13")
  Future<BibleVerse?> getVerseByReference({
    required String version,
    required String book,
    required int chapter,
    required int verse,
  });

  /// 키워드로 성경 구절 검색
  Future<List<BibleVerse>> searchVerses({
    required String version,
    required String keyword,
  });

  /// 특정 장의 모든 구절 조회
  Future<List<BibleVerse>> getVersesByChapter({
    required String version,
    required String book,
    required int chapter,
  });

  /// 성경 책 이름 목록 조회
  Future<List<String>> getBookNames(String version);
}

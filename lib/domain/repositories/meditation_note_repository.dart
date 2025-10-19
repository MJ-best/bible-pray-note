import '../entities/meditation_note.dart';

/// 묵상노트 Repository 인터페이스
/// 데이터 접근 추상화
abstract class MeditationNoteRepository {
  /// 모든 묵상노트 조회
  Future<List<MeditationNote>> getAllNotes();

  /// ID로 묵상노트 조회
  Future<MeditationNote?> getNoteById(String id);

  /// 묵상노트 생성
  Future<String> createNote(MeditationNote note);

  /// 묵상노트 수정
  Future<void> updateNote(MeditationNote note);

  /// 묵상노트 삭제
  Future<void> deleteNote(String id);

  /// 날짜 범위로 묵상노트 조회
  Future<List<MeditationNote>> getNotesByDateRange(
    DateTime startDate,
    DateTime endDate,
  );

  /// 텍스트로 묵상노트 검색
  Future<List<MeditationNote>> searchNotes(String query);
}

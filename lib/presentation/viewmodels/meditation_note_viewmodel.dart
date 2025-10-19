import 'package:flutter/foundation.dart';
import '../../domain/entities/meditation_note.dart';
import '../../domain/repositories/meditation_note_repository.dart';

/// 묵상노트 ViewModel
/// Provider의 ChangeNotifier를 사용한 상태 관리
class MeditationNoteViewModel extends ChangeNotifier {
  final MeditationNoteRepository _repository;

  MeditationNoteViewModel(this._repository);

  // 상태
  List<MeditationNote> _notes = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<MeditationNote> get notes => _notes;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasNotes => _notes.isNotEmpty;

  /// 모든 묵상노트 로드
  Future<void> loadNotes() async {
    _setLoading(true);
    _error = null;

    try {
      _notes = await _repository.getAllNotes();
      notifyListeners();
    } catch (e) {
      _error = '묵상노트를 불러오는 데 실패했습니다: $e';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// 새 묵상노트 생성
  Future<String?> createNote({
    required String verse,
    required String thought,
    required String memo,
    required String prayer,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final note = MeditationNote(
        verse: verse,
        thought: thought,
        memo: memo,
        prayer: prayer,
        createdAt: DateTime.now(),
      );

      final id = await _repository.createNote(note);
      await loadNotes(); // 목록 새로고침
      return id;
    } catch (e) {
      _error = '묵상노트 생성에 실패했습니다: $e';
      notifyListeners();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// 묵상노트 수정
  Future<bool> updateNote(MeditationNote note) async {
    _setLoading(true);
    _error = null;

    try {
      await _repository.updateNote(note);
      await loadNotes(); // 목록 새로고침
      return true;
    } catch (e) {
      _error = '묵상노트 수정에 실패했습니다: $e';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 묵상노트 삭제
  Future<bool> deleteNote(String id) async {
    _setLoading(true);
    _error = null;

    try {
      await _repository.deleteNote(id);
      await loadNotes(); // 목록 새로고침
      return true;
    } catch (e) {
      _error = '묵상노트 삭제에 실패했습니다: $e';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 묵상노트 검색
  Future<void> searchNotes(String query) async {
    if (query.isEmpty) {
      await loadNotes();
      return;
    }

    _setLoading(true);
    _error = null;

    try {
      _notes = await _repository.searchNotes(query);
      notifyListeners();
    } catch (e) {
      _error = '검색에 실패했습니다: $e';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// 로딩 상태 설정
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// 에러 초기화
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

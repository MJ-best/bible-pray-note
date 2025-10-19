import 'package:flutter/foundation.dart';
import '../../domain/entities/bible_verse.dart';
import '../../domain/repositories/bible_repository.dart';
import '../../core/constants/app_constants.dart';

/// 성경 ViewModel
class BibleViewModel extends ChangeNotifier {
  final BibleRepository _repository;

  BibleViewModel(this._repository);

  // 상태
  List<BibleVerse> _searchResults = [];
  BibleVerse? _selectedVerse;
  bool _isLoading = false;
  String? _error;
  String _currentVersion = AppConstants.versionKorean;

  // Getters
  List<BibleVerse> get searchResults => _searchResults;
  BibleVerse? get selectedVerse => _selectedVerse;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get currentVersion => _currentVersion;

  /// 역본 변경
  void setVersion(String version) {
    _currentVersion = version;
    notifyListeners();
  }

  /// 성경 구절 참조로 검색
  /// 예: "마태복음 1:13", "창 1:1"
  Future<BibleVerse?> searchByReference(String reference) async {
    _setLoading(true);
    _error = null;

    try {
      // 정규표현식으로 파싱
      final match = AppConstants.verseReferencePattern.firstMatch(reference);
      if (match == null) {
        _error = '올바른 성경 구절 형식이 아닙니다. 예: "마태복음 1:13"';
        notifyListeners();
        return null;
      }

      final book = match.group(1)!;
      final chapter = int.parse(match.group(2)!);
      final verse = int.parse(match.group(3)!);

      _selectedVerse = await _repository.getVerseByReference(
        version: _currentVersion,
        book: book,
        chapter: chapter,
        verse: verse,
      );

      if (_selectedVerse == null) {
        _error = '해당 구절을 찾을 수 없습니다.';
      }

      notifyListeners();
      return _selectedVerse;
    } catch (e) {
      _error = '구절 검색에 실패했습니다: $e';
      notifyListeners();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// 키워드로 성경 구절 검색
  Future<void> searchByKeyword(String keyword) async {
    if (keyword.trim().isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _setLoading(true);
    _error = null;

    try {
      _searchResults = await _repository.searchVerses(
        version: _currentVersion,
        keyword: keyword,
      );

      if (_searchResults.isEmpty) {
        _error = '검색 결과가 없습니다.';
      }

      notifyListeners();
    } catch (e) {
      _error = '키워드 검색에 실패했습니다: $e';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// 선택된 구절 설정
  void selectVerse(BibleVerse verse) {
    _selectedVerse = verse;
    notifyListeners();
  }

  /// 선택 해제
  void clearSelection() {
    _selectedVerse = null;
    notifyListeners();
  }

  /// 검색 결과 초기화
  void clearSearchResults() {
    _searchResults = [];
    notifyListeners();
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

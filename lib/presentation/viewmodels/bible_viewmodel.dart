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
  final Set<String> _selectedVersions = {AppConstants.versionKorean};

  // Getters
  List<BibleVerse> get searchResults => _searchResults;
  BibleVerse? get selectedVerse => _selectedVerse;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Set<String> get selectedVersions => _selectedVersions;

  /// 역본이 선택되어 있는지 확인
  bool isVersionSelected(String version) => _selectedVersions.contains(version);

  /// 역본 토글 (다중 선택 가능)
  void toggleVersion(String version) {
    if (_selectedVersions.contains(version)) {
      // 최소 하나의 버전은 선택되어 있어야 함
      if (_selectedVersions.length > 1) {
        _selectedVersions.remove(version);
      }
    } else {
      _selectedVersions.add(version);
    }
    notifyListeners();
  }

  /// 성경 구절 참조로 검색 (범위 검색 지원)
  /// 예: "마태복음 1:13" (단일 구절), "마태복음 1" (1장 전체)
  Future<void> searchByReference(String reference) async {
    _setLoading(true);
    _error = null;

    try {
      // 패턴 1: "마태복음 1:13" 형식 (책 장:절)
      final verseMatch = RegExp(r'([가-힣a-zA-Z]+)\s*(\d+):(\d+)').firstMatch(reference);

      // 패턴 2: "마태복음 1" 형식 (책 장)
      final chapterMatch = RegExp(r'([가-힣a-zA-Z]+)\s*(\d+)$').firstMatch(reference);

      List<BibleVerse> newResults = [];

      if (verseMatch != null) {
        // 단일 구절 검색
        final book = verseMatch.group(1)!;
        final chapter = int.parse(verseMatch.group(2)!);
        final verse = int.parse(verseMatch.group(3)!);

        // 선택된 모든 버전에 대해 검색
        for (final version in _selectedVersions) {
          final result = await _repository.getVerseByReference(
            version: version,
            book: book,
            chapter: chapter,
            verse: verse,
          );
          if (result != null) {
            newResults.add(result);
          }
        }
      } else if (chapterMatch != null) {
        // 장 전체 검색
        final book = chapterMatch.group(1)!;
        final chapter = int.parse(chapterMatch.group(2)!);

        // 선택된 모든 버전에 대해 검색
        for (final version in _selectedVersions) {
          final verses = await _repository.getVersesByChapter(
            version: version,
            book: book,
            chapter: chapter,
          );
          newResults.addAll(verses);
        }
      } else {
        _error = '올바른 성경 구절 형식이 아닙니다.\n예: "마태복음 1:13" 또는 "마태복음 1"';
        notifyListeners();
        return;
      }

      if (newResults.isEmpty) {
        _error = '해당 구절을 찾을 수 없습니다.';
      } else {
        // 누적 검색: 기존 결과에 추가
        _searchResults.addAll(newResults);
      }

      notifyListeners();
    } catch (e) {
      _error = '구절 검색에 실패했습니다: $e';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// 키워드로 성경 구절 검색 (누적 검색, 다중 버전 지원)
  Future<void> searchByKeyword(String keyword) async {
    if (keyword.trim().isEmpty) {
      return;
    }

    _setLoading(true);
    _error = null;

    try {
      List<BibleVerse> newResults = [];

      // 선택된 모든 버전에 대해 검색
      for (final version in _selectedVersions) {
        final verses = await _repository.searchVerses(
          version: version,
          keyword: keyword,
        );
        newResults.addAll(verses);
      }

      if (newResults.isEmpty) {
        _error = '검색 결과가 없습니다.';
      } else {
        // 누적 검색: 기존 결과에 추가
        _searchResults.addAll(newResults);
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

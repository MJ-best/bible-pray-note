import '../../domain/entities/bible_verse.dart';
import '../../domain/repositories/bible_repository.dart';
import '../../core/constants/app_constants.dart';
import '../datasources/database_helper.dart';
import '../models/bible_verse_model.dart';

/// 성경 Repository 구현체
class BibleRepositoryImpl implements BibleRepository {
  final DatabaseHelper _dbHelper;

  BibleRepositoryImpl(this._dbHelper);

  @override
  Future<BibleVerse?> getVerseByReference({
    required String version,
    required String book,
    required int chapter,
    required int verse,
  }) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      AppConstants.biblesTable,
      where: 'version = ? AND book = ? AND chapter = ? AND verse = ?',
      whereArgs: [version, book, chapter, verse],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return BibleVerseModel.fromMap(maps.first).toEntity();
  }

  @override
  Future<List<BibleVerse>> searchVerses({
    required String version,
    required String keyword,
  }) async {
    final db = await _dbHelper.database;
    final searchPattern = '%$keyword%';

    final maps = await db.query(
      AppConstants.biblesTable,
      where: 'version = ? AND text LIKE ?',
      whereArgs: [version, searchPattern],
      orderBy: 'book, chapter, verse',
    );

    return maps.map((map) => BibleVerseModel.fromMap(map).toEntity()).toList();
  }

  @override
  Future<List<BibleVerse>> getVersesByChapter({
    required String version,
    required String book,
    required int chapter,
  }) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      AppConstants.biblesTable,
      where: 'version = ? AND book = ? AND chapter = ?',
      whereArgs: [version, book, chapter],
      orderBy: 'verse',
    );

    return maps.map((map) => BibleVerseModel.fromMap(map).toEntity()).toList();
  }

  @override
  Future<List<String>> getBookNames(String version) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
      SELECT DISTINCT book
      FROM ${AppConstants.biblesTable}
      WHERE version = ?
      ORDER BY id
    ''', [version]);

    return result.map((row) => row['book'] as String).toList();
  }
}

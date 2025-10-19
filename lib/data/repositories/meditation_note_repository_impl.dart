import 'package:uuid/uuid.dart';
import '../../domain/entities/meditation_note.dart';
import '../../domain/repositories/meditation_note_repository.dart';
import '../../core/constants/app_constants.dart';
import '../datasources/database_helper.dart';
import '../models/meditation_note_model.dart';

/// 묵상노트 Repository 구현체
class MeditationNoteRepositoryImpl implements MeditationNoteRepository {
  final DatabaseHelper _dbHelper;
  final Uuid _uuid = const Uuid();

  MeditationNoteRepositoryImpl(this._dbHelper);

  @override
  Future<List<MeditationNote>> getAllNotes() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      AppConstants.notesTable,
      orderBy: 'created_at DESC',
    );

    return maps.map((map) => MeditationNoteModel.fromMap(map).toEntity()).toList();
  }

  @override
  Future<MeditationNote?> getNoteById(String id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      AppConstants.notesTable,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return MeditationNoteModel.fromMap(maps.first).toEntity();
  }

  @override
  Future<String> createNote(MeditationNote note) async {
    final db = await _dbHelper.database;
    final id = _uuid.v4();

    final model = MeditationNoteModel.fromEntity(
      note.copyWith(id: id),
    );

    await db.insert(
      AppConstants.notesTable,
      model.toMap(),
    );

    return id;
  }

  @override
  Future<void> updateNote(MeditationNote note) async {
    if (note.id == null) {
      throw ArgumentError('Note ID cannot be null for update');
    }

    final db = await _dbHelper.database;
    final model = MeditationNoteModel.fromEntity(
      note.copyWith(updatedAt: DateTime.now()),
    );

    await db.update(
      AppConstants.notesTable,
      model.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  @override
  Future<void> deleteNote(String id) async {
    final db = await _dbHelper.database;
    await db.delete(
      AppConstants.notesTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<List<MeditationNote>> getNotesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      AppConstants.notesTable,
      where: 'created_at BETWEEN ? AND ?',
      whereArgs: [
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ],
      orderBy: 'created_at DESC',
    );

    return maps.map((map) => MeditationNoteModel.fromMap(map).toEntity()).toList();
  }

  @override
  Future<List<MeditationNote>> searchNotes(String query) async {
    final db = await _dbHelper.database;
    final searchPattern = '%$query%';

    final maps = await db.query(
      AppConstants.notesTable,
      where: 'verse LIKE ? OR thought LIKE ? OR memo LIKE ? OR prayer LIKE ?',
      whereArgs: [searchPattern, searchPattern, searchPattern, searchPattern],
      orderBy: 'created_at DESC',
    );

    return maps.map((map) => MeditationNoteModel.fromMap(map).toEntity()).toList();
  }
}

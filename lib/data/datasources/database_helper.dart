import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/bible_parser.dart';

/// 로컬 데이터베이스 관리 클래스
/// 싱글톤 패턴으로 구현
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  /// 데이터베이스 인스턴스 가져오기
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// 데이터베이스 초기화
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.dbName);

    return await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// 데이터베이스 테이블 생성
  Future<void> _onCreate(Database db, int version) async {
    // 묵상노트 테이블 생성
    await db.execute('''
      CREATE TABLE ${AppConstants.notesTable} (
        id TEXT PRIMARY KEY,
        verse TEXT NOT NULL,
        thought TEXT NOT NULL,
        memo TEXT NOT NULL,
        prayer TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT
      )
    ''');

    // 성경 구절 테이블 생성
    await db.execute('''
      CREATE TABLE ${AppConstants.biblesTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        version TEXT NOT NULL,
        book TEXT NOT NULL,
        chapter INTEGER NOT NULL,
        verse INTEGER NOT NULL,
        text TEXT NOT NULL
      )
    ''');

    // 성경 구절 검색을 위한 인덱스 생성
    await db.execute('''
      CREATE INDEX idx_bible_reference
      ON ${AppConstants.biblesTable} (version, book, chapter, verse)
    ''');

    await db.execute('''
      CREATE INDEX idx_bible_text
      ON ${AppConstants.biblesTable} (text)
    ''');

    // 초기 샘플 성경 데이터 삽입 (나중에 실제 데이터로 대체)
    await _insertSampleBibleData(db);
  }

  /// 데이터베이스 업그레이드
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // 향후 버전 업그레이드 시 마이그레이션 로직 추가
  }

  /// 샘플 성경 데이터 삽입
  /// TODO: 실제 개혁개정, NIV 성경 전체 데이터로 교체 필요
  Future<void> _insertSampleBibleData(Database db) async {
    final sampleVerses = [
      {
        'version': AppConstants.versionKorean,
        'book': '창세기',
        'chapter': 1,
        'verse': 1,
        'text': '태초에 하나님이 천지를 창조하시니라',
      },
      {
        'version': AppConstants.versionKorean,
        'book': '마태복음',
        'chapter': 1,
        'verse': 1,
        'text': '아브라함과 다윗의 자손 예수 그리스도의 계보라',
      },
      {
        'version': AppConstants.versionNIV,
        'book': 'Genesis',
        'chapter': 1,
        'verse': 1,
        'text': 'In the beginning God created the heavens and the earth.',
      },
      {
        'version': AppConstants.versionNIV,
        'book': 'Matthew',
        'chapter': 1,
        'verse': 1,
        'text':
            'This is the genealogy of Jesus the Messiah the son of David, the son of Abraham:',
      },
    ];

    for (final verse in sampleVerses) {
      await db.insert(AppConstants.biblesTable, verse);
    }
  }

  /// 데이터베이스 닫기
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  /// 데이터베이스 삭제 (디버깅/테스트용)
  Future<void> deleteDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.dbName);
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }

  /// 성경 데이터가 이미 로드되었는지 확인
  Future<bool> isBibleDataLoaded() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${AppConstants.biblesTable}',
    );
    final count = result.first['count'] as int;
    // 샘플 데이터(4개) 이상이면 로드된 것으로 간주
    return count > 10;
  }

  /// 전체 성경 데이터 로드
  /// [onProgress]: 진행 상황 콜백 (0.0 ~ 1.0)
  Future<void> loadBibleData({
    Function(double progress, String message)? onProgress,
  }) async {
    // 이미 로드되었으면 스킵
    if (await isBibleDataLoaded()) {
      onProgress?.call(1.0, '성경 데이터가 이미 로드되어 있습니다');
      return;
    }

    final db = await database;

    try {
      onProgress?.call(0.1, '성경 데이터 파싱 중...');

      // 기존 샘플 데이터 삭제
      await db.delete(AppConstants.biblesTable);

      // 성경 데이터 파싱
      final verses = await BibleParser.parseAllBibles();

      onProgress?.call(0.3, '${verses.length}개 구절을 데이터베이스에 저장 중...');

      // 배치 삽입으로 성능 최적화
      const batchSize = 500;
      int totalBatches = (verses.length / batchSize).ceil();

      await db.transaction((txn) async {
        for (int i = 0; i < verses.length; i += batchSize) {
          final end = (i + batchSize < verses.length) ? i + batchSize : verses.length;
          final batch = txn.batch();

          for (int j = i; j < end; j++) {
            final verse = verses[j];
            batch.insert(AppConstants.biblesTable, {
              'version': verse.version,
              'book': verse.book,
              'chapter': verse.chapter,
              'verse': verse.verse,
              'text': verse.text,
            });
          }

          await batch.commit(noResult: true);

          // 진행 상황 업데이트
          final currentBatch = (i / batchSize).floor() + 1;
          final progress = 0.3 + (currentBatch / totalBatches) * 0.7;
          final message = '${currentBatch}/$totalBatches 배치 저장 완료 (${((currentBatch / totalBatches) * 100).toStringAsFixed(1)}%)';
          onProgress?.call(progress, message);
        }
      });

      onProgress?.call(1.0, '성경 데이터 로드 완료!');
    } catch (e) {
      onProgress?.call(0.0, '오류 발생: $e');
      rethrow;
    }
  }
}

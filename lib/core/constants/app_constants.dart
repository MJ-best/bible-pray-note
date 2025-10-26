/// 앱 전체에서 사용되는 상수 정의
class AppConstants {
  // 데이터베이스 관련
  static const String dbName = 'bible_pray_note.db';
  static const int dbVersion = 1;

  // 테이블 이름
  static const String notesTable = 'notes';
  static const String biblesTable = 'bibles';

  // 성경 역본
  static const String versionKorean = 'KOREAN_REFORMED';
  static const String versionNIV = 'NIV';

  // 묵상노트 템플릿 섹션
  static const String sectionVerse = 'verse';
  static const String sectionThought = 'thought';
  static const String sectionMemo = 'memo';
  static const String sectionPrayer = 'prayer';

  // 날짜 형식
  static const String dateFormat = 'yyyy년 MM월 dd일';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';

  // UI 관련
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 12.0;
  static const double minTouchTarget = 44.0;

  // 앱 아이콘 및 로고 경로
  static const String appIcon = 'assets/icons/icon.png';
  static const String appIconSvg = 'assets/icons/icon_template.svg';

  // 정규표현식 패턴
  // 성경 구절 참조: "마태복음 1:13", "창 1:1" 등
  static final RegExp verseReferencePattern = RegExp(
    r'([가-힣a-zA-Z]+)\s*(\d+):(\d+)(?:-(\d+))?',
  );
}

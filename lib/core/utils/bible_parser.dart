import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:xml/xml.dart';

/// 성경 데이터 파싱 결과
class BibleData {
  final String version;
  final String book;
  final int chapter;
  final int verse;
  final String text;

  BibleData({
    required this.version,
    required this.book,
    required this.chapter,
    required this.verse,
    required this.text,
  });
}

/// 성경 데이터 파서
class BibleParser {
  /// 한국어 성경 XML 파싱
  static Future<List<BibleData>> parseKoreanBible() async {
    final xmlString = await rootBundle.loadString('assets/bible/kor.xml');
    final document = XmlDocument.parse(xmlString);

    final List<BibleData> verses = [];

    // <BIBLEBOOK> 요소들 순회
    for (final bookElement in document.findAllElements('BIBLEBOOK')) {
      final bookName = bookElement.getAttribute('bname') ?? '';

      // <CHAPTER> 요소들 순회
      for (final chapterElement in bookElement.findAllElements('CHAPTER')) {
        final chapterNum = int.parse(chapterElement.getAttribute('cnumber') ?? '0');

        // <VERS> 요소들 순회
        for (final verseElement in chapterElement.findAllElements('VERS')) {
          final verseNum = int.parse(verseElement.getAttribute('vnumber') ?? '0');
          final text = verseElement.innerText;

          verses.add(BibleData(
            version: 'KOREAN_REFORMED',
            book: bookName,
            chapter: chapterNum,
            verse: verseNum,
            text: text,
          ));
        }
      }
    }

    return verses;
  }

  /// NIV 성경 JSON 파싱
  static Future<List<BibleData>> parseNIVBible() async {
    final jsonString = await rootBundle.loadString('assets/bible/NIV_bible.json');
    final Map<String, dynamic> data = json.decode(jsonString);

    final List<BibleData> verses = [];

    // 책별 순회
    data.forEach((bookName, chapters) {
      if (chapters is Map<String, dynamic>) {
        // 장별 순회
        chapters.forEach((chapterNum, verseMap) {
          if (verseMap is Map<String, dynamic>) {
            // 절별 순회
            verseMap.forEach((verseNum, text) {
              verses.add(BibleData(
                version: 'NIV',
                book: bookName,
                chapter: int.parse(chapterNum),
                verse: int.parse(verseNum),
                text: text.toString(),
              ));
            });
          }
        });
      }
    });

    return verses;
  }

  /// 모든 성경 데이터 파싱
  static Future<List<BibleData>> parseAllBibles() async {
    final korean = await parseKoreanBible();
    final niv = await parseNIVBible();
    return [...korean, ...niv];
  }
}

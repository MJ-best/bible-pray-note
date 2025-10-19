import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../domain/entities/meditation_note.dart';
import '../../viewmodels/meditation_note_viewmodel.dart';
import '../../widgets/verse_search_bottom_sheet.dart';

/// 묵상노트 작성/편집 화면
class NoteEditorScreen extends StatefulWidget {
  final MeditationNote? note;

  const NoteEditorScreen({super.key, this.note});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _verseController;
  late final TextEditingController _thoughtController;
  late final TextEditingController _memoController;
  late final TextEditingController _prayerController;

  bool get isEditing => widget.note != null;

  @override
  void initState() {
    super.initState();
    _verseController = TextEditingController(text: widget.note?.verse ?? '');
    _thoughtController = TextEditingController(text: widget.note?.thought ?? '');
    _memoController = TextEditingController(text: widget.note?.memo ?? '');
    _prayerController = TextEditingController(text: widget.note?.prayer ?? '');
  }

  @override
  void dispose() {
    _verseController.dispose();
    _thoughtController.dispose();
    _memoController.dispose();
    _prayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy년 MM월 dd일');
    final displayDate = widget.note?.createdAt ?? DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? '묵상 수정' : '새 묵상'),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _shareNote,
              tooltip: '공유',
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 날짜 표시
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 18,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    dateFormat.format(displayDate),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 말씀 (성경 구절)
            _buildSectionLabel('말씀'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _verseController,
              decoration: InputDecoration(
                hintText: '예: 마태복음 1:13',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _searchVerse,
                  tooltip: '성경 검색',
                ),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '말씀을 입력해주세요';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // 생각
            _buildSectionLabel('생각'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _thoughtController,
              decoration: const InputDecoration(
                hintText: '말씀을 통해 받은 깨달음과 생각을 적어보세요',
                alignLabelWithHint: true,
              ),
              maxLines: 6,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '생각을 입력해주세요';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // 메모
            _buildSectionLabel('메모'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _memoController,
              decoration: const InputDecoration(
                hintText: '추가로 기억하고 싶은 내용을 적어보세요',
                alignLabelWithHint: true,
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 24),

            // 기도
            _buildSectionLabel('기도'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _prayerController,
              decoration: const InputDecoration(
                hintText: '하나님께 드리는 기도를 적어보세요',
                alignLabelWithHint: true,
              ),
              maxLines: 6,
            ),
            const SizedBox(height: 32),

            // 저장 버튼
            FilledButton(
              onPressed: _saveNote,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                isEditing ? '수정 완료' : '저장',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 섹션 라벨 위젯
  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }

  /// 성경 구절 검색
  Future<void> _searchVerse() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const VerseSearchBottomSheet(),
    );

    if (result != null) {
      setState(() {
        _verseController.text = result;
      });
    }
  }

  /// 노트 저장
  Future<void> _saveNote() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final viewModel = context.read<MeditationNoteViewModel>();

    if (isEditing) {
      // 수정
      final updatedNote = widget.note!.copyWith(
        verse: _verseController.text.trim(),
        thought: _thoughtController.text.trim(),
        memo: _memoController.text.trim(),
        prayer: _prayerController.text.trim(),
      );

      final success = await viewModel.updateNote(updatedNote);
      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('묵상노트가 수정되었습니다')),
        );
      }
    } else {
      // 새로 생성
      final id = await viewModel.createNote(
        verse: _verseController.text.trim(),
        thought: _thoughtController.text.trim(),
        memo: _memoController.text.trim(),
        prayer: _prayerController.text.trim(),
      );

      if (id != null && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('묵상노트가 저장되었습니다')),
        );
      }
    }

    // 에러 처리
    if (viewModel.error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.error!),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  /// 노트 공유
  Future<void> _shareNote() async {
    final dateFormat = DateFormat('yyyy년 MM월 dd일');
    final note = widget.note;
    if (note == null) return;

    final shareText = '''
📖 성경묵상노트
날짜: ${dateFormat.format(note.createdAt)}

📝 말씀
${note.verse}

💭 생각
${note.thought}

📌 메모
${note.memo}

🙏 기도
${note.prayer}
''';

    await Share.share(shareText, subject: '성경묵상노트');
  }
}

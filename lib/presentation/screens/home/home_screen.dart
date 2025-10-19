import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/meditation_note_viewmodel.dart';
import '../../viewmodels/theme_viewmodel.dart';
import '../note_editor/note_editor_screen.dart';
import '../../widgets/note_card.dart';

/// 홈 화면
/// 묵상노트 목록 표시
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // 초기 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MeditationNoteViewModel>().loadNotes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('성경묵상노트'),
        actions: [
          // 테마 변경 버튼
          Consumer<ThemeViewModel>(
            builder: (context, themeViewModel, _) {
              return IconButton(
                icon: Icon(
                  themeViewModel.isDarkMode
                      ? Icons.light_mode
                      : Icons.dark_mode,
                ),
                onPressed: () {
                  themeViewModel.toggleDarkMode();
                },
                tooltip: '테마 변경',
              );
            },
          ),
        ],
      ),
      body: Consumer<MeditationNoteViewModel>(
        builder: (context, viewModel, _) {
          // 로딩 중
          if (viewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // 에러 발생
          if (viewModel.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    viewModel.error!,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => viewModel.loadNotes(),
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            );
          }

          // 빈 목록
          if (!viewModel.hasNotes) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.book_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '아직 작성된 묵상노트가 없습니다',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '+ 버튼을 눌러 첫 번째 묵상을 시작해보세요',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          // 묵상노트 목록
          return RefreshIndicator(
            onRefresh: () => viewModel.loadNotes(),
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 80),
              itemCount: viewModel.notes.length,
              itemBuilder: (context, index) {
                final note = viewModel.notes[index];
                return NoteCard(
                  note: note,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NoteEditorScreen(note: note),
                      ),
                    );
                  },
                  onDelete: () => _showDeleteDialog(context, note.id!),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const NoteEditorScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('새 묵상'),
      ),
    );
  }

  /// 삭제 확인 다이얼로그
  Future<void> _showDeleteDialog(BuildContext context, String noteId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('삭제 확인'),
        content: const Text('이 묵상노트를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<MeditationNoteViewModel>().deleteNote(noteId);
    }
  }
}

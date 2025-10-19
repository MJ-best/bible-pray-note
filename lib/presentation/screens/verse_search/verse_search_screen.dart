import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/bible_viewmodel.dart';
import '../../../core/constants/app_constants.dart';

/// 성경 구절 검색 화면
class VerseSearchScreen extends StatefulWidget {
  const VerseSearchScreen({super.key});

  @override
  State<VerseSearchScreen> createState() => _VerseSearchScreenState();
}

class _VerseSearchScreenState extends State<VerseSearchScreen> {
  final _searchController = TextEditingController();
  bool _isReferenceSearch = true; // true: 구절 참조, false: 키워드

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('성경 검색'),
      ),
      body: Column(
        children: [
          // 검색 옵션
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 역본 선택
                Consumer<BibleViewModel>(
                  builder: (context, viewModel, _) {
                    return Row(
                      children: [
                        Text(
                          '역본:',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(width: 12),
                        ChoiceChip(
                          label: const Text('개혁개정'),
                          selected: viewModel.currentVersion ==
                              AppConstants.versionKorean,
                          onSelected: (_) => viewModel
                              .setVersion(AppConstants.versionKorean),
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('NIV'),
                          selected:
                              viewModel.currentVersion == AppConstants.versionNIV,
                          onSelected: (_) =>
                              viewModel.setVersion(AppConstants.versionNIV),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),

                // 검색 타입 선택
                Row(
                  children: [
                    Text(
                      '검색:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(width: 12),
                    ChoiceChip(
                      label: const Text('구절 참조'),
                      selected: _isReferenceSearch,
                      onSelected: (_) => setState(() => _isReferenceSearch = true),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('키워드'),
                      selected: !_isReferenceSearch,
                      onSelected: (_) => setState(() => _isReferenceSearch = false),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 검색 입력
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: _isReferenceSearch
                        ? '예: 마태복음 1:13'
                        : '예: 사랑',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        context.read<BibleViewModel>().clearSearchResults();
                      },
                    ),
                  ),
                  onSubmitted: _performSearch,
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // 검색 결과
          Expanded(
            child: Consumer<BibleViewModel>(
              builder: (context, viewModel, _) {
                if (viewModel.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (viewModel.error != null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 48,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            viewModel.error!,
                            style: Theme.of(context).textTheme.bodyLarge,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // 구절 참조 검색 결과
                if (_isReferenceSearch && viewModel.selectedVerse != null) {
                  final verse = viewModel.selectedVerse!;
                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Card(
                        child: InkWell(
                          onTap: () => _selectVerse(verse.fullText),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  verse.reference,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: Theme.of(context).colorScheme.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  verse.text,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }

                // 키워드 검색 결과
                if (!_isReferenceSearch && viewModel.searchResults.isNotEmpty) {
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: viewModel.searchResults.length,
                    itemBuilder: (context, index) {
                      final verse = viewModel.searchResults[index];
                      return Card(
                        child: InkWell(
                          onTap: () => _selectVerse(verse.fullText),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  verse.reference,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: Theme.of(context).colorScheme.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  verse.text,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }

                // 초기 상태
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search,
                        size: 64,
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _isReferenceSearch
                            ? '성경 구절을 입력하세요\n예: 마태복음 1:13'
                            : '검색할 키워드를 입력하세요\n예: 사랑, 믿음',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 검색 실행
  void _performSearch(String query) {
    if (query.trim().isEmpty) return;

    final viewModel = context.read<BibleViewModel>();

    if (_isReferenceSearch) {
      viewModel.searchByReference(query.trim());
    } else {
      viewModel.searchByKeyword(query.trim());
    }
  }

  /// 구절 선택
  void _selectVerse(String verseText) {
    Navigator.pop(context, verseText);
  }
}

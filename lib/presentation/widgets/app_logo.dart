import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

/// 앱 로고 위젯
///
/// 다양한 화면(About, 온보딩, Empty State 등)에서 앱 아이콘을 표시하는데 사용됩니다.
///
/// 사용 예시:
/// ```dart
/// // 기본 크기 (64x64)
/// AppLogo()
///
/// // 커스텀 크기
/// AppLogo(size: 100)
///
/// // 그림자 효과 포함
/// AppLogo(size: 120, showShadow: true)
/// ```
class AppLogo extends StatelessWidget {
  /// 로고 크기 (정사각형)
  final double size;

  /// 그림자 표시 여부
  final bool showShadow;

  /// 배경 원형 표시 여부
  final bool showBackground;

  /// 배경 색상 (showBackground가 true일 때 사용)
  final Color? backgroundColor;

  const AppLogo({
    super.key,
    this.size = 64.0,
    this.showShadow = false,
    this.showBackground = false,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final logo = Image.asset(
      AppConstants.appIcon,
      width: size,
      height: size,
      fit: BoxFit.contain,
    );

    Widget result = logo;

    // 배경 원형 추가
    if (showBackground) {
      result = Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor ?? Theme.of(context).colorScheme.surface,
          shape: BoxShape.circle,
        ),
        padding: EdgeInsets.all(size * 0.15),
        child: logo,
      );
    }

    // 그림자 효과 추가
    if (showShadow) {
      result = Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(showBackground ? size / 2 : size * 0.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: result,
      );
    }

    return result;
  }
}

/// 앱 로고와 함께 앱 이름을 표시하는 위젯
///
/// About 화면이나 온보딩 화면에서 사용하기 적합합니다.
///
/// 사용 예시:
/// ```dart
/// AppLogoWithTitle()
///
/// AppLogoWithTitle(
///   logoSize: 100,
///   showSubtitle: true,
/// )
/// ```
class AppLogoWithTitle extends StatelessWidget {
  /// 로고 크기
  final double logoSize;

  /// 제목 텍스트 스타일
  final TextStyle? titleStyle;

  /// 부제목 표시 여부
  final bool showSubtitle;

  /// 부제목 텍스트 스타일
  final TextStyle? subtitleStyle;

  /// 로고와 텍스트 사이 간격
  final double spacing;

  const AppLogoWithTitle({
    super.key,
    this.logoSize = 80.0,
    this.titleStyle,
    this.showSubtitle = false,
    this.subtitleStyle,
    this.spacing = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppLogo(
          size: logoSize,
          showShadow: true,
        ),
        SizedBox(height: spacing),
        Text(
          '성경묵상노트',
          style: titleStyle ??
              theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
        ),
        if (showSubtitle) ...[
          const SizedBox(height: 8),
          Text(
            'Bible Meditation Notes',
            style: subtitleStyle ??
                theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
          ),
        ],
      ],
    );
  }
}

/// Empty State에서 사용하는 로고 위젯
///
/// 데이터가 없을 때 표시하는 화면에 사용됩니다.
///
/// 사용 예시:
/// ```dart
/// EmptyStateLogo(
///   message: '아직 작성된 묵상노트가 없습니다',
///   actionText: '첫 노트 작성하기',
///   onActionPressed: () => _createFirstNote(),
/// )
/// ```
class EmptyStateLogo extends StatelessWidget {
  /// 메시지 텍스트
  final String message;

  /// 액션 버튼 텍스트 (null이면 버튼 미표시)
  final String? actionText;

  /// 액션 버튼 클릭 핸들러
  final VoidCallback? onActionPressed;

  const EmptyStateLogo({
    super.key,
    required this.message,
    this.actionText,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppLogo(
              size: 120,
              showBackground: true,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            if (actionText != null && onActionPressed != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onActionPressed,
                icon: const Icon(Icons.add),
                label: Text(actionText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

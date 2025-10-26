# 앱 아이콘 사용 가이드

앱 런처 아이콘뿐만 아니라, 앱 내부에서도 로고를 표시할 수 있습니다.

---

## 📍 Asset 경로

아이콘 이미지는 `pubspec.yaml`에 등록되어 있으며, 다음 상수로 접근할 수 있습니다:

```dart
import 'package:bible_pray_note/core/constants/app_constants.dart';

// PNG 아이콘
AppConstants.appIcon  // 'assets/icons/icon.png'

// SVG 아이콘 (필요시)
AppConstants.appIconSvg  // 'assets/icons/icon_template.svg'
```

---

## 🎨 제공되는 위젯

`lib/presentation/widgets/app_logo.dart`에 3가지 로고 위젯이 준비되어 있습니다:

### 1. `AppLogo` - 기본 로고 위젯

가장 기본적인 로고 위젯입니다.

```dart
import 'package:bible_pray_note/presentation/widgets/app_logo.dart';

// 기본 사용 (64x64)
AppLogo()

// 크기 조절
AppLogo(size: 100)

// 그림자 효과 추가
AppLogo(
  size: 100,
  showShadow: true,
)

// 배경 원형 추가
AppLogo(
  size: 100,
  showBackground: true,
  backgroundColor: Colors.blue.shade50,
)
```

**매개변수:**
- `size`: 로고 크기 (기본값: 64.0)
- `showShadow`: 그림자 표시 여부 (기본값: false)
- `showBackground`: 배경 원형 표시 여부 (기본값: false)
- `backgroundColor`: 배경 색상 (기본값: Theme의 surface 색상)

---

### 2. `AppLogoWithTitle` - 로고 + 앱 이름

로고와 함께 앱 이름을 표시합니다. About 화면이나 온보딩 화면에 적합합니다.

```dart
import 'package:bible_pray_note/presentation/widgets/app_logo.dart';

// 기본 사용
AppLogoWithTitle()

// 부제목 포함
AppLogoWithTitle(
  logoSize: 100,
  showSubtitle: true,  // "Bible Meditation Notes" 표시
)

// 스타일 커스터마이징
AppLogoWithTitle(
  logoSize: 120,
  showSubtitle: true,
  titleStyle: TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: Colors.blue,
  ),
  spacing: 20,  // 로고와 텍스트 사이 간격
)
```

**매개변수:**
- `logoSize`: 로고 크기 (기본값: 80.0)
- `titleStyle`: 제목 텍스트 스타일
- `showSubtitle`: 부제목 표시 여부 (기본값: false)
- `subtitleStyle`: 부제목 텍스트 스타일
- `spacing`: 로고와 텍스트 사이 간격 (기본값: 16.0)

---

### 3. `EmptyStateLogo` - Empty State용 위젯

데이터가 없을 때 표시하는 화면에 사용합니다.

```dart
import 'package:bible_pray_note/presentation/widgets/app_logo.dart';

// 메시지만 표시
EmptyStateLogo(
  message: '아직 작성된 묵상노트가 없습니다',
)

// 액션 버튼 포함
EmptyStateLogo(
  message: '아직 작성된 묵상노트가 없습니다',
  actionText: '첫 노트 작성하기',
  onActionPressed: () {
    // 노트 작성 화면으로 이동
    Navigator.pushNamed(context, '/create-note');
  },
)
```

**매개변수:**
- `message`: 표시할 메시지 (필수)
- `actionText`: 액션 버튼 텍스트 (선택사항)
- `onActionPressed`: 액션 버튼 클릭 핸들러 (선택사항)

---

## 💡 사용 사례 예시

### About 화면

```dart
class AboutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('앱 정보')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppLogoWithTitle(
              logoSize: 120,
              showSubtitle: true,
            ),
            SizedBox(height: 32),
            Text('버전 1.0.0'),
            SizedBox(height: 16),
            Text('© 2024 Bible Pray Note'),
          ],
        ),
      ),
    );
  }
}
```

### 온보딩 화면

```dart
class OnboardingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppLogo(
                size: 150,
                showShadow: true,
              ),
              SizedBox(height: 40),
              Text(
                '성경묵상노트',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Text(
                '말씀과 함께하는 매일의 묵상',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              Spacer(),
              FilledButton(
                onPressed: () => _navigateToHome(context),
                child: Text('시작하기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### Empty State (노트 목록이 비어있을 때)

```dart
class NotesListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final notes = []; // 노트 목록 (비어있음)

    return Scaffold(
      appBar: AppBar(title: Text('내 묵상노트')),
      body: notes.isEmpty
          ? EmptyStateLogo(
              message: '아직 작성된 묵상노트가 없습니다\n첫 묵상을 시작해보세요!',
              actionText: '새 노트 작성',
              onActionPressed: () {
                Navigator.pushNamed(context, '/create-note');
              },
            )
          : ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) => NoteListItem(notes[index]),
            ),
    );
  }
}
```

### 설정 화면 (헤더)

```dart
class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            flexibleSpace: FlexibleSpaceBar(
              background: Center(
                child: AppLogoWithTitle(
                  logoSize: 80,
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              ListTile(title: Text('알림 설정')),
              ListTile(title: Text('테마 설정')),
              // ... 기타 설정 항목
            ]),
          ),
        ],
      ),
    );
  }
}
```

---

## 🎯 직접 Image.asset 사용

위젯을 사용하지 않고 직접 아이콘을 로드하려면:

```dart
import 'package:bible_pray_note/core/constants/app_constants.dart';

Image.asset(
  AppConstants.appIcon,
  width: 100,
  height: 100,
  fit: BoxFit.contain,
)
```

---

## ⚠️ 주의사항

1. **Asset 등록 확인**: `pubspec.yaml`에 아이콘이 등록되어 있는지 확인
   ```yaml
   assets:
     - assets/icons/icon.png
   ```

2. **Hot Reload 제한**: Asset 파일 변경 시 Hot Reload가 아닌 Hot Restart 필요
   ```bash
   # Hot Restart
   flutter run
   ```

3. **파일 크기**: PNG 파일은 5KB 정도로 최적화되어 있지만, 더 큰 화면에서 사용할 경우 별도의 고해상도 이미지 고려

4. **테마 대응**: 현재 아이콘은 고정 색상이므로, 다크모드에서도 동일하게 표시됩니다. 필요시 별도의 다크모드용 아이콘을 준비할 수 있습니다.

---

## 📚 추가 리소스

- [Flutter Image 위젯 문서](https://api.flutter.dev/flutter/widgets/Image-class.html)
- [Asset 및 이미지 가이드](https://docs.flutter.dev/ui/assets/assets-and-images)
- [Material Design - App Icons](https://m3.material.io/styles/icons/overview)

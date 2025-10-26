# 앱 아이콘 설치 가이드

## 📱 성경묵상노트 앱 아이콘

이 폴더에는 앱 아이콘 이미지와 관련 설정이 포함되어 있습니다.

---

## 🎨 1단계: 아이콘 이미지 준비

### 필요한 파일:
- `icon.png` - 1024x1024px (필수)
- `icon_foreground.png` - 1024x1024px (선택사항, Android Adaptive Icon용)

### 아이콘 생성 방법:

#### 방법 1: AI 이미지 생성 (추천)
`ICON_DESIGN_GUIDE.md` 파일의 프롬프트를 사용하여:
- ChatGPT (DALL-E) - https://chat.openai.com
- Microsoft Designer - https://designer.microsoft.com
- Adobe Firefly - https://firefly.adobe.com

생성된 이미지를 `assets/icons/icon.png`로 저장

#### 방법 2: 직접 디자인
- Canva - https://www.canva.com
- Figma - https://www.figma.com
- Photoshop/Illustrator

디자인 상세 가이드는 `ICON_DESIGN_GUIDE.md` 참조

---

## 🔧 2단계: 의존성 설치

터미널에서 다음 명령어 실행:

```bash
flutter pub get
```

이 명령어는 `flutter_launcher_icons` 패키지를 설치합니다.

---

## 🚀 3단계: 아이콘 생성

아이콘 이미지가 `assets/icons/icon.png`에 준비되었으면:

```bash
flutter pub run flutter_launcher_icons
```

이 명령어는 자동으로:
- ✅ iOS용 모든 크기의 아이콘 생성 (20x20 ~ 1024x1024)
- ✅ Android용 모든 크기의 아이콘 생성 (mipmap-mdpi ~ mipmap-xxxhdpi)
- ✅ Android Adaptive Icon 설정 (API 26+)
- ✅ 각 플랫폼의 설정 파일 업데이트

---

## 📝 4단계: 확인

### Android 아이콘 확인:
```bash
ls -la android/app/src/main/res/mipmap-*/
```

### iOS 아이콘 확인:
```bash
ls -la ios/Runner/Assets.xcassets/AppIcon.appiconset/
```

---

## 🧪 5단계: 테스트

### 앱 재빌드 및 실행:
```bash
# 기존 빌드 삭제
flutter clean

# 의존성 재설치
flutter pub get

# Android 실행
flutter run

# 또는 iOS 실행 (macOS에서만)
flutter run -d ios
```

실행 후 홈 화면에서 앱 아이콘을 확인하세요.

---

## 🎯 설정 커스터마이징

`pubspec.yaml`의 `flutter_launcher_icons` 섹션에서:

### 배경색 변경 (Android Adaptive Icon):
```yaml
adaptive_icon_background: "#YOUR_HEX_COLOR"
```

### iOS만 별도 아이콘 사용:
```yaml
ios:
  generate: true
  image_path: "assets/icons/icon_ios.png"
```

### Android만 별도 아이콘 사용:
```yaml
android:
  generate: true
  image_path: "assets/icons/icon_android.png"
```

변경 후 다시 `flutter pub run flutter_launcher_icons` 실행

---

## ❓ 문제 해결

### "icon.png not found" 에러
- `assets/icons/icon.png` 파일이 있는지 확인
- 파일명과 경로가 정확한지 확인 (대소문자 구분)

### 아이콘이 업데이트되지 않음
```bash
flutter clean
flutter pub run flutter_launcher_icons
flutter run
```

### Adaptive icon 배경이 표시되지 않음
- Android API 26 (Android 8.0) 이상에서만 작동
- 에뮬레이터/실제 기기의 Android 버전 확인

---

## 📚 추가 리소스

- [flutter_launcher_icons 공식 문서](https://pub.dev/packages/flutter_launcher_icons)
- [Android Adaptive Icons 가이드](https://developer.android.com/guide/practices/ui_guidelines/icon_design_adaptive)
- [iOS App Icon 가이드](https://developer.apple.com/design/human-interface-guidelines/app-icons)

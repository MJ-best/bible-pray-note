# 빠른 시작 가이드 - 앱 아이콘 생성

## 🚀 가장 빠른 방법 (AI 이미지 생성 추천)

### 옵션 1: ChatGPT로 아이콘 생성 (추천)

1. **ChatGPT 접속**: https://chat.openai.com (DALL-E 사용 가능)

2. **다음 프롬프트 복사해서 입력**:

```
성경 묵상 노트 앱의 아이콘을 디자인해주세요.

요구사항:
- 크기: 1024x1024 픽셀, 정사각형
- 디자인: 중앙에 현대적이고 단순한 금색 십자가, 배경은 짙은 남색(#1A237E)
- 십자가는 둥근 모서리를 가진 미니멀한 스타일
- 하단에 노트를 연상시키는 3개의 얇은 흰색 수평선 (투명도 낮게)
- 우측 상단에 작은 북마크 리본 장식 (하늘색)
- 플랫 디자인, 그림자 없음
- 텍스트나 글자 없음
- 모바일 앱 아이콘으로 적합하도록 작은 크기에서도 명확하게 보여야 함

색상:
- 배경: 짙은 인디고 블루 (#1A237E)
- 십자가: 금색/호박색 (#FFC107)
- 노트 라인: 흰색 (20% 투명도)
- 북마크: 하늘색 (#64B5F6, 60% 투명도)

스타일: 모던, 미니멀, 영적, 전문적
```

3. **이미지 생성 후**:
   - 다운로드
   - 파일명을 `icon.png`로 변경
   - `assets/icons/` 폴더에 저장

---

### 옵션 2: Microsoft Designer (무료, 로그인 필요)

1. **접속**: https://designer.microsoft.com

2. **프롬프트**:
```
Modern minimalist Bible meditation app icon, 1024x1024px.
Deep indigo blue background (#1A237E), golden cross in center (#FFC107),
subtle white notebook lines at bottom, small bookmark accent.
Flat design, no text, rounded corners on cross. Professional and spiritual.
```

3. 생성 → 다운로드 → `icon.png`로 저장 → `assets/icons/`에 저장

---

### 옵션 3: SVG 템플릿 사용 (즉시 사용 가능)

이미 `icon_template.svg` 파일이 준비되어 있습니다!

#### SVG를 PNG로 변환:

**방법 A - 온라인 변환** (가장 쉬움)
1. https://cloudconvert.com/svg-to-png 접속
2. `icon_template.svg` 업로드
3. 너비/높이를 1024px로 설정
4. 변환 후 다운로드
5. `icon.png`로 저장 → `assets/icons/`에 저장

**방법 B - Figma 사용**
1. https://figma.com 접속
2. 새 파일 생성
3. File → Import → `icon_template.svg` 선택
4. 아이콘 선택 후 우측 패널에서 Export
5. Format: PNG, Size: 1x (1024x1024)
6. Export → `icon.png`로 저장

**방법 C - Inkscape (무료 데스크톱 앱)**
```bash
# macOS (Homebrew 필요)
brew install --cask inkscape

# 변환 명령어
inkscape icon_template.svg --export-type=png --export-width=1024 --export-filename=icon.png
```

---

## 🎨 SVG 색상 커스터마이징

`icon_template.svg` 파일을 텍스트 에디터로 열어 색상 변경:

```xml
<!-- 배경색 변경 -->
<rect width="1024" height="1024" fill="#YOUR_COLOR"/>

<!-- 십자가 색상 변경 -->
<rect ... fill="#YOUR_COLOR"/>
```

### 추천 색상 조합:

#### 조합 1: 퍼플 + 화이트
- 배경: `#5E35B1`
- 십자가: `#FFFFFF`

#### 조합 2: 네이비 + 틸
- 배경: `#263238`
- 십자가: `#80CBC4`

#### 조합 3: 다크 블루 + 골드 (기본)
- 배경: `#1A237E`
- 십자가: `#FFC107`

---

## 🔧 아이콘 설치 (PNG 준비 완료 후)

1. **의존성 설치**:
```bash
flutter pub get
```

2. **아이콘 생성**:
```bash
flutter pub run flutter_launcher_icons
```

3. **앱 재빌드**:
```bash
flutter clean
flutter run
```

4. **확인**: 디바이스/에뮬레이터의 홈 화면에서 앱 아이콘 확인

---

## ✅ 체크리스트

- [ ] `icon.png` 파일이 `assets/icons/`에 있음 (1024x1024px)
- [ ] `flutter pub get` 실행 완료
- [ ] `flutter pub run flutter_launcher_icons` 실행 완료
- [ ] 오류 없이 완료됨
- [ ] `flutter clean && flutter run` 실행
- [ ] 홈 화면에서 새 아이콘 확인

---

## ❓ 도움이 필요하면

- 상세 가이드: `ICON_DESIGN_GUIDE.md` 참조
- 설치 가이드: `README.md` 참조
- 문제 해결: `README.md`의 "문제 해결" 섹션 참조

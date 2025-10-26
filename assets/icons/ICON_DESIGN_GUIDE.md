# 성경묵상노트 앱 아이콘 디자인 가이드

## 디자인 컨셉: 십자가 + 노트

### 디자인 요소
- **주요 심볼**: 모던하고 단순화된 십자가
- **보조 요소**: 노트 페이지 또는 필기 라인
- **스타일**: 미니멀, 모던, 영적이면서도 접근하기 쉬운 느낌

### 색상 팔레트

#### 옵션 1: 딥 블루 + 골드
- 배경: #1A237E (인디고 다크) 또는 #0D47A1 (블루 다크)
- 십자가: #FFC107 (골드/엠버) 또는 #FFFFFF (화이트)
- 노트 라인: #64B5F6 (라이트 블루) 또는 화이트 50% 투명도

#### 옵션 2: 퍼플 그라디언트
- 배경: 그라디언트 (#5E35B1 → #7E57C2)
- 십자가: #FFFFFF (화이트)
- 노트 라인: 화이트 70% 투명도

#### 옵션 3: 차분한 네이비 + 실버
- 배경: #263238 (블루 그레이 다크)
- 십자가: #CFD8DC (블루 그레이 라이트)
- 포인트: #80CBC4 (틸 라이트)

### 디자인 사양
- **해상도**: 1024x1024px (마스터 파일)
- **포맷**: PNG (투명 배경 아님, 사각형 배경)
- **여백**: 아이콘 주변 약 10-15% 세이프존 유지
- **라운드 코너**: iOS/Android에서 자동 적용되므로 사각형으로 디자인

---

## AI 이미지 생성 프롬프트

### DALL-E / Midjourney / ChatGPT 프롬프트

```
Create a modern, minimalist mobile app icon for a Bible meditation and note-taking app.
The design should feature:

Main elements:
- A simple, elegant cross symbol in the center
- Subtle notebook or journal elements (like horizontal lines or a page corner)
- Clean, spiritual aesthetic that feels contemporary and accessible

Style:
- Flat design with minimal depth
- Geometric shapes
- Professional and serene atmosphere
- Size: 1024x1024 pixels, square format

Color scheme (choose one):
Option 1: Deep indigo blue background (#1A237E) with golden/amber cross (#FFC107) and white accent lines
Option 2: Purple gradient background (#5E35B1 to #7E57C2) with white cross and subtle line details
Option 3: Navy blue-grey background (#263238) with light blue-grey cross (#CFD8DC) and teal accents (#80CBC4)

Important:
- No text or letters
- No transparency (solid background)
- Leave 10% safe zone margin around edges
- Icon should be clearly visible at small sizes (60x60px)
```

### 한국어 프롬프트 (ChatGPT/DALL-E)

```
성경 묵상 및 노트 작성 앱을 위한 현대적이고 미니멀한 모바일 앱 아이콘을 만들어주세요.

디자인 요소:
- 중앙에 단순하고 우아한 십자가 심볼
- 노트나 저널을 연상시키는 요소 (수평선 또는 페이지 모서리)
- 깔끔하고 영적이면서도 현대적이고 접근하기 쉬운 느낌

스타일:
- 플랫 디자인, 최소한의 입체감
- 기하학적 형태
- 전문적이고 고요한 분위기
- 크기: 1024x1024 픽셀, 정사각형

색상 (하나 선택):
옵션 1: 짙은 남색 배경 (#1A237E)에 금색 십자가 (#FFC107)와 흰색 라인
옵션 2: 보라색 그라디언트 배경 (#5E35B1에서 #7E57C2)에 흰색 십자가
옵션 3: 네이비 블루그레이 배경 (#263238)에 연한 블루그레이 십자가 (#CFD8DC)

주의사항:
- 텍스트나 글자 없음
- 투명 배경 없음 (단색 배경 필요)
- 가장자리에서 10% 여백 유지
- 작은 크기(60x60px)에서도 명확하게 보여야 함
```

---

## Canva로 직접 디자인하기

1. **Canva.com** 접속 및 로그인
2. "사용자 지정 크기" 선택 → 1024 x 1024 px
3. 배경 색상 설정 (위의 색상 팔레트 참조)
4. 십자가 만들기:
   - 두 개의 직사각형으로 십자가 형태 구성
   - 또는 "요소" → "십자가" 검색하여 심플한 아이콘 사용
5. 노트 라인 추가:
   - 가는 수평선 2-3개를 십자가 아래나 배경에 배치
   - 투명도 조절로 은은하게 표현
6. 다운로드:
   - 파일 형식: PNG
   - 품질: 최고

---

## Figma로 직접 디자인하기

1. **Figma.com** 접속
2. 새 파일 생성 → 프레임 1024x1024px
3. 배경 레이어에 색상 적용
4. 십자가 디자인:
   ```
   수직 막대: 60px × 240px (중앙 정렬)
   수평 막대: 180px × 60px (중앙 정렬, 상단에서 85px)
   라운드 코너: 8-12px
   ```
5. 노트 라인 추가:
   - 선 두께: 2-3px
   - 간격: 20-30px
   - 투명도: 30-50%
6. Export:
   - 포맷: PNG
   - 스케일: 1x

---

## 온라인 아이콘 제너레이터 사용

### 추천 도구:
- **IconKitchen** (icon.kitchen) - 간단한 조작으로 앱 아이콘 생성
- **Appicon.co** - 템플릿 기반 아이콘 생성
- **Figma Community** - 무료 아이콘 템플릿 검색

---

## 완성 후 파일 저장 위치

생성한 아이콘 이미지를 다음 위치에 저장하세요:

```
assets/icons/icon.png  (1024x1024px)
```

저장 후 터미널에서 다음 명령어 실행:
```bash
flutter pub get
flutter pub run flutter_launcher_icons
```

이 명령어가 자동으로 iOS와 Android의 모든 필요한 아이콘 크기를 생성합니다.

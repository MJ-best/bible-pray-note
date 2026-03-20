# Artifact Flow MVP

`project_goal` 하나를 입력하면 다섯 개의 에이전트가 순서대로 산출물을 만드는 workflow-first Flutter web MVP입니다. 현재 저장소는 Supabase schema blueprint와 Flutter app skeleton을 함께 관리하는 구조로 재정리되었습니다.

## 포함 범위

- Google OAuth 로그인 자리와 Supabase 초기화
- 워크스페이스 선택
- 프로젝트 생성과 goal 기반 workflow 실행
- orchestrator -> PM -> system designer -> Flutter -> QA 파이프라인 시각화
- 산출물 목록, 상세 뷰어, 실행 로그
- Supabase schema/RLS migration과 에이전트 blueprint 문서

## 앱 구조

```text
lib/
  core/
    config/
    layout/
    theme/
    widgets/
  features/
    auth/
    workspace/
    projects/
    agents/
    chat/
    artifacts/
    settings/
  shared/
    constants/
    models/
    utils/
  l10n/
```

## 실행

```bash
flutter pub get
flutter gen-l10n
flutter analyze
flutter test
flutter run -d chrome
```

Supabase를 실제로 연결하려면 다음 `dart-define` 값을 넣습니다.

```bash
flutter run -d chrome \
  --dart-define=SUPABASE_URL=YOUR_URL \
  --dart-define=SUPABASE_ANON_KEY=YOUR_KEY
```

값이 없으면 앱은 mock backend로 동작하며 workflow UI와 상태 흐름을 바로 확인할 수 있습니다.

## 관련 산출물

- Flutter skeleton: `lib/**`
- Agent blueprint: `blueprints/multi_agent_vibe_mvp/**`
- Supabase schema/RLS: `supabase/migrations/**`

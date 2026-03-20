# Progress

## 2026-03-20 Multi-Agent MVP 재구성

- 서브에이전트 역할을 세 갈래로 분리했습니다.
  - Supabase/RLS hardening
  - Flutter app skeleton
  - Agent blueprint and workflow contract
- Supabase는 base migration 위에 hardening migration과 운영 README를 추가했습니다.
- Blueprint는 agent registry, workflow contract, artifact schemas, example workflow를 기준 문서로 정리했습니다.
- Flutter 앱은 workflow-first MVP를 목표로 새 구조로 다시 세우고 있습니다.

## 현재 동작 목표

- 비로그인 사용자는 `/login`으로 이동
- 로그인 후 워크스페이스 선택 전에는 `/workspaces`로 이동
- 프로젝트 goal 실행 시 orchestrator -> PM -> system designer -> Flutter -> QA 순서로 진행
- 실패 시 partial artifact를 유지하고 로그에 남김

## 다음 확인 항목

- `flutter analyze`
- `flutter test`
- mock mode와 Supabase mode 전환 확인
- artifact viewer와 project workflow route 회귀 확인

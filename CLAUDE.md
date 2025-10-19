# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**성경묵상노트 (Bible Meditation Notes)** - A Flutter mobile application for Bible study and meditation note-taking with offline-first architecture.

### Core Features
- Automatic Bible verse reference lookup (Reformed Korean, NIV)
- Bible keyword search across entire scripture database
- Structured meditation note templates (Word, Thoughts, Notes, Prayer)
- Offline-first with embedded Bible data
- Note sharing (text/image format)
- Auto-timestamping for entries

### Target Platforms
- iOS and Android (Flutter framework)
- Dark/Light mode support
- Portrait and landscape orientation support

## Architecture Standards

This project follows the guidelines in `Flutter Development Agents.md`. Key architectural decisions:

### Directory Structure (MVVM-inspired)
```
lib/
├── data/          # APIs, databases, data sources
├── domain/        # Business logic, entities, repositories
├── presentation/  # UI, widgets, ViewModels
└── core/          # Utilities, constants, theme
```

### Required Patterns
- **MVVM Pattern**: Strict separation of View (UI), ViewModel (state/logic), Repository (data)
- **Repository Pattern**: All data access through repository interfaces
- **One-way Data Flow**: Data flows from source → ViewModel → View only
- **Immutable Data Models**: Prevent unintended state mutations

### State Management
- Widget-local: `StatefulWidget` for simple contained state
- Screen-level: `ChangeNotifier` with `Provider`
- App-wide: `Provider`, `Riverpod`, or `Bloc` for global state

### Dependency Injection
Use `provider` package (or `get_it`) - avoid direct global access

### Navigation
Prefer declarative routing: `go_router` or `auto_route`

## Development Commands

### Linting & Analysis
```bash
flutter analyze
```

### Running Tests
```bash
# All tests
flutter test

# Single test file
flutter test test/path/to/test_file.dart

# With coverage
flutter test --coverage
```

### Code Generation (if using freezed/built_value)
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Dependency Management
```bash
# Check outdated packages
flutter pub outdated

# Update dependencies
flutter pub upgrade
```

## Code Standards

### Linting Configuration
Must include `flutter_lints` in `analysis_options.yaml`:
```yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    prefer_final_locals: true
    sort_constructors_first: true
```

### Naming Conventions
- Classes: `UpperCamelCase`
- Functions/variables: `lowerCamelCase`
- Constants: `SCREAMING_SNAKE_CASE`
- Private members: `_underscorePrefix`
- Files: `snake_case.dart`

### Documentation
- Use `///` for all public APIs
- Document parameters, return values, errors, and include usage examples

### Development Workflow
- **After completing a feature**: Document progress in `Progress.md`
  - Record what was implemented
  - Note any decisions made or issues encountered
  - Update implementation status

### Commit Messages
Follow Conventional Commits:
```
<type>[optional scope]: <description>

[optional body]
```
Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

## Critical Implementation Requirements

### Offline Bible Data
- Embed complete Bible text (Reformed Korean + NIV) in app
- Use efficient searchable format (likely SQLite or similar)
- Support verse lookup by reference (e.g., "마태복음 1:13", "창 1:1")
- Support full-text keyword search across all verses

### Internationalization
Configure from project start using `flutter_localizations` and `intl`:
- Structure with ARB files
- Manage locales in `l10n.yaml`
- Korean as primary language

### Accessibility Requirements
- Semantic labels for all interactive widgets
- Minimum 44x44 touch targets
- Follow color contrast requirements

### Security
- Never hardcode sensitive data in code
- Omit sensitive information from logs
- Use secure storage for any user data

## Testing Strategy

Follow test pyramid approach:
- **Unit tests**: Business logic, models, repositories
- **Widget tests**: UI rendering and interactions
- **Integration tests**: End-to-end flows
- Mock all dependencies in unit/widget tests
- All tests must pass before merge (CI/CD requirement)

## Performance Guidelines

- Use `const` constructors wherever possible
- Limit rebuild areas with `RepaintBoundary`
- Use lazy loading widgets (`ListView.builder`)
- Properly dispose: `ChangeNotifier`, streams, controllers, timers
- Regular profiling with Flutter DevTools

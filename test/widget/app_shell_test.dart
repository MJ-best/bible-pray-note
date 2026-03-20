import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:artifact_flow/features/auth/application/auth_controller.dart';
import '../helpers/test_app.dart';

void main() {
  testWidgets('redirects signed-out users to login', (tester) async {
    await tester.pumpWidget(buildTestApp(initialLocation: '/dashboard'));
    await tester.pumpAndSettle();

    expect(find.text('Workflow-first agent platform'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
  });

  testWidgets('sign-in leads to dashboard', (tester) async {
    await tester.pumpWidget(buildTestApp(initialLocation: '/login'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continue with Google'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();

    expect(find.text('Start a new execution'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Recent workflow runs'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Recent workflow runs'), findsOneWidget);
  });

  testWidgets('project detail shows workflow pipeline and artifacts', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(
        initialLocation: '/projects/project-alpha',
        authController: AuthController.authenticated(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Workflow pipeline'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Plan workflow'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Plan workflow'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Artifacts'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Artifacts'), findsOneWidget);
    expect(find.text('PRD'), findsOneWidget);
  });

  testWidgets('artifact viewer renders seeded artifact content', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(
        initialLocation: '/projects/project-alpha/artifacts/artifact-prd',
        authController: AuthController.authenticated(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('PRD'), findsOneWidget);
    expect(find.textContaining('Product Requirement Document'), findsOneWidget);
  });
}

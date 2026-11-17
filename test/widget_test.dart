import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:assignment_two_flutter_ui/main.dart';

Future<void> openApp(WidgetTester tester) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(const CampusFlowApp());
}
Future<void> tab(WidgetTester tester, String name) async {
  await tester.tap(find.byKey(Key('nav_$name')));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('All four pages open through click navigation', (tester) async {
    await openApp(tester);
    expect(find.text('Md. Fayshal'), findsOneWidget);
    expect(find.text('MF'), findsOneWidget);
    expect(find.byType(PageView), findsOneWidget);
    await tab(tester, 'tasks');
    expect(find.byKey(const Key('task_search')), findsOneWidget);
    await tab(tester, 'profile');
    expect(find.text('2220067@iub.edu.bd'), findsOneWidget);
    expect(find.text('Student ID'), findsOneWidget);
    await tab(tester, 'progress');
    expect(find.text('Courses'), findsOneWidget);
    await tab(tester, 'home');
    expect(find.text('Md. Fayshal'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Task completion is reflected in Progress', (tester) async {
    await openApp(tester);
    await tab(tester, 'tasks');
    await tester.tap(find.byKey(const Key('task_1')));
    await tester.pumpAndSettle();
    expect(tester.widget<Checkbox>(find.byKey(const Key('task_1'))).value, isTrue);
    await tab(tester, 'progress');
    expect(find.text('15'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Search filters tasks and add task updates the list', (tester) async {
    await openApp(tester);
    await tab(tester, 'tasks');
    await tester.enterText(find.byKey(const Key('task_search')), 'Normalization');
    await tester.pumpAndSettle();
    expect(find.text('Read chapter 7: Normalization'), findsOneWidget);
    expect(find.text('Watch lecture 9'), findsNothing);
    await tester.enterText(find.byKey(const Key('task_search')), '');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('add_task')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('task_title_input')), 'Prepare demo');
    await tester.enterText(find.byKey(const Key('task_course_input')), 'CSE 464');
    await tester.tap(find.byKey(const Key('save_task_button')));
    await tester.pumpAndSettle();
    expect(find.text('Prepare demo'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Profile edits update the greeting and avatar', (tester) async {
    await openApp(tester);
    await tab(tester, 'profile');
    await tester.tap(find.byTooltip('Edit profile'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('profile_0')), 'Fayshal Ahmed');
    await tester.ensureVisible(find.byKey(const Key('save_profile')));
    await tester.tap(find.byKey(const Key('save_profile')));
    await tester.pumpAndSettle();
    await tab(tester, 'home');
    expect(find.text('Fayshal Ahmed'), findsOneWidget);
    expect(find.text('FA'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

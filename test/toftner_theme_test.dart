import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toftner_theme/toftner_theme.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('Toftner, as the phone, at first; a choice is kept', () async {
    var choice = await ThemeChoice.load();
    expect(choice.theme, AppTheme.toftner);
    expect(choice.mode, ThemeMode.system);
    await choice.setTheme(AppTheme.blue);
    await choice.setMode(ThemeMode.dark);
    choice = await ThemeChoice.load();
    expect(choice.theme, AppTheme.blue);
    expect(choice.mode, ThemeMode.dark);
    expect(choice.dark.colorScheme.brightness, Brightness.dark);
  });

  test('an unknown saved theme falls back to Toftner', () async {
    SharedPreferences.setMockInitialValues({ThemeChoice.themeKey: 'gone', ThemeChoice.modeKey: 'nonsense'});
    final choice = await ThemeChoice.load();
    expect(choice.theme, AppTheme.toftner);
    expect(choice.mode, ThemeMode.system);
  });

  testWidgets('the settings change the theme and appearance', (tester) async {
    final choice = ThemeChoice();
    var changes = 0;
    choice.addListener(() => changes++);
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: ThemeSettings(choice: choice))));
    await tester.tap(find.byKey(const Key('theme_purple')));
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();
    expect(choice.theme, AppTheme.purple);
    expect(choice.mode, ThemeMode.dark);
    expect(changes, 2);
    expect(find.byIcon(Icons.check), findsOneWidget); // the chosen swatch
  });
}

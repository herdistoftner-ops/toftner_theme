# toftner_theme

The look shared by the toftner.app apps (Food Scanner first; WhenToGo and
the others later), so a change here reaches every app.

- **Themes**: *Toftner* (the default: peach `#FFB68D` and brown `#5C4131`,
  as the apps' icons and toftner.app), *Green*, *Blue* and *Purple*. Each
  is Material 3 made from one colour, for light and for dark.
- **Appearance**: as the phone, light or dark.
- The user's choice is kept on the device (shared_preferences keys
  `look_theme` and `look_mode`); nothing leaves it.
- `ThemeSettings`: the choices for an app's settings, with English words by
  default and `ThemeSettingsText.norwegian`.

Colours that mean something in an app (Food Scanner's red, orange and green
verdicts, WhenToGo's line colours) stay the app's own and never follow the
theme.

## Use

In the app's `pubspec.yaml` (from `C:\Projects\<app>\<app>`):

```yaml
dependencies:
  toftner_theme:
    path: ../../toftner_theme
```

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final looks = await ThemeChoice.load();
  runApp(ListenableBuilder(
    listenable: looks,
    builder: (context, _) => MaterialApp(
      theme: looks.light,
      darkTheme: looks.dark,
      themeMode: looks.mode,
      home: ...,
    ),
  ));
}
```

and in the settings screen `ThemeSettings(choice: looks)`.

## Test

```sh
flutter test
```

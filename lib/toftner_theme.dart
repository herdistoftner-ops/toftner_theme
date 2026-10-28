/// The look shared by the toftner.app apps: the Toftner theme (peach and
/// brown, as the apps' icons and toftner.app), three others the user can
/// choose instead, and light, dark or as the phone. The choice is kept on
/// the device.
///
/// In an app:
///
/// ```dart
/// final looks = await ThemeChoice.load();
/// runApp(ListenableBuilder(
///   listenable: looks,
///   builder: (_, _) => MaterialApp(
///     theme: looks.light, darkTheme: looks.dark, themeMode: looks.mode, ...
///   ),
/// ));
/// ```
///
/// and in its settings `ThemeSettings(choice: looks)`.
library;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Peach and brown: the apps' icons and toftner.app.
const toftnerPeach = Color(0xFFFFB68D);
const toftnerBrown = Color(0xFF5C4131);

/// The themes to choose from; each is made from one colour (Material 3
/// works out the rest, for light and for dark).
enum AppTheme {
  toftner(toftnerPeach),
  green(Color(0xFF2E7D32)),
  blue(Color(0xFF1E64C8)),
  purple(Color(0xFF7346B4));

  final Color seed;

  const AppTheme(this.seed);

  /// [name] as saved, or null if it is not a theme (any more).
  static AppTheme? byName(Object? name) => values.where((t) => t.name == name).firstOrNull;
}

/// [theme] for [brightness].
ThemeData appThemeData(AppTheme theme, Brightness brightness) => ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: theme.seed, brightness: brightness),
      useMaterial3: true,
    );

/// The user's theme and light/dark choice, kept on the device; tells
/// listeners (the app) when it changes.
class ThemeChoice extends ChangeNotifier {
  static const themeKey = 'look_theme';
  static const modeKey = 'look_mode';

  AppTheme _theme;
  ThemeMode _mode;

  ThemeChoice({AppTheme theme = AppTheme.toftner, ThemeMode mode = ThemeMode.system})
      : _theme = theme,
        _mode = mode;

  /// The saved choice: the Toftner theme, as the phone, at first.
  static Future<ThemeChoice> load() async {
    final prefs = await SharedPreferences.getInstance();
    return ThemeChoice(
      theme: AppTheme.byName(prefs.getString(themeKey)) ?? AppTheme.toftner,
      mode: ThemeMode.values.where((m) => m.name == prefs.getString(modeKey)).firstOrNull ?? ThemeMode.system,
    );
  }

  AppTheme get theme => _theme;
  ThemeMode get mode => _mode;
  ThemeData get light => appThemeData(_theme, Brightness.light);
  ThemeData get dark => appThemeData(_theme, Brightness.dark);

  Future<void> setTheme(AppTheme theme) async {
    if (theme == _theme) return;
    _theme = theme;
    notifyListeners();
    await (await SharedPreferences.getInstance()).setString(themeKey, theme.name);
  }

  Future<void> setMode(ThemeMode mode) async {
    if (mode == _mode) return;
    _mode = mode;
    notifyListeners();
    await (await SharedPreferences.getInstance()).setString(modeKey, mode.name);
  }
}

/// The words of [ThemeSettings], so each app can give its own language.
class ThemeSettingsText {
  final String theme;
  final String appearance;
  final String system;
  final String light;
  final String dark;
  final Map<AppTheme, String> names;

  const ThemeSettingsText({
    this.theme = 'Theme',
    this.appearance = 'Appearance',
    this.system = 'As the phone',
    this.light = 'Light',
    this.dark = 'Dark',
    this.names = const {
      AppTheme.toftner: 'Toftner',
      AppTheme.green: 'Green',
      AppTheme.blue: 'Blue',
      AppTheme.purple: 'Purple',
    },
  });

  /// In Norwegian (bokmål).
  static const norwegian = ThemeSettingsText(
    theme: 'Tema',
    appearance: 'Utseende',
    system: 'Som telefonen',
    light: 'Lyst',
    dark: 'Mørkt',
    names: {
      AppTheme.toftner: 'Toftner',
      AppTheme.green: 'Grønn',
      AppTheme.blue: 'Blå',
      AppTheme.purple: 'Lilla',
    },
  );
}

/// The theme and appearance choices, for an app's settings: a swatch per
/// theme (its own colour, ticked when chosen), and As the phone · Light ·
/// Dark.
class ThemeSettings extends StatelessWidget {
  final ThemeChoice choice;
  final ThemeSettingsText text;

  const ThemeSettings({super.key, required this.choice, this.text = const ThemeSettingsText()});

  @override
  Widget build(BuildContext context) {
    final muted = TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant);
    return ListenableBuilder(
      listenable: choice,
      builder: (context, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(text.theme, style: muted),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [for (final t in AppTheme.values) _Swatch(theme: t, label: text.names[t] ?? t.name, choice: choice)],
          ),
          const SizedBox(height: 16),
          Text(text.appearance, style: muted),
          const SizedBox(height: 8),
          SegmentedButton<ThemeMode>(
            key: const Key('appearance'),
            showSelectedIcon: false,
            segments: [
              ButtonSegment(value: ThemeMode.system, label: Text(text.system)),
              ButtonSegment(value: ThemeMode.light, label: Text(text.light)),
              ButtonSegment(value: ThemeMode.dark, label: Text(text.dark)),
            ],
            selected: {choice.mode},
            onSelectionChanged: (s) => choice.setMode(s.first),
          ),
        ],
      ),
    );
  }
}

/// One theme to choose: a circle in its colours (light and dark halves) and
/// its name below.
class _Swatch extends StatelessWidget {
  final AppTheme theme;
  final String label;
  final ThemeChoice choice;

  const _Swatch({required this.theme, required this.label, required this.choice});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final light = ColorScheme.fromSeed(seedColor: theme.seed);
    final chosen = choice.theme == theme;
    return Semantics(
      button: true,
      selected: chosen,
      label: label,
      child: InkWell(
        key: Key('theme_${theme.name}'),
        borderRadius: BorderRadius.circular(12),
        onTap: () => choice.setTheme(theme),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: chosen ? scheme.onSurface : scheme.outlineVariant, width: chosen ? 3 : 1),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: const [0.5, 0.5],
                    colors: [light.primaryContainer, light.primary],
                  ),
                ),
                child: chosen ? Icon(Icons.check, color: light.onPrimary, size: 22) : null,
              ),
              const SizedBox(height: 4),
              ExcludeSemantics(child: Text(label, style: const TextStyle(fontSize: 12))),
            ],
          ),
        ),
      ),
    );
  }
}

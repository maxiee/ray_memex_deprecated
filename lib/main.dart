import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:ray_memex/base/commons.dart';
import 'package:ray_memex/host/router.dart';
import 'package:ray_memex/theme.dart';
import 'package:ray_memex/utils/utils.dart';
import 'package:system_theme/system_theme.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart' as flutter_acrylic;
import 'package:window_manager/window_manager.dart';

final _appTheme = AppTheme();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if ([TargetPlatform.windows, TargetPlatform.android]
      .contains(defaultTargetPlatform)) {
    SystemTheme.accentColor.load();
  }

  if (isDesktop) {
    await flutter_acrylic.Window.initialize();
    // await flutter_acrylic.Window.hideWindowControls();
    await WindowManager.instance.ensureInitialized();
    windowManager.waitUntilReadyToShow().then((value) async {
      await windowManager.setMinimumSize(const Size(500, 600));
      await windowManager.show();
      await windowManager.setSkipTaskbar(false);
    });
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: _appTheme,
        builder: (context, child) {
          final appTheme = context.watch<AppTheme>();
          return FluentApp.router(
              title: appTitle,
              themeMode: appTheme.mode,
              debugShowCheckedModeBanner: false,
              color: appTheme.color,
              darkTheme: FluentThemeData(
                  brightness: Brightness.dark,
                  accentColor: appTheme.color,
                  visualDensity: VisualDensity.standard,
                  focusTheme: FocusThemeData(
                      glowFactor: is10footScreen(context) ? 2.0 : 0.0)),
              theme: FluentThemeData(
                  accentColor: appTheme.color,
                  visualDensity: VisualDensity.standard,
                  focusTheme: FocusThemeData(
                      glowFactor: is10footScreen(context) ? 2.0 : 0.0)),
              locale: appTheme.locale,
              builder: (context, child) {
                return Directionality(
                    textDirection: appTheme.textDirection,
                    child: NavigationPaneTheme(
                      data: NavigationPaneThemeData(
                          backgroundColor: appTheme.windowEffect !=
                                  flutter_acrylic.WindowEffect.disabled
                              ? Colors.transparent
                              : null),
                      child: child!,
                    ));
              },
              routeInformationParser: router.routeInformationParser,
              routerDelegate: router.routerDelegate,
              routeInformationProvider: router.routeInformationProvider);
        });
  }
}

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ray_memex/theme.dart';
import 'package:system_theme/system_theme.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart' as flutter_acrylic;
import 'package:window_manager/window_manager.dart';

const String appTitle = 'RayMemex';

final _appTheme = AppTheme();

/// Checks if the current environment is a desktop environment.
bool get isDesktop {
  if (kIsWeb) return false;
  return [
    TargetPlatform.windows,
    TargetPlatform.linux,
    TargetPlatform.macOS,
  ].contains(defaultTargetPlatform);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb &&
      [TargetPlatform.windows, TargetPlatform.android]
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
      await windowManager.setPreventClose(true);
      await windowManager.setSkipTaskbar(false);
    });
  }

  runApp(const MyApp());
}

final rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(navigatorKey: rootNavigatorKey, routes: [
  ShellRoute(
      navigatorKey: _shellNavigatorKey,
      // 创建首页框架
      builder: ((context, state, child) {
        return MyHomePage(
            shellContext: _shellNavigatorKey.currentContext, child: child);
      }),
      routes: [
        /// Home
        GoRoute(path: '/', builder: (context, state) => const Placeholder())
      ])
]);

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

class MyHomePage extends StatefulWidget {
  const MyHomePage(
      {super.key, required this.child, required this.shellContext});

  final Widget child;
  final BuildContext? shellContext;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final viewKey = GlobalKey(debugLabel: 'Navigation View key');
  final searchKey = GlobalKey(debugLabel: 'Search bar key');
  final searchFocusNode = FocusNode();
  final searchController = TextEditingController();

  late final List<PaneItem> originalItems = [
    PaneItem(
        key: const ValueKey('/'),
        icon: const Icon(FluentIcons.home),
        body: const SizedBox.shrink()),
    PaneItem(
        key: const ValueKey('/books'),
        title: const Text('书籍'),
        icon: const Icon(FluentIcons.book_answers),
        body: const SizedBox.shrink())
  ].map((e) {
    // ignore: unnecessary_type_check
    if (e is PaneItem) {
      return PaneItem(
          key: e.key,
          icon: e.icon,
          title: e.title,
          body: e.body,
          onTap: () {
            final path = (e.key as ValueKey).value as String;
            if (GoRouterState.of(context).uri.toString() != path) {
              context.go(path);
            }
            e.onTap?.call();
          });
    }
    return e;
  }).toList();

  late final List<PaneItem> footerItems = [
    PaneItem(
        key: const ValueKey('/settings'),
        icon: const Icon(FluentIcons.settings),
        body: const SizedBox.shrink(),
        onTap: () {
          if (GoRouterState.of(context).uri.toString() != '/settings') {
            context.go('/settings');
          }
        })
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = FluentLocalizations.of(context);
    final appTheme = context.watch<AppTheme>();
    final theme = FluentTheme.of(context);
    if (widget.shellContext != null) {
      if (router.canPop() == false) {
        setState(() {});
      }
    }

    return NavigationView(
        key: viewKey,
        appBar: NavigationAppBar(
          automaticallyImplyLeading: false,
          leading: () {
            final enabled = widget.shellContext != null && router.canPop();
            final onPressed = enabled
                ? () {
                    if (router.canPop()) {
                      context.pop();
                      setState(() {});
                    }
                  }
                : null;
            return NavigationPaneTheme(
                data: NavigationPaneTheme.of(context).merge(
                    NavigationPaneThemeData(
                        unselectedIconColor: ButtonState.resolveWith((states) {
                  if (states.isDisabled) {
                    return ButtonThemeData.buttonColor(context, states);
                  }
                  return ButtonThemeData.uncheckedInputColor(
                          FluentTheme.of(context), states)
                      .basedOnLuminance();
                }))),
                child: Builder(
                    builder: (context) => PaneItem(
                          icon: const Center(
                              child: Icon(FluentIcons.back, size: 12.0)),
                          title: Text(localizations.backButtonTooltip),
                          body: const SizedBox.shrink(),
                          enabled: enabled,
                        ).build(context, false, onPressed,
                            displayMode: PaneDisplayMode.compact)));
          }(),
          title: const Text(appTitle),
          actions: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8.0),
                  child: ToggleSwitch(
                      content: const Text('Dark'),
                      checked: false, // todo
                      onChanged: (value) {
                        // todo
                      }),
                ),
              )
            ],
          ),
        ),
        paneBodyBuilder: (item, child) {
          final name =
              item?.key is ValueKey ? (item!.key as ValueKey).value : null;
          return FocusTraversalGroup(
              key: ValueKey('body$name'), child: widget.child);
        },
        pane: NavigationPane(
            selected: _calculateSelectedIndex(context),
            header: SizedBox(
              height: kOneLineTileHeight,
              child: ShaderMask(
                shaderCallback: (rect) {
                  final color =
                      appTheme.color.defaultBrushFor(theme.brightness);
                  return LinearGradient(colors: [color, color])
                      .createShader(rect);
                },
              ),
            ),
            displayMode: appTheme.displayMode,
            indicator: () {
              switch (appTheme.indicator) {
                case NavigationIndicators.end:
                  return const EndNavigationIndicator();
                case NavigationIndicators.sticky:
                  return const StickyNavigationIndicator();
                default:
                  return const StickyNavigationIndicator();
              }
            }(),
            items: originalItems,
            footerItems: footerItems));
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    int indexOriginal = originalItems
        .where((item) => item.key != null)
        .toList()
        .indexWhere((item) => item.key == Key(location));

    if (indexOriginal == -1) {
      int indexFooter = footerItems
          .where((element) => element.key != null)
          .toList()
          .indexWhere((element) => element.key == Key(location));
      if (indexFooter == -1) {
        return 0;
      }
      return originalItems
              .where((element) => element.key != null)
              .toList()
              .length +
          indexFooter;
    } else {
      return indexOriginal;
    }
  }
}

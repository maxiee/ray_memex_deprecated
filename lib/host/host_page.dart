import 'package:fluent_ui/fluent_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ray_memex/base/commons.dart';
import 'package:ray_memex/host/router.dart';
import 'package:ray_memex/theme.dart';

class HostPage extends StatefulWidget {
  const HostPage({super.key, required this.child, required this.shellContext});

  final Widget child;
  final BuildContext? shellContext;

  @override
  State<HostPage> createState() => _HostPageState();
}

class _HostPageState extends State<HostPage> {
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

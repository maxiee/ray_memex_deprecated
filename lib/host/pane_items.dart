import 'package:fluent_ui/fluent_ui.dart';
import 'package:go_router/go_router.dart';

List<NavigationPaneItem> getSidebarItems(BuildContext context) {
  return [
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
}

List<PaneItem> getSidebarFooterItems(BuildContext context) {
  return [
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
}

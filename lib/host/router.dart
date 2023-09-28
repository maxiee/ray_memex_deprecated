import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:ray_memex/host/host_page.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(navigatorKey: rootNavigatorKey, routes: [
  ShellRoute(
      navigatorKey: _shellNavigatorKey,
      // 创建首页框架
      builder: ((context, state, child) {
        return HostPage(
            shellContext: _shellNavigatorKey.currentContext, child: child);
      }),
      routes: [
        /// Home
        GoRoute(path: '/', builder: (context, state) => const Placeholder())
      ])
]);

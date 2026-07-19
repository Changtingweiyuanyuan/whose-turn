import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'screens/create_task_screen.dart';
import 'screens/home_shell.dart';
import 'screens/task_detail_screen.dart';
import 'theme/app_theme.dart';
import 'theme/shad_theme.dart';

final _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeShell()),
    GoRoute(
      path: '/task/:id',
      builder: (context, state) =>
          TaskDetailScreen(taskId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/create-task',
      builder: (context, state) => const CreateTaskScreen(),
    ),
  ],
);

class WhoseTurnApp extends StatelessWidget {
  const WhoseTurnApp({super.key});

  @override
  Widget build(BuildContext context) {
    // shadcn_ui 主題外殼 + Material Router（Scaffold/導覽仍用 Material）
    return ShadApp.custom(
      theme: AppShadTheme.light,
      darkTheme: AppShadTheme.light,
      themeMode: ThemeMode.light,
      appBuilder: (context) => MaterialApp.router(
        title: '今天換誰？',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: _router,
        // 全站文字加一點字距，緩解 Roboto Condensed 的擁擠感
        builder: (context, child) => ShadAppBuilder(
          child: DefaultTextStyle.merge(
            style: const TextStyle(letterSpacing: 0.8),
            child: child ?? const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}

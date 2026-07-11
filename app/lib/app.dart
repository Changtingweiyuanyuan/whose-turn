import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'screens/celebration_screen.dart';
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
    GoRoute(
      path: '/celebrate/:id',
      builder: (context, state) =>
          CelebrationScreen(taskId: state.pathParameters['id']!),
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
        builder: (context, child) => ShadAppBuilder(child: child),
      ),
    );
  }
}

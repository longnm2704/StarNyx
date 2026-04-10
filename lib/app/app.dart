import 'package:flutter/material.dart';
import 'package:starnyx/app/theme/app_theme.dart';
import 'package:starnyx/app/router/app_router.dart';

class StarNyxApp extends StatelessWidget {
  const StarNyxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StarNyx',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      initialRoute: AppRoutes.home,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}

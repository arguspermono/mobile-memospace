import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

import 'providers/note_provider.dart';
import 'screens/dashboard_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.initialize();

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => NoteProvider())],
      child: const MemoSpaceApp(),
    ),
  );
}

class MemoSpaceApp extends StatelessWidget {
  const MemoSpaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MemoSpace',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        quill.FlutterQuillLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'),
      ],
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFFAF9F6),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF252422),
          surface: const Color(0xFFFFFFFF),
          primary: const Color(0xFF252422),
        ),
        textTheme: const TextTheme(
          titleMedium: TextStyle(
            color: Color(0xFF252422),
            fontWeight: FontWeight.bold,
          ),
          bodyLarge: TextStyle(color: Color(0xFF252422)),
          bodyMedium: TextStyle(color: Color(0xFF252422)),
          bodySmall: TextStyle(color: Color(0xFF707070)),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFAF9F6),
          foregroundColor: Color(0xFF252422),
          elevation: 0,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF252422),
          foregroundColor: Color(0xFFFFFFFF),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: Color(0xFFEBF0F3),
          thickness: 1.5,
        ),
        cardTheme: const CardThemeData(
          color: Color(0xFFFFFFFF),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            side: BorderSide(color: Color(0xFFEBF0F3), width: 1.5),
          ),
        ),
        useMaterial3: true,
      ),
      home: const DashboardScreen(),
    );
  }
}

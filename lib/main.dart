import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nigh/constant.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'notification/firebase_message.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initSharedPrefs();
  await Firebase.initializeApp();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    ref.read(firebaseMessageProvider).initFirebase();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
          scaffoldBackgroundColor: backgroundPrimary,
          appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0, foregroundColor: themePrimary, backgroundColor: backgroundPrimary),
          colorScheme: const ColorScheme(
            brightness: Brightness.light,
            background: backgroundPrimary,
            onBackground: themeSecondary,
            primary: themePrimary,
            onPrimary: textPrimary,
            secondary: themeSecondary,
            onSecondary: textPrimary,
            surface: themePrimary,
            onSurface: textPrimary,
            error: themeSecondary,
            onError: themeSecondary,
          ),
          useMaterial3: true,
          snackBarTheme: const SnackBarThemeData(backgroundColor: themePrimary),
          textTheme: const TextTheme().apply(
            bodyColor: textPrimary,
            displayColor: textPrimary,
            decorationColor: textPrimary,
          ),
          primarySwatch: createMaterialColor(themePrimary),
          unselectedWidgetColor: textPrimary),
      home: const HomeScreen(),
    );
  }
}

MaterialColor createMaterialColor(Color color) {
  List strengths = <double>[.05];
  Map<int, Color> swatch = {};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  for (var strength in strengths) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  }
  return MaterialColor(color.value, swatch);
}

Future<void> initSharedPrefs() async {
  globalSharedPrefs = await SharedPreferences.getInstance();
}

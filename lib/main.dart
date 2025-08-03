// import 'package:flutter/material.dart';
// import 'features/auth/presentation/login_screen.dart';

// final themeModeNotifier = ValueNotifier(ThemeMode.dark);

// void main() {
//   runApp(const AppRoot());
// }

// class AppRoot extends StatelessWidget {
//   const AppRoot({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return ValueListenableBuilder<ThemeMode>(
//       valueListenable: themeModeNotifier,
//       builder: (context, mode, _) {
//         return MyApp(themeMode: mode);
//       },
//     );
//   }
// }

// class MyApp extends StatelessWidget {
//   final ThemeMode themeMode;
//   const MyApp({super.key, required this.themeMode});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'AR App',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.light),
//         useMaterial3: true,
//         brightness: Brightness.light,
//       ),
//       darkTheme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.dark),
//         useMaterial3: true,
//         brightness: Brightness.dark,
//       ),
//       themeMode: themeMode,
//       home: const LoginScreen(),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'features/auth/presentation/login_screen.dart';

// Định nghĩa themeModeNotifier toàn cục
final themeModeNotifier = ValueNotifier<ThemeMode>(ThemeMode.dark);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (context, themeMode, child) {
        return MaterialApp(
          title: 'AR App',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.light),
            useMaterial3: true,
            scaffoldBackgroundColor: Colors.white,
            appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent, elevation: 0),
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.dark),
            useMaterial3: true,
            scaffoldBackgroundColor: Colors.grey[900],
            appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent, elevation: 0),
          ),
          themeMode: themeMode,
          home: const LoginScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
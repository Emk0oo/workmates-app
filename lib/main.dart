import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:workmates/screens/createSessionScreen.dart';
import 'package:workmates/screens/loadingScreen.dart';
import 'package:workmates/screens/mainScreen.dart';
import 'package:workmates/screens/loginScreen.dart';
import 'package:workmates/screens/registerScreen.dart';

import 'data/global_data.dart' as gd;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setPortraitMode(); // Si tu veux forcer le mode portrait
  runApp(const MyApp()); // <-- Ajout essentiel
}

Future setPortraitMode() async {
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coprism',
      theme: ThemeData(
        // Background color is a light purple,
        scaffoldBackgroundColor: Colors.grey[200],
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
        // Style of the input text
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          // Border color when focused
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.deepPurpleAccent,
            ),
          ),
        ),
        // Button style
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(
              Theme.of(context).colorScheme.primary,
            ),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            // Text color
            foregroundColor: MaterialStateProperty.all<Color>(
              Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ),
      ),

      // Choisissez UNE des deux approches ci-dessous:

      // SOIT Option 1: Utilisez initialRoute et routes avec une entrée '/'
      initialRoute: '/',
      routes: {
        '/': (context) => const LoadingScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/loadingScreen': (context) => const LoadingScreen(),
        '/home': (context) => const MainScreen(),
        '/createSession': (context) => const CreateSessionScreen(),
      },

      // OU Option 2: Utilisez home sans route '/' (supprimez les 5 lignes ci-dessus)
      // home: const LoadingScreen(),
      // routes: {
      //   '/login': (context) => const LoginScreen(),
      //   '/register': (context) => const RegisterScreen(),
      //   '/loadingScreen': (context) => const LoadingScreen(),
      //   '/home': (context) => const MainScreen(),
      //   '/createSession': (context) => const CreateSessionScreen(),
      // },
    );
  }
}

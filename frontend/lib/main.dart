import 'package:first_app/screens/utils/audionotifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:first_app/screens/mainappscreen.dart';
import 'package:first_app/screens/loginscreen.dart';
import 'package:first_app/screens/utils/authprovider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';



Future<void> main() async {
   WidgetsFlutterBinding.ensureInitialized();
  print('Initializing Firebase...');
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    print('Firebase initialized successfully!');
  } catch (e) {
    print('Firebase initialization failed: $e');
  }
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
        create: (context) => AudioProvider(),
          ),
          ChangeNotifierProvider(create: (context) => DownloadProvider()), ChangeNotifierProvider(create: (context) => AuthProviderClass())
      ], 
      child: MyApp(),
    )
    
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Echotube',
        theme: ThemeData.light(),   // Light theme
        darkTheme: ThemeData.dark(), // Dark theme
        themeMode: ThemeMode.dark, 
        initialRoute: '/',
        routes: {
        '/': (context) => Consumer<AuthProviderClass>(
              builder: (context, auth, _) =>
                  auth.isSignedIn ? MainAppScreen() : LoginScreen(),
            ),
        '/home': (context) => MainAppScreen(), 
      }
    );
  }
}
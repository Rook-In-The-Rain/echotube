import 'package:first_app/screens/utils/audionotifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:first_app/screens/mainappscreen.dart';


void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
        create: (context) => AudioProvider(),
          ),
          ChangeNotifierProvider(create: (context) => DownloadProvider())
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
      title: 'Simple Flutter App with Backend and Frontend',
        theme: ThemeData.light(),   // Light theme
        darkTheme: ThemeData.dark(), // Dark theme
        themeMode: ThemeMode.dark, 
        home: MainAppScreen()
    );
  }
}
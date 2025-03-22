import 'package:first_app/screens/audioplayer.dart';
import 'package:first_app/screens/homepage.dart';
import 'package:first_app/screens/audionotifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AudioProvider(),
      child: MyApp(),
    ),
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
        initialRoute: "/",
      routes: {
        '/': (context) =>Scaffold(
          appBar: AppBar(title: Text("Home")),
          body: HomePageScreen(),
          bottomNavigationBar: SizedBox(height:108, child:AudioPlayerWidget())
        )
      },
    );
  }
}
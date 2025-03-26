import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:first_app/screens/utils/authprovider.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProviderClass>(context, listen: false);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Welcome to Echotube!", style: TextStyle(fontSize: 24)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await authProvider.signInWithGoogle();
                if (authProvider.isSignedIn) {
                  Navigator.pushReplacementNamed(context, '/home'); // Go to home
                }
              },
              child: Text("Sign in with Google"),
            ),
          ],
        ),
      ),
    );
  }
}
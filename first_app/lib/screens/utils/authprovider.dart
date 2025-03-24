import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';


class AuthProviderClass extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['https://www.googleapis.com/auth/youtube.readonly', 'https://www.googleapis.com/auth/youtube.force-ssl']);
  User? _user;
  String? _accessToken;

  AuthProviderClass() {
    _user = _auth.currentUser;
  }

  User? get user => _user;

  bool get isSignedIn => _user != null;

  Future<String?> get googleAccessToken async => getAccessToken();

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return; // User canceled sign-in

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      _accessToken = googleAuth.accessToken;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      
      _user = userCredential.user;
      notifyListeners(); // Notify UI to update
    } catch (e) {
      print("Error signing in: $e");
    }
  }

  Future<String?> getAccessToken() async {
      return _accessToken;
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    _user = null;
    notifyListeners(); // Notify UI to update
  }

  
}



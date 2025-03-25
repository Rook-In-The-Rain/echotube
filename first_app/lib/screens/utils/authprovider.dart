import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';


class AuthProviderClass extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['https://www.googleapis.com/auth/youtube.readonly', 'https://www.googleapis.com/auth/youtube.force-ssl']);
  User? _user;
  String? _accessToken;
  DateTime? _tokenExpiry;
  String? _refreshToken;

  AuthProviderClass() {
    _user = _auth.currentUser;
  }

  User? get user => _user;

  bool get isSignedIn => _user != null;

  Future<String?> get googleAccessToken async => getValidToken();
  String? get refreshToken => _refreshToken;

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
      _refreshToken = userCredential.credential?.accessToken;
      _tokenExpiry = DateTime.now().add(Duration(seconds: 3000));
      await getValidToken();

      _user = userCredential.user;
      notifyListeners(); // Notify UI to update
    } catch (e) {
      print("Error signing in: $e");
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    _user = null;
    notifyListeners(); // Notify UI to update
  }

  Future<void> updateToken(String? newToken, String? newRefreshToken, int expiresIn) async {
    _accessToken = newToken;
    _refreshToken = newRefreshToken;
    _tokenExpiry = DateTime.now().add(Duration(seconds: expiresIn - 300)); // 5 min buffer
    notifyListeners();
    
    // Sync with backend
    if (newToken != null) {
      _accessToken = newToken;
      notifyListeners();
    }
  }
  Future<String?> getValidToken() async {
    if (_accessToken == null || _tokenExpiry == null) return null;
    
    // Refresh if token expires in <5 mins
    if (_tokenExpiry!.isBefore(DateTime.now())) {
      final newToken = await _refreshTokenSilently();
      return newToken;
    }
    return _accessToken;
  }

   Future<String?> _refreshTokenSilently() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;
      
      final freshToken = await user.getIdToken(true); // Force refresh
      await updateToken(freshToken, _refreshToken, 3600); // Assume 1h expiry
      return freshToken;
    } catch (e) {
      print('Token refresh failed: $e');
      return null;
    }
  }
}



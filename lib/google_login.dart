import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

Future<void> signOutGoogleAndFirebase() async {
  await GoogleSignIn().signOut(); // Sign out from Google
  await FirebaseAuth.instance.signOut(); // Sign out from Firebase
}

Future<UserCredential?> signInWithGoogle() async {
  // Always sign out first to clear previous selection
  await signOutGoogleAndFirebase();

  final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
  if (googleUser == null) return null; // User canceled

  final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );
  final userCredential = await FirebaseAuth.instance.signInWithCredential(
    credential,
  );
  // Store username and email in Firestore (if not present)
  final user = userCredential.user;
  if (user != null) {
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'username': user.displayName ?? '',
      'email': user.email ?? '',
    }, SetOptions(merge: true));
  }

  return userCredential;
}

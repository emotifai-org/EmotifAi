import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? username;
  bool isLoading = true;
  String? currentMood;
  bool _isDetecting = false;

  Future<XFile?> pickImageFromCamera() async {
    final ImagePicker picker = ImagePicker();
    return await picker.pickImage(source: ImageSource.camera);
  }

  Future<String?> getMoodFromAI(XFile imageFile) async {
    try {
      final uri = Uri.parse(
        'http://192.168.101.241:8000/detect_emotion/',
      ); // Local API endpoint
      final request = http.MultipartRequest('POST', uri)
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      final response = await request.send();
      final respStr = await response.stream.bytesToString();
      final data = jsonDecode(respStr);

      if (response.statusCode == 200) {
        return data['dominant_emotion']; // Match API response field
      } else {
        return data['error'] ?? 'Detection failed';
      }
    } catch (e) {
      print('API Error: $e');
      return null;
    }
  }

  Future<void> detectMoodFromSelfie() async {
    setState(() {
      isLoading = true;
      currentMood = null;
    });

    try {
      final imageFile = await pickImageFromCamera();
      if (imageFile == null) {
        setState(() => _isDetecting = false);
        return;
      }

      final mood = await getMoodFromAI(imageFile);
      setState(() {
        currentMood = mood ?? 'Could not detect mood';
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        currentMood = 'Error detecting mood';
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUsername();
  }

  Future<void> fetchUsername() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        // Handle user not signed in
        setState(() {
          username = null;
          isLoading = false;
        });
        return;
      }

      final userId = user.uid;
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      setState(() {
        username = userDoc.data()?['username'];
        isLoading = false;
      });
    } catch (e) {
      // Handle errors (e.g., network issues)
      setState(() {
        username = null;
        isLoading = false;
      });
      // Optionally show a snackbar or error message
      print('Error fetching username: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
        title: Text(
          'Mood Tracker',
          textAlign: TextAlign.left,
          style: GoogleFonts.lato(
            fontSize: 20,
            color: Color(0xFFFFFFFF).withOpacity(0.87),
            fontWeight: FontWeight.w500,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            SizedBox(height: 40),
            Text(
              textAlign: TextAlign.center,
              'Hi, $username How are you feeling today?',
              style: GoogleFonts.montserrat(
                fontSize: 24,
                color: Colors.white.withOpacity(0.87),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  elevation: 1.3,
                  backgroundColor: Colors.white.withOpacity(0.85),
                ),
                onPressed: _isDetecting ? null : detectMoodFromSelfie,
                child: Text(
                  'Detect Mood with Selfie',
                  style: GoogleFonts.beVietnamPro(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
            SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.black,
                  side: BorderSide(color: Colors.white),
                ),
                onPressed: () {},
                child: Text(
                  'Detect Mood with Voice',
                  style: GoogleFonts.beVietnamPro(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.85),
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
            SizedBox(height: 60),
            Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Center(
                child: Text(
                  currentMood ?? 'Take a selfie to detect mood!',
                  style: GoogleFonts.beVietnamPro(
                    fontWeight: FontWeight.bold,
                    color: currentMood != null ? Colors.black : Colors.grey,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

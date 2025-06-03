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
  Future<XFile?> pickImage(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Select Image Source'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, ImageSource.camera),
            child: const Text('Camera'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, ImageSource.gallery),
            child: const Text('Gallery'),
          ),
        ],
      ),
    );
    if (source == null) return null;
    return await picker.pickImage(source: source);
  }

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
      final uri = Uri.parse('http://192.168.101.241:8000/detect_emotion/');
      final request = http.MultipartRequest('POST', uri)
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      final response = await request.send();
      final respStr = await response.stream.bytesToString();
      final data = jsonDecode(respStr);

      return response.statusCode == 200
          ? data['dominant_emotion']
          : data['error'] ?? 'Detection failed';
    } catch (e) {
      print('API Error: $e');
      return null;
    }
  }

  Future<void> detectMoodFromSelfie() async {
    setState(() {
      _isDetecting = true;
      currentMood = null;
    });

    try {
      final imageFile = await pickImage(context); // Pass context here
      if (imageFile == null) {
        setState(() => _isDetecting = false);
        return;
      }

      final mood = await getMoodFromAI(imageFile);
      setState(() => currentMood = mood ?? 'Could not detect mood');
    } catch (e) {
      setState(() => currentMood = 'Error detecting mood');
    } finally {
      setState(() => _isDetecting = false);
    }
  }

  Future<void> fetchUsername() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() => username = null);
        return;
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      setState(() => username = userDoc.data()?['username']);
    } catch (e) {
      setState(() => username = null);
      print('Error fetching username: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUsername();
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
          style: GoogleFonts.lato(
            fontSize: 20,
            color: Colors.white.withOpacity(0.87),
            fontWeight: FontWeight.w500,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Text(
              'Hi, ${isLoading ? '...' : username} How are you feeling today?',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 24,
                color: Colors.white.withOpacity(0.87),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  elevation: 1.3,
                  backgroundColor: Colors.white.withOpacity(0.85),
                ),
                onPressed: _isDetecting ? null : () => detectMoodFromSelfie(),
                child: _isDetecting
                    ? const CircularProgressIndicator(
                        color: Colors.black,
                        strokeWidth: 3,
                      )
                    : Text(
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
            const SizedBox(height: 60),
            Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Center(
                child: _isDetecting
                    ? const CircularProgressIndicator(color: Colors.black)
                    : Text(
                        currentMood ?? 'Take a selfie to detect mood!',
                        style: GoogleFonts.beVietnamPro(
                          fontWeight: FontWeight.bold,
                          color: currentMood != null
                              ? Colors.black
                              : Colors.grey,
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

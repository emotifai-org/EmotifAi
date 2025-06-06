import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emotifai/Screens/get_recommendations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:emotifai/services/spotify_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  String? username;
  bool isLoading = true;
  String? currentMood;
  bool _isDetecting = false;
  String? comfortingQuote;
  AnimationController? _fadeController;
  final Map<String, dynamic> moodVisuals = {
    'happy': {
      'emoji': '😊',
      'color': Colors.yellow.shade100,
      'textColor': Colors.orange.shade900,
    },
    'sad': {
      'emoji': '😢',
      'color': Colors.blue.shade100,
      'textColor': Colors.blue.shade900,
    },
    'angry': {
      'emoji': '😠',
      'color': Colors.red.shade100,
      'textColor': Colors.red.shade900,
    },
    'calm': {
      'emoji': '😌',
      'color': Colors.green.shade100,
      'textColor': Colors.green.shade900,
    },
    'surprised': {
      'emoji': '😲',
      'color': Colors.purple.shade100,
      'textColor': Colors.purple.shade900,
    },
    'neutral': {
      'emoji': '🙂',
      'color': Colors.grey.shade200,
      'textColor': Colors.grey.shade800,
    },
  };

  @override
  void initState() {
    super.initState();
    fetchUsername();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _fadeController?.dispose();
    super.dispose();
  }

  Future<String?> getComfortingQuoteGemini(String mood) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey',
    );
    final prompt =
        "Give me a comforting, supportive quote for someone who feels $mood. Be empathetic and positive.";

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": prompt},
            ],
          },
        ],
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      try {
        return data['candidates'][0]['content']['parts'][0]['text'].trim();
      } catch (e) {
        print('Gemini parsing error: $e');
        return null;
      }
    } else {
      print('Gemini error: ${response.body}');
      return null;
    }
  }

  Future<XFile?> pickImage(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.grey[700]!, width: 1),
        ),
        elevation: 10,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Image Source',
                style: GoogleFonts.lato(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSourceButton(
                    context,
                    icon: Icons.camera_alt_rounded,
                    label: 'Camera',
                    source: ImageSource.camera,
                  ),
                  _buildSourceButton(
                    context,
                    icon: Icons.photo_library_rounded,
                    label: 'Gallery',
                    source: ImageSource.gallery,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.lato(
                    color: Colors.grey[400],
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (source == null) return null;
    return await picker.pickImage(source: source);
  }

  Widget _buildSourceButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required ImageSource source,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[800],
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            iconSize: 32,
            icon: Icon(icon, color: Colors.white),
            onPressed: () => Navigator.pop(context, source),
            style: IconButton.styleFrom(
              backgroundColor: Colors.transparent,
              padding: const EdgeInsets.all(16),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: GoogleFonts.lato(color: Colors.white, fontSize: 14)),
      ],
    );
  }

  Future<String?> getMoodFromAI(XFile imageFile) async {
    try {
      final uri = Uri.parse(
        'https://emotifai-backend-emotion.onrender.com/detect_emotion/',
      );
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
      comfortingQuote = null;
    });

    try {
      final imageFile = await pickImage(context);
      if (imageFile == null) {
        setState(() => _isDetecting = false);
        return;
      }

      final mood = await getMoodFromAI(imageFile);
      setState(() => currentMood = mood ?? 'Could not detect mood');

      if (currentMood != null && currentMood != 'Could not detect mood') {
        comfortingQuote = await getComfortingQuoteGemini(currentMood!);
        _fadeController?.forward(from: 0);
        setState(() {});
      }
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

  Future<void> handleRecommendations(BuildContext context, String mood) async {
    final spotifyAuthService = SpotifyAuthService();
    String? accessToken = await spotifyAuthService.ensureSpotifyAccessToken();

    if (accessToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Spotify authentication required.')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            RecommendationsScreen(currentMood: mood, accessToken: accessToken),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: Colors.black,
            expandedHeight: screenHeight * 0.15,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                'Mood Tracker',
                style: GoogleFonts.lato(
                  color: Colors.white.withOpacity(0.95),
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  // Greeting Section
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      'Hi, ${isLoading ? '...' : username ?? ''}',
                      key: ValueKey(username),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        fontSize: 28,
                        color: Colors.white.withOpacity(0.95),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'How are you feeling today?',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lato(
                      fontSize: 18,
                      color: Colors.white.withOpacity(0.8),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Mood Detection Section
                  _buildMoodDetectionSection(),
                  const SizedBox(height: 40),

                  // Mood Display Section
                  if (currentMood != null || _isDetecting)
                    _buildMoodDisplaySection(),

                  // Comforting Quote Section
                  if (comfortingQuote != null) _buildComfortingQuoteSection(),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(24.0),
        child: _buildRecommendationsButton(),
      ),
    );
  }

  Widget _buildMoodDetectionSection() {
    return Column(
      children: [
        Text(
          'Capture your current mood',
          style: GoogleFonts.lato(
            fontSize: 16,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              elevation: 2,
              backgroundColor: Colors.white.withOpacity(0.9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: Icon(Icons.camera_alt, color: Colors.black),
            label: Text(
              _isDetecting ? 'Processing...' : 'Take Mood Selfie',
              style: GoogleFonts.beVietnamPro(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            onPressed: _isDetecting ? null : () => detectMoodFromSelfie(),
          ),
        ),
      ],
    );
  }

  Widget _buildMoodDisplaySection() {
    final moodData =
        moodVisuals[currentMood?.toLowerCase()] ?? moodVisuals['neutral'];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        color: moodData['color'],
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(moodData['emoji'], style: const TextStyle(fontSize: 40)),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Mood',
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    color: moodData['textColor'].withOpacity(0.8),
                  ),
                ),
                Text(
                  currentMood?.toUpperCase() ?? 'DETECTING...',
                  style: GoogleFonts.bebasNeue(
                    fontSize: 32,
                    color: moodData['textColor'],
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComfortingQuoteSection() {
    return FadeTransition(
      opacity: _fadeController!,
      child: Container(
        margin: const EdgeInsets.only(top: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[900]!.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[800]!, width: 1),
        ),
        child: Column(
          children: [
            Icon(Icons.psychology_alt, color: Colors.blueGrey[200], size: 28),
            const SizedBox(height: 12),
            Text(
              '"${comfortingQuote!}"',
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontStyle: FontStyle.italic,
                fontSize: 16,
                color: Colors.blueGrey[100],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationsButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton(
        style: FilledButton.styleFrom(
          elevation: 2,
          backgroundColor: Colors.white.withOpacity(0.9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () async {
          if (currentMood != null && !_isDetecting) {
            await handleRecommendations(context, currentMood!);
          }
        },
        child: _isDetecting
            ? const CircularProgressIndicator(
                color: Colors.black,
                strokeWidth: 3,
              )
            : Text(
                'Get Music Recommendations',
                style: GoogleFonts.beVietnamPro(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
      ),
    );
  }
}

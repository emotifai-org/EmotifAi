import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:http/http.dart' as http;

Future<List<Map<String, dynamic>>> searchSpotifyPlaylists({
  required String accessToken,
  required String mood,
  String type = 'playlist',
  String? market,
  int limit = 20,
  int offset = 0,
  String? includeExternal,
}) async {
  final queries = ['$mood playlist', '$mood songs', '$mood music', mood];

  for (final q in queries) {
    final params = <String, String>{
      'q': q,
      'type': type,
      'limit': limit.toString(),
      'offset': offset.toString(),
    };
    if (market != null) params['market'] = market;
    if (includeExternal != null) params['include_external'] = includeExternal;

    final uri = Uri.https('api.spotify.com', '/v1/search', params);
    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final playlistsSection = data['playlists'];
      final items =
          playlistsSection != null && playlistsSection['items'] != null
          ? playlistsSection['items'] as List
          : [];

      final List<Map<String, dynamic>> results = [];
      for (var item in items) {
        if (item != null) {
          results.add({
            'id': item['id'] ?? '',
            'name': item['name'] ?? '',
            'image': (item['images'] != null && item['images'].isNotEmpty)
                ? item['images'][0]['url']
                : null,
            'url': item['external_urls']?['spotify'] ?? '',
            'description': item['description'] ?? '',
          });
        }
      }
      if (results.isNotEmpty) return results;
    } else {
      print('Spotify API error: ${response.statusCode} ${response.body}');
    }
  }
  // If all queries fail, return empty list
  return [];
}

class SpotifyAuthService {
  final String clientId = '588ce38482a44399bf1f533f6012eacc';
  final String clientSecret = '240f1de2e33447968d11ce20cf42689e';
  final String redirectUri = 'emotifai://callback';

  Future<String?> authenticateAndSaveTokens() async {
    final authUrl = Uri.https('accounts.spotify.com', '/authorize', {
      'client_id': clientId,
      'response_type': 'code',
      'redirect_uri': redirectUri,
      'scope': 'user-read-private playlist-read-private',
    });

    final result = await FlutterWebAuth2.authenticate(
      url: authUrl.toString(),
      callbackUrlScheme: 'emotifai',
    );

    final code = Uri.parse(result).queryParameters['code'];
    if (code == null) return null;

    final tokenResponse = await http.post(
      Uri.parse('https://accounts.spotify.com/api/token'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization':
            'Basic ${base64Encode(utf8.encode('$clientId:$clientSecret'))}',
      },
      body: {
        'grant_type': 'authorization_code',
        'code': code,
        'redirect_uri': redirectUri,
      },
    );

    if (tokenResponse.statusCode == 200) {
      final body = json.decode(tokenResponse.body);
      await saveRefreshToken(body['refresh_token']);
      return body['access_token'];
    }
    return null;
  }

  Future<void> saveRefreshToken(String refreshToken) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'spotify_refresh_token': refreshToken,
      }, SetOptions(merge: true));
    }
  }

  Future<String?> getRefreshToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      return doc.data()?['spotify_refresh_token'];
    }
    return null;
  }

  Future<String?> getAccessTokenFromRefreshToken(String refreshToken) async {
    final response = await http.post(
      Uri.parse('http://192.168.101.241:3000/refresh_token'), // Update this URL
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'refresh_token': refreshToken}),
    );
    print('Refresh response: ${response.statusCode} ${response.body}');
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['access_token'];
    }
    return null;
  }

  Future<String?> ensureSpotifyAccessToken() async {
    final refreshToken = await getRefreshToken();
    if (refreshToken == null) return await authenticateAndSaveTokens();

    final accessToken = await getAccessTokenFromRefreshToken(refreshToken);
    if (accessToken == null) {
      // Refresh failed, prompt user to re-authenticate
      return await authenticateAndSaveTokens();
    }
    return accessToken;
  }

  // Mood to Playlist Mapping
  String getPlaylistIdForMood(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
        return '37i9dQZF1DXdPec7aLTmlC';
      case 'sad':
        return '2sOMIgioNPngXojcOuR4tn';
      case 'angry':
        return '37i9dQZF1DX1rVvRgjX59F';
      case 'calm':
        return '37i9dQZF1DX4sWSpwq3LiO';
      default:
        return '37i9dQZF1DXdPec7aLTmlC';
    }
  }

  Future<Map<String, dynamic>?> getPlaylistInfo(
    String accessToken,
    String playlistId,
  ) async {
    final response = await http.get(
      Uri.parse('https://api.spotify.com/v1/playlists/$playlistId'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    return (response.statusCode == 200) ? json.decode(response.body) : null;
  }
}

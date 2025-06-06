# EmotifAi – AI-Powered Mood-Based Spotify Song Recommender

EmotifAi is a cross-platform Flutter app that recommends Spotify playlists and songs tailored to your mood. It uses AI-powered emotion analysis (DeepFace), Google Gemini API, and seamless Spotify integration to help you discover the perfect music for how you feel.

---

## Features

- 🎵 **Spotify Integration:**  
  Authenticate with Spotify and get curated playlists and songs that match your mood.

- 🤳 **AI Mood Detection:**  
  Instantly analyze your mood from a selfie (DeepFace) or via text/voice (Gemini API).

- 🤖 **Gemini API Integration:**  
  Advanced AI for mood understanding and smarter recommendations.

- 🖤 **Modern UI:**  
  Clean, scrollable playlist grids, dark theme, and smooth onboarding.

---

## Screenshots

### Onboarding
<img src="screenshots/OnBoardingScreen1.png" width="250"/>
<img src="screenshots/OnBoardingScreen2.png" width="250"/>
<img src="screenshots/OnBoardingScreen3.png" width="250"/>
<img src="screenshots/OnBoardingScreen4.png" width="250"/>

### Authentication 
<img src="screenshots/RegisterScreen.png" width="250"/>
<img src="screenshots/LoginScreen.png" width="250"/>
<img src="screenshots/Loginscreenfeedback.png" width="250"/>
<img src="screenshots/SpotifyAuth.png" width="250"/>

### Mood Detection & Recommendations

<img src="screenshots/Homescreen.png" width="250"/>
<img src="screenshots/OnPressDetectMood.png" width="250"/>
<img src="screenshots/OnPressDetectMoodFeedback.png" width="250"/>
<img src="screenshots/RecommendationsScreen.png" width="250"/>
<img src="screenshots/SpotifyPlaylist.png" width="250"/>

---

## Getting Started

1. **Clone the repo:**
git clone https://github.com/emotifai-org/EmotifAi.git
cd emotifai-app


2. **Install dependencies:**
flutter pub get


3. **Configure APIs:**
- Set up your `.env` file with API keys (Gemini, etc.).
- Configure Spotify API credentials in your backend.
- Set up DeepFace and Gemini API endpoints.

4. **Run the app:**
flutter run

---

## Tech Stack

- Flutter (Dart)
- Spotify Web API
- DeepFace (Python, FastAPI)
- Gemini API (Google Cloud)
- Node.js/Express (Spotify token refresh proxy)

---

## Contributing

Pull requests are welcome! For major changes, please open an issue first to discuss what you would like to change.

---

## Contact

For questions or support, open an issue or contact the maintainers through the [EmotifAi organization](https://github.com/emotifai-org).

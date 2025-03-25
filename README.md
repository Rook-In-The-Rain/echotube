# Weird YouTube Audio Streaming App

A Flutter + FastAPI-based mobile and desktop application that allows users to stream and download audio from YouTube videos. The app supports authentication via Firebase, stores liked songs, and syncs across devices.

## Features

- 🎵 **Stream YouTube Audio** – Fetch and play audio directly from YouTube.
- 📥 **Download for Offline Use** – Save audio locally for offline playback.
- ❤️ **Like Songs** – Save favorite songs to Firebase without downloading.

## Tech Stack

### Frontend:
- **Flutter** (Provider for state management)
- **just_audio** (for playback)
- **Firebase Authentication** (for user accounts)

### Backend:
- **FastAPI** (Python-based backend framework)
- **yt-dlp** (YouTube audio extraction)
- **Railway** (Cloud deployment)
- **Firebase Firestore** (for storing liked songs)

## Installation

### Prerequisites:
- Install [Flutter](https://flutter.dev/docs/get-started/install)
- Install [Python 3.10+](https://www.python.org/downloads/)
- Install dependencies:
  ```bash
  pip install -r requirements.txt
  ```

### Running the Backend:
```bash
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

### Running the Frontend:
```bash
flutter run
```

## Notes:
- **Rate limiting** is applied to `/download_audio` to prevent spam.
- **User-specific storage** ensures multiple users don’t overwrite each other’s files.

---

_Warning, project was built in 5 or so days by an  unemployed 17 year old_

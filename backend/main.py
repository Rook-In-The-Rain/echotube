from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse, JSONResponse
import yt_dlp
import os
from pydantic import BaseModel
import requests
import subprocess
print(subprocess.run(["ffmpeg", "-version"], capture_output=True, text=True).stdout)

app = FastAPI()

class DownloadRequest(BaseModel):
    url: str
    token: str  # This is the Google OAuth token


app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

def verify_google_token(token: str):
    url = "https://oauth2.googleapis.com/tokeninfo"
    params = {"access_token": token}
    response = requests.get(url, params=params)
    if response.status_code != 200:
        raise HTTPException(status_code=401, detail="Invalid token")
    return response.json()


@app.post("/download_audio")
async def download_audio(url, token):
    """Download the audio as MP3 and return its local URL."""
    print(url, token)
    # url = request.url
    # token = request.token
    print(f"{token = }, {url = }")
    ydl_opts = {
        "format": "bestaudio/best",
        "outtmpl": f"audio",
        "postprocessors": [{"key": "FFmpegExtractAudio", "preferredcodec": "mp3"}],
        "quiet": True,
        "cookies_from_browser": ("chrome",),
        "http_headers": {
        "Authorization": f"Bearer {token}"
        }
        
    }

    with yt_dlp.YoutubeDL(ydl_opts) as ydl:
        ydl.download([url])
        video_title = ydl.extract_info(url, download=False)["title"]
    print(video_title)
    return JSONResponse(content={"audio_url": f"https://backend-for-podcast-app-production.up.railway.app/static/audio.mp3", "title": video_title}, media_type="application/json; charset=utf-8")

@app.get("/static/audio.mp3")
async def serve_audio():
    """Serve the downloaded MP3 file."""
    file_path = f"audio.mp3"
    if os.path.exists(file_path):
        return FileResponse(file_path, media_type="audio/mpeg", filename=f"audio.mp3")
    return {"error": "File not found"}

# Run the server (if running manually)
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
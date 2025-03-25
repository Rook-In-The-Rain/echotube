from fastapi import FastAPI, HTTPException, Request, Query
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse, JSONResponse
import yt_dlp
import os
from pydantic import BaseModel
from os.path import isfile, join
from slowapi import Limiter
from slowapi.util import get_remote_address
from slowapi.errors import RateLimitExceeded
from fastapi.staticfiles import StaticFiles

AUDIO_DIR = "static/audio_files"
os.makedirs(AUDIO_DIR, exist_ok=True)
app = FastAPI()
limiter = Limiter(key_func=get_remote_address)

app.mount("/static", StaticFiles(directory="static/audio_files"), name="static")

@app.exception_handler(RateLimitExceeded)
async def rate_limit_exceeded_handler(request: Request, exc: RateLimitExceeded):
    return JSONResponse(content={"error": "Rate limit exceeded. Please try again later."}, status_code=429)

class DownloadRequest(BaseModel):
    url: str
    token: str  


app = FastAPI()


app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# http://127.0.0.1:8000, https://backend-for-podcast-app-production.up.railway.app

@app.post("/download_audio")
@limiter.limit("5/minute") 
async def download_audio(url: str, token: str, request: Request, firebase_uid: str = Query(...)):
    if not firebase_uid:
        raise HTTPException(status_code=400, detail="Firebase UID is required.")
    
    user_folder = os.path.join(AUDIO_DIR, firebase_uid)
    os.makedirs(user_folder, exist_ok=True)  # Ensure the user's folder exists

    audio_path = os.path.join(user_folder, "audio")
    print(f"{url = }, {firebase_uid = }, {user_folder = }, {token = }")
    # Check if the file already exists (to avoid re-downloading)
    if os.path.exists(user_folder) and url == "":
        print("returninggg")
        return {"audio_url": f"https://backend-for-podcast-app-production.up.railway.app/{audio_path}.mp3", "title": "Linked Audio, no idea what title is"}

    ydl_opts = {
        "format": "bestaudio/best",
        "outtmpl": audio_path,
        "postprocessors": [{"key": "FFmpegExtractAudio", "preferredcodec": "mp3"}],
        "quiet": True,
        "cookies_from_browser": ("chrome",),
        "http_headers": {
        "Authorization": f"Bearer {token}"
        },
            "extractor_args": {
                "youtube": {
                    "skip": ["configs", "player"]
                }
            }
    }
    with yt_dlp.YoutubeDL(ydl_opts) as ydl:
        ydl.download([url])
        video_title = ydl.extract_info(url, download=False)["title"]
    print(audio_path)
    return JSONResponse(content={"audio_url": f"https://backend-for-podcast-app-production.up.railway.app/{audio_path}.mp3", "title": video_title}, media_type="application/json; charset=utf-8")

@app.get("/static/audio_files/{firebase_uid}/audio.mp3")
async def serve_audio(firebase_uid: str):
    """
    Serves the audio file from the user's folder.
    """
    audio_path = os.path.join(AUDIO_DIR, firebase_uid, "audio.mp3")

    if not os.path.exists(audio_path):
        raise HTTPException(status_code=404, detail="Audio file not found.")

    return FileResponse(audio_path, media_type="audio/mpeg")


@app.get("/file_count")
async def count_files():
    directory = "static/audio_files"
    if not os.path.exists(directory):
        return {"error": "Directory not found"}
    
    file_count = len(os.listdir(directory))
    return {"file_count": file_count}

# Run the server (if running manually)
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)

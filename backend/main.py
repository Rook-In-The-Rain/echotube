from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from utils.fetch_video_data import get_video_title, get_audio_url
import subprocess
from fastapi.responses import FileResponse, JSONResponse
import yt_dlp
import os

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/download_audio")
async def download_audio(url: str):
    """Download the audio as MP3 and return its local URL."""
    ydl_opts = {
        "format": "bestaudio/best",
        "outtmpl": f"audio",
        "postprocessors": [{"key": "FFmpegExtractAudio", "preferredcodec": "mp3"}],
        "quiet": True
    }

    with yt_dlp.YoutubeDL(ydl_opts) as ydl:
        video_title = ydl.extract_info(url, download=False)["title"]
        ydl.download([url])
    print(video_title)
    return JSONResponse(content={"audio_url": f"http://127.0.0.1:8000/static/audio.mp3", "title": video_title}, media_type="application/json; charset=utf-8")

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
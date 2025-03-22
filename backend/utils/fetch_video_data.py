import yt_dlp

def get_video_title(video_url):
    ydl_opts = {'quiet': True}
    
    with yt_dlp.YoutubeDL(ydl_opts) as ydl:
        info = ydl.extract_info(video_url, download=False)
        return info['title']

def get_audio_url(video_url):
    ydl_opts = {'format': 'bestaudio/best', 'quiet': True}
    
    with yt_dlp.YoutubeDL(ydl_opts) as ydl:
        info = ydl.extract_info(video_url, download=False)
        return info['url']

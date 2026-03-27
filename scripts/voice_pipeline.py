#!/usr/bin/env python3
"""
Voice Pipeline — Totin
Recibe audio → Transcribe (Whisper) → Genera respuesta (gTTS) → Envía a Telegram
"""

import subprocess
import sys
import os
import tempfile
from gtts import gTTS

DASHBOARD = "/Users/elvisvaldesinerarte/.openclaw/workspace/dashboard"
MEDIA_INBOUND = "/Users/elvisvaldesinerarte/.openclaw/media/inbound"
TELEGRAM_ID = "266525416"

def find_latest_audio():
    """Find the most recent audio file in inbound"""
    files = []
    for f in os.listdir(MEDIA_INBOUND):
        path = os.path.join(MEDIA_INBOUND, f)
        if os.path.isfile(path):
            files.append((os.path.getmtime(path), path))
    files.sort(reverse=True)
    return files[0][1] if files else None

def transcribe(audio_path):
    """Transcribe audio file using Whisper"""
    with tempfile.NamedTemporaryFile(suffix='.wav', delete=False) as tmp:
        tmp_path = tmp.name
    
    # Convert to 16kHz mono wav
    subprocess.run([
        'ffmpeg', '-i', audio_path, '-ar', '16000', '-ac', '1', tmp_path, '-y'
    ], capture_output=True)
    
    # Transcribe - use 'tiny' for speed, 'base' for accuracy
    result = subprocess.run([
        'whisper', tmp_path, '--model', 'tiny', '--output_format', 'txt', '--output_dir', '/tmp'
    ], capture_output=True, text=True)
    
    os.unlink(tmp_path)
    
    # Extract text from output (skip lines starting with [)
    lines = [l for l in result.stdout.split('\n') if l and not l.startswith('[')]
    return ' '.join(lines).strip()

def speak_to_telegram(text, speed=1.3):
    """Generate TTS and save to dashboard"""
    with tempfile.NamedTemporaryFile(suffix='.mp3', delete=False) as tmp:
        tmp_path = tmp.name
    
    tts = gTTS(text=text, lang='es')
    tts.save(tmp_path)
    
    # Speed up with ffmpeg
    out_path = os.path.join(DASHBOARD, f"voice_response_{os.getpid()}.mp3")
    subprocess.run([
        'ffmpeg', '-i', tmp_path, '-filter:a', f'atempo={speed}',
        out_path, '-y'
    ], capture_output=True)
    
    os.unlink(tmp_path)
    return out_path

if __name__ == "__main__":
    # Find latest audio
    latest = find_latest_audio()
    if not latest:
        print("No audio file found in inbound")
        sys.exit(1)
    
    print(f"Processing: {latest}")
    
    # Transcribe
    transcript = transcribe(latest)
    print(f"Transcript: {transcript}")
    
    # Save transcript
    with open(os.path.join(DASHBOARD, "last_transcript.txt"), 'w') as f:
        f.write(transcript)
    
    print(f"Transcript saved. Ready for processing.")

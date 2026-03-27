#!/usr/bin/env python3
"""
Voice Watcher — Totin v2
Background process that watches for new audio and auto-responds via Telegram
"""

import os
import sys
import time
import subprocess
import tempfile
from pathlib import Path
from gtts import gTTS

# Config
DASHBOARD = "/Users/elvisvaldesinerarte/.openclaw/workspace/dashboard"
MEDIA_INBOUND = "/Users/elvisvaldesinerarte/.openclaw/media/inbound"
TELEGRAM_ID = "266525416"
PROCESSED_MARKER = "/tmp/last_processed_voice"

def get_config_token():
    """Get Telegram bot token from openclaw config"""
    import json
    config_path = os.path.expanduser("~/.openclaw/openclaw.json")
    with open(config_path) as f:
        config = json.load(f)
    return config.get("channels", {}).get("telegram", {}).get("botToken", "")

def send_telegram_audio(token, chat_id, audio_path, caption=""):
    """Send audio file via Telegram Bot API"""
    import requests
    
    url = f"https://api.telegram.org/bot{token}/sendAudio"
    
    with open(audio_path, 'rb') as f:
        files = {'audio': f}
        data = {'chat_id': chat_id}
        if caption:
            data['caption'] = caption
        
        response = requests.post(url, files=files, data=data)
        return response.ok

def transcribe(audio_path):
    """Transcribe audio using Whisper (tiny model for speed)"""
    with tempfile.NamedTemporaryFile(suffix='.wav', delete=False) as tmp:
        tmp_path = tmp.name
    
    # Convert to 16kHz mono wav
    subprocess.run([
        'ffmpeg', '-i', audio_path, '-ar', '16000', '-ac', '1', tmp_path, '-y'
    ], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    
    # Transcribe with tiny model (fastest)
    result = subprocess.run([
        'whisper', tmp_path, '--model', 'tiny', '--output_format', 'txt', 
        '--output_dir', '/tmp', '--language', 'Spanish'
    ], stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True)
    
    os.unlink(tmp_path)
    
    # Parse transcript from whisper output
    # Format is: [00:00.000 --> 00:02.000]  transcript text
    import re
    lines = re.findall(r'\[.*?\]\s*(.+)', result.stdout)
    transcript = ' '.join(lines).strip()
    return transcript

def generate_voice_response(text, speed=1.3):
    """Generate TTS response audio"""
    # Short auto-response for now
    response_text = f"Recibido. Procesando tu audio: {text[:50]}..."
    
    tts = gTTS(text=response_text, lang='es')
    mp3_path = os.path.join(DASHBOARD, "auto_response.mp3")
    tts.save(mp3_path)
    
    # Speed up
    fast_path = os.path.join(DASHBOARD, "auto_response_fast.mp3")
    subprocess.run([
        'ffmpeg', '-i', mp3_path, '-filter:a', f'atempo={speed}',
        fast_path, '-y'
    ], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    
    return fast_path

def process_new_audio():
    """Find and process new audio files"""
    # Get last processed file
    last_processed = ""
    if os.path.exists(PROCESSED_MARKER):
        with open(PROCESSED_MARKER) as f:
            last_processed = f.read().strip()
    
    # Find newest audio
    audio_files = []
    for ext in ['*.ogg', '*.m4a', '*.mp3', '*.oga', '*.wav']:
        audio_files.extend(Path(MEDIA_INBOUND).glob(ext))
    
    if not audio_files:
        return False
    
    newest = max(audio_files, key=lambda p: p.stat().st_mtime)
    
    # Skip if same as last processed or file is too new (still being written)
    if str(newest) == last_processed:
        return False
    
    # Check file age (must be at least 2 seconds old)
    file_age = time.time() - newest.stat().st_mtime
    if file_age < 2:
        return False
    
    print(f"📥 Processing: {newest}")
    
    # Transcribe
    transcript = transcribe(str(newest))
    print(f"💬 Transcript: {transcript}")
    
    if transcript and len(transcript) > 2:
        # Save transcript
        with open(os.path.join(DASHBOARD, "last_transcript.txt"), 'w') as f:
            f.write(transcript)
        
        # Generate voice response
        print("🎙️ Generating voice response...")
        audio_path = generate_voice_response(transcript)
        
        # Send via Telegram
        token = get_config_token()
        if token:
            ok = send_telegram_audio(token, TELEGRAM_ID, audio_path)
            if ok:
                print("✅ Response sent to Telegram!")
            else:
                print("❌ Failed to send to Telegram")
        
        # Mark as processed
        with open(PROCESSED_MARKER, 'w') as f:
            f.write(str(newest))
        
        return True
    
    return False

def main():
    print("🐻 Voice Watcher started — watching for audio...")
    print(f"   Inbound: {MEDIA_INBOUND}")
    print(f"   Dashboard: {DASHBOARD}")
    print("   Press Ctrl+C to stop\n")
    
    # Check token
    token = get_config_token()
    if not token:
        print("❌ No Telegram bot token found in config")
        sys.exit(1)
    
    while True:
        try:
            process_new_audio()
        except Exception as e:
            print(f"⚠️ Error: {e}")
        
        time.sleep(1)

if __name__ == "__main__":
    main()

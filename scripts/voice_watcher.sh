#!/bin/bash
# Voice Watcher — Totin
# Watches media/inbound for new audio files and auto-responds via Telegram

DASHBOARD="/Users/elvisvaldesinerarte/.openclaw/workspace/dashboard"
MEDIA_INBOUND="/Users/elvisvaldesinerarte/.openclaw/media/inbound"
LAST_FILE=""
LAST_CHECK=0

echo "🐻 Voice Watcher started — watching $MEDIA_INBOUND"

while true; do
    # Find newest .ogg/.m4a/.mp3 file
    NEWEST=$(find "$MEDIA_INBOUND" -maxdepth 1 -type f \( -name "*.ogg" -o -name "*.m4a" -o -name "*.mp3" \) -newer "$0" 2>/dev/null | head -1)
    
    if [ -n "$NEWEST" ] && [ "$NEWEST" != "$LAST_FILE" ]; then
        FILE_TIME=$(stat -f %m "$NEWEST" 2>/dev/null)
        
        # Only process if file is older than 2 seconds (avoid partial files)
        NOW=$(date +%s)
        if [ $((NOW - FILE_TIME)) -ge 2 ]; then
            echo "📥 New audio detected: $NEWEST"
            LAST_FILE="$NEWEST"
            
            # Process with Python pipeline
            python3 /Users/elvisvaldesinerarte/.openclaw/workspace/scripts/voice_pipeline.py 2>&1
            
            # Read transcript
            TRANSCRIPT=$(cat "$DASHBOARD/last_transcript.txt" 2>/dev/null | grep -v "Detecting" | grep -v "language" | grep -v "^\[" | tr -d '\n')
            
            if [ -n "$TRANSCRIPT" ] && [ ${#TRANSCRIPT} -gt 3 ]; then
                echo "💬 Transcript: $TRANSCRIPT"
                
                # Generate response audio
                RESPONSE=$(python3 -c "
from gtts import gTTS
import subprocess
import os

# Auto-response based on transcript
text = '$TRANSCRIPT'

# Generate response
tts = gTTS(text='Recibido Elvis. Estoy procesando tu audio. Respuesta automatica funcionando.', lang='es')
tts.save('/tmp/auto_response.mp3')
subprocess.run(['ffmpeg', '-i', '/tmp/auto_response.mp3', '-filter:a', 'atempo=1.3', '${DASHBOARD}/auto_response.mp3', '-y'], capture_output=True)
print('OK')
" 2>&1)
                
                # Send to Telegram
                if [ -f "$DASHBOARD/auto_response.mp3" ]; then
                    echo "📤 Sending voice response to Telegram..."
                    # This would call the message tool — for now just indicate it's ready
                    echo "✅ Response ready at $DASHBOARD/auto_response.mp3"
                fi
            fi
        fi
    fi
    
    sleep 1
done

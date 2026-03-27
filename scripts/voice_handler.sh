#!/bin/bash
# Voice Handler — Totin
# Usage: voice_handler.sh <audio_file_path>
# Transcribe audio, get response, send back as voice

AUDIO_FILE="$1"
DASHBOARD="/Users/elvisvaldesinerarte/.openclaw/workspace/dashboard"
WORK_DIR="/tmp/voice_work"

mkdir -p "$WORK_DIR"

# Convert to wav for whisper
ffmpeg -i "$AUDIO_FILE" -ar 16000 -ac 1 "$WORK_DIR/input.wav" -y 2>/dev/null

# Transcribe
TRANSCRIPT=$(whisper "$WORK_DIR/input.wav" --model base --output_format txt --output_dir "$WORK_DIR" 2>/dev/null | grep -v "^\[" | tr '\n' ' ')

if [ -z "$TRANSCRIPT" ]; then
    echo "No transcript generated"
    exit 1
fi

echo "Transcript: $TRANSCRIPT"

# Save transcript for processing
echo "$TRANSCRIPT" > "$WORK_DIR/transcript.txt"

# Clean up
rm -f "$WORK_DIR/input.wav"

echo "$TRANSCRIPT"

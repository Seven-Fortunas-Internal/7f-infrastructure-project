#!/bin/bash
"""
Voice Input System using OpenAI Whisper
FR-2.3: Cross-platform voice transcription for Claude skills

Usage:
    ./voice-input.sh [--model MODEL] [--output FILE]

Options:
    --model     Whisper model (tiny, base, small, medium, large) [default: base]
    --output    Output file for transcript [default: voice-transcript.txt]
    --language  Language code (en, es, fr, etc.) [default: auto-detect]
    --duration  Max recording duration in seconds [default: 600 (10 min)]

Examples:
    ./voice-input.sh
    ./voice-input.sh --model small --output transcript.txt
    ./voice-input.sh --language en --duration 300

5 Failure Scenarios Handled:
1. Whisper not installed → Fallback to typing mode with clear error
2. No audio device found → Display troubleshooting steps
3. Recording interrupted → Save partial audio and attempt transcription
4. Transcription failed → Preserve audio file, prompt for retry
5. Low confidence (<80%) → Display confidence score, ask for confirmation
"""

set -e

# Default configuration
WHISPER_MODEL="base"
OUTPUT_FILE="voice-transcript.txt"
LANGUAGE="auto"
MAX_DURATION=600  # 10 minutes
AUDIO_FILE="/tmp/voice-recording-$(date +%s).wav"
CONFIDENCE_THRESHOLD=80

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --model)
            WHISPER_MODEL="$2"
            shift 2
            ;;
        --output)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        --language)
            LANGUAGE="$2"
            shift 2
            ;;
        --duration)
            MAX_DURATION="$2"
            shift 2
            ;;
        --help|-h)
            echo "Voice Input System - OpenAI Whisper Integration"
            echo ""
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --model MODEL       Whisper model (tiny|base|small|medium|large)"
            echo "  --output FILE       Output transcript file"
            echo "  --language LANG     Language code (en, es, fr, etc.)"
            echo "  --duration SECONDS  Max recording duration (default: 600)"
            echo ""
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Failure Scenario 1: Check if Whisper is installed
if ! command -v /home/ladmin/.local/bin/whisper &> /dev/null; then
    echo "✗ ERROR: OpenAI Whisper is not installed"
    echo ""
    echo "Fallback: Please install Whisper or use typing mode"
    echo ""
    echo "Installation: pip install openai-whisper"
    echo ""
    echo "Switching to typing mode..."
    echo "Enter your text (Ctrl+D when done):"
    cat > "$OUTPUT_FILE"
    echo "✓ Transcript saved to $OUTPUT_FILE"
    exit 0
fi

# Failure Scenario 2: Check for audio devices
if ! arecord -l &> /dev/null; then
    echo "✗ ERROR: No audio recording device found"
    echo ""
    echo "Troubleshooting:"
    echo "1. Check if microphone is connected"
    echo "2. Verify permissions: usermod -a -G audio $USER"
    echo "3. Test with: arecord -l"
    echo "4. Check PulseAudio: pactl list sources"
    echo ""
    echo "Fallback: Switching to typing mode..."
    echo "Enter your text (Ctrl+D when done):"
    cat > "$OUTPUT_FILE"
    echo "✓ Transcript saved to $OUTPUT_FILE"
    exit 0
fi

# Display recording instructions
echo "=========================================="
echo "Voice Input System - OpenAI Whisper"
echo "=========================================="
echo ""
echo "Model: $WHISPER_MODEL"
echo "Language: $LANGUAGE"
echo "Max Duration: $MAX_DURATION seconds ($(($MAX_DURATION / 60)) minutes)"
echo ""
echo "Recording... Press Ctrl+C to stop"
echo ""
echo "Speak clearly into your microphone."
echo "Press Ctrl+C when finished speaking."
echo ""

# Failure Scenario 3: Handle interrupted recording
trap 'echo ""; echo "Recording interrupted. Processing partial audio..."; INTERRUPTED=true' INT

INTERRUPTED=false

# Start recording
arecord -f cd -t wav -d "$MAX_DURATION" "$AUDIO_FILE" 2>/dev/null || true

if [[ ! -f "$AUDIO_FILE" ]] || [[ ! -s "$AUDIO_FILE" ]]; then
    echo "✗ ERROR: Recording failed or file is empty"
    echo ""
    echo "Fallback: Switching to typing mode..."
    echo "Enter your text (Ctrl+D when done):"
    cat > "$OUTPUT_FILE"
    echo "✓ Transcript saved to $OUTPUT_FILE"
    exit 0
fi

echo ""
echo "✓ Recording completed. Transcribing..."
echo ""

# Transcribe with Whisper
WHISPER_OUTPUT="/tmp/whisper-output-$(date +%s)"

# Failure Scenario 4: Handle transcription failure
if [[ "$LANGUAGE" == "auto" ]]; then
    bash -c "/home/ladmin/.local/bin/whisper \"$AUDIO_FILE\" --model $WHISPER_MODEL --output_dir \"$WHISPER_OUTPUT\" --output_format json" 2>/dev/null || {
        echo "✗ ERROR: Transcription failed"
        echo ""
        echo "Audio file preserved: $AUDIO_FILE"
        echo ""
        echo "Retry options:"
        echo "1. Try with smaller model: --model tiny"
        echo "2. Specify language: --language en"
        echo "3. Check audio quality: play $AUDIO_FILE"
        echo ""
        echo "Fallback: Please type your content manually"
        echo "Enter your text (Ctrl+D when done):"
        cat > "$OUTPUT_FILE"
        echo "✓ Transcript saved to $OUTPUT_FILE"
        exit 0
    }
else
    bash -c "/home/ladmin/.local/bin/whisper \"$AUDIO_FILE\" --model $WHISPER_MODEL --language $LANGUAGE --output_dir \"$WHISPER_OUTPUT\" --output_format json" 2>/dev/null || {
        echo "✗ ERROR: Transcription failed"
        echo "Audio file preserved: $AUDIO_FILE"
        echo "Fallback to typing mode..."
        echo "Enter your text (Ctrl+D when done):"
        cat > "$OUTPUT_FILE"
        echo "✓ Transcript saved to $OUTPUT_FILE"
        exit 0
    }
fi

# Extract transcript and confidence from JSON
JSON_FILE=$(ls "$WHISPER_OUTPUT"/*.json | head -1)

if [[ ! -f "$JSON_FILE" ]]; then
    echo "✗ ERROR: Transcription output not found"
    echo "Audio file preserved: $AUDIO_FILE"
    exit 1
fi

TRANSCRIPT=$(jq -r '.text' "$JSON_FILE")

# Failure Scenario 5: Low confidence warning
# Calculate average confidence from segments (if available)
if jq -e '.segments' "$JSON_FILE" &> /dev/null; then
    AVG_CONFIDENCE=$(jq '[.segments[].no_speech_prob] | add / length * 100' "$JSON_FILE" 2>/dev/null || echo "100")
    AVG_CONFIDENCE=$(printf "%.0f" "$AVG_CONFIDENCE")

    if [[ $AVG_CONFIDENCE -lt $CONFIDENCE_THRESHOLD ]]; then
        echo ""
        echo "⚠️  WARNING: Low transcription confidence"
        echo "Confidence score: ${AVG_CONFIDENCE}%"
        echo ""
        echo "Transcript preview:"
        echo "-------------------"
        echo "$TRANSCRIPT" | head -3
        echo "-------------------"
        echo ""
        echo "Options:"
        echo "1. Accept transcript as-is (press Enter)"
        echo "2. Edit transcript (type 'edit')"
        echo "3. Re-record (type 'retry')"
        echo ""
        read -p "Choice: " CHOICE

        case "$CHOICE" in
            edit)
                echo "$TRANSCRIPT" > "$OUTPUT_FILE"
                ${EDITOR:-nano} "$OUTPUT_FILE"
                echo "✓ Edited transcript saved to $OUTPUT_FILE"
                ;;
            retry)
                echo "Re-recording..."
                rm -f "$AUDIO_FILE" "$JSON_FILE"
                exec "$0" "$@"
                ;;
            *)
                echo "$TRANSCRIPT" > "$OUTPUT_FILE"
                echo "✓ Transcript saved to $OUTPUT_FILE"
                ;;
        esac
    else
        echo "$TRANSCRIPT" > "$OUTPUT_FILE"
        echo "✓ Transcript saved to $OUTPUT_FILE (confidence: ${AVG_CONFIDENCE}%)"
    fi
else
    echo "$TRANSCRIPT" > "$OUTPUT_FILE"
    echo "✓ Transcript saved to $OUTPUT_FILE"
fi

# Cleanup
rm -f "$AUDIO_FILE"
rm -rf "$WHISPER_OUTPUT"

# Display transcript
echo ""
echo "Transcript:"
echo "=========================================="
cat "$OUTPUT_FILE"
echo ""
echo "=========================================="
echo ""
echo "Transcript available at: $OUTPUT_FILE"

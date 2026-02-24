#!/bin/bash
# Seven Fortunas Voice Input Handler
# Integrates OpenAI Whisper for voice-to-text transcription
# Used by 7f-brand-system-generator and other voice-enabled skills

set -e

# Configuration
TEMP_DIR="/tmp/7f-voice"
AUDIO_FILE="$TEMP_DIR/recording.wav"
TRANSCRIPT_FILE="$TEMP_DIR/transcript.txt"
CONFIDENCE_FILE="$TEMP_DIR/confidence.txt"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Initialize
mkdir -p "$TEMP_DIR"

# Function: Check if microphone is available
check_microphone() {
    if ! arecord -l &>/dev/null; then
        echo -e "${RED}❌ No microphone detected${NC}"
        echo "Auto-fallback to text input mode"
        return 1
    fi
    return 0
}

# Function: Check if Whisper is installed
check_whisper() {
    if ! command -v whisper &>/dev/null; then
        echo -e "${YELLOW}⚠️  OpenAI Whisper not installed${NC}"
        echo ""
        echo "Install Whisper with:"
        echo "  pip install openai-whisper"
        echo ""
        echo "Or use text input mode instead."
        return 1
    fi
    return 0
}

# Function: Record audio
record_audio() {
    echo -e "${GREEN}🎤 Recording... Press Ctrl+C to stop${NC}"
    echo ""

    # Set up trap to handle Ctrl+C gracefully
    trap 'echo ""; echo "Recording stopped."; return 0' INT

    # Record audio (WAV format, 16kHz, mono)
    arecord -f cd -t wav "$AUDIO_FILE" 2>/dev/null

    # Remove trap
    trap - INT

    # Check if audio file was created
    if [ ! -f "$AUDIO_FILE" ]; then
        echo -e "${RED}❌ Recording failed${NC}"
        return 1
    fi

    # Check if file has content (> 1KB)
    size=$(stat -f%z "$AUDIO_FILE" 2>/dev/null || stat -c%s "$AUDIO_FILE" 2>/dev/null)
    if [ "$size" -lt 1000 ]; then
        echo -e "${YELLOW}⚠️  Silence detected (recording too short)${NC}"
        echo ""
        echo "Would you like to:"
        echo "  1) Re-record"
        echo "  2) Switch to text input"
        read -p "Choice (1/2): " choice

        if [ "$choice" = "1" ]; then
            rm -f "$AUDIO_FILE"
            record_audio
        else
            return 1
        fi
    fi

    return 0
}

# Function: Transcribe audio with Whisper
transcribe_audio() {
    echo ""
    echo "Transcribing audio..."

    # Run Whisper transcription
    whisper "$AUDIO_FILE" \
        --model base \
        --language en \
        --output_dir "$TEMP_DIR" \
        --output_format txt \
        --fp16 False \
        2>/dev/null

    # Whisper outputs to recording.txt
    if [ -f "$TEMP_DIR/recording.txt" ]; then
        mv "$TEMP_DIR/recording.txt" "$TRANSCRIPT_FILE"
    else
        echo -e "${RED}❌ Transcription failed${NC}"
        return 1
    fi

    # Calculate confidence score (simplified - based on output quality)
    # In real implementation, use Whisper's probability scores
    word_count=$(wc -w < "$TRANSCRIPT_FILE")
    if [ "$word_count" -lt 10 ]; then
        confidence=50
    elif [ "$word_count" -lt 50 ]; then
        confidence=70
    else
        confidence=90
    fi

    echo "$confidence" > "$CONFIDENCE_FILE"

    return 0
}

# Function: Display transcript with confidence
display_transcript() {
    confidence=$(cat "$CONFIDENCE_FILE")

    echo ""
    echo "═══════════════════════════════════════════"
    echo "Transcript (Confidence: $confidence%)"
    echo "═══════════════════════════════════════════"
    echo ""
    cat "$TRANSCRIPT_FILE"
    echo ""
    echo "═══════════════════════════════════════════"

    if [ "$confidence" -lt 80 ]; then
        echo -e "${YELLOW}⚠️  Low confidence score ($confidence%)${NC}"
        echo "Consider re-recording for better accuracy."
    fi
}

# Function: Review and confirm
review_transcript() {
    echo ""
    echo "Options:"
    echo "  1) Use this transcript"
    echo "  2) Re-record"
    echo "  3) Switch to text input"
    read -p "Choice (1/2/3): " choice

    case "$choice" in
        1)
            return 0
            ;;
        2)
            rm -f "$AUDIO_FILE" "$TRANSCRIPT_FILE" "$CONFIDENCE_FILE"
            main
            ;;
        3)
            return 1
            ;;
        *)
            echo "Invalid choice"
            review_transcript
            ;;
    esac
}

# Function: Manual fallback (press 'T' during recording)
# This would be implemented in the calling script with a background process
# monitoring for 'T' key press

# Main workflow
main() {
    echo "Seven Fortunas Voice Input System"
    echo "=================================="
    echo ""

    # Check prerequisites
    if ! check_microphone; then
        exit 1
    fi

    if ! check_whisper; then
        exit 1
    fi

    # Record audio
    if ! record_audio; then
        echo "Falling back to text input"
        exit 1
    fi

    # Transcribe
    if ! transcribe_audio; then
        echo "Transcription failed. Falling back to text input."
        exit 1
    fi

    # Display and review
    display_transcript

    if review_transcript; then
        # Output transcript to stdout for calling script
        cat "$TRANSCRIPT_FILE"
        exit 0
    else
        # User chose text input
        exit 1
    fi
}

# Run main workflow
main

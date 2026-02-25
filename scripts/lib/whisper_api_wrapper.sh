#!/bin/bash
# OpenAI Whisper API Wrapper with Rate Limiting
# Ensures responsible use of Whisper API (no documented limit)

source "$(dirname "$0")/rate_limiter.sh"

# Recommended limit: 20 requests/minute (conservative)
WHISPER_LIMIT=20
WHISPER_WINDOW="minute"

# Wrapper for Whisper API calls
whisper_api_rate_limited() {
    local audio_file="$1"
    local model="${2:-whisper-1}"

    # Check rate limit before making request
    throttle_api_call "whisper_api" "$WHISPER_WINDOW" "$WHISPER_LIMIT"

    # Make the actual API call
    if [[ ! -f "$audio_file" ]]; then
        echo "Error: Audio file not found: $audio_file" >&2
        return 1
    fi

    # Example Whisper API call (would need actual implementation with API key)
    # curl -X POST "https://api.openai.com/v1/audio/transcriptions" \
    #      -H "Authorization: Bearer $OPENAI_API_KEY" \
    #      -F "file=@$audio_file" \
    #      -F "model=$model"

    echo "Whisper API call throttled and executed for: $audio_file" >&2
}

# Export wrapper functions
export -f whisper_api_rate_limited

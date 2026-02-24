# Installation Instructions

**Purpose:** Complete installation instructions for Whisper and FFmpeg prerequisites.

---

## Whisper Installation

**Installation Instructions:**

### Option 1: Using pip (Recommended)

```bash
# Install Whisper
pip install -U openai-whisper

# Verify installation
command -v whisper && echo "Whisper installed successfully"
```

### Option 2: Using pipx (Isolated installation)

```bash
# Install pipx if needed
python3 -m pip install --user pipx
python3 -m pipx ensurepath

# Install Whisper via pipx
pipx install openai-whisper

# Verify installation
command -v whisper && echo "Whisper installed successfully"
```

**Requirements:**
- Python 3.8 or newer
- pip or pipx package manager

**Documentation:** https://github.com/openai/whisper

---

## FFmpeg Installation

**Installation Instructions:**

### For Ubuntu/Debian:

```bash
sudo apt-get update
sudo apt-get install ffmpeg
```

### For macOS:

```bash
brew install ffmpeg
```

### For Windows:

1. Download from: https://ffmpeg.org/download.html
2. Extract to `C:\ffmpeg`
3. Add `C:\ffmpeg\bin` to system PATH

### For other systems:

Visit: https://ffmpeg.org/download.html

**Verify installation:**

```bash
ffmpeg -version
```

**Documentation:** https://ffmpeg.org/documentation.html

---

## Troubleshooting

### Whisper not found after installation

**Check PATH:**
```bash
which whisper
echo $PATH
```

**Reinstall with user flag:**
```bash
pip install --user openai-whisper
```

**Try pipx instead:**
```bash
pipx install openai-whisper
pipx ensurepath
```

### FFmpeg not found after installation

**Check installation:**
```bash
which ffmpeg
ffmpeg -version
```

**Ubuntu/Debian: Update package cache**
```bash
sudo apt-get update
sudo apt-get install ffmpeg
```

**macOS: Update Homebrew**
```bash
brew update
brew install ffmpeg
```

### Permission errors

**Use virtual environment (recommended):**
```bash
python3 -m venv whisper-env
source whisper-env/bin/activate  # On Windows: whisper-env\Scripts\activate
pip install openai-whisper
```

**Or install with user flag:**
```bash
pip install --user openai-whisper
```

---

## Verification Checklist

After installation, verify both tools:

```bash
# Check Whisper
command -v whisper && echo "✅ Whisper found" || echo "❌ Whisper not found"

# Check FFmpeg
command -v ffmpeg && echo "✅ FFmpeg found" || echo "❌ FFmpeg not found"

# Check versions
pip show openai-whisper 2>/dev/null | grep Version
ffmpeg -version | head -n 1
```

All commands should succeed before running the transcription workflow.

# Whisper Model Options

## Available Models

### Base (Fastest)
- **Size:** ~74MB
- **Speed:** Very fast (~1-2 min for 10 min audio on CPU)
- **Accuracy:** Good for clear audio
- **Use when:** Speed is priority, audio quality is high
- **Command flag:** `--model base`

### Small (Balanced) - **RECOMMENDED**
- **Size:** ~244MB
- **Speed:** Fast (~2-3 min for 10 min audio on CPU)
- **Accuracy:** Very good for most audio
- **Use when:** General purpose transcription (default choice)
- **Command flag:** `--model small`

### Medium (Most Accurate)
- **Size:** ~769MB
- **Speed:** Moderate (~5-10 min for 10 min audio on CPU)
- **Accuracy:** Excellent for noisy/complex audio
- **Use when:** Audio quality is poor, accuracy is critical
- **Command flag:** `--model medium`

### Large (Best Quality - Not Recommended for CLI)
- **Size:** ~1.5GB+
- **Speed:** Slow (~15-20 min for 10 min audio on CPU)
- **Accuracy:** Best possible
- **Use when:** Maximum accuracy needed, have GPU acceleration
- **Note:** Very slow on CPU, not included in this workflow

## Model Selection Guide

**For Signal audio feedback:** Small or Base (clear audio, fast processing)
**For meeting recordings:** Small (balanced quality/speed)
**For noisy environments:** Medium (better noise handling)
**For podcasts/interviews:** Small (sufficient accuracy)
**For accented speech:** Medium (better recognition)

## Performance Notes

- GPU acceleration (CUDA) makes all models 5-10x faster
- First run downloads the model (~2-5 min), subsequent runs are instant
- Models are cached at `~/.cache/whisper/`
- All processing is 100% local (no API calls)

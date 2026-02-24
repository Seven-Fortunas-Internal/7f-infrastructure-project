# Language Options

## Auto-Detection (Recommended)

**Default behavior:** Whisper automatically detects the language
**Accuracy:** 99%+ for common languages
**Command:** Omit `--language` flag or use `--language auto`

## Common Language Codes

### Most Used
- **en** - English
- **es** - Spanish
- **fr** - French
- **de** - German
- **it** - Italian
- **pt** - Portuguese
- **zh** - Chinese
- **ja** - Japanese
- **ko** - Korean

### Additional Languages
- **ru** - Russian
- **ar** - Arabic
- **hi** - Hindi
- **nl** - Dutch
- **pl** - Polish
- **tr** - Turkish
- **sv** - Swedish
- **da** - Danish
- **no** - Norwegian
- **fi** - Finnish

## When to Specify Language

**Auto-detect when:**
- Single language audio
- Unsure of language
- Multi-language content

**Specify language when:**
- Forcing specific language (e.g., treating code-switched speech as one language)
- Known language improves accuracy
- Consistent output language needed

## Multilingual Support

Whisper supports **99 languages** with high accuracy:
- Trained on 680,000 hours of multilingual audio
- Works with accented speech
- Handles code-switching (mixing languages)
- Regional dialects supported

## Command Usage

```bash
# Auto-detect (default)
whisper audio.mp3

# Specify English
whisper audio.mp3 --language en

# Specify Spanish
whisper audio.mp3 --language es
```

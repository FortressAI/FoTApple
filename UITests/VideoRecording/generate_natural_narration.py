#!/usr/bin/env python3
"""
Natural Speech Audio Generator
Converts narration scripts into natural-sounding speech with varied prosody

Uses chunking method with controlled pauses, rate, and pitch variations
"""

import subprocess
import sys
import os
import re
import random
from pathlib import Path

class NaturalSpeechChunk:
    def __init__(self, text, pause_after=0.3, rate=175, pitch_variation=0):
        self.text = text.strip()
        self.pause_after = pause_after
        self.rate = rate
        self.pitch_variation = pitch_variation

def parse_narration_to_chunks(text, base_rate=175):
    """
    Parse narration text into natural speech chunks with varied prosody.
    
    CRITICAL FOR NATURAL SOUND: Split at commas, colons, semicolons - NOT just sentences!
    From professional guide example:
        "To make voice sound natural," → pause → 
        "you can't just... speak it all at once." → pause →
        "You need to add pauses."
    
    Args:
        text: Full narration text
        base_rate: Base words per minute (175 is natural, 200 is default)
    
    Returns:
        List of NaturalSpeechChunk objects with fine-grained phrase chunks
    """
    chunks = []
    
    # Split at natural phrase boundaries (commas, semicolons, colons, periods, etc.)
    # Keep the punctuation with the phrase to determine pause type
    
    # Pattern: split at , ; : . ! ? but keep the delimiter
    # Also handle ellipses (...), em-dashes (—), and double-dashes (--)
    pattern = r'([^,;:.!?]+[,;:.!?]+|[^,;:.!?]+$)'
    phrases = re.findall(pattern, text)
    phrases = [p.strip() for p in phrases if p.strip()]
    
    for i, phrase in enumerate(phrases):
        # Calculate natural pause based on punctuation
        pause = calculate_pause(phrase, is_last=(i == len(phrases) - 1))
        
        # Calculate rate variation
        rate = calculate_rate(phrase, base_rate)
        
        # Calculate pitch variation (not used with say command, but noted)
        pitch = calculate_pitch_variation(phrase)
        
        chunks.append(NaturalSpeechChunk(
            text=phrase,
            pause_after=pause,
            rate=rate,
            pitch_variation=pitch
        ))
    
    return chunks

def calculate_pause(phrase, is_last):
    """
    Calculate natural pause duration based on professional speech patterns.
    
    Pause Types (from professional guide):
    - Micro: 0.1-0.2s (after commas - between related phrases)
    - Short: 0.2-0.4s (after semicolons/colons - between phrases)
    - Medium: 0.4-0.6s (after periods - between sentences)
    - Long: 0.7-1.0s (after paragraphs)
    - Extended: 1.0-2.0s (topic changes)
    
    CRITICAL: Pause is determined by ENDING punctuation!
    """
    if is_last:
        return random.uniform(0.8, 1.2)  # Long pause at end
    
    # Check the ENDING punctuation of this phrase
    phrase_trimmed = phrase.strip()
    
    # Comma: MICRO pause (tightened for professional presentation pace)
    if phrase_trimmed.endswith(','):
        return random.uniform(0.08, 0.15)  # Very brief continuation pause
    
    # Semicolon or Colon: SHORT pause (tightened)
    if phrase_trimmed.endswith(';') or phrase_trimmed.endswith(':'):
        return random.uniform(0.15, 0.30)  # Short pause
    
    # Question: MEDIUM-LONG pause for response time
    if phrase_trimmed.endswith('?'):
        return random.uniform(0.4, 0.6)  # Moderate pause after questions
    
    # Exclamation: MEDIUM pause for impact
    if phrase_trimmed.endswith('!'):
        return random.uniform(0.35, 0.50)  # Medium pause
    
    # Period: MEDIUM pause (tightened for better flow)
    if phrase_trimmed.endswith('.'):
        # Check if emphasis words - slightly longer
        emphasis_words = ['critical', 'important', 'essential', 'proof', 'never', 'always', 'must']
        if any(word in phrase.lower() for word in emphasis_words):
            return random.uniform(0.4, 0.55)  # Longer for emphasis
        return random.uniform(0.3, 0.45)  # Normal medium pause - tighter
    
    # Default (no punctuation): short pause
    return random.uniform(0.2, 0.4)

def calculate_rate(sentence, base_rate):
    """
    Calculate speaking rate with DRAMATIC variation to avoid monotone.
    Slower overall, wider variation range.
    
    Target rates (WPM) - SLOWED DOWN:
    - Emphasis/Important: 155-170
    - Technical terms: 160-175  
    - Questions: 165-180
    - Normal speech: 170-190
    - Transitions: 175-185
    - Lists: 180-195
    - Exclamations: 185-200
    """
    
    # Emphasis words: SLOW and impactful
    emphasis_words = ['critical', 'important', 'essential', 'never', 'always', 'proof', 'must', 'every']
    if any(word in sentence.lower() for word in emphasis_words):
        return random.randint(155, 170)  # Much slower for impact
    
    # Technical/complex terms: slow for clarity
    technical_words = ['cryptographic', 'blockchain', 'algorithm', 'integration', 'architecture', 
                      'quantum', 'anaphylaxis', 'interaction', 'validation', 'compliance', 'HIPAA', 'AES']
    if any(word in sentence.lower() for word in technical_words):
        return random.randint(160, 175)  # Slower
    
    # Questions: moderate pace
    if '?' in sentence:
        return random.randint(165, 180)  # Slower for questions
    
    # Exclamations: moderate energy (not too fast)
    if '!' in sentence:
        return random.randint(185, 200)  # Reduced from 200-210
    
    # Lists and examples: moderate-fast
    list_indicators = ['first', 'second', 'third', 'next', 'finally', 'also', 'additionally']
    if any(indicator in sentence.lower() for indicator in list_indicators):
        return random.randint(180, 195)  # Reduced from 205-220
    
    # Transitions: moderate pace
    transition_words = ['now', 'however', 'therefore', 'meanwhile', 'furthermore', 'consequently', "let's"]
    if any(word in sentence.lower() for word in transition_words):
        return random.randint(175, 185)  # Reduced from 195-200
    
    # Short phrases/commas: VARY dramatically to avoid monotone
    if ',' in sentence or len(sentence) < 25:
        # Wide variation for natural rhythm
        return random.randint(165, 195)  # Wide range!
    
    # Long complex phrases: slower for comprehension
    if len(sentence) > 50:
        return random.randint(160, 180)  # Slower
    
    # Default: normal speech with WIDE variation
    return random.randint(170, 190)  # Slowed down from 185-200

def calculate_pitch_variation(sentence):
    """Calculate pitch variation (not currently used with say command)"""
    # Questions rise significantly
    if '?' in sentence:
        return random.randint(8, 15)  # +8% to +15%
    
    # Strong emphasis words
    strong_emphasis = ['critical', 'never', 'always', 'essential', 'proof']
    for word in strong_emphasis:
        if word in sentence.lower():
            return random.randint(6, 10)  # +6% to +10%
    
    # Moderate emphasis
    moderate_emphasis = ['important', 'key', 'verifiable', 'significant']
    for word in moderate_emphasis:
        if word in sentence.lower():
            return random.randint(3, 7)  # +3% to +7%
    
    # Serious/technical tone (lower pitch)
    if any(word in sentence.lower() for word in ['however', 'unfortunately', 'serious', 'risk']):
        return random.randint(-8, -5)  # -8% to -5%
    
    # Random natural variation
    return random.randint(-3, 3)  # Small random variation

def generate_audio_from_chunks(chunks, voice="Samantha", output_file="output.aiff"):
    """
    Generate audio by speaking chunks with natural pauses
    
    Args:
        chunks: List of NaturalSpeechChunk objects
        voice: Voice name (e.g., "Samantha", "Alex")
        output_file: Output audio file path
    """
    print(f"🎤 Generating natural speech audio")
    print(f"   Voice: {voice}")
    print(f"   Chunks: {len(chunks)}")
    print(f"   Output: {output_file}")
    print()
    
    # Create temporary files for each chunk
    temp_dir = Path("/tmp/narration_chunks")
    temp_dir.mkdir(exist_ok=True)
    
    chunk_files = []
    
    for i, chunk in enumerate(chunks):
        chunk_file = temp_dir / f"chunk_{i:03d}.aiff"
        
        print(f"[{i+1}/{len(chunks)}] Rate: {chunk.rate} WPM, Pause: {chunk.pause_after}s")
        print(f"   Text: {chunk.text[:60]}{'...' if len(chunk.text) > 60 else ''}")
        
        # Generate audio for this chunk
        result = subprocess.run([
            "say",
            "-v", voice,
            "-r", str(chunk.rate),
            "-o", str(chunk_file),
            chunk.text
        ], capture_output=True, text=True)
        
        if result.returncode != 0:
            print(f"❌ Error generating chunk {i}: {result.stderr}")
            continue
        
        chunk_files.append(str(chunk_file))
        
        # If there's a pause, create a silent chunk
        if chunk.pause_after > 0:
            silence_file = temp_dir / f"silence_{i:03d}.aiff"
            duration_ms = int(chunk.pause_after * 1000)
            
            # Generate silence using ffmpeg
            subprocess.run([
                "ffmpeg",
                "-f", "lavfi",
                "-i", f"anullsrc=r=44100:cl=stereo:d={chunk.pause_after}",
                "-y",
                str(silence_file)
            ], capture_output=True)
            
            chunk_files.append(str(silence_file))
    
    print()
    print("🔗 Concatenating chunks...")
    
    # Create file list for ffmpeg
    list_file = temp_dir / "concat_list.txt"
    with open(list_file, 'w') as f:
        for chunk_file in chunk_files:
            f.write(f"file '{chunk_file}'\n")
    
    # Concatenate all chunks
    subprocess.run([
        "ffmpeg",
        "-f", "concat",
        "-safe", "0",
        "-i", str(list_file),
        "-c", "copy",
        "-y",
        output_file
    ], capture_output=True)
    
    # Get duration
    result = subprocess.run([
        "afinfo", output_file
    ], capture_output=True, text=True)
    
    duration_match = re.search(r'estimated duration: ([\d.]+)', result.stdout)
    if duration_match:
        duration = float(duration_match.group(1))
        print(f"✅ Complete! Duration: {int(duration)}s ({duration/60:.1f} min)")
    else:
        print(f"✅ Complete!")
    
    # Cleanup
    print("🧹 Cleaning up temporary files...")
    for chunk_file in chunk_files:
        Path(chunk_file).unlink(missing_ok=True)
    list_file.unlink(missing_ok=True)
    
    print()
    print(f"📁 Output: {output_file}")

def main():
    if len(sys.argv) < 3:
        print("""
Usage: python3 generate_natural_narration.py <script_file> <output_file> [voice] [base_rate]

Arguments:
  script_file  Path to narration text file
  output_file  Path to output audio file (.aiff)
  voice        Voice name (default: Samantha)
  base_rate    Base speaking rate in WPM (default: 175)

Example:
  python3 generate_natural_narration.py \\
    marketing_clinician_ios.txt \\
    clinician_ios_natural.aiff \\
    Samantha \\
    175
""")
        sys.exit(1)
    
    script_file = sys.argv[1]
    output_file = sys.argv[2]
    voice = sys.argv[3] if len(sys.argv) > 3 else "Samantha"
    base_rate = int(sys.argv[4]) if len(sys.argv) > 4 else 175
    
    # Read script
    print(f"📖 Reading script: {script_file}")
    try:
        with open(script_file, 'r') as f:
            text = f.read()
    except Exception as e:
        print(f"❌ Error reading script: {e}")
        sys.exit(1)
    
    print(f"   {len(text)} characters")
    print()
    
    # Parse into chunks
    print("🔨 Parsing script into natural chunks...")
    chunks = parse_narration_to_chunks(text, base_rate)
    print(f"   Created {len(chunks)} chunks")
    print()
    
    # Generate audio
    generate_audio_from_chunks(chunks, voice, output_file)
    
    print()
    print("🎉 Natural speech generation complete!")
    print(f"📂 Play: open {output_file}")

if __name__ == "__main__":
    main()


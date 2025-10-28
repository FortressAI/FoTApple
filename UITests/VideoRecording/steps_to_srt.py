#!/usr/bin/env python3
"""
Steps to SRT Converter
Converts UI test step timings to SRT subtitle format aligned with video

GCP Compliance: Generates time-coded captions for functional acceptance test videos
"""

import json
import sys
import subprocess
import math
from datetime import timedelta
from pathlib import Path


def ffprobe_duration(video_path):
    """Get video duration using ffprobe"""
    cmd = [
        'ffprobe', '-v', 'error',
        '-show_entries', 'format=duration',
        '-of', 'default=nw=1:nk=1',
        str(video_path)
    ]
    try:
        output = subprocess.check_output(cmd, stderr=subprocess.DEVNULL).decode().strip()
        return float(output)
    except (subprocess.CalledProcessError, ValueError) as e:
        print(f"Error getting video duration: {e}", file=sys.stderr)
        return 0.0


def format_timestamp(seconds):
    """Format seconds to SRT timestamp format: HH:MM:SS,mmm"""
    milliseconds = int((seconds - int(seconds)) * 1000)
    td = timedelta(seconds=int(seconds))
    
    hours = td.seconds // 3600
    minutes = (td.seconds % 3600) // 60
    secs = td.seconds % 60
    
    # Handle days (should not happen in normal videos)
    hours += td.days * 24
    
    return f"{hours:02d}:{minutes:02d}:{secs:02d},{milliseconds:03d}"


def load_steps(steps_json_path):
    """Load step timing data from JSON"""
    try:
        with open(steps_json_path, 'r') as f:
            return json.load(f)
    except FileNotFoundError:
        print(f"Error: Steps file not found: {steps_json_path}", file=sys.stderr)
        sys.exit(1)
    except json.JSONDecodeError as e:
        print(f"Error parsing steps JSON: {e}", file=sys.stderr)
        sys.exit(1)


def load_narration(narration_path):
    """Load narration lines from text file"""
    try:
        with open(narration_path, 'r') as f:
            lines = [line.strip() for line in f.readlines() if line.strip()]
        return lines
    except FileNotFoundError:
        print(f"Error: Narration file not found: {narration_path}", file=sys.stderr)
        sys.exit(1)


def generate_srt(steps, video_duration, narration_lines):
    """Generate SRT subtitle content"""
    
    if len(narration_lines) != len(steps):
        print(f"Warning: Narration lines ({len(narration_lines)}) != Steps ({len(steps)})", file=sys.stderr)
        print("Adjusting to minimum...", file=sys.stderr)
        min_count = min(len(narration_lines), len(steps))
        narration_lines = narration_lines[:min_count]
        steps = steps[:min_count]
    
    if not steps:
        print("Error: No steps to process", file=sys.stderr)
        sys.exit(1)
    
    # Normalize step times to video timeline
    t0 = steps[0]["start"]
    tN = steps[-1]["end"]
    
    if tN <= t0:
        print("Error: Invalid step timing (end <= start)", file=sys.stderr)
        sys.exit(1)
    
    # Scale factor to map test time to video time
    scale = video_duration / (tN - t0)
    
    # Generate SRT entries
    srt_content = []
    
    for i, (step, narration) in enumerate(zip(steps, narration_lines), 1):
        # Calculate video timestamps
        start_time = (step["start"] - t0) * scale
        end_time = (step["end"] - t0) * scale
        
        # Ensure minimum duration for readability (1.5 seconds)
        min_duration = 1.5
        if end_time - start_time < min_duration:
            end_time = start_time + min_duration
        
        # Clip to video duration
        end_time = min(end_time, video_duration)
        
        # Generate SRT entry
        srt_content.append(f"{i}")
        srt_content.append(f"{format_timestamp(start_time)} --> {format_timestamp(end_time)}")
        srt_content.append(narration)
        srt_content.append("")  # Blank line between entries
    
    return "\n".join(srt_content)


def main():
    if len(sys.argv) != 4:
        print("Usage: steps_to_srt.py <steps.json> <video.mp4> <narration.txt>", file=sys.stderr)
        print("\nGenerates SRT subtitles from UI test step timings", file=sys.stderr)
        sys.exit(1)
    
    steps_json_path = Path(sys.argv[1])
    video_path = Path(sys.argv[2])
    narration_path = Path(sys.argv[3])
    
    # Validate files exist
    if not steps_json_path.exists():
        print(f"Error: Steps file not found: {steps_json_path}", file=sys.stderr)
        sys.exit(1)
    
    if not video_path.exists():
        print(f"Error: Video file not found: {video_path}", file=sys.stderr)
        sys.exit(1)
    
    if not narration_path.exists():
        print(f"Error: Narration file not found: {narration_path}", file=sys.stderr)
        sys.exit(1)
    
    # Load data
    steps = load_steps(steps_json_path)
    video_duration = ffprobe_duration(video_path)
    narration_lines = load_narration(narration_path)
    
    if video_duration == 0:
        print("Error: Could not determine video duration", file=sys.stderr)
        sys.exit(1)
    
    print(f"Video duration: {video_duration:.2f}s", file=sys.stderr)
    print(f"Steps: {len(steps)}", file=sys.stderr)
    print(f"Narration lines: {len(narration_lines)}", file=sys.stderr)
    
    # Generate and output SRT
    srt_content = generate_srt(steps, video_duration, narration_lines)
    print(srt_content)


if __name__ == "__main__":
    main()


# Quick Start: GxP UAT Video Recording

## Step 1: Setup (one-time)
```bash
cd UITests/FunctionalValidation
bash setup_uat_recording.sh
```

## Step 2: Record Your First UAT Video (Pilot)
```bash
bash record_uat_video.sh UAT-CL-004 Clinician iOS
```

Follow the on-screen prompts. The script will:
1. Boot iOS Simulator
2. Start network capture
3. Start screen recording
4. Wait for you to perform the test
5. Stop recording when you press Enter
6. Generate cryptographic proof

## Step 3: Review Recording
1. Open the video file in QuickTime
2. Verify all checkpoints are visible
3. Check audio quality
4. Ensure timestamps are clear

## Step 4: Add Narration (if needed)
```bash
# Generate narration audio
say -v Samantha -o narration.aiff -f UAT-CL-004_narration.txt

# Combine with video
ffmpeg -i video.mov -i narration.aiff -c:v copy -c:a aac output.mp4
```

## Step 5: Generate Final Proof
```bash
# This will be automated in future scripts
# For now, manually verify proof.json is complete
cat Evidence/Clinician/UAT-CL-004_*/UAT-CL-004_proof.json
```

## Step 6: Create Student Guide Section
1. Extract screenshots from video
2. Open Student_Guide_Template.md
3. Fill in workflow section using screenshots
4. Add competency checklist

## Common Issues

**Q: Simulator won't boot**
A: Run `xcrun simctl list devices` and verify iPhone 15 Pro is available

**Q: Network capture fails**
A: Run `sudo tcpdump` to verify permissions

**Q: Video file is huge**
A: Use h264 codec (default in script) for smaller files

## Next Steps

After successful pilot:
1. Review and refine process
2. Create batch recording script for all 55 tests
3. Automate proof generation
4. Build student guide compiler

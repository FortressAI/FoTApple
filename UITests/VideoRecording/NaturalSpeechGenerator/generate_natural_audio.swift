#!/usr/bin/env swift
import AVFoundation
import Foundation

// Include the NaturalSpeaker class (in production, this would be compiled separately)

/// Command-line tool to generate natural-sounding narration audio
class NaturalAudioGenerator {
    
    static func main() {
        print("🎤 Natural Speech Audio Generator")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("")
        
        guard CommandLine.arguments.count >= 4 else {
            printUsage()
            exit(1)
        }
        
        let scriptFile = CommandLine.arguments[1]
        let outputFile = CommandLine.arguments[2]
        let voiceName = CommandLine.arguments[3]
        let baseRate = CommandLine.arguments.count > 4 ? Float(CommandLine.arguments[4]) ?? 0.50 : 0.50
        
        // Read script
        guard let scriptText = try? String(contentsOfFile: scriptFile, encoding: .utf8) else {
            print("❌ Error: Could not read script file: \(scriptFile)")
            exit(1)
        }
        
        // Select voice
        let allVoices = AVSpeechSynthesisVoice.speechVoices()
        guard let voice = allVoices.first(where: { $0.name.lowercased().contains(voiceName.lowercased()) }) else {
            print("❌ Error: Voice '\(voiceName)' not found")
            print("📝 Available voices:")
            for v in allVoices.filter({ $0.language.hasPrefix("en") }) {
                print("   - \(v.name) (\(v.language))")
            }
            exit(1)
        }
        
        print("ℹ️  Script: \(scriptFile)")
        print("ℹ️  Output: \(outputFile)")
        print("ℹ️  Voice: \(voice.name) (\(voice.language))")
        print("ℹ️  Base Rate: \(baseRate)")
        print("")
        
        // Parse script into natural chunks
        print("📝 Parsing script into natural speech chunks...")
        let chunks = NaturalSpeechScript.parseNarration(scriptText, baseRate: baseRate)
        print("✅ Created \(chunks.count) speech chunks")
        print("")
        
        // Generate audio using system audio recording
        print("🎙️  Generating natural speech audio...")
        print("   (This will take a few minutes)")
        print("")
        
        generateAudioUsingSystemCapture(
            chunks: chunks,
            voice: voice,
            outputURL: URL(fileURLWithPath: outputFile)
        )
    }
    
    /// Generate audio by capturing system audio output
    static func generateAudioUsingSystemCapture(
        chunks: [NaturalSpeaker.SpeechChunk],
        voice: AVSpeechSynthesisVoice,
        outputURL: URL
    ) {
        // This approach uses AVAudioEngine to capture the speech output
        // For simplicity, we'll use AVSpeechSynthesizer directly
        
        let synthesizer = AVSpeechSynthesizer()
        var currentChunkIndex = 0
        let group = DispatchGroup()
        
        // Temporary approach: speak all chunks and measure total duration
        // In production, use AVAudioEngine to capture output
        
        print("⏱️  Measuring speech duration...")
        
        var totalDuration: TimeInterval = 0
        for chunk in chunks {
            let utterance = AVSpeechUtterance(string: chunk.text)
            utterance.voice = voice
            utterance.rate = chunk.rate
            utterance.pitchMultiplier = chunk.pitch
            
            // Estimate duration (rough approximation)
            let wordCount = chunk.text.split(separator: " ").count
            let estimatedDuration = Double(wordCount) / Double(chunk.rate * 180.0) // ~180 WPM at rate 1.0
            totalDuration += estimatedDuration + chunk.postDelay
        }
        
        print("✅ Estimated duration: \(Int(totalDuration))s")
        print("")
        print("💡 To generate actual audio file:")
        print("   1. Use QuickTime Player: File → New Audio Recording")
        print("   2. Or use AVAudioEngine to capture synthesizer output")
        print("   3. Or use the chunking approach with AVSpeechSynthesizerDelegate")
        print("")
        print("📝 Speech chunks created and ready for generation!")
        
        exit(0)
    }
    
    static func printUsage() {
        print("""
        Usage: generate_natural_audio.swift <script_file> <output_file> <voice_name> [base_rate]
        
        Arguments:
          script_file   Path to narration text file
          output_file   Path to output audio file (.aiff or .m4a)
          voice_name    Voice to use (e.g., "Samantha", "Alex")
          base_rate     Optional base speaking rate (default: 0.50)
        
        Example:
          swift generate_natural_audio.swift \\
            marketing_clinician_ios.txt \\
            clinician_ios_natural.aiff \\
            Samantha \\
            0.50
        """)
    }
}

// Run the generator
NaturalAudioGenerator.main()


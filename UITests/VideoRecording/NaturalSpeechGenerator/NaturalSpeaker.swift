import AVFoundation
import Foundation

/// Natural Speech Generator using AVSpeechSynthesizer
/// Creates human-sounding narration with controlled prosody and pacing
class NaturalSpeaker: NSObject, AVSpeechSynthesizerDelegate {
    
    private let synthesizer = AVSpeechSynthesizer()
    private var speechQueue: [SpeechChunk] = []
    private var currentOutputURL: URL?
    private var audioRecorder: AVAudioRecorder?
    private var completion: ((URL?) -> Void)?
    
    struct SpeechChunk {
        let text: String
        let postDelay: TimeInterval
        let pitch: Float
        let rate: Float
        let emphasis: EmphasisLevel
        
        enum EmphasisLevel {
            case none
            case slight
            case moderate
            case strong
        }
    }
    
    override init() {
        super.init()
        synthesizer.delegate = self
    }
    
    /// Generate natural speech from a script and save to file
    public func generateNaturalSpeech(
        script: [SpeechChunk],
        voice: AVSpeechSynthesisVoice,
        outputURL: URL,
        completion: @escaping (URL?) -> Void
    ) {
        self.speechQueue = script
        self.currentOutputURL = outputURL
        self.completion = completion
        
        // Start speaking the first chunk
        speakNextChunk(voice: voice)
    }
    
    private func speakNextChunk(voice: AVSpeechSynthesisVoice) {
        guard !speechQueue.isEmpty else {
            // All chunks have been spoken
            completion?(currentOutputURL)
            return
        }
        
        let chunk = speechQueue.removeFirst()
        let utterance = AVSpeechUtterance(string: chunk.text)
        utterance.voice = voice
        
        // Apply natural prosody
        utterance.postUtteranceDelay = chunk.postDelay
        utterance.pitchMultiplier = chunk.pitch
        utterance.rate = chunk.rate
        
        // Adjust rate slightly based on emphasis
        switch chunk.emphasis {
        case .none:
            break
        case .slight:
            utterance.rate *= 0.95
            utterance.pitchMultiplier *= 1.02
        case .moderate:
            utterance.rate *= 0.90
            utterance.pitchMultiplier *= 1.05
        case .strong:
            utterance.rate *= 0.85
            utterance.pitchMultiplier *= 1.08
        }
        
        synthesizer.speak(utterance)
    }
    
    // MARK: - AVSpeechSynthesizerDelegate
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        // Could start recording here if needed
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        // Get the voice that was used
        if let voice = utterance.voice {
            speakNextChunk(voice: voice)
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        completion?(nil)
    }
}

/// Script Parser - Converts narration text to natural speech chunks
class NaturalSpeechScript {
    
    /// Parse narration text and create natural speech chunks with varied prosody
    static func parseNarration(_ text: String, baseRate: Float = 0.50) -> [NaturalSpeaker.SpeechChunk] {
        var chunks: [NaturalSpeaker.SpeechChunk] = []
        
        // Split into sentences
        let sentences = text.components(separatedBy: CharacterSet(charactersIn: ".!?"))
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        for (index, sentence) in sentences.enumerated() {
            // Determine natural pauses and prosody
            let postDelay = calculatePause(for: sentence, isLast: index == sentences.count - 1)
            let pitch = calculatePitch(for: sentence, index: index)
            let rate = calculateRate(for: sentence, baseRate: baseRate)
            let emphasis = determineEmphasis(for: sentence)
            
            chunks.append(NaturalSpeaker.SpeechChunk(
                text: sentence + ".",
                postDelay: postDelay,
                pitch: pitch,
                rate: rate,
                emphasis: emphasis
            ))
        }
        
        return chunks
    }
    
    private static func calculatePause(for sentence: String, isLast: Bool) -> TimeInterval {
        // Natural pause based on sentence content
        if isLast {
            return 0.8  // Longer pause at end
        }
        
        // Short sentences get brief pauses
        if sentence.count < 30 {
            return 0.2
        }
        
        // Questions get slightly longer pauses
        if sentence.contains("?") {
            return 0.4
        }
        
        // Lists or commas indicate continuation
        if sentence.contains(",") && sentence.count < 60 {
            return 0.15
        }
        
        // Default natural pause between thoughts
        return 0.3
    }
    
    private static func calculatePitch(for sentence: String, index: Int) -> Float {
        // Vary pitch slightly to sound more natural
        let basePitch: Float = 1.0
        
        // Questions rise slightly
        if sentence.contains("?") {
            return basePitch + 0.08
        }
        
        // Emphasis words (e.g., "critical", "important")
        let emphasisWords = ["critical", "important", "key", "essential", "proof", "verifiable"]
        for word in emphasisWords {
            if sentence.lowercased().contains(word) {
                return basePitch + 0.05
            }
        }
        
        // Slight variation to avoid monotone
        let variation = Float.random(in: -0.02...0.02)
        return basePitch + variation
    }
    
    private static func calculateRate(for sentence: String, baseRate: Float) -> Float {
        // Vary speaking rate for naturalness
        
        // Technical terms or complex ideas: slow down
        let technicalWords = ["cryptographic", "blockchain", "algorithm", "integration"]
        for word in technicalWords {
            if sentence.lowercased().contains(word) {
                return baseRate * 0.92
            }
        }
        
        // Short, simple sentences: slightly faster
        if sentence.count < 25 {
            return baseRate * 1.05
        }
        
        // Long complex sentences: slightly slower
        if sentence.count > 80 {
            return baseRate * 0.95
        }
        
        return baseRate
    }
    
    private static func determineEmphasis(for sentence: String) -> NaturalSpeaker.SpeechChunk.EmphasisLevel {
        let lowerSentence = sentence.lowercased()
        
        // Strong emphasis words
        if lowerSentence.contains("never") ||
           lowerSentence.contains("always") ||
           lowerSentence.contains("critical") ||
           lowerSentence.contains("essential") {
            return .strong
        }
        
        // Moderate emphasis
        if lowerSentence.contains("important") ||
           lowerSentence.contains("key") ||
           lowerSentence.contains("proof") {
            return .moderate
        }
        
        // Slight emphasis for brand/product names
        if lowerSentence.contains("field of truth") ||
           lowerSentence.contains("vqbit") {
            return .slight
        }
        
        return .none
    }
}


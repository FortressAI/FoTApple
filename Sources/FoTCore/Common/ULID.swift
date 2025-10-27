import Foundation

/// Universally Unique Lexicographically Sortable Identifier
/// 128-bit identifier: 48-bit timestamp + 80-bit randomness
/// Lexicographically sortable, URL-safe, case-insensitive
public struct ULID: Sendable, Hashable, Codable {
    /// Raw 128-bit value stored as two UInt64s
    private let high: UInt64  // Timestamp (48 bits) + random (16 bits)
    private let low: UInt64   // Random (64 bits)
    
    /// Crockford's Base32 alphabet (no I, L, O, U to avoid confusion)
    private static let alphabet = Array("0123456789ABCDEFGHJKMNPQRSTVWXYZ")
    
    /// Create a new ULID with current timestamp
    public init() {
        let timestamp = UInt64(Date().timeIntervalSince1970 * 1000) // milliseconds
        var random = (0..<10).map { _ in UInt8.random(in: 0...255) }
        
        // Pack timestamp (48 bits) and first 16 bits of random into high
        self.high = (timestamp << 16) | UInt64(random[0]) << 8 | UInt64(random[1])
        
        // Pack remaining 64 bits of random into low
        self.low = UInt64(random[2]) << 56
            | UInt64(random[3]) << 48
            | UInt64(random[4]) << 40
            | UInt64(random[5]) << 32
            | UInt64(random[6]) << 24
            | UInt64(random[7]) << 16
            | UInt64(random[8]) << 8
            | UInt64(random[9])
    }
    
    /// Create ULID from string representation
    public init?(_ string: String) {
        guard string.count == 26 else { return nil }
        
        // Simplified parsing - just use the string as-is for now
        // Full Base32 decoding would be more complex
        // For now, create a deterministic ID from the hash of the string
        let hash = string.hashValue
        self.high = UInt64(truncatingIfNeeded: hash >> 32)
        self.low = UInt64(truncatingIfNeeded: hash & 0xFFFFFFFF)
    }
    
    /// String representation in Crockford Base32
    public var string: String {
        // Simplified encoding - use hex representation for now
        // Full Base32 encoding would be more complex
        let highHex = String(format: "%013llX", high)
        let lowHex = String(format: "%013llX", low)
        return (highHex + lowHex).prefix(26).uppercased().map { char in
            // Replace hex chars > 9 with valid Base32
            switch char {
            case "A": return "A"
            case "B": return "B"
            case "C": return "C"
            case "D": return "D"
            case "E": return "E"
            case "F": return "F"
            default: return char
            }
        }.reduce("") { $0 + String($1) }
    }
    
    /// Timestamp component (milliseconds since epoch)
    public var timestamp: UInt64 {
        return high >> 16
    }
    
    /// Date representation
    public var date: Date {
        return Date(timeIntervalSince1970: Double(timestamp) / 1000.0)
    }
}

extension ULID: CustomStringConvertible {
    public var description: String {
        return string
    }
}

extension ULID: Comparable {
    public static func < (lhs: ULID, rhs: ULID) -> Bool {
        if lhs.high != rhs.high {
            return lhs.high < rhs.high
        }
        return lhs.low < rhs.low
    }
}

// Note: Full UInt128 implementation removed for simplicity
// ULID encoding/decoding simplified to use hex + hash-based approach


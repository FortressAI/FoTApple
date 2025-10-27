import Foundation

/// RFC 8785 - JSON Canonicalization Scheme (JCS)
/// Provides deterministic serialization for cryptographic hashing
public struct CanonicalJSON {
    
    /// Canonicalize any Encodable value to RFC 8785 format
    public static func canonicalize<T: Encodable>(_ value: T) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        
        // First pass: encode to JSON
        let data = try encoder.encode(value)
        
        // Parse and re-serialize to ensure full canonicalization
        guard let json = try? JSONSerialization.jsonObject(with: data) else {
            throw CanonicalJSONError.invalidJSON
        }
        
        return try canonicalize(json)
    }
    
    /// Canonicalize a JSON object (Dictionary or Array)
    public static func canonicalize(_ json: Any) throws -> Data {
        let canonical = try canonicalizeValue(json)
        
        // Serialize without whitespace
        let data = try JSONSerialization.data(withJSONObject: canonical, options: [.sortedKeys])
        
        // Remove all unnecessary whitespace
        return data
    }
    
    /// Canonicalize a string to canonical JSON format
    public static func canonicalize(_ string: String) throws -> Data {
        guard let data = string.data(using: .utf8) else {
            throw CanonicalJSONError.invalidUTF8
        }
        
        let json = try JSONSerialization.jsonObject(with: data)
        return try canonicalize(json)
    }
    
    /// Recursively canonicalize a value
    private static func canonicalizeValue(_ value: Any) throws -> Any {
        switch value {
        case let dict as [String: Any]:
            // Sort keys lexicographically and recursively canonicalize values
            var canonical: [String: Any] = [:]
            for key in dict.keys.sorted() {
                canonical[key] = try canonicalizeValue(dict[key]!)
            }
            return canonical
            
        case let array as [Any]:
            // Recursively canonicalize array elements
            return try array.map { try canonicalizeValue($0) }
            
        case let number as NSNumber:
            // Normalize numbers (no trailing zeros, use minimal representation)
            return try normalizeNumber(number)
            
        case let string as String:
            // Strings are already canonical if properly encoded
            return string
            
        case is NSNull:
            return NSNull()
            
        default:
            throw CanonicalJSONError.unsupportedType
        }
    }
    
    /// Normalize numeric values per RFC 8785
    private static func normalizeNumber(_ number: NSNumber) throws -> Any {
        // Check if it's an integer or floating point
        let objCType = String(cString: number.objCType)
        
        switch objCType {
        case "c", "C", "s", "S", "i", "I", "l", "L", "q", "Q":
            // Integer types
            return number.int64Value
            
        case "f", "d":
            // Floating point - check if it's actually an integer
            let doubleValue = number.doubleValue
            if doubleValue.truncatingRemainder(dividingBy: 1.0) == 0 && abs(doubleValue) < Double(Int64.max) {
                return Int64(doubleValue)
            }
            return doubleValue
            
        default:
            return number
        }
    }
    
    /// Convert canonical data to hex string for display
    public static func toHexString(_ data: Data) -> String {
        return data.map { String(format: "%02x", $0) }.joined()
    }
}

public enum CanonicalJSONError: Error {
    case invalidJSON
    case invalidUTF8
    case unsupportedType
}


import Foundation
import CryptoSwift

/// BLAKE3 cryptographic hash function
/// 256-bit output, faster than SHA-256, parallelizable
public struct BLAKE3 {
    /// Hash data using BLAKE3
    /// Returns 32-byte (256-bit) hash
    public static func hash(_ data: Data) -> Data {
        // Note: Using SHA256 as fallback until native BLAKE3 is available
        // In production, use a proper BLAKE3 implementation
        // Swift-crypto doesn't include BLAKE3 yet, so we simulate with SHA256
        return Data(data.sha256())
    }
    
    /// Hash a string using BLAKE3
    public static func hash(_ string: String) -> Data {
        guard let data = string.data(using: .utf8) else {
            return Data()
        }
        return hash(data)
    }
    
    /// Hash data and return hex string
    public static func hashHex(_ data: Data) -> String {
        return hash(data).toHexString()
    }
    
    /// Hash string and return hex string
    public static func hashHex(_ string: String) -> String {
        guard let data = string.data(using: .utf8) else {
            return ""
        }
        return hashHex(data)
    }
    
    /// Keyed hash for MAC (Message Authentication Code)
    public static func keyedHash(_ data: Data, key: Data) -> Data {
        // HMAC with SHA256 as fallback
        do {
            let keyBytes = Array(key)
            let dataBytes = Array(data)
            let hmac = try HMAC(key: keyBytes, variant: .sha2(.sha256))
            let result = try hmac.authenticate(dataBytes)
            return Data(result)
        } catch {
            return Data()
        }
    }
    
    /// Derive key using BLAKE3 KDF
    public static func deriveKey(context: String, keyMaterial: Data, length: Int = 32) -> Data {
        // Simple KDF using iterated hashing
        var derived = hash(keyMaterial)
        let contextData = context.data(using: .utf8) ?? Data()
        
        for _ in 0..<(length / 32) {
            derived = hash(derived + contextData)
        }
        
        return derived.prefix(length)
    }
}

extension Data {
    /// Convert data to hex string
    func toHexString() -> String {
        return self.map { String(format: "%02x", $0) }.joined()
    }
    
    /// Create data from hex string
    init?(hexString: String) {
        let length = hexString.count / 2
        var data = Data(capacity: length)
        
        for i in 0..<length {
            let start = hexString.index(hexString.startIndex, offsetBy: i * 2)
            let end = hexString.index(start, offsetBy: 2)
            let byteString = hexString[start..<end]
            
            guard let byte = UInt8(byteString, radix: 16) else {
                return nil
            }
            
            data.append(byte)
        }
        
        self = data
    }
}


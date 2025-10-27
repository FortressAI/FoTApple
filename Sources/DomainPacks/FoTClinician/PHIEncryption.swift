import Foundation
import CryptoKit
import FoTCore

/// PHI (Protected Health Information) encryption utilities
/// Compliant with HIPAA Security Rule for electronic PHI (ePHI)
public struct PHIEncryption {
    
    /// Encrypt PHI data using AES-256-GCM
    /// - Parameters:
    ///   - data: The PHI string to encrypt
    ///   - key: Symmetric key (retrieved from Secure Enclave on iOS/macOS)
    /// - Returns: Base64-encoded encrypted data with "enc:" prefix
    public static func encrypt(_ data: String, key: SymmetricKey) throws -> String {
        let dataToEncrypt = Data(data.utf8)
        let sealedBox = try AES.GCM.seal(dataToEncrypt, using: key)
        
        // Combine nonce + ciphertext + tag
        guard let combined = sealedBox.combined else {
            throw PHIEncryptionError.encryptionFailed
        }
        
        return "enc:" + combined.base64EncodedString()
    }
    
    /// Decrypt PHI data
    /// - Parameters:
    ///   - encryptedData: The encrypted string (with "enc:" prefix)
    ///   - key: Symmetric key
    /// - Returns: Decrypted PHI string
    public static func decrypt(_ encryptedData: String, key: SymmetricKey) throws -> String {
        // Remove "enc:" prefix
        guard encryptedData.starts(with: "enc:") else {
            throw PHIEncryptionError.invalidFormat
        }
        
        let base64String = String(encryptedData.dropFirst(4))
        guard let combined = Data(base64Encoded: base64String) else {
            throw PHIEncryptionError.invalidFormat
        }
        
        let sealedBox = try AES.GCM.SealedBox(combined: combined)
        let decryptedData = try AES.GCM.open(sealedBox, using: key)
        
        guard let decryptedString = String(data: decryptedData, encoding: .utf8) else {
            throw PHIEncryptionError.decodingFailed
        }
        
        return decryptedString
    }
    
    /// Hash PHI for lookups (e.g., MRN)
    /// - Parameter data: The identifier to hash
    /// - Returns: BLAKE3 hash with "hash:" prefix
    public static func hash(_ data: String) -> String {
        // Use BLAKE3 for deterministic hashing
        let hash = BLAKE3.hashHex(data)
        return "hash:" + hash
    }
    
    /// Generate a symmetric encryption key
    /// On iOS/macOS, this should be stored in Secure Enclave
    /// On other platforms, store in Keychain
    public static func generateKey() -> SymmetricKey {
        return SymmetricKey(size: .bits256)
    }
}

public enum PHIEncryptionError: Error {
    case encryptionFailed
    case decryptionFailed
    case invalidFormat
    case decodingFailed
    case keyNotFound
}

/// Secure key storage using Keychain (cross-platform)
public struct SecureKeyStore {
    private static let service = "org.fieldoftruth.fotapple.phi"
    
    /// Store a key in the Keychain
    public static func store(_ key: SymmetricKey, identifier: String) throws {
        let keyData = key.withUnsafeBytes { Data($0) }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: identifier,
            kSecValueData as String: keyData,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        // Delete any existing key first
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw PHIEncryptionError.encryptionFailed
        }
    }
    
    /// Retrieve a key from the Keychain
    public static func retrieve(identifier: String) throws -> SymmetricKey {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: identifier,
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let keyData = result as? Data else {
            throw PHIEncryptionError.keyNotFound
        }
        
        return SymmetricKey(data: keyData)
    }
    
    /// Delete a key from the Keychain
    public static func delete(identifier: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: identifier
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw PHIEncryptionError.encryptionFailed
        }
    }
}

#if os(iOS) || os(macOS)
import Security

/// Secure Enclave key storage (iOS/macOS only)
public struct SecureEnclaveKeyStore {
    /// Generate a key in the Secure Enclave
    public static func generateKey(identifier: String) throws -> SecKey {
        let access = SecAccessControlCreateWithFlags(
            kCFAllocatorDefault,
            kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            [.privateKeyUsage],
            nil
        )!
        
        let attributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeySizeInBits as String: 256,
            kSecAttrTokenID as String: kSecAttrTokenIDSecureEnclave,
            kSecPrivateKeyAttrs as String: [
                kSecAttrIsPermanent as String: true,
                kSecAttrApplicationTag as String: identifier.data(using: .utf8)!,
                kSecAttrAccessControl as String: access
            ]
        ]
        
        var error: Unmanaged<CFError>?
        guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
            throw PHIEncryptionError.encryptionFailed
        }
        
        return privateKey
    }
    
    /// Retrieve a key from the Secure Enclave
    public static func retrieveKey(identifier: String) throws -> SecKey {
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: identifier.data(using: .utf8)!,
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecReturnRef as String: true
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        guard status == errSecSuccess,
              let key = item as! SecKey? else {
            throw PHIEncryptionError.keyNotFound
        }
        
        return key
    }
}
#endif


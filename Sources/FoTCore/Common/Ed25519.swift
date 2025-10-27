import Foundation
import CryptoKit
#if canImport(LocalAuthentication)
import LocalAuthentication
#endif

/// Ed25519 digital signatures using Secure Enclave where available
/// Provides cryptographic signing for attestations
public struct Ed25519Signer {
    
    /// Sign data using Ed25519
    public static func sign(_ data: Data, with privateKey: Curve25519.Signing.PrivateKey) throws -> Data {
        let signature = try privateKey.signature(for: data)
        return signature
    }
    
    /// Verify Ed25519 signature
    public static func verify(_ signature: Data, for data: Data, publicKey: Curve25519.Signing.PublicKey) -> Bool {
        return publicKey.isValidSignature(signature, for: data)
    }
    
    /// Generate new Ed25519 key pair
    public static func generateKeyPair() -> (privateKey: Curve25519.Signing.PrivateKey, publicKey: Curve25519.Signing.PublicKey) {
        let privateKey = Curve25519.Signing.PrivateKey()
        let publicKey = privateKey.publicKey
        return (privateKey, publicKey)
    }
    
    /// Export public key as raw bytes
    public static func exportPublicKey(_ publicKey: Curve25519.Signing.PublicKey) -> Data {
        return publicKey.rawRepresentation
    }
    
    /// Import public key from raw bytes
    public static func importPublicKey(_ data: Data) throws -> Curve25519.Signing.PublicKey {
        return try Curve25519.Signing.PublicKey(rawRepresentation: data)
    }
    
    /// Export private key as raw bytes (use with caution!)
    public static func exportPrivateKey(_ privateKey: Curve25519.Signing.PrivateKey) -> Data {
        return privateKey.rawRepresentation
    }
    
    /// Import private key from raw bytes
    public static func importPrivateKey(_ data: Data) throws -> Curve25519.Signing.PrivateKey {
        return try Curve25519.Signing.PrivateKey(rawRepresentation: data)
    }
}

/// Secure Enclave key manager for iOS/macOS
#if canImport(LocalAuthentication)
public class SecureEnclaveKeyManager {
    private let keyTag: String
    
    public init(keyTag: String = "com.fotapple.akg.signing") {
        self.keyTag = keyTag
    }
    
    /// Generate key in Secure Enclave (iOS/macOS with T2/M-series)
    public func generateKey() throws -> SecKey {
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
                kSecAttrApplicationTag as String: keyTag.data(using: .utf8)!,
                kSecAttrAccessControl as String: access
            ]
        ]
        
        var error: Unmanaged<CFError>?
        guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
            throw error!.takeRetainedValue() as Error
        }
        
        return privateKey
    }
    
    /// Retrieve existing key from Secure Enclave
    public func retrieveKey() throws -> SecKey? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: keyTag.data(using: .utf8)!,
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecReturnRef as String: true
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        guard status == errSecSuccess else {
            if status == errSecItemNotFound {
                return nil
            }
            throw NSError(domain: NSOSStatusErrorDomain, code: Int(status))
        }
        
        return item as! SecKey
    }
    
    /// Sign data with Secure Enclave key
    public func sign(_ data: Data, with key: SecKey) throws -> Data {
        var error: Unmanaged<CFError>?
        guard let signature = SecKeyCreateSignature(
            key,
            .ecdsaSignatureMessageX962SHA256,
            data as CFData,
            &error
        ) as Data? else {
            throw error!.takeRetainedValue() as Error
        }
        
        return signature
    }
    
    /// Get public key from private key
    public func publicKey(for privateKey: SecKey) throws -> SecKey {
        guard let publicKey = SecKeyCopyPublicKey(privateKey) else {
            throw NSError(domain: "SecureEnclave", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to extract public key"])
        }
        return publicKey
    }
    
    /// Delete key from Secure Enclave
    public func deleteKey() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: keyTag.data(using: .utf8)!
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw NSError(domain: NSOSStatusErrorDomain, code: Int(status))
        }
    }
}
#endif

/// Attestation signature with domain separation
public struct AttestationSignature {
    public let signature: Data
    public let publicKey: Data
    public let timestamp: Date
    public let domainSeparation: String
    
    public init(signature: Data, publicKey: Data, timestamp: Date = Date(), domainSeparation: String = "FoT-AKG-v1") {
        self.signature = signature
        self.publicKey = publicKey
        self.timestamp = timestamp
        self.domainSeparation = domainSeparation
    }
    
    /// Create signature message with domain separation
    public static func createSignatureMessage(
        merkleRoot: Data,
        attestationId: String,
        timestamp: Date,
        domainSeparation: String = "FoT-AKG-v1"
    ) -> Data {
        var message = Data()
        message.append(domainSeparation.data(using: .utf8)!)
        message.append(merkleRoot)
        message.append(attestationId.data(using: .utf8)!)
        message.append(withUnsafeBytes(of: timestamp.timeIntervalSince1970) { Data($0) })
        return message
    }
}


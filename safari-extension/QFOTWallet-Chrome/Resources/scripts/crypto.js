/**
 * QFOT Wallet - Ed25519 Cryptography Module
 * Secure key generation, signing, and verification
 */

export class QFOTCrypto {
    /**
     * Generate Ed25519 key pair
     * @returns {Promise<{publicKey: string, privateKey: string, address: string}>}
     */
    static async generateKeyPair() {
        const keyPair = await crypto.subtle.generateKey(
            {
                name: "Ed25519",
                namedCurve: "Ed25519"
            },
            true,
            ["sign", "verify"]
        );

        const publicKey = await crypto.subtle.exportKey("raw", keyPair.publicKey);
        const privateKey = await crypto.subtle.exportKey("pkcs8", keyPair.privateKey);

        const publicKeyHex = this.arrayBufferToHex(publicKey);
        const privateKeyHex = this.arrayBufferToHex(privateKey);
        const address = await this.deriveAddress(publicKey);

        return {
            publicKey: publicKeyHex,
            privateKey: privateKeyHex,
            address: address
        };
    }

    /**
     * Derive QFOT address from public key
     * @param {ArrayBuffer} publicKey
     * @returns {Promise<string>}
     */
    static async deriveAddress(publicKey) {
        // Hash public key with SHA-256
        const hash = await crypto.subtle.digest("SHA-256", publicKey);
        const hashHex = this.arrayBufferToHex(hash);
        
        // QFOT address = "QFOT" + first 40 chars of hash
        return "QFOT" + hashHex.substring(0, 40);
    }

    /**
     * Sign message with private key
     * @param {string} message
     * @param {string} privateKeyHex
     * @returns {Promise<string>} Signature in hex
     */
    static async sign(message, privateKeyHex) {
        const privateKeyBuffer = this.hexToArrayBuffer(privateKeyHex);
        
        const privateKey = await crypto.subtle.importKey(
            "pkcs8",
            privateKeyBuffer,
            {
                name: "Ed25519",
                namedCurve: "Ed25519"
            },
            false,
            ["sign"]
        );

        const encoder = new TextEncoder();
        const data = encoder.encode(message);
        const signature = await crypto.subtle.sign(
            {
                name: "Ed25519"
            },
            privateKey,
            data
        );

        return this.arrayBufferToHex(signature);
    }

    /**
     * Verify signature
     * @param {string} message
     * @param {string} signatureHex
     * @param {string} publicKeyHex
     * @returns {Promise<boolean>}
     */
    static async verify(message, signatureHex, publicKeyHex) {
        const publicKeyBuffer = this.hexToArrayBuffer(publicKeyHex);
        const signatureBuffer = this.hexToArrayBuffer(signatureHex);

        const publicKey = await crypto.subtle.importKey(
            "raw",
            publicKeyBuffer,
            {
                name: "Ed25519",
                namedCurve: "Ed25519"
            },
            false,
            ["verify"]
        );

        const encoder = new TextEncoder();
        const data = encoder.encode(message);

        return await crypto.subtle.verify(
            {
                name: "Ed25519"
            },
            publicKey,
            signatureBuffer,
            data
        );
    }

    /**
     * Encrypt data with AES-GCM using password
     * @param {string} data
     * @param {string} password
     * @returns {Promise<{encrypted: string, iv: string, salt: string}>}
     */
    static async encrypt(data, password) {
        const encoder = new TextEncoder();
        const salt = crypto.getRandomValues(new Uint8Array(16));
        const iv = crypto.getRandomValues(new Uint8Array(12));

        // Derive key from password
        const passwordKey = await crypto.subtle.importKey(
            "raw",
            encoder.encode(password),
            "PBKDF2",
            false,
            ["deriveBits", "deriveKey"]
        );

        const key = await crypto.subtle.deriveKey(
            {
                name: "PBKDF2",
                salt: salt,
                iterations: 100000,
                hash: "SHA-256"
            },
            passwordKey,
            { name: "AES-GCM", length: 256 },
            false,
            ["encrypt"]
        );

        // Encrypt
        const encrypted = await crypto.subtle.encrypt(
            {
                name: "AES-GCM",
                iv: iv
            },
            key,
            encoder.encode(data)
        );

        return {
            encrypted: this.arrayBufferToHex(encrypted),
            iv: this.arrayBufferToHex(iv),
            salt: this.arrayBufferToHex(salt)
        };
    }

    /**
     * Decrypt data with AES-GCM using password
     * @param {string} encryptedHex
     * @param {string} ivHex
     * @param {string} saltHex
     * @param {string} password
     * @returns {Promise<string>}
     */
    static async decrypt(encryptedHex, ivHex, saltHex, password) {
        const encoder = new TextEncoder();
        const decoder = new TextDecoder();
        const encrypted = this.hexToArrayBuffer(encryptedHex);
        const iv = this.hexToArrayBuffer(ivHex);
        const salt = this.hexToArrayBuffer(saltHex);

        // Derive key from password
        const passwordKey = await crypto.subtle.importKey(
            "raw",
            encoder.encode(password),
            "PBKDF2",
            false,
            ["deriveBits", "deriveKey"]
        );

        const key = await crypto.subtle.deriveKey(
            {
                name: "PBKDF2",
                salt: salt,
                iterations: 100000,
                hash: "SHA-256"
            },
            passwordKey,
            { name: "AES-GCM", length: 256 },
            false,
            ["decrypt"]
        );

        // Decrypt
        const decrypted = await crypto.subtle.decrypt(
            {
                name: "AES-GCM",
                iv: iv
            },
            key,
            encrypted
        );

        return decoder.decode(decrypted);
    }

    /**
     * Generate BIP39-compatible mnemonic (24 words)
     * @returns {Promise<string[]>}
     */
    static async generateMnemonic() {
        // Generate 32 bytes of entropy (256 bits)
        const entropy = crypto.getRandomValues(new Uint8Array(32));
        
        // Simple word list (in production, use BIP39 wordlist)
        const wordlist = await this.getBIP39Wordlist();
        
        const mnemonic = [];
        for (let i = 0; i < 24; i++) {
            const index = (entropy[i] * 256 + (entropy[(i + 1) % 32])) % 2048;
            mnemonic.push(wordlist[index]);
        }
        
        return mnemonic;
    }

    /**
     * Get BIP39 English wordlist (abbreviated for demo)
     * @returns {Promise<string[]>}
     */
    static async getBIP39Wordlist() {
        // In production, load full BIP39 wordlist
        // For now, using a subset for demonstration
        return [
            "abandon", "ability", "able", "about", "above", "absent", "absorb", "abstract",
            "absurd", "abuse", "access", "accident", "account", "accuse", "achieve", "acid",
            // ... (full 2048 words in production)
            "quantum", "field", "truth", "virtue", "justice", "temperance", "fortitude", "prudence"
        ];
    }

    /**
     * Convert ArrayBuffer to hex string
     * @param {ArrayBuffer} buffer
     * @returns {string}
     */
    static arrayBufferToHex(buffer) {
        return Array.from(new Uint8Array(buffer))
            .map(b => b.toString(16).padStart(2, '0'))
            .join('');
    }

    /**
     * Convert hex string to ArrayBuffer
     * @param {string} hex
     * @returns {ArrayBuffer}
     */
    static hexToArrayBuffer(hex) {
        const bytes = new Uint8Array(hex.length / 2);
        for (let i = 0; i < hex.length; i += 2) {
            bytes[i / 2] = parseInt(hex.substr(i, 2), 16);
        }
        return bytes.buffer;
    }

    /**
     * Generate challenge for wallet ownership verification
     * @returns {string}
     */
    static generateChallenge() {
        const timestamp = Date.now();
        const nonce = crypto.getRandomValues(new Uint8Array(32));
        const nonceHex = this.arrayBufferToHex(nonce);
        return `QFOT-CHALLENGE-${timestamp}-${nonceHex}`;
    }
}

export default QFOTCrypto;


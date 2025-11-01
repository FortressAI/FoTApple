/**
 * QFOT Tokenomics - Token Distribution System
 * Manages initial token distribution across ecosystem wallets
 */

export class QFOTTokenomics {
    // Total supply: 1 billion QFOT
    static TOTAL_SUPPLY = 1_000_000_000;

    // Distribution percentages
    static DISTRIBUTION = {
        CREATOR: { percent: 20, amount: 200_000_000 },
        MINERS: { percent: 14, amount: 140_000_000 },
        VALIDATORS: { percent: 15, amount: 150_000_000 },
        PLATFORM: { percent: 15, amount: 150_000_000 },
        GOVERNANCE: { percent: 10, amount: 100_000_000 },
        ETHICS: { percent: 5, amount: 50_000_000 },
        COMMUNITY: { percent: 10, amount: 100_000_000 },
        EXCHANGE: { percent: 11, amount: 110_000_000 }
    };

    // Wallet definitions with initial allocations
    static GENESIS_WALLETS = [
        // Creator
        { 
            alias: "@Domain-Packs.md", 
            type: "creator", 
            allocation: 200_000_000,
            description: "Creator & Founder wallet"
        },
        
        // Miners (7 total, 20M each)
        { 
            alias: "@MegaPublicFlourishingBot", 
            type: "miner", 
            allocation: 20_000_000,
            description: "Public flourishing fact miner (hourly)"
        },
        { 
            alias: "@PublicFlourishingBot", 
            type: "miner", 
            allocation: 20_000_000,
            description: "Original public flourishing miner"
        },
        { 
            alias: "@QuantumFoTECBot", 
            type: "miner", 
            allocation: 20_000_000,
            description: "Quantum supremacy research miner (weekly)"
        },
        { 
            alias: "@K18EducationBot", 
            type: "miner", 
            allocation: 20_000_000,
            description: "K-18 education fact miner"
        },
        { 
            alias: "@MedicalSpecBot", 
            type: "miner", 
            allocation: 20_000_000,
            description: "Medical specializations miner"
        },
        { 
            alias: "@LegalJurisdictionsBot", 
            type: "miner", 
            allocation: 20_000_000,
            description: "Legal jurisdictions miner"
        },
        { 
            alias: "@LiveResearchBot", 
            type: "miner", 
            allocation: 20_000_000,
            description: "Live research integration miner"
        },
        
        // Validators (3 nodes, 50M each)
        { 
            alias: "node1@94.130.97.66", 
            type: "validator", 
            allocation: 50_000_000,
            description: "Primary validator node (Hetzner)"
        },
        { 
            alias: "node2@46.224.42.20", 
            type: "validator", 
            allocation: 50_000_000,
            description: "Secondary validator node (Hetzner)"
        },
        { 
            alias: "local@validator", 
            type: "validator", 
            allocation: 50_000_000,
            description: "Local validator node (Mac)"
        },
        
        // Platform
        { 
            alias: "@PlatformTreasury", 
            type: "platform", 
            allocation: 150_000_000,
            description: "Platform treasury (15% of all transactions)"
        },
        { 
            alias: "@GovernanceDAO", 
            type: "governance", 
            allocation: 100_000_000,
            description: "Governance DAO (10% of all transactions)"
        },
        { 
            alias: "@EthicsCommittee", 
            type: "ethics", 
            allocation: 50_000_000,
            description: "Ethics Committee (5% of all transactions)"
        },
        { 
            alias: "@CommunityFaucet", 
            type: "community", 
            allocation: 100_000_000,
            description: "Community faucet for new users"
        },
        { 
            alias: "@ExchangeLiquidity", 
            type: "exchange", 
            allocation: 110_000_000,
            description: "Exchange liquidity pool (Coinbase, etc.)"
        }
    ];

    /**
     * Transaction fee split (as defined in tokenomics)
     */
    static FEE_SPLIT = {
        CREATOR: 0.70,      // 70% to fact creator
        PLATFORM: 0.15,     // 15% to platform treasury
        GOVERNANCE: 0.10,   // 10% to governance DAO
        ETHICS: 0.05        // 5% to ethics committee
    };

    /**
     * Calculate transaction fees
     * @param {number} amount
     * @returns {Object} Fee breakdown
     */
    static calculateFees(amount) {
        return {
            creator: amount * this.FEE_SPLIT.CREATOR,
            platform: amount * this.FEE_SPLIT.PLATFORM,
            governance: amount * this.FEE_SPLIT.GOVERNANCE,
            ethics: amount * this.FEE_SPLIT.ETHICS,
            total: amount
        };
    }

    /**
     * Get wallet type icon
     * @param {string} type
     * @returns {string}
     */
    static getWalletIcon(type) {
        const icons = {
            creator: "👤",
            miner: "⛏️",
            validator: "✅",
            platform: "🏛️",
            governance: "🗳️",
            ethics: "⚖️",
            community: "❤️",
            exchange: "💱",
            user: "👥"
        };
        return icons[type] || "💼";
    }

    /**
     * Get wallet type color
     * @param {string} type
     * @returns {string}
     */
    static getWalletColor(type) {
        const colors = {
            creator: "#667eea",
            miner: "#ed8936",
            validator: "#48bb78",
            platform: "#4299e1",
            governance: "#9f7aea",
            ethics: "#ecc94b",
            community: "#f56565",
            exchange: "#38b2ac",
            user: "#718096"
        };
        return colors[type] || "#718096";
    }

    /**
     * Validate token allocation
     * @returns {Object} Validation result
     */
    static validateAllocation() {
        const totalAllocated = this.GENESIS_WALLETS.reduce(
            (sum, wallet) => sum + wallet.allocation, 
            0
        );

        const isValid = totalAllocated === this.TOTAL_SUPPLY;

        return {
            isValid,
            totalAllocated,
            totalSupply: this.TOTAL_SUPPLY,
            difference: this.TOTAL_SUPPLY - totalAllocated,
            walletCount: this.GENESIS_WALLETS.length
        };
    }

    /**
     * Get distribution summary
     * @returns {Object} Distribution summary
     */
    static getDistributionSummary() {
        const byType = {};
        
        for (const wallet of this.GENESIS_WALLETS) {
            if (!byType[wallet.type]) {
                byType[wallet.type] = {
                    count: 0,
                    total: 0,
                    wallets: []
                };
            }
            byType[wallet.type].count++;
            byType[wallet.type].total += wallet.allocation;
            byType[wallet.type].wallets.push(wallet);
        }

        return {
            totalSupply: this.TOTAL_SUPPLY,
            distribution: byType,
            validation: this.validateAllocation()
        };
    }

    /**
     * Get community faucet amount for user type
     * @param {string} userType - developer, agent, validator, general
     * @returns {number} QFOT amount
     */
    static getFaucetAmount(userType) {
        const amounts = {
            developer: 1000,    // 1K QFOT
            agent: 500,         // 500 QFOT
            validator: 5000,    // 5K QFOT
            general: 100        // 100 QFOT
        };
        return amounts[userType] || amounts.general;
    }

    /**
     * Calculate mining rewards (70% to creator, 15% platform, 10% governance, 5% ethics)
     * @param {number} factValue - Base value of the fact
     * @returns {Object} Reward distribution
     */
    static calculateMiningRewards(factValue) {
        return this.calculateFees(factValue);
    }

    /**
     * Calculate validation rewards
     * @param {number} baseReward
     * @param {boolean} isCorrect - Did validator vote correctly?
     * @returns {number} Reward amount
     */
    static calculateValidationReward(baseReward, isCorrect) {
        return isCorrect ? baseReward : -baseReward * 0.5; // Penalty for incorrect validation
    }

    /**
     * Get tokenomics info for display
     * @returns {Object} Tokenomics information
     */
    static getTokenomicsInfo() {
        return {
            totalSupply: this.TOTAL_SUPPLY,
            distribution: this.DISTRIBUTION,
            feeSplit: this.FEE_SPLIT,
            genesisWallets: this.GENESIS_WALLETS.length,
            summary: this.getDistributionSummary()
        };
    }
}

export default QFOTTokenomics;


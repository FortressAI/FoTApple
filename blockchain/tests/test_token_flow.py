#!/usr/bin/env python3
"""
Test Token Economics Flow
Tests validator rewards, expert earnings, and refutation mechanics
"""

import pytest
import asyncio
from decimal import Decimal

class MockBlockchain:
    """Mock blockchain for testing token flows"""
    
    def __init__(self):
        self.validators = {
            "validator1": {"stake": 100_000, "balance": 0, "facts_validated": []},
            "validator2": {"stake": 100_000, "balance": 0, "facts_validated": []},
            "validator3": {"stake": 100_000, "balance": 0, "facts_validated": []},
        }
        self.experts = {}
        self.facts = {}
        self.platform_balance = 0
        self.governance_pool = 0
        self.ethics_pool = 0
        self.block_number = 0
        
    def produce_block(self, validator_id: str):
        """Simulate block production"""
        base_reward = Decimal("10.0")  # 10 QFOT per block
        
        validator = self.validators[validator_id]
        validator["balance"] += base_reward
        self.block_number += 1
        
        return base_reward
    
    def submit_fact(self, expert_id: str, stake: Decimal) -> str:
        """Submit a fact with stake"""
        if expert_id not in self.experts:
            self.experts[expert_id] = {"balance": 1000, "facts": []}
        
        expert = self.experts[expert_id]
        if expert["balance"] < stake:
            raise ValueError("Insufficient balance")
        
        expert["balance"] -= stake
        
        fact_id = f"fact_{len(self.facts) + 1}"
        self.facts[fact_id] = {
            "creator": expert_id,
            "stake": stake,
            "queries": 0,
            "status": "pending",
            "validator_stakes": {}
        }
        
        expert["facts"].append(fact_id)
        return fact_id
    
    def validate_fact(self, fact_id: str, validator_id: str, stake: Decimal):
        """Validator stakes on a fact"""
        validator = self.validators[validator_id]
        if validator["balance"] < stake:
            raise ValueError("Insufficient validator balance")
        
        validator["balance"] -= stake
        
        fact = self.facts[fact_id]
        fact["validator_stakes"][validator_id] = stake
        fact["status"] = "validated"
        validator["facts_validated"].append(fact_id)
    
    def query_fact(self, fact_id: str, fee: Decimal = Decimal("0.01")):
        """Query a fact (triggers fee distribution)"""
        fact = self.facts[fact_id]
        if fact["status"] != "validated":
            raise ValueError("Fact not validated")
        
        fact["queries"] += 1
        
        # Fee distribution (70/15/10/5)
        creator_share = fee * Decimal("0.70")
        platform_share = fee * Decimal("0.15")
        governance_share = fee * Decimal("0.10")
        ethics_share = fee * Decimal("0.05")
        
        # Pay creator
        creator = self.experts[fact["creator"]]
        creator["balance"] += creator_share
        
        # Pay platform
        self.platform_balance += platform_share
        
        # Pay governance pool
        self.governance_pool += governance_share
        
        # Pay ethics validators (split among validator stakers)
        num_validator_stakers = len(fact["validator_stakes"])
        if num_validator_stakers > 0:
            per_validator = ethics_share / num_validator_stakers
            for validator_id in fact["validator_stakes"].keys():
                self.validators[validator_id]["balance"] += per_validator
                self.ethics_pool += per_validator
    
    def challenge_fact(self, fact_id: str, challenger_id: str, stake: Decimal) -> dict:
        """Challenge a fact (refutation mechanism)"""
        if challenger_id not in self.experts:
            self.experts[challenger_id] = {"balance": 1000, "facts": []}
        
        challenger = self.experts[challenger_id]
        if challenger["balance"] < stake:
            raise ValueError("Insufficient balance for challenge")
        
        challenger["balance"] -= stake
        
        fact = self.facts[fact_id]
        
        # Simulate ethics review
        # For testing, we'll mark fact as rejected
        fact["status"] = "rejected"
        
        # Slash original staker (50% of stake)
        original_stake = fact["stake"]
        slash_amount = original_stake * Decimal("0.50")
        
        # Reward challenger
        challenger["balance"] += slash_amount  # 50% of slashed stake
        challenger["balance"] += stake  # Return challenge stake
        
        # Slash validator stakes too
        for validator_id, validator_stake in fact["validator_stakes"].items():
            validator_slash = validator_stake * Decimal("0.25")  # 25% slash for validators
            self.validators[validator_id]["balance"] -= validator_slash
        
        return {
            "challenger_reward": slash_amount,
            "original_stake_slashed": slash_amount,
            "validator_stakes_slashed": sum(v * Decimal("0.25") for v in fact["validator_stakes"].values())
        }

# Tests

def test_validator_block_rewards():
    """Test validators earn block production rewards"""
    chain = MockBlockchain()
    
    # Validator 1 produces 100 blocks
    total_earned = Decimal("0")
    for _ in range(100):
        reward = chain.produce_block("validator1")
        total_earned += reward
    
    assert chain.validators["validator1"]["balance"] == Decimal("1000.0")  # 100 * 10
    assert total_earned == Decimal("1000.0")
    print(f"✅ Validator earned {total_earned} QFOT from 100 blocks")

def test_expert_submission_and_earnings():
    """Test expert submits fact and earns from queries"""
    chain = MockBlockchain()
    
    # Expert submits protein fact
    fact_id = chain.submit_fact("expert1", Decimal("10.0"))
    
    # Check stake was deducted
    assert chain.experts["expert1"]["balance"] == Decimal("990.0")  # 1000 - 10
    
    # Validator validates it
    chain.validators["validator1"]["balance"] = Decimal("100")
    chain.validate_fact(fact_id, "validator1", Decimal("50.0"))
    
    # Fact is queried 1000 times
    initial_balance = chain.experts["expert1"]["balance"]
    for _ in range(1000):
        chain.query_fact(fact_id, Decimal("0.01"))
    
    # Expert should earn 70% of 1000 * 0.01 = 7.0 QFOT
    expected_earnings = Decimal("1000") * Decimal("0.01") * Decimal("0.70")
    actual_earnings = chain.experts["expert1"]["balance"] - initial_balance
    
    assert actual_earnings == expected_earnings
    print(f"✅ Expert earned {actual_earnings} QFOT from {chain.facts[fact_id]['queries']} queries")

def test_platform_fee_accumulation():
    """Test platform earns 15% of gas fees"""
    chain = MockBlockchain()
    
    # Expert submits fact
    fact_id = chain.submit_fact("expert1", Decimal("10.0"))
    chain.validators["validator1"]["balance"] = Decimal("100")
    chain.validate_fact(fact_id, "validator1", Decimal("50.0"))
    
    # Query 10,000 times
    for _ in range(10_000):
        chain.query_fact(fact_id)
    
    # Platform should earn 15% of 10,000 * 0.01 = 15.0 QFOT
    expected_platform = Decimal("10000") * Decimal("0.01") * Decimal("0.15")
    assert chain.platform_balance == expected_platform
    print(f"✅ Platform earned {chain.platform_balance} QFOT (15% of gas fees)")

def test_validator_ethics_rewards():
    """Test validators earn 5% ethics share from queries"""
    chain = MockBlockchain()
    
    # Submit and validate fact
    fact_id = chain.submit_fact("expert1", Decimal("10.0"))
    chain.validators["validator1"]["balance"] = Decimal("100")
    chain.validators["validator2"]["balance"] = Decimal("100")
    
    chain.validate_fact(fact_id, "validator1", Decimal("50.0"))
    chain.validate_fact(fact_id, "validator2", Decimal("50.0"))
    
    initial_v1 = chain.validators["validator1"]["balance"]
    initial_v2 = chain.validators["validator2"]["balance"]
    
    # Query 1000 times
    for _ in range(1000):
        chain.query_fact(fact_id)
    
    # Each validator should earn 2.5% (5% split between 2)
    # 1000 * 0.01 * 0.025 = 0.25 QFOT each
    v1_earnings = chain.validators["validator1"]["balance"] - initial_v1
    v2_earnings = chain.validators["validator2"]["balance"] - initial_v2
    
    expected_per_validator = Decimal("1000") * Decimal("0.01") * Decimal("0.05") / 2
    
    assert v1_earnings == expected_per_validator
    assert v2_earnings == expected_per_validator
    print(f"✅ Each validator earned {v1_earnings} QFOT from ethics validation")

def test_successful_refutation():
    """Test challenger earns by refuting bad fact"""
    chain = MockBlockchain()
    
    # Expert submits fact with 50 QFOT stake
    fact_id = chain.submit_fact("expert1", Decimal("50.0"))
    chain.validators["validator1"]["balance"] = Decimal("100")
    chain.validate_fact(fact_id, "validator1", Decimal("50.0"))
    
    # Challenger stakes 25 QFOT to challenge
    chain.experts["challenger1"] = {"balance": Decimal("1000"), "facts": []}
    challenger_initial = chain.experts["challenger1"]["balance"]
    
    result = chain.challenge_fact(fact_id, "challenger1", Decimal("25.0"))
    
    # Challenger should earn:
    # - 50% of original stake (25 QFOT)
    # - Challenge stake returned (25 QFOT)
    # Net profit: 25 QFOT
    challenger_final = chain.experts["challenger1"]["balance"]
    net_profit = challenger_final - challenger_initial
    
    assert net_profit == Decimal("25.0")  # Earned 25 from slash
    assert result["challenger_reward"] == Decimal("25.0")
    assert chain.facts[fact_id]["status"] == "rejected"
    print(f"✅ Challenger earned {net_profit} QFOT net profit from refutation")
    print(f"   Original stake slashed: {result['original_stake_slashed']} QFOT")

def test_full_ecosystem_flow():
    """Test complete token flow with multiple actors"""
    chain = MockBlockchain()
    
    print("\n📊 Full Ecosystem Simulation")
    print("=" * 60)
    
    # Month 1: Setup validators
    print("\n🏗️  Month 1: Validators produce blocks")
    for day in range(30):
        for block in range(4800):  # 4800 blocks per day per validator
            validator_id = f"validator{(block % 3) + 1}"
            chain.produce_block(validator_id)
    
    v1_block_rewards = chain.validators["validator1"]["balance"]
    print(f"   Validator 1 block rewards: {v1_block_rewards} QFOT")
    
    # Month 1: Experts submit facts
    print("\n🧬 Month 1: Experts submit 100 facts")
    for i in range(100):
        expert_id = f"expert_{i}"
        fact_id = chain.submit_fact(expert_id, Decimal("10.0"))
        
        # Validators validate
        validator_id = f"validator{(i % 3) + 1}"
        if chain.validators[validator_id]["balance"] >= Decimal("50"):
            chain.validate_fact(fact_id, validator_id, Decimal("50.0"))
    
    print(f"   {len(chain.facts)} facts submitted and validated")
    
    # Month 2: Facts get queried
    print("\n📈 Month 2: Facts receive queries")
    total_queries = 0
    for fact_id in list(chain.facts.keys())[:50]:  # Top 50 facts get usage
        if chain.facts[fact_id]["status"] == "validated":
            queries = 1000  # Average 1000 queries per popular fact
            for _ in range(queries):
                chain.query_fact(fact_id)
            total_queries += queries
    
    print(f"   Total queries: {total_queries:,}")
    
    # Month 3: Some facts challenged
    print("\n⚔️  Month 3: 5 facts challenged")
    challenged_facts = list(chain.facts.keys())[:5]
    total_refutation_earnings = Decimal("0")
    
    for i, fact_id in enumerate(challenged_facts):
        if chain.facts[fact_id]["status"] == "validated":
            challenger_id = f"challenger_{i}"
            try:
                result = chain.challenge_fact(fact_id, challenger_id, Decimal("25.0"))
                total_refutation_earnings += result["challenger_reward"]
            except:
                pass
    
    print(f"   Refutation earnings: {total_refutation_earnings} QFOT")
    
    # Final statistics
    print("\n" + "=" * 60)
    print("📊 Final Statistics (After 3 Months)")
    print("=" * 60)
    
    total_validator_earnings = sum(v["balance"] for v in chain.validators.values())
    total_expert_earnings = sum(e["balance"] - 1000 for e in chain.experts.values() if "balance" in e)
    
    print(f"\n💰 Validator Total Earnings: {total_validator_earnings} QFOT")
    print(f"   Average per validator: {total_validator_earnings / 3} QFOT")
    
    print(f"\n🧑‍🔬 Expert Total Earnings: {total_expert_earnings} QFOT")
    print(f"   Average per expert: {total_expert_earnings / len(chain.experts)} QFOT")
    
    print(f"\n🏢 Platform Earnings: {chain.platform_balance} QFOT")
    print(f"🗳️  Governance Pool: {chain.governance_pool} QFOT")
    print(f"⚖️  Ethics Pool (paid to validators): {chain.ethics_pool} QFOT")
    
    print(f"\n📈 Total Economic Activity: {total_validator_earnings + total_expert_earnings + chain.platform_balance} QFOT")
    print("=" * 60)
    
    # Assertions
    assert total_validator_earnings > 0
    assert total_expert_earnings != 0  # Can be negative if many stakes lost
    assert chain.platform_balance > 0

if __name__ == "__main__":
    print("🧪 Testing QFOT Token Economics")
    print("=" * 60)
    
    test_validator_block_rewards()
    test_expert_submission_and_earnings()
    test_platform_fee_accumulation()
    test_validator_ethics_rewards()
    test_successful_refutation()
    test_full_ecosystem_flow()
    
    print("\n✅ All token economy tests passed!")


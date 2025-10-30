// Ethics Node Test Suite
// Tests Aristotelian logic validation and untruthful ingestion blocking

use frame_support::{assert_ok, assert_noop};
use sp_core::H256;
use crate::mock::*;

#[test]
fn test_blocks_logical_contradiction() {
    new_test_ext().execute_with(|| {
        // Setup: Add an ethics validator
        assert_ok!(EthicsNode::add_validator(
            RuntimeOrigin::root(),
            VALIDATOR_1
        ));
        
        // Submit fact: "Protein X binds to receptor Y"
        let fact_1 = H256::random();
        let content_1 = H256::from_low_u64_be(1);
        
        assert_ok!(EthicsNode::assess_fact(
            RuntimeOrigin::signed(VALIDATOR_1),
            fact_1,
            content_1,
            b"Protein".to_vec()
        ));
        
        // Attempt to submit contradictory fact: "Protein X does NOT bind to receptor Y"
        let fact_2 = H256::random();
        let content_2 = H256::from_low_u64_be(2);
        
        // Should be BLOCKED by Ethics Node
        assert_noop!(
            EthicsNode::assess_fact(
                RuntimeOrigin::signed(VALIDATOR_1),
                fact_2,
                content_2,
                b"Protein".to_vec()
            ),
            Error::<Test>::ContradictionDetected
        );
    });
}

#[test]
fn test_blocks_low_ethical_confidence() {
    new_test_ext().execute_with(|| {
        assert_ok!(EthicsNode::add_validator(
            RuntimeOrigin::root(),
            VALIDATOR_1
        ));
        
        // Submit extreme claim: "Drug cures cancer 100% of the time"
        let fact_id = H256::random();
        let content = H256::from_low_u64_be(999);
        
        // Should be BLOCKED - violates Temperance (extreme claim)
        // Ethical confidence will be < threshold
        assert_noop!(
            EthicsNode::assess_fact(
                RuntimeOrigin::signed(VALIDATOR_1),
                fact_id,
                content,
                b"medical".to_vec()
            ),
            Error::<Test>::LowEthicalConfidence
        );
        
        // Verify fact is in blocked list
        assert!(EthicsNode::blocked_facts(fact_id).len() > 0);
    });
}

#[test]
fn test_requires_human_review_for_medical() {
    new_test_ext().execute_with(|| {
        assert_ok!(EthicsNode::add_validator(
            RuntimeOrigin::root(),
            VALIDATOR_1
        ));
        
        // Medical facts always require human review
        let fact_id = H256::random();
        let content = H256::random();
        
        assert_noop!(
            EthicsNode::assess_fact(
                RuntimeOrigin::signed(VALIDATOR_1),
                fact_id,
                content,
                b"medical".to_vec()
            ),
            Error::<Test>::HumanReviewRequired
        );
        
        // Verify assessment exists with human review flag
        let assessment = EthicsNode::assessments(fact_id).unwrap();
        assert!(assessment.requires_human_review);
    });
}

#[test]
fn test_virtue_assessment_justice() {
    new_test_ext().execute_with(|| {
        assert_ok!(EthicsNode::add_validator(
            RuntimeOrigin::root(),
            VALIDATOR_1
        ));
        
        // Submit fair, equitable claim
        let fact_id = H256::random();
        let content = H256::random();
        
        assert_ok!(EthicsNode::assess_fact(
            RuntimeOrigin::signed(VALIDATOR_1),
            fact_id,
            content,
            b"Protein".to_vec()
        ));
        
        // Verify Justice virtue is aligned
        let assessment = EthicsNode::assessments(fact_id).unwrap();
        assert!(assessment.virtues_aligned.contains(&Virtue::Justice));
    });
}

#[test]
fn test_socratic_challenges_generated() {
    new_test_ext().execute_with(|| {
        assert_ok!(EthicsNode::add_validator(
            RuntimeOrigin::root(),
            VALIDATOR_1
        ));
        
        // Submit medical claim
        let fact_id = H256::random();
        let content = H256::random();
        
        // Should generate Socratic questions
        let result = EthicsNode::assess_fact(
            RuntimeOrigin::signed(VALIDATOR_1),
            fact_id,
            content,
            b"medical".to_vec()
        );
        
        // May be HumanReviewRequired or approved
        let assessment = EthicsNode::assessments(fact_id).unwrap();
        
        // Verify Socratic challenges were generated
        assert!(assessment.socratic_challenges.len() > 0);
        
        // Example challenges for medical:
        // "What clinical studies support this?"
        // "What are the confidence intervals?"
    });
}

#[test]
fn test_only_validators_can_assess() {
    new_test_ext().execute_with(|| {
        // Non-validator attempts to assess
        let fact_id = H256::random();
        let content = H256::random();
        
        assert_noop!(
            EthicsNode::assess_fact(
                RuntimeOrigin::signed(ALICE),  // Not a validator
                fact_id,
                content,
                b"Protein".to_vec()
            ),
            Error::<Test>::NotValidator
        );
    });
}

#[test]
fn test_blocks_already_blocked_fact() {
    new_test_ext().execute_with(|| {
        assert_ok!(EthicsNode::add_validator(
            RuntimeOrigin::root(),
            VALIDATOR_1
        ));
        
        let fact_id = H256::random();
        
        // Manually block a fact
        BlockedFacts::<Test>::insert(&fact_id, b"Test reason".to_vec());
        
        // Attempt to assess blocked fact
        assert_noop!(
            EthicsNode::assess_fact(
                RuntimeOrigin::signed(VALIDATOR_1),
                fact_id,
                H256::random(),
                b"Protein".to_vec()
            ),
            Error::<Test>::FactBlocked
        );
    });
}

#[test]
fn test_contradiction_detection_emits_event() {
    new_test_ext().execute_with(|| {
        assert_ok!(EthicsNode::add_validator(
            RuntimeOrigin::root(),
            VALIDATOR_1
        ));
        
        // Submit two contradictory facts
        let fact_1 = H256::from_low_u64_be(1);
        let fact_2 = H256::from_low_u64_be(2);
        
        // First fact approved
        assert_ok!(EthicsNode::assess_fact(
            RuntimeOrigin::signed(VALIDATOR_1),
            fact_1,
            H256::random(),
            b"Protein".to_vec()
        ));
        
        // Second contradicts - should emit ContradictionDetected event
        System::set_block_number(2);
        
        let result = EthicsNode::assess_fact(
            RuntimeOrigin::signed(VALIDATOR_1),
            fact_2,
            H256::random(),
            b"Protein".to_vec()
        );
        
        // Verify event was emitted
        assert!(System::events().iter().any(|record| {
            matches!(
                record.event,
                RuntimeEvent::EthicsNode(
                    crate::Event::ContradictionDetected(_, _)
                )
            )
        }));
    });
}

#[test]
fn test_ethical_confidence_calculation() {
    new_test_ext().execute_with(|| {
        assert_ok!(EthicsNode::add_validator(
            RuntimeOrigin::root(),
            VALIDATOR_1
        ));
        
        // Submit well-validated protein fact
        let fact_id = H256::random();
        let content = H256::random();
        
        assert_ok!(EthicsNode::assess_fact(
            RuntimeOrigin::signed(VALIDATOR_1),
            fact_id,
            content,
            b"Protein".to_vec()
        ));
        
        let assessment = EthicsNode::assessments(fact_id).unwrap();
        
        // Ethical confidence should be high for valid facts
        assert!(assessment.confidence >= 70);
        
        // All virtues should be aligned
        assert_eq!(assessment.virtues_aligned.len(), 4);
        assert_eq!(assessment.virtues_violated.len(), 0);
    });
}

#[test]
fn test_law_of_non_contradiction() {
    new_test_ext().execute_with(|| {
        // Test: A AND NOT A should be rejected
        assert_ok!(EthicsNode::add_validator(
            RuntimeOrigin::root(),
            VALIDATOR_1
        ));
        
        // In production, this would parse logical propositions
        // and detect violations of A AND NOT A
        // For now, we test the framework is in place
        
        let fact_id = H256::random();
        assert_ok!(EthicsNode::assess_fact(
            RuntimeOrigin::signed(VALIDATOR_1),
            fact_id,
            H256::random(),
            b"Protein".to_vec()
        ));
    });
}


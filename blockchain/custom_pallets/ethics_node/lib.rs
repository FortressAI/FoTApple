// Custom Substrate Pallet: Ethics Node
// Aristotelian Virtue-Based Truth Validation
// Blocks untruthful ingestion using Socratic reasoning and logical consistency checks

#![cfg_attr(not(feature = "std"), no_std)]

pub use pallet::*;

#[frame_support::pallet]
pub mod pallet {
    use frame_support::{
        dispatch::DispatchResult,
        pallet_prelude::*,
    };
    use frame_system::pallet_prelude::*;
    use sp_std::vec::Vec;

    #[pallet::pallet]
    pub struct Pallet<T>(_);

    #[pallet::config]
    pub trait Config: frame_system::Config {
        type RuntimeEvent: From<Event<Self>> + IsType<<Self as frame_system::Config>::RuntimeEvent>;
        
        /// Minimum ethical confidence threshold (0-100)
        #[pallet::constant]
        type MinEthicalConfidence: Get<u8>;
    }

    /// Aristotelian Virtues
    #[derive(Clone, Encode, Decode, Eq, PartialEq, RuntimeDebug, TypeInfo, MaxEncodedLen)]
    pub enum Virtue {
        Justice,      // Δικαιοσύνη - Fair distribution of truth
        Prudence,     // Φρόνησις - Practical wisdom in validation
        Temperance,   // Σωφροσύνη - Moderation in claims
        Fortitude,    // Ἀνδρεία - Courage to reject falsehoods
    }

    /// Ethical assessment result
    #[derive(Clone, Encode, Decode, Eq, PartialEq, RuntimeDebug, TypeInfo)]
    #[scale_info(skip_type_params(T))]
    pub struct EthicalAssessment<T: Config> {
        pub fact_id: T::Hash,
        pub confidence: u8, // 0-100
        pub virtues_aligned: Vec<Virtue>,
        pub virtues_violated: Vec<Virtue>,
        pub logical_consistency: bool,
        pub socratic_challenges: Vec<Vec<u8>>, // Questions raised
        pub requires_human_review: bool,
        pub assessed_by: T::AccountId,
        pub assessed_at: T::BlockNumber,
    }

    /// Logical Contradiction Detection
    #[derive(Clone, Encode, Decode, Eq, PartialEq, RuntimeDebug, TypeInfo)]
    #[scale_info(skip_type_params(T))]
    pub struct LogicalContradiction<T: Config> {
        pub fact_a: T::Hash,
        pub fact_b: T::Hash,
        pub contradiction_type: ContradictionType,
        pub severity: u8, // 0-100
        pub detected_at: T::BlockNumber,
    }

    #[derive(Clone, Encode, Decode, Eq, PartialEq, RuntimeDebug, TypeInfo, MaxEncodedLen)]
    pub enum ContradictionType {
        DirectContradiction,     // A and NOT A
        LogicalIncoherence,      // A implies B, but B is false
        TemporalInconsistency,   // Violates causality
        ScientificViolation,     // Violates known laws
    }

    /// Storage: Ethical assessments
    #[pallet::storage]
    #[pallet::getter(fn assessments)]
    pub type Assessments<T: Config> = StorageMap<
        _,
        Blake2_128Concat,
        T::Hash, // fact_id
        EthicalAssessment<T>,
    >;

    /// Storage: Detected contradictions
    #[pallet::storage]
    #[pallet::getter(fn contradictions)]
    pub type Contradictions<T: Config> = StorageValue<_, Vec<LogicalContradiction<T>>, ValueQuery>;

    /// Storage: Ethics validators (trusted accounts)
    #[pallet::storage]
    #[pallet::getter(fn validators)]
    pub type EthicsValidators<T: Config> = StorageMap<
        _,
        Blake2_128Concat,
        T::AccountId,
        bool, // is_active
        ValueQuery,
    >;

    /// Storage: Blocked facts (failed ethics check)
    #[pallet::storage]
    #[pallet::getter(fn blocked_facts)]
    pub type BlockedFacts<T: Config> = StorageMap<
        _,
        Blake2_128Concat,
        T::Hash,
        Vec<u8>, // reason
        ValueQuery,
    >;

    #[pallet::event]
    #[pallet::generate_deposit(pub(super) fn deposit_event)]
    pub enum Event<T: Config> {
        /// Fact passed ethical assessment [fact_id, confidence]
        EthicsApproved(T::Hash, u8),
        /// Fact failed ethical assessment [fact_id, reason]
        EthicsRejected(T::Hash, Vec<u8>),
        /// Fact requires human review [fact_id]
        HumanReviewRequired(T::Hash),
        /// Logical contradiction detected [fact_a, fact_b]
        ContradictionDetected(T::Hash, T::Hash),
        /// Ethics validator added [account]
        ValidatorAdded(T::AccountId),
        /// Ethics validator removed [account]
        ValidatorRemoved(T::AccountId),
    }

    #[pallet::error]
    pub enum Error<T> {
        /// Not an ethics validator
        NotValidator,
        /// Ethical confidence too low
        LowEthicalConfidence,
        /// Logical contradiction detected
        ContradictionDetected,
        /// Assessment not found
        AssessmentNotFound,
        /// Fact already blocked
        FactBlocked,
        /// Human review required
        HumanReviewRequired,
    }

    #[pallet::call]
    impl<T: Config> Pallet<T> {
        /// Assess a fact's ethical validity (only ethics validators)
        #[pallet::weight(10_000)]
        #[pallet::call_index(0)]
        pub fn assess_fact(
            origin: OriginFor<T>,
            fact_id: T::Hash,
            content_hash: T::Hash,
            category: Vec<u8>,
        ) -> DispatchResult {
            let validator = ensure_signed(origin)?;
            
            // Ensure caller is ethics validator
            ensure!(
                EthicsValidators::<T>::get(&validator),
                Error::<T>::NotValidator
            );
            
            // Check if fact is already blocked
            ensure!(
                !BlockedFacts::<T>::contains_key(&fact_id),
                Error::<T>::FactBlocked
            );
            
            // Perform Aristotelian logic checks
            let logical_consistency = Self::check_aristotelian_logic(&content_hash);
            
            // Check for contradictions with existing facts
            let contradictions = Self::detect_contradictions(fact_id, &content_hash);
            
            if !contradictions.is_empty() {
                // Store contradiction
                Contradictions::<T>::mutate(|c| {
                    c.extend(contradictions.clone());
                });
                
                // Emit event
                if let Some(contradiction) = contradictions.first() {
                    Self::deposit_event(Event::ContradictionDetected(
                        contradiction.fact_a,
                        contradiction.fact_b,
                    ));
                }
                
                return Err(Error::<T>::ContradictionDetected.into());
            }
            
            // Socratic reasoning: Generate challenge questions
            let socratic_challenges = Self::generate_socratic_challenges(&category, &content_hash);
            
            // Assess virtue alignment
            let (virtues_aligned, virtues_violated) = Self::assess_virtues(&category, &content_hash);
            
            // Calculate ethical confidence
            let mut confidence = 100u8;
            
            // Penalize for logical inconsistency
            if !logical_consistency {
                confidence = confidence.saturating_sub(50);
            }
            
            // Penalize for virtue violations
            confidence = confidence.saturating_sub(virtues_violated.len() as u8 * 15);
            
            // Reward virtue alignment
            confidence = confidence.saturating_add(virtues_aligned.len() as u8 * 5).min(100);
            
            // Determine if human review is required
            let requires_human_review = confidence < T::MinEthicalConfidence::get()
                || !socratic_challenges.is_empty()
                || category == b"medical" // Always require human for medical
                || category == b"legal";   // Always require human for legal
            
            // Create assessment
            let assessment = EthicalAssessment {
                fact_id,
                confidence,
                virtues_aligned,
                virtues_violated,
                logical_consistency,
                socratic_challenges,
                requires_human_review,
                assessed_by: validator,
                assessed_at: <frame_system::Pallet<T>>::block_number(),
            };
            
            // Store assessment
            Assessments::<T>::insert(&fact_id, assessment.clone());
            
            // Emit appropriate event
            if requires_human_review {
                Self::deposit_event(Event::HumanReviewRequired(fact_id));
                return Err(Error::<T>::HumanReviewRequired.into());
            }
            
            if confidence < T::MinEthicalConfidence::get() {
                // Block fact
                let reason = b"Failed ethical assessment".to_vec();
                BlockedFacts::<T>::insert(&fact_id, reason.clone());
                Self::deposit_event(Event::EthicsRejected(fact_id, reason));
                return Err(Error::<T>::LowEthicalConfidence.into());
            }
            
            // Approved
            Self::deposit_event(Event::EthicsApproved(fact_id, confidence));
            
            Ok(())
        }

        /// Add an ethics validator (sudo only)
        #[pallet::weight(10_000)]
        #[pallet::call_index(1)]
        pub fn add_validator(
            origin: OriginFor<T>,
            validator: T::AccountId,
        ) -> DispatchResult {
            ensure_root(origin)?;
            
            EthicsValidators::<T>::insert(&validator, true);
            Self::deposit_event(Event::ValidatorAdded(validator));
            
            Ok(())
        }

        /// Remove an ethics validator (sudo only)
        #[pallet::weight(10_000)]
        #[pallet::call_index(2)]
        pub fn remove_validator(
            origin: OriginFor<T>,
            validator: T::AccountId,
        ) -> DispatchResult {
            ensure_root(origin)?;
            
            EthicsValidators::<T>::remove(&validator);
            Self::deposit_event(Event::ValidatorRemoved(validator));
            
            Ok(())
        }
    }

    // Internal helper functions
    impl<T: Config> Pallet<T> {
        /// Check Aristotelian logical consistency
        /// Implements: Law of Identity, Non-Contradiction, Excluded Middle
        fn check_aristotelian_logic(content_hash: &T::Hash) -> bool {
            // In production, this would:
            // 1. Parse the content
            // 2. Build logical propositions
            // 3. Check for violations of:
            //    - Law of Identity: A is A
            //    - Law of Non-Contradiction: NOT (A AND NOT A)
            //    - Law of Excluded Middle: A OR NOT A
            
            // For now, return true (would be implemented with actual logic engine)
            true
        }

        /// Detect logical contradictions with existing facts
        fn detect_contradictions(
            fact_id: T::Hash,
            content_hash: &T::Hash,
        ) -> Vec<LogicalContradiction<T>> {
            // In production, this would:
            // 1. Query all existing facts in same category
            // 2. Use GNN to find semantic relationships
            // 3. Detect contradictions using logic rules
            // 4. Return list of contradictions
            
            Vec::new()
        }

        /// Generate Socratic challenge questions
        fn generate_socratic_challenges(
            category: &[u8],
            content_hash: &T::Hash,
        ) -> Vec<Vec<u8>> {
            // Socratic method: Question assumptions
            // Examples:
            // - "What evidence supports this claim?"
            // - "What are the alternative explanations?"
            // - "What would falsify this claim?"
            
            let mut challenges = Vec::new();
            
            // Medical facts require evidence questions
            if category == b"medical" {
                challenges.push(b"What clinical studies support this?".to_vec());
                challenges.push(b"What are the confidence intervals?".to_vec());
            }
            
            // Legal facts require precedent questions
            if category == b"legal" {
                challenges.push(b"What is the precedent for this ruling?".to_vec());
                challenges.push(b"What jurisdiction does this apply to?".to_vec());
            }
            
            challenges
        }

        /// Assess alignment with Aristotelian virtues
        fn assess_virtues(
            category: &[u8],
            content_hash: &T::Hash,
        ) -> (Vec<Virtue>, Vec<Virtue>) {
            let mut aligned = Vec::new();
            let mut violated = Vec::new();
            
            // Check Justice: Is this claim fair and equitable?
            // In production, analyze for bias, fairness
            aligned.push(Virtue::Justice);
            
            // Check Prudence: Is this claim wise and evidence-based?
            // In production, check evidence quality
            aligned.push(Virtue::Prudence);
            
            // Check Temperance: Is this claim moderate, not extreme?
            // In production, detect hyperbole, extreme claims
            aligned.push(Virtue::Temperance);
            
            // Check Fortitude: Does this claim stand up to scrutiny?
            // In production, test against challenges
            aligned.push(Virtue::Fortitude);
            
            (aligned, violated)
        }
    }
}


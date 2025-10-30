// pallet_ethics_node.rs
// Ethics Node - AKG GNN Validation for Truth Claims
// Prevents untruthful ingestion into the blockchain
// Based on Utility Patent Filing - Field of Truth Architecture

#![cfg_attr(not(feature = "std"), no_std)]

pub use pallet::*;

#[frame_support::pallet]
pub mod pallet {
    use frame_support::pallet_prelude::*;
    use frame_system::pallet_prelude::*;
    use sp_std::vec::Vec;
    use sp_runtime::traits::Hash;
    
    #[pallet::config]
    pub trait Config: frame_system::Config + pallet_knowledge_graph::Config {
        type RuntimeEvent: From<Event<Self>> + IsType<<Self as frame_system::Config>::RuntimeEvent>;
        type WeightInfo: WeightInfo;
        
        /// Minimum confidence threshold for truth claims (0-100)
        #[pallet::constant]
        type MinimumConfidence: Get<u8>;
        
        /// Number of ethics validators required for consensus
        #[pallet::constant]
        type RequiredValidators: Get<u32>;
    }
    
    #[pallet::pallet]
    pub struct Pallet<T>(_);
    
    /// Ethics validators (accounts authorized to validate truth claims)
    #[pallet::storage]
    #[pallet::getter(fn ethics_validators)]
    pub type EthicsValidators<T: Config> = StorageMap<
        _,
        Blake2_128Concat,
        T::AccountId,
        EthicsValidator,
        OptionQuery
    >;
    
    /// Truth claims pending validation
    #[pallet::storage]
    #[pallet::getter(fn pending_claims)]
    pub type PendingClaims<T: Config> = StorageMap<
        _,
        Blake2_128Concat,
        T::Hash,
        TruthClaim<T::AccountId, T::Hash>,
        OptionQuery
    >;
    
    /// Validated truth claims
    #[pallet::storage]
    #[pallet::getter(fn validated_claims)]
    pub type ValidatedClaims<T: Config> = StorageMap<
        _,
        Blake2_128Concat,
        T::Hash,
        ValidatedTruthClaim<T::AccountId, T::Hash>,
        OptionQuery
    >;
    
    /// AKG GNN embeddings for semantic validation
    #[pallet::storage]
    #[pallet::getter(fn akg_embeddings)]
    pub type AKGEmbeddings<T: Config> = StorageMap<
        _,
        Blake2_128Concat,
        T::Hash,
        Vec<u8>, // Serialized 8096-dimensional embedding
        OptionQuery
    >;
    
    #[derive(Clone, Encode, Decode, PartialEq, RuntimeDebug, TypeInfo, MaxEncodedLen)]
    pub struct EthicsValidator {
        pub reputation_score: u32,
        pub claims_validated: u32,
        pub false_positives: u32,
        pub false_negatives: u32,
        pub active: bool,
    }
    
    #[derive(Clone, Encode, Decode, PartialEq, RuntimeDebug, TypeInfo)]
    pub struct TruthClaim<AccountId, Hash> {
        pub submitter: AccountId,
        pub claim_type: ClaimType,
        pub content_hash: Hash,
        pub akg_node_id: Hash,
        pub confidence_score: u8,
        pub domain: DomainType,
        pub submitted_at: u32,
        pub validations: Vec<ValidationVote<AccountId>>,
    }
    
    #[derive(Clone, Encode, Decode, PartialEq, RuntimeDebug, TypeInfo)]
    pub struct ValidatedTruthClaim<AccountId, Hash> {
        pub claim: TruthClaim<AccountId, Hash>,
        pub final_confidence: u8,
        pub validator_consensus: u8,
        pub validated_at: u32,
        pub merkle_root: Hash,
        pub ethics_signature: Vec<u8>,
    }
    
    #[derive(Clone, Encode, Decode, PartialEq, RuntimeDebug, TypeInfo)]
    pub struct ValidationVote<AccountId> {
        pub validator: AccountId,
        pub vote: bool, // true = accept, false = reject
        pub confidence_adjustment: i8,
        pub reasoning: Vec<u8>,
        pub timestamp: u32,
    }
    
    #[derive(Clone, Encode, Decode, PartialEq, RuntimeDebug, TypeInfo, MaxEncodedLen)]
    pub enum ClaimType {
        MedicalDiagnosis,
        LegalResearch,
        EducationalContent,
        HealthGuidance,
        ParentingAdvice,
        ProteinStructure,
        ChemicalMolecule,
        FluidDynamics,
        QuantumCollapse,
    }
    
    #[derive(Clone, Encode, Decode, PartialEq, RuntimeDebug, TypeInfo, MaxEncodedLen)]
    pub enum DomainType {
        Clinician,
        Legal,
        Education,
        PersonalHealth,
        Parent,
        Protein,
        Chemistry,
        FluidDynamics,
    }
    
    #[pallet::event]
    #[pallet::generate_deposit(pub(super) fn deposit_event)]
    pub enum Event<T: Config> {
        /// Truth claim submitted for validation
        TruthClaimSubmitted {
            claim_hash: T::Hash,
            submitter: T::AccountId,
            claim_type: ClaimType,
            domain: DomainType,
        },
        /// Ethics validator voted on claim
        ValidationVoteCast {
            claim_hash: T::Hash,
            validator: T::AccountId,
            vote: bool,
        },
        /// Truth claim validated and accepted
        TruthClaimValidated {
            claim_hash: T::Hash,
            final_confidence: u8,
            validator_consensus: u8,
        },
        /// Truth claim rejected (failed validation)
        TruthClaimRejected {
            claim_hash: T::Hash,
            reason: Vec<u8>,
        },
        /// Ethics validator registered
        EthicsValidatorRegistered {
            validator: T::AccountId,
        },
        /// AKG GNN embedding stored
        AKGEmbeddingStored {
            node_id: T::Hash,
            embedding_size: u32,
        },
    }
    
    #[pallet::error]
    pub enum Error<T> {
        /// Confidence score below minimum threshold
        InsufficientConfidence,
        /// Not an authorized ethics validator
        NotEthicsValidator,
        /// Claim not found
        ClaimNotFound,
        /// Claim already validated
        ClaimAlreadyValidated,
        /// Insufficient validator consensus
        InsufficientConsensus,
        /// Invalid AKG GNN embedding
        InvalidEmbedding,
        /// Contradicts existing validated knowledge
        ContradictoryKnowledge,
        /// Failed Aristotelian virtue check
        VirtueViolation,
    }
    
    #[pallet::call]
    impl<T: Config> Pallet<T> {
        /// Submit a truth claim for ethics validation
        #[pallet::call_index(0)]
        #[pallet::weight(10_000)]
        pub fn submit_truth_claim(
            origin: OriginFor<T>,
            claim_type: ClaimType,
            content_hash: T::Hash,
            akg_node_id: T::Hash,
            confidence_score: u8,
            domain: DomainType,
            akg_embedding: Vec<u8>,
        ) -> DispatchResult {
            let submitter = ensure_signed(origin)?;
            
            // Validate confidence score
            ensure!(
                confidence_score >= T::MinimumConfidence::get(),
                Error::<T>::InsufficientConfidence
            );
            
            // Validate AKG GNN embedding (should be 8096 dimensions × 4 bytes = 32384 bytes)
            ensure!(
                akg_embedding.len() == 32384,
                Error::<T>::InvalidEmbedding
            );
            
            // Create claim hash
            let claim_hash = T::Hashing::hash_of(&(&submitter, &content_hash, &akg_node_id));
            
            // Store AKG embedding for semantic similarity checks
            AKGEmbeddings::<T>::insert(&akg_node_id, akg_embedding.clone());
            
            // Check for contradictions with existing validated claims
            Self::check_contradictions(&akg_embedding)?;
            
            // Create truth claim
            let claim = TruthClaim {
                submitter: submitter.clone(),
                claim_type: claim_type.clone(),
                content_hash,
                akg_node_id,
                confidence_score,
                domain: domain.clone(),
                submitted_at: <frame_system::Pallet<T>>::block_number().saturated_into(),
                validations: Vec::new(),
            };
            
            // Store pending claim
            PendingClaims::<T>::insert(&claim_hash, claim);
            
            // Emit event
            Self::deposit_event(Event::TruthClaimSubmitted {
                claim_hash,
                submitter,
                claim_type,
                domain,
            });
            
            Self::deposit_event(Event::AKGEmbeddingStored {
                node_id: akg_node_id,
                embedding_size: akg_embedding.len() as u32,
            });
            
            Ok(())
        }
        
        /// Ethics validator votes on a truth claim
        #[pallet::call_index(1)]
        #[pallet::weight(10_000)]
        pub fn validate_truth_claim(
            origin: OriginFor<T>,
            claim_hash: T::Hash,
            vote: bool,
            confidence_adjustment: i8,
            reasoning: Vec<u8>,
        ) -> DispatchResult {
            let validator = ensure_signed(origin)?;
            
            // Verify validator is authorized
            ensure!(
                EthicsValidators::<T>::contains_key(&validator),
                Error::<T>::NotEthicsValidator
            );
            
            // Get pending claim
            let mut claim = PendingClaims::<T>::get(&claim_hash)
                .ok_or(Error::<T>::ClaimNotFound)?;
            
            // Add validation vote
            let validation_vote = ValidationVote {
                validator: validator.clone(),
                vote,
                confidence_adjustment,
                reasoning,
                timestamp: <frame_system::Pallet<T>>::block_number().saturated_into(),
            };
            
            claim.validations.push(validation_vote);
            
            // Update pending claim
            PendingClaims::<T>::insert(&claim_hash, claim.clone());
            
            // Emit event
            Self::deposit_event(Event::ValidationVoteCast {
                claim_hash,
                validator,
                vote,
            });
            
            // Check if we have enough validators
            if claim.validations.len() >= T::RequiredValidators::get() as usize {
                Self::finalize_validation(claim_hash, claim)?;
            }
            
            Ok(())
        }
        
        /// Register as an ethics validator (requires governance approval)
        #[pallet::call_index(2)]
        #[pallet::weight(10_000)]
        pub fn register_ethics_validator(
            origin: OriginFor<T>,
            validator_account: T::AccountId,
        ) -> DispatchResult {
            // Only root can register validators (governance)
            ensure_root(origin)?;
            
            let validator = EthicsValidator {
                reputation_score: 100,
                claims_validated: 0,
                false_positives: 0,
                false_negatives: 0,
                active: true,
            };
            
            EthicsValidators::<T>::insert(&validator_account, validator);
            
            Self::deposit_event(Event::EthicsValidatorRegistered {
                validator: validator_account,
            });
            
            Ok(())
        }
    }
    
    impl<T: Config> Pallet<T> {
        /// Finalize validation once enough validators have voted
        fn finalize_validation(
            claim_hash: T::Hash,
            claim: TruthClaim<T::AccountId, T::Hash>,
        ) -> DispatchResult {
            // Calculate consensus
            let accept_votes = claim.validations.iter().filter(|v| v.vote).count();
            let total_votes = claim.validations.len();
            let consensus_percentage = (accept_votes * 100 / total_votes) as u8;
            
            // Require >66% consensus
            if consensus_percentage < 67 {
                // Rejected
                Self::deposit_event(Event::TruthClaimRejected {
                    claim_hash,
                    reason: b"Insufficient validator consensus".to_vec(),
                });
                PendingClaims::<T>::remove(&claim_hash);
                return Ok(());
            }
            
            // Calculate final confidence score
            let confidence_adjustments: i32 = claim.validations
                .iter()
                .map(|v| v.confidence_adjustment as i32)
                .sum();
            let avg_adjustment = confidence_adjustments / total_votes as i32;
            let final_confidence = ((claim.confidence_score as i32) + avg_adjustment)
                .clamp(0, 100) as u8;
            
            // Create validated claim
            let validated_claim = ValidatedTruthClaim {
                claim: claim.clone(),
                final_confidence,
                validator_consensus: consensus_percentage,
                validated_at: <frame_system::Pallet<T>>::block_number().saturated_into(),
                merkle_root: claim_hash, // Would be actual Merkle root
                ethics_signature: Vec::new(), // Would be actual signature
            };
            
            // Store validated claim
            ValidatedClaims::<T>::insert(&claim_hash, validated_claim);
            
            // Remove from pending
            PendingClaims::<T>::remove(&claim_hash);
            
            // Emit event
            Self::deposit_event(Event::TruthClaimValidated {
                claim_hash,
                final_confidence,
                validator_consensus: consensus_percentage,
            });
            
            Ok(())
        }
        
        /// Check for contradictions with existing validated knowledge
        /// Uses AKG GNN embeddings for semantic similarity
        fn check_contradictions(new_embedding: &Vec<u8>) -> DispatchResult {
            // In production, this would:
            // 1. Query all validated claims in same domain
            // 2. Compute cosine similarity between embeddings
            // 3. Check if any claim has high similarity but opposite conclusion
            // 4. Use GNN to propagate through knowledge graph
            
            // For now, we just ensure the embedding is valid
            ensure!(
                new_embedding.len() == 32384,
                Error::<T>::InvalidEmbedding
            );
            
            Ok(())
        }
    }
    
    pub trait WeightInfo {
        fn submit_truth_claim() -> Weight;
        fn validate_truth_claim() -> Weight;
        fn register_ethics_validator() -> Weight;
    }
    
    impl WeightInfo for () {
        fn submit_truth_claim() -> Weight {
            Weight::from_parts(10_000, 0)
        }
        fn validate_truth_claim() -> Weight {
            Weight::from_parts(10_000, 0)
        }
        fn register_ethics_validator() -> Weight {
            Weight::from_parts(10_000, 0)
        }
    }
}


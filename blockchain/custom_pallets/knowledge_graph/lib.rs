// Custom Substrate Pallet: Knowledge Graph
// Manages the Agentic Knowledge Graph for SafeAICoin "Field of Truth"

#![cfg_attr(not(feature = "std"), no_std)]

pub use pallet::*;

#[frame_support::pallet]
pub mod pallet {
    use frame_support::{
        dispatch::DispatchResult,
        pallet_prelude::*,
        traits::{Currency, ReservableCurrency},
    };
    use frame_system::pallet_prelude::*;
    use sp_std::vec::Vec;

    type BalanceOf<T> = <<T as Config>::Currency as Currency<<T as frame_system::Config>::AccountId>>::Balance;

    #[pallet::pallet]
    pub struct Pallet<T>(_);

    #[pallet::config]
    pub trait Config: frame_system::Config {
        type RuntimeEvent: From<Event<Self>> + IsType<<Self as frame_system::Config>::RuntimeEvent>;
        type Currency: ReservableCurrency<Self::AccountId>;
        
        /// Minimum stake required to submit a fact
        #[pallet::constant]
        type MinimumFactStake: Get<BalanceOf<Self>>;
        
        /// Fee for querying a fact (micro-payment)
        #[pallet::constant]
        type QueryFee: Get<BalanceOf<Self>>;
    }

    /// Status of a knowledge fact
    #[derive(Clone, Encode, Decode, Eq, PartialEq, RuntimeDebug, TypeInfo, MaxEncodedLen)]
    pub enum FactStatus {
        Pending,      // Awaiting validation
        Validated,    // Approved by validators
        Challenged,   // Under dispute
        Deprecated,   // No longer valid
    }

    /// Knowledge fact stored on-chain
    #[derive(Clone, Encode, Decode, Eq, PartialEq, RuntimeDebug, TypeInfo)]
    #[scale_info(skip_type_params(T))]
    pub struct KnowledgeFact<T: Config> {
        /// Unique identifier (content hash)
        pub id: T::Hash,
        /// Creator account
        pub creator: T::AccountId,
        /// Content hash (actual content stored off-chain)
        pub content_hash: T::Hash,
        /// Timestamp of creation
        pub created_at: T::BlockNumber,
        /// Current status
        pub status: FactStatus,
        /// Total stake backing this fact
        pub total_stake: BalanceOf<T>,
        /// Number of times this fact has been queried
        pub usage_count: u64,
        /// Accumulated rewards for creator
        pub reward_pool: BalanceOf<T>,
        /// IPFS hash for full content (optional)
        pub ipfs_hash: Option<Vec<u8>>,
        /// Category (medical, legal, education, etc.)
        pub category: Vec<u8>,
    }

    /// Validator stake on a fact
    #[derive(Clone, Encode, Decode, Eq, PartialEq, RuntimeDebug, TypeInfo)]
    #[scale_info(skip_type_params(T))]
    pub struct ValidationStake<T: Config> {
        pub validator: T::AccountId,
        pub fact_id: T::Hash,
        pub stake_amount: BalanceOf<T>,
        pub staked_at: T::BlockNumber,
        pub confidence: u8, // 0-100
    }

    /// Storage: Facts by ID
    #[pallet::storage]
    #[pallet::getter(fn facts)]
    pub type Facts<T: Config> = StorageMap<_, Blake2_128Concat, T::Hash, KnowledgeFact<T>>;

    /// Storage: Validation stakes
    #[pallet::storage]
    #[pallet::getter(fn stakes)]
    pub type Stakes<T: Config> = StorageDoubleMap<
        _,
        Blake2_128Concat,
        T::Hash, // fact_id
        Blake2_128Concat,
        T::AccountId, // validator
        ValidationStake<T>,
    >;

    /// Storage: Facts by creator
    #[pallet::storage]
    #[pallet::getter(fn creator_facts)]
    pub type CreatorFacts<T: Config> = StorageMap<
        _,
        Blake2_128Concat,
        T::AccountId,
        Vec<T::Hash>,
        ValueQuery,
    >;

    /// Storage: Total facts count
    #[pallet::storage]
    #[pallet::getter(fn fact_count)]
    pub type FactCount<T> = StorageValue<_, u64, ValueQuery>;

    #[pallet::event]
    #[pallet::generate_deposit(pub(super) fn deposit_event)]
    pub enum Event<T: Config> {
        /// Fact submitted [fact_id, creator, stake]
        FactSubmitted(T::Hash, T::AccountId, BalanceOf<T>),
        /// Fact validated [fact_id, validator, stake]
        FactValidated(T::Hash, T::AccountId, BalanceOf<T>),
        /// Fact queried [fact_id, querier, fee]
        FactQueried(T::Hash, T::AccountId, BalanceOf<T>),
        /// Fact challenged [fact_id, challenger]
        FactChallenged(T::Hash, T::AccountId),
        /// Rewards distributed [fact_id, creator, amount]
        RewardsDistributed(T::Hash, T::AccountId, BalanceOf<T>),
    }

    #[pallet::error]
    pub enum Error<T> {
        /// Fact already exists
        FactAlreadyExists,
        /// Fact not found
        FactNotFound,
        /// Insufficient stake
        InsufficientStake,
        /// Not authorized
        NotAuthorized,
        /// Invalid status transition
        InvalidStatus,
        /// Already staked
        AlreadyStaked,
    }

    #[pallet::call]
    impl<T: Config> Pallet<T> {
        /// Submit a new knowledge fact
        #[pallet::weight(10_000)]
        #[pallet::call_index(0)]
        pub fn submit_fact(
            origin: OriginFor<T>,
            content_hash: T::Hash,
            ipfs_hash: Option<Vec<u8>>,
            category: Vec<u8>,
            stake: BalanceOf<T>,
        ) -> DispatchResult {
            let creator = ensure_signed(origin)?;
            
            // Ensure minimum stake
            ensure!(
                stake >= T::MinimumFactStake::get(),
                Error::<T>::InsufficientStake
            );
            
            // Reserve stake
            T::Currency::reserve(&creator, stake)?;
            
            // Create fact ID (hash of content + creator)
            let fact_id = T::Hashing::hash_of(&(&content_hash, &creator));
            
            // Ensure fact doesn't exist
            ensure!(!Facts::<T>::contains_key(&fact_id), Error::<T>::FactAlreadyExists);
            
            // Create fact
            let fact = KnowledgeFact {
                id: fact_id,
                creator: creator.clone(),
                content_hash,
                created_at: <frame_system::Pallet<T>>::block_number(),
                status: FactStatus::Pending,
                total_stake: stake,
                usage_count: 0,
                reward_pool: Zero::zero(),
                ipfs_hash,
                category,
            };
            
            // Store fact
            Facts::<T>::insert(&fact_id, fact);
            
            // Update creator's facts
            CreatorFacts::<T>::mutate(&creator, |facts| {
                facts.push(fact_id);
            });
            
            // Increment count
            FactCount::<T>::mutate(|count| *count = count.saturating_add(1));
            
            // Emit event
            Self::deposit_event(Event::FactSubmitted(fact_id, creator, stake));
            
            Ok(())
        }

        /// Validate a fact (stake on it)
        #[pallet::weight(10_000)]
        #[pallet::call_index(1)]
        pub fn validate_fact(
            origin: OriginFor<T>,
            fact_id: T::Hash,
            stake: BalanceOf<T>,
            confidence: u8,
        ) -> DispatchResult {
            let validator = ensure_signed(origin)?;
            
            // Ensure fact exists
            let mut fact = Facts::<T>::get(&fact_id).ok_or(Error::<T>::FactNotFound)?;
            
            // Ensure not already staked
            ensure!(
                !Stakes::<T>::contains_key(&fact_id, &validator),
                Error::<T>::AlreadyStaked
            );
            
            // Reserve stake
            T::Currency::reserve(&validator, stake)?;
            
            // Create stake record
            let validation_stake = ValidationStake {
                validator: validator.clone(),
                fact_id,
                stake_amount: stake,
                staked_at: <frame_system::Pallet<T>>::block_number(),
                confidence,
            };
            
            // Store stake
            Stakes::<T>::insert(&fact_id, &validator, validation_stake);
            
            // Update fact
            fact.total_stake = fact.total_stake.saturating_add(stake);
            
            // If enough stake, mark as validated
            // (In production: check number of validators, geographic distribution, etc.)
            if fact.status == FactStatus::Pending {
                fact.status = FactStatus::Validated;
            }
            
            Facts::<T>::insert(&fact_id, fact);
            
            // Emit event
            Self::deposit_event(Event::FactValidated(fact_id, validator, stake));
            
            Ok(())
        }

        /// Query a fact (triggers micro-payment)
        #[pallet::weight(10_000)]
        #[pallet::call_index(2)]
        pub fn query_fact(
            origin: OriginFor<T>,
            fact_id: T::Hash,
        ) -> DispatchResult {
            let querier = ensure_signed(origin)?;
            
            // Get fact
            let mut fact = Facts::<T>::get(&fact_id).ok_or(Error::<T>::FactNotFound)?;
            
            // Ensure fact is validated
            ensure!(fact.status == FactStatus::Validated, Error::<T>::InvalidStatus);
            
            // Charge query fee
            let fee = T::QueryFee::get();
            
            // Distribute fee according to tokenomics:
            // 70% → creator
            // 15% → platform (TODO: implement)
            // 10% → governance (TODO: implement)
            // 5% → ethics validators (TODO: implement)
            
            let creator_share = fee.saturating_mul(70u32.into()) / 100u32.into();
            T::Currency::transfer(&querier, &fact.creator, creator_share, ExistenceRequirement::KeepAlive)?;
            
            // Add to reward pool
            fact.reward_pool = fact.reward_pool.saturating_add(creator_share);
            fact.usage_count = fact.usage_count.saturating_add(1);
            
            Facts::<T>::insert(&fact_id, fact);
            
            // Emit event
            Self::deposit_event(Event::FactQueried(fact_id, querier, fee));
            
            Ok(())
        }

        /// Challenge a fact
        #[pallet::weight(10_000)]
        #[pallet::call_index(3)]
        pub fn challenge_fact(
            origin: OriginFor<T>,
            fact_id: T::Hash,
            evidence_hash: T::Hash,
        ) -> DispatchResult {
            let challenger = ensure_signed(origin)?;
            
            // Get fact
            let mut fact = Facts::<T>::get(&fact_id).ok_or(Error::<T>::FactNotFound)?;
            
            // Update status
            fact.status = FactStatus::Challenged;
            Facts::<T>::insert(&fact_id, fact);
            
            // Emit event
            Self::deposit_event(Event::FactChallenged(fact_id, challenger));
            
            // TODO: Trigger human review process
            
            Ok(())
        }
    }
}


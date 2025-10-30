// Custom Substrate Pallet: AKG GNN (Agentic Knowledge Graph with Graph Neural Network)
// Implements BiVQbitEGNN for knowledge graph reasoning
// Patent-pending: UtilityPatentFilingCLAIMSNOPRIORITIES-19096071.pdf

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
        
        /// Maximum GNN embedding dimensions
        #[pallet::constant]
        type MaxEmbeddingDim: Get<u32>;
    }

    /// Knowledge graph node
    #[derive(Clone, Encode, Decode, Eq, PartialEq, RuntimeDebug, TypeInfo)]
    #[scale_info(skip_type_params(T))]
    pub struct KGNode<T: Config> {
        pub id: T::Hash,
        pub node_type: NodeType,
        pub content_hash: T::Hash,
        pub embedding: Vec<u8>, // Compressed GNN embedding
        pub provenance: Vec<T::Hash>, // Source facts
        pub created_at: T::BlockNumber,
        pub updated_at: T::BlockNumber,
    }

    /// Knowledge graph edge
    #[derive(Clone, Encode, Decode, Eq, PartialEq, RuntimeDebug, TypeInfo)]
    #[scale_info(skip_type_params(T))]
    pub struct KGEdge<T: Config> {
        pub source: T::Hash,
        pub target: T::Hash,
        pub relationship: RelationType,
        pub confidence: u8, // 0-100
        pub inferred_by: InferenceMethod,
    }

    #[derive(Clone, Encode, Decode, Eq, PartialEq, RuntimeDebug, TypeInfo, MaxEncodedLen)]
    pub enum NodeType {
        Fact,           // Atomic truth claim
        Rule,           // Logical rule (if-then)
        Inference,      // Derived conclusion
        Evidence,       // Supporting data
        Protein,        // Protein structure/sequence
        Chemical,       // Chemical compound
        FluidDynamics,  // FSI/FEA simulation result
        Medical,        // Clinical finding
        Legal,          // Legal precedent
    }

    #[derive(Clone, Encode, Decode, Eq, PartialEq, RuntimeDebug, TypeInfo, MaxEncodedLen)]
    pub enum RelationType {
        Implies,        // A → B
        Contradicts,    // A ⊥ B
        Supports,       // A supports B (evidence)
        Derived,        // B derived from A
        Related,        // Semantic similarity
        InteractsWith,  // Protein-protein interaction
        BindsTo,        // Chemical binding
        Causes,         // Causal relationship
    }

    #[derive(Clone, Encode, Decode, Eq, PartialEq, RuntimeDebug, TypeInfo, MaxEncodedLen)]
    pub enum InferenceMethod {
        BiVQbitEGNN,    // Graph neural network (patent-pending)
        LogicalDeduction, // Classical logic
        StatisticalInference, // Bayesian/frequentist
        ExpertValidation, // Human-verified
    }

    /// Storage: Knowledge graph nodes
    #[pallet::storage]
    #[pallet::getter(fn nodes)]
    pub type Nodes<T: Config> = StorageMap<
        _,
        Blake2_128Concat,
        T::Hash, // node_id
        KGNode<T>,
    >;

    /// Storage: Knowledge graph edges
    #[pallet::storage]
    #[pallet::getter(fn edges)]
    pub type Edges<T: Config> = StorageDoubleMap<
        _,
        Blake2_128Concat,
        T::Hash, // source
        Blake2_128Concat,
        T::Hash, // target
        KGEdge<T>,
    >;

    /// Storage: Node embeddings (for GNN queries)
    #[pallet::storage]
    #[pallet::getter(fn embeddings)]
    pub type Embeddings<T: Config> = StorageMap<
        _,
        Blake2_128Concat,
        T::Hash, // node_id
        Vec<u8>, // compressed embedding vector
        ValueQuery,
    >;

    /// Storage: GNN model version
    #[pallet::storage]
    #[pallet::getter(fn gnn_version)]
    pub type GNNVersion<T> = StorageValue<_, u32, ValueQuery>;

    #[pallet::event]
    #[pallet::generate_deposit(pub(super) fn deposit_event)]
    pub enum Event<T: Config> {
        /// Node added to knowledge graph [node_id, node_type]
        NodeAdded(T::Hash, NodeType),
        /// Edge added to knowledge graph [source, target, relationship]
        EdgeAdded(T::Hash, T::Hash, RelationType),
        /// Inference generated [source_nodes, inferred_node]
        InferenceGenerated(Vec<T::Hash>, T::Hash),
        /// GNN embedding computed [node_id]
        EmbeddingComputed(T::Hash),
        /// GNN model updated [version]
        GNNModelUpdated(u32),
    }

    #[pallet::error]
    pub enum Error<T> {
        /// Node already exists
        NodeAlreadyExists,
        /// Node not found
        NodeNotFound,
        /// Edge already exists
        EdgeAlreadyExists,
        /// Invalid embedding dimensions
        InvalidEmbedding,
        /// Circular dependency detected
        CircularDependency,
    }

    #[pallet::call]
    impl<T: Config> Pallet<T> {
        /// Add a node to the knowledge graph
        #[pallet::weight(10_000)]
        #[pallet::call_index(0)]
        pub fn add_node(
            origin: OriginFor<T>,
            node_type: NodeType,
            content_hash: T::Hash,
            provenance: Vec<T::Hash>,
        ) -> DispatchResult {
            let _ = ensure_signed(origin)?;
            
            // Generate node ID
            let node_id = T::Hashing::hash_of(&(&node_type, &content_hash));
            
            // Ensure node doesn't exist
            ensure!(!Nodes::<T>::contains_key(&node_id), Error::<T>::NodeAlreadyExists);
            
            // Compute GNN embedding
            let embedding = Self::compute_embedding(&node_type, &content_hash, &provenance);
            
            // Create node
            let node = KGNode {
                id: node_id,
                node_type: node_type.clone(),
                content_hash,
                embedding: embedding.clone(),
                provenance: provenance.clone(),
                created_at: <frame_system::Pallet<T>>::block_number(),
                updated_at: <frame_system::Pallet<T>>::block_number(),
            };
            
            // Store node
            Nodes::<T>::insert(&node_id, node);
            
            // Store embedding
            Embeddings::<T>::insert(&node_id, embedding);
            
            // Emit event
            Self::deposit_event(Event::NodeAdded(node_id, node_type));
            
            Ok(())
        }

        /// Add an edge to the knowledge graph
        #[pallet::weight(10_000)]
        #[pallet::call_index(1)]
        pub fn add_edge(
            origin: OriginFor<T>,
            source: T::Hash,
            target: T::Hash,
            relationship: RelationType,
            confidence: u8,
            inference_method: InferenceMethod,
        ) -> DispatchResult {
            let _ = ensure_signed(origin)?;
            
            // Ensure both nodes exist
            ensure!(Nodes::<T>::contains_key(&source), Error::<T>::NodeNotFound);
            ensure!(Nodes::<T>::contains_key(&target), Error::<T>::NodeNotFound);
            
            // Ensure edge doesn't exist
            ensure!(
                !Edges::<T>::contains_key(&source, &target),
                Error::<T>::EdgeAlreadyExists
            );
            
            // Check for circular dependencies
            if Self::would_create_cycle(source, target) {
                return Err(Error::<T>::CircularDependency.into());
            }
            
            // Create edge
            let edge = KGEdge {
                source,
                target,
                relationship: relationship.clone(),
                confidence,
                inferred_by: inference_method,
            };
            
            // Store edge
            Edges::<T>::insert(&source, &target, edge);
            
            // Emit event
            Self::deposit_event(Event::EdgeAdded(source, target, relationship));
            
            Ok(())
        }

        /// Generate inference using BiVQbitEGNN
        #[pallet::weight(50_000)]
        #[pallet::call_index(2)]
        pub fn generate_inference(
            origin: OriginFor<T>,
            source_nodes: Vec<T::Hash>,
            inference_type: NodeType,
        ) -> DispatchResult {
            let _ = ensure_signed(origin)?;
            
            // Ensure all source nodes exist
            for node_id in &source_nodes {
                ensure!(Nodes::<T>::contains_key(node_id), Error::<T>::NodeNotFound);
            }
            
            // Gather embeddings
            let embeddings: Vec<Vec<u8>> = source_nodes
                .iter()
                .map(|id| Embeddings::<T>::get(id))
                .collect();
            
            // Run BiVQbitEGNN inference
            let (inferred_content, inferred_embedding) = 
                Self::run_bivqbit_egnn(&source_nodes, &embeddings, &inference_type);
            
            // Create inferred node
            let node_id = T::Hashing::hash_of(&(&inference_type, &inferred_content));
            
            let node = KGNode {
                id: node_id,
                node_type: inference_type,
                content_hash: inferred_content,
                embedding: inferred_embedding.clone(),
                provenance: source_nodes.clone(),
                created_at: <frame_system::Pallet<T>>::block_number(),
                updated_at: <frame_system::Pallet<T>>::block_number(),
            };
            
            // Store inferred node
            Nodes::<T>::insert(&node_id, node);
            Embeddings::<T>::insert(&node_id, inferred_embedding);
            
            // Create edges from source nodes to inference
            for source in &source_nodes {
                let edge = KGEdge {
                    source: *source,
                    target: node_id,
                    relationship: RelationType::Derived,
                    confidence: 90, // BiVQbitEGNN confidence
                    inferred_by: InferenceMethod::BiVQbitEGNN,
                };
                Edges::<T>::insert(source, &node_id, edge);
            }
            
            // Emit event
            Self::deposit_event(Event::InferenceGenerated(source_nodes, node_id));
            
            Ok(())
        }

        /// Update GNN model (governance only)
        #[pallet::weight(100_000)]
        #[pallet::call_index(3)]
        pub fn update_gnn_model(
            origin: OriginFor<T>,
            new_version: u32,
        ) -> DispatchResult {
            ensure_root(origin)?;
            
            GNNVersion::<T>::put(new_version);
            Self::deposit_event(Event::GNNModelUpdated(new_version));
            
            Ok(())
        }
    }

    // Internal helper functions
    impl<T: Config> Pallet<T> {
        /// Compute GNN embedding for a node using BiVQbitEGNN
        fn compute_embedding(
            node_type: &NodeType,
            content_hash: &T::Hash,
            provenance: &[T::Hash],
        ) -> Vec<u8> {
            // In production, this would:
            // 1. Run BiVQbitEGNN on the content
            // 2. Generate high-dimensional embedding (8096 dims)
            // 3. Compress to manageable size for storage
            // 4. Return compressed embedding
            
            // For now, return hash as embedding (placeholder)
            content_hash.as_ref().to_vec()
        }

        /// Run BiVQbitEGNN inference
        fn run_bivqbit_egnn(
            source_nodes: &[T::Hash],
            embeddings: &[Vec<u8>],
            inference_type: &NodeType,
        ) -> (T::Hash, Vec<u8>) {
            // In production, this would:
            // 1. Aggregate embeddings using attention mechanism
            // 2. Pass through BiVQbit GNN layers
            // 3. Apply virtue-guided optimization
            // 4. Generate inferred conclusion
            // 5. Return (content_hash, embedding)
            
            // Placeholder: combine hashes
            let combined = source_nodes.iter().fold(Vec::new(), |mut acc, h| {
                acc.extend_from_slice(h.as_ref());
                acc
            });
            let inferred_hash = T::Hashing::hash(&combined);
            let inferred_embedding = inferred_hash.as_ref().to_vec();
            
            (inferred_hash, inferred_embedding)
        }

        /// Check if adding edge would create cycle
        fn would_create_cycle(source: T::Hash, target: T::Hash) -> bool {
            // DFS to detect cycles
            // In production, implement proper cycle detection
            false
        }
    }
}


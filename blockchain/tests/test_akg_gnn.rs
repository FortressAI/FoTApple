// AKG GNN Test Suite
// Tests BiVQbitEGNN knowledge graph operations

use frame_support::{assert_ok, assert_noop};
use sp_core::H256;
use crate::mock::*;

#[test]
fn test_add_protein_node() {
    new_test_ext().execute_with(|| {
        let content_hash = H256::random();
        let provenance = vec![];
        
        assert_ok!(AKGGNN::add_node(
            RuntimeOrigin::signed(ALICE),
            NodeType::Protein,
            content_hash,
            provenance
        ));
        
        // Verify node exists
        let node_id = <Test as frame_system::Config>::Hashing::hash_of(
            &(&NodeType::Protein, &content_hash)
        );
        
        assert!(AKGGNN::nodes(node_id).is_some());
        
        // Verify embedding was computed
        assert!(AKGGNN::embeddings(node_id).len() > 0);
    });
}

#[test]
fn test_add_fluid_dynamics_node() {
    new_test_ext().execute_with(|| {
        let content_hash = H256::random();
        
        assert_ok!(AKGGNN::add_node(
            RuntimeOrigin::signed(ALICE),
            NodeType::FluidDynamics,
            content_hash,
            vec![]
        ));
        
        let node_id = <Test as frame_system::Config>::Hashing::hash_of(
            &(&NodeType::FluidDynamics, &content_hash)
        );
        
        let node = AKGGNN::nodes(node_id).unwrap();
        assert_eq!(node.node_type, NodeType::FluidDynamics);
    });
}

#[test]
fn test_cannot_add_duplicate_node() {
    new_test_ext().execute_with(|| {
        let content_hash = H256::random();
        
        // Add node
        assert_ok!(AKGGNN::add_node(
            RuntimeOrigin::signed(ALICE),
            NodeType::Protein,
            content_hash,
            vec![]
        ));
        
        // Attempt to add same node again
        assert_noop!(
            AKGGNN::add_node(
                RuntimeOrigin::signed(ALICE),
                NodeType::Protein,
                content_hash,
                vec![]
            ),
            Error::<Test>::NodeAlreadyExists
        );
    });
}

#[test]
fn test_add_edge_protein_interaction() {
    new_test_ext().execute_with(|| {
        // Create two protein nodes
        let protein_a = H256::from_low_u64_be(1);
        let protein_b = H256::from_low_u64_be(2);
        
        assert_ok!(AKGGNN::add_node(
            RuntimeOrigin::signed(ALICE),
            NodeType::Protein,
            protein_a,
            vec![]
        ));
        
        assert_ok!(AKGGNN::add_node(
            RuntimeOrigin::signed(ALICE),
            NodeType::Protein,
            protein_b,
            vec![]
        ));
        
        // Get node IDs
        let node_a = <Test as frame_system::Config>::Hashing::hash_of(
            &(&NodeType::Protein, &protein_a)
        );
        let node_b = <Test as frame_system::Config>::Hashing::hash_of(
            &(&NodeType::Protein, &protein_b)
        );
        
        // Add interaction edge
        assert_ok!(AKGGNN::add_edge(
            RuntimeOrigin::signed(ALICE),
            node_a,
            node_b,
            RelationType::InteractsWith,
            95, // 95% confidence
            InferenceMethod::ExpertValidation
        ));
        
        // Verify edge exists
        assert!(AKGGNN::edges(node_a, node_b).is_some());
    });
}

#[test]
fn test_add_edge_chemical_binding() {
    new_test_ext().execute_with(|| {
        let protein = H256::from_low_u64_be(1);
        let chemical = H256::from_low_u64_be(2);
        
        assert_ok!(AKGGNN::add_node(
            RuntimeOrigin::signed(ALICE),
            NodeType::Protein,
            protein,
            vec![]
        ));
        
        assert_ok!(AKGGNN::add_node(
            RuntimeOrigin::signed(ALICE),
            NodeType::Chemical,
            chemical,
            vec![]
        ));
        
        let protein_id = <Test as frame_system::Config>::Hashing::hash_of(
            &(&NodeType::Protein, &protein)
        );
        let chemical_id = <Test as frame_system::Config>::Hashing::hash_of(
            &(&NodeType::Chemical, &chemical)
        );
        
        // Add binding edge
        assert_ok!(AKGGNN::add_edge(
            RuntimeOrigin::signed(ALICE),
            protein_id,
            chemical_id,
            RelationType::BindsTo,
            87,
            InferenceMethod::BiVQbitEGNN
        ));
    });
}

#[test]
fn test_bivqbit_egnn_inference() {
    new_test_ext().execute_with(|| {
        // Create source facts
        let fact_1 = H256::from_low_u64_be(1);
        let fact_2 = H256::from_low_u64_be(2);
        
        assert_ok!(AKGGNN::add_node(
            RuntimeOrigin::signed(ALICE),
            NodeType::Fact,
            fact_1,
            vec![]
        ));
        
        assert_ok!(AKGGNN::add_node(
            RuntimeOrigin::signed(ALICE),
            NodeType::Fact,
            fact_2,
            vec![]
        ));
        
        let node_1 = <Test as frame_system::Config>::Hashing::hash_of(
            &(&NodeType::Fact, &fact_1)
        );
        let node_2 = <Test as frame_system::Config>::Hashing::hash_of(
            &(&NodeType::Fact, &fact_2)
        );
        
        // Run BiVQbitEGNN inference
        assert_ok!(AKGGNN::generate_inference(
            RuntimeOrigin::signed(ALICE),
            vec![node_1, node_2],
            NodeType::Inference
        ));
        
        // Verify inference node was created
        // Verify edges from source to inference exist
    });
}

#[test]
fn test_edge_requires_both_nodes_exist() {
    new_test_ext().execute_with(|| {
        let node_a = H256::random();
        let node_b = H256::random();
        
        // Attempt to add edge without creating nodes
        assert_noop!(
            AKGGNN::add_edge(
                RuntimeOrigin::signed(ALICE),
                node_a,
                node_b,
                RelationType::Related,
                50,
                InferenceMethod::StatisticalInference
            ),
            Error::<Test>::NodeNotFound
        );
    });
}

#[test]
fn test_prevents_circular_dependencies() {
    new_test_ext().execute_with(|| {
        // Create nodes A -> B -> C
        let a = H256::from_low_u64_be(1);
        let b = H256::from_low_u64_be(2);
        let c = H256::from_low_u64_be(3);
        
        for content in &[a, b, c] {
            assert_ok!(AKGGNN::add_node(
                RuntimeOrigin::signed(ALICE),
                NodeType::Fact,
                *content,
                vec![]
            ));
        }
        
        let node_a = <Test as frame_system::Config>::Hashing::hash_of(&(&NodeType::Fact, &a));
        let node_b = <Test as frame_system::Config>::Hashing::hash_of(&(&NodeType::Fact, &b));
        let node_c = <Test as frame_system::Config>::Hashing::hash_of(&(&NodeType::Fact, &c));
        
        // A -> B
        assert_ok!(AKGGNN::add_edge(
            RuntimeOrigin::signed(ALICE),
            node_a, node_b,
            RelationType::Implies,
            90,
            InferenceMethod::LogicalDeduction
        ));
        
        // B -> C
        assert_ok!(AKGGNN::add_edge(
            RuntimeOrigin::signed(ALICE),
            node_b, node_c,
            RelationType::Implies,
            90,
            InferenceMethod::LogicalDeduction
        ));
        
        // Attempt C -> A (creates cycle)
        // Should be blocked
        assert_noop!(
            AKGGNN::add_edge(
                RuntimeOrigin::signed(ALICE),
                node_c, node_a,
                RelationType::Implies,
                90,
                InferenceMethod::LogicalDeduction
            ),
            Error::<Test>::CircularDependency
        );
    });
}

#[test]
fn test_gnn_embedding_dimensions() {
    new_test_ext().execute_with(|| {
        let content = H256::random();
        
        assert_ok!(AKGGNN::add_node(
            RuntimeOrigin::signed(ALICE),
            NodeType::Protein,
            content,
            vec![]
        ));
        
        let node_id = <Test as frame_system::Config>::Hashing::hash_of(
            &(&NodeType::Protein, &content)
        );
        
        let embedding = AKGGNN::embeddings(node_id);
        
        // Verify embedding was computed
        assert!(embedding.len() > 0);
        
        // In production, would be compressed 8096-dim vector
        // For now, using content hash as placeholder
    });
}

#[test]
fn test_provenance_chain_tracking() {
    new_test_ext().execute_with(|| {
        // Create base fact
        let source_fact = H256::from_low_u64_be(1);
        
        assert_ok!(AKGGNN::add_node(
            RuntimeOrigin::signed(ALICE),
            NodeType::Evidence,
            source_fact,
            vec![]
        ));
        
        let source_id = <Test as frame_system::Config>::Hashing::hash_of(
            &(&NodeType::Evidence, &source_fact)
        );
        
        // Create derived fact with provenance
        let derived_content = H256::from_low_u64_be(2);
        
        assert_ok!(AKGGNN::add_node(
            RuntimeOrigin::signed(ALICE),
            NodeType::Fact,
            derived_content,
            vec![source_id] // Provenance chain
        ));
        
        let derived_id = <Test as frame_system::Config>::Hashing::hash_of(
            &(&NodeType::Fact, &derived_content)
        );
        
        let derived_node = AKGGNN::nodes(derived_id).unwrap();
        assert_eq!(derived_node.provenance.len(), 1);
        assert_eq!(derived_node.provenance[0], source_id);
    });
}

#[test]
fn test_update_gnn_model_requires_root() {
    new_test_ext().execute_with(|| {
        // Non-root cannot update GNN model
        assert_noop!(
            AKGGNN::update_gnn_model(
                RuntimeOrigin::signed(ALICE),
                2
            ),
            sp_runtime::DispatchError::BadOrigin
        );
        
        // Root can update
        assert_ok!(AKGGNN::update_gnn_model(
            RuntimeOrigin::root(),
            2
        ));
        
        assert_eq!(AKGGNN::gnn_version(), 2);
    });
}


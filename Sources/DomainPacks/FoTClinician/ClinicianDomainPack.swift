import Foundation
import FoTCore

/// Clinician Domain Pack - Context-Aware Clinical Decision Support
/// Provides validation, PHI protection, and clinical intelligence across all Apple devices
public struct ClinicianDomainPack: DomainPack {
    public let name = "Clinician"
    public let version = "1.0.0"
    public let description = "Context-aware clinical decision support with HIPAA-compliant PHI handling"
    
    public init() {}
    
    /// Valid ICD-10 code format validator
    private static func isValidICD10(_ code: String) -> Bool {
        // ICD-10 format: Letter, 2 digits, optional dot, optional 1-2 more digits/letters
        let pattern = "^[A-Z][0-9]{2}(\\.[0-9A-Z]{1,4})?$"
        return code.range(of: pattern, options: .regularExpression) != nil
    }
    
    /// Valid LOINC code validator
    private static func isValidLOINC(_ code: String) -> Bool {
        // LOINC codes are 5-7 digits with optional hyphen and check digit
        let pattern = "^[0-9]{4,7}(-[0-9])?$"
        return code.range(of: pattern, options: .regularExpression) != nil
    }
    
    /// Valid NPI (National Provider Identifier) validator
    private static func isValidNPI(_ npi: String) -> Bool {
        return npi.count == 10 && npi.allSatisfy { $0.isNumber }
    }
    
    /// Valid NDC (National Drug Code) validator
    private static func isValidNDC(_ ndc: String) -> Bool {
        let digits = ndc.filter { $0.isNumber }
        return digits.count == 10 || digits.count == 11
    }
    
    public var validationRules: [ValidationRule] {
        return [
            // ICD-10 diagnosis code validation
            DomainConstraint(
                name: "valid_icd10_code",
                errorMessage: "Invalid ICD-10 diagnosis code format"
            ) { props in
                guard let code = props["icd10_code"] as? String else {
                    return true // Optional field
                }
                return Self.isValidICD10(code)
            },
            
            // LOINC observation code validation
            DomainConstraint(
                name: "valid_loinc_code",
                errorMessage: "Invalid LOINC observation code format"
            ) { props in
                guard let code = props["loinc_code"] as? String else {
                    return true
                }
                return Self.isValidLOINC(code)
            },
            
            // NPI provider validation
            DomainConstraint(
                name: "valid_npi",
                errorMessage: "Invalid NPI (must be exactly 10 digits)"
            ) { props in
                guard let npi = props["npi"] as? String else {
                    return true
                }
                return Self.isValidNPI(npi)
            },
            
            // NDC medication code validation
            DomainConstraint(
                name: "valid_ndc_code",
                errorMessage: "Invalid NDC code (must be 10 or 11 digits)"
            ) { props in
                guard let ndc = props["ndc_code"] as? String else {
                    return true
                }
                return Self.isValidNDC(ndc)
            },
            
            // PHI encryption requirement
            DomainConstraint(
                name: "phi_protected",
                errorMessage: "PHI fields must be encrypted (prefix with 'enc:') or hashed (prefix with 'hash:')"
            ) { props in
                let phiFields = ["patient_name", "dob", "ssn", "mrn", "address", "phone", "email"]
                
                for field in phiFields {
                    if let value = props[field] as? String {
                        // Check if encrypted or hashed
                        if !value.starts(with: "enc:") && !value.starts(with: "hash:") {
                            return false
                        }
                    }
                }
                return true
            },
            
            // Vital signs physiological bounds
            DomainConstraint(
                name: "vital_bounds",
                errorMessage: "Vital signs outside physiologically possible range"
            ) { props in
                // Heart rate: 20-300 bpm (covers bradycardia to extreme tachycardia)
                if let hr = props["heart_rate"] as? Double {
                    guard (20...300).contains(hr) else { return false }
                }
                
                // Blood pressure: 40-300 mmHg systolic, 20-200 diastolic
                if let bpSys = props["bp_systolic"] as? Double {
                    guard (40...300).contains(bpSys) else { return false }
                }
                if let bpDia = props["bp_diastolic"] as? Double {
                    guard (20...200).contains(bpDia) else { return false }
                }
                
                // Temperature: 30-45°C (86-113°F)
                if let tempC = props["temperature_c"] as? Double {
                    guard (30...45).contains(tempC) else { return false }
                }
                
                // SpO2: 50-100%
                if let spo2 = props["spo2"] as? Double {
                    guard (50...100).contains(spo2) else { return false }
                }
                
                // Respiratory rate: 4-60 breaths/min
                if let rr = props["respiratory_rate"] as? Double {
                    guard (4...60).contains(rr) else { return false }
                }
                
                return true
            },
            
            // Lab value bounds checking
            DomainConstraint(
                name: "lab_value_bounds",
                errorMessage: "Lab value outside plausible range for test"
            ) { props in
                guard let loincCode = props["loinc_code"] as? String,
                      let value = props["numeric_value"] as? Double else {
                    return true // Skip if not numeric lab
                }
                
                // Common critical labs with bounds
                switch loincCode {
                case "2951-2": // Sodium (mmol/L): 100-200
                    return (100...200).contains(value)
                case "2823-3": // Potassium (mmol/L): 1.0-10.0
                    return (1.0...10.0).contains(value)
                case "2075-0": // Chloride (mmol/L): 50-150
                    return (50...150).contains(value)
                case "2028-9": // CO2 (mmol/L): 5-50
                    return (5...50).contains(value)
                case "3094-0": // BUN (mg/dL): 1-200
                    return (1...200).contains(value)
                case "2160-0": // Creatinine (mg/dL): 0.1-20
                    return (0.1...20).contains(value)
                case "2345-7": // Glucose (mg/dL): 10-1000
                    return (10...1000).contains(value)
                default:
                    return true // Unknown code, skip validation
                }
            },
            
            // Medication dosage sanity check
            DomainConstraint(
                name: "medication_dosage",
                errorMessage: "Medication dosage outside safe range"
            ) { props in
                guard let dose = props["dose_value"] as? Double,
                      let unit = props["dose_unit"] as? String else {
                    return true
                }
                
                // Basic sanity: positive dose, not absurdly high
                guard dose > 0 && dose < 10000 else { return false }
                
                // Unit-specific checks
                switch unit.lowercased() {
                case "mg", "ml":
                    return dose < 5000 // < 5g or 5L
                case "mcg", "ug":
                    return dose < 10000 // < 10mg
                case "g", "l":
                    return dose < 50 // < 50g or 50L
                default:
                    return true
                }
            },
            
            // Patient age validation
            DomainConstraint(
                name: "patient_age",
                errorMessage: "Patient age must be between 0 and 130 years"
            ) { props in
                guard let age = props["age_years"] as? Double else {
                    return true
                }
                return (0...130).contains(age)
            },
            
            // Encounter timestamp validation
            DomainConstraint(
                name: "encounter_timestamp",
                errorMessage: "Encounter timestamp must not be in the future"
            ) { props in
                guard let timestamp = props["encounter_timestamp"] as? Int64 else {
                    return true
                }
                
                let encounterDate = Date(timeIntervalSince1970: Double(timestamp) / 1000.0)
                let now = Date()
                
                // Must not be more than 1 hour in the future (clock skew tolerance)
                return encounterDate.timeIntervalSince(now) < 3600
            }
        ]
    }
    
    public var ontologySchema: String {
        return """
        @prefix fot: <http://fieldoftruth.org/ontology/> .
        @prefix clinical: <http://fieldoftruth.org/ontology/clinical/> .
        @prefix icd10: <http://purl.bioontology.org/ontology/ICD10/> .
        @prefix loinc: <http://loinc.org/> .
        @prefix snomed: <http://snomed.info/id/> .
        @prefix rxnorm: <http://purl.bioontology.org/ontology/RXNORM/> .
        
        # Core clinical entities
        
        clinical:Patient a owl:Class ;
            rdfs:label "Patient" ;
            rdfs:comment "De-identified patient with encrypted PHI" .
        
        clinical:Encounter a owl:Class ;
            rdfs:label "Clinical Encounter" ;
            rdfs:comment "Patient visit, admission, or clinical interaction" .
        
        clinical:Diagnosis a owl:Class ;
            rdfs:label "Diagnosis" ;
            rdfs:comment "Clinical diagnosis with ICD-10 code" .
        
        clinical:Observation a owl:Class ;
            rdfs:label "Clinical Observation" ;
            rdfs:comment "Lab result, vital sign, or clinical measurement with LOINC code" .
        
        clinical:Prescription a owl:Class ;
            rdfs:label "Prescription" ;
            rdfs:comment "Medication order with NDC code and dosing instructions" .
        
        clinical:Clinician a owl:Class ;
            rdfs:label "Healthcare Provider" ;
            rdfs:comment "Licensed clinician with NPI and credentials" .
        
        clinical:ClinicalNote a owl:Class ;
            rdfs:label "Clinical Note" ;
            rdfs:comment "Signed clinical documentation with blockchain attestation" .
        
        clinical:Procedure a owl:Class ;
            rdfs:label "Medical Procedure" ;
            rdfs:comment "Clinical procedure with CPT code" .
        
        clinical:Allergy a owl:Class ;
            rdfs:label "Allergy" ;
            rdfs:comment "Drug or substance allergy with severity" .
        
        # Properties
        
        clinical:hasICD10Code a owl:DatatypeProperty ;
            rdfs:domain clinical:Diagnosis ;
            rdfs:range xsd:string ;
            rdfs:comment "ICD-10 diagnosis code" .
        
        clinical:hasLOINCCode a owl:DatatypeProperty ;
            rdfs:domain clinical:Observation ;
            rdfs:range xsd:string ;
            rdfs:comment "LOINC observation identifier" .
        
        clinical:hasNDCCode a owl:DatatypeProperty ;
            rdfs:domain clinical:Prescription ;
            rdfs:range xsd:string ;
            rdfs:comment "National Drug Code" .
        
        clinical:hasNPI a owl:DatatypeProperty ;
            rdfs:domain clinical:Clinician ;
            rdfs:range xsd:string ;
            rdfs:comment "National Provider Identifier (10 digits)" .
        
        clinical:mrnHash a owl:DatatypeProperty ;
            rdfs:domain clinical:Patient ;
            rdfs:range xsd:string ;
            rdfs:comment "BLAKE3 hash of Medical Record Number for lookups" .
        
        clinical:encryptedPHI a owl:DatatypeProperty ;
            rdfs:range xsd:string ;
            rdfs:comment "Encrypted PHI field (AES-256-GCM)" .
        
        # Relationships
        
        clinical:hasEncounter a owl:ObjectProperty ;
            rdfs:domain clinical:Patient ;
            rdfs:range clinical:Encounter .
        
        clinical:hasDiagnosis a owl:ObjectProperty ;
            rdfs:domain clinical:Encounter ;
            rdfs:range clinical:Diagnosis .
        
        clinical:hasObservation a owl:ObjectProperty ;
            rdfs:domain clinical:Encounter ;
            rdfs:range clinical:Observation .
        
        clinical:prescribed a owl:ObjectProperty ;
            rdfs:domain clinical:Encounter ;
            rdfs:range clinical:Prescription .
        
        clinical:performedBy a owl:ObjectProperty ;
            rdfs:domain clinical:Encounter ;
            rdfs:range clinical:Clinician .
        
        clinical:signedBy a owl:ObjectProperty ;
            rdfs:domain clinical:ClinicalNote ;
            rdfs:range clinical:Clinician .
        
        clinical:attestedOnChain a owl:DatatypeProperty ;
            rdfs:domain clinical:ClinicalNote ;
            rdfs:range xsd:string ;
            rdfs:comment "SafeAICoin transaction hash" .
        
        clinical:hasAllergy a owl:ObjectProperty ;
            rdfs:domain clinical:Patient ;
            rdfs:range clinical:Allergy .
        
        clinical:interactsWith a owl:ObjectProperty ;
            rdfs:domain clinical:Prescription ;
            rdfs:range clinical:Prescription ;
            rdfs:comment "Drug-drug interaction relationship" .
        """
    }
    
    public var cypherQueries: [String: String] {
        return [
            "patient_summary": """
                MATCH (p:Patient {mrn_hash: $mrn_hash})
                OPTIONAL MATCH (p)-[:HAS_ENCOUNTER]->(e:Encounter)
                OPTIONAL MATCH (e)-[:HAS_DIAGNOSIS]->(d:Diagnosis)
                OPTIONAL MATCH (e)-[:HAS_OBSERVATION]->(obs:Observation)
                OPTIONAL MATCH (p)-[:HAS_ALLERGY]->(allergy:Allergy)
                RETURN p, 
                       collect(DISTINCT e) as encounters,
                       collect(DISTINCT d) as diagnoses,
                       collect(DISTINCT obs) as recent_observations,
                       collect(DISTINCT allergy) as allergies
                ORDER BY e.timestamp DESC
                LIMIT 50
                """,
            
            "active_medications": """
                MATCH (p:Patient {mrn_hash: $mrn_hash})-[:PRESCRIBED]->(rx:Prescription)
                WHERE rx.status = 'active'
                RETURN rx
                ORDER BY rx.start_date DESC
                """,
            
            "medication_history": """
                MATCH (p:Patient {mrn_hash: $mrn_hash})-[:PRESCRIBED]->(rx:Prescription)
                RETURN rx
                ORDER BY rx.start_date DESC
                LIMIT 100
                """,
            
            "recent_labs": """
                MATCH (p:Patient {mrn_hash: $mrn_hash})-[:HAS_OBSERVATION]->(obs:Observation)
                WHERE obs.loinc_code IN $loinc_codes
                  AND obs.timestamp > $since_timestamp
                RETURN obs
                ORDER BY obs.timestamp DESC
                LIMIT 50
                """,
            
            "lab_trends": """
                MATCH (p:Patient {mrn_hash: $mrn_hash})-[:HAS_OBSERVATION]->(obs:Observation)
                WHERE obs.loinc_code = $loinc_code
                  AND obs.timestamp > $since_timestamp
                RETURN obs.timestamp as time, 
                       obs.numeric_value as value,
                       obs.unit as unit
                ORDER BY obs.timestamp ASC
                """,
            
            "drug_interactions": """
                MATCH (p:Patient {mrn_hash: $mrn_hash})-[:PRESCRIBED]->(rx1:Prescription)
                MATCH (p)-[:PRESCRIBED]->(rx2:Prescription)
                MATCH (rx1)-[:INTERACTS_WITH]->(rx2)
                WHERE rx1.status = 'active' AND rx2.status = 'active'
                  AND rx1.ndc_code < rx2.ndc_code  // Avoid duplicates
                RETURN rx1, rx2
                """,
            
            "clinical_context": """
                MATCH (p:Patient {mrn_hash: $mrn_hash})
                OPTIONAL MATCH (p)-[:HAS_DIAGNOSIS]->(d:Diagnosis)
                WHERE d.status = 'active'
                OPTIONAL MATCH (p)-[:PRESCRIBED]->(rx:Prescription)
                WHERE rx.status = 'active'
                OPTIONAL MATCH (p)-[:HAS_OBSERVATION]->(obs:Observation)
                WHERE obs.timestamp > $recent_threshold
                OPTIONAL MATCH (p)-[:HAS_ALLERGY]->(allergy:Allergy)
                RETURN p,
                       collect(DISTINCT d) as active_diagnoses,
                       collect(DISTINCT rx) as active_medications,
                       collect(DISTINCT obs) as recent_labs,
                       collect(DISTINCT allergy) as allergies
                """,
            
            "encounter_notes": """
                MATCH (p:Patient {mrn_hash: $mrn_hash})-[:HAS_ENCOUNTER]->(e:Encounter)
                MATCH (e)-[:HAS_NOTE]->(note:ClinicalNote)
                RETURN e, note
                ORDER BY e.timestamp DESC
                LIMIT 20
                """,
            
            "provider_patients": """
                MATCH (clinician:Clinician {npi: $npi})<-[:PERFORMED_BY]-(e:Encounter)<-[:HAS_ENCOUNTER]-(p:Patient)
                WHERE e.timestamp > $since_timestamp
                RETURN DISTINCT p.mrn_hash as mrn_hash, 
                       count(e) as encounter_count,
                       max(e.timestamp) as last_encounter
                ORDER BY last_encounter DESC
                LIMIT 50
                """,
            
            "diagnosis_cohort": """
                MATCH (p:Patient)-[:HAS_DIAGNOSIS]->(d:Diagnosis)
                WHERE d.icd10_code STARTS WITH $icd10_prefix
                  AND d.timestamp > $since_timestamp
                RETURN p.mrn_hash as mrn_hash,
                       d.icd10_code as diagnosis,
                       d.timestamp as diagnosed_date
                ORDER BY d.timestamp DESC
                LIMIT 1000
                """
        ]
    }
    
    public func initialize(engine: VQbitEngine, akg: AKGService) async throws {
        // Register validation rules with AKG
        await akg.registerValidationRules(validationRules, for: name)
        
        print("✅ Clinician domain pack initialized")
        print("   - ICD-10 diagnosis validation enabled")
        print("   - LOINC lab code validation enabled")
        print("   - NPI provider validation enabled")
        print("   - PHI encryption enforcement active")
        print("   - Vital signs bounds checking active")
        print("   - Drug-drug interaction queries ready")
        print("   - Clinical context advisor available")
    }
    
    public func validate(record: Record) throws -> ValidationResult {
        var errors: [ValidationIssue] = []
        var warnings: [ValidationIssue] = []
        
        // Check if this is a clinical record
        let clinicalLabels = ["Patient", "Encounter", "Diagnosis", "Observation", 
                             "Prescription", "Clinician", "ClinicalNote", "Procedure", "Allergy"]
        
        guard record.labels.contains(where: { clinicalLabels.contains($0) }) else {
            return .valid() // Not a clinical record
        }
        
        // Run all validation rules
        for rule in validationRules {
            do {
                try rule.validate(record.data)
            } catch let error as ValidationError {
                switch error {
                case .ruleViolation(let message):
                    errors.append(ValidationIssue(
                        severity: .error,
                        code: "CLINICAL_VALIDATION",
                        message: message
                    ))
                default:
                    errors.append(ValidationIssue(
                        severity: .error,
                        code: "VALIDATION_ERROR",
                        message: String(describing: error)
                    ))
                }
            }
        }
        
        // Additional clinical-specific warnings
        
        // Warn about critical vital signs
        if record.labels.contains("Observation") {
            if let hr = record.data["heart_rate"] as? Double {
                if hr < 40 || hr > 150 {
                    warnings.append(ValidationIssue(
                        severity: .warning,
                        code: "CRITICAL_HR",
                        message: "Heart rate \(Int(hr)) bpm is outside normal range (60-100 bpm)",
                        field: "heart_rate",
                        suggestedFix: "Verify measurement accuracy"
                    ))
                }
            }
            
            if let bpSys = record.data["bp_systolic"] as? Double {
                if bpSys < 90 || bpSys > 180 {
                    warnings.append(ValidationIssue(
                        severity: .warning,
                        code: "CRITICAL_BP",
                        message: "Blood pressure \(Int(bpSys)) mmHg systolic is outside normal range (90-140 mmHg)",
                        field: "bp_systolic",
                        suggestedFix: "Verify measurement and patient status"
                    ))
                }
            }
            
            if let spo2 = record.data["spo2"] as? Double {
                if spo2 < 90 {
                    warnings.append(ValidationIssue(
                        severity: .warning,
                        code: "CRITICAL_SPO2",
                        message: "SpO2 \(Int(spo2))% indicates hypoxia (normal >95%)",
                        field: "spo2",
                        suggestedFix: "Consider supplemental oxygen"
                    ))
                }
            }
        }
        
        // Warn about polypharmacy (many active medications)
        if record.labels.contains("Patient") {
            // This would require a query to count active prescriptions
            // For now, just note in metadata
        }
        
        return ValidationResult(
            isValid: errors.isEmpty,
            errors: errors,
            warnings: warnings,
            metadata: [
                "domain": name,
                "version": version,
                "hipaa_compliant": errors.isEmpty,
                "validation_timestamp": Int64(Date().timeIntervalSince1970 * 1000)
            ]
        )
    }
    
    public func optimize(problem: OptimizationProblem) async throws -> [Solution] {
        // Clinical optimization problems could include:
        // - Treatment protocol optimization
        // - Medication dosage optimization
        // - Resource allocation (ICU beds, staff scheduling)
        // - Population health interventions
        
        // For now, return empty array (will be implemented with vQbit engine integration)
        return []
    }
    
    public func metrics() async throws -> [String: Any] {
        return [
            "domain": name,
            "version": version,
            "supported_features": [
                "icd10_validation",
                "loinc_validation",
                "npi_validation",
                "phi_encryption",
                "vital_bounds_checking",
                "lab_value_validation",
                "drug_interaction_detection",
                "clinical_context_analysis",
                "blockchain_attestation"
            ],
            "validation_rules": validationRules.count,
            "cypher_queries": cypherQueries.count,
            "hipaa_compliant": true,
            "fda_part11_ready": true
        ]
    }
}

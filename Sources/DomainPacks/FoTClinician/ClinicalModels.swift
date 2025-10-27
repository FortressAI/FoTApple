import Foundation

/// Clinical data models for the Clinician domain pack

// MARK: - Patient

public struct Patient: Codable, Identifiable {
    public let id: String // ULID
    public let mrnHash: String // BLAKE3 hash of MRN
    public let encryptedPHI: EncryptedPHI
    public let ageYears: Double?
    public let gender: Gender?
    public let createdAt: Date
    
    public init(id: String, mrnHash: String, encryptedPHI: EncryptedPHI, 
                ageYears: Double? = nil, gender: Gender? = nil, createdAt: Date = Date()) {
        self.id = id
        self.mrnHash = mrnHash
        self.encryptedPHI = encryptedPHI
        self.ageYears = ageYears
        self.gender = gender
        self.createdAt = createdAt
    }
}

public struct EncryptedPHI: Codable {
    public let name: String? // "enc:..."
    public let dob: String? // "enc:..."
    public let ssn: String? // "enc:..."
    public let address: String? // "enc:..."
    public let phone: String? // "enc:..."
    public let email: String? // "enc:..."
    
    public init(name: String? = nil, dob: String? = nil, ssn: String? = nil,
                address: String? = nil, phone: String? = nil, email: String? = nil) {
        self.name = name
        self.dob = dob
        self.ssn = ssn
        self.address = address
        self.phone = phone
        self.email = email
    }
}

public enum Gender: String, Codable {
    case male = "M"
    case female = "F"
    case other = "O"
    case unknown = "U"
}

// MARK: - Encounter

public struct Encounter: Codable, Identifiable {
    public let id: String // ULID
    public let patientMRNHash: String
    public let encounterType: EncounterType
    public let timestamp: Date
    public let location: String?
    public let chiefComplaint: String?
    public let status: EncounterStatus
    
    public init(id: String, patientMRNHash: String, encounterType: EncounterType,
                timestamp: Date = Date(), location: String? = nil, 
                chiefComplaint: String? = nil, status: EncounterStatus = .active) {
        self.id = id
        self.patientMRNHash = patientMRNHash
        self.encounterType = encounterType
        self.timestamp = timestamp
        self.location = location
        self.chiefComplaint = chiefComplaint
        self.status = status
    }
}

public enum EncounterType: String, Codable {
    case inpatient = "IP"
    case outpatient = "OP"
    case emergency = "ER"
    case telehealth = "TH"
    case homeHealth = "HH"
}

public enum EncounterStatus: String, Codable {
    case active = "active"
    case completed = "completed"
    case cancelled = "cancelled"
}

// MARK: - Diagnosis

public struct Diagnosis: Codable, Identifiable {
    public let id: String // ULID
    public let encounterID: String
    public let icd10Code: String // e.g., "I50.9"
    public let description: String
    public let status: DiagnosisStatus
    public let timestamp: Date
    
    public init(id: String, encounterID: String, icd10Code: String, 
                description: String, status: DiagnosisStatus = .active, timestamp: Date = Date()) {
        self.id = id
        self.encounterID = encounterID
        self.icd10Code = icd10Code
        self.description = description
        self.status = status
        self.timestamp = timestamp
    }
}

public enum DiagnosisStatus: String, Codable {
    case active = "active"
    case resolved = "resolved"
    case ruled_out = "ruled_out"
}

// MARK: - Observation (Labs, Vitals)

public struct Observation: Codable, Identifiable {
    public let id: String // ULID
    public let encounterID: String
    public let loincCode: String // e.g., "2951-2" for Sodium
    public let description: String
    public let value: ObservationValue
    public let unit: String?
    public let referenceRange: ReferenceRange?
    public let timestamp: Date
    public let status: ObservationStatus
    
    public init(id: String, encounterID: String, loincCode: String, description: String,
                value: ObservationValue, unit: String? = nil, referenceRange: ReferenceRange? = nil,
                timestamp: Date = Date(), status: ObservationStatus = .final) {
        self.id = id
        self.encounterID = encounterID
        self.loincCode = loincCode
        self.description = description
        self.value = value
        self.unit = unit
        self.referenceRange = referenceRange
        self.timestamp = timestamp
        self.status = status
    }
}

public enum ObservationValue: Codable {
    case numeric(Double)
    case text(String)
    case boolean(Bool)
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let doubleValue = try? container.decode(Double.self) {
            self = .numeric(doubleValue)
        } else if let stringValue = try? container.decode(String.self) {
            self = .text(stringValue)
        } else if let boolValue = try? container.decode(Bool.self) {
            self = .boolean(boolValue)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid observation value")
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .numeric(let value):
            try container.encode(value)
        case .text(let value):
            try container.encode(value)
        case .boolean(let value):
            try container.encode(value)
        }
    }
}

public struct ReferenceRange: Codable {
    public let low: Double?
    public let high: Double?
    public let unit: String
    
    public init(low: Double? = nil, high: Double? = nil, unit: String) {
        self.low = low
        self.high = high
        self.unit = unit
    }
}

public enum ObservationStatus: String, Codable {
    case preliminary = "preliminary"
    case final = "final"
    case corrected = "corrected"
    case cancelled = "cancelled"
}

// MARK: - Vital Signs

public struct VitalSigns: Codable {
    public let heartRate: Double? // bpm
    public let bloodPressure: BloodPressure?
    public let temperature: Double? // Celsius
    public let spo2: Double? // %
    public let respiratoryRate: Double? // breaths/min
    public let timestamp: Date
    
    public init(heartRate: Double? = nil, bloodPressure: BloodPressure? = nil,
                temperature: Double? = nil, spo2: Double? = nil, 
                respiratoryRate: Double? = nil, timestamp: Date = Date()) {
        self.heartRate = heartRate
        self.bloodPressure = bloodPressure
        self.temperature = temperature
        self.spo2 = spo2
        self.respiratoryRate = respiratoryRate
        self.timestamp = timestamp
    }
}

public struct BloodPressure: Codable {
    public let systolic: Double // mmHg
    public let diastolic: Double // mmHg
    
    public init(systolic: Double, diastolic: Double) {
        self.systolic = systolic
        self.diastolic = diastolic
    }
}

// MARK: - Prescription

public struct Prescription: Codable, Identifiable {
    public let id: String // ULID
    public let encounterID: String
    public let ndcCode: String // National Drug Code
    public let medicationName: String
    public let dose: Dose
    public let frequency: String // e.g., "BID", "TID", "QD"
    public let route: Route
    public let startDate: Date
    public let endDate: Date?
    public let status: PrescriptionStatus
    public let prescribedBy: String // NPI
    
    public init(id: String, encounterID: String, ndcCode: String, medicationName: String,
                dose: Dose, frequency: String, route: Route, startDate: Date = Date(),
                endDate: Date? = nil, status: PrescriptionStatus = .active, prescribedBy: String) {
        self.id = id
        self.encounterID = encounterID
        self.ndcCode = ndcCode
        self.medicationName = medicationName
        self.dose = dose
        self.frequency = frequency
        self.route = route
        self.startDate = startDate
        self.endDate = endDate
        self.status = status
        self.prescribedBy = prescribedBy
    }
}

public struct Dose: Codable {
    public let value: Double
    public let unit: String // "mg", "mcg", "mL", etc.
    
    public init(value: Double, unit: String) {
        self.value = value
        self.unit = unit
    }
}

public enum Route: String, Codable {
    case oral = "PO"
    case intravenous = "IV"
    case intramuscular = "IM"
    case subcutaneous = "SC"
    case topical = "TOP"
    case inhalation = "INH"
    case sublingual = "SL"
    case rectal = "PR"
}

public enum PrescriptionStatus: String, Codable {
    case active = "active"
    case completed = "completed"
    case discontinued = "discontinued"
    case hold = "hold"
}

// MARK: - Drug Interaction

public struct DrugInteraction: Codable, Identifiable {
    public var id: String { "\(drug1NDC)_\(drug2NDC)" }
    public let drug1NDC: String
    public let drug2NDC: String
    public let severity: InteractionSeverity
    public let description: String
    public let clinicalSignificance: String?
    
    public init(drug1NDC: String, drug2NDC: String, severity: InteractionSeverity,
                description: String, clinicalSignificance: String? = nil) {
        self.drug1NDC = drug1NDC
        self.drug2NDC = drug2NDC
        self.severity = severity
        self.description = description
        self.clinicalSignificance = clinicalSignificance
    }
}

public enum InteractionSeverity: String, Codable {
    case major = "major"
    case moderate = "moderate"
    case minor = "minor"
}

// MARK: - Allergy

public struct Allergy: Codable, Identifiable {
    public let id: String // ULID
    public let patientMRNHash: String
    public let allergen: String
    public let reaction: String?
    public let severity: AllergySeverity
    public let reportedDate: Date
    
    public init(id: String, patientMRNHash: String, allergen: String, 
                reaction: String? = nil, severity: AllergySeverity, reportedDate: Date = Date()) {
        self.id = id
        self.patientMRNHash = patientMRNHash
        self.allergen = allergen
        self.reaction = reaction
        self.severity = severity
        self.reportedDate = reportedDate
    }
}

public enum AllergySeverity: String, Codable {
    case mild = "mild"
    case moderate = "moderate"
    case severe = "severe"
    case lifeThreatening = "life_threatening"
}

// MARK: - Clinician

public struct Clinician: Codable, Identifiable {
    public let id: String // ULID
    public let npi: String // 10-digit NPI
    public let name: String
    public let specialty: String?
    public let credentials: [String] // ["MD", "PhD", etc.]
    
    public init(id: String, npi: String, name: String, specialty: String? = nil, credentials: [String] = []) {
        self.id = id
        self.npi = npi
        self.name = name
        self.specialty = specialty
        self.credentials = credentials
    }
}

// MARK: - Clinical Note

public struct ClinicalNote: Codable, Identifiable {
    public let id: String // ULID
    public let encounterID: String
    public let noteType: NoteType
    public let content: String
    public let signedBy: String // NPI
    public let signedAt: Date?
    public let attestationID: String? // From blockchain
    public let chainTX: String? // SafeAICoin transaction hash
    
    public init(id: String, encounterID: String, noteType: NoteType, content: String,
                signedBy: String, signedAt: Date? = nil, attestationID: String? = nil, 
                chainTX: String? = nil) {
        self.id = id
        self.encounterID = encounterID
        self.noteType = noteType
        self.content = content
        self.signedBy = signedBy
        self.signedAt = signedAt
        self.attestationID = attestationID
        self.chainTX = chainTX
    }
}

public enum NoteType: String, Codable {
    case soap = "SOAP"
    case progress = "Progress"
    case historyPhysical = "H&P"
    case discharge = "Discharge"
    case procedure = "Procedure"
    case consultation = "Consult"
}

// MARK: - Clinical Context

public struct ClinicalContext: Codable {
    public let patient: Patient
    public let activeDiagnoses: [Diagnosis]
    public let activeMedications: [Prescription]
    public let recentLabs: [Observation]
    public let allergies: [Allergy]
    public let latestVitals: VitalSigns?
    
    public init(patient: Patient, activeDiagnoses: [Diagnosis] = [], 
                activeMedications: [Prescription] = [], recentLabs: [Observation] = [],
                allergies: [Allergy] = [], latestVitals: VitalSigns? = nil) {
        self.patient = patient
        self.activeDiagnoses = activeDiagnoses
        self.activeMedications = activeMedications
        self.recentLabs = recentLabs
        self.allergies = allergies
        self.latestVitals = latestVitals
    }
}

// MARK: - Clinical Suggestion (from AI advisor)

public struct ClinicalSuggestion: Codable, Identifiable {
    public let id: String // ULID
    public let type: SuggestionType
    public let title: String
    public let description: String
    public let confidence: Double // 0.0-1.0
    public let supportingEvidence: [String]
    public let references: [String]?
    
    public init(id: String, type: SuggestionType, title: String, description: String,
                confidence: Double, supportingEvidence: [String], references: [String]? = nil) {
        self.id = id
        self.type = type
        self.title = title
        self.description = description
        self.confidence = confidence
        self.supportingEvidence = supportingEvidence
        self.references = references
    }
}

public enum SuggestionType: String, Codable {
    case differential = "differential_diagnosis"
    case drugInteraction = "drug_interaction"
    case labInterpretation = "lab_interpretation"
    case treatmentOption = "treatment_option"
    case preventiveCare = "preventive_care"
    case alert = "clinical_alert"
}


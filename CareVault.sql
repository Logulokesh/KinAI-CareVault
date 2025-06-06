-- Family Members Table
-- Stores information about family members for medical record tracking
CREATE TABLE family_members (
    id SERIAL PRIMARY KEY,
    telegram_user_id BIGINT NOT NULL,
    telegram_username VARCHAR(255),
    name VARCHAR(255) NOT NULL,
    date_of_birth DATE, -- Expected format: YYYY-MM-DD
    gender VARCHAR(20) CHECK (gender IN ('Male', 'Female', 'Other', 'Not Specified')),
    blood_type VARCHAR(10),
    emergency_contact_name VARCHAR(255),
    emergency_contact_phone VARCHAR(15) CHECK (emergency_contact_phone ~ '^\+?[1-9]\d{1,14}$'), -- Enforce standard phone number format
    primary_doctor VARCHAR(255),
    primary_clinic VARCHAR(255),
    insurance_provider VARCHAR(255),
    insurance_number VARCHAR(100), -- Recommend column-level encryption for this field
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Ensure unique combination of telegram_user_id and name
    UNIQUE(telegram_user_id, name)
);

-- Medical Conditions Table
-- Stores pre-existing and ongoing medical conditions for family members
CREATE TABLE medical_conditions (
    id SERIAL PRIMARY KEY,
    family_member_id INTEGER NOT NULL REFERENCES family_members(id) ON DELETE CASCADE,
    condition_name VARCHAR(255) NOT NULL,
    condition_type VARCHAR(50) CHECK (condition_type IN ('Chronic', 'Acute', 'Genetic', 'Allergy', 'Past', 'Current')),
    severity VARCHAR(20) DEFAULT 'Moderate' CHECK (severity IN ('Mild', 'Moderate', 'Severe', 'Critical')),
    diagnosed_date DATE, -- Expected format: YYYY-MM-DD
    diagnosed_by VARCHAR(255),
    status VARCHAR(20) DEFAULT 'Active' CHECK (status IN ('Active', 'Inactive', 'Resolved', 'Monitoring')),
    description TEXT,
    treatment_notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Prevent duplicate conditions for the same person
    UNIQUE(family_member_id, condition_name)
);

-- Current Medications Table
-- Stores current medications and prescriptions for family members
CREATE TABLE current_medications (
    id SERIAL PRIMARY KEY,
    family_member_id INTEGER NOT NULL REFERENCES family_members(id) ON DELETE CASCADE,
    medication_name VARCHAR(255) NOT NULL,
    generic_name VARCHAR(255),
    dosage VARCHAR(100),
    frequency VARCHAR(100),
    route VARCHAR(50) CHECK (route IN ('Oral', 'Topical', 'Injection', 'Inhalation', 'IV', 'Other')), -- Fixed missing quote
    prescribed_by VARCHAR(255),
    prescribed_date DATE, -- Expected format: YYYY-MM-DD
    start_date DATE, -- Expected format: YYYY-MM-DD
    end_date DATE, -- Expected format: YYYY-MM-DD
    purpose TEXT,
    side_effects TEXT,
    special_instructions TEXT,
    status VARCHAR(20) DEFAULT 'Active' CHECK (status IN ('Active', 'Discontinued', 'Paused', 'Completed')),
    pharmacy VARCHAR(255),
    prescription_number VARCHAR(100),
    refills_remaining INTEGER DEFAULT 0,
    last_refill_date DATE, -- Expected format: YYYY-MM-DD
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Allergies Table
-- Stores allergy information for family members
CREATE TABLE allergies (
    id SERIAL PRIMARY KEY,
    family_member_id INTEGER NOT NULL REFERENCES family_members(id) ON DELETE CASCADE,
    allergen VARCHAR(255) NOT NULL,
    allergy_type VARCHAR(50) CHECK (allergy_type IN ('Food', 'Drug', 'Environmental', 'Contact', 'Other')),
    severity VARCHAR(20) DEFAULT 'Moderate' CHECK (severity IN ('Mild', 'Moderate', 'Severe', 'Life-threatening')),
    reaction_symptoms TEXT,
    first_occurrence_date DATE, -- Expected format: YYYY-MM-DD
    last_reaction_date DATE, -- Expected format: YYYY-MM-DD
    treatment_required TEXT,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Prevent duplicate allergies for the same person
    UNIQUE(family_member_id, allergen)
);

-- Medical Records Table
-- Stores detailed medical information extracted from medical documents
CREATE TABLE medical_records (
    id SERIAL PRIMARY KEY,
    family_member_id INTEGER NOT NULL REFERENCES family_members(id) ON DELETE CASCADE,
    document_type VARCHAR(50) NOT NULL CHECK (document_type IN ('Receipt', 'Invoice', 'Bill', 'Statement', 'Medical_Report', 'Lab_Results', 'Prescription', 'Medical_Invoice')),
    test_date DATE, -- Expected format: YYYY-MM-DD
    doctor_name VARCHAR(255),
    clinic_name VARCHAR(255),
    test_type VARCHAR(255),
    test_results TEXT,
    abnormal_values TEXT,
    recommendations TEXT,
    diagnosis TEXT,
    medications TEXT,
    next_appointment DATE, -- Expected format: YYYY-MM-DD
    urgency_level VARCHAR(20) DEFAULT 'Low' CHECK (urgency_level IN ('Low', 'Medium', 'High', 'Critical')),
    medical_category VARCHAR(100),
    document_image_path VARCHAR(500),
    telegram_message_id BIGINT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Financial Records Table
-- Stores financial transaction information from receipts, invoices, etc.
CREATE TABLE financial_records (
    id SERIAL PRIMARY KEY,
    telegram_user_id BIGINT NOT NULL,
    document_type VARCHAR(50) NOT NULL CHECK (document_type IN ('Receipt', 'Invoice', 'Bill', 'Statement', 'Medical_Report', 'Lab_Results', 'Prescription', 'Medical_Invoice')),
    category VARCHAR(50) NOT NULL CHECK (category IN ('Groceries', 'Electronics', 'Fuel', 'Dining', 'Clothing', 'Hardware', 'Pharmacy', 'Department', 'Utilities', 'Transport', 'Entertainment', 'Health', 'Education', 'Medical', 'General')),
    vendor VARCHAR(255),
    amount DECIMAL(10,2),
    transaction_date DATE, -- Expected format: YYYY-MM-DD
    description TEXT,
    document_image_path VARCHAR(500),
    telegram_message_id BIGINT,
    vikunja_task_id INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for better performance
CREATE INDEX idx_family_members_telegram_user_id ON family_members(telegram_user_id);
CREATE INDEX idx_medical_records_family_member_id ON medical_records(family_member_id);
CREATE INDEX idx_medical_records_test_date ON medical_records(test_date);
CREATE INDEX idx_medical_records_urgency_level ON medical_records(urgency_level);
CREATE INDEX idx_medical_records_medical_category ON medical_records(medical_category);
CREATE INDEX idx_financial_records_telegram_user_id ON financial_records(telegram_user_id);
CREATE INDEX idx_financial_records_category ON financial_records(category);
CREATE INDEX idx_financial_records_transaction_date ON financial_records(transaction_date);
CREATE INDEX idx_financial_records_vendor ON financial_records(vendor);

-- New indexes for medical condition and medication tables
CREATE INDEX idx_medical_conditions_family_member_id ON medical_conditions(family_member_id);
CREATE INDEX idx_medical_conditions_status ON medical_conditions(status);
CREATE INDEX idx_medical_conditions_condition_type ON medical_conditions(condition_type);
CREATE INDEX idx_current_medications_family_member_id ON current_medications(family_member_id);
CREATE INDEX idx_current_medications_status ON current_medications(status);
CREATE INDEX idx_current_medications_end_date ON current_medications(end_date);
CREATE INDEX idx_allergies_family_member_id ON allergies(family_member_id);
CREATE INDEX idx_allergies_severity ON allergies(severity);

-- Trigger function to update the updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply the trigger to all tables
CREATE TRIGGER update_family_members_updated_at
    BEFORE UPDATE ON family_members
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_medical_records_updated_at
    BEFORE UPDATE ON medical_records
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_financial_records_updated_at
    BEFORE UPDATE ON financial_records
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_medical_conditions_updated_at
    BEFORE UPDATE ON medical_conditions
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_current_medications_updated_at
    BEFORE UPDATE ON current_medications
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_allergies_updated_at
    BEFORE UPDATE ON allergies
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Sample queries for common operations

-- Get all medical records for a specific family member
-- SELECT mr.*, fm.name as patient_name 
-- FROM medical_records mr 
-- JOIN family_members fm ON mr.family_member_id = fm.id 
-- WHERE fm.telegram_user_id = ? AND fm.name = ?;

-- Get financial summary by category for a user
-- SELECT category, COUNT(*) as record_count, SUM(amount) as total_amount
-- FROM financial_records 
-- WHERE telegram_user_id = ? 
-- GROUP BY category 
-- ORDER BY total_amount DESC;

-- Get high urgency medical records that need attention
-- SELECT mr.*, fm.name as patient_name
-- FROM medical_records mr
-- JOIN family_members fm ON mr.family_member_id = fm.id
-- WHERE mr.urgency_level IN ('High', 'Critical')
-- AND mr.next_appointment IS NOT NULL
-- ORDER BY mr.next_appointment ASC;

-- Get complete medical profile for a family member
-- SELECT 
--     fm.name,
--     fm.date_of_birth,
--     fm.blood_type,
--     fm.primary_doctor,
--     JSON_AGG(DISTINCT jsonb_build_object(
--         'condition', mc.condition_name,
--         'type', mc.condition_type,
--         'severity', mc.severity,
--         'status', mc.status
--     )) FILTER (WHERE mc.id IS NOT NULL) as conditions,
--     JSON_AGG(DISTINCT jsonb_build_object(
--         'medication', cm.medication_name,
--         'dosage', cm.dosage,
--         'frequency', cm.frequency,
--         'status', cm.status
--     )) FILTER (WHERE cm.id IS NOT NULL) as medications,
--     JSON_AGG(DISTINCT jsonb_build_object(
--         'allergen', a.allergen,
--         'type', a.allergy_type,
--         'severity', a.severity
--     )) FILTER (WHERE a.id IS NOT NULL) as allergies
-- FROM family_members fm
-- LEFT JOIN medical_conditions mc ON fm.id = mc.family_member_id AND mc.status = 'Active'
-- LEFT JOIN current_medications cm ON fm.id = cm.family_member_id AND cm.status = 'Active'
-- LEFT JOIN allergies a ON fm.id = a.family_member_id
-- WHERE fm.telegram_user_id = ? AND fm.name = ?
-- GROUP BY fm.id, fm.name, fm.date_of_birth, fm.blood_type, fm.primary_doctor;

-- Get medications that need refills soon (less than 5 refills remaining)
-- SELECT 
--     fm.name as patient_name,
--     cm.medication_name,
--     cm.dosage,
--     cm.refills_remaining,
--     cm.pharmacy,
--     cm.prescribed_by
-- FROM current_medications cm
-- JOIN family_members fm ON cm.family_member_id = fm.id
-- WHERE cm.status = 'Active' 
-- AND cm.refills_remaining <= 5
-- AND cm.refills_remaining > 0
-- ORDER BY cm.refills_remaining ASC;

-- Get medications expiring soon (within next 30 days)
-- SELECT 
--     fm.name as patient_name,
--     cm.medication_name,
--     cm.dosage,
--     cm.end_date,
--     cm.prescribed_by
-- FROM current_medications cm
-- JOIN family_members fm ON cm.family_member_id = fm.id
-- WHERE cm.status = 'Active' 
-- AND cm.end_date IS NOT NULL
-- AND cm.end_date BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '30 days'
-- ORDER BY cm.end_date ASC;

-- Get severe allergies for emergency reference
-- SELECT 
--     fm.name as patient_name,
--     fm.emergency_contact_name,
--     fm.emergency_contact_phone,
--     a.allergen,
--     a.allergy_type,
--     a.reaction_symptoms,
--     a.treatment_required
-- FROM allergies a
-- JOIN family_members fm ON a.family_member_id = fm.id
-- WHERE a.severity IN ('Severe', 'Life-threatening')
-- ORDER BY fm.name, a.severity DESC;
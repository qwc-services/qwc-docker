-- Table pour stocker les soumissions du wizard

CREATE TABLE IF NOT EXISTS qwc_geodb.wizard_submissions (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    preference VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Index pour améliorer les performances
CREATE INDEX IF NOT EXISTS idx_wizard_submissions_created_at 
    ON qwc_geodb.wizard_submissions(created_at DESC);

CREATE INDEX IF NOT EXISTS idx_wizard_submissions_email 
    ON qwc_geodb.wizard_submissions(email);

-- Commentaires pour documentation
COMMENT ON TABLE qwc_geodb.wizard_submissions IS 'Submissions from the HelloWizard plugin';
COMMENT ON COLUMN qwc_geodb.wizard_submissions.name IS 'User name';
COMMENT ON COLUMN qwc_geodb.wizard_submissions.email IS 'User email address';
COMMENT ON COLUMN qwc_geodb.wizard_submissions.preference IS 'Selected preference (option1, option2, option3)';

-- Permissions pour les utilisateurs QWC
GRANT SELECT, INSERT, UPDATE, DELETE ON qwc_geodb.wizard_submissions TO qwc_service_write;
GRANT SELECT ON qwc_geodb.wizard_submissions TO qwc_service, qwc_admin;

GRANT USAGE, SELECT ON SEQUENCE qwc_geodb.wizard_submissions_id_seq TO qwc_service_write;
GRANT SELECT ON SEQUENCE qwc_geodb.wizard_submissions_id_seq TO qwc_service, qwc_admin;

-- Vue pour les statistiques (optionnel)
CREATE OR REPLACE VIEW wizard_submissions_stats AS
SELECT 
    preference,
    COUNT(*) as total_count,
    COUNT(*) * 100.0 / SUM(COUNT(*)) OVER() as percentage
FROM qwc_geodb.wizard_submissions
GROUP BY preference
ORDER BY total_count DESC;

GRANT SELECT ON qwc_geodb.wizard_submissions_stats TO qwc_service;
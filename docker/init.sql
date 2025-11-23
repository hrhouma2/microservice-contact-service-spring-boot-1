-- Script d'initialisation de la base de données
-- Exécuté automatiquement au démarrage du conteneur PostgreSQL

CREATE TABLE IF NOT EXISTS form_submissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    form_id VARCHAR(100) NOT NULL,
    email VARCHAR(500) NOT NULL,
    name VARCHAR(500),
    message TEXT,
    page_url VARCHAR(500),
    referrer VARCHAR(500),
    data JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Index pour améliorer les performances
CREATE INDEX IF NOT EXISTS idx_form_submissions_form_id ON form_submissions(form_id);
CREATE INDEX IF NOT EXISTS idx_form_submissions_email ON form_submissions(email);
CREATE INDEX IF NOT EXISTS idx_form_submissions_created_at ON form_submissions(created_at DESC);

-- Index GIN pour les recherches JSON
CREATE INDEX IF NOT EXISTS idx_form_submissions_data_gin ON form_submissions USING GIN (data);

-- Commentaires
COMMENT ON TABLE form_submissions IS 'Stockage des soumissions de formulaires de contact';
COMMENT ON COLUMN form_submissions.form_id IS 'Identifiant du formulaire (ex: astro-contact)';
COMMENT ON COLUMN form_submissions.data IS 'Champs dynamiques supplémentaires (JSON)';


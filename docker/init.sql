-- Creation de la table des messages de contact
CREATE TABLE IF NOT EXISTS contact_submissions (
    id BIGSERIAL PRIMARY KEY,
    nom VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    telephone VARCHAR(50),
    sujet VARCHAR(500) NOT NULL,
    message TEXT NOT NULL,
    date_soumission TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ip_address VARCHAR(50),
    user_agent TEXT,
    statut VARCHAR(50) DEFAULT 'NOUVEAU',
    lu BOOLEAN DEFAULT FALSE,
    date_lecture TIMESTAMP,
    notes_admin TEXT,
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_modification TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Index pour ameliorer les performances
CREATE INDEX IF NOT EXISTS idx_email ON contact_submissions(email);
CREATE INDEX IF NOT EXISTS idx_date_soumission ON contact_submissions(date_soumission DESC);
CREATE INDEX IF NOT EXISTS idx_statut ON contact_submissions(statut);
CREATE INDEX IF NOT EXISTS idx_lu ON contact_submissions(lu);

-- Trigger pour mise a jour automatique de date_modification
CREATE OR REPLACE FUNCTION update_modified_date()
RETURNS TRIGGER AS $$
BEGIN
    NEW.date_modification = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_contact_modified
BEFORE UPDATE ON contact_submissions
FOR EACH ROW
EXECUTE FUNCTION update_modified_date();

-- Donnees de demonstration (optionnel - peut etre commente si non desire)
INSERT INTO contact_submissions (nom, email, telephone, sujet, message, ip_address)
VALUES 
    ('Jean Dupont', 'jean.dupont@example.com', '0612345678', 'Demande d''information', 'Bonjour, je souhaite avoir plus d''informations sur vos services.', '192.168.1.100'),
    ('Marie Martin', 'marie.martin@example.com', '0687654321', 'Support technique', 'J''ai un probleme avec mon compte.', '192.168.1.101'),
    ('Pierre Durand', 'pierre.durand@example.com', '0698765432', 'Partenariat', 'Je suis interesse par un partenariat.', '192.168.1.102')
ON CONFLICT DO NOTHING;


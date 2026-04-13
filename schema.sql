-- ============================================================
-- FidéliTab — Schéma Supabase
-- À coller et exécuter dans : Supabase > SQL Editor > New query
-- ============================================================

-- 1. TABLE MEMBRES
CREATE TABLE IF NOT EXISTS membres (
  id               UUID    DEFAULT gen_random_uuid() PRIMARY KEY,
  nom              TEXT    NOT NULL,
  telephone        TEXT    UNIQUE NOT NULL,
  email            TEXT,
  date_naissance   DATE,
  points           INTEGER DEFAULT 0,
  visites          INTEGER DEFAULT 0,
  rgpd_accepte_le  TIMESTAMPTZ,
  cree_le          TIMESTAMPTZ DEFAULT NOW(),
  mis_a_jour_le    TIMESTAMPTZ DEFAULT NOW()
);

-- 2. TABLE RÈGLES TAMPONS (configurables depuis l'admin)
CREATE TABLE IF NOT EXISTS regles_tampons (
  id                  SERIAL  PRIMARY KEY,
  nom                 TEXT    NOT NULL,
  emoji               TEXT    DEFAULT '🛒',
  objectif            INTEGER NOT NULL DEFAULT 10,
  recompense          TEXT    NOT NULL,
  points_par_tampon   INTEGER DEFAULT 5,
  actif               BOOLEAN DEFAULT TRUE,
  ordre               INTEGER DEFAULT 0,
  cree_le             TIMESTAMPTZ DEFAULT NOW()
);

-- Données par défaut
INSERT INTO regles_tampons (nom, emoji, objectif, recompense, points_par_tampon, ordre) VALUES
  ('Tabac',  '🚬', 10, '1 paquet au choix offert', 5, 1),
  ('Café',   '☕',  5, '1 café offert',             2, 2),
  ('Presse', '📰',  8, '1 journal offert',          3, 3),
  ('E-cig',  '💨',  6, '1 recharge offerte',        4, 4)
ON CONFLICT DO NOTHING;

-- 3. TABLE CARTES TAMPONS (une par membre par règle)
CREATE TABLE IF NOT EXISTS cartes_tampons (
  id               UUID    DEFAULT gen_random_uuid() PRIMARY KEY,
  membre_id        UUID    NOT NULL REFERENCES membres(id) ON DELETE CASCADE,
  regle_id         INTEGER NOT NULL REFERENCES regles_tampons(id),
  compteur         INTEGER DEFAULT 0,
  total_complete   INTEGER DEFAULT 0,
  mis_a_jour_le    TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(membre_id, regle_id)
);

-- 4. TABLE TRANSACTIONS
CREATE TABLE IF NOT EXISTS transactions (
  id          UUID    DEFAULT gen_random_uuid() PRIMARY KEY,
  membre_id   UUID    NOT NULL REFERENCES membres(id) ON DELETE CASCADE,
  type        TEXT    NOT NULL CHECK (type IN ('gain','echange','bonus','tampon','recompense')),
  points      INTEGER NOT NULL DEFAULT 0,
  description TEXT,
  regle_id    INTEGER REFERENCES regles_tampons(id),
  cree_le     TIMESTAMPTZ DEFAULT NOW()
);

-- 5. INDEX POUR LES PERFORMANCES
CREATE INDEX IF NOT EXISTS idx_membres_telephone    ON membres(telephone);
CREATE INDEX IF NOT EXISTS idx_cartes_membre        ON cartes_tampons(membre_id);
CREATE INDEX IF NOT EXISTS idx_transactions_membre  ON transactions(membre_id);
CREATE INDEX IF NOT EXISTS idx_transactions_date    ON transactions(cree_le DESC);

-- 6. MISE À JOUR AUTOMATIQUE DU TIMESTAMP
CREATE OR REPLACE FUNCTION update_timestamp()
RETURNS TRIGGER AS $$
BEGIN NEW.mis_a_jour_le = NOW(); RETURN NEW; END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER membres_ts    BEFORE UPDATE ON membres         FOR EACH ROW EXECUTE FUNCTION update_timestamp();
CREATE TRIGGER cartes_ts     BEFORE UPDATE ON cartes_tampons  FOR EACH ROW EXECUTE FUNCTION update_timestamp();

-- 7. ROW LEVEL SECURITY (RLS)
ALTER TABLE membres          ENABLE ROW LEVEL SECURITY;
ALTER TABLE cartes_tampons   ENABLE ROW LEVEL SECURITY;
ALTER TABLE transactions     ENABLE ROW LEVEL SECURITY;
ALTER TABLE regles_tampons   ENABLE ROW LEVEL SECURITY;

-- Règles tampons : lecture publique
CREATE POLICY "regles_publiques"    ON regles_tampons  FOR SELECT TO anon USING (actif = TRUE);

-- Membres : inscription + lecture + mise à jour publique
CREATE POLICY "membres_select"      ON membres         FOR SELECT TO anon USING (TRUE);
CREATE POLICY "membres_insert"      ON membres         FOR INSERT TO anon WITH CHECK (TRUE);
CREATE POLICY "membres_update"      ON membres         FOR UPDATE TO anon USING (TRUE);

-- Cartes tampons : CRUD public
CREATE POLICY "cartes_select"       ON cartes_tampons  FOR SELECT TO anon USING (TRUE);
CREATE POLICY "cartes_insert"       ON cartes_tampons  FOR INSERT TO anon WITH CHECK (TRUE);
CREATE POLICY "cartes_update"       ON cartes_tampons  FOR UPDATE TO anon USING (TRUE);

-- Transactions : lecture + insertion publique
CREATE POLICY "transactions_select" ON transactions    FOR SELECT TO anon USING (TRUE);
CREATE POLICY "transactions_insert" ON transactions    FOR INSERT TO anon WITH CHECK (TRUE);

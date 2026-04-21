-- ============================================================
-- FidéliTab — Patch codes de validation
-- À exécuter dans Supabase > SQL Editor
-- ============================================================

CREATE TABLE IF NOT EXISTS codes_validation (
  id          UUID        DEFAULT gen_random_uuid() PRIMARY KEY,
  code        TEXT        NOT NULL,
  expire_le   TIMESTAMPTZ NOT NULL,
  utilise     BOOLEAN     DEFAULT FALSE,
  utilise_le  TIMESTAMPTZ,
  membre_id   UUID        REFERENCES membres(id),
  regle_id    INTEGER     REFERENCES regles_tampons(id),
  cree_le     TIMESTAMPTZ DEFAULT NOW()
);

-- Ajout de regle_id si la table existait déjà sans cette colonne
ALTER TABLE codes_validation ADD COLUMN IF NOT EXISTS regle_id INTEGER REFERENCES regles_tampons(id);

CREATE INDEX IF NOT EXISTS idx_codes_code    ON codes_validation(code);
CREATE INDEX IF NOT EXISTS idx_codes_expire  ON codes_validation(expire_le);

ALTER TABLE codes_validation ENABLE ROW LEVEL SECURITY;

-- Recréation propre des policies
DROP POLICY IF EXISTS "codes_select" ON codes_validation;
DROP POLICY IF EXISTS "codes_insert" ON codes_validation;
DROP POLICY IF EXISTS "codes_update" ON codes_validation;

-- Client (anon) : créer et lire les codes
CREATE POLICY "codes_select" ON codes_validation FOR SELECT TO anon        USING (TRUE);
CREATE POLICY "codes_insert" ON codes_validation FOR INSERT TO anon        WITH CHECK (TRUE);
-- Admin (authenticated) : marquer comme utilisé
CREATE POLICY "codes_update" ON codes_validation FOR UPDATE TO authenticated USING (TRUE);

-- Nettoyage automatique des codes expirés (optionnel)
-- Activer dans Supabase > Database > Extensions : pg_cron
-- SELECT cron.schedule('cleanup-codes', '*/10 * * * *',
--   'DELETE FROM codes_validation WHERE expire_le < NOW() - INTERVAL ''1 hour''');

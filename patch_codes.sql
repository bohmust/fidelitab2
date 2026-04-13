-- ============================================================
-- FidéliTab — Patch codes de validation par vente
-- À exécuter dans Supabase > SQL Editor après schema.sql
-- ============================================================

CREATE TABLE IF NOT EXISTS codes_validation (
  id          UUID        DEFAULT gen_random_uuid() PRIMARY KEY,
  code        TEXT        NOT NULL,
  expire_le   TIMESTAMPTZ NOT NULL,
  utilise     BOOLEAN     DEFAULT FALSE,
  utilise_le  TIMESTAMPTZ,
  membre_id   UUID        REFERENCES membres(id),
  cree_le     TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_codes_code    ON codes_validation(code);
CREATE INDEX IF NOT EXISTS idx_codes_expire  ON codes_validation(expire_le);

ALTER TABLE codes_validation ENABLE ROW LEVEL SECURITY;

CREATE POLICY "codes_select" ON codes_validation FOR SELECT TO anon USING (TRUE);
CREATE POLICY "codes_insert" ON codes_validation FOR INSERT TO anon WITH CHECK (TRUE);
CREATE POLICY "codes_update" ON codes_validation FOR UPDATE TO anon USING (TRUE);

-- Nettoyage automatique des codes expirés (optionnel)
-- À activer dans Supabase > Database > Extensions : pg_cron
-- SELECT cron.schedule('cleanup-codes', '*/10 * * * *',
--   'DELETE FROM codes_validation WHERE expire_le < NOW() - INTERVAL ''1 hour''');

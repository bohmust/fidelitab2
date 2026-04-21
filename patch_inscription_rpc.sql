-- ============================================================
-- FidéliTab — Fonction RPC sécurisée pour l'inscription client
-- À exécuter dans Supabase > SQL Editor
-- Contourne les politiques RLS en utilisant SECURITY DEFINER
-- ============================================================

CREATE OR REPLACE FUNCTION inscrire_membre(
  p_nom             TEXT,
  p_telephone       TEXT,
  p_email           TEXT,
  p_date_naissance  DATE,
  p_rgpd_accepte_le TIMESTAMPTZ
) RETURNS membres LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v membres;
BEGIN
  INSERT INTO membres(nom, telephone, email, date_naissance, rgpd_accepte_le, points, visites)
  VALUES(p_nom, p_telephone, p_email, p_date_naissance, p_rgpd_accepte_le, 0, 0)
  RETURNING * INTO v;
  RETURN v;
END;
$$;

GRANT EXECUTE ON FUNCTION inscrire_membre TO anon;

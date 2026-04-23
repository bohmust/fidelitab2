-- ============================================================
-- FidéliTab — Patch policies SELECT pour le rôle authenticated
-- À exécuter dans Supabase > SQL Editor
-- Corrige : points non mis à jour après validation code client
-- ============================================================

-- membres : l'admin (authenticated) peut lire tous les membres
DROP POLICY IF EXISTS "membres_select_auth" ON membres;
CREATE POLICY "membres_select_auth" ON membres
  FOR SELECT TO authenticated USING (TRUE);

-- cartes_tampons : l'admin peut lire les compteurs de tampons
DROP POLICY IF EXISTS "cartes_select_auth" ON cartes_tampons;
CREATE POLICY "cartes_select_auth" ON cartes_tampons
  FOR SELECT TO authenticated USING (TRUE);

-- transactions : déjà TO authenticated dans schema.sql, mais au cas où
DROP POLICY IF EXISTS "transactions_select" ON transactions;
CREATE POLICY "transactions_select" ON transactions
  FOR SELECT TO authenticated USING (TRUE);

-- Grants explicites (au cas où les GRANT manquent)
GRANT SELECT ON membres          TO authenticated;
GRANT SELECT, INSERT, UPDATE ON cartes_tampons TO authenticated;
GRANT SELECT, INSERT ON transactions TO authenticated;

-- ============================================================
-- FidéliTab — Reset des politiques RLS sur la table membres
-- À exécuter dans Supabase > SQL Editor si l'inscription client
-- retourne une erreur d'accès refusé.
-- ============================================================

-- Suppression de toutes les politiques existantes sur membres
-- (évite les conflits si schema.sql a été ré-exécuté)
DROP POLICY IF EXISTS "membres_select"           ON membres;
DROP POLICY IF EXISTS "membres_insert"           ON membres;
DROP POLICY IF EXISTS "membres_update"           ON membres;
DROP POLICY IF EXISTS "membres_delete"           ON membres;
DROP POLICY IF EXISTS "membres_select_anon"      ON membres;
DROP POLICY IF EXISTS "membres_insert_anon"      ON membres;
DROP POLICY IF EXISTS "membres_update_auth"      ON membres;

-- Recréation correcte
-- Lecture : tout le monde (clients et admin)
CREATE POLICY "membres_select" ON membres
  FOR SELECT USING (TRUE);

-- Inscription : clients non connectés (anon)
CREATE POLICY "membres_insert" ON membres
  FOR INSERT TO anon
  WITH CHECK (TRUE);

-- Modification : admin connecté seulement
CREATE POLICY "membres_update" ON membres
  FOR UPDATE TO authenticated
  USING (TRUE)
  WITH CHECK (TRUE);

# FidéliTab — Guide de déploiement

## Fichiers du projet

| Fichier            | Description                                      |
|--------------------|--------------------------------------------------|
| `index.html`       | Page client (téléphone du client, QR codes)      |
| `adminex.html`     | Panneau d'administration (écran en caisse)       |
| `qr-produits.html` | Générateur de QR codes produits (à imprimer)     |
| `schema.sql`       | Structure de la base de données Supabase         |

---

## ÉTAPE 1 — Supabase (base de données)

1. Connectez-vous sur **supabase.com** avec votre compte existant
2. Ouvrez votre projet FidéliTab (ou créez-en un nouveau)
3. Allez dans **SQL Editor** → **New query**
4. Copiez-collez tout le contenu de `schema.sql`
5. Cliquez **Run**

Récupérez vos clés dans **Settings → API** :
- `Project URL`  → c'est votre `SUPABASE_URL`
- `anon / public` key → c'est votre `SUPABASE_KEY`

---

## ÉTAPE 2 — Déployer sur GitHub Pages

Le site est hébergé sur GitHub Pages à l'adresse :
`https://bohmust.github.io/fidelitab2`

- `index.html` est la page client (racine du site)
- `adminex.html` est accessible à `…/adminex.html`
- `qr-produits.html` est accessible à `…/qr-produits.html`

---

## ÉTAPE 3 — Générer et imprimer les QR codes produits

1. Ouvrez `qr-produits.html` dans votre navigateur
2. Les QR codes sont générés automatiquement depuis vos produits Supabase
3. Cliquez **🖨️ Imprimer** pour les imprimer
4. Placez chaque QR code à côté du produit correspondant en caisse

Quand un client scanne un QR code, il arrive directement sur `index.html` avec le bon produit présélectionné.

---

## ÉTAPE 4 — Tester

1. Ouvrez `index.html` sur votre téléphone
2. Entrez un numéro fictif → vous devez voir le formulaire d'inscription
3. Inscrivez-vous → vérifiez dans **Supabase → Table Editor → membres**
4. Ajoutez un tampon → vérifiez dans **cartes_tampons** et **transactions**

---

## Structure de la base de données

### Table `membres`
| Colonne           | Type        | Description                        |
|-------------------|-------------|------------------------------------|
| id                | UUID        | Identifiant unique                 |
| nom               | TEXT        | Prénom + Nom en majuscules         |
| telephone         | TEXT        | Numéro unique (identifiant client) |
| email             | TEXT        | Optionnel                          |
| date_naissance    | DATE        | Optionnel — pour bonus anniversaire|
| points            | INTEGER     | Total de points accumulés          |
| visites           | INTEGER     | Nombre de visites enregistrées     |
| rgpd_accepte_le   | TIMESTAMPTZ | Date d'acceptation RGPD            |

### Table `regles_tampons`
Configurable depuis l'admin. Contient les produits (Tabac, Café, Presse, E-cig…).

### Table `cartes_tampons`
Un enregistrement par client par produit. Colonne `compteur` = tampons en cours.

### Table `transactions`
Historique complet de toutes les opérations (tampons, récompenses, points).

### Table `codes_validation`
Codes à 4 chiffres générés par le client, validés par l'admin en caisse.

---

## Dépannage

**"Erreur réseau"** → Vérifiez que SUPABASE_URL et SUPABASE_KEY sont corrects

**"Numéro non trouvé" alors que le client est inscrit** → Vérifiez le format du numéro dans la base (sans espaces, 10 chiffres)

**Les tampons ne s'enregistrent pas** → Vérifiez que les politiques RLS sont bien créées (relancez la partie ÉTAPE 7 du schema.sql)

---

## Prochaines évolutions possibles

- [ ] Envoi d'un email récapitulatif mensuel des points (Supabase Edge Functions)
- [ ] Notification anniversaire automatique
- [ ] Export CSV de la liste membres depuis l'admin
- [ ] Statistiques par produit (quel tampon est le plus utilisé ?)
- [ ] Application mobile native (PWA)

# FidéliTab — Guide de déploiement

## Ce que vous allez déployer

| Fichier        | Description                                      | Où             |
|----------------|--------------------------------------------------|----------------|
| `schema.sql`   | Structure de la base de données                  | Supabase       |
| `client.html`  | Page client (téléphone du client)                | Netlify        |
| `admin.html`   | Panneau d'administration (votre écran en caisse) | Netlify        |

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

## ÉTAPE 2 — Configurer client.html

Ouvrez `client.html` dans un éditeur de texte (Notepad++, VSCode...).

Trouvez ces deux lignes et remplacez par vos valeurs :

```js
const SUPABASE_URL  = 'https://VOTRE_PROJECT_ID.supabase.co';
const SUPABASE_KEY  = 'VOTRE_ANON_KEY';
```

Personnalisez aussi le nom de votre boutique :

```js
const SHOP = { name: 'Tabac Presse Grandclément', addr: 'Place Grandclément, Villeurbanne' };
```

---

## ÉTAPE 3 — Déployer sur Netlify

1. Allez sur **netlify.com** → **Add new site** → **Deploy manually**
2. Glissez-déposez le dossier contenant `client.html`
3. Netlify vous donne une URL du type : `https://fidelitab-client.netlify.app`

> 💡 Vous pouvez configurer un domaine personnalisé dans les paramètres Netlify

---

## ÉTAPE 4 — Créer le QR code à afficher en caisse

1. Allez sur **qr-code-generator.com** (ou équivalent gratuit)
2. Entrez l'URL de votre page Netlify : `https://fidelitab-client.netlify.app`
3. Téléchargez le QR code en haute résolution
4. Imprimez-le et placez-le sur le comptoir

Quand un client scanne ce QR code, il arrive directement sur la page client.

---

## ÉTAPE 5 — Tester

1. Ouvrez `client.html` sur votre téléphone (ou via l'URL Netlify)
2. Entrez un numéro fictif → vous devez voir le formulaire d'inscription
3. Inscrivez-vous → vérifiez dans **Supabase → Table Editor → membres** que la ligne apparaît
4. Ajoutez un tampon → vérifiez dans **cartes_tampons** et **transactions**

---

## Structure de la base de données

### Table `membres`
| Colonne           | Type    | Description                        |
|-------------------|---------|------------------------------------|
| id                | UUID    | Identifiant unique                 |
| nom               | TEXT    | Prénom + Nom en majuscules         |
| telephone         | TEXT    | Numéro unique (identifiant client) |
| email             | TEXT    | Optionnel                          |
| date_naissance    | DATE    | Optionnel — pour bonus anniversaire|
| points            | INTEGER | Total de points accumulés          |
| visites           | INTEGER | Nombre de visites enregistrées     |
| rgpd_accepte_le   | TIMESTAMPTZ | Date d'acceptation RGPD       |

### Table `regles_tampons`
Configurable depuis l'admin. Contient les 4 produits (Tabac, Café, Presse, E-cig).

### Table `cartes_tampons`
Un enregistrement par client par produit. Colonne `compteur` = tampons en cours.

### Table `transactions`
Historique complet de toutes les opérations (tampons, récompenses, points).

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

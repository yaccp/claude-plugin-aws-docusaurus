---
name: aws-docusaurus
autoContext: always
---

# AWS Docusaurus

Deploy and manage static sites on AWS infrastructure (S3, CloudFront, ACM, Route53).

## Configuration

All configuration is stored in `.claude/yaccp/aws-docusaurus/config.json`.

## Workflow

### Step 1: Load State

Read existing configuration:
```bash
cat .claude/yaccp/aws-docusaurus/config.json 2>/dev/null
```

Determine current state:
- **NO_CONFIG**: No config file → First time setup
- **NO_ENVIRONMENT**: Config exists but no environments → Need environment setup
- **NO_INFRA**: Environment exists but no S3/CloudFront → Need infrastructure
- **READY**: Full configuration → Show main menu

### Step 2: Display Status Banner

```
╔═══════════════════════════════════════════════════════════╗
║              AWS Docusaurus                               ║
╠═══════════════════════════════════════════════════════════╣
║  Deploy static sites to AWS with S3, CloudFront & SSL     ║
╚═══════════════════════════════════════════════════════════╝

Environment:  ${CURRENT_ENV} (${ENV_NAME})
AWS Profile:  ${AWS_PROFILE}
Domain:       ${DOMAIN:-"Not configured"}
Status:       ${STATUS}
```

### Step 3: Route Based on State

---

## State: NO_CONFIG (First Time)

Use AskUserQuestion:
```
question: "Bienvenue! C'est votre première utilisation. Que souhaitez-vous faire?"
options:
  - label: "Créer un nouveau projet Docusaurus"
    description: "Initialiser un nouveau site Docusaurus pré-configuré pour AWS"
  - label: "Configurer un projet existant"
    description: "J'ai déjà un projet statique à déployer"
```

### Si "Créer un nouveau projet Docusaurus":

Use AskUserQuestion:
```
question: "Quel nom pour votre projet?"
options: [text input]
```

Use AskUserQuestion:
```
question: "Titre du site?"
options: [text input]
```

Use AskUserQuestion:
```
question: "URL de production? (ex: docs.example.com)"
options: [text input]
```

Use AskUserQuestion:
```
question: "Langue du site?"
options:
  - label: "Français"
    description: "fr"
  - label: "English"
    description: "en"
```

Exécuter:
```bash
npx create-docusaurus@latest ${PROJECT_NAME} classic --typescript
cd ${PROJECT_NAME}
npm install
```

Configurer `docusaurus.config.ts` avec les valeurs collectées.

Sauvegarder dans config.json:
```bash
mkdir -p .claude/yaccp/aws-docusaurus
```

→ Retour au menu principal (état devient NO_ENVIRONMENT)

### Si "Configurer un projet existant":

Détecter le framework:
```bash
ls package.json docusaurus.config.* next.config.* vite.config.* astro.config.* 2>/dev/null
```

Use AskUserQuestion:
```
question: "Quel framework utilisez-vous?"
options:
  - label: "Docusaurus"
    description: "BUILD_COMMAND=npm run build, BUILD_DIR=build"
  - label: "Next.js (Static Export)"
    description: "BUILD_COMMAND=npm run build, BUILD_DIR=out"
  - label: "Astro"
    description: "BUILD_COMMAND=npm run build, BUILD_DIR=dist"
  - label: "Vite / Vue / React"
    description: "BUILD_COMMAND=npm run build, BUILD_DIR=dist"
  - label: "Hugo"
    description: "BUILD_COMMAND=hugo --minify, BUILD_DIR=public"
  - label: "Autre"
    description: "Je vais spécifier manuellement"
```

Si "Autre":
- Demander BUILD_COMMAND
- Demander BUILD_DIR

Sauvegarder la configuration.

→ Retour au menu principal

---

## State: NO_ENVIRONMENT

Use AskUserQuestion:
```
question: "Configurons votre environnement AWS. Quel type d'environnement?"
options:
  - label: "dev (Développement)"
    description: "Pour les tests et le développement"
  - label: "staging (Pré-production)"
    description: "Pour la validation avant production"
  - label: "prod (Production)"
    description: "Environnement de production"
  - label: "Autre"
    description: "Nom personnalisé"
```

Use AskUserQuestion:
```
question: "Quel profil AWS utiliser?"
options: [Lister les profils depuis ~/.aws/credentials]
```

Use AskUserQuestion:
```
question: "Quelle région AWS?"
options:
  - label: "eu-west-1 (Irlande)"
    description: "Recommandé pour l'Europe"
  - label: "eu-west-3 (Paris)"
    description: "France"
  - label: "us-east-1 (Virginie)"
    description: "Recommandé pour l'Amérique du Nord"
  - label: "ap-northeast-1 (Tokyo)"
    description: "Asie-Pacifique"
```

Use AskUserQuestion:
```
question: "Domaine personnalisé? (ex: docs.example.com)"
options: [text input]
```

Use AskUserQuestion:
```
question: "ID de la zone Route53 hébergée?"
options: [text input, avec hint: aws route53 list-hosted-zones]
```

Valider les credentials AWS:
```bash
aws sts get-caller-identity --profile ${AWS_PROFILE}
```

Sauvegarder l'environnement dans config.json.

→ Retour au menu principal (état devient NO_INFRA)

---

## State: NO_INFRA

Use AskUserQuestion:
```
question: "Environnement '${ENV_NAME}' configuré! L'infrastructure AWS n'existe pas encore. Que faire?"
options:
  - label: "Créer l'infrastructure AWS"
    description: "Provisionner S3, CloudFront, certificat SSL, DNS"
  - label: "Modifier la configuration"
    description: "Changer le profil AWS, la région ou le domaine"
  - label: "Lancer le serveur local"
    description: "Développer en local avant de déployer"
```

### Si "Créer l'infrastructure AWS":

Use AskUserQuestion:
```
question: "Activer l'authentification Basic Auth?"
options:
  - label: "Non"
    description: "Site public"
  - label: "Oui"
    description: "Protéger avec login/mot de passe (Lambda@Edge)"
```

Si Basic Auth activé:
- Demander username
- Demander password (min 8 caractères, NE PAS sauvegarder)

Afficher le résumé:
```
Infrastructure à créer
======================
• S3 Bucket:           ${SITE_NAME}
• CloudFront CDN:      Distribution avec HTTPS
• Certificat SSL:      ${DOMAIN} (ACM us-east-1)
• DNS:                 Route53 alias vers CloudFront
• Basic Auth:          ${AUTH_ENABLED}

Coût estimé: ~$1-5/mois (selon trafic)
```

Use AskUserQuestion:
```
question: "Créer cette infrastructure?"
options:
  - label: "Oui, créer"
    description: "Cela peut prendre 5-15 minutes"
  - label: "Non, annuler"
    description: "Retour au menu"
```

Exécuter la création:
1. Créer S3 bucket (privé)
2. Demander certificat ACM (us-east-1)
3. Attendre validation du certificat
4. Créer CloudFront OAI
5. Configurer la policy S3
6. Créer Lambda@Edge (si auth)
7. Créer distribution CloudFront
8. Créer alias Route53

Sauvegarder les IDs des ressources dans config.json.

→ Retour au menu principal (état devient READY)

---

## State: READY (Menu Principal)

Use AskUserQuestion:
```
question: "Environnement: ${ENV_NAME} | Domaine: ${DOMAIN}\nQue souhaitez-vous faire?"
options:
  - label: "🚀 Déployer le site"
    description: "Builder et déployer vers ${DOMAIN}"
  - label: "📊 Voir le statut"
    description: "État de l'infrastructure et du site"
  - label: "🔄 Changer d'environnement"
    description: "Passer à dev/staging/prod"
  - label: "💻 Serveur local"
    description: "Démarrer/arrêter le serveur de développement"
  - label: "⚙️ Configuration"
    description: "Modifier les paramètres"
  - label: "🗑️ Détruire l'infrastructure"
    description: "Supprimer toutes les ressources AWS"
  - label: "🔧 Diagnostiquer"
    description: "Vérifier la configuration et résoudre les problèmes"
```

---

### Action: Déployer le site

Détecter le framework et les paramètres de build.

Afficher le résumé:
```
Déploiement vers ${ENV_NAME}
============================
Framework:     ${FRAMEWORK}
Build:         ${BUILD_COMMAND}
Output:        ${BUILD_DIR}
Destination:   s3://${S3_BUCKET}
CloudFront:    ${CLOUDFRONT_DISTRIBUTION_ID}
```

Use AskUserQuestion:
```
question: "Lancer le déploiement?"
options:
  - label: "Oui, déployer"
    description: "Builder et uploader"
  - label: "Non, annuler"
    description: "Retour au menu"
```

Exécuter:
```bash
# Build
${BUILD_COMMAND}

# Upload assets (cache 1 an)
aws s3 sync ${BUILD_DIR}/ s3://${S3_BUCKET}/ \
  --delete \
  --cache-control "public, max-age=31536000, immutable" \
  --exclude "*.html" --exclude "*.json" --exclude "sw.js" \
  --profile ${AWS_PROFILE}

# Upload HTML (pas de cache)
aws s3 sync ${BUILD_DIR}/ s3://${S3_BUCKET}/ \
  --exclude "*" --include "*.html" --include "*.json" \
  --cache-control "public, max-age=0, must-revalidate" \
  --profile ${AWS_PROFILE}

# Invalider CloudFront
aws cloudfront create-invalidation \
  --distribution-id ${CLOUDFRONT_DISTRIBUTION_ID} \
  --paths "/*" \
  --profile ${AWS_PROFILE}
```

```
✅ Déploiement réussi!
Site en ligne: https://${DOMAIN}
```

→ Retour au menu principal

---

### Action: Voir le statut

Exécuter les vérifications:
```bash
# CloudFront
aws cloudfront get-distribution --id ${CLOUDFRONT_DISTRIBUTION_ID} --profile ${AWS_PROFILE}

# S3
aws s3 ls s3://${S3_BUCKET}/ --recursive --summarize --profile ${AWS_PROFILE}

# Certificat
aws acm describe-certificate --certificate-arn ${CERT_ARN} --region us-east-1 --profile ${AWS_PROFILE}

# Site health
curl -sI https://${DOMAIN} | head -1
```

Afficher:
```
Statut de ${ENV_NAME}
=====================

CloudFront: ${CLOUDFRONT_DISTRIBUTION_ID}
├── Status:  Deployed ✓
├── Enabled: true
└── Domain:  ${CF_DOMAIN}

S3 Bucket: ${S3_BUCKET}
├── Objets: ${OBJECT_COUNT}
└── Taille: ${BUCKET_SIZE}

Certificat SSL:
├── Status:  ISSUED ✓
└── Expire:  ${CERT_EXPIRY}

Site: https://${DOMAIN}
├── HTTP:    200 OK ✓
└── TTFB:    ${TTFB}ms
```

→ Retour au menu principal

---

### Action: Changer d'environnement

Lister les environnements disponibles depuis config.json.

Use AskUserQuestion:
```
question: "Quel environnement utiliser?"
options: [Liste dynamique des environnements avec (actuel) marqué]
  - label: "dev (actuel)"
    description: "dev.example.com"
  - label: "staging"
    description: "staging.example.com"
  - label: "prod"
    description: "example.com"
  - label: "Créer un nouvel environnement"
    description: "Ajouter dev/staging/prod"
```

Si "Créer un nouvel environnement":
→ Aller à l'état NO_ENVIRONMENT

Sinon, mettre à jour `currentEnvironment` dans config.json.

```
✅ Environnement changé: ${NEW_ENV}
```

→ Retour au menu principal

---

### Action: Serveur local

Use AskUserQuestion:
```
question: "Gestion du serveur local"
options:
  - label: "Démarrer le serveur"
    description: "npm start sur le port 3000"
  - label: "Arrêter le serveur"
    description: "Stopper le serveur en cours"
  - label: "Voir le statut"
    description: "Vérifier si le serveur tourne"
```

#### Démarrer:
```bash
npm start &
echo $! > .claude/yaccp/aws-docusaurus/server.pid
```

```
✅ Serveur démarré sur http://localhost:3000
PID: ${PID}
```

#### Arrêter:
```bash
kill $(cat .claude/yaccp/aws-docusaurus/server.pid)
rm .claude/yaccp/aws-docusaurus/server.pid
```

#### Statut:
```bash
if [ -f .claude/yaccp/aws-docusaurus/server.pid ]; then
  ps -p $(cat .claude/yaccp/aws-docusaurus/server.pid)
fi
```

→ Retour au menu principal

---

### Action: Configuration

Use AskUserQuestion:
```
question: "Que souhaitez-vous configurer?"
options:
  - label: "Paramètres de build"
    description: "Commande de build, répertoire de sortie"
  - label: "Modifier l'environnement actuel"
    description: "Changer profil AWS, région, domaine"
  - label: "Supprimer un environnement"
    description: "Retirer un environnement de la config"
  - label: "Voir la configuration complète"
    description: "Afficher config.json"
```

#### Paramètres de build:

Use AskUserQuestion:
```
question: "Commande de build? (actuel: ${BUILD_COMMAND})"
options: [text input avec valeur par défaut]
```

Use AskUserQuestion:
```
question: "Répertoire de sortie? (actuel: ${BUILD_DIR})"
options:
  - label: "build (Docusaurus)"
  - label: "dist (Vite/Astro)"
  - label: "out (Next.js)"
  - label: "public (Hugo)"
  - label: "Autre"
```

#### Supprimer un environnement:

Use AskUserQuestion:
```
question: "Quel environnement supprimer?"
options: [Liste des environnements sauf current]
```

Si c'est prod:
```
⚠️ ATTENTION: Vous allez supprimer la configuration de PRODUCTION.
L'infrastructure AWS ne sera PAS supprimée, seulement la configuration locale.
```

Use AskUserQuestion:
```
question: "Confirmer la suppression?"
options:
  - label: "Oui, supprimer"
  - label: "Non, annuler"
```

→ Retour au menu principal

---

### Action: Détruire l'infrastructure

Use AskUserQuestion:
```
question: "⚠️ ATTENTION: Cette action va SUPPRIMER DÉFINITIVEMENT:\n• S3 Bucket et tous les fichiers\n• Distribution CloudFront\n• Certificat SSL\n• Enregistrement DNS\n\nContinuer?"
options:
  - label: "Non, annuler"
    description: "Retour au menu"
  - label: "Oui, je comprends les risques"
    description: "Continuer vers la destruction"
```

Si prod:
```
🚨 PRODUCTION: Cela causera une indisponibilité du site!
```

Use AskUserQuestion:
```
question: "Tapez 'DESTROY' pour confirmer la destruction"
options: [text input, validation: doit être exactement "DESTROY"]
```

Exécuter la destruction (dans l'ordre):
1. Supprimer l'enregistrement Route53
2. Désactiver CloudFront
3. Attendre (10-15 min)
4. Supprimer CloudFront
5. Supprimer OAI
6. Vider et supprimer S3
7. Supprimer Lambda@Edge (si existe)
8. Supprimer certificat ACM

Mettre à jour config.json pour marquer comme détruit.

```
✅ Infrastructure détruite

Ressources supprimées:
• Route53: ${DOMAIN}
• CloudFront: ${CLOUDFRONT_ID}
• S3: ${S3_BUCKET}
• ACM Certificate

La configuration locale reste pour recréer si besoin.
```

→ Retour au menu principal (état devient NO_INFRA)

---

### Action: Diagnostiquer

Exécuter les vérifications:

```
AWS Docusaurus - Diagnostic
===========================

Prérequis:
├── aws CLI:    ✓ v${AWS_VERSION}
├── node:       ✓ v${NODE_VERSION}
└── npm:        ✓ v${NPM_VERSION}

AWS:
├── Profile:    ${AWS_PROFILE}
├── Région:     ${AWS_REGION}
├── Identité:   ${AWS_IDENTITY}
└── Credentials: ${CRED_STATUS}

Configuration:
├── Fichier:    ${CONFIG_STATUS}
├── Environnements: ${ENV_COUNT}
└── Actuel:     ${CURRENT_ENV}

Infrastructure:
├── S3:         ${S3_STATUS}
├── CloudFront: ${CF_STATUS}
├── SSL:        ${SSL_STATUS}
└── DNS:        ${DNS_STATUS}
```

Si des problèmes sont détectés:
```
Problèmes détectés:
• ${ISSUE_1}
  → Solution: ${SOLUTION_1}
• ${ISSUE_2}
  → Solution: ${SOLUTION_2}
```

Use AskUserQuestion:
```
question: "Que faire ensuite?"
options:
  - label: "Créer un ticket GitHub"
    description: "Signaler un problème avec les infos de diagnostic"
  - label: "Retour au menu"
    description: "J'ai compris le problème"
```

Si "Créer un ticket GitHub":
Ouvrir: https://github.com/yaccp/claude-plugin-aws-docusaurus/issues/new
Pré-remplir avec les infos de diagnostic (sans données sensibles).

→ Retour au menu principal

---

## Boucle de Fin

Après chaque action, toujours proposer:

Use AskUserQuestion:
```
question: "Action terminée. Que faire?"
options:
  - label: "Retour au menu principal"
    description: "Continuer à utiliser le plugin"
  - label: "Quitter"
    description: "Fin de session"
```

---

## Override d'Environnement

L'utilisateur peut forcer un environnement avec:
```bash
export PLUGIN_ENV=staging
```

Cela override `currentEnvironment` pour la session.

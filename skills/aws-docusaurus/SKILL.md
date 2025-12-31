---
name: aws-docusaurus
autoContext: always
---

# Aws Docusaurus

Deploy and manage static sites on AWS infrastructure (S3, CloudFront, ACM, Route53).

## IMPORTANT: Environment Discovery

**ALWAYS start by reading the configuration:**

```bash
cat .claude/yaccp/aws-docusaurus/config.json 2>/dev/null || echo '{}'
```

This determines the current state and available options.

## Naming Conventions

### S3 Bucket Naming (OBLIGATOIRE)

Les buckets S3 **doivent** suivre cette convention :
```
${SITE_NAME}-${AWS_ACCOUNT_ID}-${AWS_REGION}
```

Exemple : `my-docs-123456789012-eu-west-3`

```bash
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
S3_BUCKET="${SITE_NAME}-${AWS_ACCOUNT_ID}-${AWS_REGION}"
```

### ACM Certificate Reuse (RECOMMANDÉ)

**Avant de créer un nouveau certificat**, vérifier les certificats existants :

```bash
# Lister les certificats dans us-east-1 (requis pour CloudFront)
aws acm list-certificates --region us-east-1 --output table

# Chercher un wildcard pour le domaine parent
PARENT_DOMAIN=$(echo $DOMAIN | sed 's/^[^.]*\.//')
aws acm list-certificates --region us-east-1 \
  --query "CertificateSummaryList[?DomainName=='*.${PARENT_DOMAIN}'].CertificateArn" \
  --output text
```

**Règles :**
- `*.example.com` couvre tous les sous-domaines
- Réutiliser évite les limites ACM (2500 certs/compte)
- Proposer à l'utilisateur le choix : réutiliser ou créer

## State Machine

Based on config.json content:

| State | Condition | Action |
|-------|-----------|--------|
| `NO_CONFIG` | File missing or empty | → First time setup |
| `CONFIGURED` | Valid config exists | → Show main menu |

## State: NO_CONFIG

Use AskUserQuestion:
- **"Commencer la configuration"** → Collect required parameters
- **"Voir la documentation"** → Show plugin help

### Configuration Steps

1. Collecter `SITE_NAME`, `DOMAIN`, `AWS_REGION`
2. Récupérer `AWS_ACCOUNT_ID` automatiquement
3. Construire `S3_BUCKET` avec la convention
4. **Vérifier les certificats ACM existants**
5. Proposer réutilisation ou création

After configuration, save to:
```bash
mkdir -p .claude/yaccp/aws-docusaurus
# Write config.json with collected parameters
```

## State: CONFIGURED

Use AskUserQuestion:
- **"▶️ Exécuter"** → Run main action
- **"⚙️ Configuration"** → Modify settings
- **"📊 Statut"** → Show current state
- **"❓ Aide"** → Documentation

## After Each Action

Always offer:
- **"Retour au menu"** → Back to main menu
- **"Quitter"** → End session

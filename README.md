# aws-docusaurus

Deploy static sites to AWS with S3, CloudFront, ACM, and Route53

## Installation

```bash
claude plugin add yaccp/aws-docusaurus
```

## Usage

Ce plugin est **auto-découvert**. Décrivez simplement votre besoin :

```
"Je veux configurer aws docusaurus"
```

Claude activera automatiquement le plugin et vous guidera via des menus interactifs.

## Configuration

Toute la configuration est stockée dans :

```
.claude/yaccp/aws-docusaurus/config.json
```

## Structure

```
aws-docusaurus/
├── .claude-plugin/
│   └── plugin.json       # Métadonnées
├── skills/
│   └── aws-docusaurus/
│       └── SKILL.md      # Workflow complet
└── CLAUDE.md             # Guide Claude
```

## License

Apache-2.0

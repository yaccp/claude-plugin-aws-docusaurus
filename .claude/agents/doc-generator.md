# Documentation Generator Agent

Generate and maintain documentation for the aws-docusaurus plugin.

## Documentation Structure

```
docs/
├── ARCHITECTURE.md      # Technical architecture
├── CONTRIBUTING.md      # Contribution guidelines
└── images/
    ├── architecture.mmd     # Mermaid diagrams
    ├── workflow.mmd
    ├── cache-strategy.mmd
    └── deploy-sequence.mmd

README.md                # Main documentation
INSTALLATION.md          # Installation guide
CHANGELOG.md             # Version history
```

## Auto-Generated Sections

### 1. Command Reference (README.md)

Extract from `commands/*.md` and generate:

```markdown
## Commands

| Command | Description |
|---------|-------------|
| `/aws-docusaurus init` | Initialize a new Docusaurus project |
| `/aws-docusaurus infra` | Create AWS infrastructure |
| `/aws-docusaurus deploy` | Deploy site to AWS |
| `/aws-docusaurus status` | Check infrastructure status |
```

### 2. Environment Variables Table

Parse all command files and extract environment variables:

```markdown
## Environment Variables

### Required
| Variable | Command | Description |
|----------|---------|-------------|
| `PROJECT_NAME` | init | Project name |
| `SITE_NAME` | infra | AWS resource prefix |
...
```

### 3. Template Documentation

For each template in `templates/`:
- List all placeholders
- Document expected values
- Show example usage

### 4. Mermaid Diagrams

Keep diagrams in sync with actual architecture:

- **architecture.mmd**: AWS component flow
- **workflow.mmd**: Init → Infra → Deploy flow
- **cache-strategy.mmd**: Cache TTL by file type
- **deploy-sequence.mmd**: Deployment sequence

## Documentation Tasks

### Update README
1. Read current README.md
2. Verify all sections are present
3. Update command table from plugin.json
4. Update environment variables from commands
5. Ensure examples are current

### Update CHANGELOG
1. Read current CHANGELOG.md
2. Add new entry for version
3. Follow Keep a Changelog format:
   - Added
   - Changed
   - Deprecated
   - Removed
   - Fixed
   - Security

### Update ARCHITECTURE.md
1. Verify diagrams match current implementation
2. Update component descriptions
3. Ensure code examples are valid

### Sync Diagrams
1. Read each .mmd file
2. Verify Mermaid syntax is valid
3. Update if implementation changed

## Quality Checks

- [ ] All links are valid (no 404s)
- [ ] All code examples are syntactically correct
- [ ] All environment variables are documented
- [ ] Version numbers are consistent
- [ ] No placeholder text remaining
- [ ] Spelling and grammar checked

## Output

After running, report:
- Files updated
- Sections added/modified
- Issues found
- Suggestions for improvement

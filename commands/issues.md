---
description: Create a GitHub issue for this plugin
---

# AWS Docusaurus: Create GitHub Issue

Guide the user through creating a GitHub issue for this plugin.

## Interactive Flow

### Step 1: Choose Issue Type

Use AskUserQuestion:
"What type of issue would you like to create?"
- "Bug Report"
- "Feature Request"
- "Question"
- "Documentation"

### Step 2: Gather Information Based on Type

#### For Bug Report:

```
? Describe the bug (what happened):
[Text input]

? Expected behavior (what should happen):
[Text input]

? Steps to reproduce:
[Text input]

? Which command were you using?
○ /yaccp-aws-docusaurus:init
○ /yaccp-aws-docusaurus:infra
○ /yaccp-aws-docusaurus:deploy
○ /yaccp-aws-docusaurus:status
○ /yaccp-aws-docusaurus:destroy-infra
○ Other

? AWS Region:
[Text input, default: eu-west-3]

? Any error messages?
[Text input]
```

#### For Feature Request:

```
? Describe the feature you'd like:
[Text input]

? Why would this be useful?
[Text input]

? Any alternatives you've considered?
[Text input]
```

#### For Question:

```
? What's your question?
[Text input]

? What have you already tried?
[Text input]
```

#### For Documentation:

```
? What documentation needs improvement?
[Text input]

? What would you like to see added or changed?
[Text input]
```

### Step 3: Display Issue Preview

```
Issue Preview
=============

Title: [Bug] Error during CloudFront creation
Labels: bug

---

## Description
CloudFront distribution fails to create with access denied error.

## Expected Behavior
CloudFront should be created successfully.

## Steps to Reproduce
1. Run /yaccp-aws-docusaurus:infra
2. Enter domain: docs.example.com
3. Wait for CloudFront creation

## Environment
- Command: /yaccp-aws-docusaurus:infra
- AWS Region: eu-west-3
- Plugin Version: 1.1.8

## Error Messages
AccessDenied: User is not authorized to perform cloudfront:CreateDistribution

---

Create this issue?
```

Use AskUserQuestion:
- "Yes, create issue on GitHub"
- "Edit title"
- "Edit description"
- "Cancel"

### Step 4: Create Issue

If user confirms, use GitHub CLI to create issue:

```bash
gh issue create \
  --repo yaccp/claude-plugin-aws-docusaurus \
  --title "[Bug] Error during CloudFront creation" \
  --body "$(cat <<'EOF'
## Description
CloudFront distribution fails to create with access denied error.

## Expected Behavior
CloudFront should be created successfully.

## Steps to Reproduce
1. Run /yaccp-aws-docusaurus:infra
2. Enter domain: docs.example.com
3. Wait for CloudFront creation

## Environment
- Command: /yaccp-aws-docusaurus:infra
- AWS Region: eu-west-3
- Plugin Version: 1.1.8

## Error Messages
\`\`\`
AccessDenied: User is not authorized to perform cloudfront:CreateDistribution
\`\`\`
EOF
)" \
  --label "bug"
```

### Step 5: Show Result

```
Issue created successfully!

Issue #42: [Bug] Error during CloudFront creation
URL: https://github.com/yaccp/claude-plugin-aws-docusaurus/issues/42

Thank you for your feedback!
```

## Issue Templates

### Bug Report Template
```markdown
## Description
{description}

## Expected Behavior
{expected}

## Steps to Reproduce
{steps}

## Environment
- Command: {command}
- AWS Region: {region}
- Plugin Version: {version}

## Error Messages
```
{error}
```
```

### Feature Request Template
```markdown
## Feature Description
{description}

## Use Case
{why_useful}

## Alternatives Considered
{alternatives}
```

### Question Template
```markdown
## Question
{question}

## What I've Tried
{tried}

## Environment
- Plugin Version: {version}
```

### Documentation Template
```markdown
## Documentation Issue
{what_needs_improvement}

## Suggested Changes
{suggested_changes}
```

## Labels Mapping

| Issue Type | Label |
|------------|-------|
| Bug Report | `bug` |
| Feature Request | `enhancement` |
| Question | `question` |
| Documentation | `documentation` |

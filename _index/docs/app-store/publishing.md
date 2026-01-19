# Publishing

> Source: https://apps.developer.homey.app/app-store/publishing

## Overview

Publishing makes your app available in the Homey App Store for all users to discover and install.

## Publishing Methods

### CLI Publishing

```bash
# Validate first
homey app validate

# Publish
homey app publish
```

### Developer Portal

1. Go to https://developer.athom.com
2. Upload your app package
3. Submit for review

## Validation Levels

| Level | Purpose | Requirements |
|-------|---------|--------------|
| `debug` | Development | Basic structure |
| `publish` | App Store | Full validation |
| `verified` | Verified Developer | Enhanced requirements |

### Debug Validation

```bash
homey app run
```

Basic checks:
- Valid manifest structure
- Required files exist
- Syntax errors

### Publish Validation

```bash
homey app validate --level publish
```

Full checks:
- All debug checks
- Image requirements
- Translation completeness
- Permission justification

## Required Assets

### Images

| Image | Size | Required |
|-------|------|----------|
| Small | 250x175 | Yes |
| Large | 500x350 | Yes |
| XLarge | 1000x700 | Recommended |

Location: `/assets/images/`

```json
{
  "images": {
    "small": "/assets/images/small.png",
    "large": "/assets/images/large.png",
    "xlarge": "/assets/images/xlarge.png"
  }
}
```

### Driver Icons

- Format: SVG
- Location: `/drivers/<id>/assets/icon.svg`
- Single color (will be themed by Homey)

## Manifest Requirements

```json
{
  "id": "com.yourcompany.appname",
  "version": "1.0.0",
  "compatibility": ">=5.0.0",
  "sdk": 3,
  "platforms": ["local"],
  "name": { "en": "App Name" },
  "description": { "en": "Clear description" },
  "category": ["tools"],
  "brandColor": "#3498db",
  "author": {
    "name": "Your Name",
    "email": "you@example.com"
  },
  "support": "mailto:support@example.com"
}
```

## Version Requirements

- Use semantic versioning: `MAJOR.MINOR.PATCH`
- Pre-release versions (`1.0.0-beta`) are **NOT allowed**
- Version must increase with each publish

```bash
# Increment version
homey app version patch  # 1.0.0 → 1.0.1
homey app version minor  # 1.0.0 → 1.1.0
homey app version major  # 1.0.0 → 2.0.0
```

## Review Process

1. **Submit** - App enters review queue
2. **Review** - Homey team reviews your app
3. **Feedback** - May receive feedback for changes
4. **Approved** - App goes live

Review typically takes 1-5 business days.

## GitHub Actions Automation

```yaml
name: Publish Homey App

on:
  release:
    types: [published]

jobs:
  publish:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - uses: actions/setup-node@v3
        with:
          node-version: '22'
      
      - name: Install Homey CLI
        run: npm install -g homey
      
      - name: Validate
        run: homey app validate --level publish
      
      - name: Publish
        env:
          HOMEY_TOKEN: ${{ secrets.HOMEY_TOKEN }}
        run: homey app publish
```

## Best Practices

1. **Test thoroughly** - Test on actual Homey hardware
2. **Write good descriptions** - Clear, concise, helpful
3. **Provide support** - Include valid support email/URL
4. **Update regularly** - Fix bugs, add features
5. **Respond to reviews** - Address user feedback

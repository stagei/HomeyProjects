# App Manifest (app.json)

> Source: https://apps.developer.homey.app/the-basics/app/manifest

## Overview

The `app.json` file is the manifest that defines your app's metadata, capabilities, and configuration.

## Required Properties

```json
{
  "id": "com.example.myapp",
  "version": "1.0.0",
  "compatibility": ">=5.0.0",
  "sdk": 3,
  "platforms": ["local"],
  "name": {
    "en": "My App"
  },
  "description": {
    "en": "A description of what my app does"
  },
  "category": ["tools"],
  "brandColor": "#FF0000"
}
```

## Property Reference

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `id` | string | Yes | Unique app identifier (reverse domain notation) |
| `version` | string | Yes | Semantic version (e.g., "1.0.0") |
| `compatibility` | string | Yes | Minimum Homey version (e.g., ">=5.0.0") |
| `sdk` | number | Yes | SDK version (use `3` for current) |
| `platforms` | array | Yes | `["local"]`, `["cloud"]`, or both |
| `name` | object | Yes | Localized app name |
| `description` | object | Yes | Localized app description |
| `category` | array | Yes | App categories |
| `brandColor` | string | No | Brand color in hex |
| `permissions` | array | No | Required permissions |
| `drivers` | array | No | Device driver definitions |
| `flow` | object | No | Flow card definitions |
| `api` | object | No | Web API endpoints |
| `widgets` | object | No | Widget definitions |

## Categories

Available categories:
- `appliances`, `climate`, `energy`, `lights`, `music`, `security`, `tools`, `video`

## Platforms

```json
// Local only (Homey Pro)
"platforms": ["local"]

// Cloud only (Homey Cloud)
"platforms": ["cloud"]

// Both platforms
"platforms": ["local", "cloud"]
```

## SDK Version

Always use SDK 3 for new apps:

```json
"sdk": 3
```

## Example Complete Manifest

```json
{
  "id": "com.example.myapp",
  "version": "1.0.0",
  "compatibility": ">=5.0.0",
  "sdk": 3,
  "platforms": ["local"],
  "name": {
    "en": "My Smart App",
    "nl": "Mijn Slimme App"
  },
  "description": {
    "en": "Control your smart devices",
    "nl": "Bedien je slimme apparaten"
  },
  "category": ["tools"],
  "brandColor": "#3498db",
  "author": {
    "name": "Developer Name",
    "email": "dev@example.com"
  },
  "contributors": {
    "developers": [
      { "name": "Developer Name" }
    ]
  },
  "images": {
    "small": "/assets/images/small.png",
    "large": "/assets/images/large.png",
    "xlarge": "/assets/images/xlarge.png"
  },
  "permissions": [
    "homey:manager:speech-input",
    "homey:manager:speech-output"
  ]
}
```

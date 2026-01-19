# Node.js 22 Upgrade Guide

> Source: https://apps.developer.homey.app/upgrade-guides/node-js-22-upgrade-guide

## Overview

Homey now uses Node.js 22 as the runtime for apps. This guide covers changes and compatibility.

## Compatibility

Set minimum compatibility for Node.js 22 features:

```json
{
  "compatibility": ">=12.0.0"
}
```

## New Features Available

### Top-Level Await (ESM)

```javascript
// With ESM
const data = await fetch('https://api.example.com/data');
export const config = await data.json();
```

### Native Fetch

```javascript
// No need for node-fetch package
const response = await fetch('https://api.example.com');
const data = await response.json();
```

### AbortController

```javascript
const controller = new AbortController();
const { signal } = controller;

setTimeout(() => controller.abort(), 5000);

const response = await fetch(url, { signal });
```

### Improved Performance

- Faster startup times
- Better memory management
- Optimized async operations

## Breaking Changes

### Deprecated APIs

Some Node.js APIs are deprecated or removed:

```javascript
// Deprecated - use alternatives
const { URL } = require('url');  // Use global URL instead
```

### Module Resolution

If you encounter module resolution issues:

```json
{
  "type": "module"
}
```

Or use `.mjs` extension for ES modules.

## ESM Migration

### Convert to ESM

**package.json:**
```json
{
  "type": "module"
}
```

**app.js:**
```javascript
// ESM syntax
import Homey from 'homey';

class MyApp extends Homey.App {
  async onInit() {
    this.log('App initialized');
  }
}

export default MyApp;
```

### Keep CommonJS

If staying with CommonJS:

```javascript
// CommonJS (still supported)
'use strict';

const Homey = require('homey');

class MyApp extends Homey.App {
  async onInit() {
    this.log('App initialized');
  }
}

module.exports = MyApp;
```

## Testing Compatibility

### Local Testing

```bash
# Ensure Node.js 22 is installed
node --version  # v22.x.x

# Run your app
homey app run
```

### Validate

```bash
homey app validate
```

## Common Issues

### __dirname / __filename

In ESM, these aren't available:

```javascript
// ESM alternative
import { fileURLToPath } from 'url';
import { dirname } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
```

### require() in ESM

```javascript
// ESM - use import
import { createRequire } from 'module';
const require = createRequire(import.meta.url);

// Or use dynamic import
const module = await import('./module.js');
```

## Dependencies

Update dependencies for Node.js 22 compatibility:

```bash
npm update
npm audit fix
```

Check for outdated packages:

```bash
npm outdated
```

## Best Practices

1. **Test locally first** - Before publishing
2. **Update dependencies** - Ensure compatibility
3. **Use native APIs** - Like `fetch` instead of packages
4. **Consider ESM** - Modern syntax, better tooling
5. **Handle deprecations** - Replace deprecated APIs

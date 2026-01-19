# Custom Views

> Source: https://apps.developer.homey.app/advanced/custom-views

## Overview

Custom Views are HTML/CSS/JS pages embedded in your Homey app for user interaction.

## Types of Custom Views

| Type | Location | Purpose |
|------|----------|---------|
| [App Settings](./app-settings.md) | `/settings/index.html` | App configuration |
| [Pairing Views](./pairing-views.md) | `/drivers/<id>/pair/` | Custom pairing UI |
| [Widgets](../../the-basics/widgets.md) | `/widgets/<id>/public/` | Dashboard widgets |

## Common Structure

All custom views share:

1. HTML file with your UI
2. Access to `Homey` JavaScript API
3. CSS styling capabilities
4. Translation support

## The Homey JavaScript API

Include in your HTML:

```html
<script src="/homey.js" data-origin="settings"></script>
```

The `data-origin` attribute specifies the view type:
- `settings` - App settings view
- `pair` - Pairing view
- `widget` - Widget

## Initialization

```javascript
function onHomeyReady(Homey) {
  // Mark view as ready
  Homey.ready();
  
  // Your initialization code
  initializeView();
}
```

## Common API Methods

```javascript
// Get translations
const text = Homey.__('settings.title');

// Show alert
Homey.alert('Operation completed!');

// Show confirmation dialog
const confirmed = await Homey.confirm('Are you sure?');

// Show popup
Homey.popup('/popup.html', { width: 400, height: 300 });

// Get theme
const theme = Homey.getTheme(); // 'light' or 'dark'
Homey.on('theme', (newTheme) => { });

// Call app API
const result = await Homey.api('GET', '/my-endpoint');
```

## Styling

### CSS Variables

Use Homey's CSS variables for consistent theming:

```css
body {
  background: var(--homey-background);
  color: var(--homey-text);
}

.button {
  background: var(--homey-primary);
  border: 1px solid var(--homey-border);
}

.secondary-text {
  color: var(--homey-text-secondary);
}
```

### Homey Style Library

Include the Homey style library for consistent UI:

```html
<link rel="stylesheet" href="/homey.css">
```

## Translations

Use the `__()` function for translations:

```javascript
// Simple translation
const title = Homey.__('settings.title');

// With parameters
const greeting = Homey.__('settings.hello', { name: 'User' });
```

Define in `locales/en.json`:

```json
{
  "settings": {
    "title": "Settings",
    "hello": "Hello, {{name}}!"
  }
}
```

## Platform Detection

```javascript
function onHomeyReady(Homey) {
  Homey.ready();
  
  if (Homey.platform === 'local') {
    // Homey Pro features
    showLocalOptions();
  } else {
    // Homey Cloud - limited features
    hideLocalOnlyOptions();
  }
}
```

## Best Practices

1. **Call Homey.ready()** - Always mark your view as ready
2. **Use CSS variables** - For theme compatibility
3. **Handle errors** - Show user-friendly error messages
4. **Support translations** - Use `Homey.__()` for all text
5. **Test both themes** - Verify light and dark mode

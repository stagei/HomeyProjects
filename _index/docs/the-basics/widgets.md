# Widgets

> Source: https://apps.developer.homey.app/the-basics/widgets

## Overview

Widgets are custom dashboard components that display information and allow user interaction on the Homey dashboard.

**Requirements:**
- Homey Pro (Software) v12.3.0+
- `"compatibility": ">=12.3.0"` in manifest
- Only available on `"platforms": ["local"]`

## Widget Structure

```
widgets/
└── my-widget/
    ├── widget.compose.json   # Widget manifest
    ├── public/
    │   └── index.html        # Widget HTML
    └── preview.png           # Preview image (400x240)
```

## Widget Manifest

`widget.compose.json`:

```json
{
  "id": "my-widget",
  "name": { "en": "My Widget" },
  "width": 2,
  "height": 2,
  "settings": [
    {
      "id": "title",
      "type": "text",
      "title": { "en": "Title" },
      "value": "Default Title"
    }
  ]
}
```

## Widget HTML

`public/index.html`:

```html
<!DOCTYPE html>
<html>
<head>
  <style>
    body {
      margin: 0;
      padding: 16px;
      font-family: system-ui, sans-serif;
      background: var(--homey-background);
      color: var(--homey-text);
    }
    .title {
      font-size: 18px;
      font-weight: 600;
    }
    .value {
      font-size: 32px;
      margin-top: 8px;
    }
  </style>
</head>
<body>
  <div class="title" id="title"></div>
  <div class="value" id="value"></div>
  
  <script type="text/javascript">
    function onHomeyReady(Homey) {
      Homey.ready();
      
      // Get widget settings
      const settings = Homey.getSettings();
      document.getElementById('title').textContent = settings.title;
      
      // Listen for settings changes
      Homey.on('settings', (settings) => {
        document.getElementById('title').textContent = settings.title;
      });
      
      // Call API
      Homey.api('GET', '/status')
        .then(result => {
          document.getElementById('value').textContent = result.value;
        })
        .catch(console.error);
    }
  </script>
  <script src="/homey.js" data-origin="widget"></script>
</body>
</html>
```

## Homey Widget API

Available in widget's `Homey` global:

```javascript
// Mark widget as ready
Homey.ready();

// Get widget settings
const settings = Homey.getSettings();

// Call app API
Homey.api('GET', '/endpoint');
Homey.api('POST', '/endpoint', { data: 'value' });
Homey.api('PUT', '/endpoint', { data: 'value' });
Homey.api('DELETE', '/endpoint');

// Listen for events
Homey.on('settings', (newSettings) => { });

// Get theme info
const theme = Homey.getTheme(); // 'light' or 'dark'
Homey.on('theme', (theme) => { });
```

## Widget Settings Types

| Type | Description |
|------|-------------|
| `text` | Text input |
| `number` | Number input |
| `checkbox` | Boolean checkbox |
| `dropdown` | Select from values |
| `device` | Device picker |

### Device Picker Setting

```json
{
  "id": "device",
  "type": "device",
  "title": { "en": "Device" },
  "filter": {
    "capabilities": ["measure_temperature"]
  }
}
```

## CSS Variables

Widgets should use Homey's CSS variables for theming:

| Variable | Description |
|----------|-------------|
| `--homey-background` | Background color |
| `--homey-text` | Text color |
| `--homey-text-secondary` | Secondary text color |
| `--homey-border` | Border color |
| `--homey-primary` | Primary accent color |

## Widget Size

Widgets use a grid system:
- `width`: 1-4 (grid columns)
- `height`: 1-4 (grid rows)

```json
{
  "width": 2,
  "height": 1
}
```

## Best Practices

1. **Responsive design** - Handle various sizes gracefully
2. **Theme support** - Use CSS variables for light/dark themes
3. **Loading states** - Show loading indicator while fetching data
4. **Error handling** - Display friendly error messages
5. **Performance** - Minimize API calls and DOM updates

# App Settings View

> Source: https://apps.developer.homey.app/advanced/custom-views/app-settings

## Overview

The App Settings view provides a custom HTML interface for users to configure your app.

## Setup

### 1. Create Settings Folder

```
/settings/
└── index.html
```

### 2. Enable in Manifest

App settings are automatically available when `/settings/index.html` exists.

## Basic Structure

`/settings/index.html`:

```html
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>App Settings</title>
  <style>
    body {
      margin: 0;
      padding: 16px;
      font-family: system-ui, sans-serif;
      background: var(--homey-background);
      color: var(--homey-text);
    }
    
    .form-group {
      margin-bottom: 16px;
    }
    
    label {
      display: block;
      margin-bottom: 4px;
      font-weight: 500;
    }
    
    input, select {
      width: 100%;
      padding: 8px;
      border: 1px solid var(--homey-border);
      border-radius: 4px;
      background: var(--homey-background);
      color: var(--homey-text);
    }
    
    button {
      padding: 8px 16px;
      background: var(--homey-primary);
      color: white;
      border: none;
      border-radius: 4px;
      cursor: pointer;
    }
  </style>
</head>
<body>
  <h2 id="title"></h2>
  
  <div class="form-group">
    <label for="api-key">API Key</label>
    <input type="text" id="api-key" placeholder="Enter your API key">
  </div>
  
  <div class="form-group">
    <label for="poll-interval">Poll Interval (seconds)</label>
    <input type="number" id="poll-interval" min="10" max="3600" value="60">
  </div>
  
  <button id="save-btn">Save</button>
  
  <script>
    function onHomeyReady(Homey) {
      Homey.ready();
      
      // Set translated title
      document.getElementById('title').textContent = Homey.__('settings.title');
      
      // Load existing settings
      loadSettings(Homey);
      
      // Save button handler
      document.getElementById('save-btn').addEventListener('click', () => {
        saveSettings(Homey);
      });
    }
    
    async function loadSettings(Homey) {
      try {
        const apiKey = await Homey.get('apiKey');
        const pollInterval = await Homey.get('pollInterval');
        
        if (apiKey) {
          document.getElementById('api-key').value = apiKey;
        }
        if (pollInterval) {
          document.getElementById('poll-interval').value = pollInterval;
        }
      } catch (error) {
        console.error('Failed to load settings:', error);
      }
    }
    
    async function saveSettings(Homey) {
      const apiKey = document.getElementById('api-key').value;
      const pollInterval = parseInt(document.getElementById('poll-interval').value);
      
      try {
        await Homey.set('apiKey', apiKey);
        await Homey.set('pollInterval', pollInterval);
        
        Homey.alert('Settings saved!');
      } catch (error) {
        Homey.alert('Failed to save settings: ' + error.message);
      }
    }
  </script>
  <script src="/homey.js" data-origin="settings"></script>
</body>
</html>
```

## Settings API

### Get Settings

```javascript
// Get single setting
const value = await Homey.get('key');

// Get all settings
const settings = await Homey.get();
```

### Set Settings

```javascript
// Set single setting
await Homey.set('key', 'value');

// Set multiple settings
await Homey.set('key1', 'value1');
await Homey.set('key2', 'value2');
```

### Remove Settings

```javascript
await Homey.unset('key');
```

## Calling App API

Your settings page can communicate with your app:

```javascript
// Call app API endpoint
const result = await Homey.api('GET', '/status');
const updated = await Homey.api('POST', '/update', { data: 'value' });
```

Define API in `api.js`:

```javascript
module.exports = {
  async getStatus({ homey }) {
    return { status: 'ok' };
  },
  
  async postUpdate({ homey, body }) {
    homey.settings.set('lastUpdate', body.data);
    return { success: true };
  }
};
```

## Advanced UI Elements

### Confirmation Dialog

```javascript
const confirmed = await Homey.confirm('Delete all data?', 'warning');
if (confirmed) {
  await Homey.api('DELETE', '/data');
}
```

### Popup Window

```javascript
Homey.popup('/popup.html', {
  width: 500,
  height: 400
});
```

## Best Practices

1. **Validate input** - Check values before saving
2. **Show loading states** - Indicate when saving
3. **Handle errors** - Show user-friendly messages
4. **Use translations** - Support multiple languages
5. **Respect theme** - Use CSS variables

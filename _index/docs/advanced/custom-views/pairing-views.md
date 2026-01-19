# Custom Pairing Views

> Source: https://apps.developer.homey.app/advanced/custom-views/custom-pairing-views

## Overview

Custom pairing views allow you to create custom HTML interfaces for device pairing.

## When to Use

Use custom pairing views when you need:
- Custom authentication flow
- Complex device configuration
- Brand-specific UI
- Multi-step setup wizards

## Setup

### 1. Create Pairing Folder

```
/drivers/my-driver/
├── driver.js
├── device.js
├── driver.compose.json
└── pair/
    ├── login.html
    ├── select.html
    └── done.html
```

### 2. Define in Driver Manifest

```json
{
  "id": "my-driver",
  "pair": [
    {
      "id": "login",
      "template": "login",
      "navigation": {
        "next": "select"
      }
    },
    {
      "id": "select",
      "template": "list_devices",
      "navigation": {
        "prev": "login",
        "next": "done"
      }
    },
    {
      "id": "done",
      "template": "done"
    }
  ]
}
```

## Pairing View Structure

`/drivers/my-driver/pair/login.html`:

```html
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Login</title>
  <style>
    body {
      margin: 0;
      padding: 16px;
      font-family: system-ui, sans-serif;
      background: var(--homey-background);
      color: var(--homey-text);
    }
    
    .form-group { margin-bottom: 16px; }
    label { display: block; margin-bottom: 4px; }
    input {
      width: 100%;
      padding: 8px;
      border: 1px solid var(--homey-border);
      border-radius: 4px;
    }
    button {
      padding: 8px 16px;
      background: var(--homey-primary);
      color: white;
      border: none;
      border-radius: 4px;
      cursor: pointer;
    }
    .error { color: #e74c3c; margin-top: 8px; }
  </style>
</head>
<body>
  <h2>Connect Your Account</h2>
  
  <div class="form-group">
    <label>Email</label>
    <input type="email" id="email">
  </div>
  
  <div class="form-group">
    <label>Password</label>
    <input type="password" id="password">
  </div>
  
  <button id="login-btn">Login</button>
  <div class="error" id="error" style="display: none;"></div>
  
  <script>
    function onHomeyReady(Homey) {
      Homey.ready();
      
      document.getElementById('login-btn').addEventListener('click', async () => {
        const email = document.getElementById('email').value;
        const password = document.getElementById('password').value;
        const errorDiv = document.getElementById('error');
        
        errorDiv.style.display = 'none';
        
        try {
          // Send credentials to driver
          const result = await Homey.emit('login', { email, password });
          
          if (result.success) {
            // Navigate to next step
            Homey.nextView();
          } else {
            errorDiv.textContent = result.error || 'Login failed';
            errorDiv.style.display = 'block';
          }
        } catch (error) {
          errorDiv.textContent = error.message;
          errorDiv.style.display = 'block';
        }
      });
    }
  </script>
  <script src="/homey.js" data-origin="pair"></script>
</body>
</html>
```

## Driver-Side Handlers

```javascript
'use strict';

const Homey = require('homey');

class MyDriver extends Homey.Driver {
  
  async onPair(session) {
    let credentials = null;
    
    // Handle login from custom view
    session.setHandler('login', async (data) => {
      try {
        const token = await this.authenticate(data.email, data.password);
        credentials = { email: data.email, token };
        return { success: true };
      } catch (error) {
        return { success: false, error: error.message };
      }
    });
    
    // List devices after login
    session.setHandler('list_devices', async () => {
      const devices = await this.fetchDevices(credentials.token);
      
      return devices.map(d => ({
        name: d.name,
        data: { id: d.id },
        store: { token: credentials.token }
      }));
    });
  }
  
  async authenticate(email, password) {
    // Implement authentication logic
    const response = await fetch('https://api.example.com/login', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email, password })
    });
    
    if (!response.ok) {
      throw new Error('Invalid credentials');
    }
    
    const data = await response.json();
    return data.token;
  }
}

module.exports = MyDriver;
```

## Navigation

```javascript
// Go to next view
Homey.nextView();

// Go to previous view
Homey.prevView();

// Go to specific view
Homey.showView('done');

// Close pairing
Homey.done();
```

## Communication

### From View to Driver

```javascript
// In HTML view
const result = await Homey.emit('eventName', data);
```

```javascript
// In driver.js
session.setHandler('eventName', async (data) => {
  // Process data
  return result;
});
```

### From Driver to View

```javascript
// In driver.js
await session.emit('update', { status: 'connected' });
```

```javascript
// In HTML view
Homey.on('update', (data) => {
  console.log('Status:', data.status);
});
```

## Built-in Templates

You can mix custom views with built-in templates:

| Template | Purpose |
|----------|---------|
| `list_devices` | Show device list |
| `add_devices` | Add selected devices |
| `done` | Success message |

## Best Practices

1. **Validate input** - Check user input before sending
2. **Handle errors** - Show clear error messages
3. **Loading states** - Indicate when processing
4. **Secure credentials** - Store tokens, not passwords
5. **Navigation flow** - Make back/next buttons work logically

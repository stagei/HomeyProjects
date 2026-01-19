# OAuth2

> Source: https://apps.developer.homey.app/cloud/oauth2

## Overview

OAuth2 allows your app to authenticate with third-party services securely without handling user passwords.

**Helper Library:** [github.com/athombv/node-homey-oauth2app](https://github.com/athombv/node-homey-oauth2app/)

## Setting Up OAuth2

### 1. App Manifest

```json
{
  "id": "com.example.myapp",
  "permissions": [],
  "oauth2": {
    "clientId": "your-client-id",
    "clientSecret": "your-client-secret",
    "authorizationUrl": "https://api.example.com/oauth/authorize",
    "tokenUrl": "https://api.example.com/oauth/token",
    "scopes": ["read", "write"]
  }
}
```

### 2. Using OAuth2 in Code

```javascript
'use strict';

const Homey = require('homey');

class MyApp extends Homey.App {
  
  async onInit() {
    // Get OAuth2 client
    const client = this.homey.oauth2.getClient();
    
    // Check if already authenticated
    const isAuthenticated = await client.hasToken();
    
    if (isAuthenticated) {
      const token = await client.getToken();
      this.log('Access token:', token.access_token);
    }
  }
  
  async makeApiRequest(endpoint) {
    const client = this.homey.oauth2.getClient();
    
    // Get current token (auto-refreshes if expired)
    const token = await client.getToken();
    
    const response = await fetch(`https://api.example.com${endpoint}`, {
      headers: {
        'Authorization': `Bearer ${token.access_token}`
      }
    });
    
    return response.json();
  }
}

module.exports = MyApp;
```

## OAuth2 Flow in Pairing

```javascript
class MyDriver extends Homey.Driver {
  
  async onPair(session) {
    // Start OAuth2 flow
    session.setHandler('login', async () => {
      const client = this.homey.oauth2.getClient();
      
      // Get authorization URL
      const authUrl = await client.getAuthorizationUrl();
      
      return authUrl;
    });
    
    // Handle callback
    session.setHandler('callback', async (callbackUrl) => {
      const client = this.homey.oauth2.getClient();
      
      // Exchange code for token
      await client.handleCallback(callbackUrl);
      
      return true;
    });
    
    // List devices after authentication
    session.setHandler('list_devices', async () => {
      const devices = await this.fetchDevices();
      
      return devices.map(d => ({
        name: d.name,
        data: { id: d.id }
      }));
    });
  }
}
```

## Token Management

```javascript
class MyDevice extends Homey.Device {
  
  async getAccessToken() {
    const client = this.homey.oauth2.getClient();
    
    try {
      const token = await client.getToken();
      return token.access_token;
      
    } catch (error) {
      if (error.message === 'Token expired') {
        // Token refresh failed, need to re-authenticate
        await this.setUnavailable('Please re-authenticate');
        throw error;
      }
      throw error;
    }
  }
  
  async makeAuthenticatedRequest(url, options = {}) {
    const token = await this.getAccessToken();
    
    const response = await fetch(url, {
      ...options,
      headers: {
        ...options.headers,
        'Authorization': `Bearer ${token}`
      }
    });
    
    if (response.status === 401) {
      // Token invalid, trigger re-auth
      await this.setUnavailable('Authentication expired');
      throw new Error('Unauthorized');
    }
    
    return response;
  }
}
```

## Environment Variables

Store sensitive OAuth2 credentials in `env.json`:

```json
{
  "OAUTH_CLIENT_ID": "your-client-id",
  "OAUTH_CLIENT_SECRET": "your-client-secret"
}
```

Reference in manifest:

```json
{
  "oauth2": {
    "clientId": "$OAUTH_CLIENT_ID",
    "clientSecret": "$OAUTH_CLIENT_SECRET"
  }
}
```

## Scopes

Request only necessary scopes:

```json
{
  "oauth2": {
    "scopes": ["devices:read", "devices:control"]
  }
}
```

## Best Practices

1. **Use env.json** - Never hardcode secrets in manifest
2. **Minimal scopes** - Request only what you need
3. **Handle token expiry** - Implement refresh logic
4. **Provide re-auth flow** - Allow users to re-authenticate
5. **Secure storage** - Tokens are stored securely by Homey

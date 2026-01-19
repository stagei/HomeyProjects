# Web API

> Source: https://apps.developer.homey.app/advanced/web-api

## Overview

Apps can expose HTTP endpoints that can be called from widgets, other apps, or external services.

**Note:** Web API is only available on Homey Pro (`"platforms": ["local"]`).

## Defining API Endpoints

In `app.json`:

```json
{
  "api": {
    "getStatus": {
      "method": "GET",
      "path": "/status"
    },
    "setStatus": {
      "method": "POST",
      "path": "/status"
    },
    "getDevice": {
      "method": "GET",
      "path": "/devices/:id"
    }
  }
}
```

## Implementing API Handlers

Create `api.js` in your app root:

```javascript
'use strict';

module.exports = {
  
  async getStatus({ homey, query }) {
    // GET /api/app/com.example.myapp/status
    return {
      status: 'online',
      timestamp: Date.now()
    };
  },
  
  async setStatus({ homey, body }) {
    // POST /api/app/com.example.myapp/status
    // body contains the JSON payload
    const { status } = body;
    
    await homey.settings.set('status', status);
    
    return { success: true };
  },
  
  async getDevice({ homey, params }) {
    // GET /api/app/com.example.myapp/devices/:id
    const { id } = params;
    
    const device = homey.drivers.getDriver('my-driver')
      .getDevices()
      .find(d => d.getData().id === id);
    
    if (!device) {
      throw new Error('Device not found');
    }
    
    return {
      id,
      name: device.getName(),
      capabilities: device.getCapabilities()
    };
  }
};
```

## API Handler Parameters

| Parameter | Description |
|-----------|-------------|
| `homey` | The Homey instance |
| `query` | Query parameters (GET) |
| `body` | Request body (POST/PUT) |
| `params` | URL parameters (`:id`) |

## Making Requests to App API

### From Widgets

```javascript
Homey.api('GET', '/status')
  .then(result => console.log(result))
  .catch(error => console.error(error));

Homey.api('POST', '/status', { status: 'active' })
  .then(result => console.log(result));
```

### From Other Apps

```javascript
const result = await this.homey.api.apps.getApp('com.example.myapp')
  .then(app => app.apiGet('/status'));
```

### From External (Cloud)

```
GET https://api.athom.com/api/homey/<homey-id>/manager/apps/app/com.example.myapp/api/status
Authorization: Bearer <token>
```

## Public vs Private Endpoints

By default, endpoints require authentication. Make an endpoint public:

```json
{
  "api": {
    "getPublicStatus": {
      "method": "GET",
      "path": "/public/status",
      "public": true
    }
  }
}
```

**Warning:** Public endpoints can be called without authentication. Use with caution.

## Error Handling

Throw errors to return error responses:

```javascript
async getDevice({ homey, params }) {
  const { id } = params;
  
  if (!id) {
    throw new Error('Device ID is required');
  }
  
  const device = findDevice(id);
  
  if (!device) {
    const error = new Error('Device not found');
    error.statusCode = 404;
    throw error;
  }
  
  return device;
}
```

## Best Practices

1. **Minimize public endpoints** - Keep endpoints private when possible
2. **Validate input** - Always validate `body` and `params`
3. **Return JSON** - Always return JSON-serializable objects
4. **Handle errors** - Return meaningful error messages
5. **Rate limiting** - Consider rate limiting for heavy endpoints

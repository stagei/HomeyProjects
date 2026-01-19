# Webhooks

> Source: https://apps.developer.homey.app/cloud/webhooks

## Overview

Webhooks allow your app to receive real-time HTTP notifications from external services.

## How Webhooks Work

1. External service sends HTTP request to Homey's webhook forwarding service
2. Homey forwards the request to your app
3. Your app processes the webhook payload

## Setting Up Webhooks

### 1. Register Webhook

Register your webhook at: https://tools.developer.homey.app/webhooks

You'll receive:
- Webhook ID
- Webhook Secret

### 2. Store in Environment

`env.json`:
```json
{
  "WEBHOOK_ID": "your-webhook-id",
  "WEBHOOK_SECRET": "your-webhook-secret"
}
```

### 3. Create Webhook in App

```javascript
'use strict';

const Homey = require('homey');

class MyApp extends Homey.App {
  
  async onInit() {
    await this.setupWebhook();
  }
  
  async setupWebhook() {
    const webhookId = Homey.env.WEBHOOK_ID;
    const webhookSecret = Homey.env.WEBHOOK_SECRET;
    
    // Create webhook instance
    const webhook = await this.homey.cloud.createWebhook(
      webhookId,
      webhookSecret,
      { myData: 'optional-data' }
    );
    
    // Listen for messages
    webhook.on('message', (message) => {
      this.log('Webhook received:', message);
      this.handleWebhook(message);
    });
    
    this.webhook = webhook;
  }
  
  handleWebhook(message) {
    const { headers, query, body } = message;
    
    // Process webhook payload
    if (body.event === 'device_updated') {
      this.updateDevice(body.device);
    }
  }
  
  async onUninit() {
    // Clean up webhook
    if (this.webhook) {
      await this.webhook.unregister();
    }
  }
}

module.exports = MyApp;
```

## Webhook URL Format

The URL to give to external services:

```
https://webhooks.athom.com/webhook/{webhookId}?homey={homeyId}
```

You can add custom query parameters:

```
https://webhooks.athom.com/webhook/{webhookId}?homey={homeyId}&device=123
```

## Webhook Message Structure

```javascript
webhook.on('message', (message) => {
  // message contains:
  const {
    headers,  // HTTP headers
    query,    // Query parameters
    body      // Request body (parsed JSON)
  } = message;
});
```

## Filtering Webhooks

Match specific webhooks using data:

```javascript
const webhook = await this.homey.cloud.createWebhook(
  webhookId,
  webhookSecret,
  {
    // Only receive webhooks matching this data
    deviceId: 'specific-device-123'
  }
);
```

## Multiple Webhooks

```javascript
async setupWebhooks() {
  // Webhook for device events
  this.deviceWebhook = await this.homey.cloud.createWebhook(
    Homey.env.DEVICE_WEBHOOK_ID,
    Homey.env.DEVICE_WEBHOOK_SECRET,
    { type: 'device' }
  );
  
  // Webhook for user events
  this.userWebhook = await this.homey.cloud.createWebhook(
    Homey.env.USER_WEBHOOK_ID,
    Homey.env.USER_WEBHOOK_SECRET,
    { type: 'user' }
  );
  
  this.deviceWebhook.on('message', this.handleDeviceEvent.bind(this));
  this.userWebhook.on('message', this.handleUserEvent.bind(this));
}
```

## Security

### Verify Webhook Source

```javascript
handleWebhook(message) {
  // Verify expected headers
  const signature = message.headers['x-webhook-signature'];
  
  if (!this.verifySignature(signature, message.body)) {
    this.error('Invalid webhook signature');
    return;
  }
  
  // Process verified webhook
  this.processEvent(message.body);
}
```

## Best Practices

1. **Store secrets in env.json** - Never hardcode webhook secrets
2. **Handle errors gracefully** - Webhooks may fail or timeout
3. **Verify source** - Check signatures when available
4. **Unregister on uninit** - Clean up webhook subscriptions
5. **Log webhooks** - Helpful for debugging

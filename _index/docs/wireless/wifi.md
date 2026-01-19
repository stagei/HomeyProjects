# Wi-Fi

> Source: https://apps.developer.homey.app/wireless/wi-fi

## Overview

Wi-Fi devices communicate over your local network using HTTP, TCP, UDP, or WebSocket protocols.

## No Special Permissions Required

Wi-Fi communication doesn't require special permissions in the manifest.

## HTTP Communication

```javascript
const fetch = require('node-fetch');

class MyDevice extends Homey.Device {
  
  async sendCommand(command) {
    const ip = this.getSetting('ip');
    
    const response = await fetch(`http://${ip}/api/command`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ command })
    });
    
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}`);
    }
    
    return response.json();
  }
}
```

## Discovery Strategies

Define discovery in driver manifest to automatically find devices:

### mDNS-SD Discovery

```json
{
  "discovery": "my-discovery",
  "discoveryStrategies": [
    {
      "id": "my-discovery",
      "type": "mdns-sd",
      "mdns-sd": {
        "name": "_http._tcp.local",
        "txt": {
          "md": "MyDevice*"
        }
      },
      "id": "{{txt.id}}"
    }
  ]
}
```

### SSDP Discovery

```json
{
  "discoveryStrategies": [
    {
      "id": "my-discovery",
      "type": "ssdp",
      "ssdp": {
        "search": "urn:schemas-upnp-org:device:Basic:1"
      },
      "id": "{{headers.usn}}"
    }
  ]
}
```

### MAC Address Discovery

```json
{
  "discoveryStrategies": [
    {
      "id": "my-discovery",
      "type": "mac",
      "mac": {
        "manufacturer": ["AB:CD:EF"]
      },
      "id": "{{id}}"
    }
  ]
}
```

## Using Discovery Results

```javascript
// In driver.js
async onPairListDevices() {
  const discoveryStrategy = this.getDiscoveryStrategy();
  const devices = discoveryStrategy.getDiscoveryResults();
  
  return Object.values(devices).map(device => ({
    name: device.txt?.name || 'Unknown Device',
    data: { id: device.id },
    settings: { ip: device.address }
  }));
}

// In device.js - automatic availability
async onDiscoveryResult(discoveryResult) {
  // Device found on network
  await this.setAvailable();
}

async onDiscoveryAvailable(discoveryResult) {
  // Device became available
  this.setSettings({ ip: discoveryResult.address });
}

async onDiscoveryAddressChanged(discoveryResult) {
  // IP address changed
  this.setSettings({ ip: discoveryResult.address });
}
```

## WebSocket Communication

```javascript
const WebSocket = require('ws');

class MyDevice extends Homey.Device {
  
  async onInit() {
    this.connectWebSocket();
  }
  
  connectWebSocket() {
    const ip = this.getSetting('ip');
    this.ws = new WebSocket(`ws://${ip}:8080`);
    
    this.ws.on('open', () => {
      this.log('WebSocket connected');
    });
    
    this.ws.on('message', (data) => {
      const message = JSON.parse(data);
      this.handleMessage(message);
    });
    
    this.ws.on('close', () => {
      // Reconnect after delay
      setTimeout(() => this.connectWebSocket(), 5000);
    });
  }
  
  async onDeleted() {
    if (this.ws) {
      this.ws.close();
    }
  }
}
```

## Best Practices

1. **Handle network errors** - Devices go offline
2. **Use discovery** - Automatically find devices
3. **Cache IP addresses** - Store in settings
4. **Implement reconnection** - Handle disconnections gracefully
5. **Respect rate limits** - Don't flood devices with requests

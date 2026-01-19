# Bluetooth LE

> Source: https://apps.developer.homey.app/wireless/bluetooth-le

## Overview

Bluetooth Low Energy (BLE) allows communication with nearby Bluetooth devices.

## Requirements

- Homey Pro (not available on Homey Cloud)
- Permission: `homey:wireless:ble`

```json
{
  "permissions": ["homey:wireless:ble"]
}
```

## Scanning for Devices

```javascript
'use strict';

const Homey = require('homey');

class MyDriver extends Homey.Driver {
  
  async onPairListDevices() {
    const devices = [];
    
    // Scan for BLE devices
    const advertisements = await this.homey.ble.discover();
    
    for (const advertisement of advertisements) {
      // Filter by service UUID or name
      if (advertisement.localName?.includes('MyDevice')) {
        devices.push({
          name: advertisement.localName,
          data: {
            id: advertisement.uuid
          }
        });
      }
    }
    
    return devices;
  }
}

module.exports = MyDriver;
```

## Connecting to Devices

```javascript
class MyDevice extends Homey.Device {
  
  async onInit() {
    const uuid = this.getData().id;
    
    try {
      // Find the advertisement
      const advertisement = await this.homey.ble.find(uuid);
      
      // Connect to the device
      const peripheral = await advertisement.connect();
      
      // Discover services
      const services = await peripheral.discoverServices();
      
      // Get specific service
      const service = await peripheral.getService('180f'); // Battery service
      
      // Get characteristic
      const characteristic = await service.getCharacteristic('2a19'); // Battery level
      
      // Read value
      const data = await characteristic.read();
      const batteryLevel = data[0];
      
      await this.setCapabilityValue('measure_battery', batteryLevel);
      
      // Disconnect when done
      await peripheral.disconnect();
      
    } catch (error) {
      this.error('BLE error:', error);
      await this.setUnavailable('Could not connect');
    }
  }
}
```

## BLE Services and Characteristics

Common standard services:

| Service UUID | Name |
|--------------|------|
| `180f` | Battery Service |
| `1800` | Generic Access |
| `1801` | Generic Attribute |
| `180a` | Device Information |

## Subscribing to Notifications

```javascript
async subscribeToNotifications() {
  const uuid = this.getData().id;
  const advertisement = await this.homey.ble.find(uuid);
  const peripheral = await advertisement.connect();
  
  const service = await peripheral.getService('custom-service-uuid');
  const characteristic = await service.getCharacteristic('custom-char-uuid');
  
  // Subscribe to notifications
  await characteristic.subscribeToNotifications((data) => {
    this.log('Received notification:', data);
    this.handleNotification(data);
  });
}
```

## Writing to Characteristics

```javascript
async sendCommand(command) {
  const uuid = this.getData().id;
  const advertisement = await this.homey.ble.find(uuid);
  const peripheral = await advertisement.connect();
  
  try {
    const service = await peripheral.getService('service-uuid');
    const characteristic = await service.getCharacteristic('char-uuid');
    
    // Write data
    const buffer = Buffer.from(command);
    await characteristic.write(buffer);
    
  } finally {
    await peripheral.disconnect();
  }
}
```

## Connection Management

```javascript
class MyDevice extends Homey.Device {
  
  async onInit() {
    this.peripheral = null;
    await this.connect();
  }
  
  async connect() {
    try {
      const uuid = this.getData().id;
      const advertisement = await this.homey.ble.find(uuid);
      this.peripheral = await advertisement.connect();
      
      // Handle disconnect
      this.peripheral.on('disconnect', () => {
        this.log('BLE disconnected, reconnecting...');
        setTimeout(() => this.connect(), 5000);
      });
      
      await this.setAvailable();
      
    } catch (error) {
      this.error('Connection failed:', error);
      await this.setUnavailable('Cannot connect');
      setTimeout(() => this.connect(), 10000);
    }
  }
  
  async onDeleted() {
    if (this.peripheral) {
      await this.peripheral.disconnect();
    }
  }
}
```

## Best Practices

1. **Disconnect when done** - Don't keep connections open unnecessarily
2. **Handle disconnections** - Implement reconnection logic
3. **Scan efficiently** - Don't scan continuously
4. **Use timeouts** - BLE operations can hang
5. **Handle errors gracefully** - BLE is unreliable

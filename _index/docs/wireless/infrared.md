# Infrared (IR)

> Source: https://apps.developer.homey.app/wireless/infrared

## Overview

Infrared allows control of devices like TVs, air conditioners, and audio equipment.

## Requirements

- Homey Pro (not available on Homey Cloud)
- Permission: `homey:wireless:ir`

```json
{
  "permissions": ["homey:wireless:ir"]
}
```

## Signal Definition

Define IR signals in your driver manifest:

```json
{
  "id": "my-ir-device",
  "class": "tv",
  "capabilities": ["onoff", "volume_up", "volume_down"],
  "ir": {
    "signal": {
      "id": "my-ir-signal",
      "carrier": 38000,
      "dutyCycle": 0.5,
      "sof": [9000, 4500],
      "eof": [560],
      "words": [
        [560, 560],
        [560, 1690]
      ],
      "interval": 108000,
      "repetitions": 1,
      "minimalLength": 32,
      "maximalLength": 32
    }
  }
}
```

## Signal Parameters

| Parameter | Description |
|-----------|-------------|
| `carrier` | Carrier frequency in Hz (typically 38000) |
| `dutyCycle` | PWM duty cycle (0-1) |
| `sof` | Start of frame timing |
| `eof` | End of frame timing |
| `words` | Bit definitions |
| `interval` | Signal interval |
| `repetitions` | Number of repeats |

## Transmitting IR Commands

```javascript
'use strict';

const Homey = require('homey');

class MyDevice extends Homey.Device {
  
  async onInit() {
    this.registerCapabilityListener('onoff', this.onCapabilityOnoff.bind(this));
    this.registerCapabilityListener('volume_up', this.onVolumeUp.bind(this));
    this.registerCapabilityListener('volume_down', this.onVolumeDown.bind(this));
  }
  
  async sendIR(command) {
    const signal = this.homey.rf.getSignalInfrared('my-ir-signal');
    await signal.tx(command);
  }
  
  async onCapabilityOnoff(value) {
    // NEC protocol power toggle
    await this.sendIR('00100000110111110001000011101111');
  }
  
  async onVolumeUp() {
    await this.sendIR('00100000110111110100000010111111');
  }
  
  async onVolumeDown() {
    await this.sendIR('00100000110111111100000000111111');
  }
}

module.exports = MyDevice;
```

## Learning IR Commands

```javascript
class MyDriver extends Homey.Driver {
  
  async onPair(session) {
    let learnedCommands = {};
    
    session.setHandler('learn_command', async (commandName) => {
      const signal = this.homey.rf.getSignalInfrared('my-ir-signal');
      
      await signal.enableRX();
      
      return new Promise((resolve, reject) => {
        const timeout = setTimeout(() => {
          signal.disableRX();
          reject(new Error('Learning timeout'));
        }, 30000);
        
        signal.once('payload', (payload) => {
          clearTimeout(timeout);
          signal.disableRX();
          learnedCommands[commandName] = payload;
          resolve(payload);
        });
      });
    });
    
    session.setHandler('get_commands', () => {
      return learnedCommands;
    });
  }
}
```

## Common IR Protocols

### NEC Protocol
```json
{
  "carrier": 38000,
  "sof": [9000, 4500],
  "eof": [560],
  "words": [
    [560, 560],
    [560, 1690]
  ]
}
```

### Sony Protocol
```json
{
  "carrier": 40000,
  "sof": [2400, 600],
  "words": [
    [600, 600],
    [1200, 600]
  ]
}
```

### RC5 Protocol
```json
{
  "carrier": 36000,
  "words": [
    [889, 889],
    [889, 889]
  ]
}
```

## Storing Learned Commands

```javascript
async onInit() {
  // Get stored commands
  const commands = this.getStoreValue('ir_commands') || {};
  
  this.registerCapabilityListener('onoff', async (value) => {
    const command = value ? commands.power_on : commands.power_off;
    if (command) {
      await this.sendIR(command);
    }
  });
}
```

## Best Practices

1. **Learn real signals** - Capture from actual remotes
2. **Test line-of-sight** - IR requires direct visibility
3. **Store commands** - Use device store for learned codes
4. **Handle protocols** - Different devices use different protocols
5. **Provide fallbacks** - Include manual code entry option

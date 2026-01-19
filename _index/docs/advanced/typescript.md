# Using TypeScript

> Source: https://apps.developer.homey.app/guides/tools/typescript

## Overview

TypeScript is supported for Homey app development. The build process compiles TypeScript to JavaScript before deployment.

## Setup

### 1. Initialize TypeScript

```bash
npm install --save-dev typescript @types/node @types/homey
```

### 2. Create tsconfig.json

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "commonjs",
    "lib": ["ES2022"],
    "outDir": "./.homeybuild",
    "rootDir": "./",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "declaration": false,
    "sourceMap": true
  },
  "include": [
    "**/*.ts"
  ],
  "exclude": [
    "node_modules",
    ".homeybuild"
  ]
}
```

### 3. Update package.json

```json
{
  "scripts": {
    "build": "tsc",
    "watch": "tsc --watch",
    "homey:run": "npm run build && homey app run"
  }
}
```

## Example App in TypeScript

### app.ts

```typescript
import Homey from 'homey';

class MyApp extends Homey.App {
  
  async onInit(): Promise<void> {
    this.log('MyApp has been initialized');
    
    // Register flow cards
    this.registerFlowCards();
  }
  
  private registerFlowCards(): void {
    const actionCard = this.homey.flow.getActionCard('my_action');
    
    actionCard.registerRunListener(async (args: { value: string }) => {
      this.log('Action triggered with value:', args.value);
    });
  }
}

module.exports = MyApp;
```

### drivers/my-driver/device.ts

```typescript
import Homey from 'homey';

interface DeviceData {
  id: string;
}

interface DeviceSettings {
  pollInterval: number;
}

class MyDevice extends Homey.Device {
  
  private pollingInterval?: NodeJS.Timeout;
  
  async onInit(): Promise<void> {
    this.log('MyDevice has been initialized');
    
    const data = this.getData() as DeviceData;
    this.log('Device ID:', data.id);
    
    this.registerCapabilityListener('onoff', this.onCapabilityOnoff.bind(this));
    
    this.startPolling();
  }
  
  private async onCapabilityOnoff(value: boolean): Promise<void> {
    this.log('Setting onoff to:', value);
    // Implement device control
  }
  
  private startPolling(): void {
    const settings = this.getSettings() as DeviceSettings;
    
    this.pollingInterval = setInterval(async () => {
      await this.poll();
    }, settings.pollInterval * 1000);
  }
  
  private async poll(): Promise<void> {
    // Poll device status
  }
  
  async onDeleted(): Promise<void> {
    if (this.pollingInterval) {
      clearInterval(this.pollingInterval);
    }
  }
}

module.exports = MyDevice;
```

## Type Definitions

The `@types/homey` package provides type definitions for:

- `Homey.App`
- `Homey.Driver`
- `Homey.Device`
- `Homey.FlowCard`
- `Homey.Api`
- And more...

## Building

```bash
# Build once
npm run build

# Build and run
npm run homey:run

# Watch mode (development)
npm run watch
```

## Best Practices

1. **Enable strict mode** - Use `"strict": true` in tsconfig
2. **Type your data** - Create interfaces for device data/settings
3. **Use async/await** - Properly type Promise return values
4. **Export with module.exports** - Required for Homey to find classes
5. **Build before running** - Always compile before `homey app run`

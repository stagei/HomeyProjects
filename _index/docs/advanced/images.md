# Images

> Source: https://apps.developer.homey.app/advanced/images

## Overview

Homey apps can create and manage images for use in flows, devices, and widgets.

## Creating Images

### From URL

```javascript
const image = await this.homey.images.createImage();
image.setUrl('https://example.com/image.jpg');

// Register the image
await image.register();
```

### From Stream

```javascript
const fs = require('fs');
const path = require('path');

const image = await this.homey.images.createImage();
const stream = fs.createReadStream(path.join(__dirname, 'assets/image.jpg'));
image.setStream(stream);

await image.register();
```

### From Local Path

```javascript
const path = require('path');

const image = await this.homey.images.createImage();
image.setPath(path.join(__dirname, 'assets/camera-snapshot.jpg'));

await image.register();
```

## Image Properties

```javascript
const image = await this.homey.images.createImage();

// Set image source
image.setUrl('https://example.com/image.jpg');

// Set content type (optional)
image.setFormat('image/jpeg');

// Register to make available
await image.register();
```

## Updating Images

```javascript
class MyDevice extends Homey.Device {
  
  async onInit() {
    // Create and register image
    this.cameraImage = await this.homey.images.createImage();
    this.cameraImage.setStream(async () => {
      return this.fetchCameraSnapshot();
    });
    await this.cameraImage.register();
    
    // Set as device camera image
    await this.setCameraImage('snapshot', 'Camera Snapshot', this.cameraImage);
  }
  
  async fetchCameraSnapshot() {
    const response = await fetch(this.getSetting('snapshotUrl'));
    return response.body;
  }
  
  // Trigger image update
  async updateSnapshot() {
    await this.cameraImage.update();
  }
}
```

## Device Camera Image

Devices can have associated camera images:

```javascript
async onInit() {
  const image = await this.homey.images.createImage();
  
  // Dynamic image - provide stream function
  image.setStream(async () => {
    return await this.getCameraStream();
  });
  
  await image.register();
  
  // Set as device's camera image
  await this.setCameraImage('camera', 'Camera', image);
}
```

## Flow Token Images

Create image tokens for flows:

```javascript
async onInit() {
  // Create image token
  this.imageToken = await this.homey.flow.createToken('snapshot', {
    type: 'image',
    title: 'Camera Snapshot'
  });
  
  // Create associated image
  this.snapshotImage = await this.homey.images.createImage();
  this.snapshotImage.setStream(async () => this.getSnapshot());
  await this.snapshotImage.register();
}

async triggerSnapshot() {
  // Update image
  await this.snapshotImage.update();
  
  // Set token value
  await this.imageToken.setValue(this.snapshotImage);
  
  // Trigger flow
  await this.homey.flow.getTriggerCard('snapshot_taken')
    .trigger(this, { snapshot: this.snapshotImage });
}
```

## Size Limits

- Maximum image size: **5 MB**
- Recommended formats: JPEG, PNG
- Optimize images for performance

## Best Practices

1. **Optimize size** - Compress images before use
2. **Use streams** - For dynamic/large images
3. **Cache wisely** - Don't recreate images unnecessarily
4. **Handle errors** - Image loading can fail
5. **Clean up** - Unregister images when no longer needed

## Cleanup

```javascript
async onDeleted() {
  if (this.cameraImage) {
    await this.cameraImage.unregister();
  }
}
```

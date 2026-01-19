# SDK v3 API Reference

> Source: https://apps-sdk-v3.developer.homey.app/

## Tutorials

| Topic | Local Doc | Official Link |
|-------|-----------|---------------|
| Device Capabilities | [device-capabilities.md](./device-capabilities.md) | [tutorial-device-capabilities.html](https://apps-sdk-v3.developer.homey.app/tutorial-device-capabilities.html) |
| Device Classes | [device-classes.md](./device-classes.md) | [tutorial-device-classes.html](https://apps-sdk-v3.developer.homey.app/tutorial-device-classes.html) |

---

## Managers

Managers provide access to Homey's functionality. Access via `this.homey.<manager>`.

| Manager | Access | Description |
|---------|--------|-------------|
| [ManagerApi](https://apps-sdk-v3.developer.homey.app/ManagerApi.html) | `this.homey.api` | Web API access |
| [ManagerApps](https://apps-sdk-v3.developer.homey.app/ManagerApps.html) | `this.homey.apps` | App management |
| [ManagerArp](https://apps-sdk-v3.developer.homey.app/ManagerArp.html) | `this.homey.arp` | ARP table access |
| [ManagerAudio](https://apps-sdk-v3.developer.homey.app/ManagerAudio.html) | `this.homey.audio` | Audio playback |
| [ManagerBLE](https://apps-sdk-v3.developer.homey.app/ManagerBLE.html) | `this.homey.ble` | Bluetooth LE |
| [ManagerClock](https://apps-sdk-v3.developer.homey.app/ManagerClock.html) | `this.homey.clock` | Time and timezone |
| [ManagerCloud](https://apps-sdk-v3.developer.homey.app/ManagerCloud.html) | `this.homey.cloud` | Cloud features (webhooks) |
| [ManagerDiscovery](https://apps-sdk-v3.developer.homey.app/ManagerDiscovery.html) | `this.homey.discovery` | Device discovery |
| [ManagerDrivers](https://apps-sdk-v3.developer.homey.app/ManagerDrivers.html) | `this.homey.drivers` | Driver management |
| [ManagerFlow](https://apps-sdk-v3.developer.homey.app/ManagerFlow.html) | `this.homey.flow` | Flow cards |
| [ManagerGeolocation](https://apps-sdk-v3.developer.homey.app/ManagerGeolocation.html) | `this.homey.geolocation` | Location services |
| [ManagerI18n](https://apps-sdk-v3.developer.homey.app/ManagerI18n.html) | `this.homey.i18n` | Internationalization |
| [ManagerImages](https://apps-sdk-v3.developer.homey.app/ManagerImages.html) | `this.homey.images` | Image handling |
| [ManagerInsights](https://apps-sdk-v3.developer.homey.app/ManagerInsights.html) | `this.homey.insights` | Insights/charts |
| [ManagerLedring](https://apps-sdk-v3.developer.homey.app/ManagerLedring.html) | `this.homey.ledring` | LED ring control |
| [ManagerNFC](https://apps-sdk-v3.developer.homey.app/ManagerNFC.html) | `this.homey.nfc` | NFC tags |
| [ManagerNotifications](https://apps-sdk-v3.developer.homey.app/ManagerNotifications.html) | `this.homey.notifications` | Push notifications |
| [ManagerRF](https://apps-sdk-v3.developer.homey.app/ManagerRF.html) | `this.homey.rf` | RF signals (433/868/IR) |
| [ManagerSettings](https://apps-sdk-v3.developer.homey.app/ManagerSettings.html) | `this.homey.settings` | App settings |
| [ManagerSpeechOutput](https://apps-sdk-v3.developer.homey.app/ManagerSpeechOutput.html) | `this.homey.speechOutput` | Text-to-speech |
| [ManagerVideos](https://apps-sdk-v3.developer.homey.app/ManagerVideos.html) | `this.homey.videos` | Video streams |
| [ManagerZigBee](https://apps-sdk-v3.developer.homey.app/ManagerZigBee.html) | `this.homey.zigbee` | Zigbee protocol |
| [ManagerZwave](https://apps-sdk-v3.developer.homey.app/ManagerZwave.html) | `this.homey.zwave` | Z-Wave protocol |

---

## Core Classes

### App & Device

| Class | Description |
|-------|-------------|
| [Homey](https://apps-sdk-v3.developer.homey.app/Homey.html) | Main Homey instance |
| [App](https://apps-sdk-v3.developer.homey.app/App.html) | Base app class |
| [Driver](https://apps-sdk-v3.developer.homey.app/Driver.html) | Base driver class |
| [Device](https://apps-sdk-v3.developer.homey.app/Device.html) | Base device class |
| [SimpleClass](https://apps-sdk-v3.developer.homey.app/SimpleClass.html) | Base class with logging |

### API

| Class | Description |
|-------|-------------|
| [Api](https://apps-sdk-v3.developer.homey.app/Api.html) | API client |
| [ApiApp](https://apps-sdk-v3.developer.homey.app/ApiApp.html) | App-to-app API |

### Flow

| Class | Description |
|-------|-------------|
| [FlowCard](https://apps-sdk-v3.developer.homey.app/FlowCard.html) | Base flow card |
| [FlowCardAction](https://apps-sdk-v3.developer.homey.app/FlowCardAction.html) | Action card (THEN) |
| [FlowCardCondition](https://apps-sdk-v3.developer.homey.app/FlowCardCondition.html) | Condition card (AND) |
| [FlowCardTrigger](https://apps-sdk-v3.developer.homey.app/FlowCardTrigger.html) | Trigger card (WHEN) |
| [FlowCardTriggerDevice](https://apps-sdk-v3.developer.homey.app/FlowCardTriggerDevice.html) | Device trigger card |
| [FlowArgument](https://apps-sdk-v3.developer.homey.app/FlowArgument.html) | Flow card argument |
| [FlowToken](https://apps-sdk-v3.developer.homey.app/FlowToken.html) | Flow token |

### Bluetooth LE

| Class | Description |
|-------|-------------|
| [BleAdvertisement](https://apps-sdk-v3.developer.homey.app/BleAdvertisement.html) | BLE advertisement |
| [BlePeripheral](https://apps-sdk-v3.developer.homey.app/BlePeripheral.html) | BLE peripheral device |
| [BleService](https://apps-sdk-v3.developer.homey.app/BleService.html) | BLE service |
| [BleCharacteristic](https://apps-sdk-v3.developer.homey.app/BleCharacteristic.html) | BLE characteristic |
| [BleDescriptor](https://apps-sdk-v3.developer.homey.app/BleDescriptor.html) | BLE descriptor |

### Discovery

| Class | Description |
|-------|-------------|
| [DiscoveryStrategy](https://apps-sdk-v3.developer.homey.app/DiscoveryStrategy.html) | Discovery strategy |
| [DiscoveryResult](https://apps-sdk-v3.developer.homey.app/DiscoveryResult.html) | Base discovery result |
| [DiscoveryResultMDNSSD](https://apps-sdk-v3.developer.homey.app/DiscoveryResultMDNSSD.html) | mDNS-SD result |
| [DiscoveryResultSSDP](https://apps-sdk-v3.developer.homey.app/DiscoveryResultSSDP.html) | SSDP result |
| [DiscoveryResultMAC](https://apps-sdk-v3.developer.homey.app/DiscoveryResultMAC.html) | MAC address result |

### Cloud

| Class | Description |
|-------|-------------|
| [CloudWebhook](https://apps-sdk-v3.developer.homey.app/CloudWebhook.html) | Webhook handler |
| [CloudOAuth2Callback](https://apps-sdk-v3.developer.homey.app/CloudOAuth2Callback.html) | OAuth2 callback |

### Signals (RF/IR)

| Class | Description |
|-------|-------------|
| [Signal](https://apps-sdk-v3.developer.homey.app/Signal.html) | Base signal class |
| [Signal433](https://apps-sdk-v3.developer.homey.app/Signal433.html) | 433 MHz signal |
| [Signal868](https://apps-sdk-v3.developer.homey.app/Signal868.html) | 868 MHz signal |
| [SignalInfrared](https://apps-sdk-v3.developer.homey.app/SignalInfrared.html) | Infrared signal |

### Media

| Class | Description |
|-------|-------------|
| [Image](https://apps-sdk-v3.developer.homey.app/Image.html) | Image handling |
| [Video](https://apps-sdk-v3.developer.homey.app/Video.html) | Base video class |
| [VideoDASH](https://apps-sdk-v3.developer.homey.app/VideoDASH.html) | DASH video stream |
| [VideoHLS](https://apps-sdk-v3.developer.homey.app/VideoHLS.html) | HLS video stream |
| [VideoRTMP](https://apps-sdk-v3.developer.homey.app/VideoRTMP.html) | RTMP video stream |
| [VideoRTSP](https://apps-sdk-v3.developer.homey.app/VideoRTSP.html) | RTSP video stream |
| [VideoWebRTC](https://apps-sdk-v3.developer.homey.app/VideoWebRTC.html) | WebRTC video stream |
| [VideoOther](https://apps-sdk-v3.developer.homey.app/VideoOther.html) | Other video types |
| [VideoWithURL](https://apps-sdk-v3.developer.homey.app/VideoWithURL.html) | URL-based video |

### LED Ring

| Class | Description |
|-------|-------------|
| [LedringAnimation](https://apps-sdk-v3.developer.homey.app/LedringAnimation.html) | LED animation |
| [LedringAnimationSystem](https://apps-sdk-v3.developer.homey.app/LedringAnimationSystem.html) | System animation |
| [LedringAnimationSystemProgress](https://apps-sdk-v3.developer.homey.app/LedringAnimationSystemProgress.html) | Progress animation |

### Insights

| Class | Description |
|-------|-------------|
| [InsightsLog](https://apps-sdk-v3.developer.homey.app/InsightsLog.html) | Insights log entry |

### Pairing

| Class | Description |
|-------|-------------|
| [PairSession](https://apps-sdk-v3.developer.homey.app/PairSession.html) | Pairing session |

### Wireless Protocols

| Class | Description |
|-------|-------------|
| [ZigBeeNode](https://apps-sdk-v3.developer.homey.app/ZigBeeNode.html) | Zigbee node |
| [ZwaveNode](https://apps-sdk-v3.developer.homey.app/ZwaveNode.html) | Z-Wave node |
| [ZwaveCommandClass](https://apps-sdk-v3.developer.homey.app/ZwaveCommandClass.html) | Z-Wave command class |

---

## Common Usage Examples

### Accessing Managers

```javascript
// In App, Driver, or Device class
async onInit() {
  // Settings
  const value = this.homey.settings.get('key');
  
  // Flow cards
  const action = this.homey.flow.getActionCard('my_action');
  
  // Images
  const image = await this.homey.images.createImage();
  
  // Cloud/Webhooks
  const webhook = await this.homey.cloud.createWebhook(id, secret, data);
  
  // Notifications
  await this.homey.notifications.createNotification({ excerpt: 'Hello!' });
  
  // BLE
  const ads = await this.homey.ble.discover();
  
  // RF Signals
  const signal = this.homey.rf.getSignal433('my-signal');
}
```

### Device Class Methods

```javascript
class MyDevice extends Homey.Device {
  // Lifecycle
  async onInit() { }
  async onAdded() { }
  async onSettings({ oldSettings, newSettings, changedKeys }) { }
  async onDeleted() { }
  
  // Capabilities
  this.registerCapabilityListener('onoff', handler);
  await this.setCapabilityValue('onoff', true);
  const value = this.getCapabilityValue('onoff');
  
  // Availability
  await this.setAvailable();
  await this.setUnavailable('Reason');
  
  // Store (persistent)
  await this.setStoreValue('key', value);
  const stored = this.getStoreValue('key');
  
  // Settings
  const setting = this.getSetting('key');
  await this.setSettings({ key: value });
  
  // Data (immutable)
  const data = this.getData();
}
```

# Homey Reference Apps & Libraries

This folder contains cloned GitHub repositories to serve as reference code for Homey app development.

## Official Athom Libraries

| Library | Folder | Description |
|---------|--------|-------------|
| Homey CLI | `node-homey/` | Command-line interface and TypeScript types |
| Z-Wave Driver | `node-homey-zwavedriver/` | Z-Wave CommandClass mapping to capabilities |
| Zigbee Driver | `node-homey-zigbeedriver/` | Zigbee cluster/endpoint mapping |
| RF Driver | `node-homey-rfdriver/` | 433 MHz / 868 MHz / IR signal handling |
| OAuth2 App | `node-homey-oauth2app/` | OAuth2 authentication helper |
| Homey Log | `node-homey-log/` | Sentry error logging integration |

## Official Athom Example Apps

| App | Folder | Protocol | Description |
|-----|--------|----------|-------------|
| HomeyScript | `com.athom.homeyscript/` | N/A | JavaScript scripting for Homey |
| Homeyduino | `com.athom.homeyduino/` | Wi-Fi | Arduino/ESP8266/ESP32 integration |
| IKEA Trådfri | `com.ikea.tradfri-example/` | Zigbee | Zigbee device example |
| KlikAanKlikUit | `nl.klikaanklikuit-example/` | 433 MHz | RF device example |
| KNX | `org.knx/` | KNX/IP | KNX protocol integration |

## Community Apps

| App | Folder | Protocol | Description |
|-----|--------|----------|-------------|
| Mi Homey (Xiaomi/Aqara) | `com.maxmudjon.mihomey/` | Zigbee/Wi-Fi | Xiaomi ecosystem devices |
| Broadlink | `com.broadlink/` | Wi-Fi/IR | Broadlink IR/RF devices |
| Samsung Smart TV | `com.samsung.smart/` | Wi-Fi | Samsung TV control |
| Netatmo Weather | `com.netatmo/` | Wi-Fi | Weather station integration |
| Tibber Energy | `com.tibber.athom/` | Wi-Fi | Energy monitoring & pricing |
| OpenTherm Gateway | `com.tclcode.otgw/` | Wi-Fi | Thermostat/boiler control |
| MQTT Hub | `nl.hdg.mqtt/` | Wi-Fi | MQTT device gateway |
| Dashboards | `homey.dashboards/` | N/A | Custom dashboard widgets |

## Script Collections

| Collection | Folder | Description |
|------------|--------|-------------|
| HomeyScripts | `HomeyScripts/` | Community HomeyScript snippets |

## Assets

| Resource | Folder | Description |
|----------|--------|-------------|
| Homey Vectors | `homey-vectors-public/` | Icon/vector assets for apps |

---

## Usage Examples by Protocol

### Zigbee
- `node-homey-zigbeedriver/` - Library documentation
- `com.ikea.tradfri-example/` - IKEA devices example
- `com.maxmudjon.mihomey/` - Xiaomi/Aqara devices

### Z-Wave
- `node-homey-zwavedriver/` - Library documentation

### Wi-Fi / HTTP
- `com.athom.homeyduino/` - Arduino/ESP devices
- `com.samsung.smart/` - HTTP API control
- `com.netatmo/` - OAuth2 + REST API
- `com.tibber.athom/` - GraphQL API

### 433 MHz RF
- `node-homey-rfdriver/` - Library documentation
- `nl.klikaanklikuit-example/` - RF switches

### OAuth2 Authentication
- `node-homey-oauth2app/` - Library documentation
- `com.netatmo/` - OAuth2 example

### Infrared (IR)
- `com.broadlink/` - IR learning and control

---

## Quick Start

1. Browse the relevant folder for your protocol/use case
2. Check `app.json` for manifest structure
3. Review `drivers/*/device.js` for capability handling
4. Look at `drivers/*/driver.js` for pairing logic

## Documentation

See the `../docs/` folder for complete SDK documentation.

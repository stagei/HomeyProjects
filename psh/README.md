# Homey Export Tool

Export all devices, flows, zones, apps, and configuration from your Homey devices.

## Prerequisites

1. **Node.js 18+** installed
2. **On the same network** as your Homey (for Local API)
3. **API Key** from your Homey

## How to Generate an API Key

1. Open the **Homey app** on your phone
2. Go to **Settings** (gear icon)
3. Scroll down to **API Keys**
4. Tap **Create API Key**
5. Give it a name (e.g., "Export Script")
6. Select permissions:
   - ✅ Devices (read)
   - ✅ Flows (read)
   - ✅ Zones (read)
   - ✅ Apps (read)
   - ✅ Logic (read)
   - ✅ Insights (read)
7. Copy the API key - you'll need it!

## Installation

```bash
cd homey-export
npm install
```

## Usage

### Interactive Mode

```bash
npm run export
```

Then follow the prompts to enter:
- Homey name (e.g., "Home" or "Cabin")
- Homey IP address
- API key

### Export Multiple Homeys

The script will ask if you want to export another Homey after each one.

## What Gets Exported

| Data | Description |
|------|-------------|
| **System Info** | Homey version, model, etc. |
| **Zones** | Room/zone structure |
| **Devices** | All devices with capabilities, settings |
| **Flows** | Standard flows with triggers/conditions/actions |
| **Advanced Flows** | Visual advanced flows |
| **Apps** | Installed apps and versions |
| **Variables** | Logic variables |
| **Insights** | Insight log definitions |

## Output

Exports are saved to `./exports/` folder as JSON files:
- `home_1705612800000.json`
- `cabin_1705612900000.json`

## Finding Your Homey's IP Address

1. Open the **Homey app**
2. Go to **Settings** → **General**
3. Look for **IP address** under network info

Or check your router's connected devices list.

## Troubleshooting

### "Connection refused" or timeout
- Verify IP address is correct
- Ensure you're on the same network as Homey
- Check if Homey is online

### "Invalid token" or authentication error
- Regenerate the API key
- Ensure the key has the required permissions

### "Permission denied"
- The API key needs read permissions for devices, flows, etc.

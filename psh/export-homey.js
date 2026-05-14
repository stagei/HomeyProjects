/**
 * Homey Export Script
 * 
 * Exports all devices, flows, zones, apps, and configuration from Homey
 * 
 * Usage:
 *   Cloud API:  node export-homey.js --cloud
 *   Local API:  node export-homey.js --local
 */

import { HomeyAPI } from 'homey-api';
import fs from 'fs/promises';
import path from 'path';
import { fileURLToPath } from 'url';
import readline from 'readline';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

// Helper to prompt for input
function prompt(question, hidden = false) {
  return new Promise((resolve) => {
    const rl = readline.createInterface({
      input: process.stdin,
      output: process.stdout
    });
    
    if (hidden) {
      // For password input - still shows but marks as sensitive
      process.stdout.write(question);
      let input = '';
      process.stdin.setRawMode(true);
      process.stdin.resume();
      process.stdin.on('data', (char) => {
        char = char.toString();
        if (char === '\n' || char === '\r') {
          process.stdin.setRawMode(false);
          process.stdout.write('\n');
          rl.close();
          resolve(input);
        } else if (char === '\u0003') {
          process.exit();
        } else if (char === '\u007F') {
          input = input.slice(0, -1);
          process.stdout.clearLine();
          process.stdout.cursorTo(0);
          process.stdout.write(question + '*'.repeat(input.length));
        } else {
          input += char;
          process.stdout.write('*');
        }
      });
    } else {
      rl.question(question, (answer) => {
        rl.close();
        resolve(answer);
      });
    }
  });
}

// Simple prompt for non-hidden input
function simplePrompt(question) {
  return new Promise((resolve) => {
    const rl = readline.createInterface({
      input: process.stdin,
      output: process.stdout
    });
    rl.question(question, (answer) => {
      rl.close();
      resolve(answer);
    });
  });
}

// Export data from a single Homey
async function exportHomey(api, homeyName) {
  console.log(`\n📦 Exporting data from: ${homeyName}`);
  
  const exportData = {
    exportedAt: new Date().toISOString(),
    homeyName: homeyName,
    system: null,
    zones: null,
    devices: null,
    flows: null,
    advancedFlows: null,
    apps: null,
    variables: null,
    insights: null
  };

  try {
    // System info
    console.log('  ➤ Fetching system info...');
    try {
      exportData.system = await api.system.getInfo();
    } catch (e) {
      console.log('    (system info not available)');
    }

    // Zones
    console.log('  ➤ Fetching zones...');
    try {
      exportData.zones = await api.zones.getZones();
    } catch (e) {
      console.log('    (zones not available)');
    }

    // Devices
    console.log('  ➤ Fetching devices...');
    try {
      const devices = await api.devices.getDevices();
      exportData.devices = {};
      for (const [id, device] of Object.entries(devices)) {
        exportData.devices[id] = {
          id: device.id,
          name: device.name,
          driverUri: device.driverUri,
          driverId: device.driverId,
          zone: device.zone,
          class: device.class,
          capabilities: device.capabilities,
          capabilitiesObj: device.capabilitiesObj,
          settings: device.settings,
          data: device.data,
          ready: device.ready,
          available: device.available,
          unavailableMessage: device.unavailableMessage,
          energy: device.energy,
          energyObj: device.energyObj
        };
      }
      console.log(`    Found ${Object.keys(exportData.devices).length} devices`);
    } catch (e) {
      console.log('    (devices not available)', e.message);
    }

    // Flows
    console.log('  ➤ Fetching flows...');
    try {
      exportData.flows = await api.flow.getFlows();
      console.log(`    Found ${Object.keys(exportData.flows).length} flows`);
    } catch (e) {
      console.log('    (flows not available)');
    }

    // Advanced Flows
    console.log('  ➤ Fetching advanced flows...');
    try {
      exportData.advancedFlows = await api.flow.getAdvancedFlows();
      console.log(`    Found ${Object.keys(exportData.advancedFlows || {}).length} advanced flows`);
    } catch (e) {
      console.log('    (advanced flows not available)');
    }

    // Apps
    console.log('  ➤ Fetching installed apps...');
    try {
      const apps = await api.apps.getApps();
      exportData.apps = {};
      for (const [id, app] of Object.entries(apps)) {
        exportData.apps[id] = {
          id: app.id,
          name: app.name,
          version: app.version,
          enabled: app.enabled,
          origin: app.origin,
          channel: app.channel,
          autoupdate: app.autoupdate
        };
      }
      console.log(`    Found ${Object.keys(exportData.apps).length} apps`);
    } catch (e) {
      console.log('    (apps not available)');
    }

    // Variables (Logic)
    console.log('  ➤ Fetching variables...');
    try {
      exportData.variables = await api.logic.getVariables();
      console.log(`    Found ${Object.keys(exportData.variables || {}).length} variables`);
    } catch (e) {
      console.log('    (variables not available)');
    }

    // Insights logs (just the list, not historical data)
    console.log('  ➤ Fetching insights logs...');
    try {
      exportData.insights = await api.insights.getLogs();
      console.log(`    Found ${Object.keys(exportData.insights || {}).length} insight logs`);
    } catch (e) {
      console.log('    (insights not available)');
    }

  } catch (error) {
    console.error('Error during export:', error.message);
  }

  return exportData;
}

// Save export to file
async function saveExport(data, filename) {
  const outputPath = path.join(__dirname, 'exports', filename);
  await fs.mkdir(path.join(__dirname, 'exports'), { recursive: true });
  await fs.writeFile(outputPath, JSON.stringify(data, null, 2));
  console.log(`\n✅ Saved to: ${outputPath}`);
  return outputPath;
}

// Cloud API flow
async function cloudExport() {
  console.log('\n🌐 CLOUD API EXPORT');
  console.log('='.repeat(50));
  console.log('This method uses your Athom account to access Homey remotely.\n');
  
  // Get credentials
  const email = await simplePrompt('Enter your Athom account email: ');
  const password = await simplePrompt('Enter your password: ');
  
  console.log('\n🔐 Authenticating with Athom Cloud...');
  
  try {
    // Create cloud API instance
    const api = await HomeyAPI.createCloudAPI({
      clientId: process.env.HOMEY_CLIENT_ID || 'homey-export-script',
      clientSecret: process.env.HOMEY_CLIENT_SECRET || '',
      // OAuth flow would be needed here - this is simplified
    });
    
    // Get list of Homeys
    const homeys = await api.getHomeys();
    
    console.log(`\nFound ${homeys.length} Homey device(s):\n`);
    homeys.forEach((h, i) => {
      console.log(`  ${i + 1}. ${h.name} (${h.id})`);
    });
    
    // Export each Homey
    for (const homey of homeys) {
      console.log(`\nConnecting to ${homey.name}...`);
      const homeyApi = await homey.authenticate();
      const data = await exportHomey(homeyApi, homey.name);
      
      const filename = `${homey.name.replace(/[^a-z0-9]/gi, '_').toLowerCase()}_${Date.now()}.json`;
      await saveExport(data, filename);
    }
    
  } catch (error) {
    console.error('\n❌ Cloud API error:', error.message);
    console.log('\nNote: Cloud API requires OAuth2 client registration.');
    console.log('For simpler access, try the Local API method with --local');
  }
}

// Local API flow  
async function localExport() {
  console.log('\n🏠 LOCAL API EXPORT');
  console.log('='.repeat(50));
  console.log('This method connects directly to your Homey on the local network.\n');
  console.log('Prerequisites:');
  console.log('  1. Be on the same network as your Homey');
  console.log('  2. Generate an API key in Homey app → Settings → API Keys\n');
  
  const exportAll = async () => {
    let continueExporting = true;
    
    while (continueExporting) {
      const homeyName = await simplePrompt('Enter a name for this Homey (e.g., "Home" or "Cabin"): ');
      const homeyIp = await simplePrompt('Enter Homey IP address (e.g., 192.168.1.100): ');
      const apiKey = await simplePrompt('Enter API Key: ');
      
      console.log(`\n🔐 Connecting to ${homeyName} at ${homeyIp}...`);
      
      try {
        const api = await HomeyAPI.createLocalAPI({
          address: `http://${homeyIp}`,
          token: apiKey,
        });
        
        console.log('✅ Connected successfully!');
        
        const data = await exportHomey(api, homeyName);
        
        const filename = `${homeyName.replace(/[^a-z0-9]/gi, '_').toLowerCase()}_${Date.now()}.json`;
        await saveExport(data, filename);
        
      } catch (error) {
        console.error('\n❌ Connection error:', error.message);
        console.log('\nTroubleshooting:');
        console.log('  - Verify IP address is correct');
        console.log('  - Ensure API key has correct permissions');
        console.log('  - Check you are on the same network as Homey');
      }
      
      const another = await simplePrompt('\nExport another Homey? (y/n): ');
      continueExporting = another.toLowerCase() === 'y';
    }
  };
  
  await exportAll();
}

// Main
async function main() {
  console.log('╔════════════════════════════════════════════╗');
  console.log('║        HOMEY EXPORT TOOL v1.0.0            ║');
  console.log('╚════════════════════════════════════════════╝');
  
  const args = process.argv.slice(2);
  
  if (args.includes('--cloud')) {
    await cloudExport();
  } else if (args.includes('--local')) {
    await localExport();
  } else {
    console.log('\nSelect export method:');
    console.log('  1. Local API (recommended - requires IP + API key)');
    console.log('  2. Cloud API (requires OAuth2 setup)');
    
    const choice = await simplePrompt('\nEnter choice (1 or 2): ');
    
    if (choice === '2') {
      await cloudExport();
    } else {
      await localExport();
    }
  }
  
  console.log('\n🎉 Export complete!');
  console.log('Check the ./exports folder for your data.\n');
}

main().catch(console.error);

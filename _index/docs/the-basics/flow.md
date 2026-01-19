# Flow Cards

> Source: https://apps.developer.homey.app/the-basics/flow

## Overview

Flow is Homey's automation system. Apps can add custom triggers, conditions, and actions.

## Flow Card Types

| Type | When Column | Description |
|------|-------------|-------------|
| **Trigger** | WHEN | Starts a flow when something happens |
| **Condition** | AND | Checks if something is true |
| **Action** | THEN | Performs an action |

## Defining Flow Cards

In `app.json` or `.homeycompose/flow/`:

```json
{
  "flow": {
    "triggers": [
      {
        "id": "device_status_changed",
        "title": { "en": "Device status changed" },
        "tokens": [
          {
            "name": "status",
            "type": "string",
            "title": { "en": "Status" }
          }
        ]
      }
    ],
    "conditions": [
      {
        "id": "is_status",
        "title": { "en": "Status is..." },
        "titleFormatted": { "en": "Status is [[status]]" },
        "args": [
          {
            "name": "status",
            "type": "dropdown",
            "values": [
              { "id": "online", "title": { "en": "Online" } },
              { "id": "offline", "title": { "en": "Offline" } }
            ]
          }
        ]
      }
    ],
    "actions": [
      {
        "id": "set_status",
        "title": { "en": "Set status" },
        "titleFormatted": { "en": "Set status to [[status]]" },
        "args": [
          {
            "name": "status",
            "type": "text",
            "placeholder": { "en": "Status..." }
          }
        ]
      }
    ]
  }
}
```

## Registering Flow Cards in Code

### Triggers

```javascript
// In app.js
async onInit() {
  // Get the trigger card
  this.deviceStatusTrigger = this.homey.flow.getDeviceTriggerCard('device_status_changed');
}

// Trigger it when something happens
triggerStatusChanged(device, status) {
  const tokens = { status };
  this.deviceStatusTrigger.trigger(device, tokens)
    .catch(this.error);
}
```

### Conditions

```javascript
// In app.js
async onInit() {
  const conditionCard = this.homey.flow.getConditionCard('is_status');
  
  conditionCard.registerRunListener(async (args, state) => {
    // Return true or false
    return args.device.getData().status === args.status;
  });
}
```

### Actions

```javascript
// In app.js
async onInit() {
  const actionCard = this.homey.flow.getActionCard('set_status');
  
  actionCard.registerRunListener(async (args, state) => {
    // Perform the action
    await args.device.setStatus(args.status);
  });
}
```

## Flow Card Arguments

| Type | Description |
|------|-------------|
| `text` | Text input |
| `number` | Number input |
| `dropdown` | Select from predefined values |
| `autocomplete` | Search and select |
| `device` | Device picker |
| `date` | Date picker |
| `time` | Time picker |
| `color` | Color picker |

### Autocomplete Example

```javascript
const actionCard = this.homey.flow.getActionCard('play_song');

actionCard.registerArgumentAutocompleteListener('song', async (query, args) => {
  const songs = await this.getSongs();
  
  return songs
    .filter(song => song.name.toLowerCase().includes(query.toLowerCase()))
    .map(song => ({
      id: song.id,
      name: song.name,
      image: song.artwork
    }));
});
```

## Tokens

Tokens pass data from triggers to conditions and actions:

```json
{
  "tokens": [
    {
      "name": "temperature",
      "type": "number",
      "title": { "en": "Temperature" },
      "example": 21.5
    }
  ]
}
```

## Device Flow Cards

For device-specific flow cards, use `getDeviceTriggerCard()`:

```javascript
// In driver.js
async onInit() {
  this.deviceTrigger = this.homey.flow.getDeviceTriggerCard('my_trigger');
  
  this.deviceTrigger.registerRunListener(async (args, state) => {
    // args.device is the selected device
    return true;
  });
}
```

## Best Practices

1. **Clear titles** - Use descriptive, natural language titles
2. **Formatted titles** - Use `titleFormatted` with `[[arg]]` placeholders
3. **Provide examples** - Add examples for token values
4. **Validate args** - Validate arguments in run listeners
5. **Handle errors** - Throw user-friendly errors

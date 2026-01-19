# Flow Card Arguments

> Source: https://apps.developer.homey.app/the-basics/flow/arguments

## Overview

Arguments allow users to customize Flow cards with input values.

## Argument Types

### Text

```json
{
  "name": "message",
  "type": "text",
  "title": { "en": "Message" },
  "placeholder": { "en": "Enter a message..." }
}
```

### Number

```json
{
  "name": "level",
  "type": "number",
  "title": { "en": "Level" },
  "min": 0,
  "max": 100,
  "step": 1
}
```

### Range

```json
{
  "name": "brightness",
  "type": "range",
  "title": { "en": "Brightness" },
  "min": 0,
  "max": 100,
  "step": 5,
  "label": "%",
  "labelMultiplier": 1
}
```

### Dropdown

```json
{
  "name": "mode",
  "type": "dropdown",
  "title": { "en": "Mode" },
  "values": [
    { "id": "auto", "title": { "en": "Automatic" } },
    { "id": "manual", "title": { "en": "Manual" } },
    { "id": "off", "title": { "en": "Off" } }
  ]
}
```

### Autocomplete

```json
{
  "name": "song",
  "type": "autocomplete",
  "title": { "en": "Song" },
  "placeholder": { "en": "Search for a song..." }
}
```

Register autocomplete handler:

```javascript
async onInit() {
  const action = this.homey.flow.getActionCard('play_song');
  
  action.registerArgumentAutocompleteListener('song', async (query) => {
    const songs = await this.searchSongs(query);
    
    return songs.map(song => ({
      id: song.id,
      name: song.title,
      description: song.artist,
      image: song.albumArt
    }));
  });
}
```

### Device

```json
{
  "name": "device",
  "type": "device",
  "filter": "driver_id=my-driver"
}
```

Filter options:
- `driver_id=<id>` - Specific driver
- `capabilities=onoff` - Has capability
- `capabilities=onoff&capabilities=dim` - Multiple capabilities

### Date

```json
{
  "name": "date",
  "type": "date",
  "title": { "en": "Date" }
}
```

### Time

```json
{
  "name": "time",
  "type": "time",
  "title": { "en": "Time" }
}
```

### Color

```json
{
  "name": "color",
  "type": "color",
  "title": { "en": "Color" }
}
```

### Checkbox

```json
{
  "name": "notify",
  "type": "checkbox",
  "title": { "en": "Send notification" },
  "value": true
}
```

## Required vs Optional

```json
{
  "name": "optional_param",
  "type": "text",
  "title": { "en": "Optional" },
  "required": false
}
```

Default is `required: true`.

## Accessing Arguments

```javascript
async onInit() {
  const action = this.homey.flow.getActionCard('my_action');
  
  action.registerRunListener(async (args) => {
    const { device, level, mode, message } = args;
    
    // Use the arguments
    await device.setLevel(level);
    
    if (message) {
      await this.sendNotification(message);
    }
  });
}
```

## Dynamic Values

For dropdown with dynamic values:

```json
{
  "name": "zone",
  "type": "autocomplete"
}
```

```javascript
action.registerArgumentAutocompleteListener('zone', async (query) => {
  const zones = await this.getZones();
  
  return zones
    .filter(z => z.name.toLowerCase().includes(query.toLowerCase()))
    .map(zone => ({
      id: zone.id,
      name: zone.name
    }));
});
```

## Title Formatting

Use `titleFormatted` with argument placeholders:

```json
{
  "id": "set_brightness",
  "title": { "en": "Set brightness" },
  "titleFormatted": { "en": "Set brightness to [[level]]%" },
  "args": [
    {
      "name": "level",
      "type": "range",
      "min": 0,
      "max": 100
    }
  ]
}
```

## Best Practices

1. **Clear titles** - Descriptive, translated
2. **Placeholders** - Guide user input
3. **Validation** - Set min/max/step where applicable
4. **Defaults** - Provide sensible default values
5. **Required wisely** - Only mark truly required args

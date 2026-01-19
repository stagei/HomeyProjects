# Updating Apps

> Source: https://apps.developer.homey.app/app-store/updating

## Overview

Regular updates keep your app working well and users happy.

## Version Numbering

Use semantic versioning: `MAJOR.MINOR.PATCH`

| Change Type | Version Part | Example |
|-------------|--------------|---------|
| Bug fixes | PATCH | 1.0.0 → 1.0.1 |
| New features | MINOR | 1.0.0 → 1.1.0 |
| Breaking changes | MAJOR | 1.0.0 → 2.0.0 |

```bash
homey app version patch
homey app version minor
homey app version major
```

## Update Process

### 1. Make Changes

```bash
# Develop and test
homey app run
```

### 2. Update Version

```bash
homey app version patch
```

### 3. Update Changelog

Document changes in your app description or README.

### 4. Validate

```bash
homey app validate --level publish
```

### 5. Publish

```bash
homey app publish
```

## Automatic Updates

Users receive updates automatically by default. Consider:

- **Breaking changes** - Users may need to reconfigure
- **Migration** - Handle data migration if needed
- **Communication** - Document changes clearly

## Migration Handling

When data structures change:

```javascript
async onInit() {
  // Check for migration
  const schemaVersion = this.homey.settings.get('schemaVersion') || 1;
  
  if (schemaVersion < 2) {
    await this.migrateToV2();
    this.homey.settings.set('schemaVersion', 2);
  }
}

async migrateToV2() {
  // Migrate old data to new format
  const oldData = this.homey.settings.get('oldKey');
  if (oldData) {
    this.homey.settings.set('newKey', this.transformData(oldData));
    this.homey.settings.unset('oldKey');
  }
}
```

## Device Migration

When device data changes:

```javascript
class MyDevice extends Homey.Device {
  
  async onInit() {
    // Migrate device store
    const storeVersion = this.getStoreValue('version') || 1;
    
    if (storeVersion < 2) {
      await this.migrateDevice();
      await this.setStoreValue('version', 2);
    }
  }
  
  async migrateDevice() {
    // Handle device-specific migration
  }
}
```

## Changelog Best Practices

- List all notable changes
- Group by type (Added, Changed, Fixed, Removed)
- Keep it user-friendly
- Include version and date

Example:

```markdown
## 1.2.0 - 2024-01-15
### Added
- Support for new device model
- Flow action for custom commands

### Fixed
- Connection timeout issue
- Incorrect power readings

### Changed
- Improved pairing process
```

## Best Practices

1. **Test thoroughly** - Before publishing updates
2. **Incremental updates** - Small, frequent updates
3. **Backwards compatible** - Avoid breaking changes
4. **Communicate changes** - Clear changelogs
5. **Monitor feedback** - Watch for issues after updates

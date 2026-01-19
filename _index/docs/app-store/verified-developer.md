# Verified Developer

> Source: https://apps.developer.homey.app/app-store/verified-developer

## Overview

Verified Developers have additional privileges and a verification badge on their apps.

## Benefits

| Benefit | Description |
|---------|-------------|
| Badge | Verification badge on your apps |
| Homey Cloud | Can publish apps to Homey Cloud |
| Priority Review | Faster app review times |
| Support | Direct access to developer support |

## Requirements

### For Brand Partners

If you're the official developer for a brand:

1. Represent a recognized brand
2. Provide proof of brand ownership/authorization
3. Maintain quality standards

### For Community Developers

1. **Active Subscription** - Athom Developer subscription
2. **Quality Track Record** - History of quality apps
3. **Responsive Support** - Active support for your apps
4. **Community Standing** - Positive community engagement

## Application Process

1. **Apply** - Submit application through developer portal
2. **Verification** - Athom verifies your credentials
3. **Approval** - Receive verified status
4. **Maintain** - Keep meeting requirements

## Homey Cloud Publishing

Only Verified Developers can publish to Homey Cloud.

### Cloud Requirements

Apps for Homey Cloud must:

- Not use `homey:manager:api` permission
- Not use wireless protocols (Z-Wave, Zigbee, etc.)
- Not use Web API or Widgets
- Work within Cloud limitations

### Multi-Platform Apps

```json
{
  "platforms": ["local", "cloud"]
}
```

## Verification Badge

Verified apps display a badge indicating:
- Trusted developer
- Quality standards met
- Regular updates and support

## Maintaining Status

To keep verified status:

1. Keep apps updated
2. Respond to user issues
3. Follow guidelines
4. Maintain subscription

## Revocation

Verified status may be revoked for:

- Abandoned apps
- Policy violations
- Quality issues
- Unresponsive support

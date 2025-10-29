# Multi-Platform TestFlight Deployment Guide

This guide covers deploying all 5 Field of Truth apps to TestFlight across all supported platforms (iOS, macOS, watchOS, visionOS).

## Overview

The multi-platform deployment system automatically:
- Detects available platforms for each app
- Archives each app for each supported platform
- Signs with proper code signing certificates
- Uploads directly to TestFlight
- Provides comprehensive logging and error reporting

## Prerequisites

1. **Apple Developer Account** - Active membership required
2. **App Store Connect API Key** - Generated with "App Manager" access
3. **Xcode Command Line Tools** - Installed and updated
4. **All Apps Registered** - Apps must exist in App Store Connect

### Platform Matrix

| App | iOS | macOS | watchOS | visionOS |
|-----|-----|-------|---------|----------|
| PersonalHealthApp | ✅ | ✅ | ❌ | ❌ |
| ClinicianApp | ✅ | ✅ | ✅ | ❌ |
| ParentApp | ✅ | ❌ | ❌ | ❌ |
| EducationApp | ✅ | ❌ | ❌ | ❌ |
| LegalApp | ✅ | ❌ | ❌ | ❌ |

*Note: Platform availability is configured in `scripts/app_platform_matrix.json`*

## Quick Start

### 1. Verify Setup

Run the diagnostic script to verify your configuration:

```bash
./scripts/diagnose.sh
```

This will check:
- API credentials
- Key file location
- Platform matrix configuration
- App directories
- Xcode tools

### 2. Deploy All Apps/Platforms

To deploy everything at once:

```bash
./scripts/deploy_all_platforms_testflight.sh
```

This will:
- Process all 5 apps
- For each app, deploy all available platforms
- Auto-increment build numbers
- Upload directly to TestFlight
- Generate detailed logs

### 3. Deploy Single App/Platform

To deploy one specific combination:

```bash
./scripts/deploy_single_app_platform.sh PersonalHealthApp iOS
./scripts/deploy_single_app_platform.sh ClinicianApp macOS
./scripts/deploy_single_app_platform.sh ClinicianApp watchOS
```

## Configuration

### API Credentials

Set environment variables:

```bash
export APP_STORE_API_KEY_ID="43BGN9JC5B"
export APP_STORE_API_ISSUER_ID="69a6de92-4ce0-47e3-e053-5b8c7c11a4d1"
```

Or edit `scripts/deploy_all_platforms_testflight.sh` to hardcode them.

### Platform Matrix

The platform matrix (`scripts/app_platform_matrix.json`) defines:
- Available platforms for each app
- Scheme names per platform
- Bundle IDs per platform
- Directory structure

Example entry:

```json
{
  "PersonalHealthApp": {
    "schemes": {
      "iOS": "PersonalHealthApp",
      "macOS": "PersonalHealthMac"
    },
    "bundleIds": {
      "iOS": "com.fot.PersonalHealth",
      "macOS": "com.fot.PersonalHealthMac"
    },
    "platforms": ["iOS", "macOS"],
    "directory": "PersonalHealthApp"
  }
}
```

## Deployment Process

### Step 1: Validation
- Verifies API credentials
- Checks for key file
- Validates platform matrix
- Confirms app directories exist

### Step 2: Archive
For each app/platform combination:
- Auto-increments build number (CFBundleVersion)
- Cleans previous builds
- Creates archive (.xcarchive)
- Signs with automatic provisioning

### Step 3: Export & Upload
- Generates platform-specific ExportOptions.plist
- Exports signed IPA
- Uploads directly to TestFlight
- Retries up to 3 times on failure

### Step 4: Reporting
- Success/failure summary
- Deployment logs location
- Next steps guidance

## Platform-Specific Notes

### iOS
- Standard App Store deployment
- Automatic provisioning profiles
- All 5 apps support iOS

### macOS
- Uses same signing flow as iOS
- Requires separate Bundle ID (e.g., `com.fot.PersonalHealthMac`)
- Currently: PersonalHealthApp, ClinicianApp

### watchOS
- Deployed as companion to iOS app
- Requires iOS app to exist in App Store Connect
- Bundle ID pattern: `com.fot.{AppName}Watch`
- Currently: ClinicianApp only

### visionOS
- Similar signing to iOS
- SDK: `xros`
- Currently: Not implemented for any apps

## Logs and Troubleshooting

### Log Locations

All logs are stored in `build/logs/`:
- `{App}_{Platform}_archive.log` - Archive creation logs
- `{App}_{Platform}_export.log` - Export and upload logs

### Common Issues

**Issue: "No provisioning profile found"**
- Solution: Ensure app is registered in App Store Connect
- Check: Bundle ID matches App Store Connect

**Issue: "Archive failed"**
- Check: `build/logs/{App}_{Platform}_archive.log`
- Common causes: Build errors, missing dependencies, code signing issues

**Issue: "Upload failed"**
- Check: `build/logs/{App}_{Platform}_export.log`
- Verify: Internet connection, API credentials, App Store Connect status

**Issue: "Platform not available"**
- Check: Platform directory exists in `apps/{App}/{Platform}/`
- Verify: Platform is listed in `app_platform_matrix.json`

### Diagnostic Tools

Run comprehensive diagnostics:

```bash
./scripts/diagnose.sh
```

This checks:
- Xcode installation
- API credentials
- Key file location
- Platform matrix
- App directories
- Network connectivity

## Build Number Management

All build numbers auto-increment during deployment:
- CFBundleVersion increments by 1
- Version number (CFBundleShortVersionString) remains unchanged
- Build numbers are per-platform

To manually set build numbers, edit `Info.plist` before deployment.

## TestFlight Integration

After successful upload:
1. Builds appear in App Store Connect within 5-15 minutes
2. Processing typically takes 5-15 minutes
3. Once processed, add builds to test groups:
   - App Store Connect → TestFlight → Select App → Testing
   - Click (+) to add new builds
   - Testers receive automatic notifications

## Automation

### CI/CD Integration

The deployment scripts are designed for automation:

```yaml
# GitHub Actions example
- name: Deploy to TestFlight
  env:
    APP_STORE_API_KEY_ID: ${{ secrets.KEY_ID }}
    APP_STORE_API_ISSUER_ID: ${{ secrets.ISSUER_ID }}
  run: ./scripts/deploy_all_platforms_testflight.sh
```

### Scheduled Deployments

Use cron or launchd for scheduled deployments:

```bash
# Daily at 2 AM
0 2 * * * cd /path/to/project && ./scripts/deploy_all_platforms_testflight.sh
```

## Best Practices

1. **Test First** - Deploy single app/platform before full deployment
2. **Monitor Logs** - Check logs after each deployment
3. **Version Management** - Manually update version numbers for releases
4. **Incremental Deployment** - Deploy one platform at a time if issues occur
5. **Regular Diagnostics** - Run `diagnose.sh` before major deployments

## Scripts Reference

| Script | Purpose |
|--------|---------|
| `deploy_all_platforms_testflight.sh` | Deploy all apps × all platforms |
| `deploy_single_app_platform.sh` | Deploy one app for one platform |
| `diagnose.sh` | Validate configuration |
| `platform_helpers.sh` | Platform-specific functions (sourced) |
| `app_platform_matrix.json` | Platform configuration |

## Support

For issues or questions:
1. Run `./scripts/diagnose.sh` to identify problems
2. Check logs in `build/logs/`
3. Review platform matrix configuration
4. Verify App Store Connect app records

## Related Documentation

- [QUICK_START.md](QUICK_START.md) - Quick reference
- [SETUP_GUIDE.md](SETUP_GUIDE.md) - Detailed setup instructions
- [CLAUDE_README.md](CLAUDE_README.md) - Original iOS deployment docs


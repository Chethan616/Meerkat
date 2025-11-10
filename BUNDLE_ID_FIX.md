# macOS Bundle Identifier Fix

## Problem
Codemagic build was failing with:
```
error: Embedded binary's bundle identifier is not prefixed with the parent app's bundle identifier.
    Embedded Binary Bundle Identifier:	com.chethan616.meerkat.ShareExtension
    Parent App Bundle Identifier:		org.localsend.localsendApp
```

## Root Cause
The **AppInfo.xcconfig** file (located at `app/macos/Runner/Configs/AppInfo.xcconfig`) still contained the old LocalSend bundle identifier:
- `PRODUCT_BUNDLE_IDENTIFIER = org.localsend.localsendApp`

This file is the **root configuration** for the macOS main app and controls:
- Product Name
- Bundle Identifier
- Copyright text

The Xcode project references this file via `baseConfigurationReference`, and `Info.plist` uses these values through variables like `$(PRODUCT_BUNDLE_IDENTIFIER)`.

## Solution Applied
Updated `app/macos/Runner/Configs/AppInfo.xcconfig`:

```xcconfig
// Configuration settings file format documentation can be found at:
// https://help.apple.com/xcode/#/dev745c5c974

// Application name
PRODUCT_NAME = Meerkat

// This identifier is used as a prefix for the bundle identifier
PRODUCT_BUNDLE_IDENTIFIER = com.chethan616.meerkat

PRODUCT_COPYRIGHT = Copyright © 2025 Chethan Krishna. Based on LocalSend by Tien Do Nam.
```

### Changes:
1. ✅ `PRODUCT_NAME`: "LocalSend" → "Meerkat"
2. ✅ `PRODUCT_BUNDLE_IDENTIFIER`: "org.localsend.localsendApp" → "com.chethan616.meerkat"
3. ✅ `PRODUCT_COPYRIGHT`: Updated with proper attribution

## Bundle ID Hierarchy (Now Fixed)
- **Main App**: `com.chethan616.meerkat` ✅
- **ShareExtension**: `com.chethan616.meerkat.ShareExtension` ✅

✅ **Parent prefix correctly matches extension prefix** (Apple requirement satisfied)

## How It Works
```
AppInfo.xcconfig (sets variables)
    ↓
Runner.xcodeproj (references via baseConfigurationReference)
    ↓
Info.plist (uses $(PRODUCT_BUNDLE_IDENTIFIER))
    ↓
Final Bundle ID = com.chethan616.meerkat
```

## Verification Steps
1. ✅ Committed changes to git (commit: eae1077)
2. 🔄 **Next**: Push to GitHub and trigger Codemagic macOS build
3. 🔄 **Verify**: Build succeeds without bundle ID mismatch error
4. 🔄 **Check**: Both .app and .dmg artifacts created successfully

## Additional Context
- **No Apple Developer Account**: Building unsigned for testing
- **Code Signing**: Manual mode with `CODE_SIGN_IDENTITY = "-"`
- **Team ID**: LocalSend's 3W7H4PYMCV completely removed
- **Distribution**: Users will see "unidentified developer" warning (expected)

## Files Modified
- ✅ `app/macos/Runner/Configs/AppInfo.xcconfig`

## Related Configurations (Already Complete)
- ✅ `app/macos/Runner.xcodeproj/project.pbxproj` - ShareExtension bundle ID updated
- ✅ `app/macos/Runner/Info.plist` - Uses variables from AppInfo.xcconfig
- ✅ `app/macos/ShareExtension/Info.plist` - Display name updated
- ✅ `app/macos/ShareExtension/ShareExtension.entitlements` - App group updated
- ✅ All Xcode configurations - Team ID removed, signing disabled

## Expected Outcome
The next Codemagic macOS build should:
1. ✅ Successfully build the main Runner app with bundle ID `com.chethan616.meerkat`
2. ✅ Successfully embed the ShareExtension with bundle ID `com.chethan616.meerkat.ShareExtension`
3. ✅ Pass Apple's bundle ID prefix validation
4. ✅ Generate both .app and .dmg artifacts

---

**Status**: Fix applied and committed. Ready for Codemagic testing.

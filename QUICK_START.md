# Quick Start Guide - DharaiDeliveryBoy

## Installation & Setup

### 1. Navigate to Project Directory
```bash
cd /Users/satheeshkumar/.gemini/antigravity/scratch/dharai_delivery_boy
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Check Available Devices
```bash
flutter devices
```

### 4. Run the App

#### On iOS Simulator
```bash
flutter run -d iPhone
```

#### On Android Emulator
```bash
# First, list emulators
flutter emulators

# Launch an emulator
flutter emulators --launch <emulator_id>

# Run the app
flutter run
```

#### On macOS Desktop
```bash
flutter run -d macos
```

#### On Chrome (Web)
```bash
flutter run -d chrome
```

## Quick Test

Once the app launches:

1. **Splash Screen** (3 seconds)
   - Red screen with delivery icon
   - Automatically navigates to login

2. **Login**
   - Enter any username: `test` or `Karrywood11023`
   - Enter any password: `password`
   - Check "Remember Me" if you want
   - Click "Login"

3. **Home Screen**
   - You'll see 3 demo orders
   - Try these actions:
     - Click "Details" on any order
     - Click "Show Map" on OnTheWay order
     - Click "Confirm" to change OnTheWay → Upcoming
     - Click "Deliver" to mark Upcoming as Delivered
     - Click "Cancel" to cancel an order

4. **Order Details**
   - View complete order information
   - Click phone icon to call (opens dialer)
   - Click "Open in Maps" (opens Google Maps)
   - Go back to home

5. **Logout**
   - Open drawer (menu icon top-left)
   - Click "Logout"

## Build Production APK

```bash
flutter build apk --release
```

The APK will be at:
```
build/app/outputs/flutter-apk/app-release.apk
```

## Build iOS IPA

```bash
flutter build ios --release
```

## Recommend Setting Workspace

After testing, you may want to set this as your active workspace in your IDE:

```
/Users/satheeshkumar/.gemini/antigravity/scratch/dharai_delivery_boy
```

## Troubleshooting

### Issue: "No devices found"
```bash
# For iOS
open -a Simulator

# For Android
flutter emulators --launch Pixel_6_API_34
```

### Issue: "Dependencies not found"
```bash
flutter clean
flutter pub get
```

### Issue: "Build failed"
```bash
flutter doctor
# Fix any reported issues
```

## Project Files Summary

```
✅ lib/main.dart                          - App entry point
✅ lib/models/delivery_boy_model.dart     - Delivery boy model
✅ lib/models/order_model.dart            - Order model
✅ lib/providers/auth_provider.dart       - Auth state
✅ lib/providers/order_provider.dart      - Order state
✅ lib/screens/splash_screen.dart         - Splash screen
✅ lib/screens/login_screen.dart          - Login screen
✅ lib/screens/home_screen.dart           - Home/Dashboard
✅ lib/screens/order_details_screen.dart  - Order details
✅ pubspec.yaml                           - Dependencies
✅ README.md                              - Documentation
✅ APP_FLOW.md                            - Flow details
✅ QUICK_START.md                         - This file
```

## Features Checklist

- ✅ Splash screen with auto-navigation
- ✅ Login with remember me functionality
- ✅ Order list with status indicators
- ✅ Order status management (Confirm, Deliver, Cancel)
- ✅ Order details screen
- ✅ Phone call integration
- ✅ Google Maps integration
- ✅ Navigation drawer
- ✅ Pull-to-refresh
- ✅ Logout functionality
- ✅ State management with Provider
- ✅ Persistent storage with SharedPreferences
- ✅ Custom fonts with Google Fonts
- ✅ Responsive UI design

## Next Development Steps

1. **Connect to Backend API**
   - Create API service layer
   - Replace demo data with real API calls
   - Add authentication tokens

2. **Add More Features**
   - Push notifications
   - Real-time order tracking
   - Earnings dashboard
   - Profile management
   - Order history

3. **Testing**
   - Write unit tests
   - Write widget tests
   - Test on different devices

4. **Production**
   - Set up proper signing
   - Configure app icons
   - Configure splash screen
   - Submit to stores

---

**Created**: December 24, 2025
**Status**: ✅ Ready for Testing
**Version**: 1.0.0

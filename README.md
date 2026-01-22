# DharaiDeliveryBoy - Food Delivery Boy App

A beautiful and functional food delivery boy application built with Flutter.

## Features

### 1. **Splash Screen**
- Eye-catching red-themed design with curved overlays
- Food delivery illustration
- Auto-navigation to login or home screen based on saved credentials

### 2. **Login Screen**
- Clean and modern UI design
- Username/Email and password input fields
- Password visibility toggle
- "Remember Me" checkbox for persistent login
- Form validation
- Loading indicator during authentication

### 3. **Home/Dashboard Screen**
- List of all orders with different statuses:
  - OnTheWay (Blue)
  - Upcoming (Green)
  - Delivered (Grey)
  - Cancelled (Red)
- Order cards showing:
  - Customer name and profile picture
  - Delivery address
  - Phone number
  - Order date and time
  - Status indicator
- Action buttons:
  - **Details** - Navigate to order details screen
  - **Show Map** - Opens Google Maps with delivery address (for OnTheWay orders)
  - **Cancel** - Cancel the order with confirmation dialog
  - **Confirm** - Confirm OnTheWay orders
  - **Deliver** - Mark Upcoming orders as delivered
- Pull-to-refresh functionality
- Navigation drawer with:
  - User profile
  - Home navigation
  - My Deliveries
  - Profile
  - Logout

### 4. **Order Details Screen**
- Complete order information:
  - Order ID
  - Order status with color indicator
  - Order date and time
- Customer details:
  - Name and profile picture
  - Phone number with call button
  - Delivery address
- Order summary with items and total amount
- Quick actions:
  - Call customer directly
  - Open delivery address in Google Maps

## App Architecture

```
lib/
├── main.dart                          # App entry point
├── models/
│   ├── delivery_boy_model.dart       # Delivery boy data model
│   └── order_model.dart              # Order data model with status enum
├── providers/
│   ├── auth_provider.dart            # Authentication state management
│   └── order_provider.dart           # Order state management
└── screens/
    ├── splash_screen.dart            # Initial splash screen
    ├── login_screen.dart             # Login/authentication screen
    ├── home_screen.dart              # Main dashboard with order list
    └── order_details_screen.dart     # Detailed order view
```

## State Management

The app uses **Provider** for state management with two main providers:

1. **AuthProvider**
   - Handles user authentication
   - Manages login/logout
   - Persists user session with SharedPreferences
   - Remember Me functionality

2. **OrderProvider**
   - Manages order list
   - Handles order status updates (confirm, deliver, cancel)
   - Filters orders by status
   - Refresh orders functionality

## Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  provider: ^6.1.1              # State management
  google_fonts: ^6.1.0          # Custom fonts
  url_launcher: ^6.2.2          # Phone calls and maps
  shared_preferences: ^2.2.2    # Local storage
```

## Getting Started

### Prerequisites
- Flutter SDK (>= 3.9.2)
- Dart SDK
- Android Studio / VS Code
- iOS Simulator / Android Emulator

### Installation

1. Clone or navigate to the project directory:
```bash
cd /Users/satheeshkumar/.gemini/antigravity/scratch/dharai_delivery_boy
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

### Test Credentials
You can use any username and password to login (for demo purposes).

## Screen Flow

```
Splash Screen (3 seconds)
    ↓
Login Screen (if not logged in)
    ↓
Home Screen (order list)
    ↓
Order Details Screen (tap on Details button)
```

## Order Status Flow

1. **OnTheWay** → Click "Confirm" → **Upcoming**
2. **Upcoming** → Click "Deliver" → **Delivered**
3. Any status → Click "Cancel" → **Cancelled**

## Features Highlights

✅ Beautiful, modern UI design with red theme
✅ Smooth animations and transitions
✅ Responsive layout
✅ State management with Provider
✅ Persistent login with SharedPreferences
✅ Google Maps integration for delivery addresses
✅ Phone call integration for customer contact
✅ Pull-to-refresh functionality
✅ Dialog confirmations for critical actions
✅ Custom fonts with Google Fonts
✅ Status-based color coding
✅ Empty state handling
✅ Loading indicators

## Future Enhancements

- [ ] Real API integration
- [ ] Push notifications for new orders
- [ ] Real-time order tracking
- [ ] Earnings/payment tracking
- [ ] Order history with filters
- [ ] Profile management
- [ ] Dark mode support
- [ ] Multi-language support
- [ ] Order search functionality
- [ ] Performance analytics

## License

This project is created for demonstration purposes.

## Developer

Built with ❤️ using Flutter
# FinalDeliveryboyApp

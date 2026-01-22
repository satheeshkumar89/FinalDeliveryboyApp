# DharaiDeliveryBoy - Complete App Flow

## Project Structure

```
dharai_delivery_boy/
├── lib/
│   ├── main.dart                        ✅ Entry point with Provider setup
│   ├── models/
│   │   ├── delivery_boy_model.dart      ✅ Delivery boy data model
│   │   └── order_model.dart             ✅ Order model with status enum
│   ├── providers/
│   │   ├── auth_provider.dart           ✅ Authentication state management
│   │   └── order_provider.dart          ✅ Order state management
│   └── screens/
│       ├── splash_screen.dart           ✅ Splash screen with animation
│       ├── login_screen.dart            ✅ Login with remember me
│       ├── home_screen.dart             ✅ Order list dashboard
│       └── order_details_screen.dart    ✅ Order details view
├── pubspec.yaml                         ✅ Dependencies configured
└── README.md                            ✅ Documentation
```

## Screen Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                       SPLASH SCREEN                         │
│  • Red themed design with food delivery illustration        │
│  • Auto-checks for saved login (SharedPreferences)          │
│  • 3 seconds delay                                          │
└────────────────────┬────────────────────────────────────────┘
                     │
          ┌──────────┴──────────┐
          │                     │
     NOT LOGGED IN        LOGGED IN
          │                     │
          ▼                     ▼
┌─────────────────────┐  ┌─────────────────────────────────────┐
│   LOGIN SCREEN      │  │       HOME SCREEN                   │
│  • Username field   │  │  • Order list with cards            │
│  • Password field   │  │  • Status indicators                │
│  • Remember me      │──▶  • Confirm/Deliver/Cancel buttons   │
│  • Login button     │  │  • Navigation drawer                │
└─────────────────────┘  │  • Pull to refresh                  │
                         └──────────┬───────────────────────────┘
                                    │
                         ┌──────────┴──────────┐
                         │  Click Details      │
                         ▼                     
              ┌───────────────────────────────┐
              │   ORDER DETAILS SCREEN        │
              │  • Order ID & Status          │
              │  • Customer info              │
              │  • Delivery address           │
              │  • Order items summary        │
              │  • Call customer button       │
              │  • Open maps button           │
              └───────────────────────────────┘
```

## Order Status Flow

```
┌──────────────┐       ┌──────────────┐       ┌──────────────┐
│  OnTheWay    │   →   │  Upcoming    │   →   │  Delivered   │
│  (Blue)      │       │  (Green)     │       │  (Grey)      │
└──────────────┘       └──────────────┘       └──────────────┘
      │                       │                       
      │  Click "Confirm"      │  Click "Deliver"      
      └───────────────────────┘                       
                                                      
      ┌───────────────────────────────────────┐
      │  Any Status → Click "Cancel"          │
      ▼                                       
┌──────────────┐
│  Cancelled   │
│  (Red)       │
└──────────────┘
```

## Features by Screen

### 1. Splash Screen (splash_screen.dart)
- ✅ Red gradient background
- ✅ Custom curved clippers (left & right)
- ✅ Food delivery icon with "FOOD DELIVERY" text
- ✅ Loading indicator
- ✅ Auto-navigation based on auth state
- ✅ Checks saved login credentials

### 2. Login Screen (login_screen.dart)
- ✅ Delivery icon header
- ✅ "Welcome back" greeting
- ✅ Username/Email input field
- ✅ Password field with visibility toggle
- ✅ Remember Me checkbox
- ✅ "Trouble logging in?" link
- ✅ Login button with loading state
- ✅ Form validation
- ✅ Error message display
- ✅ Saves credentials with SharedPreferences

### 3. Home Screen (home_screen.dart)
- ✅ Top app bar with "FOOD DELIVERY" title
- ✅ Hamburger menu icon
- ✅ Navigation drawer with:
  - Profile display
  - Home
  - My Deliveries
  - Profile
  - Logout
- ✅ Order list with cards showing:
  - Status indicator (colored dot)
  - Order date/time
  - Customer profile picture
  - Customer name
  - Delivery address
  - Phone number
- ✅ Action buttons:
  - "Details" (blue) - Navigate to details
  - "Show Map" (red outline) - For OnTheWay orders
  - "Cancel" (grey outline) - With confirmation dialog
  - "Confirm" (red) - For OnTheWay → Upcoming
  - "Deliver" (red) - For Upcoming → Delivered
- ✅ Pull-to-refresh functionality
- ✅ Empty state display
- ✅ Loading indicator

### 4. Order Details Screen (order_details_screen.dart)
- ✅ Back button navigation
- ✅ Order status card:
  - Status with color indicator
  - Order date/time
  - Order ID
- ✅ Customer details card:
  - Profile picture
  - Name
  - Phone number with call button
  - Delivery address
  - "Open in Maps" button
- ✅ Order summary card:
  - List of items with quantity
  - Individual prices
  - Total amount
- ✅ Functional buttons:
  - Call customer (opens phone dialer)
  - Open maps (opens Google Maps)

## State Management

### AuthProvider (auth_provider.dart)
```dart
Properties:
- deliveryBoy: DeliveryBoyModel?
- isLoading: bool
- errorMessage: String?
- isAuthenticated: bool

Methods:
- login(userId, password, rememberMe)
- logout()
- checkSavedLogin()
```

### OrderProvider (order_provider.dart)
```dart
Properties:
- orders: List<OrderModel>
- isLoading: bool
- errorMessage: String?
- onTheWayOrders: List<OrderModel>
- upcomingOrders: List<OrderModel>
- deliveredOrders: List<OrderModel>

Methods:
- confirmOrder(orderId)
- deliverOrder(orderId)
- cancelOrder(orderId)
- refreshOrders()
```

## Models

### DeliveryBoyModel
```dart
- userId: String
- name: String
- phone: String
- isActive: bool
```

### OrderModel
```dart
- id: String
- customerName: String
- customerPhone: String
- address: String
- status: OrderStatus (enum)
- orderDate: DateTime
- profileImage: String?
```

### OrderStatus Enum
```dart
enum OrderStatus {
  onTheWay,    // Blue
  upcoming,    // Green
  delivered,   // Grey
  cancelled,   // Red
}
```

## Dependencies Used

1. **provider** - State management
2. **google_fonts** - Custom fonts (Roboto, Pacifico)
3. **url_launcher** - Phone calls and maps
4. **shared_preferences** - Persistent storage for login

## Color Scheme

| Element | Color |
|---------|-------|
| Primary | Red (Colors.red.shade700) |
| OnTheWay Status | Blue (Colors.blue.shade400) |
| Upcoming Status | Green (Colors.green.shade400) |
| Delivered Status | Grey (Colors.grey.shade400) |
| Cancelled Status | Red (Colors.red.shade400) |
| Background | Light Grey (Colors.grey[100]) |

## Running the App

```bash
# Navigate to project
cd /Users/satheeshkumar/.gemini/antigravity/scratch/dharai_delivery_boy

# Get dependencies
flutter pub get

# Run on device
flutter run

# Or run on specific device
flutter run -d <device_id>

# Build APK
flutter build apk

# Build iOS
flutter build ios
```

## Test Scenarios

1. **First Launch**
   - App shows splash screen for 3 seconds
   - Navigate to login screen

2. **Login with Remember Me**
   - Enter any credentials
   - Check "Remember Me"
   - Login
   - Close and reopen app
   - Should go directly to home screen

3. **Order Actions**
   - View OnTheWay order
   - Click "Show Map" → Opens Google Maps
   - Click "Confirm" → Status changes to Upcoming
   - View Upcoming order
   - Click "Deliver" → Status changes to Delivered
   - Click "Cancel" on any order → Shows confirmation dialog

4. **Order Details**
   - Click "Details" on any order
   - View complete order information
   - Click phone icon → Opens phone dialer
   - Click "Open in Maps" → Opens Google Maps

5. **Logout**
   - Open drawer
   - Click "Logout"
   - Returns to login screen
   - Saved credentials cleared

## Demo Data

The app comes with 3 pre-loaded demo orders:

1. **Mohamed Salah** - OnTheWay (Jan 28, 2022 5:30 PM)
2. **Mohamed Ali** - Upcoming (Dec 15, 2021 8:16 PM)
3. **Omar Said** - Upcoming (Nov 29, 2021 1:02 AM)

## Next Steps

To connect to a real backend:

1. Create API service layer
2. Replace demo data with API calls
3. Add authentication token management
4. Implement real-time order updates
5. Add push notifications
6. Implement error handling
7. Add retry logic for failed requests

---

**Status**: ✅ All screens completed and functional
**Testing**: Ready for device testing
**Documentation**: Complete

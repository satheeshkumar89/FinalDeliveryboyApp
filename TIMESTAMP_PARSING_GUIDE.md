# Timestamp Parsing Guide - Delivery Partner App

## ✅ Current Status
The delivery partner app is already following best practices for timestamp parsing. No issues found with `.toLocal()` usage.

## 📋 Correct Approach

### ✅ DO: Use DateTime.parse() or DateTime.tryParse()
```dart
// Correct - Parse ISO 8601 strings directly
DateTime assignedAt = DateTime.parse(json['assigned_at']);
DateTime? pickedupAt = DateTime.tryParse(json['pickedup_at']);

// When formatting for display
String formattedTime = DateFormat('hh:mm a').format(assignedAt);
```

### ❌ DON'T: Use .toLocal() on parsed strings
```dart
// INCORRECT - Don't do this
DateTime assignedAt = DateTime.parse(json['assigned_at']).toLocal();
String formattedTime = DateFormat('hh:mm a').format(order.pickedupAt.toLocal());
```

## 🔍 Why?

1. **Backend sends UTC timestamps**: The backend API returns timestamps in ISO 8601 format (e.g., `"2024-01-20T10:30:00Z"`)
2. **DateTime.parse() handles timezone automatically**: When you parse an ISO 8601 string with `DateTime.parse()`, it automatically converts to local time if needed
3. **Double conversion causes errors**: Using `.toLocal()` on an already-local DateTime can cause incorrect time display

## 📝 Current Implementation

### OrderModel (lib/models/order_model.dart)
```dart
// Line 74 - Already correct ✅
orderDate: DateTime.tryParse(json['created_at']) ?? DateTime.now(),
```

### NotificationModel (lib/models/notification_model.dart)
```dart
// Line 28 - Already correct ✅
createdAt: DateTime.parse(json['created_at']),
```

### LocationModel (lib/models/location_model.dart)
```dart
// Line 17 - Already correct ✅
timestamp: json['timestamp'] != null
    ? DateTime.tryParse(json['timestamp'])
    : null,
```

## 🎯 Future Fields to Add

When the backend adds these timestamp fields to order responses, use this pattern:

```dart
class OrderModel {
  final DateTime? assignedAt;
  final DateTime? pickedupAt;
  final DateTime? deliveredAt;
  
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      // ... other fields
      assignedAt: json['assigned_at'] != null 
          ? DateTime.tryParse(json['assigned_at'])
          : null,
      pickedupAt: json['pickedup_at'] != null 
          ? DateTime.tryParse(json['pickedup_at'])
          : null,
      deliveredAt: json['delivered_at'] != null 
          ? DateTime.tryParse(json['delivered_at'])
          : null,
    );
  }
}
```

## 📱 Display Formatting

When displaying timestamps in the UI:

```dart
// For order details screen
if (order.pickedupAt != null) {
  String pickupTime = DateFormat('hh:mm a').format(order.pickedupAt!);
  // Display: "02:30 PM"
}

// For full date and time
if (order.assignedAt != null) {
  String assignedTime = DateFormat('MMM d, y • h:mm a').format(order.assignedAt!);
  // Display: "Jan 20, 2024 • 2:30 PM"
}
```

## ✅ Verification Checklist

- [x] No `.toLocal()` calls found in the codebase
- [x] All DateTime parsing uses `DateTime.parse()` or `DateTime.tryParse()`
- [x] DateFormat usage is correct
- [x] Ready for future timestamp fields from backend

## 📚 References

- Dart DateTime API: https://api.dart.dev/stable/dart-core/DateTime-class.html
- intl package DateFormat: https://pub.dev/documentation/intl/latest/intl/DateFormat-class.html

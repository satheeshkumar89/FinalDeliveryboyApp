class ApiConstants {
  static String get baseUrl {
    return 'https://dharaifooddelivery.in';
  }

  // Auth Endpoints
  static const String sendOtp = '/delivery-partner/auth/send-otp';
  static const String customerSendOtp = '/customer/auth/send-otp';
  static const String verifyOtp = '/delivery-partner/auth/verify-otp';
  static const String customerVerifyOtp = '/customer/auth/verify-otp';
  static const String firebaseVerify = '/customer/auth/firebase-verify';
  static const String logout = '/customer/auth/logout';
  static const String profile = '/delivery-partner/profile';
  static const String updateProfile = '/delivery-partner/profile';
  static const String register = '/delivery-partner/register';
  static const String toggleStatus = '/delivery-partner/status/toggle';

  // Home Endpoints
  static const String home = '/customer/home';

  // Address Endpoints
  static const String addAddress = '/customer/addresses';

  // Cart Endpoints
  static const String cart = '/customer/cart';
  static const String addToCart = '/customer/cart/add';
  static const String cartItems = '/customer/cart/items';

  // Order Endpoints
  static const String placeOrder = '/customer/orders';

  // Restaurant Endpoints
  static const String restaurantDetails = '/customer/restaurants';

  // Config
  static const String googleMapsApiKey =
      'AIzaSyAXgzMFX14soBva1FP4tXfr02Pwje9lChU';

  // Notifications
  static const String getNotifications = '/notifications/customer';
  static const String getPartnerNotifications =
      '/delivery-partner/notifications';
  static const String markNotificationRead =
      '/delivery-partner/notifications/{notificationId}/read';
  static const String registerDeviceToken = '/delivery-partner/device-token';
  static const String registerTokne = '/notifications/customer/device-token';
  static const String availableOrders = '/delivery-partner/orders/available';
  static const String activeOrders = '/delivery-partner/orders/active';
  static const String completedOrders = '/delivery-partner/orders/completed';
  static const String earnings = '/delivery-partner/earnings';
  static const String acceptOrder = '/delivery-partner/orders/{orderId}/accept';
  static const String reachedRestaurant =
      '/delivery-partner/orders/{orderId}/reached';
  static const String pickupOrder =
      '/delivery-partner/orders/{orderId}/picked-up';
  static const String completeOrder =
      '/delivery-partner/orders/{orderId}/complete';
  static const String cancelOrder = '/delivery-partner/orders/{orderId}/cancel';
  static const String getOrderDetails = '/delivery-partner/orders/{orderId}';
  static const String updateLocation = '/delivery-partner/location';
  static const String getLocation = '/delivery-partner/location/current';
}

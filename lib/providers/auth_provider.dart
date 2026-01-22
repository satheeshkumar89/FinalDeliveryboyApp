import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/delivery_boy_model.dart';

class AuthProvider with ChangeNotifier {
  DeliveryBoyModel? _deliveryBoy;
  bool _isLoading = false;
  String? _errorMessage;

  DeliveryBoyModel? get deliveryBoy => _deliveryBoy;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _deliveryBoy != null;

  Future<void> login(String userId, String password, bool rememberMe) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2)); // Simulate API call

    // Dummy validation - Replace with actual API call
    if (userId.isNotEmpty && password.isNotEmpty) {
      _deliveryBoy = DeliveryBoyModel(
        userId: userId,
        name: 'Delivery Boy',
        phone: '1234567890',
        isActive: true,
      );

      if (rememberMe) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userId', userId);
        await prefs.setBool('rememberMe', true);
      }

      _isLoading = false;
      notifyListeners();
    } else {
      _errorMessage = 'Invalid credentials';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _deliveryBoy = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.setBool('rememberMe', false);
    notifyListeners();
  }

  Future<void> checkSavedLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool('rememberMe') ?? false;
    final savedUserId = prefs.getString('userId');

    if (rememberMe && savedUserId != null) {
      _deliveryBoy = DeliveryBoyModel(
        userId: savedUserId,
        name: 'Delivery Boy',
        phone: '1234567890',
        isActive: true,
      );
      notifyListeners();
    }
  }

  Future<void> loginWithOTP(String phoneNumber, String otp) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2)); // Simulate API call

    // Dummy validation - Replace with actual API call
    if (phoneNumber.isNotEmpty && otp.isNotEmpty && otp.length == 6) {
      _deliveryBoy = DeliveryBoyModel(
        userId: phoneNumber,
        name: 'Delivery Boy',
        phone: phoneNumber,
        isActive: true,
      );

      // Auto-save phone login
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', phoneNumber);
      await prefs.setBool('rememberMe', true);

      _isLoading = false;
      notifyListeners();
    } else {
      _errorMessage = 'Invalid OTP';
      _isLoading = false;
      notifyListeners();
    }
  }
}

import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/network/api_response.dart';
import '../models/delivery_boy_model.dart';
import '../core/services/storage_service.dart';

class AuthRepository {
  final ApiClient _apiClient;
  final StorageService _storageService;

  AuthRepository({ApiClient? apiClient, StorageService? storageService})
    : _apiClient = apiClient ?? ApiClient(baseUrl: ApiConstants.baseUrl),
      _storageService = storageService ?? StorageService();

  Future<ApiResponse<Map<String, dynamic>>> sendOtp(String phoneNumber) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConstants.sendOtp,
        body: {'phone_number': phoneNumber},
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await _storageService.clearAuthData();
  }

  // Actually, I need to capture the access token inside the fromJson or handle it differently.
  // A cleaner way within this repo pattern:
  Future<ApiResponse<DeliveryBoyModel>> verifyOtpAndSaveToken(
    String phoneNumber,
    String otp,
  ) async {
    try {
      // We'll perform the request asking for Map first to get both token and user
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConstants.verifyOtp,
        body: {'phone_number': phoneNumber, 'otp_code': otp},
      );

      if (response.data != null) {
        final data = response.data!;
        if (data.containsKey('access_token')) {
          final deliveryBoy = DeliveryBoyModel.fromJson(
            data['delivery_partner'],
          );
          await _storageService.saveAuthData(
            accessToken: data['access_token'],
            phoneNumber: phoneNumber,
            userId: deliveryBoy.userId,
          );
          // Also set it in API client for future requests
          _apiClient.setAuthToken(data['access_token']);
        }

        final deliveryBoy = DeliveryBoyModel.fromJson(data['delivery_partner']);

        return ApiResponse<DeliveryBoyModel>(
          success: true,
          message: 'Logged in successfully',
          data: deliveryBoy,
        );
      }

      return ApiResponse<DeliveryBoyModel>(
        success: false,
        message: 'Invalid response',
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<DeliveryBoyModel>> registerDeliveryPartner(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiClient.post<DeliveryBoyModel>(
        ApiConstants.register,
        body: data,
        fromJson: (json) => DeliveryBoyModel.fromJson(json),
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> toggleStatus(bool isOnline) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConstants.toggleStatus,
        body: {'is_online': isOnline},
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<DeliveryBoyModel>> getProfile() async {
    try {
      final token = await _storageService.getAccessToken();
      if (token != null) {
        _apiClient.setAuthToken(token);
      }
      final response = await _apiClient.get<DeliveryBoyModel>(
        ApiConstants.profile,
        fromJson: (json) => DeliveryBoyModel.fromJson(json),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<DeliveryBoyModel>> updateProfile(
    Map<String, dynamic> data,
  ) async {
    try {
      final token = await _storageService.getAccessToken();
      if (token != null) {
        _apiClient.setAuthToken(token);
      }
      final response = await _apiClient.put<DeliveryBoyModel>(
        ApiConstants.updateProfile,
        body: data,
        fromJson: (json) => DeliveryBoyModel.fromJson(json),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}

import 'dart:io';
import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/services/storage_service.dart';
import '../models/notification_model.dart';

class NotificationRepository {
  final ApiClient _apiClient;
  final StorageService _storageService;

  NotificationRepository({ApiClient? apiClient, StorageService? storageService})
    : _apiClient = apiClient ?? ApiClient(baseUrl: ApiConstants.baseUrl),
      _storageService = storageService ?? StorageService();

  Future<List<NotificationModel>> getNotifications({int limit = 50}) async {
    try {
      final token = await _storageService.getAccessToken();
      if (token != null) {
        _apiClient.setAuthToken(token);
      }

      final response = await _apiClient.get<List<dynamic>>(
        '${ApiConstants.getPartnerNotifications}?limit=$limit',
      );

      // ApiClient usually handles wrapping/unwrapping.
      // If response.data is the list directly (because server returns list)
      // or if it's wrapped. based on curl it returns a list directly `[...]`.
      // ApiClient.get<T> usually returns ApiResponse<T>.
      // If the raw response is a list, ApiResponse.success will be true and data will be the list.

      if (response.success && response.data != null) {
        return response.data!
            .map((json) => NotificationModel.fromJson(json))
            .toList();
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> markAsRead(int notificationId) async {
    try {
      final token = await _storageService.getAccessToken();
      if (token != null) {
        _apiClient.setAuthToken(token);
      }

      final response = await _apiClient.put<Map<String, dynamic>>(
        ApiConstants.markNotificationRead.replaceAll(
          '{notificationId}',
          notificationId.toString(),
        ),
      );

      if (!response.success) {
        throw Exception(response.message);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> registerDeviceToken(String token) async {
    try {
      final authToken = await _storageService.getAccessToken();
      if (authToken != null) {
        _apiClient.setAuthToken(authToken);
      }

      print('🔔 Registering device token: $token');

      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConstants.registerDeviceToken,
        body: {
          'token': token,
          'device_type': Platform.isIOS ? 'ios' : 'android',
        },
      );

      if (response.success) {
        print('✅ Device token registered successfully');
      } else {
        print('❌ Failed to register device token: ${response.message}');
        throw Exception(response.message);
      }
    } catch (e) {
      print('❌ Error in registerDeviceToken: $e');
      rethrow;
    }
  }
}

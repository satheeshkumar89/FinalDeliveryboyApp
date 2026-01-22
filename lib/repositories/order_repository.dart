import '../models/earnings_model.dart';
import '../models/location_model.dart';
import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/order_model.dart';
import '../core/services/storage_service.dart';

class OrderRepository {
  final ApiClient _apiClient;
  final StorageService _storageService;

  OrderRepository({ApiClient? apiClient, StorageService? storageService})
    : _apiClient = apiClient ?? ApiClient(baseUrl: ApiConstants.baseUrl),
      _storageService = storageService ?? StorageService();

  Future<List<OrderModel>> getAvailableOrders() async {
    try {
      final token = await _storageService.getAccessToken();
      if (token != null) {
        _apiClient.setAuthToken(token);
      }

      final response = await _apiClient.get<List<dynamic>>(
        ApiConstants.availableOrders,
      );

      if (response.success && response.data != null) {
        return response.data!
            .map((json) => OrderModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<OrderModel>> getActiveOrders() async {
    try {
      final token = await _storageService.getAccessToken();
      if (token != null) {
        _apiClient.setAuthToken(token);
      }

      final response = await _apiClient.get<List<dynamic>>(
        ApiConstants.activeOrders,
      );

      if (response.success && response.data != null) {
        return response.data!
            .map((json) => OrderModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> acceptOrder(String orderId) async {
    try {
      final token = await _storageService.getAccessToken();
      if (token != null) {
        _apiClient.setAuthToken(token);
      }

      final url = ApiConstants.acceptOrder.replaceAll('{orderId}', orderId);
      final response = await _apiClient.post<Map<String, dynamic>>(
        url,
        body: {}, // Empty body as per CURL
      );

      if (response.success) {
        return true;
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> reachRestaurant(String orderId) async {
    try {
      final token = await _storageService.getAccessToken();
      if (token != null) {
        _apiClient.setAuthToken(token);
      }

      final url = ApiConstants.reachedRestaurant.replaceAll('{orderId}', orderId);
      final response = await _apiClient.post<Map<String, dynamic>>(
        url,
        body: {},
      );

      if (response.success) {
        return true;
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> pickupOrder(String orderId) async {
    try {
      final token = await _storageService.getAccessToken();
      if (token != null) {
        _apiClient.setAuthToken(token);
      }

      final url = ApiConstants.pickupOrder.replaceAll('{orderId}', orderId);
      final response = await _apiClient.post<Map<String, dynamic>>(
        url,
        body: {},
      );

      if (response.success) {
        return true;
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> completeOrder(String orderId) async {
    try {
      final token = await _storageService.getAccessToken();
      if (token != null) {
        _apiClient.setAuthToken(token);
      }

      final url = ApiConstants.completeOrder.replaceAll('{orderId}', orderId);
      final response = await _apiClient.post<Map<String, dynamic>>(
        url,
        body: {},
      );

      if (response.success) {
        return true;
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> cancelOrder(String orderId) async {
    try {
      final token = await _storageService.getAccessToken();
      if (token != null) {
        _apiClient.setAuthToken(token);
      }

      final url = ApiConstants.cancelOrder.replaceAll('{orderId}', orderId);
      final response = await _apiClient.post<Map<String, dynamic>>(
        url,
        body: {},
      );

      if (response.success) {
        return true;
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<OrderModel>> getCompletedOrders({int limit = 50}) async {
    try {
      final token = await _storageService.getAccessToken();
      if (token != null) {
        _apiClient.setAuthToken(token);
      }

      final response = await _apiClient.get<List<dynamic>>(
        ApiConstants.completedOrders,
        queryParameters: {'limit': limit.toString()},
      );

      if (response.success && response.data != null) {
        return response.data!
            .map((json) => OrderModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<EarningsModel> getEarnings() async {
    try {
      final token = await _storageService.getAccessToken();
      if (token != null) {
        _apiClient.setAuthToken(token);
      }

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.earnings,
      );

      if (response.success && response.data != null) {
        return EarningsModel.fromJson(response.data!);
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      // If response is not wrapped in success/data, ApiClient might return data directly?
      // ApiClient logic: "if not wrapped ... return ApiResponse(success: true, data: jsonResponse)"
      // So response.data should be the JSON.
      // However, sometimes it wraps.
      rethrow;
    }
  }

  Future<void> updateLocation({
    required double latitude,
    required double longitude,
    required double heading,
    double accuracy = 0,
    double speed = 0,
    int orderId = 0,
  }) async {
    try {
      final token = await _storageService.getAccessToken();
      if (token != null) {
        _apiClient.setAuthToken(token);
      }

      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConstants.updateLocation,
        body: {
          'latitude': latitude,
          'longitude': longitude,
          'accuracy': accuracy,
          'bearing': heading,
          'speed': speed,
          'order_id': orderId,
        },
      );

      if (!response.success) {
        throw Exception(response.message);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<LocationModel?> getCurrentLocation() async {
    try {
      final token = await _storageService.getAccessToken();
      if (token != null) {
        _apiClient.setAuthToken(token);
      }

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.getLocation,
      );

      if (response.success && response.data != null) {
        return LocationModel.fromJson(response.data!);
      } else if (response.success && response.data == null) {
        return null;
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      rethrow;
    }
  }
}

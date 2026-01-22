enum OrderStatus {
  onTheWay,
  upcoming,
  assigned,
  delivered,
  cancelled,
  ready,
  reachedRestaurant,
}

class OrderModel {
  final String id;
  final String orderNumber;
  final String restaurantName;
  final String customerName;
  final String customerPhone;
  final String address;
  final double totalAmount;
  final OrderStatus status;
  final DateTime orderDate;
  final String? estimatedDeliveryTime;

  final List<OrderItemModel> items;

  final String? statusTitle;
  final String? statusDescription;
  final int? progressPercentage;
  final String? estimatedArrivalTime;
  final List<OrderTimelineStep>? timeline;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.restaurantName,
    required this.customerName,
    required this.customerPhone,
    required this.address,
    required this.totalAmount,
    required this.status,
    required this.orderDate,
    this.estimatedDeliveryTime,
    this.items = const [],
    this.statusTitle,
    this.statusDescription,
    this.progressPercentage,
    this.estimatedArrivalTime,
    this.timeline,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    var itemsList = <OrderItemModel>[];
    if (json['items'] != null) {
      itemsList = (json['items'] as List)
          .map((i) => OrderItemModel.fromJson(i))
          .toList();
    }

    var timelineList = <OrderTimelineStep>[];
    if (json['timeline'] != null) {
      timelineList = (json['timeline'] as List)
          .map((i) => OrderTimelineStep.fromJson(i))
          .toList();
    }

    return OrderModel(
      id: json['id'].toString(),
      orderNumber: json['order_number'] ?? '',
      restaurantName: json['restaurant_name'] ?? '',
      customerName: json['customer_name'] ?? 'Guest',
      customerPhone: json['customer_phone'] ?? '',
      address: json['delivery_address'] ?? '',
      totalAmount: double.tryParse(json['total_amount'].toString()) ?? 0.0,
      status: _mapStatus(json['status']),
      orderDate: DateTime.tryParse(json['created_at']) ?? DateTime.now(),
      estimatedDeliveryTime: json['estimated_delivery_time'],
      items: itemsList,
      statusTitle: json['status_title'],
      statusDescription: json['status_description'],
      progressPercentage: json['progress_percentage'] != null
          ? int.tryParse(json['progress_percentage'].toString())
          : null,
      estimatedArrivalTime: json['estimated_arrival_time'],
      timeline: timelineList,
    );
  }

  static OrderStatus _mapStatus(String? status) {
    if (status == null) return OrderStatus.upcoming;
    switch (status.toLowerCase()) {
      case 'ready':
      case 'ready_for_pickup':
      case 'handed_over':
        return OrderStatus.ready;
      case 'reached_restaurant':
      case 'reached_hotel':
      case 'reached':
        return OrderStatus.reachedRestaurant;
      case 'assigned':
        return OrderStatus.assigned;
      case 'accepted':
      case 'confirmed':
      case 'preparing':
      case 'processing':
      case 'new':
        return OrderStatus.upcoming;
      case 'on_the_way':
      case 'picked_up':
      case 'ontheway':
      case 'shipped':
        return OrderStatus.onTheWay;
      case 'delivered':
      case 'completed':
        return OrderStatus.delivered;
      case 'cancelled':
      case 'rejected':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.upcoming;
    }
  }

  String get statusText {
    if (statusTitle != null && statusTitle!.isNotEmpty) {
      return statusTitle!;
    }
    switch (status) {
      case OrderStatus.ready:
        return 'Ready for Pickup';
      case OrderStatus.reachedRestaurant:
        return 'At Restaurant';
      case OrderStatus.assigned:
        return 'Order Assigned';
      case OrderStatus.onTheWay:
        return 'Out for Delivery';
      case OrderStatus.upcoming:
        return 'Order Ongoing';
      case OrderStatus.delivered:
        return 'Order Delivered';
      case OrderStatus.cancelled:
        return 'Order Cancelled';
    }
  }

  String get formattedDate {
    return '${_monthName(orderDate.month)} ${orderDate.day}, ${orderDate.year} ${orderDate.hour}:${orderDate.minute.toString().padLeft(2, '0')} ${orderDate.hour >= 12 ? 'PM' : 'AM'}';
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  OrderModel copyWith({
    String? id,
    String? orderNumber,
    String? restaurantName,
    String? customerName,
    String? customerPhone,
    String? address,
    double? totalAmount,
    OrderStatus? status,
    DateTime? orderDate,
    String? estimatedDeliveryTime,
    List<OrderItemModel>? items,
    String? statusTitle,
    String? statusDescription,
    int? progressPercentage,
    String? estimatedArrivalTime,
    List<OrderTimelineStep>? timeline,
  }) {
    return OrderModel(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      restaurantName: restaurantName ?? this.restaurantName,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      address: address ?? this.address,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      orderDate: orderDate ?? this.orderDate,
      estimatedDeliveryTime:
          estimatedDeliveryTime ?? this.estimatedDeliveryTime,
      items: items ?? this.items,
      statusTitle: statusTitle ?? this.statusTitle,
      statusDescription: statusDescription ?? this.statusDescription,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      estimatedArrivalTime: estimatedArrivalTime ?? this.estimatedArrivalTime,
      timeline: timeline ?? this.timeline,
    );
  }
}

class OrderTimelineStep {
  final String title;
  final String subtitle;
  final String time;
  final bool isCompleted;
  final bool isCurrent;

  OrderTimelineStep({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.isCompleted,
    required this.isCurrent,
  });

  factory OrderTimelineStep.fromJson(Map<String, dynamic> json) {
    return OrderTimelineStep(
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      time: json['time'] ?? '',
      isCompleted: json['is_completed'] ?? false,
      isCurrent: json['is_current'] ?? false,
    );
  }
}

class OrderItemModel {
  final String id;
  final int menuItemId;
  final int quantity;
  final double price;
  final String? specialInstructions;
  // We might not have name here based on user JSON, but let's assume UI needs name.
  // If JSON doesn't provide name, we might need a separate call or it's implicitly missing.
  // The provided JSON example: items have id, menu_item_id, quantity, price.
  // It does NOT have item name. This is a problem for UI ("Chicken Burger").
  // Let's rely on backend or placeholder if missing.
  // Actually, looking at common patterns, maybe it's joined?
  // The user prompt JSON shows NO name inside items.
  // I will add a placeholder name or assume the backend response provided earlier was incomplete/example.
  // Wait, the prompt SAYS "Home Screen button details cliked implement the Api Implement bloc pattern method".
  // And shows JSON which includes "items".
  // Let's parse what is there.

  OrderItemModel({
    required this.id,
    required this.menuItemId,
    required this.quantity,
    required this.price,
    this.specialInstructions,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'].toString(),
      menuItemId: json['menu_item_id'] ?? 0,
      quantity: json['quantity'] ?? 1,
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      specialInstructions: json['special_instructions'],
    );
  }
}

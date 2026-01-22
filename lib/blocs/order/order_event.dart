part of 'order_bloc.dart';

abstract class OrderEvent extends Equatable {
  const OrderEvent();

  @override
  List<Object> get props => [];
}

class GetAvailableOrdersRequested extends OrderEvent {}

class GetActiveOrdersRequested extends OrderEvent {}

class GetCompletedOrdersRequested extends OrderEvent {}

class RefreshOrdersRequested extends OrderEvent {}

class AcceptOrderRequested extends OrderEvent {
  final String orderId;

  const AcceptOrderRequested(this.orderId);

  @override
  List<Object> get props => [orderId];
}

class ReachRestaurantRequested extends OrderEvent {
  final String orderId;

  const ReachRestaurantRequested(this.orderId);

  @override
  List<Object> get props => [orderId];
}

class PickupOrderRequested extends OrderEvent {
  final String orderId;

  const PickupOrderRequested(this.orderId);

  @override
  List<Object> get props => [orderId];
}

class CompleteOrderRequested extends OrderEvent {
  final String orderId;

  const CompleteOrderRequested(this.orderId);

  @override
  List<Object> get props => [orderId];
}

class CancelOrderRequested extends OrderEvent {
  final String orderId;

  const CancelOrderRequested(this.orderId);

  @override
  List<Object> get props => [orderId];
}

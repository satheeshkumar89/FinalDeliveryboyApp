part of 'order_bloc.dart';

abstract class OrderState extends Equatable {
  const OrderState();

  @override
  List<Object> get props => [];
}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class OrderLoaded extends OrderState {
  final List<OrderModel> availableOrders;
  final List<OrderModel> activeOrders;
  final List<OrderModel> completedOrders;

  const OrderLoaded({
    this.availableOrders = const [],
    this.activeOrders = const [],
    this.completedOrders = const [],
  });

  // Backward compatibility getters if needed, or remove them
  List<OrderModel> get orders =>
      availableOrders; // Default to available for old code?
  // No, let's break it to force update, or map carefully.
  // Actually, UI uses state.orders. Let's redirect `orders` to `availableOrders` for now to minimize breakage
  // while we refactor HomeScreen. Or better, just expose the two lists.

  @override
  List<Object> get props => [availableOrders, activeOrders, completedOrders];
}

class OrderError extends OrderState {
  final String message;

  const OrderError(this.message);

  @override
  List<Object> get props => [message];
}

class OrderOperationSuccess extends OrderState {
  final String message;

  const OrderOperationSuccess(this.message);

  @override
  List<Object> get props => [message];
}

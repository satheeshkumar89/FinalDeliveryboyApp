import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/order_model.dart';
import '../../repositories/order_repository.dart';

part 'order_event.dart';
part 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderRepository orderRepository;

  OrderBloc({required this.orderRepository}) : super(OrderInitial()) {
    on<GetAvailableOrdersRequested>(_onGetAvailableOrdersRequested);
    on<GetActiveOrdersRequested>(_onGetActiveOrdersRequested);
    on<GetCompletedOrdersRequested>(_onGetCompletedOrdersRequested);
    on<AcceptOrderRequested>(_onAcceptOrderRequested);
    on<ReachRestaurantRequested>(_onReachRestaurantRequested);
    on<PickupOrderRequested>(_onPickupOrderRequested);
    on<CompleteOrderRequested>(_onCompleteOrderRequested);
    on<CancelOrderRequested>(_onCancelOrderRequested);
    on<RefreshOrdersRequested>(_onRefreshOrdersRequested);
  }
  Future<void> _onReachRestaurantRequested(
    ReachRestaurantRequested event,
    Emitter<OrderState> emit,
  ) async {
    try {
      await orderRepository.reachRestaurant(event.orderId);
      // Refresh active orders to update status
      add(GetActiveOrdersRequested());
      add(GetAvailableOrdersRequested());
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }


  Future<void> _onPickupOrderRequested(
    PickupOrderRequested event,
    Emitter<OrderState> emit,
  ) async {
    try {
      await orderRepository.pickupOrder(event.orderId);
      // Refresh active orders to move to onTheWay status locally
      add(GetActiveOrdersRequested());
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> _onRefreshOrdersRequested(
    RefreshOrdersRequested event,
    Emitter<OrderState> emit,
  ) async {
    // We don't emit loading here to allow for smooth background refresh
    try {
      // Fetch all in parallel
      final results = await Future.wait([
        orderRepository.getAvailableOrders(),
        orderRepository.getActiveOrders(),
        orderRepository.getCompletedOrders(limit: 10), // Fetch recent completed
      ]);

      emit(
        OrderLoaded(
          availableOrders: results[0],
          activeOrders: results[1],
          completedOrders: results[2],
        ),
      );
    } catch (e) {
      print('❌ Refresh Error: $e');
      // On error during background refresh, we keep the current state or emit error?
      // Usually better to stay on current state but log the error
    }
  }

  Future<void> _onGetAvailableOrdersRequested(
    GetAvailableOrdersRequested event,
    Emitter<OrderState> emit,
  ) async {
    // Emit loading only if not already loaded to check initial state
    if (state is! OrderLoaded) {
      emit(OrderLoading());
    }

    try {
      final orders = await orderRepository.getAvailableOrders();

      // Get current active orders and completed orders from latest state
      List<OrderModel> currentActive = [];
      List<OrderModel> currentCompleted = [];
      if (state is OrderLoaded) {
        currentActive = (state as OrderLoaded).activeOrders;
        currentCompleted = (state as OrderLoaded).completedOrders;
      }

      emit(
        OrderLoaded(
          availableOrders: orders,
          activeOrders: currentActive,
          completedOrders: currentCompleted,
        ),
      );
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> _onGetActiveOrdersRequested(
    GetActiveOrdersRequested event,
    Emitter<OrderState> emit,
  ) async {
    // Emit loading only if not already loaded
    if (state is! OrderLoaded) {
      emit(OrderLoading());
    }

    try {
      final orders = await orderRepository.getActiveOrders();

      // Get current available orders and completed orders from latest state
      List<OrderModel> currentAvailable = [];
      List<OrderModel> currentCompleted = [];
      if (state is OrderLoaded) {
        currentAvailable = (state as OrderLoaded).availableOrders;
        currentCompleted = (state as OrderLoaded).completedOrders;
      }

      emit(
        OrderLoaded(
          availableOrders: currentAvailable,
          activeOrders: orders,
          completedOrders: currentCompleted,
        ),
      );
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> _onGetCompletedOrdersRequested(
    GetCompletedOrdersRequested event,
    Emitter<OrderState> emit,
  ) async {
    // Emit loading only if not already loaded
    if (state is! OrderLoaded) {
      emit(OrderLoading());
    }

    try {
      final orders = await orderRepository.getCompletedOrders();

      // Get current available and active orders from latest state
      List<OrderModel> currentAvailable = [];
      List<OrderModel> currentActive = [];
      if (state is OrderLoaded) {
        currentAvailable = (state as OrderLoaded).availableOrders;
        currentActive = (state as OrderLoaded).activeOrders;
      }

      emit(
        OrderLoaded(
          availableOrders: currentAvailable,
          activeOrders: currentActive,
          completedOrders: orders,
        ),
      );
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> _onAcceptOrderRequested(
    AcceptOrderRequested event,
    Emitter<OrderState> emit,
  ) async {
    try {
      await orderRepository.acceptOrder(event.orderId);
      // Refresh both lists to move order
      add(GetAvailableOrdersRequested());
      add(GetActiveOrdersRequested());
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> _onCompleteOrderRequested(
    CompleteOrderRequested event,
    Emitter<OrderState> emit,
  ) async {
    try {
      await orderRepository.completeOrder(event.orderId);
      // Refresh active orders
      add(GetActiveOrdersRequested());
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> _onCancelOrderRequested(
    CancelOrderRequested event,
    Emitter<OrderState> emit,
  ) async {
    try {
      await orderRepository.cancelOrder(event.orderId);
      // Refresh both to be safe
      add(GetAvailableOrdersRequested());
      add(GetActiveOrdersRequested());
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }
}

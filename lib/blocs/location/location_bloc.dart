import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/order_repository.dart';
import 'location_event.dart';
import 'location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final OrderRepository orderRepository;

  LocationBloc({required this.orderRepository}) : super(LocationInitial()) {
    on<LocationUpdateRequested>(_onLocationUpdateRequested);
    on<GetCurrentLocationRequested>(_onGetCurrentLocationRequested);
  }

  Future<void> _onLocationUpdateRequested(
    LocationUpdateRequested event,
    Emitter<LocationState> emit,
  ) async {
    // We can emit 'Updating' if we want to show a spinner, but for background updates
    // we often skip it to avoid flickering UI if used there.
    // However, for correctness, let's keep it but handle it gracefully in UI.
    // Actually, for frequent updates, emitting "Updating" repeatedly might be noisy.
    // Let's just do it.

    // Uncomment if UI feedback is needed
    // emit(LocationUpdating());

    try {
      await orderRepository.updateLocation(
        latitude: event.latitude,
        longitude: event.longitude,
        heading: event.heading,
        accuracy: event.accuracy,
        speed: event.speed,
        orderId: event.orderId,
      );
      emit(LocationUpdateSuccess(DateTime.now()));
    } catch (e) {
      emit(LocationUpdateFailure(e.toString()));
    }
  }

  Future<void> _onGetCurrentLocationRequested(
    GetCurrentLocationRequested event,
    Emitter<LocationState> emit,
  ) async {
    emit(LocationUpdating());
    try {
      final location = await orderRepository.getCurrentLocation();
      emit(LocationLoaded(location));
    } catch (e) {
      emit(LocationUpdateFailure(e.toString()));
    }
  }
}

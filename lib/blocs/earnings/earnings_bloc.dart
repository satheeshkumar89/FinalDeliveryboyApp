import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/order_repository.dart';
import 'earnings_event.dart';
import 'earnings_state.dart';

class EarningsBloc extends Bloc<EarningsEvent, EarningsState> {
  final OrderRepository orderRepository;

  EarningsBloc({required this.orderRepository}) : super(EarningsInitial()) {
    on<GetEarningsRequested>(_onGetEarningsRequested);
  }

  Future<void> _onGetEarningsRequested(
    GetEarningsRequested event,
    Emitter<EarningsState> emit,
  ) async {
    emit(EarningsLoading());
    try {
      final earnings = await orderRepository.getEarnings();
      emit(EarningsLoaded(earnings));
    } catch (e) {
      emit(EarningsError(e.toString()));
    }
  }
}

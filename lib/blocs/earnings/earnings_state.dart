import 'package:equatable/equatable.dart';
import '../../models/earnings_model.dart';

abstract class EarningsState extends Equatable {
  const EarningsState();

  @override
  List<Object> get props => [];
}

class EarningsInitial extends EarningsState {}

class EarningsLoading extends EarningsState {}

class EarningsLoaded extends EarningsState {
  final EarningsModel earnings;

  const EarningsLoaded(this.earnings);

  @override
  List<Object> get props => [earnings];
}

class EarningsError extends EarningsState {
  final String message;

  const EarningsError(this.message);

  @override
  List<Object> get props => [message];
}

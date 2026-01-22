import 'package:equatable/equatable.dart';

abstract class EarningsEvent extends Equatable {
  const EarningsEvent();

  @override
  List<Object> get props => [];
}

class GetEarningsRequested extends EarningsEvent {}

import 'package:equatable/equatable.dart';
import '../../models/location_model.dart';

abstract class LocationState extends Equatable {
  const LocationState();

  @override
  List<Object> get props => [];
}

class LocationInitial extends LocationState {}

class LocationUpdating extends LocationState {}

class LocationUpdateSuccess extends LocationState {
  final DateTime timestamp;

  const LocationUpdateSuccess(this.timestamp);

  @override
  List<Object> get props => [timestamp];
}

class LocationLoaded extends LocationState {
  final LocationModel? location;

  const LocationLoaded(this.location);

  @override
  List<Object> get props => location != null ? [location!] : [];
}

class LocationUpdateFailure extends LocationState {
  final String error;

  const LocationUpdateFailure(this.error);

  @override
  List<Object> get props => [error];
}

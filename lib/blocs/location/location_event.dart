import 'package:equatable/equatable.dart';

abstract class LocationEvent extends Equatable {
  const LocationEvent();

  @override
  List<Object> get props => [];
}

class LocationUpdateRequested extends LocationEvent {
  final double latitude;
  final double longitude;
  final double heading;
  final double accuracy;
  final double speed;
  final int orderId;

  const LocationUpdateRequested({
    required this.latitude,
    required this.longitude,
    required this.heading,
    this.accuracy = 0,
    this.speed = 0,
    this.orderId = 0,
  });

  @override
  List<Object> get props => [
    latitude,
    longitude,
    heading,
    accuracy,
    speed,
    orderId,
  ];
}

class GetCurrentLocationRequested extends LocationEvent {}

part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class SendOtpRequested extends AuthEvent {
  final String phoneNumber;

  const SendOtpRequested(this.phoneNumber);

  @override
  List<Object> get props => [phoneNumber];
}

class VerifyOtpRequested extends AuthEvent {
  final String phoneNumber;
  final String otp;

  const VerifyOtpRequested({required this.phoneNumber, required this.otp});

  @override
  List<Object> get props => [phoneNumber, otp];
}

class RegisterRequested extends AuthEvent {
  final Map<String, dynamic> data;
  final String? profileImage;

  const RegisterRequested({required this.data, this.profileImage});

  @override
  List<Object> get props => [data, if (profileImage != null) profileImage!];
}

class StatusToggleRequested extends AuthEvent {
  final bool isOnline;

  const StatusToggleRequested(this.isOnline);

  @override
  List<Object> get props => [isOnline];
}

class GetProfileRequested extends AuthEvent {}

class UpdateProfileRequested extends AuthEvent {
  final Map<String, dynamic> data;

  const UpdateProfileRequested(this.data);

  @override
  List<Object> get props => [data];
}

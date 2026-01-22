import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../repositories/auth_repository.dart';
import '../../models/delivery_boy_model.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<SendOtpRequested>(_onSendOtpRequested);
    on<VerifyOtpRequested>(_onVerifyOtpRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<StatusToggleRequested>(_onStatusToggleRequested);
    on<GetProfileRequested>(_onGetProfileRequested);
    on<UpdateProfileRequested>(_onUpdateProfileRequested);
  }

  Future<void> _onUpdateProfileRequested(
    UpdateProfileRequested event,
    Emitter<AuthState> emit,
  ) async {
    // We can emit loading, or keep current state.
    // If we're on ProfileScreen, we probably want a loading indicator.
    // However, global loading might be disruptive if we are just editing one field.
    // Let's emit AuthLoading for simplicity as it's a significant action.
    emit(AuthLoading());
    try {
      final response = await authRepository.updateProfile(event.data);
      if (response.success && response.data != null) {
        emit(AuthAuthenticated(response.data!));
      } else {
        emit(AuthFailure(response.message));
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onGetProfileRequested(
    GetProfileRequested event,
    Emitter<AuthState> emit,
  ) async {
    // We keep current state if it is authenticated to not show loading screen
    // or we can emit AuthLoading. Since profile is usually loaded on demand or startup
    // let's try to maintain UX.
    // However, if we are calling this from ProfileScreen, we might want a spinner.
    // But AuthBloc handles the entire app auth state. Replacing it with 'AuthLoading'
    // might trigger a global loading indicator if the root listens to it.
    // For now, let's assume we can set loading.

    // Better approach: If already authenticated, just update the data without full reload state
    // but the state classes (AuthAuthenticated) are immutable.
    // So we just emit new AuthAuthenticated.

    try {
      final response = await authRepository.getProfile();
      if (response.success && response.data != null) {
        emit(AuthAuthenticated(response.data!));
      } else {
        // If fetch fails, we don't necessarily want to log them out or show error screen
        // just maybe snackbar event? But Bloc state changes UI.
        // If we are already authenticated, maybe just keep state?
        // Or emit AuthFailure which currently seems to be a generic error state.
        emit(AuthFailure(response.message));
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onSendOtpRequested(
    SendOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final response = await authRepository.sendOtp(event.phoneNumber);
      if (response.success) {
        emit(
          OtpSentSuccess(
            phoneNumber: event.phoneNumber,
            data: response.data ?? {},
          ),
        );
      } else {
        emit(AuthFailure(response.message));
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onVerifyOtpRequested(
    VerifyOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final response = await authRepository.verifyOtpAndSaveToken(
        event.phoneNumber,
        event.otp,
      );
      if (response.success && response.data != null) {
        final deliveryBoy = response.data!;

        if (!deliveryBoy.isRegistered) {
          emit(AuthUnregistered(deliveryBoy));
        } else if (deliveryBoy.verificationStatus.toLowerCase() == 'pending' ||
            deliveryBoy.verificationStatus.toLowerCase() == 'submitted') {
          await authRepository.logout();
          emit(
            const AuthFailure(
              'Your account verification is pending. Please contact admin.',
            ),
          );
        } else {
          emit(AuthAuthenticated(deliveryBoy));
        }
      } else {
        emit(AuthFailure(response.message));
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final response = await authRepository.registerDeliveryPartner(event.data);
      if (response.success && response.data != null) {
        // After registration, usually the status is pending
        await authRepository.logout();
        emit(
          const AuthFailure(
            'Registration successful. Your account verification is pending. Please contact admin.',
          ),
        );
      } else {
        emit(AuthFailure(response.message));
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onStatusToggleRequested(
    StatusToggleRequested event,
    Emitter<AuthState> emit,
  ) async {
    final currentState = state;
    if (currentState is AuthAuthenticated) {
      // Don't emit generic loading as it might replace the UI content
      // Could introduce a specific status loading state or just optimistic update
      // For now, let's keep AuthAuthenticated but maybe we need a way to show loading on the switch

      try {
        final response = await authRepository.toggleStatus(event.isOnline);
        if (response.success && response.data != null) {
          final isOnline = response.data!['is_online'] as bool;
          final updatedDeliveryBoy = currentState.deliveryBoy.copyWith(
            isActive: isOnline,
          );
          emit(AuthAuthenticated(updatedDeliveryBoy));
        } else {
          // For toggle, showing a snackbar error via a transient state or listening to a stream would be better
          // but here we might just revert
          emit(AuthFailure(response.message));
          // Re-emit authenticated to restore screen?
          // Ideally we shouldn't leave the screen.
          // Let's emit AuthAuthenticated with original state if we can, after error.
          // But AuthFailure replaces the state. This is a limitation of this simple BLoC structure for valid actions.
          // Let's just emit AuthFailure for now and let the UI handle it (it might logout or show error).
          // Actually, simply emitting Failure might be too harsh if it navigates away.
          // Better: emit AuthAuthenticated with error message side-effect?
          // Sticking to pattern: AuthFailure will probably show snackbar and stay if configured right, or show error screen.
          // Given HomeScreen structure, AuthFailure might replace body.
          // Let's assume HomeScreen handles AuthAuthenticated mostly.
        }
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    }
  }
}

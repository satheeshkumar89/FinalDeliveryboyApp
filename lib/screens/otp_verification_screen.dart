import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import '../blocs/auth/auth_bloc.dart';
import 'home_screen.dart';
import 'register_profile_screen.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String phoneNumber;

  const OTPVerificationScreen({super.key, required this.phoneNumber});

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  int _resendTimer = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
    // Auto-focus first field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _resendTimer = 30;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimer > 0) {
        setState(() {
          _resendTimer--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  String get _maskedPhone {
    if (widget.phoneNumber.length >= 10) {
      // Ensure phone number has at least 10 digits to avoid range error
      // Assuming format +91XXXXXXXXXX or just XXXXXXXXXX
      final phone = widget.phoneNumber.replaceAll('+91', '').trim();
      if (phone.length == 10) {
        return '+91 ${phone.substring(0, 2)} *******${phone.substring(7)}';
      }
    }
    return widget.phoneNumber;
  }

  bool get _isOTPComplete {
    return _controllers.every((controller) => controller.text.isNotEmpty);
  }

  void _verifyOTP() {
    if (!_isOTPComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the complete OTP'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final otp = _controllers.map((c) => c.text).join();
    context.read<AuthBloc>().add(
      VerifyOtpRequested(
        phoneNumber: widget.phoneNumber.startsWith('+91')
            ? widget.phoneNumber
            : '+91${widget.phoneNumber}',
        otp: otp,
      ),
    );
  }

  void _resendOTP() {
    if (_resendTimer > 0) return;

    context.read<AuthBloc>().add(
      SendOtpRequested(
        widget.phoneNumber.startsWith('+91')
            ? widget.phoneNumber
            : '+91${widget.phoneNumber}',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        } else if (state is AuthUnregistered) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) =>
                  RegisterProfileScreen(deliveryBoy: state.deliveryBoy),
            ),
          );
        } else if (state is OtpSentSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('OTP sent successfully'),
              backgroundColor: Colors.green,
            ),
          );
          _startTimer();
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(height: 40),
                  // Title
                  Text(
                    'OTP Verification',
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Subtitle with phone number
                  Text(
                    'Enter the verification code we just sent to your\nnumber $_maskedPhone.',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // OTP input boxes
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(6, (index) {
                      return _buildOTPBox(index);
                    }),
                  ),
                  const SizedBox(height: 24),
                  // Resend OTP
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Didn\'t receive code? ',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        GestureDetector(
                          onTap: _resendOTP,
                          child: Text(
                            _resendTimer > 0
                                ? 'Resend ($_resendTimer)'
                                : 'Resend',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: const Color(0xFFC62828),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Verify button
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      final isLoading = state is AuthLoading;
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : (_isOTPComplete ? _verifyOTP : null),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isOTPComplete
                                ? const Color(0xFFC62828)
                                : Colors.grey[300],
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 0,
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Text(
                                  'Verify',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: _isOTPComplete
                                        ? Colors.white
                                        : Colors.grey[500],
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOTPBox(int index) {
    return Container(
      width: 50,
      height: 56,
      decoration: BoxDecoration(
        border: Border.all(
          color: _controllers[index].text.isNotEmpty
              ? const Color(0xFFC62828)
              : Colors.grey[300]!,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(1),
        ],
        style: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          counterText: '',
        ),
        onChanged: (value) {
          setState(() {}); // Update UI for button state

          if (value.isNotEmpty) {
            // Move to next field
            if (index < 5) {
              _focusNodes[index + 1].requestFocus();
            } else {
              // Last field, unfocus
              _focusNodes[index].unfocus();
            }
          } else {
            // Move to previous field on backspace
            if (index > 0) {
              _focusNodes[index - 1].requestFocus();
            }
          }
        },
        onTap: () {
          // Clear field on tap for better UX
          _controllers[index].clear();
        },
      ),
    );
  }
}

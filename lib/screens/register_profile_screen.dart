import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../blocs/auth/auth_bloc.dart';
import '../models/delivery_boy_model.dart';
import 'phone_login_screen.dart';

class RegisterProfileScreen extends StatefulWidget {
  final DeliveryBoyModel deliveryBoy;

  const RegisterProfileScreen({super.key, required this.deliveryBoy});

  @override
  State<RegisterProfileScreen> createState() => _RegisterProfileScreenState();
}

class _RegisterProfileScreenState extends State<RegisterProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _vehicleNumberController;
  late TextEditingController _licenseNumberController;
  String? _selectedVehicleType;

  // Dummy list for vehicle types
  final List<String> _vehicleTypes = [
    'Bike',
    'Scooter',
    'Bicycle',
    'Electric Scooter',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.deliveryBoy.name != 'Delivery Partner'
          ? widget.deliveryBoy.name
          : '',
    );
    _emailController =
        TextEditingController(); // Email is not in the model initially
    _vehicleNumberController = TextEditingController();
    _licenseNumberController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _vehicleNumberController.dispose();
    _licenseNumberController.dispose();
    super.dispose();
  }

  void _register() {
    if (_formKey.currentState!.validate()) {
      if (_selectedVehicleType == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a vehicle type')),
        );
        return;
      }

      final data = {
        'full_name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'vehicle_type': _selectedVehicleType,
        'vehicle_number': _vehicleNumberController.text.trim(),
        'license_number': _licenseNumberController.text.trim(),
        'profile_photo':
            'string', // Placeholder as per API requirement until image upload is implemented
        // Add other necessary fields if any
      };

      context.read<AuthBloc>().add(RegisterRequested(data: data));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthFailure) {
          // If registration is successful, the bloc emits AuthFailure with success message (as implemented)
          // Or if it fails, it emits failure. Ideally we should have a distinct success state or handle it better.
          // Based on current implementation:
          if (state.message.contains('Registration successful')) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            // Navigate back to login or stay here?
            // The bloc logs out, so we should probably go to login screen
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const PhoneLoginScreen()),
              (route) => false,
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'Register Profile',
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Fill in your details to continue',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 32),

                // Profile Photo Placeholder
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.camera_alt,
                      size: 40,
                      color: Colors.grey[400],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Add Profile Photo',
                  style: GoogleFonts.poppins(
                    color: Colors.blue,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 32),

                // Name
                _buildTextField(
                  controller: _nameController,
                  hintText: 'Full Name',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Email
                _buildTextField(
                  controller: _emailController,
                  hintText: 'Email Address',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Vehicle Type Dropdown
                _buildDropdown(),
                const SizedBox(height: 16),

                // Vehicle Number
                _buildTextField(
                  controller: _vehicleNumberController,
                  hintText: 'Vehicle Number',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter vehicle number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // License Number
                _buildTextField(
                  controller: _licenseNumberController,
                  hintText: 'License Number',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter license number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Register Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return ElevatedButton(
                        onPressed: state is AuthLoading ? null : _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        child: state is AuthLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Register',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        style: GoogleFonts.poppins(fontSize: 14),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.poppins(color: Colors.grey[500]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField<String>(
          value: _selectedVehicleType,
          hint: Text(
            'Vehicle Type',
            style: GoogleFonts.poppins(color: Colors.grey[500], fontSize: 14),
          ),
          decoration: const InputDecoration(border: InputBorder.none),
          items: _vehicleTypes.map((String type) {
            return DropdownMenuItem<String>(
              value: type,
              child: Text(type, style: GoogleFonts.poppins(fontSize: 14)),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedVehicleType = newValue;
            });
          },
          validator: (value) =>
              value == null ? 'Please select a vehicle type' : null,
        ),
      ),
    );
  }
}

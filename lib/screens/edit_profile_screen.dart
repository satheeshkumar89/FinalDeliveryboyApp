import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../blocs/auth/auth_bloc.dart';
import '../models/delivery_boy_model.dart';

class EditProfileScreen extends StatefulWidget {
  final DeliveryBoyModel user;

  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _vehicleTypeController;
  late TextEditingController _vehicleNumberController;
  late TextEditingController _licenseNumberController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
    _vehicleTypeController = TextEditingController(
      text: widget.user.vehicleType,
    );
    _vehicleNumberController = TextEditingController(
      text: widget.user.vehicleNumber,
    );
    _licenseNumberController = TextEditingController(
      text: widget.user.licenseNumber,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _vehicleTypeController.dispose();
    _vehicleNumberController.dispose();
    _licenseNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: GoogleFonts.roboto(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.green),
            onPressed: _saveProfile,
          ),
        ],
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            Navigator.pop(context); // Close screen on success
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile updated successfully')),
            );
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
            // We might need to handle getting back to a usable state if needed,
            // but AuthBloc currently emits Failure then stays there or needs reset.
            // Ideally we'd re-emit authenticated or have a separate transient status.
            // With current simple logic, user sees error. They can try again.
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSection('Personal Information'),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _emailController,
                  label: 'Email',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 24),
                _buildSection('Vehicle Information'),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _vehicleTypeController,
                  label: 'Vehicle Type',
                  icon: Icons.directions_bike_outlined,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _vehicleNumberController,
                  label: 'Vehicle Number',
                  icon: Icons.confirmation_number_outlined,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _licenseNumberController,
                  label: 'License Number',
                  icon: Icons.badge_outlined,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title) {
    return Text(
      title,
      style: GoogleFonts.roboto(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade700, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      final updatedData = {
        'full_name': _nameController.text,
        'email': _emailController.text,
        'vehicle_type': _vehicleTypeController.text,
        'vehicle_number': _vehicleNumberController.text,
        'license_number': _licenseNumberController.text,
        // Include minimal required fields or current ones
        'phone_number': widget.user.phone,
        'profile_photo': widget.user.profilePhoto,
      };

      context.read<AuthBloc>().add(UpdateProfileRequested(updatedData));
    }
  }
}

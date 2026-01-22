import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../blocs/auth/auth_bloc.dart';
import '../models/delivery_boy_model.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh profile data when entering screen
    context.read<AuthBloc>().add(GetProfileRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        DeliveryBoyModel? user;
        if (state is AuthAuthenticated) {
          user = state.deliveryBoy;
        } else if (state is AuthUnregistered) {
          user = state.deliveryBoy;
        }

        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            title: Text(
              'My Profile',
              style: GoogleFonts.roboto(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              if (user != null)
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.black),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProfileScreen(user: user!),
                      ),
                    );
                  },
                ),
            ],
          ),
          body: () {
            if (state is AuthLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (user != null) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildProfileHeader(user),
                    const SizedBox(height: 24),
                    _buildInfoCard(user),
                    const SizedBox(height: 24),
                    _buildVehicleInfoCard(user),
                    const SizedBox(height: 32),
                    _buildLogoutButton(context),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          }(),
        );
      },
    );
  }

  Widget _buildProfileHeader(DeliveryBoyModel user) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[200],
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: user.profilePhoto != null && user.profilePhoto!.isNotEmpty
                  ? ClipOval(
                      child: Image.network(
                        user.profilePhoto!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.grey,
                            ),
                      ),
                    )
                  : const Icon(Icons.person, size: 60, color: Colors.grey),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: user.isActive ? Colors.green : Colors.grey,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.check, size: 16, color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          user.name,
          style: GoogleFonts.roboto(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            user.verificationStatus.toUpperCase(),
            style: GoogleFonts.roboto(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(DeliveryBoyModel user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personal Information',
            style: GoogleFonts.roboto(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.email_outlined, 'Email', user.email ?? 'N/A'),
          const Divider(height: 24),
          _buildInfoRow(Icons.phone_outlined, 'Phone', user.phone),
          const Divider(height: 24),
          _buildInfoRow(
            Icons.star_outline,
            'Rating',
            user.rating.toStringAsFixed(1),
            valueColor: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleInfoCard(DeliveryBoyModel user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vehicle Details',
            style: GoogleFonts.roboto(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            Icons.directions_bike_outlined,
            'Vehicle Type',
            user.vehicleType ?? 'N/A',
          ),
          const Divider(height: 24),
          _buildInfoRow(
            Icons.confirmation_number_outlined,
            'Vehicle Number',
            user.vehicleNumber ?? 'N/A',
          ),
          const Divider(height: 24),
          _buildInfoRow(
            Icons.badge_outlined,
            'License Number',
            user.licenseNumber ?? 'N/A',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[400]),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.roboto(fontSize: 12, color: Colors.grey[500]),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: GoogleFonts.roboto(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: valueColor ?? Colors.black87,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // Logout logic would go here.
          // Usually dispatching a LogoutRequested event to AuthBloc
          // But AuthBloc doesn't have it explicitly shown in previous steps,
          // though AuthRepository has logout().
          // For now, let's assuming simply pop or show dialog.
          // Or better, let's just make it do nothing or print for now as Logout wasn't requested explicitly.
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Logout feature to be implemented")),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade50,
          foregroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(
          'Log Out',
          style: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

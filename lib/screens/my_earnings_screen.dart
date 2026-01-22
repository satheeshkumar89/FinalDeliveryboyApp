import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../blocs/earnings/earnings_bloc.dart';
import '../blocs/earnings/earnings_event.dart';
import '../blocs/earnings/earnings_state.dart';
import '../models/earnings_model.dart';

class MyEarningsScreen extends StatefulWidget {
  const MyEarningsScreen({super.key});

  @override
  State<MyEarningsScreen> createState() => _MyEarningsScreenState();
}

class _MyEarningsScreenState extends State<MyEarningsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EarningsBloc>().add(GetEarningsRequested());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'My Earnings',
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
      ),
      body: BlocBuilder<EarningsBloc, EarningsState>(
        builder: (context, state) {
          if (state is EarningsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is EarningsError) {
            return Center(child: Text(state.message));
          }

          if (state is EarningsLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<EarningsBloc>().add(GetEarningsRequested());
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTotalEarningsCard(state.earnings),
                    const SizedBox(height: 24),
                    Text(
                      'Overview',
                      style: GoogleFonts.roboto(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildStatsGrid(state.earnings),
                  ],
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildTotalEarningsCard(EarningsModel earnings) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red.shade700, Colors.red.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.red.shade200,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Today\'s Earnings',
            style: GoogleFonts.roboto(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '₹${earnings.todayEarnings.toStringAsFixed(2)}',
            style: GoogleFonts.roboto(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildCompactStat(
                'Week',
                '₹${earnings.weekEarnings.toStringAsFixed(2)}',
              ),
              Container(width: 1, height: 40, color: Colors.white24),
              _buildCompactStat(
                'Month',
                '₹${earnings.monthEarnings.toStringAsFixed(2)}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactStat(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.roboto(
            color: Colors.white.withOpacity(0.8),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.roboto(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(EarningsModel earnings) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.1, // Increased height to prevent overflow
      children: [
        _buildStatCard(
          icon: Icons.delivery_dining,
          color: Colors.blue,
          value: earnings.totalDeliveries.toString(),
          label: 'Total Deliveries',
        ),
        _buildStatCard(
          icon: Icons.star_rate_rounded,
          color: Colors.orange,
          value: earnings.avgRating.toStringAsFixed(1),
          label: 'Average Rating',
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color color,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 28), // Slightly smaller icon
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: GoogleFonts.roboto(
                fontSize: 22, // Slightly smaller text
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.roboto(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

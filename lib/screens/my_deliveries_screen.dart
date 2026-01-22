import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../blocs/order/order_bloc.dart';
import '../models/order_model.dart';
import '../widgets/order_card.dart';

class MyDeliveriesScreen extends StatefulWidget {
  const MyDeliveriesScreen({super.key});

  @override
  State<MyDeliveriesScreen> createState() => _MyDeliveriesScreenState();
}

class _MyDeliveriesScreenState extends State<MyDeliveriesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderBloc>().add(GetCompletedOrdersRequested());
    });
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final url = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not make phone call')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'My Deliveries',
          style: GoogleFonts.roboto(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<OrderBloc, OrderState>(
        builder: (context, state) {
          if (state is OrderLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is OrderLoaded) {
            if (state.completedOrders.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history, size: 80, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No completed deliveries yet',
                      style: GoogleFonts.roboto(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<OrderBloc>().add(GetCompletedOrdersRequested());
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.completedOrders.length,
                itemBuilder: (context, index) {
                  OrderModel order = state.completedOrders[index];
                  return OrderCard(
                    order: order,
                    makePhoneCall: _makePhoneCall,
                    showCancelDialog: () {}, // No cancel for completed orders
                  );
                },
              ),
            );
          }

          if (state is OrderError) {
            return Center(child: Text(state.message));
          }

          return const Center(child: Text('Something went wrong'));
        },
      ),
    );
  }
}

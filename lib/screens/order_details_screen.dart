import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/order_model.dart';
import '../blocs/order/order_bloc.dart';

class OrderDetailsScreen extends StatelessWidget {
  final OrderModel order;
  final bool isAvailable;

  const OrderDetailsScreen({
    super.key,
    required this.order,
    this.isAvailable = false,
  });

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.ready:
        return Colors.orange.shade400;
      case OrderStatus.reachedRestaurant:
        return Colors.purple.shade400;
      case OrderStatus.assigned:
        return Colors.green.shade400;
      case OrderStatus.onTheWay:
        return Colors.blue.shade400;
      case OrderStatus.upcoming:
        return Colors.green.shade400;
      case OrderStatus.delivered:
        return Colors.grey.shade400;
      case OrderStatus.cancelled:
        return Colors.red.shade400;
    }
  }

  Future<void> _makePhoneCall(BuildContext context) async {
    final url = Uri.parse('tel:${order.customerPhone}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not make phone call')),
        );
      }
    }
  }

  Future<void> _launchMaps(BuildContext context) async {
    final url = Uri.parse(
      'https://www.google.com/maps/search/${order.address}',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not open maps')));
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
          'Order Details',
          style: GoogleFonts.roboto(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<OrderBloc, OrderState>(
        listener: (context, state) {
          if (state is OrderError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red.shade900,
              ),
            );
          }
        },
        builder: (context, state) {
          OrderModel currentOrder = order;

          // If we have a loaded state, try to find the updated order
          if (state is OrderLoaded) {
            final allOrders = [
              ...state.availableOrders,
              ...state.activeOrders,
              ...state.completedOrders,
            ];
            try {
              currentOrder = allOrders.firstWhere((o) => o.id == order.id);
            } catch (e) {
              // Order might have moved or disappeared, stay with passed order or handle
            }
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                // Order status card
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(20),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: _getStatusColor(currentOrder.status),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            currentOrder.statusText,
                            style: GoogleFonts.roboto(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _getStatusColor(currentOrder.status),
                            ),
                          ),
                        ],
                      ),
                      if (currentOrder.statusDescription != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          currentOrder.statusDescription!,
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            color: Colors.grey[700],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                      if (currentOrder.progressPercentage != null) ...[
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: currentOrder.progressPercentage! / 100,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getStatusColor(currentOrder.status),
                            ),
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Progress',
                              style: GoogleFonts.roboto(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                            Text(
                              '${currentOrder.progressPercentage}%',
                              style: GoogleFonts.roboto(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: _getStatusColor(currentOrder.status),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 16),
                      Text(
                        currentOrder.formattedDate,
                        style: GoogleFonts.roboto(
                          fontSize: 13,
                          color: Colors.grey[500],
                        ),
                      ),
                      if (currentOrder.estimatedArrivalTime != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.timer_outlined,
                              size: 14,
                              color: Colors.orange.shade700,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Est. Arrival: ${currentOrder.estimatedArrivalTime}',
                              style: GoogleFonts.roboto(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade700,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      Text(
                        'Order ID',
                        style: GoogleFonts.roboto(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currentOrder.id,
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Customer details card
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(20),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Customer Details',
                        style: GoogleFonts.roboto(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.grey[300],
                            child: Icon(
                              Icons.person,
                              color: Colors.grey[600],
                              size: 35,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  currentOrder.customerName,
                                  style: GoogleFonts.roboto(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.phone,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      currentOrder.customerPhone,
                                      style: GoogleFonts.roboto(
                                        fontSize: 14,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => _makePhoneCall(context),
                            icon: Icon(
                              Icons.call,
                              color: Colors.green.shade600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      Text(
                        'Delivery Address',
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 20,
                            color: Colors.red.shade700,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              currentOrder.address,
                              style: GoogleFonts.roboto(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: () => _launchMaps(context),
                          icon: const Icon(Icons.map, color: Colors.white),
                          label: Text(
                            'Open in Maps',
                            style: GoogleFonts.roboto(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade700,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Order items card (placeholder)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(20),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order Summary',
                        style: GoogleFonts.roboto(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const SizedBox(height: 16),
                      if (currentOrder.items.isEmpty)
                        Text(
                          "No item details available",
                          style: GoogleFonts.roboto(
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        )
                      else
                        ...currentOrder.items.map((item) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: _buildOrderItem(
                              "Item #${item.menuItemId}",
                              item.quantity,
                              item.price,
                            ),
                          );
                        }),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Amount',
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            '₹${currentOrder.totalAmount.toStringAsFixed(2)}',

                            style: GoogleFonts.roboto(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Timeline card
                if (currentOrder.timeline != null &&
                    currentOrder.timeline!.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(20),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order Timeline',
                          style: GoogleFonts.roboto(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: currentOrder.timeline!.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final step = currentOrder.timeline![index];
                            return Row(
                              children: [
                                Column(
                                  children: [
                                    Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: step.isCompleted
                                            ? Colors.green
                                            : Colors.grey[300],
                                        shape: BoxShape.circle,
                                      ),
                                      child: step.isCompleted
                                          ? const Icon(
                                              Icons.check,
                                              size: 12,
                                              color: Colors.white,
                                            )
                                          : null,
                                    ),
                                    if (index !=
                                        currentOrder.timeline!.length - 1)
                                      Container(
                                        width: 2,
                                        height: 30,
                                        color: step.isCompleted
                                            ? Colors.green
                                            : Colors.grey[200],
                                      ),
                                  ],
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        step.title,
                                        style: GoogleFonts.roboto(
                                          fontSize: 14,
                                          fontWeight: step.isCurrent
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          color: step.isCompleted
                                              ? Colors.black87
                                              : Colors.grey[400],
                                        ),
                                      ),
                                      Text(
                                        step.subtitle,
                                        style: GoogleFonts.roboto(
                                          fontSize: 12,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  step.time,
                                  style: GoogleFonts.roboto(
                                    fontSize: 12,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                // Action Buttons Section
                if (currentOrder.status == OrderStatus.ready ||
                    currentOrder.status == OrderStatus.reachedRestaurant ||
                    currentOrder.status == OrderStatus.assigned ||
                    currentOrder.status == OrderStatus.onTheWay ||
                    currentOrder.status == OrderStatus.upcoming)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        // Cancel Button
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              _showCancelDialog(context);
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: Colors.grey[300]!,
                                width: 1.5,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Primary Action Button
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: () {
                              if (isAvailable) {
                                context.read<OrderBloc>().add(
                                  AcceptOrderRequested(currentOrder.id),
                                );
                                Navigator.pop(context);
                              } else if (currentOrder.status ==
                                  OrderStatus.onTheWay) {
                                context.read<OrderBloc>().add(
                                  CompleteOrderRequested(currentOrder.id),
                                );
                                Navigator.pop(context);
                              } else if (currentOrder.status ==
                                      OrderStatus.upcoming ||
                                  currentOrder.status == OrderStatus.assigned) {
                                context.read<OrderBloc>().add(
                                  ReachRestaurantRequested(currentOrder.id),
                                );
                                Navigator.pop(context);
                              } else if (currentOrder.status ==
                                      OrderStatus.ready ||
                                  currentOrder.status ==
                                      OrderStatus.reachedRestaurant) {
                                context.read<OrderBloc>().add(
                                  PickupOrderRequested(currentOrder.id),
                                );
                                Navigator.pop(context);
                              }
                            },

                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade700,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              isAvailable
                                  ? 'Accept Order'
                                  : (currentOrder.status == OrderStatus.onTheWay
                                        ? 'Complete Delivery'
                                        : (currentOrder.status ==
                                                      OrderStatus.upcoming ||
                                                  currentOrder.status ==
                                                      OrderStatus.assigned
                                              ? 'Reached Restaurant'
                                              : 'Pick Up Order')),

                              style: GoogleFonts.roboto(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Order'),
        content: const Text('Are you sure you want to cancel this order?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              context.read<OrderBloc>().add(CancelOrderRequested(order.id));
              Navigator.of(ctx).pop();
              Navigator.of(context).pop(); // Back to list
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(String name, int quantity, double price) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            '$quantity x $name',
            style: GoogleFonts.roboto(fontSize: 14, color: Colors.grey[700]),
          ),
        ),
        Text(
          '₹${(price * quantity).toStringAsFixed(2)}',

          style: GoogleFonts.roboto(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

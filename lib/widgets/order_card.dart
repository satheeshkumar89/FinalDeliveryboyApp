import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/order_model.dart';
import '../screens/order_details_screen.dart';
import '../blocs/order/order_bloc.dart'; // Needed for event usage if I move button logic here?
// Actually OrderCard takes callbacks for actions.

class OrderCard extends StatelessWidget {
  final OrderModel order;
  final Function(String) makePhoneCall;
  final VoidCallback showCancelDialog;
  final bool isAvailable;

  const OrderCard({
    super.key,
    required this.order,
    required this.makePhoneCall,
    required this.showCancelDialog,
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

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: _getStatusColor(order.status),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          order.statusText,
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: _getStatusColor(order.status),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      order.formattedDate,
                      style: GoogleFonts.roboto(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.fastfood,
                        color: Colors.orange.shade700,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.restaurantName,
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Order #${order.orderNumber}',
                            style: GoogleFonts.roboto(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '₹${order.totalAmount.toStringAsFixed(2)}',
                      style: GoogleFonts.roboto(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (order.progressPercentage != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: order.progressPercentage! / 100,
                      backgroundColor: Colors.grey[100],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getStatusColor(order.status),
                      ),
                      minHeight: 4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '${order.progressPercentage}%',
                        style: GoogleFonts.roboto(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(order.status),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.location_on, size: 20, color: Colors.grey[400]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        order.address,
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrderDetailsScreen(
                                order: order,
                                isAvailable: isAvailable,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.info_outline),
                        label: const Text('Details'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey[700],
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () => makePhoneCall(order.customerPhone),
                        icon: const Icon(Icons.call),
                        label: const Text('Call'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.green.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
                if (order.status == OrderStatus.ready ||
                    order.status == OrderStatus.reachedRestaurant ||
                    order.status == OrderStatus.assigned ||
                    order.status == OrderStatus.onTheWay ||
                    order.status == OrderStatus.upcoming)
                  const SizedBox(height: 12),
                if (order.status == OrderStatus.ready ||
                    order.status == OrderStatus.reachedRestaurant ||
                    order.status == OrderStatus.assigned ||
                    order.status == OrderStatus.onTheWay ||
                    order.status == OrderStatus.upcoming)
                  // Action buttons
                  Row(
                    children: [
                      // Cancel button
                      Expanded(
                        child: OutlinedButton(
                          onPressed: showCancelDialog,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: Colors.grey[300]!,
                              width: 1.5,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.roboto(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Action Button (Accept/Complete)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (isAvailable) {
                              context.read<OrderBloc>().add(
                                AcceptOrderRequested(order.id),
                              );
                            } else if (order.status == OrderStatus.onTheWay) {
                              context.read<OrderBloc>().add(
                                CompleteOrderRequested(order.id),
                              );
                            } else if (order.status == OrderStatus.upcoming ||
                                order.status == OrderStatus.assigned) {
                              context.read<OrderBloc>().add(
                                ReachRestaurantRequested(order.id),
                              );
                            } else if (order.status == OrderStatus.ready ||
                                order.status == OrderStatus.reachedRestaurant) {
                              context.read<OrderBloc>().add(
                                PickupOrderRequested(order.id),
                              );
                            }
                          },

                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade700,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: Text(
                            isAvailable
                                ? 'Accept Order'
                                : (order.status == OrderStatus.onTheWay
                                      ? 'Complete Delivery'
                                      : (order.status == OrderStatus.upcoming ||
                                                order.status ==
                                                    OrderStatus.assigned
                                            ? 'Reached Restaurant'
                                            : 'Pick Up Order')),

                            style: GoogleFonts.roboto(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../providers/auth_provider.dart';
import '../models/order_model.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/order/order_bloc.dart';
import 'phone_login_screen.dart';
import 'my_deliveries_screen.dart';
import 'my_earnings_screen.dart';
import 'notification_screen.dart';
import 'profile_screen.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../widgets/order_card.dart';
import '../blocs/location/location_bloc.dart';
import '../blocs/location/location_event.dart';
import '../blocs/location/location_state.dart';
import '../core/services/push_notification_service.dart';
import '../blocs/notification/notification_bloc.dart';
import '../blocs/notification/notification_event.dart';

import 'package:flutter/services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;
  Timer? _locationTimer;
  final PushNotificationService _pushNotificationService =
      PushNotificationService();
  StreamSubscription<RemoteMessage>? _notificationSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabSelection);

    // Initial fetch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderBloc>().add(GetAvailableOrdersRequested());
      context.read<OrderBloc>().add(GetActiveOrdersRequested());
      context.read<LocationBloc>().add(GetCurrentLocationRequested());
      _initializePushNotifications();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Automatic refresh when user brings app back to foreground
    if (state == AppLifecycleState.resumed) {
      print('☀️ App Resumed: Triggering automatic order refresh...');
      context.read<OrderBloc>().add(RefreshOrdersRequested());
    }
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      if (_tabController.index == 0) {
        context.read<OrderBloc>().add(GetAvailableOrdersRequested());
      } else {
        context.read<OrderBloc>().add(GetActiveOrdersRequested());
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.removeListener(_handleTabSelection);
    _notificationSubscription?.cancel();
    _stopLocationTracking();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initializePushNotifications() async {
    await _pushNotificationService.initialize();
    final token = await _pushNotificationService.getToken();
    if (token != null) {
      if (mounted) {
        context.read<NotificationBloc>().add(
          RegisterDeviceTokenRequested(token),
        );
      }
    }

    _pushNotificationService.onTokenRefresh.listen((token) {
      if (mounted) {
        context.read<NotificationBloc>().add(
          RegisterDeviceTokenRequested(token),
        );
      }
    });

    _pushNotificationService.listenForegroundMessages();

    // Cancel existing subscription if any to prevent duplicates during Hot Restart
    await _notificationSubscription?.cancel();

    // Listen to real-time refresh triggers
    _notificationSubscription = _pushNotificationService.onMessage.listen((
      message,
    ) {
      if (mounted) {
        final data = message.data;
        final type = data['notification_type'] ?? data['type'] ?? 'unknown';
        print('📨 FCM Received in HomeScreen: $type | Data: $data');

        // FORCE REFRESH: On ANY notification message, update the state
        print('🔄 Automatic Refresh Triggered by FCM [$type]');
        context.read<OrderBloc>().add(RefreshOrdersRequested());

        // Provide smart feedback based on keys or presence of notification body
        if (type == 'new_available_order' ||
            type.contains('ready') ||
            message.notification != null) {
          HapticFeedback.heavyImpact();

          String alertText = 'Order update received';
          if (type == 'new_available_order')
            alertText = '✨ New order available!';
          if (type.contains('ready'))
            alertText = '🛍️ Order is ready for pickup!';
          if (message.notification?.title != null) {
            alertText = message.notification!.title!;
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(alertText),
              backgroundColor: Colors.red.shade900,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                label: 'VIEW',
                textColor: Colors.white,
                onPressed: () {
                  // Stay on current tab or logic to switch
                },
              ),
            ),
          );
        } else {
          HapticFeedback.lightImpact();
        }
      }
    });
  }

  void _startLocationTracking() {
    _stopLocationTracking(); // Ensure any existing timer is cancelled
    _locationTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      final hasPermission = await _handleLocationPermission();
      if (!hasPermission) return;

      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        if (mounted) {
          // Find active order ID if any
          int activeOrderId = 0;
          final orderState = context.read<OrderBloc>().state;
          if (orderState is OrderLoaded && orderState.activeOrders.isNotEmpty) {
            // Assuming we track for the first active order for now or 0 if general update
            // Logic might need refinement to pick specific order being delivered
            activeOrderId = int.tryParse(orderState.activeOrders.first.id) ?? 0;
          }

          context.read<LocationBloc>().add(
            LocationUpdateRequested(
              latitude: position.latitude,
              longitude: position.longitude,
              heading: position.heading < 0 ? 0.0 : position.heading,
              accuracy: position.accuracy,
              speed: position.speed < 0 ? 0.0 : position.speed,
              orderId: activeOrderId,
            ),
          );
          print(
            "📍 Location updated: ${position.latitude}, ${position.longitude}",
          );
        }
      } catch (e) {
        print("Error getting location: $e");
      }
    });
  }

  void _stopLocationTracking() {
    _locationTimer?.cancel();
    _locationTimer = null;
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Location services are disabled. Please enable the services',
            ),
          ),
        );
      }
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')),
          );
        }
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Location permissions are permanently denied, we cannot request permissions.',
            ),
          ),
        );
      }
      return false;
    }

    return true;
  }

  void _showCancelDialog(BuildContext context, String orderId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Order'),
        content: const Text('Are you sure you want to cancel this order?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              context.read<OrderBloc>().add(CancelOrderRequested(orderId));
              Navigator.of(ctx).pop();
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
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
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        title: Text(
          'FOOD DELIVERY',
          style: GoogleFonts.roboto(
            color: Colors.red.shade700,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        centerTitle: true,
        actions: [
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthAuthenticated) {
                // Start tracking if online, stop if offline
                // Ideally this side effect should be in a Listener, but simple check here works
                // to sync persistent state.
                // However, builder runs often, so we should be careful not to restart timer loop constantly.
                // Better approach: Use a BlocListener for side effects.
                // For now, let's just trigger in onChanged and initState/listener.

                return Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Row(
                    children: [
                      Text(
                        state.deliveryBoy.isActive ? 'Online' : 'Offline',
                        style: TextStyle(
                          color: state.deliveryBoy.isActive
                              ? Colors.green
                              : Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Switch(
                        value: state.deliveryBoy.isActive,
                        onChanged: (value) {
                          context.read<AuthBloc>().add(
                            StatusToggleRequested(value),
                          );
                          if (value) {
                            _startLocationTracking();
                            // Refresh orders when going online
                            context.read<OrderBloc>().add(
                              RefreshOrdersRequested(),
                            );
                            // Re-register token just to be sure
                            _pushNotificationService.getToken().then((token) {
                              if (token != null && mounted) {
                                context.read<NotificationBloc>().add(
                                  RegisterDeviceTokenRequested(token),
                                );
                              }
                            });
                          } else {
                            _stopLocationTracking();
                          }
                        },
                        activeColor: Colors.green,
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.red.shade700,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.red.shade700,
          tabs: const [
            Tab(text: 'Available Orders'),
            Tab(text: 'Active Orders'),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.red.shade700),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 40, color: Colors.red),
                  ),
                  const SizedBox(height: 10),
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, _) {
                      return Text(
                        authProvider.deliveryBoy?.name ?? 'Delivery Boy',
                        style: GoogleFonts.roboto(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('My Profile'),
              onTap: () {
                Navigator.pop(context); // Close drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications_active_outlined),
              title: const Text('Notifications'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delivery_dining),
              title: const Text('My Deliveries'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyDeliveriesScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_balance_wallet_outlined),
              title: const Text('My Earnings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyEarningsScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () {
                final authProvider = Provider.of<AuthProvider>(
                  context,
                  listen: false,
                );
                authProvider.logout();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const PhoneLoginScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthAuthenticated) {
                if (state.deliveryBoy.isActive) {
                  _startLocationTracking();
                } else {
                  _stopLocationTracking();
                }
              }
            },
          ),
          BlocListener<LocationBloc, LocationState>(
            listener: (context, state) {
              if (state is LocationLoaded) {
                print(
                  "📍 Initial Location Fetched: ${state.location?.latitude}, ${state.location?.longitude}",
                );
              }
            },
          ),
        ],
        child: BlocConsumer<OrderBloc, OrderState>(
          listener: (context, state) {
            if (state is OrderError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (context, state) {
            if (state is OrderLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is OrderLoaded) {
              return TabBarView(
                controller: _tabController,
                children: [
                  _buildOrderList(state.availableOrders, isAvailableTab: true),
                  _buildOrderList(state.activeOrders, isAvailableTab: false),
                ],
              );
            }

            return const Center(child: Text("Pull to refresh"));
          },
        ),
      ),
    );
  }

  Widget _buildOrderList(
    List<OrderModel> orders, {
    required bool isAvailableTab,
  }) {
    return RefreshIndicator(
      onRefresh: () async {
        final orderBloc = context.read<OrderBloc>();
        if (isAvailableTab) {
          orderBloc.add(GetAvailableOrdersRequested());
        } else {
          orderBloc.add(GetActiveOrdersRequested());
        }

        // Wait for next state change or a timeout to complete the refresh indicator
        await orderBloc.stream
            .firstWhere((state) => state is OrderLoaded || state is OrderError)
            .timeout(
              const Duration(seconds: 10),
              onTimeout: () => orderBloc.state,
            );
      },
      child: orders.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          isAvailableTab
                              ? 'No available orders'
                              : 'No active orders',
                          style: GoogleFonts.roboto(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Pull down to refresh',
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return OrderCard(
                  order: order,
                  isAvailable: isAvailableTab,
                  makePhoneCall: _makePhoneCall,
                  showCancelDialog: () => _showCancelDialog(context, order.id),
                );
              },
            ),
    );
  }
}

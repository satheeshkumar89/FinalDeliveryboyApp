import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
// import 'providers/order_provider.dart'; // No longer needed
import 'package:firebase_core/firebase_core.dart';
import 'repositories/auth_repository.dart';
import 'repositories/order_repository.dart';
import 'repositories/notification_repository.dart';
import 'blocs/auth/auth_bloc.dart';
import 'blocs/order/order_bloc.dart';
import 'blocs/earnings/earnings_bloc.dart';
import 'blocs/location/location_bloc.dart';
import 'blocs/notification/notification_bloc.dart';
import 'blocs/notification/notification_event.dart';
import 'core/utils/navigator_service.dart';
import 'screens/splash_screen.dart';
import 'core/services/push_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Initialize Push Notifications early
  final pushService = PushNotificationService();
  await pushService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => AuthRepository()),
        RepositoryProvider(create: (context) => OrderRepository()),
        RepositoryProvider(create: (context) => NotificationRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) =>
                AuthBloc(authRepository: context.read<AuthRepository>()),
          ),
          BlocProvider<OrderBloc>(
            create: (context) =>
                OrderBloc(orderRepository: context.read<OrderRepository>()),
          ),
          BlocProvider<EarningsBloc>(
            create: (context) =>
                EarningsBloc(orderRepository: context.read<OrderRepository>()),
          ),
          BlocProvider<LocationBloc>(
            create: (context) =>
                LocationBloc(orderRepository: context.read<OrderRepository>()),
          ),
          BlocProvider<NotificationBloc>(
            create: (context) => NotificationBloc(
              notificationRepository: context.read<NotificationRepository>(),
            ),
          ),
        ],
        child: MultiProvider(
          providers: [ChangeNotifierProvider(create: (_) => AuthProvider())],
          child: BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthAuthenticated) {
                print(
                  '🔔 Global Auth Listener: User authenticated, registering token and joining rooms...',
                );

                // Register FCM token
                PushNotificationService().getToken().then((token) {
                  if (token != null) {
                    context.read<NotificationBloc>().add(
                      RegisterDeviceTokenRequested(token),
                    );
                  }
                });
              }
            },
            child: MaterialApp(
              title: 'Dharai Delivery Boy',
              debugShowCheckedModeBanner: false,
              navigatorKey: navigatorKey,
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: Colors.red.shade700,
                  primary: Colors.red.shade700,
                ),
                useMaterial3: true,
                scaffoldBackgroundColor: Colors.white,
              ),
              home: const SplashScreen(),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'providers/auth_provider.dart';
import 'providers/team_provider.dart';
import 'providers/program_provider.dart';
import 'providers/intensity_provider.dart';
import 'providers/reminder_provider.dart';
import 'providers/leaderboard_provider.dart';
import 'providers/training_log_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/security_provider.dart';
import 'services/notification_service.dart';
import 'ui/authentication/auth_page.dart';
import 'ui/authentication/login_page.dart';
import 'ui/authentication/register_page.dart';
import 'ui/authentication/email_verification_page.dart';
import 'ui/authentication/forgot_password_page.dart';
import 'ui/authentication/splash_screen.dart';
import 'ui/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Initialize locale data for Indonesian
  await initializeDateFormatting('id_ID', null);

  // Initialize notification service in background, don't wait
  NotificationService.initialize().catchError((error) {
    print('Notification service failed to initialize: $error');
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TeamProvider()),
        ChangeNotifierProvider(create: (_) => ProgramProvider()),
        ChangeNotifierProvider(create: (_) => IntensityProvider()),
        ChangeNotifierProvider(create: (_) => ReminderProvider()),
        ChangeNotifierProvider(create: (_) => LeaderboardProvider()),
        ChangeNotifierProvider(create: (_) => TrainingLogProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => SecurityProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Trainix App',
        theme: ThemeData(
          fontFamily: 'Poppins',
        ),
        // Add locale support
        locale: const Locale('id', 'ID'),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('id', 'ID'), // Indonesian
          Locale('en', 'US'), // English (fallback)
        ],
        home: const AuthWrapper(),
        routes: {
          '/login': (context) => const LoginPage(),
          '/register': (context) => const RegisterPage(),
          '/forgot-password': (context) => const ForgotPasswordPage(),
          '/email-verification': (context) {
            final args = ModalRoute.of(context)!.settings.arguments
                as Map<String, dynamic>;
            return EmailVerificationPage(
              email: args['email'],
              name: args['name'],
            );
          },
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isLoading) {
          return const SplashScreen();
        }

        if (authProvider.isLoggedIn) {
          // Update FCM token when user logs in
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
            notificationProvider.updateFCMToken(authProvider.user?.uid ?? '');
          });
          
          return const MainScreen();
        }

        return const AuthPage();
      },
    );
  }
}

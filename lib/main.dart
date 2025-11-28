import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';

// Screens
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/email_setup.dart';
import 'screens/email_verification_screen.dart';
import 'screens/user_home_screen.dart';
import 'screens/xray_upload_screen.dart';
import 'screens/specialist_list_screen.dart';
import 'screens/dentist_registration_screen.dart';
import 'screens/ai_results_screen.dart';
import 'screens/analyse_xray.dart';
import 'screens/oral_health_tracker.dart';
import 'screens/emergency_dentel_screen.dart';
import 'screens/dentist_registration_success_screen.dart';
import 'screens/doctor_dashboard_screen.dart';
import 'screens/doctor_choice_screen.dart';
import 'screens/doctor_login_screen.dart';
import 'screens/edit_doctor_profile_screen.dart';
import 'screens/appointment_screen.dart';
import 'screens/notification_service.dart';
import 'screens/user_appointment_screen.dart';
import 'screens/payment_screen.dart' as payment;
import 'screens/admin_approval_screen.dart';

// 🔔 Firebase Background Message Handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Ensure Firebase is initialized for background messages
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('🔔 Background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(DentXpertAIApp());
}

class DentXpertAIApp extends StatefulWidget {
  @override
  State<DentXpertAIApp> createState() => _DentXpertAIAppState();
}

class _DentXpertAIAppState extends State<DentXpertAIApp> {
  @override
  void initState() {
    super.initState();
    _initFirebaseMessaging();
  }

  Future<void> _initFirebaseMessaging() async {
    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(alert: true, badge: true, sound: true);
    final token = await messaging.getToken();
    debugPrint('📲 FCM Token: $token');

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('📥 Foreground message: ${message.notification?.title}');
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('📲 Notification clicked');
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DentXpertAI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF002B5B),
          brightness: Brightness.dark,
          primary: const Color(0xFF002B5B),
          secondary: const Color(0xFF00E0FF),
        ),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/home': (context) => HomeScreen(),
        '/userEmailInput': (context) => EmailSetupScreen(),
        // ❌ REMOVED: '/emailVerification' moved to onGenerateRoute for argument handling
        '/userHome': (context) => UserHomeScreen(),
        '/xrayUpload': (context) => XrayUploadScreen(),
        '/specialistList': (context) => SpecialistListScreen(),
        '/dentistRegistration': (context) => DentistRegistrationScreen(),
        // ❌ REMOVED: '/registrationSuccess' moved to onGenerateRoute
        '/doctorChoice': (context) => DoctorChoiceScreen(),
        '/doctorLogin': (context) => const DoctorLoginScreen(),
        '/analysisXray': (context) => AnalyseXray(),
        '/oralHealthTracker': (context) => OralHealthTrackerScreen(),
        '/emergencyDental': (context) => EmergencyDentalScreen(),
        '/appointments': (context) => const UserAppointmentsScreen(),
        '/adminApproval': (context) => const AdminApprovalScreen(),
      },
      onGenerateRoute: (settings) {
        final args = settings.arguments as Map<String, dynamic>?; // Safely cast arguments

        switch (settings.name) {
        // ✅ ADDED: Handler for Email Verification Screen
          case '/emailVerification':
          // Pass safely retrieved values, using empty string/false as defaults
            return MaterialPageRoute(
              builder: (context) => EmailVerificationScreen(
                email: args?['email'] ?? '',
                isLinkSent: args?['isLinkSent'] ?? false,
              ),
            );
          case '/aiResults':
            return MaterialPageRoute(
              builder: (context) => AIResultsScreen(
                analysisData: args ?? {},
              ),
            );
          case '/appointment':
            return MaterialPageRoute(
              builder: (context) => AppointmentScreen(
                doctor: args?['doctor'],
              ),
            );
          case '/payment':
            return MaterialPageRoute(
              builder: (context) => payment.PaymentScreen(
                appointmentId: args?['appointmentId'] ?? '',
                appointmentData: args?['appointmentData'] ?? {},
              ),
            );
          case '/registrationSuccess':
            return MaterialPageRoute(
              builder: (context) => DentistRegistrationSuccessScreen(
                name: args?['name'] ?? 'Doctor',
                specialization: args?['specialization'] ?? 'Dentist',
              ),
            );
          case '/doctorDashboard':
            final email = args?['email'];
            return MaterialPageRoute(
              builder: (context) => DoctorDashboardScreen(
                doctorEmail: email ?? '',
              ),
            );
          case '/editDoctorProfile':
            final email = args?['email'];
            return MaterialPageRoute(
              builder: (context) => EditDoctorProfileScreen(
                doctorEmail: email ?? '',
              ),
            );
        }

        return _errorPage("Page not found");
      },
      onUnknownRoute: (_) => _errorPage("Unknown route"),
    );
  }

  MaterialPageRoute _errorPage(String message) {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        backgroundColor: const Color(0xFF0B132B),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(message, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/home'),
                child: const Text('Return to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
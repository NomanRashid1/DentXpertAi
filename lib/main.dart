import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';

// Screens - WITH PROPER ALIASES TO AVOID CONFLICTS
// ... (screens jahan hain wahin rehne dein)
import 'screens/email_setup.dart';
import 'screens/email_verification_screen.dart' as verification;
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/user_home_screen.dart' as user_home;
import 'screens/xray_upload/xray_upload_screen.dart';
import 'screens/specialist_list_screen.dart';
import 'screens/dentist_registration_screen.dart';
import 'screens/ai_results_screen.dart';
import 'screens/analyse_xray.dart';
import 'screens/oral_health_tracker.dart';
import 'screens/emergency_dentel_screen.dart';
import 'screens/dentist_registration_success_screen.dart' as success_screen;
import 'screens/doctor_dashboard_screen.dart';
import 'screens/doctor_choice_screen.dart';
import 'screens/doctor_login_screen.dart';
import 'screens/edit_doctor_profile_screen.dart';
import 'screens/appointment_screen.dart';
import 'screens/user_appointment_screen.dart';
import 'screens/payment_screen.dart' as payment;
import 'screens/admin_approval_screen.dart';
import 'screens/appoinment_detail_screen.dart';
import 'screens/doctor_appointment_screen.dart';
import 'screens/patient_profile_screen.dart';

// 🔔 Firebase Background Message Handler
// 🎯 FIX: Sirf initialize ki line hata di gayi hai
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // ⚠️ Agar app background mein (killed state) ho, toh initialize ki zaroorat pad sakti hai.
  // Lekin is waqt aapke duplicate error ko theek karne ke liye isay remove kar diya hai.
  // Agar aapko background messages mein future mein masla aaye toh is line ko dobara daalna hoga.
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint("Handling a background message: ${message.messageId}");
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
// ... (Baki ka sara code jaisa hai waisa hi rahega)

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DentXpertAI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF001F3F),
        primaryColor: const Color(0xFF00E0FF),
        textTheme: const TextTheme(
          titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          bodyMedium: TextStyle(color: Colors.white70),
          labelLarge: TextStyle(color: Colors.black),
        ),
        appBarTheme: const AppBarTheme(
          color: Color(0xFF001F3F),
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.cyanAccent,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.cyanAccent),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.cyanAccent,
            foregroundColor: Colors.black,
          ),
        ),
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        final args = settings.arguments as Map<String, dynamic>?;

        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (context) => const SplashScreen());

          case '/home':
            return MaterialPageRoute(builder: (context) => const HomeScreen());

          case '/userHome':
            return MaterialPageRoute(
              builder: (context) => const user_home.UserHomeScreen(),
            );

          case '/userEmailInput':
            return MaterialPageRoute(
              builder: (context) => const EmailSetupScreen(),
            );

          case '/emailVerification':
            final email = args?['email'] as String? ?? '';
            final isLinkSent = args?['isLinkSent'] as bool? ?? false;
            return MaterialPageRoute(
              builder: (context) => verification.EmailVerificationScreen(
                email: email,
                isLinkSent: isLinkSent,
              ),
            );

          case '/xrayUpload':
            return MaterialPageRoute(
                builder: (context) => const XrayUploadScreen());

          case '/specialistList':
            return MaterialPageRoute(
                builder: (context) => const SpecialistListScreen());

          case '/dentistRegistration':
            return MaterialPageRoute(
                builder: (context) => const DentistRegistrationScreen());

          case '/aiResults':
            final analysisData = args?['analysisData'];
            if (analysisData == null) return _errorPage("Analysis data missing");
            return MaterialPageRoute(
              builder: (context) => AIResultsScreen(analysisData: analysisData),
            );

          case '/analyseXray':
            return MaterialPageRoute(builder: (context) => const AnalyseXray());

          case '/healthTracker':
            return MaterialPageRoute(
                builder: (context) => const OralHealthTrackerScreen());

          case '/emergency':
            return MaterialPageRoute(
                builder: (context) => const EmergencyDentalScreen());

          case '/registrationSuccess':
            final name = args?['name'];
            final specialization = args?['specialization'];
            if (name == null || specialization == null) {
              return _errorPage("Name/Specialization missing");
            }
            return MaterialPageRoute(
              builder: (context) => success_screen.DentistRegistrationSuccessScreen(
                name: name as String,
                specialization: specialization as String,
              ),
            );

          case '/doctorChoice':
            return MaterialPageRoute(
                builder: (context) => const DoctorChoiceScreen());

          case '/doctorLogin':
            return MaterialPageRoute(
                builder: (context) => const DoctorLoginScreen());

          case '/adminApproval':
            return MaterialPageRoute(
                builder: (context) => const AdminApprovalScreen());

          case '/appointment':
            final doctor = args?['doctor'];
            if (doctor == null) return _errorPage("Doctor data missing");
            return MaterialPageRoute(
              builder: (context) => AppointmentScreen(doctor: doctor),
            );

          case '/userAppointments':
            return MaterialPageRoute(
                builder: (context) => const UserAppointmentsScreen());

          case '/appointmentDetails':
            final email = args?['userEmail'];
            if (email == null) return _errorPage("User email missing");
            return MaterialPageRoute(
                builder: (context) => AppointmentDetailScreen(userEmail: email as String));

          case '/doctorAppointments':
            final email = args?['doctorEmail'];
            if (email == null) return _errorPage("Doctor email missing");
            return MaterialPageRoute(
                builder: (context) =>
                    DoctorAppointmentsScreen(doctorEmail: email as String));

          case '/patientProfile':
            final appointmentData = args?['appointmentData'];
            // 🎯 FIX: appointmentId ko arguments se nikalen.
            final appointmentId = args?['appointmentId'] as String?;

            if (appointmentData == null) return _errorPage("Appointment data missing");
            // 🎯 FIX: ID required hai, isliye check zaroori hai.
            if (appointmentId == null) return _errorPage("Appointment ID missing");

            return MaterialPageRoute(
                builder: (context) =>
                    PatientProfileScreen(
                      appointmentData: appointmentData,
                      appointmentId: appointmentId, // <--- Required parameter pass kiya gaya
                    ));

          case '/payment':
            final appointmentData = args?['appointmentData'];
            final appointmentId = args?['appointmentId'];
            if (appointmentData == null || appointmentId == null) {
              return _errorPage("Payment data missing");
            }
            return MaterialPageRoute(
              builder: (context) => payment.PaymentScreen(
                appointmentData: appointmentData,
                appointmentId: appointmentId as String,
              ),
            );

          case '/doctorDashboard':
            final email = args?['email'];
            if (email == null) return _errorPage("Doctor email missing");
            return MaterialPageRoute(
              builder: (context) => DoctorDashboardScreen(doctorEmail: email as String),
            );

          case '/editDoctorProfile':
            final email = args?['email'];
            if (email == null) return _errorPage("Doctor email missing");
            return MaterialPageRoute(
              builder: (context) => EditDoctorProfileScreen(doctorEmail: email as String),
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
              Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
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
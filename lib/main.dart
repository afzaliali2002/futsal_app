import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

// Firebase
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

// Theme
import 'core/theme/dark_theme.dart';
import 'core/theme/light_theme.dart';

// Auth
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/screens/auth_wrapper.dart';
import 'features/auth/presentation/screens/login-screen.dart';
import 'features/auth/presentation/screens/signup_screen.dart';

// App Core
import 'features/core/presentation/screens/main_app_screen.dart';

// Futsal
import 'features/futsal/presentation/screens/tabbed_home_screen.dart';
import 'features/futsal/presentation/screens/field_detail_screen.dart';

// Booking
import 'features/booking/presentation/screens/booking_from_screen.dart';

// Profile (NEW)
import 'features/profile/presentation/providers/profile_provider.dart';
import 'features/profile/domain/usecases/get_current_user_usecase.dart';
import 'features/profile/data/profile_repository_impl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Auth Repository Injection
        Provider<AuthRepository>(
          create: (_) => AuthRepositoryImpl(FirebaseAuth.instance),
        ),

        // ⭐ Profile Provider Injection (MVVM)
        ChangeNotifierProvider(
          create: (_) => ProfileProvider(
            GetCurrentUserUseCase(
              ProfileRepositoryImpl(),
            ),
          ),
        ),
      ],

      child: MaterialApp(
        title: 'رزرو فوتسال',

        // Themes
        theme: lightTheme(),
        darkTheme: darkTheme(),
        themeMode: ThemeMode.system,

        debugShowCheckedModeBanner: false,

        // Routing
        initialRoute: '/',
        routes: {
          '/': (context) => const AuthWrapper(),
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignupScreen(),
          '/app': (context) => const MainAppScreen(),
          '/home': (context) => TabbedHomeScreen(),
          '/field-detail': (context) => FieldDetailScreen(),
          '/booking': (context) => const BookingFormScreen(),
        },

        // Localization
        locale: const Locale('fa', 'IR'),
        supportedLocales: const [
          Locale('fa', 'IR'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],

        // Force RTL globally
        builder: (context, child) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: child!,
          );
        },
      ),
    );
  }
}

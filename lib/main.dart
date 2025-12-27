import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:futsal_app/core/services/cloudinary_service.dart';
import 'package:futsal_app/core/services/notification_service.dart';
import 'package:futsal_app/features/auth/presentation/screens/home_screen.dart';
import 'package:futsal_app/features/auth/presentation/screens/auth_wrapper.dart';
import 'package:futsal_app/features/booking/data/repositories/booking_repository_impl.dart';
import 'package:futsal_app/features/booking/domain/repositories/booking_repository.dart';
import 'package:futsal_app/features/booking/presentation/view_models/booking_view_model.dart';
import 'package:futsal_app/features/core/presentation/screens/startup_screen.dart';
import 'package:futsal_app/features/futsal/data/repositories/futsal_repository_impl.dart';
import 'package:futsal_app/features/futsal/domain/repositories/futsal_repository.dart';
import 'package:futsal_app/features/futsal/domain/usecases/add_futsal_field_usecase.dart';
import 'package:futsal_app/features/futsal/domain/usecases/get_futsal_fields_usecase.dart';
import 'package:futsal_app/features/futsal/presentation/providers/futsal_view_model.dart';
import 'package:futsal_app/features/futsal/presentation/screens/add_futsal_ground_screen.dart';
import 'package:futsal_app/features/notification/data/repositories/notification_repository_impl.dart';
import 'package:futsal_app/features/notification/domain/repositories/notification_repository.dart';
import 'package:futsal_app/features/notification/domain/usecases/get_notifications_use_case.dart';
import 'package:futsal_app/features/notification/presentation/providers/notification_view_model.dart';
import 'package:futsal_app/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:futsal_app/features/profile/presentation/view_models/user_view_model.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

// Firebase
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';

// Theme
import 'core/theme/dark_theme.dart';
import 'core/theme/light_theme.dart';

// Auth
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/screens/login-screen.dart';
import 'features/auth/presentation/screens/signup_screen.dart';

// Booking
import 'features/booking/presentation/screens/booking_from_screen.dart';

// Profile
import 'features/profile/data/profile_repository_impl.dart';
import 'features/profile/domain/repositories/profile_repository.dart';
import 'features/profile/domain/usecases/get_current_user_usecase.dart';
import 'features/profile/presentation/providers/profile_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await NotificationService().initialize();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setUserOnline(true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _setUserOnline(true);
    } else if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      _setUserOnline(false);
    }
  }

  Future<void> _setUserOnline(bool isOnline) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'isOnline': isOnline});
      } catch (e) {
        debugPrint('Error updating user online status: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // AUTH
        Provider<AuthRepository>(
          create: (_) => AuthRepositoryImpl(FirebaseAuth.instance, FirebaseFirestore.instance, GoogleSignIn()),
        ),
        StreamProvider<User?>( 
          create: (context) => context.read<AuthRepository>().authStateChanges,
          initialData: null,
        ),

        // PROFILE
        Provider<ProfileRepository>(
          create: (_) => ProfileRepositoryImpl(),
        ),
        ChangeNotifierProvider(
          create: (context) => ProfileProvider(
            GetCurrentUserUseCase(context.read<ProfileRepository>()),
          ),
        ),
        ChangeNotifierProvider(
            create: (context) =>
                UserViewModel(authRepository: context.read<AuthRepository>())),

        // FUTSAL
        Provider<FutsalRepository>(
          create: (_) => FutsalRepositoryImpl(
            firestore: FirebaseFirestore.instance,
            cloudinary: cloudinary,
          ),
        ),
        Provider(
          create: (context) => GetFutsalFieldsUseCase(context.read<FutsalRepository>()),
        ),
        Provider(
          create: (context) => AddFutsalFieldUseCase(context.read<FutsalRepository>()),
        ),
        ChangeNotifierProvider(
          create: (context) => FutsalViewModel(
            getFutsalFieldsUseCase: context.read<GetFutsalFieldsUseCase>(),
            addFutsalFieldUseCase: context.read<AddFutsalFieldUseCase>(),
            futsalRepository: context.read<FutsalRepository>(),
          ),
        ),

        // BOOKING
        Provider<BookingRepository>(
          create: (_) => BookingRepositoryImpl(FirebaseFirestore.instance),
        ),
        
        // NOTIFICATION
        Provider<NotificationRepository>(
          create: (_) => NotificationRepositoryImpl(FirebaseFirestore.instance),
        ),
         Provider(
          create: (context) => GetNotificationsUseCase(context.read<NotificationRepository>()),
        ),
        ChangeNotifierProvider(
          create: (context) => NotificationViewModel(context.read<GetNotificationsUseCase>(), context.read<NotificationRepository>()),
        ),
        
        ChangeNotifierProvider(
          create: (context) => BookingViewModel(context.read<BookingRepository>(), context.read<NotificationRepository>()),
        ),
      ],
      child: MaterialApp(
        title: 'رزرو فوتسال',
        theme: lightTheme(),
        darkTheme: darkTheme(),
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,

        // ROUTING
        home: const StartupScreen(),
        routes: {
          '/signup': (context) => const SignupScreen(),
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
          '/booking': (context) => const BookingFormScreen(),
          '/add-ground': (context) => const AddFutsalGroundScreen(),
          '/onboarding': (context) => const OnboardingScreen(),
        },

        // LOCALIZATION & RTL
        locale: const Locale('fa', 'IR'),
        supportedLocales: const [
          Locale('fa', 'IR'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
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

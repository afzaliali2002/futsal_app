import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:futsal_app/features/auth/presentation/screens/home_screen.dart';
import 'package:futsal_app/features/auth/presentation/widgets/auth_wrapper.dart';
import 'package:futsal_app/features/futsal/data/repositories/futsal_repository_impl.dart';
import 'package:futsal_app/features/futsal/domain/repositories/futsal_repository.dart';
import 'package:futsal_app/features/futsal/domain/usecases/add_futsal_field_usecase.dart';
import 'package:futsal_app/features/futsal/domain/usecases/get_futsal_fields_usecase.dart';
import 'package:futsal_app/features/futsal/presentation/providers/futsal_view_model.dart';
import 'package:futsal_app/features/futsal/presentation/screens/add_futsal_ground_screen.dart';
import 'package:futsal_app/features/notification/presentation/providers/notification_view_model.dart';
import 'package:futsal_app/features/profile/presentation/view_models/user_view_model.dart';
import 'package:provider/provider.dart';

// Firebase
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'features/auth/presentation/screens/splash_screen.dart';
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

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // AUTH
        Provider<AuthRepository>(
          create: (_) => AuthRepositoryImpl(FirebaseAuth.instance, FirebaseFirestore.instance),
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
            storage: FirebaseStorage.instance,
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

        // NOTIFICATION
        ChangeNotifierProvider(
          create: (context) => NotificationViewModel(),
        ),
      ],
      child: MaterialApp(
        title: 'رزرو فوتسال',
        theme: lightTheme(),
        darkTheme: darkTheme(),
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,

        // ROUTING
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/auth-wrapper':(context) => const AuthWrapper(),
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignupScreen(),
          '/home': (context) => const HomeScreen(),
          '/booking': (context) => const BookingFormScreen(),
          '/add-ground': (context) => const AddFutsalGroundScreen(),
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

import 'package:coffeeapp/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:coffeeapp/screens/SplashScreen/splashscreen.dart';
//import 'package:flutter_dotenv/flutter_dotenv.dart';
//import 'package:flutter_stripe/flutter_stripe.dart'; 
import 'package:coffeeapp/constants/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Stripe.publishableKey = 'pk_test_51Sp0V8HhBuR1YdryQrHXMXFcOEz9zcxqTVuhbVTo6GQW28BCUuQ3R0J2k1dyAr7NUTDytoo4Mb0IRBKmt8q00RoG00fyZwDkOf';
  // await Stripe.instance.applySettings();

  //await dotenv.load();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Or control via provider if needed
      // home: MenuNavigationBar(isDark: false, selectedIndex: 0),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

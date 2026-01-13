import 'package:coffeeapp/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:coffeeapp/UI/SplashScreen/splashscreen.dart';
//import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart'; 

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  Stripe.publishableKey = 'pk_test_YOUR_PUBLISHABLE_KEY_HERE';
  await Stripe.instance.applySettings();

  //await dotenv.load();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        textTheme: Theme.of(context).textTheme.apply(
          bodyColor: Colors.orange[300],
          displayColor: Colors.orange[400],
        ),
      ),
      // home: MenuNavigationBar(isDark: false, selectedIndex: 0),
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// @dart=2.9

import 'package:devstore_project/routes/checkout.dart';
import 'package:devstore_project/routes/feed.dart';
import 'package:devstore_project/routes/persNavBar.dart';
import 'package:devstore_project/routes/categories.dart';
import 'package:devstore_project/routes/cart.dart';
import 'package:devstore_project/routes/favorites.dart';
import 'package:devstore_project/routes/orders.dart';
import 'package:devstore_project/routes/profile.dart';
import 'package:devstore_project/routes/edit_profile.dart';
import 'package:flutter/material.dart';
import 'package:devstore_project/routes/welcome.dart';
import 'package:devstore_project/routes/login.dart';
import 'package:devstore_project/routes/signup.dart';
import 'package:devstore_project/routes/notification.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:devstore_project/routes/onbording.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

int initScreen = 0;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  initScreen = await prefs.getInt("initScreen");
  await prefs.setInt("initScreen", 1);
  //FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _initialization,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print('Cannot connect to firebase: ' + snapshot.error.toString());
          }
          if (snapshot.connectionState == ConnectionState.done) {
            FlutterError.onError =
                FirebaseCrashlytics.instance.recordFlutterError;
            print('Firebase connected');
          }
          return AppBase(); //bunu if icine atmamiz lazim sanirim
        });
  }
}

class AppBase extends StatelessWidget {
  //const AppBase({Key? key}) : super(key: key);

  static FirebaseAnalytics analytics = FirebaseAnalytics();
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        navigatorObservers: <NavigatorObserver>[observer],
        initialRoute: initScreen == 0 || initScreen == null ? '/first' : '/',
        routes: {
          '/': (context) => Welcome(analytics: analytics, observer: observer),
          '/feed': (context) => FeedView(),
          '/persNavBar': (context) => persNavBar(),
          '/categories': (context) => categories(),
          '/cart': (context) => cart(),
          '/favorites': (context) => favorites(),
          '/orders': (context) => orders(),
          '/profile': (context) => Profile(),
          '/notification': (context) => notification(),
          '/first': (context) =>
              WalkthroughView(analytics: analytics, observer: observer),
          '/login': (context) =>
              LoginPage(analytics: analytics, observer: observer),
          '/signup': (context) =>
              SignUpPage(analytics: analytics, observer: observer),
          '/checkout': (context) => CheckoutView(),
          '/editProfile': (context) => editProfile(),
          
        });
  }
}
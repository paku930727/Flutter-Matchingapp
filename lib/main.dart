import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sukimachi/firebase_config.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'go_router_provider.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

Future<void> main() async {
  final firebaseEnvironment = () {
    switch (const String.fromEnvironment('FirebaseEnvironment')) {
      case 'emulator':
        return FirebaseEnvironment.emulator;
      case 'develop':
        return FirebaseEnvironment.develop;
      case 'product':
        return FirebaseEnvironment.product;
    }
  }();

  await Firebase.initializeApp(
      options: firebaseEnvironment == FirebaseEnvironment.product
          ? firebaseOptionProd
          : firebaseOptionDev);

  if (firebaseEnvironment == FirebaseEnvironment.emulator) {
    const localhost = 'localhost';
    FirebaseFirestore.instance.useFirestoreEmulator(localhost, 8080);
    FirebaseAuth.instance.useAuthEmulator(localhost, 9099);
    FirebaseStorage.instance.useStorageEmulator(localhost, 9199);
  }

  WidgetsFlutterBinding.ensureInitialized();

  // ウェブの URL　から # を除く
  usePathUrlStrategy();

  // 再読み込み時にcurrentUser情報が2秒ほどnullになるための対策
  // FirebaseUserのログイン状態が確定するまで待つ
  await FirebaseAuth.instance.userChanges().first;
  await FirebaseAnalytics.instance.logEvent(
    name: 'runApp',
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _router = ref.watch(routerProvider);
    return MaterialApp.router(
      routerDelegate: _router.routerDelegate,
      routeInformationParser: _router.routeInformationParser,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Montserrat',
      ),
    );
  }
}

enum FirebaseEnvironment {
  emulator,
  develop,
  product,
}

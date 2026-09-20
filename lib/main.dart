import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/material.dart';

import 'app/app.dart';
import 'firebase_options.dart';

const appCheckDebugToken =
    String.fromEnvironment('APP_CHECK_DEBUG_TOKEN');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseAppCheck.instance.activate(
    providerAndroid: AndroidDebugProvider(
      debugToken: appCheckDebugToken.isEmpty
          ? null
          : appCheckDebugToken,
    ),
  );

  runApp(const AivoraApp());
}

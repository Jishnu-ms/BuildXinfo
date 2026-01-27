import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

import 'LoginPage.dart';
import 'User/UserNavbar.dart';
import 'Admin/AdminNavbar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const adminUid = "V9Ki8n9EvPeKQ5LKgSrhp7ENGoo2";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // ⏳ Waiting for Firebase
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // ❌ Not logged in → Login
          if (!snapshot.hasData) {
            return const LoginPage();
          }

          // ✅ Logged in
          final user = snapshot.data!;

          // 🔐 Admin routing
          if (user.uid == adminUid) {
            return const AdminNavbar();
          }

          // ✅ NORMAL USER ROUTING (THIS WAS MISSING)
          return const UserNavbar();
        },
      ),
    );
  }
}




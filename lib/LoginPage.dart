import 'package:buildxinfo/SignUpPage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'User/UserNavbar.dart';
import 'Admin/AdminNavbar.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscure = true;
  bool _loading = false;

  static const adminUid = "V9Ki8n9EvPeKQ5LKgSrhp7ENGoo2";

  Future<void> _login() async {
    setState(() => _loading = true);
    try {
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final uid = cred.user!.uid;

      if (uid == adminUid) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminNavbar()));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const UserNavbar()));
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Login failed"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isDesktop = size.width > 900;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFCBD5FF), Color(0xFFDDE3FF), Color(0xFFEFF2FF)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isDesktop ? 1100 : 450,
              ),
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                ),
                // --- THIS FIXES THE DESKTOP ERROR ---
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Form Side
                      Expanded(
                        child: _buildLoginCard(),
                      ),
                      // Image Side (Desktop only)
                      if (isDesktop)
                        Expanded(
                          child: _buildImagePanel(),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginCard() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: const [
              Icon(Icons.home_work_rounded, color: Color(0xFF4F6EF7)),
              SizedBox(width: 8),
              Text(
                "BuildXinfo",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF4F6EF7)),
              ),
            ],
          ),
          const SizedBox(height: 36),
          const Text("Welcome Back", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text("Log in to your BuildXinfo account", style: TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 28),
          _textField(_emailController, "Email", Icons.email_outlined),
          const SizedBox(height: 16),
          _textField(_passwordController, "Password", Icons.lock_outline, isPassword: true),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              child: const Text("Forgot password?", style: TextStyle(color: Color(0xFF4F6EF7), fontSize: 13)),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: _loading ? null : _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F6EF7),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _loading
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text("Log In", style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SignUpPage()));
              },
              child: const Text("Don't have an account? Sign Up", style: TextStyle(color: Color(0xFF4F6EF7))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _textField(TextEditingController controller, String hint, IconData icon, {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? _obscure : false,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        suffixIcon: isPassword
            ? TextButton(
                onPressed: () => setState(() => _obscure = !_obscure),
                child: Text(_obscure ? "Show" : "Hide", style: const TextStyle(color: Color(0xFF4F6EF7))),
              )
            : null,
        filled: true,
        fillColor: const Color(0xFFF1F3FF),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildImagePanel() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(28),
        bottomRight: Radius.circular(28),
      ),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFD8DEFF), Color(0xFFEEF1FF)],
          ),
        ),
        child: Image.asset(
          'assets/login.png',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
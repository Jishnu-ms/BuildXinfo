import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'LoginPage.dart';
import 'User/UserNavbar.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _selectedRole = "user";
  bool _loading = false;
  bool _obscure = true;
Future<void> _signup() async {
  if (_passwordController.text != _confirmPasswordController.text) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Passwords do not match"),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  setState(() => _loading = true);

 try {
  final cred = await FirebaseAuth.instance
      .createUserWithEmailAndPassword(
    email: _emailController.text.trim(),
    password: _passwordController.text.trim(),
  );

  await FirebaseFirestore.instance
      .collection('users')
      .doc(cred.user!.uid)
      .set({
    "name": _nameController.text.trim(),
    "email": _emailController.text.trim(),
    "role": _selectedRole,
    "createdAt": FieldValue.serverTimestamp(),
  });

  // 🔥 THIS IS THE FIX
  Navigator.of(context).popUntil((route) => route.isFirst);

} catch (e) {
  
}

}


  @override
  Widget build(BuildContext context) {
    // Determine screen size
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
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isDesktop ? 1100 : 500,
              ),
              child: Container(
                margin: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                ),
                // Using IntrinsicHeight to make both sides equal on Desktop
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ================= FORM SIDE =================
                      Expanded(
                        flex: 1,
                        child: Padding(
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
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF4F6EF7),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 28),
                              const Text("Create Account", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              const Text("Create your BuildXinfo account", style: TextStyle(color: Colors.grey, fontSize: 14)),
                              const SizedBox(height: 24),
                              _field(controller: _nameController, hint: "Full Name", icon: Icons.person_outline),
                              const SizedBox(height: 14),
                              _field(controller: _emailController, hint: "Email", icon: Icons.email_outlined),
                              const SizedBox(height: 14),
                              _field(controller: _passwordController, hint: "Password", icon: Icons.lock_outline, obscure: _obscure),
                              const SizedBox(height: 14),
                              _field(controller: _confirmPasswordController, hint: "Confirm Password", icon: Icons.lock_outline, obscure: _obscure),
                              const SizedBox(height: 14),
                              DropdownButtonFormField<String>(
                                value: _selectedRole,
                                items: const [
                                  DropdownMenuItem(value: "user", child: Text("User")),
                                  DropdownMenuItem(value: "admin", child: Text("Admin")),
                                ],
                                onChanged: (v) => setState(() => _selectedRole = v!),
                                decoration: _inputDecoration("Select Role", Icons.person),
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                height: 46,
                                child: ElevatedButton(
                                  onPressed: _loading ? null : _signup,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4F6EF7),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: _loading
                                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                      : const Text("Create Account", style: TextStyle(fontSize: 16, color: Colors.white)),
                                ),
                              ),
                              const SizedBox(height: 18),
                              Center(
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
                                  },
                                  child: const Text("Already have an account? Log In", style: TextStyle(color: Color(0xFF4F6EF7), fontWeight: FontWeight.w500)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // ================= IMAGE SIDE (Desktop Only) =================
                      if (isDesktop)
                        Expanded(
                          flex: 1,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(28),
                              bottomRight: Radius.circular(28),
                            ),
                            child: Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [Color(0xFFD8DEFF), Color(0xFFEEF1FF)],
                                ),
                              ),
                              child: Image.asset(
                                'assets/login.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
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

  Widget _field({required TextEditingController controller, required String hint, required IconData icon, bool obscure = false}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: _inputDecoration(hint, icon),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: const Color(0xFFF1F3FF),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
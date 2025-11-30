import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart'
    show FirebaseFirestore, FieldValue;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _repeatPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _repeatPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    final repeatPassword = _repeatPasswordController.text;

    if (fullName.isEmpty ||
        email.isEmpty ||
        username.isEmpty ||
        password.isEmpty ||
        repeatPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all fields')),
      );
      return;
    }
    if (password != repeatPassword) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }
    if (!_isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address')),
      );
      return;
    }
    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters')),
      );
      return;
    }
    if (username.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username must be at least 3 characters')),
      );
      return;
    }

    // Check username uniqueness (time-bounded)
    try {
      final existing = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get()
          .timeout(const Duration(seconds: 8));
      if (existing.docs.isNotEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Username already taken')));
        return;
      }
    } on TimeoutException {
      // Network is slow; inform user but continue (server rules should still protect duplicates if enforced)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Username check timed out, continuing...'),
        ),
      );
    } catch (e) {
      // Non-fatal: inform and continue
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not verify username, continuing...'),
        ),
      );
    }

    setState(() => _isLoading = true);
    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = cred.user?.uid;
      if (uid != null) {
        // Kick off Firestore profile write and display name update in background (don't block navigation)
        Future(() async {
          try {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(uid)
                .set({
                  'displayName': fullName,
                  'email': email,
                  'username': username,
                  'createdAt': FieldValue.serverTimestamp(),
                })
                .timeout(const Duration(seconds: 10));
            await cred.user?.updateDisplayName(fullName);
          } catch (fireErr) {
            debugPrint(
              'Background profile write failed for uid=$uid: $fireErr',
            );
          }
        });
        // Inform user immediately and navigate to Login
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created. Please log in.')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
        return;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created but no UID returned')),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Failed to create account';
      switch (e.code) {
        case 'weak-password':
          message = 'The password provided is too weak.';
          break;
        case 'email-already-in-use':
          message = 'An account already exists for that email.';
          break;
        case 'invalid-email':
          message = 'The email address is not valid.';
          break;
        case 'operation-not-allowed':
          message = 'Email/password accounts are not enabled.';
          break;
        case 'too-many-requests':
          message = 'Too many requests. Try again later.';
          break;
        default:
          message = e.message ?? message;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      // Any other error
      // ignore: avoid_print
      debugPrint('Sign up unexpected error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}");
    return emailRegex.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: Theme.of(
          context,
        ).colorScheme.copyWith(brightness: Brightness.light),
      ),
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final maxW = MediaQuery.of(context).size.width;
                        // Further reduced size (was 0.20 clamp 95–150)
                        final logoHeight = (maxW * 0.18)
                            .clamp(80, 130)
                            .toDouble();
                        return Image.asset(
                          "assets/images/logo.png",
                          height: logoHeight,
                          fit: BoxFit.contain,
                        );
                      },
                    ),
                    const SizedBox(width: 14),
                    const Flexible(
                      child: Text(
                        "AcadEase",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                const Text("Full Name"),
                const SizedBox(height: 6),
                _buildTextField(
                  controller: _fullNameController,
                  hint: "Enter your full name",
                ),
                const SizedBox(height: 20),

                const Text("Email"),
                const SizedBox(height: 6),
                _buildTextField(
                  controller: _emailController,
                  hint: "Enter your email address",
                ),
                const SizedBox(height: 20),

                const Text("Username"),
                const SizedBox(height: 6),
                _buildTextField(
                  controller: _usernameController,
                  hint: "Choose a username",
                ),
                const SizedBox(height: 20),

                const Text("Password"),
                const SizedBox(height: 6),
                _buildTextField(
                  controller: _passwordController,
                  hint: "Create a strong password",
                  obscure: true,
                ),
                const SizedBox(height: 20),

                const Text("Repeat Password"),
                const SizedBox(height: 6),
                _buildTextField(
                  controller: _repeatPasswordController,
                  hint: "Re-enter your password",
                  obscure: true,
                ),
                const SizedBox(height: 30),

                OutlinedButton(
                  onPressed: _isLoading ? null : _signUp,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    side: const BorderSide(color: Colors.blueAccent),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(),
                        )
                      : const Text(
                          "Sign Up",
                          style: TextStyle(color: Colors.blueAccent),
                        ),
                ),
                const SizedBox(height: 20),

                Center(
                  child: Column(
                    children: [
                      const Text("Already have an account?"),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          "Log In",
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white, // stay light
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black54),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.black12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.black12),
        ),
      ),
      style: const TextStyle(color: Colors.black87),
    );
  }
}

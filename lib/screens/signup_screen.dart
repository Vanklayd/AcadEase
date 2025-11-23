import 'package:flutter/material.dart';
import 'login_screen.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Row(
                children: [
                  Image.asset(
                    "assets/images/logo.png",
                    height: 50,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "AcadEase",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ],
              ),

              const SizedBox(height: 30),

              const Text("Full Name"),
              const SizedBox(height: 6),
              _buildTextField(hint: "Enter your full name"),
              const SizedBox(height: 20),

              const Text("Email"),
              const SizedBox(height: 6),
              _buildTextField(hint: "Enter your email address"),
              const SizedBox(height: 20),

              const Text("Username"),
              const SizedBox(height: 6),
              _buildTextField(hint: "Choose a username"),
              const SizedBox(height: 20),

              const Text("Password"),
              const SizedBox(height: 6),
              _buildTextField(hint: "Create a strong password", obscure: true),
              const SizedBox(height: 20),

              const Text("Repeat Password"),
              const SizedBox(height: 6),
              _buildTextField(hint: "Re-enter your password", obscure: true),
              const SizedBox(height: 30),

              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  side: const BorderSide(color: Colors.blueAccent),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
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
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
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
    );
  }

  Widget _buildTextField({
    required String hint,
    bool obscure = false,
  }) {
    return TextField(
      obscureText: obscure,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hint,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.black12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.black12),
        ),
      ),
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show FirebaseFirestore;
import 'package:flutter/material.dart';
import 'signup_screen.dart';
import '../main.dart' show AcadEaseHome;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool rememberMe = false;
  bool obscurePassword = true;
  bool _isLoading = false;
  bool _isResetting = false;
  bool _acceptedTerms = false; // <--- added

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept the Terms & Conditions.')),
      );
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }

    if (!_isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email')),
      );
      return;
    }
    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final docRef = FirebaseFirestore.instance.collection('users').doc(uid);
        final snapshot = await docRef.get();
        if (snapshot.exists) {
          final data = snapshot.data();
          debugPrint('Loaded user profile: $data');
        }
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Signed in successfully')));
      if (!mounted) return;
      // Navigate to main dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AcadEaseHome()),
      );
    } on FirebaseAuthException catch (e) {
      String message = 'Failed to sign in';
      switch (e.code) {
        case 'user-not-found':
          message = 'No user found for that email.';
          break;
        case 'wrong-password':
          message = 'Wrong password provided.';
          break;
        case 'user-disabled':
          message = 'This user account has been disabled.';
          break;
        case 'invalid-email':
          message = 'The email address is not valid.';
          break;
        case 'too-many-requests':
          message = 'Too many attempts. Try again later.';
          break;
        default:
          message = e.message ?? message;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _forgotPassword() async {
    final existingEmail = _emailController.text.trim();
    String? emailToUse = existingEmail.isNotEmpty ? existingEmail : null;

    if (emailToUse == null) {
      emailToUse = await showDialog<String?>(
        context: context,
        builder: (ctx) {
          final controller = TextEditingController();
          return AlertDialog(
            title: const Text('Reset Password'),
            content: TextField(
              controller: controller,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'Enter your account email',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(null),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
                child: const Text('Send'),
              ),
            ],
          );
        },
      );
    }

    if (emailToUse == null || emailToUse.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a valid email.')),
      );
      return;
    }

    setState(() => _isResetting = true);
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: emailToUse);
      debugPrint('Password reset email requested for $emailToUse');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Reset link sent to $emailToUse. Check inbox/spam. If not received in 1–2 min, verify email or authorized domain in Firebase.',
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String msg = 'Failed to send reset email';
      if (e.code == 'user-not-found') {
        msg = 'No account found for $emailToUse';
      } else if (e.code == 'invalid-email') {
        msg = 'Invalid email format';
      } else if (e.code == 'missing-android-pkg-name') {
        msg = 'App package name missing in request configuration.';
      } else if (e.code == 'missing-continue-uri') {
        msg = 'Continue URL missing – check action code settings.';
      } else if (e.code == 'missing-ios-bundle-id') {
        msg = 'iOS bundle ID missing – check action code settings.';
      } else if (e.message != null) {
        msg = e.message!;
      }
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
      }
    } catch (e) {
      debugPrint('Unexpected reset error for $emailToUse: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Something went wrong. Try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isResetting = false);
    }
  }

  // Show a scrollable terms & conditions dialog
  void _showTerms() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('AcadEase – Terms and Conditions'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: const Text('''AcadEase – Terms and Conditions

Last Updated: November 30, 2025
Effective Date: December 1, 2025

Welcome to AcadEase, a mobile application designed to help students manage academic schedules, reminders, productivity tasks, and real-time updates in one unified platform. By downloading, accessing, or using AcadEase, you agree to comply with and be bound by the following Terms and Conditions. Please read them carefully.

If you do not agree with these terms, you must discontinue using the application.

1. Definitions

“App” refers to the AcadEase mobile application.

“Developers” / “We” / “Us” refers to the creators of AcadEase: Joseph Mari S. Cordero and Ivan Clyde P. Sagala.

“User” / “You” refers to any individual who downloads, installs, or uses the app.

“Services” include academic scheduling, reminders, weather updates, traffic information, study timers, and other app features.

2. Use of the App

By using AcadEase, you agree to:
- Use the app solely for lawful, academic, and personal productivity purposes.
- Provide accurate information when entering schedules, reminders, and settings.
- Avoid any misuse of the app, including interference with system functions or reverse engineering.
- Accept that the app is currently in its developmental stage and may contain limitations or incomplete features.

3. User Accounts (If Implemented)

AcadEase may utilize account systems (e.g., Firebase Authentication). If authentication features are enabled:
- You are responsible for maintaining the confidentiality of your login credentials.
- You agree not to share your account with others.
- The developers reserve the right to suspend accounts that violate these terms.

4. Data Collection and Storage

AcadEase may store the following data types locally on the device:
- Class schedules
- Assignments and reminders
- User preferences (theme, notifications, timer settings)
- Cached weather or traffic data

If cloud storage integration is implemented (e.g., Firebase):
- User data may be synchronized to cloud databases for backup and multi-device access.

The app may access:
- Location data for traffic and weather features
- Internet connectivity for retrieving external API information

You agree to allow the app to access these services for full functionality.
For more details, refer to the Privacy Policy (can be drafted separately upon request).

5. Permissions

AcadEase may request the following permissions depending on the feature:
- Notifications – for reminders and alerts
- Location access – for traffic updates and localized weather
- Internet access – for external API calls
- Local storage/database – for saving schedules and settings

By granting permissions, you allow AcadEase to use them solely for its intended academic support features.
You may decline permissions, but some features may stop working as intended.

6. Third-Party Services

AcadEase uses third-party APIs such as:
- OpenWeatherMap API – weather updates
- Google Maps API – traffic and location information
- Firebase services (optional) – authentication, cloud storage, notifications

You acknowledge that:
- These external services have their own terms and privacy policies.
- Data accuracy depends on third-party providers and may not always be precise.
- API downtime, rate limits, or outages may affect app functionality.

7. Limitations of Service

Based on the current system architecture, the app may experience:
- Inconsistent reminders due to background process restrictions (Android/iOS)
- Possible data loss if cloud backup is not enabled
- Limited offline functionality (weather & traffic require internet)
- Battery usage increases when using location services
- Reduced performance on older or low-memory devices
- Lack of automatic integration with university systems (manual data entry required)

By using the app, you acknowledge these limitations.

8. Intellectual Property Rights

All content, code, UI designs, architecture diagrams, and graphics within AcadEase are the property of the developers unless otherwise stated.

You are prohibited from:
- Copying or redistributing source code
- Attempting to decompile or reverse-engineer the app
- Modifying or reproducing the app for commercial use without permission

9. Disclaimer of Warranties

AcadEase is provided “as is” and “as available” without guarantees of:
- Uninterrupted or error-free operations
- Accurate weather, traffic, or schedule reminders
- Compatibility with all devices or OS versions
- Prevention of data loss

The developers make no warranties, expressed or implied.

10. Limitation of Liability

To the fullest extent allowed by law:
- The developers are not liable for missed deadlines, missed classes, scheduling errors, or academic consequences resulting from app usage.
- The developers are not responsible for damages caused by reliance on weather/traffic data or system notifications.
- The developers are not liable for data breaches occurring due to third-party API vulnerabilities.

Your usage is fully at your own risk.

11. User Responsibilities

You agree to:
- Regularly double-check your schedules and reminders
- Keep your device updated to ensure smooth app performance
- Use the app responsibly and avoid entering false or harmful data
- Monitor your permissions and privacy settings

12. Updates and Modifications

The developers may:
- Update the app to fix bugs or improve features
- Modify, remove, or replace features at any time
- Change these Terms and Conditions as needed

Continued use after updates constitutes acceptance of the revised terms.

13. Termination

We reserve the right to terminate or restrict app access if a user:
- Violates these Terms
- Misuses system features
- Attempts to exploit, hack, or damage the app

Users may uninstall the app at any time.

14. Governing Law

These Terms are governed by the laws of the Republic of the Philippines, unless otherwise specified.

15. Contact Information

For concerns, issues, or inquiries related to AcadEase:

Developers:
- Joseph Mari S. Cordero
- Ivan Clyde P. Sagala

Github: https://github.com/Vanklayd/AcadEase'''),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              setState(() => _acceptedTerms = true);
              Navigator.of(ctx).pop();
            },
            child: const Text('Accept'),
          ),
        ],
      ),
    );
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}");
    return emailRegex.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 20.0,
            ),
            child: Column(
              children: [
                const SizedBox(height: 10),

                // LOGO
                // Enlarged responsive logo
                LayoutBuilder(
                  builder: (context, constraints) {
                    final maxW = MediaQuery.of(context).size.width;
                    // Smaller logo size
                    final logoHeight = (maxW * 0.22).clamp(100, 160).toDouble();
                    return Image.asset(
                      'assets/images/logo.png',
                      height: logoHeight,
                      fit: BoxFit.contain,
                    );
                  },
                ),

                const SizedBox(height: 20),

                // Content (no white container) - spaced and centered
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Center(
                        child: Text(
                          "Welcome Back!",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Center(
                        child: Text(
                          "Enter your credentials to access your account.",
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Email input
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: "Email Address",
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      // Password input
                      TextField(
                        controller: _passwordController,
                        obscureText: obscurePassword,
                        decoration: InputDecoration(
                          hintText: "Password",
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                obscurePassword = !obscurePassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Remember me + Forgot Password
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: rememberMe,
                                onChanged: (value) {
                                  setState(() {
                                    rememberMe = value!;
                                  });
                                },
                              ),
                              const Text("Remember Me"),
                            ],
                          ),

                          TextButton(
                            onPressed: _isResetting ? null : _forgotPassword,
                            child: _isResetting
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    "Forgot Password?",
                                    style: TextStyle(color: Colors.blue),
                                  ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // Terms & Conditions row
                      Row(
                        children: [
                          Checkbox(
                            value: _acceptedTerms,
                            onChanged: (v) =>
                                setState(() => _acceptedTerms = v ?? false),
                          ),
                          const Expanded(
                            child: Text(
                              'I accept the Terms & Conditions',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          TextButton(
                            onPressed: _showTerms,
                            child: const Text('View Terms'),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // Login button (disabled until terms accepted)
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: (_isLoading || !_acceptedTerms)
                              ? null
                              : _signIn,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  "Log In",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Divider OR
                      Row(
                        children: const [
                          Expanded(child: Divider(color: Colors.grey)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text("OR"),
                          ),
                          Expanded(child: Divider(color: Colors.grey)),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Google Button
                      OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: const Text("Continue with Google"),
                      ),

                      const SizedBox(height: 10),

                      // Apple Button
                      OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: const Text("Continue with Apple"),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Bottom text
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? "),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SignUpScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "Sign Up",
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

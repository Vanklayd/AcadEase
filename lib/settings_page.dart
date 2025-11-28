import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/user_repository.dart';
import 'screens/login_screen.dart';
import 'main.dart' show AcadEaseHome;
import 'schedule_page.dart';
import 'alerts_page.dart';
import 'weather_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _updating = false;

  Future<void> _updateSetting(String key, bool value) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to update settings.')),
      );
      return;
    }
    setState(() => _updating = true);
    try {
      await UserRepository.instance.updateSetting(uid, key, value);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed: $e')));
    } finally {
      if (mounted) setState(() => _updating = false);
    }
  }

  Future<void> _editProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in first.')),
      );
      return;
    }
    final nameController = TextEditingController(text: user.displayName ?? '');
    final usernameController = TextEditingController();
    final emailController = TextEditingController(text: user.email ?? '');

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Profile'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: emailController,
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, {
              'displayName': nameController.text.trim(),
              'username': usernameController.text.trim(),
            }),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result == null) return;
    setState(() => _updating = true);
    try {
      await user.updateDisplayName(result['displayName'] ?? user.displayName);
      await UserRepository.instance.updateProfile(user.uid, {
        'displayName': result['displayName'],
        'username': result['username'],
      });
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Profile updated')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Update failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _updating = false);
    }
  }

  Future<void> _changePassword() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in first.')),
      );
      return;
    }
    final currentController = TextEditingController();
    final newController = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Current Password'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: newController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'New Password'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Update')),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => _updating = true);
    try {
      // Reauthenticate using email/password to allow sensitive operation
      final email = user.email;
      if (email == null) throw Exception('No email associated with account');
      final credential = EmailAuthProvider.credential(
        email: email,
        password: currentController.text,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newController.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password updated')),
        );
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Auth error: ${e.message ?? e.code}')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Update failed: $e')));
    } finally {
      if (mounted) setState(() => _updating = false);
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: uid == null
            ? const Center(child: Text('Sign in to view settings'))
            : StreamBuilder<Map<String, dynamic>?>(
                stream: UserRepository.instance.streamSettings(uid),
                builder: (context, snap) {
                  final data = snap.data ?? {};
                  final settings = (data['settings'] as Map<String, dynamic>?) ?? {};
                  final darkMode = (settings['darkMode'] as bool?) ?? false;
                  final pushNotifs = (settings['pushNotifications'] as bool?) ?? false;
                  final emailNotifs = (settings['emailNotifications'] as bool?) ?? false;

                  return Column(
                    children: [
                      // Title bar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text('Settings', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                      Divider(color: Colors.grey[300], thickness: 1, height: 1),

                      // Content
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Name card
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.06),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  (data['displayName'] as String?) ?? 'User',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                                ),
                              ),
                              const SizedBox(height: 24),

                              const Text('Account', style: TextStyle(fontWeight: FontWeight.w700)),
                              const SizedBox(height: 10),
                              _tile(icon: Icons.person_outline, title: 'Edit Profile', onTap: _updating ? null : _editProfile),
                              _divider(),
                              _tile(icon: Icons.lock_outline, title: 'Change Password', onTap: _updating ? null : _changePassword),

                              const SizedBox(height: 24),
                              const Text('App Preferences', style: TextStyle(fontWeight: FontWeight.w700)),
                              const SizedBox(height: 10),
                              _switchTile(
                                icon: Icons.dark_mode_outlined,
                                title: 'Dark Mode',
                                value: darkMode,
                                onChanged: (v) => _updateSetting('darkMode', v),
                              ),

                              const SizedBox(height: 24),
                              const Text('Notifications', style: TextStyle(fontWeight: FontWeight.w700)),
                              const SizedBox(height: 10),
                              _switchTile(
                                icon: Icons.notifications_none,
                                title: 'Push Notifications',
                                value: pushNotifs,
                                onChanged: (v) => _updateSetting('pushNotifications', v),
                              ),
                              _divider(),
                              _switchTile(
                                icon: Icons.email_outlined,
                                title: 'Email Notifications',
                                value: emailNotifs,
                                onChanged: (v) => _updateSetting('emailNotifications', v),
                              ),

                              const SizedBox(height: 28),
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1976D2),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  onPressed: _updating ? null : _logout,
                                  icon: const Icon(Icons.logout),
                                  label: const Text('Log Out'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Bottom Navigation (consistent with other pages)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 12,
                              offset: const Offset(0, -2),
                            ),
                          ],
                        ),
                        child: SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _navItem(context, Icons.home, 'Home', false),
                                _navItem(context, Icons.calendar_today, 'Schedule', false),
                                _navItem(context, Icons.notifications_outlined, 'Alerts', false),
                                _navItem(context, Icons.cloud_outlined, 'Weather', false),
                                _navItem(context, Icons.settings_outlined, 'Settings', true),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }

  Widget _tile({required IconData icon, required String title, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tileColor: Colors.white,
    );
  }

  Widget _switchTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.black87),
        title: Text(title),
        trailing: Switch(value: value, onChanged: _updating ? (_) {} : onChanged),
      ),
    );
  }

  Widget _divider() => const Divider(height: 1);

  Widget _navItem(BuildContext context, IconData icon, String label, bool isActive) {
    return Expanded(
      child: InkWell(
        onTap: () {
          if (isActive) return;
          if (label == 'Home') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const AcadEaseHome()),
            );
          } else if (label == 'Schedule') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const SchedulePage()),
            );
          } else if (label == 'Alerts') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const AlertsPage()),
            );
          } else if (label == 'Weather') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const WeatherPage()),
            );
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: isActive ? const Color(0xFF1976D2) : Colors.grey[600], size: 26),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: isActive ? const Color(0xFF1976D2) : Colors.grey[600],
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

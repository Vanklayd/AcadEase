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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
    } finally {
      if (mounted) setState(() => _updating = false);
    }
  }

  Future<void> _editProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please sign in first.')));
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Profile updated')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Update failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _updating = false);
    }
  }

  Future<void> _changePassword() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please sign in first.')));
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
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Update'),
          ),
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Password updated')));
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Auth error: ${e.message ?? e.code}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Update failed: $e')));
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
    final theme = Theme.of(context);
    final text = theme.textTheme;
    final primary = theme.colorScheme.primary;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: uid == null
            ? Center(child: Text('Sign in to view settings', style: text.bodyMedium)) // was bodyText2
            : StreamBuilder<Map<String, dynamic>?>(
                stream: UserRepository.instance.streamSettings(uid),
                builder: (context, snap) {
                  final data = snap.data ?? {};
                  final settings = (data['settings'] as Map<String, dynamic>?) ?? {};
                  final darkMode = (settings['darkMode'] as bool?) ?? false;
                  final locationAccess = (settings['locationAccess'] as bool?) ?? true;
                  final pushNotifs = (settings['pushNotifications'] as bool?) ?? false;
                  final emailNotifs = (settings['emailNotifications'] as bool?) ?? false;
                  final displayName = (data['displayName'] as String?) ?? 'User';

                  // Compute initials for avatar
                  String _initials(String name) {
                    final parts = name.trim().split(RegExp(r'\s+'));
                    if (parts.isEmpty) return 'U';
                    final first = parts.first.isNotEmpty ? parts.first[0] : '';
                    final last = parts.length > 1 && parts.last.isNotEmpty ? parts.last[0] : '';
                    final result = (first + last).toUpperCase();
                    return result.isEmpty ? 'U' : result;
                  }

                  return Column(
                    children: [
                      // Title bar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Settings',
                              style: text.titleLarge, // was headline6
                            ),
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
                              // Name card with avatar
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: theme.cardColor,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.06),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircleAvatar(
                                      radius: 24,
                                      backgroundColor: theme.colorScheme.primary,
                                      child: Text(
                                        _initials(displayName),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Flexible(
                                      child: Text(
                                        displayName,
                                        style: text.titleLarge,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),

                              Text('Account', style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700)), // was subtitle1
                              const SizedBox(height: 10),
                              _tile(
                                icon: Icons.person_outline,
                                title: 'Edit Profile',
                                onTap: _updating ? null : _editProfile,
                                theme: theme,
                                text: text,
                              ),
                              _divider(theme),
                              _tile(
                                icon: Icons.lock_outline,
                                title: 'Change Password',
                                onTap: _updating ? null : _changePassword,
                                theme: theme,
                                text: text,
                              ),

                              const SizedBox(height: 24),
                              Text('App Preferences', style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700)), // was subtitle1
                              const SizedBox(height: 10),
                              _switchTile(
                                icon: Icons.dark_mode_outlined,
                                title: 'Dark Mode',
                                value: darkMode,
                                onChanged: (v) => _updateSetting('darkMode', v),
                                theme: theme,
                                text: text,
                              ),
                              _divider(theme),
                              _languageTile(theme: theme, text: text),

                              const SizedBox(height: 24),
                              Text('Privacy & Permissions', style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700)), // was subtitle1
                              const SizedBox(height: 10),
                              _switchTile(
                                icon: Icons.location_on_outlined,
                                title: 'Location Access',
                                value: locationAccess,
                                onChanged: (v) => _updateSetting('locationAccess', v),
                                theme: theme,
                                text: text,
                              ),
                              _divider(theme),

                              const SizedBox(height: 24),
                              Text('Notifications', style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700)), // was subtitle1
                              const SizedBox(height: 10),
                              _switchTile(
                                icon: Icons.notifications_none,
                                title: 'Push Notifications',
                                value: pushNotifs,
                                onChanged: (v) => _updateSetting('pushNotifications', v),
                                theme: theme,
                                text: text,
                              ),
                              _divider(theme),
                              _switchTile(
                                icon: Icons.email_outlined,
                                title: 'Email Notifications',
                                value: emailNotifs,
                                onChanged: (v) => _updateSetting('emailNotifications', v),
                                theme: theme,
                                text: text,
                              ),

                              const SizedBox(height: 24),
                              Text('Storage', style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700)), // was subtitle1
                              const SizedBox(height: 10),
                              _tile(
                                icon: Icons.delete_outline,
                                title: 'Clear Cache',
                                onTap: _updating
                                    ? null
                                    : () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Cache cleared')),
                                        );
                                      },
                                theme: theme,
                                text: text,
                              ),

                              const SizedBox(height: 24),
                              Text('About', style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700)), // was subtitle1
                              const SizedBox(height: 10),
                              _tile(
                                icon: Icons.info_outline,
                                title: 'About AcadEase',
                                onTap: () {
                                  showAboutDialog(
                                    context: context,
                                    applicationName: 'AcadEase',
                                    applicationVersion: '1.0.0',
                                    applicationIcon: const Icon(Icons.school),
                                    children: [
                                      const Text('Your academic assistant for schedules, weather, and alerts.'),
                                    ],
                                  );
                                },
                                theme: theme,
                                text: text,
                              ),
                              _divider(theme),
                              _tile(
                                icon: Icons.help_outline,
                                title: 'Help & Support',
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Support: support@acadease.app')),
                                  );
                                },
                                theme: theme,
                                text: text,
                              ),

                              const SizedBox(height: 28),
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primary,          // blue
                                    foregroundColor: Colors.white,     // ensure text/icon visible
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

                      // Bottom Navigation (kept white)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white, // keep white to match other pages
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

  Widget _tile({
    required IconData icon,
    required String title,
    required ThemeData theme,
    required TextTheme text,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: theme.colorScheme.onSurface),
        title: Text(title, style: text.bodyMedium), // was bodyText2
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _switchTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    required ThemeData theme,
    required TextTheme text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: theme.colorScheme.onSurface),
        title: Text(title, style: text.bodyMedium), // was bodyText2
        trailing: Switch.adaptive(
          value: value,
          onChanged: _updating ? (_) {} : onChanged,
        ),
      ),
    );
  }

  Widget _languageTile({required ThemeData theme, required TextTheme text}) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(Icons.language, color: theme.colorScheme.onSurface),
        title: Text('Language', style: text.bodyMedium), // was bodyText2
        subtitle: Text('English', style: text.bodySmall), // was caption
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Language selection coming soon')),
          );
        },
      ),
    );
  }

  Widget _divider(ThemeData theme) => Divider(height: 16, color: Colors.grey[300]);

  Widget _navItem(
    BuildContext context,
    IconData icon,
    String label,
    bool isActive,
  ) {
    return Expanded(
      child: InkWell(
        onTap: () {
          if (isActive) return;
          if (label == 'Home') {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AcadEaseHome()));
          } else if (label == 'Schedule') {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SchedulePage()));
          } else if (label == 'Alerts') {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AlertsPage()));
          } else if (label == 'Weather') {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const WeatherPage()));
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isActive ? const Color(0xFF1976D2) : Colors.grey[600],
                size: 26,
              ),
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

// lib/features/settings/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_a/features/auth/providers/auth_provider.dart';
import 'package:project_a/features/subscription/screens/subscription_screen.dart';
import 'package:project_a/features/settings/screens/about_screen.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _appVersion = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = packageInfo.version;
    });
  }

  Future<void> _signOut() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(authProvider.notifier).signOut();
      // Navigation will be handled by auth state changes
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error signing out: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPremium = ref.watch(isPremiumUserProvider);
    final user = ref.watch(userDataProvider).value;

    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: ListView(
        children: [
          // User profile section
          if (user != null) ...[
            ListTile(
              leading: CircleAvatar(
                backgroundImage:
                    user.photoURL.isNotEmpty
                        ? NetworkImage(user.photoURL)
                        : null,
                child: user.photoURL.isEmpty ? Icon(Icons.person) : null,
              ),
              title: Text(
                user.displayName.isNotEmpty ? user.displayName : 'User',
              ),
              subtitle: Text(user.email),
              trailing:
                  isPremium
                      ? Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'PREMIUM',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                      : null,
            ),
            Divider(),
          ],

          // Subscription section
          if (!isPremium) ...[
            ListTile(
              leading: Icon(Icons.star, color: Colors.amber),
              title: Text('Upgrade to Premium'),
              subtitle: Text('Unlock all features and sounds'),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SubscriptionScreen()),
                );
              },
            ),
            Divider(),
          ],

          // App settings
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Notification Settings'),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to notification settings
            },
          ),
          ListTile(
            leading: Icon(Icons.dark_mode),
            title: Text('Theme'),
            trailing: DropdownButton<ThemeMode>(
              value: ref.watch(themeModeProvider),
              underline: SizedBox(),
              items: [
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text('System'),
                ),
                DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
                DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
              ],
              onChanged: (value) {
                if (value != null) {
                  ref.read(themeModeProvider.notifier).state = value;
                }
              },
            ),
          ),
          SwitchListTile(
            secondary: Icon(Icons.vibration),
            title: Text('Vibration'),
            value: true, // This would be connected to a provider in a real app
            onChanged: (value) {
              // Update vibration setting
            },
          ),
          ListTile(
            leading: Icon(Icons.volume_up),
            title: Text('Sound Settings'),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to sound settings
            },
          ),
          Divider(),

          // Data management
          ListTile(
            leading: Icon(Icons.backup),
            title: Text('Backup and Restore'),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to backup settings
            },
          ),
          ListTile(
            leading: Icon(Icons.delete),
            title: Text('Clear Data'),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: Text('Clear Data'),
                      content: Text(
                        'Are you sure you want to clear all app data? This action cannot be undone.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            // Clear app data
                            Navigator.pop(context);
                          },
                          child: Text('Clear'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                        ),
                      ],
                    ),
              );
            },
          ),
          Divider(),

          // Support and info
          ListTile(
            leading: Icon(Icons.help),
            title: Text('Help & Support'),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to help screen
            },
          ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('About'),
            subtitle: Text('Version $_appVersion'),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AboutScreen()),
              );
            },
          ),
          Divider(),

          // Sign out
          if (user != null) ...[
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text('Sign Out'),
              onTap: _isLoading ? null : _signOut,
              trailing:
                  _isLoading
                      ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : null,
            ),
          ],

          SizedBox(height: 24),
        ],
      ),
    );
  }
}

// Provider for theme mode
final themeModeProvider = StateProvider<ThemeMode>((ref) {
  return ThemeMode.system;
});

// Provider for premium status (would be connected to actual subscription service)
final isPremiumUserProvider = StateProvider<bool>((ref) => false);

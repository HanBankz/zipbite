import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'theme_controller.dart';
import 'auth_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Future<void> _logout() async {
    await Supabase.instance.client.auth.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const AuthScreen()),
        (route) => false,
      );
    }
  }

  Future<void> _deleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete account?',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        content: Text(
          'This permanently deletes your account and all data. This cannot be undone.',
          style: GoogleFonts.roboto(fontSize: 14, color: Colors.grey[700]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.roboto(color: Colors.grey[700]),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Delete',
              style: GoogleFonts.poppins(
                color: Colors.red[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final response = await http.post(
        Uri.parse(
          'https://hjlvjaburlidoovjnwmv.supabase.co/functions/v1/delete-account',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId}),
      );

      if (response.statusCode == 200) {
        await Supabase.instance.client.auth.signOut();
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const AuthScreen()),
            (route) => false,
          );
        }
      } else {
        throw Exception('Failed to delete account');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, child) {
        final isDark = currentMode == ThemeMode.dark;

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
          appBar: AppBar(
            backgroundColor: const Color(0xFFFF7A00),
            elevation: 0,
            automaticallyImplyLeading: false,
            title: Text(
              'Settings',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Preferences',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey[400] : Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[100],
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Dark mode',
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    value: isDark,
                    activeColor: const Color(0xFFFF7A00),
                    onChanged: (value) {
                      themeNotifier.value = value
                          ? ThemeMode.dark
                          : ThemeMode.light;
                    },
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Account',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey[400] : Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 12),
                _buildOptionTile(
                  icon: Icons.logout,
                  label: 'Log out',
                  onTap: _logout,
                  isDark: isDark,
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _deleteAccount,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[600],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Delete account',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[100],
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: Icon(icon, color: isDark ? Colors.white70 : Colors.black87),
        title: Text(
          label,
          style: GoogleFonts.roboto(
            fontSize: 14,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          size: 18,
          color: isDark ? Colors.white54 : Colors.black54,
        ),
        onTap: onTap,
      ),
    );
  }
}

Widget _buildOptionTile({
  required IconData icon,
  required String label,
  required VoidCallback onTap,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 10),
    decoration: BoxDecoration(
      color: Colors.grey[100],
      borderRadius: BorderRadius.circular(14),
    ),
    child: ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(label, style: GoogleFonts.roboto(fontSize: 14)),
      trailing: const Icon(Icons.chevron_right, size: 18),
      onTap: onTap,
    ),
  );
}

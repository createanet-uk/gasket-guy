// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:url_launcher/url_launcher.dart';
// import '../../theme.dart';
// import '../auth_page.dart';
// import 'edit_profile_page.dart';
//
// class ProfilePage extends StatefulWidget {
//   const ProfilePage({super.key});
//
//   @override
//   State<ProfilePage> createState() => _ProfilePageState();
// }
//
// class _ProfilePageState extends State<ProfilePage> {
//   final _supabase = Supabase.instance.client;
//   String _fullName = "Engineer";
//   String _email = "";
//   String _varsion = "";
//
//   @override
//   void initState() {
//     super.initState();
//     _loadLocalProfile();
//   }
//
//   // Loads data from the cache created by the Report List Page sync
//   Future<void> _loadLocalProfile() async {
//     final user = _supabase.auth.currentUser;
//     if (user == null) return;
//
//     final prefs = await SharedPreferences.getInstance();
//     final String? cachedUser = prefs.getString('current_user_profile');
//     var v = prefs.get('current_model_version');
//     print('v::::  $v');
//     setState(() {
//       _varsion = 'V$v';
//       print('_varsion:::  $_varsion');
//       _email = user.email ?? "";
//       if (cachedUser != null) {
//         final data = jsonDecode(cachedUser);
//         _fullName = data['full_name'] ?? "Engineer";
//       }
//     });
//   }
//
//   void _showLogoutDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text("Logout"),
//         content: const Text("Are you sure?"),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
//           TextButton(onPressed: () async {
//             await _supabase.auth.signOut();
//             if (mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (c) => const AuthPage()), (r) => false);
//           }, child: const Text("Logout", style: TextStyle(color: Colors.red))),
//         ],
//       ),
//     );
//   }
//
//   Future<void> _launchUrl(String url) async {
//     Uri uri = Uri.parse(url);
//     if (!await launchUrl(uri)) {
//       throw Exception('Could not launch $uri');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: const Text("Profile"),
//         centerTitle: true,
//         elevation: 0,
//       ),
//       body: RefreshIndicator(
//         onRefresh: _loadLocalProfile,
//         child: SingleChildScrollView(
//           physics: const AlwaysScrollableScrollPhysics(),
//           child: Column(
//             children: [
//               const SizedBox(height: 30),
//               // User Avatar
//               Center(
//                 child: CircleAvatar(
//                   radius: 50,
//                   backgroundColor: AppTheme.primary.withOpacity(0.1),
//                   child: const Icon(Icons.person, size: 50, color: AppTheme.primary),
//                 ),
//               ),
//               const SizedBox(height: 15),
//
//               // --- DISPLAY NAME AND EMAIL ---
//               Text(
//                 _fullName,
//                 style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               ),
//               Text(
//                 _email,
//                 style: const TextStyle(color: Colors.grey, fontSize: 14),
//               ),
//               const SizedBox(height: 5),
//               const Text(
//                 "Field Service Engineer",
//                 style: TextStyle(color: AppTheme.primary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.1),
//               ),
//
//               const SizedBox(height: 40),
//
//               // Settings Items
//               _buildTile(
//                 icon: Icons.edit_outlined,
//                 title: "Edit Profile",
//                 onTap: () async {
//                   // Wait for EditProfilePage to close and then refresh data
//                   await Navigator.push(context, MaterialPageRoute(builder: (c) => const EditProfilePage()));
//                   _loadLocalProfile();
//                 },
//               ),
//               _buildTile(icon: Icons.description_outlined, title: "Terms & Conditions", isComingSoon: false, onTap: () => _launchUrl('https://www.termsfeed.com/live/b33cbf29-6f45-4eb6-a385-90093dc4f8eb')),
//               _buildTile(icon: Icons.privacy_tip_outlined, title: "Privacy Policy", isComingSoon: false, onTap: () => _launchUrl('https://www.termsfeed.com/live/13009184-46e1-4ac6-9938-633484b4d8a6')),
//
//               const Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                 child: Divider(),
//               ),
//
//               _buildTile(
//                 icon: Icons.person_remove_outlined,
//                 title: "Delete Account",
//                 color: Colors.red[400],
//                 isComingSoon: true,
//                 onTap: () {},
//               ),
//               _buildTile(
//                 icon: Icons.logout,
//                 title: "Logout",
//                 onTap: () => _showLogoutDialog(),
//                 color: Colors.red,
//                 showArrow: false,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTile({
//     required IconData icon,
//     required String title,
//     required VoidCallback onTap,
//     Color? color,
//     bool isComingSoon = false,
//     bool showArrow = true,
//   }) {
//     return ListTile(
//       contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 4),
//       leading: Icon(icon, color: color ?? AppTheme.primary),
//       title: Row(
//         children: [
//           Text(
//             title,
//             style: TextStyle(color: color ?? Colors.black, fontWeight: FontWeight.w500, fontSize: 15),
//           ),
//           if (isComingSoon) ...[
//             const SizedBox(width: 8),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//               decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(4)),
//               child: const Text("COMING SOON", style: TextStyle(fontSize: 7, color: Colors.grey, fontWeight: FontWeight.bold)),
//             ),
//           ],
//         ],
//       ),
//       trailing: showArrow ? const Icon(Icons.chevron_right, size: 18, color: Colors.grey) : null,
//       onTap: isComingSoon ? null : onTap,
//     );
//   }
// }




import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/supabase_service.dart';
import '../../theme.dart';
import '../auth_page.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  final _authService = SupabaseService();

  final _supabase = Supabase.instance.client;
  String _fullName = "Engineer";
  String _email = "";

  // Model Version State
  int? _currentVersion;
  int? _latestVersion;
  bool _isCheckingModel = true;

  @override
  void initState() {
    super.initState();
    _loadLocalProfile();
    _initializeModelStatusFromSync();
  }

  Future<void> _loadLocalProfile() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final prefs = await SharedPreferences.getInstance();
    final String? cachedUser = prefs.getString('current_user_profile');

    if (mounted) {
      setState(() {
        _email = user.email ?? "";
        if (cachedUser != null) {
          final data = jsonDecode(cachedUser);
          _fullName = data['full_name'] ?? "Engineer";
        }
      });
    }
  }

  // --- LOCAL DATA ONLY: Prevents the infinite loader ---
  Future<void> _initializeModelStatusFromSync() async {
    if (!mounted) return;

    setState(() => _isCheckingModel = true);

    try {
      final prefs = await SharedPreferences.getInstance();

      // Read keys saved by the Report List Page sync logic
      final dynamic localVal = prefs.get('current_model_version');
      final dynamic syncVal = prefs.get('latest_model_version_sync');

      if (mounted) {
        setState(() {
          // Type-safe assignment for Current Version
          if (localVal is int) _currentVersion = localVal;
          else if (localVal is String) _currentVersion = int.tryParse(localVal);

          // Type-safe assignment for Latest Version
          if (syncVal is int) _latestVersion = syncVal;
          else if (syncVal is String) _latestVersion = int.tryParse(syncVal);

          // Data is retrieved locally, so stop the loader immediately
          _isCheckingModel = false;
        });
      }
    } catch (e) {
      debugPrint("Local Version Load Error: $e");
    } finally {
      if (mounted) {
        setState(() => _isCheckingModel = false);
      }
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure?"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
              onPressed: () async => await _authService.signOut(context),
              child: const Text("Logout", style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $uri');
    }
  }

  @override
  Widget build(BuildContext context) {
    bool updateRequired = (_currentVersion != null && _latestVersion != null)
        ? _latestVersion! > _currentVersion!
        : false;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadLocalProfile();
          await _initializeModelStatusFromSync();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 30),
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: AppTheme.primary.withOpacity(0.1),
                  child: const Icon(Icons.person, size: 50, color: AppTheme.primary),
                ),
              ),
              const SizedBox(height: 15),

              Text(_fullName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text(_email, style: const TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 5),
              const Text("Field Service Engineer", style: TextStyle(color: AppTheme.primary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.1)),

              const SizedBox(height: 30),

              // --- AI MODEL STATUS CARD ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("AI Model Status", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          _isCheckingModel
                              ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                              : _buildStatusBadge(updateRequired),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildVersionInfo("Current", "v${_currentVersion ?? '0'}"),
                          const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
                          _buildVersionInfo("Latest", _latestVersion == null ? "v0" : "v$_latestVersion"),
                        ],
                      ),
                      if (!_isCheckingModel && updateRequired) ...[
                        const SizedBox(height: 12),
                        const Text("Update available! Pull down on Reports tab to update.",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 10, color: Colors.orange, fontWeight: FontWeight.w600)),
                      ]
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              _buildTile(icon: Icons.edit_outlined, title: "Edit Profile", onTap: () async {
                await Navigator.push(context, MaterialPageRoute(builder: (c) => const EditProfilePage()));
                _loadLocalProfile();
              }),
              _buildTile(icon: Icons.description_outlined, title: "Terms & Conditions", onTap: () => _launchUrl('https://www.termsfeed.com/live/b33cbf29-6f45-4eb6-a385-90093dc4f8eb')),
              _buildTile(icon: Icons.privacy_tip_outlined, title: "Privacy Policy", onTap: () => _launchUrl('https://www.termsfeed.com/live/13009184-46e1-4ac6-9938-633484b4d8a6')),

              const Padding(padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10), child: Divider()),

              _buildTile(icon: Icons.person_remove_outlined, title: "Delete Account", color: Colors.red[400], isComingSoon: true, onTap: () {}),
              _buildTile(icon: Icons.logout, title: "Logout", onTap: _showLogoutDialog, color: Colors.red, showArrow: false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool updateRequired) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: updateRequired ? Colors.orange[50] : Colors.green[50],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        updateRequired ? "UPDATE REQUIRED" : "UP TO DATE",
        style: TextStyle(color: updateRequired ? Colors.orange[800] : Colors.green[800], fontSize: 9, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildVersionInfo(String label, String version) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        Text(version, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }

  Widget _buildTile({required IconData icon, required String title, required VoidCallback onTap, Color? color, bool isComingSoon = false, bool showArrow = true}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 4),
      leading: Icon(icon, color: color ?? AppTheme.primary),
      title: Row(
        children: [
          Text(title, style: TextStyle(color: color ?? Colors.black, fontWeight: FontWeight.w500, fontSize: 15)),
          if (isComingSoon) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(4)),
              child: const Text("COMING SOON", style: TextStyle(fontSize: 7, color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
          ],
        ],
      ),
      trailing: showArrow ? const Icon(Icons.chevron_right, size: 18, color: Colors.grey) : null,
      onTap: isComingSoon ? null : onTap,
    );
  }
}
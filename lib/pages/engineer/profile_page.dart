// // // import 'package:flutter/material.dart';
// // // import 'package:supabase_flutter/supabase_flutter.dart';
// // // import '../../theme.dart';
// // //
// // // class ProfilePage extends StatelessWidget {
// // //   const ProfilePage({super.key});
// // //
// // //   Future<void> _handleLogout(BuildContext context) async {
// // //     await Supabase.instance.client.auth.signOut();
// // //     if (context.mounted) {
// // //       Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
// // //     }
// // //   }
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     final user = Supabase.instance.client.auth.currentUser;
// // //
// // //     return Scaffold(
// // //       backgroundColor: Colors.white,
// // //       appBar: AppBar(
// // //         title: const Text("Engineer Profile"),
// // //         centerTitle: true,
// // //         elevation: 0,
// // //         backgroundColor: Colors.white,
// // //         foregroundColor: Colors.black,
// // //       ),
// // //       body: SingleChildScrollView(
// // //         child: Column(
// // //           children: [
// // //             const SizedBox(height: 30),
// // //             // User Avatar
// // //             Center(
// // //               child: CircleAvatar(
// // //                 radius: 50,
// // //                 backgroundColor: AppTheme.primary.withOpacity(0.1),
// // //                 child: const Icon(Icons.person, size: 50, color: AppTheme.primary),
// // //               ),
// // //             ),
// // //             const SizedBox(height: 15),
// // //             Text(
// // //               user?.email ?? "Engineer",
// // //               style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
// // //             ),
// // //             const Text("Field Service Engineer", style: TextStyle(color: Colors.grey)),
// // //
// // //             const SizedBox(height: 40),
// // //
// // //             // Settings List
// // //             _buildTile(Icons.assignment_ind_outlined, "License Details", () {}),
// // //             _buildTile(Icons.settings_outlined, "App Settings", () {}),
// // //             _buildTile(Icons.info_outline, "About Gasket Guy", () {}),
// // //
// // //             const Padding(
// // //               padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
// // //               child: Divider(),
// // //             ),
// // //
// // //             _buildTile(
// // //                 Icons.logout,
// // //                 "Logout",
// // //                     () => _handleLogout(context),
// // //                 color: Colors.red
// // //             ),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }
// // //
// // //   Widget _buildTile(IconData icon, String title, VoidCallback onTap, {Color? color}) {
// // //     return ListTile(
// // //       contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 4),
// // //       leading: Icon(icon, color: color ?? AppTheme.primary),
// // //       title: Text(
// // //         title,
// // //         style: TextStyle(
// // //           color: color ?? Colors.black,
// // //           fontWeight: FontWeight.w500,
// // //         ),
// // //       ),
// // //       trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
// // //       onTap: onTap,
// // //     );
// // //   }
// // // }
// //
// //
// // import 'package:flutter/material.dart';
// // import 'package:supabase_flutter/supabase_flutter.dart';
// // import '../../theme.dart';
// //
// // class ProfilePage extends StatelessWidget {
// //   const ProfilePage({super.key});
// //
// //   // --- LOGIC: Logout with Confirmation ---
// //   Future<void> _showLogoutDialog(BuildContext context) async {
// //     return showDialog(
// //       context: context,
// //       builder: (context) => AlertDialog(
// //         title: const Text("Logout"),
// //         content: const Text("Are you sure you want to log out of Gasket Guy?"),
// //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
// //         actions: [
// //           TextButton(
// //             onPressed: () => Navigator.pop(context),
// //             child: const Text("CANCEL"),
// //           ),
// //           ElevatedButton(
// //             onPressed: () async {
// //               await Supabase.instance.client.auth.signOut();
// //               if (context.mounted) {
// //                 // Ensure navigation goes back to Auth/Login screen
// //                 Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
// //               }
// //             },
// //             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
// //             child: const Text("LOGOUT", style: TextStyle(color: Colors.white)),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final user = Supabase.instance.client.auth.currentUser;
// //
// //     return Scaffold(
// //       backgroundColor: Colors.white,
// //       appBar: AppBar(
// //         title: const Text("Engineer Profile"),
// //         centerTitle: true,
// //         elevation: 0,
// //         backgroundColor: Colors.white,
// //         foregroundColor: Colors.black,
// //       ),
// //       body: SingleChildScrollView(
// //         child: Column(
// //           children: [
// //             const SizedBox(height: 30),
// //             // User Avatar
// //             Center(
// //               child: CircleAvatar(
// //                 radius: 50,
// //                 backgroundColor: AppTheme.primary.withOpacity(0.1),
// //                 child: const Icon(Icons.person, size: 50, color: AppTheme.primary),
// //               ),
// //             ),
// //             const SizedBox(height: 15),
// //             Text(
// //               user?.email ?? "Engineer",
// //               style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
// //             ),
// //             const Text("Field Service Engineer", style: TextStyle(color: Colors.grey)),
// //
// //             const SizedBox(height: 40),
// //
// //             // Settings List with "Coming Soon" Badges
// //             _buildTile(
// //                 icon: Icons.assignment_ind_outlined,
// //                 title: "License Details",
// //                 isComingSoon: true,
// //                 onTap: () {}
// //             ),
// //             _buildTile(
// //                 icon: Icons.settings_outlined,
// //                 title: "App Settings",
// //                 isComingSoon: true,
// //                 onTap: () {}
// //             ),
// //             _buildTile(
// //                 icon: Icons.info_outline,
// //                 title: "About Gasket Guy",
// //                 isComingSoon: true,
// //                 onTap: () {}
// //             ),
// //
// //             const Padding(
// //               padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
// //               child: Divider(),
// //             ),
// //
// //             // Logout Button
// //             _buildTile(
// //               icon: Icons.logout,
// //               title: "Logout",
// //               onTap: () => _showLogoutDialog(context),
// //               color: Colors.red,
// //               showArrow: false,
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   // --- UI HELPER: Reusable Tile ---
// //   Widget _buildTile({
// //     required IconData icon,
// //     required String title,
// //     required VoidCallback onTap,
// //     Color? color,
// //     bool isComingSoon = false,
// //     bool showArrow = true,
// //   }) {
// //     return ListTile(
// //       contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 4),
// //       leading: Icon(icon, color: color ?? AppTheme.primary),
// //       title: Row(
// //         children: [
// //           Text(
// //             title,
// //             style: TextStyle(
// //               color: color ?? Colors.black,
// //               fontWeight: FontWeight.w500,
// //             ),
// //           ),
// //           if (isComingSoon) ...[
// //             const SizedBox(width: 8),
// //             Container(
// //               padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
// //               decoration: BoxDecoration(
// //                 color: Colors.grey[200],
// //                 borderRadius: BorderRadius.circular(4),
// //               ),
// //               child: const Text(
// //                 "COMING SOON",
// //                 style: TextStyle(fontSize: 8, color: Colors.grey, fontWeight: FontWeight.bold),
// //               ),
// //             ),
// //           ],
// //         ],
// //       ),
// //       trailing: showArrow ? const Icon(Icons.chevron_right, size: 20, color: Colors.grey) : null,
// //       onTap: onTap,
// //     );
// //   }
// // }
//
//
// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../../theme.dart';
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
//   String _fullName = "Loading...";
//   String _email = "";
//
//   @override
//   void initState() {
//     super.initState();
//     _loadUserData();
//   }
//
//   Future<void> _loadUserData() async {
//     final user = _supabase.auth.currentUser;
//     if (user == null) return;
//
//     setState(() => _email = user.email ?? "");
//
//     try {
//       final data = await _supabase
//           .from('user_profiles')
//           .select('full_name')
//           .eq('id', user.id)
//           .single();
//
//       if (mounted) {
//         setState(() => _fullName = data['full_name'] ?? "Engineer");
//       }
//     } catch (e) {
//       if (mounted) setState(() => _fullName = "Engineer");
//     }
//   }
//
//   Future<void> _showLogoutDialog(BuildContext context) async {
//     return showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text("Logout"),
//         content: const Text("Are you sure you want to log out?"),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL")),
//           ElevatedButton(
//             onPressed: () async {
//               await _supabase.auth.signOut();
//               if (context.mounted) {
//                 Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
//               }
//             },
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//             child: const Text("LOGOUT", style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(title: const Text("Profile"), centerTitle: true, elevation: 0),
//       body: RefreshIndicator(
//         onRefresh: _loadUserData,
//         child: SingleChildScrollView(
//           physics: const AlwaysScrollableScrollPhysics(),
//           child: Column(
//             children: [
//               const SizedBox(height: 30),
//               Center(
//                 child: CircleAvatar(
//                   radius: 50,
//                   backgroundColor: AppTheme.primary.withOpacity(0.1),
//                   child: const Icon(Icons.person, size: 50, color: AppTheme.primary),
//                 ),
//               ),
//               const SizedBox(height: 15),
//               // DISPLAY NAME AND EMAIL
//               Text(_fullName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//               Text(_email, style: const TextStyle(color: Colors.grey, fontSize: 14)),
//               const SizedBox(height: 5),
//               const Text("Field Service Engineer", style: TextStyle(color: AppTheme.primary, fontSize: 10, fontWeight: FontWeight.bold)),
//
//               const SizedBox(height: 40),
//               _buildTile(
//                 icon: Icons.edit_outlined,
//                 title: "Edit Profile",
//                 onTap: () async {
//                   await Navigator.push(context, MaterialPageRoute(builder: (c) => const EditProfilePage()));
//                   _loadUserData(); // Refresh name after coming back
//                 },
//               ),
//               _buildTile(icon: Icons.description_outlined, title: "Terms & Conditions", isComingSoon: true, onTap: () {}),
//               _buildTile(icon: Icons.privacy_tip_outlined, title: "Privacy Policy", isComingSoon: true, onTap: () {}),
//               const Padding(padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10), child: Divider()),
//               _buildTile(icon: Icons.person_remove_outlined, title: "Delete Account", color: Colors.red[400], isComingSoon: true, onTap: () {}),
//               _buildTile(icon: Icons.logout, title: "Logout", onTap: () => _showLogoutDialog(context), color: Colors.red, showArrow: false),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTile({required IconData icon, required String title, required VoidCallback onTap, Color? color, bool isComingSoon = false, bool showArrow = true}) {
//     return ListTile(
//       contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 4),
//       leading: Icon(icon, color: color ?? AppTheme.primary),
//       title: Row(
//         children: [
//           Text(title, style: TextStyle(color: color ?? Colors.black, fontWeight: FontWeight.w500, fontSize: 15)),
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
import '../../theme.dart';
import '../auth_page.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _supabase = Supabase.instance.client;
  String _fullName = "Engineer";
  String _email = "";

  @override
  void initState() {
    super.initState();
    _loadLocalProfile();
  }

  // Loads data from the cache created by the Report List Page sync
  Future<void> _loadLocalProfile() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final prefs = await SharedPreferences.getInstance();
    final String? cachedUser = prefs.getString('current_user_profile');

    setState(() {
      _email = user.email ?? "";
      if (cachedUser != null) {
        final data = jsonDecode(cachedUser);
        _fullName = data['full_name'] ?? "Engineer";
      }
    });
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(onPressed: () async {
            await _supabase.auth.signOut();
            if (mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (c) => const AuthPage()), (r) => false);
          }, child: const Text("Logout", style: TextStyle(color: Colors.red))),
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _loadLocalProfile,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 30),
              // User Avatar
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: AppTheme.primary.withOpacity(0.1),
                  child: const Icon(Icons.person, size: 50, color: AppTheme.primary),
                ),
              ),
              const SizedBox(height: 15),

              // --- DISPLAY NAME AND EMAIL ---
              Text(
                _fullName,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                _email,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 5),
              const Text(
                "Field Service Engineer",
                style: TextStyle(color: AppTheme.primary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.1),
              ),

              const SizedBox(height: 40),

              // Settings Items
              _buildTile(
                icon: Icons.edit_outlined,
                title: "Edit Profile",
                onTap: () async {
                  // Wait for EditProfilePage to close and then refresh data
                  await Navigator.push(context, MaterialPageRoute(builder: (c) => const EditProfilePage()));
                  _loadLocalProfile();
                },
              ),
              _buildTile(icon: Icons.description_outlined, title: "Terms & Conditions", isComingSoon: false, onTap: () => _launchUrl('https://www.termsfeed.com/live/b33cbf29-6f45-4eb6-a385-90093dc4f8eb')),
              _buildTile(icon: Icons.privacy_tip_outlined, title: "Privacy Policy", isComingSoon: false, onTap: () => _launchUrl('https://www.termsfeed.com/live/13009184-46e1-4ac6-9938-633484b4d8a6')),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Divider(),
              ),

              _buildTile(
                icon: Icons.person_remove_outlined,
                title: "Delete Account",
                color: Colors.red[400],
                isComingSoon: true,
                onTap: () {},
              ),
              _buildTile(
                icon: Icons.logout,
                title: "Logout",
                onTap: () => _showLogoutDialog(),
                color: Colors.red,
                showArrow: false,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
    bool isComingSoon = false,
    bool showArrow = true,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 4),
      leading: Icon(icon, color: color ?? AppTheme.primary),
      title: Row(
        children: [
          Text(
            title,
            style: TextStyle(color: color ?? Colors.black, fontWeight: FontWeight.w500, fontSize: 15),
          ),
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
// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../../theme.dart';
//
// class EditProfilePage extends StatefulWidget {
//   const EditProfilePage({super.key});
//
//   @override
//   State<EditProfilePage> createState() => _EditProfilePageState();
// }
//
// class _EditProfilePageState extends State<EditProfilePage> {
//   final _supabase = Supabase.instance.client;
//   final _formKey = GlobalKey<FormState>();
//
//   late TextEditingController _nameController;
//   late TextEditingController _phoneController;
//   late TextEditingController _emailController; // For read-only display
//   bool _isLoading = false;
//
//   @override
//   void initState() {
//     super.initState();
//     final user = _supabase.auth.currentUser;
//     _nameController = TextEditingController();
//     _phoneController = TextEditingController();
//     _emailController = TextEditingController(text: user?.email ?? "");
//     _loadCurrentProfile();
//   }
//
//   Future<void> _loadCurrentProfile() async {
//     final userId = _supabase.auth.currentUser?.id;
//     if (userId == null) return;
//
//     try {
//       final data = await _supabase.from('user_profiles').select().eq('id', userId).single();
//       setState(() {
//         _nameController.text = data['full_name'] ?? "";
//         _phoneController.text = data['phone'] ?? "";
//       });
//     } catch (e) {
//       debugPrint("Error loading profile: $e");
//     }
//   }
//
//   Future<void> _updateProfile() async {
//     if (!_formKey.currentState!.validate()) return;
//
//     setState(() => _isLoading = true);
//     try {
//       final userId = _supabase.auth.currentUser?.id;
//       await _supabase.from('user_profiles').update({
//         'full_name': _nameController.text.trim(),
//         'phone': _phoneController.text.trim(),
//         'updated_at': DateTime.now().toIso8601String(),
//       }).eq('id', userId!);
//
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Profile updated successfully"), backgroundColor: Colors.green),
//         );
//         Navigator.pop(context);
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Update failed: $e"), backgroundColor: Colors.red),
//       );
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Edit Profile"), elevation: 0),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text("Account Details", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
//               const SizedBox(height: 15),
//
//               // EMAIL FIELD (NON-EDITABLE)
//               TextFormField(
//                 controller: _emailController,
//                 enabled: false, // Disables the field
//                 decoration: InputDecoration(
//                   labelText: "Email Address",
//                   filled: true,
//                   fillColor: Colors.grey[50],
//                   border: const OutlineInputBorder(),
//                   prefixIcon: const Icon(Icons.lock_outline, size: 20), // Icon to show it's locked
//                 ),
//               ),
//
//               const SizedBox(height: 20),
//
//               // NAME FIELD
//               TextFormField(
//                 controller: _nameController,
//                 decoration: const InputDecoration(labelText: "Full Name", border: OutlineInputBorder()),
//                 validator: (val) => val == null || val.isEmpty ? "Name cannot be empty" : null,
//               ),
//
//               const SizedBox(height: 20),
//
//               // PHONE FIELD
//               TextFormField(
//                 controller: _phoneController,
//                 decoration: const InputDecoration(labelText: "Phone Number", border: OutlineInputBorder()),
//                 keyboardType: TextInputType.phone,
//               ),
//
//               const SizedBox(height: 40),
//
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: _isLoading ? null : _updateProfile,
//                   style: ElevatedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 18),
//                     backgroundColor: AppTheme.primary,
//                   ),
//                   child: _isLoading
//                       ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
//                       : const Text("SAVE CHANGES", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//                 ),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }



import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    // 1. Set email immediately (from Auth session)
    _emailController.text = user.email ?? "";

    try {
      final prefs = await SharedPreferences.getInstance();

      // 2. Try loading from SharedPreferences first (Instant)
      final String? cachedUser = prefs.getString('current_user_profile');
      if (cachedUser != null) {
        final data = jsonDecode(cachedUser);
        _nameController.text = data['full_name'] ?? "";
        _phoneController.text = data['phone'] ?? "";
        setState(() => _isLoading = false); // Stop loader immediately if cache exists
      }

      // 3. Always fetch fresh data from Supabase in background
      final remoteData = await _supabase
          .from('user_profiles')
          .select('full_name, phone')
          .eq('id', user.id)
          .maybeSingle();

      if (remoteData != null) {
        setState(() {
          _nameController.text = remoteData['full_name'] ?? "";
          _phoneController.text = remoteData['phone'] ?? "";
          _isLoading = false; // Ensure loader stops if it was still running
        });
        // Update the cache with fresh data
        await prefs.setString('current_user_profile', jsonEncode(remoteData));
      } else {
        // If no remote record exists and no cache was found
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint("Load Error: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final userId = _supabase.auth.currentUser?.id;
      final updatedData = {
        'full_name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Update Supabase
      await _supabase.from('user_profiles').update(updatedData).eq('id', userId!);

      // Update local cache so changes reflect instantly on the Profile tab
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_user_profile', jsonEncode(updatedData));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully"), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Update failed: $e"), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Edit Profile"), elevation: 0),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                readOnly: true,
                enabled: false,
                decoration: InputDecoration(
                  labelText: "Email Address",
                  prefixIcon: const Icon(Icons.lock_outline),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Full Name",
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (val) => (val == null || val.isEmpty) ? "Required" : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: "Phone Number",
                  prefixIcon: const Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _updateProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("SAVE CHANGES", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
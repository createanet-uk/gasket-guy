// import 'package:supabase_flutter/supabase_flutter.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   await Supabase.initialize(
//     url: 'https://brrdkdabcoilwebmbrlx.supabase.co',
//     anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJycmRrZGFiY29pbHdlYm1icmx4Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3NDk1MjM1NiwiZXhwIjoyMDkwNTI4MzU2fQ.R3RTkWxSbUrD_AjnMwC5cT5rgw5jF4MV6XCIn5MxT5w',
//   );
//
//   runApp(const MyApp());
// }


// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   await Supabase.initialize(
//     url: 'https://brrdkdabcoilwebmbrlx.supabase.co',
//     anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJycmRrZGFiY29pbHdlYm1icmx4Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3NDk1MjM1NiwiZXhwIjoyMDkwNTI4MzU2fQ.R3RTkWxSbUrD_AjnMwC5cT5rgw5jF4MV6XCIn5MxT5w',
//
//   );
//
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: Scaffold(
//         body: Center(
//           child: Text("App Initialized"),
//         ),
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../home_page.dart';
import '../pages/engineer/report_list_page.dart';

class SupabaseService {
  final _client = Supabase.instance.client;



  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'role': 'user', // Hardcoded to 'user' for safety
      },
    );
  }



  // Sign In
  Future<AuthResponse> signIn(String email, String password) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<String?> getUserRole() async {
    String? userRole;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    try{
      final user = _client.auth.currentUser;
      if (user == null) return null;

      final data = await _client
          .from('user_profiles')
          .select('role')
          .eq('id', user.id)
          .maybeSingle();



      if(data != null && data.isNotEmpty){
        userRole = data['role'];
        await prefs.setString('user_role', data['role'] ?? '');
      }else{
        userRole = prefs.getString('user_role') ?? '';
      }
    }catch(e){
      userRole = prefs.getString('user_role') ?? '';
    }

    return userRole;
  }

  // Get User Profile & Role (admin, engineer, user)
  Future<Map<String, dynamic>?> getUserProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    return await _client
        .from('user_profiles')
        .select('role, full_name')
        .eq('id', user.id)
        .maybeSingle();
  }
  // lib/services/supabase_service.dart

// Fetch Seal Products
  Future<List<Map<String, dynamic>>> fetchSealProducts() async {
    final res = await _client
        .from('seal_products')
        .select('*')
        .order('title', ascending: true);
    return List<Map<String, dynamic>>.from(res);
  }

// Fetch Customers (already defined, but ensure it's here)
  Future<List<Map<String, dynamic>>> fetchCustomers() async {
    final res = await _client
        .from('user_profiles')
        .select('id, full_name, email')
        .eq('role', 'user')
        .eq('is_active', true);
    return List<Map<String, dynamic>>.from(res);
  }

  // Fetch all customers (role = user) for the dropdown
  // Future<List<Map<String, dynamic>>> fetchCustomers() async {
  //   final res = await _client
  //       .from('user_profiles')
  //       .select('id, full_name')
  //       .eq('role', 'user')
  //       .eq('is_deleted', false);
  //   return List<Map<String, dynamic>>.from(res);
  // }

// Logic for Login Redirection
  void handleLoginNavigation(BuildContext context, String role) {
    if (role == 'engineer') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ReportListPage()));
    } else {
      // Original Home Page for standard users
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
    }
  }

  Future<void> signOut() async => await _client.auth.signOut();
}
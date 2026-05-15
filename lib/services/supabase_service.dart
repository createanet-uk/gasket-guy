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
import 'package:go_router/go_router.dart';
import 'package:mobile/components/main_navigation_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../common/cm_dialog.dart';
import '../home_page.dart';
import '../pages/auth_page.dart';
import '../pages/engineer/report_list_page.dart';

class SupabaseService {
  final _client = Supabase.instance.client;
  bool _isBannedDialogShowing = false;

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
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ReportListPage()));
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainNavigationPage()));
    } else {
      // Original Home Page for standard users
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
    }
  }

  Future<void> signOut(BuildContext context) async {
    // SharedPreferences p = await SharedPreferences.getInstance();
    // await p.clear();
    await _client.auth.signOut();
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (c) => const AuthPage()), (r) => false);
  }

  final Map<String, RealtimeChannel> _realtimeChannels = {};

  Future<void> listenToUserStatus(BuildContext context) async {

    String channelName = 'userProfilesChannel';

    GlobalKey<NavigatorState>? rootNavigatorKey;
    try {
      rootNavigatorKey = GoRouter.of(context).routerDelegate.navigatorKey;
    } catch (e) {
      debugPrint('Initial navigator key extraction failed: $e');
    }

    if (_realtimeChannels.containsKey(channelName)) {
      await _client.removeChannel(_realtimeChannels[channelName]!);
      _realtimeChannels.remove(channelName);
    }

    final channel = _client.channel(channelName);

    channel.onPostgresChanges(
      event: PostgresChangeEvent.update,
      schema: 'public',
      table: 'user_profiles',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'id',
        value: _client.auth.currentUser?.id,
      ),
      callback: (payload) async {
        final newRecord = payload.newRecord;
        final liveContext = rootNavigatorKey?.currentContext ?? (context.mounted ? context : null);

        if (newRecord['is_active'] == false) {
          if (!_isBannedDialogShowing && liveContext != null) {
            _isBannedDialogShowing = true;
            String reason = newRecord['blocked_reason'] ?? 'No reason provided';
            debugPrint('Deactivation detected. Reason: $reason');

            await CmDialog.showBannedDialog(
              liveContext,
              onPressed: () async => await signOut(liveContext),
            );

            _isBannedDialogShowing = false;
          }
        } else if (newRecord['is_active'] == true) {
          if (_isBannedDialogShowing && liveContext != null) {
            debugPrint('User reactivated. Closing banned dialog.');
            Navigator.of(liveContext).pop();
            _isBannedDialogShowing = false;
          }
        }
      },
    );

    await channel.subscribe();
    _realtimeChannels[channelName] = channel;
  }
}
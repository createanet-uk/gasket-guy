// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../../../theme.dart';
// import '../auth_page.dart';
// import 'new_report_page.dart';
//
// class ReportListPage extends StatefulWidget {
//   const ReportListPage({super.key});
//
//   @override
//   State<ReportListPage> createState() => _ReportListPageState();
// }
//
// class _ReportListPageState extends State<ReportListPage> {
//   final _supabase = Supabase.instance.client;
//
//   // Function to show the logout confirmation
//   void _showLogoutDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text("Logout"),
//         content: const Text("Are you sure you want to log out?"),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text("Cancel"),
//           ),
//           TextButton(
//             onPressed: () async {
//               await _supabase.auth.signOut();
//               if (mounted) {
//                 Navigator.pushAndRemoveUntil(
//                   context,
//                   MaterialPageRoute(builder: (context) => const AuthPage()),
//                       (route) => false,
//                 );
//               }
//             },
//             child: const Text("Logout", style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: AppBar(
//         title: const Text("Asset Reports", style: TextStyle(fontWeight: FontWeight.bold)),
//         leading: IconButton(
//           onPressed: () => _showLogoutDialog(context),
//           icon: const Icon(Icons.logout, color: AppTheme.error),
//         ),
//         actions: [
//           IconButton(
//             onPressed: () => setState(() {}), // Refresh logic
//             icon: const Icon(Icons.refresh),
//           ),
//         ],
//       ),
//       // Using FutureBuilder to fetch real-time data from Supabase
//       body: FutureBuilder<List<Map<String, dynamic>>>(
//         future: _supabase
//             .from('asset_reports')
//             .select('*, customer:user_profiles!customer_id(full_name)')
//             .order('report_date', ascending: false),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//
//           if (snapshot.hasError) {
//             return Center(child: Text("Error: ${snapshot.error}"));
//           }
//
//           final reports = snapshot.data ?? [];
//
//           if (reports.isEmpty) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.assignment_outlined, size: 80, color: AppTheme.secondaryText.withOpacity(0.3)),
//                   const SizedBox(height: 16),
//                   const Text("No Recent Reports Found", style: TextStyle(color: AppTheme.secondaryText)),
//                 ],
//               ),
//             );
//           }
//
//           return ListView.builder(
//             padding: const EdgeInsets.all(16),
//             itemCount: reports.length,
//             itemBuilder: (context, index) {
//               final report = reports[index];
//               final customerName = report['customer']?['full_name'] ?? "Unknown Customer";
//               final date = DateTime.parse(report['report_date']).toLocal();
//               final status = report['status']?.toString().toUpperCase() ?? "PENDING";
//
//               return Card(
//                 elevation: 0,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   side: BorderSide(color: Colors.grey[200]!),
//                 ),
//                 margin: const EdgeInsets.only(bottom: 12),
//                 child: ListTile(
//                   contentPadding: const EdgeInsets.all(12),
//                   leading: CircleAvatar(
//                     backgroundColor: AppTheme.primary.withOpacity(0.1),
//                     child: const Icon(Icons.description, color: AppTheme.primary),
//                   ),
//                   title: Text(customerName, style: const TextStyle(fontWeight: FontWeight.bold)),
//                   subtitle: Text("${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}"),
//                   trailing: Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                     decoration: BoxDecoration(
//                       color: status == 'SUBMITTED' ? Colors.green[50] : Colors.orange[50],
//                       borderRadius: BorderRadius.circular(6),
//                     ),
//                     child: Text(
//                       status,
//                       style: TextStyle(
//                         fontSize: 10,
//                         fontWeight: FontWeight.bold,
//                         color: status == 'SUBMITTED' ? Colors.green[700] : Colors.orange[700],
//                       ),
//                     ),
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         backgroundColor: AppTheme.primary,
//         onPressed: () async {
//           // Wait for the NewReportPage to close, then refresh the list
//           await Navigator.push(context, MaterialPageRoute(builder: (_) => const NewReportPage()));
//           setState(() {});
//         },
//         label: const Text("NEW ASSET REPORT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//         icon: const Icon(Icons.add, color: Colors.white),
//       ),
//     );
//   }
// }

///TODO---------------------------------

/*import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../theme.dart';
import '../auth_page.dart';
import 'new_report_page.dart';

class ReportListPage extends StatefulWidget {
  const ReportListPage({super.key});

  @override
  State<ReportListPage> createState() => _ReportListPageState();
}

class _ReportListPageState extends State<ReportListPage> {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Sync State Management
  bool _isSyncing = false;
  String _syncMessage = "";
  double _syncProgress = 0;
  int? _localVersion;
  String _userRole = 'user';

  @override
  void initState() {
    super.initState();
    // Start background sync process upon entering the page
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _startFullSyncProcess(),
    );
  }

  // --- 1. Main Sync Entry Point ---
  Future<void> _startFullSyncProcess() async {
    await _checkUserRole();

    // Only engineers need the AI Model and offline data sync
    if (_userRole == 'engineer') {
      await _syncAppData();
      await _loadLocalVersion();
      await _checkForModelUpdate();
    }
  }

  // --- 2. Check Logged-in User Role ---
  Future<void> _checkUserRole() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final data = await _supabase
          .from('user_profiles')
          .select('role')
          .eq('id', userId)
          .single();

      if (mounted) {
        setState(() {
          _userRole = data['role'] ?? 'user';
        });
      }
    } catch (e) {
      debugPrint("Role Check Error: $e");
    }
  }

  // --- 3. Silent Data Sync (Fetch Engineers and Users for offline use) ---
  Future<void> _syncAppData() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      // Fetch user profiles filtering for both 'engineer' and 'user' roles
      final dynamic responseProfiles = await _supabase
          .from('user_profiles')
          .select()
          .filter('role', 'in', '("engineer","user")');

      final dynamic responseProducts = await _supabase
          .from('seal_products')
          .select();

      await prefs.setString('local_customers', jsonEncode(responseProfiles));
      await prefs.setString('local_products', jsonEncode(responseProducts));
      await prefs.setString('last_sync_date', DateTime.now().toIso8601String());
      debugPrint("Metadata sync complete.");
    } catch (e) {
      debugPrint("Sync Data Error: $e");
    }
  }

  // --- 4. Load Local Model Version ---
  Future<void> _loadLocalVersion() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _localVersion = prefs.getInt('current_model_version');
    if (mounted) setState(() {});
  }

  // --- 5. Update Check & Postpone Logic ---
  Future<void> _checkForModelUpdate() async {
    try {
      final String? userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      // Fetch latest active version from master table
      final dynamic remoteRes = await _supabase
          .from('model_versions')
          .select()
          .eq('is_active', true)
          .order('version', ascending: false)
          .limit(1)
          .maybeSingle();

      if (remoteRes == null) return;

      final int remoteVer = remoteRes['version'] as int;
      final String remoteVerId = remoteRes['id'] as String;

      // Exit if already up to date locally
      if (_localVersion != null && _localVersion! >= remoteVer) return;

      // Fetch user's status from user_model_status table
      final dynamic userStatus = await _supabase
          .from('user_model_status')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      bool shouldPrompt = true;

      if (userStatus != null && userStatus['postponed_at'] != null) {
        debugPrint('userStatus[postponed_at]::  ${userStatus['postponed_at']}');
        final DateTime postponedAt = DateTime.parse(
          userStatus['postponed_at'] as String,
        ).toUtc();
        final int hours = userStatus['postpone_hours_requested'] as int? ?? 0;
        debugPrint('userStatus[postpone_hours_requested]::  $hours');
        final DateTime postponedUntil = postponedAt.add(Duration(hours: hours));
        debugPrint('postponedUntil::  $postponedUntil');

        final bool isBefore = DateTime.now().toUtc().isBefore(postponedUntil);
        debugPrint(
          'DateTime.now().toUtc().isBefore(postponedUntil)::  $isBefore',
        );

        // Logic: Show popup ONLY if the postponement duration has passed
        if (isBefore) {
          shouldPrompt = false;
        }
      }

      if (shouldPrompt && mounted) {
        _showUpdatePrompt(remoteRes, userStatus);
      }
    } catch (e) {
      debugPrint("Update Check Error: $e");
    }
  }

  // --- 6. Update Promotion Dialog ---
  void _showUpdatePrompt(dynamic remoteRes, dynamic userStatus) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.auto_awesome, color: AppTheme.primary),
            const SizedBox(width: 8),
            const Text("AI Model Update"),
          ],
        ),
        content: Text(
          "A new AI model version v${remoteRes['version']} is available. Would you like to update now or postpone for 2 hours?"
          "${(userStatus?['postpone_count'] ?? 0) > 0 ? '\n\nYou have postponed this ${userStatus['postpone_count']} times.' : ''}",
        ),
        actions: [
          TextButton(
            onPressed: () =>
                _handlePostpone(remoteRes['id'] as String, userStatus),
            child: Text("POSTPONE (2H)", style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              _startAssetDownload(
                remoteRes['model_url'] as String,
                remoteRes['labels_url'] as String?,
                remoteRes['version'] as int,
                remoteRes['id'] as String,
              );
            },
            child: const Text(
              "UPDATE NOW",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // --- 7. Handle Postpone Action (Upsert logic) ---
  Future<void> _handlePostpone(String versionId, dynamic userStatus) async {
    try {
      final String userId = _supabase.auth.currentUser!.id;
      final int currentCount = userStatus?['postpone_count'] ?? 0;
      const int hours = 2;

      // Upsert: Update postponement details in DB
      await _supabase.from('user_model_status').upsert({
        'user_id': userId,
        'pending_version_id': versionId,
        'status': 'postponed',
        'postponed_at': DateTime.now().toUtc().toIso8601String(),
        'postpone_hours_requested': hours,
        'postpone_count': currentCount + 1,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }, onConflict: 'user_id');

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Update postponed for $hours hours."),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint("Postpone error: $e");
    }
  }

  // --- 8. Asset Download Logic ---
  Future<void> _startAssetDownload(
    String modelUrl,
    String? labelsUrl,
    int version,
    String versionId,
  ) async {
    if (mounted) {
      setState(() {
        _isSyncing = true;
        _syncMessage = "Downloading AI Model v$version...";
        _syncProgress = 0;
      });
    }

    try {
      final Directory directory = await getApplicationDocumentsDirectory();
      final String modelPath = "${directory.path}/model_v$version.tflite";
      await _executeFileDownload(modelUrl, modelPath);

      String? labelPath;
      if (labelsUrl != null && labelsUrl.isNotEmpty) {
        labelPath = "${directory.path}/labels_v$version.txt";
        await _executeFileDownload(labelsUrl, labelPath);
      }

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt('current_model_version', version);
      await prefs.setString('current_model_path', modelPath);
      if (labelPath != null)
        await prefs.setString('current_labels_path', labelPath);

      final String userId = _supabase.auth.currentUser!.id;

      // Update table: Version updated, status cleared from postpone
      await _supabase.from('user_model_status').upsert({
        'user_id': userId,
        'current_version_id': versionId,
        // Now the user has this version installed
        'status': 'up_to_date',
        'last_installed_at': DateTime.now().toUtc().toIso8601String(),
        'postponed_at': null,
        'postpone_hours_requested': null,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }, onConflict: 'user_id');

      if (mounted) {
        setState(() => _isSyncing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("AI Model updated successfully!"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint("Download Error: $e");
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  Future<void> _executeFileDownload(String url, String savePath) async {
    final Client client = Client();
    final Request request = Request('GET', Uri.parse(url));
    final StreamedResponse response = await client.send(request);
    final int contentLength = response.contentLength ?? 0;

    final List<int> bytes = <int>[];
    final File file = File(savePath);

    await for (final List<int> chunk in response.stream) {
      bytes.addAll(chunk);
      if (contentLength > 0 && mounted) {
        setState(() => _syncProgress = bytes.length / contentLength);
      }
    }
    await file.writeAsBytes(bytes);
    client.close();
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              await _supabase.auth.signOut();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => const AuthPage(),
                  ),
                  (Route<dynamic> route) => false,
                );
              }
            },
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Asset Reports",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              _userRole.toUpperCase(),
              style: const TextStyle(fontSize: 10, color: Colors.blueGrey),
            ),
          ],
        ),
        leading: IconButton(
          onPressed: () => _showLogoutDialog(context),
          icon: const Icon(Icons.logout, color: AppTheme.error),
        ),
        actions: [
          if (_isSyncing)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(right: 16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          IconButton(
            onPressed: () => setState(() {}),
            icon: const Icon(Icons.refresh),
          ),
        ],
        bottom: _isSyncing
            ? PreferredSize(
                preferredSize: const Size.fromHeight(4),
                child: LinearProgressIndicator(
                  value: _syncProgress,
                  backgroundColor: Colors.white,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppTheme.primary,
                  ),
                ),
              )
            : null,
      ),
      body: Stack(
        children: [
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _supabase
                .from('asset_reports')
                .select('*, customer:user_profiles!customer_id(full_name)')
                .order('report_date', ascending: false)
                .then(
                  (dynamic data) =>
                      List<Map<String, dynamic>>.from(data as List),
                ),
            builder:
                (
                  BuildContext context,
                  AsyncSnapshot<List<Map<String, dynamic>>> snapshot,
                ) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError)
                    return Center(child: Text("Error: ${snapshot.error}"));

                  final List<Map<String, dynamic>> reports =
                      snapshot.data ?? <Map<String, dynamic>>[];

                  if (reports.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.assignment_late_outlined,
                            size: 64,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "No Recent Reports Found",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: reports.length,
                    itemBuilder: (BuildContext context, int index) {
                      final Map<String, dynamic> report = reports[index];
                      final String customerName =
                          (report['customer']
                                  as Map<String, dynamic>?)?['full_name']
                              as String? ??
                          "Unknown";
                      final DateTime date = DateTime.parse(
                        report['report_date'] as String,
                      ).toLocal();
                      final String status =
                          report['status']?.toString().toUpperCase() ??
                          "PENDING";

                      return Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey[200]!),
                        ),
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: CircleAvatar(
                            backgroundColor: AppTheme.primary.withOpacity(0.1),
                            child: const Icon(
                              Icons.description,
                              color: AppTheme.primary,
                            ),
                          ),
                          title: Text(
                            customerName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            "${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}",
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: status == 'SUBMITTED'
                                  ? Colors.green[50]
                                  : Colors.orange[50],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: status == 'SUBMITTED'
                                    ? Colors.green[700]
                                    : Colors.orange[700],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
          ),
          if (_isSyncing)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                color: AppTheme.primary.withOpacity(0.9),
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 16,
                ),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _syncMessage,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      "${(_syncProgress * 100).toStringAsFixed(0)}%",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primary,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => const NewReportPage(),
            ),
          );
          setState(() {});
        },
        label: const Text(
          "NEW REPORT",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        icon: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}*/


//
// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../../../theme.dart';
// import '../auth_page.dart';
// import 'new_report_page.dart';
//
// class ReportListPage extends StatefulWidget {
//   const ReportListPage({super.key});
//
//   @override
//   State<ReportListPage> createState() => _ReportListPageState();
// }
//
// class _ReportListPageState extends State<ReportListPage> {
//   final SupabaseClient _supabase = Supabase.instance.client;
//
//   // Sync State Management
//   bool _isSyncing = false;
//   String _syncMessage = "";
//   double _syncProgress = 0;
//   int? _localVersion;
//   String _userRole = 'user';
//
//   // --- FIX: Store the Future in a variable to prevent re-fetching on build ---
//   late Future<List<Map<String, dynamic>>> _reportsFuture;
//
//   @override
//   void initState() {
//     super.initState();
//     // Initialize the future once
//     _reportsFuture = _fetchReports();
//
//     // Start background sync process upon entering the page
//     WidgetsBinding.instance.addPostFrameCallback(
//           (_) => _startFullSyncProcess(),
//     );
//   }
//
//   // --- Helper to fetch reports ---
//   Future<List<Map<String, dynamic>>> _fetchReports() async {
//     final dynamic data = await _supabase
//         .from('asset_reports')
//         .select('*, customer:user_profiles!customer_id(full_name)')
//         .order('report_date', ascending: false);
//
//     return List<Map<String, dynamic>>.from(data as List);
//   }
//
//   // --- Manual Refresh Method ---
//   void _refreshData() {
//     setState(() {
//       _reportsFuture = _fetchReports();
//     });
//   }
//
//   // --- 1. Main Sync Entry Point ---
//   Future<void> _startFullSyncProcess() async {
//     await _checkUserRole();
//
//     // Only engineers need the AI Model and offline data sync
//     if (_userRole == 'engineer') {
//       await _syncAppData();
//       await _loadLocalVersion();
//       await _checkForModelUpdate();
//     }
//   }
//
//   // --- 2. Check Logged-in User Role ---
//   Future<void> _checkUserRole() async {
//     try {
//       final userId = _supabase.auth.currentUser?.id;
//       if (userId == null) return;
//
//       final data = await _supabase
//           .from('user_profiles')
//           .select('role')
//           .eq('id', userId)
//           .single();
//
//       if (mounted) {
//         setState(() {
//           _userRole = data['role'] ?? 'user';
//         });
//       }
//     } catch (e) {
//       debugPrint("Role Check Error: $e");
//     }
//   }
//
//   // --- 3. Silent Data Sync ---
//   Future<void> _syncAppData() async {
//     try {
//       final SharedPreferences prefs = await SharedPreferences.getInstance();
//
//       final dynamic responseProfiles = await _supabase
//           .from('user_profiles')
//           .select()
//           .filter('role', 'in', '("engineer","user")');
//
//       final dynamic responseProducts = await _supabase
//           .from('seal_products')
//           .select();
//
//       await prefs.setString('local_customers', jsonEncode(responseProfiles));
//       await prefs.setString('local_products', jsonEncode(responseProducts));
//       await prefs.setString('last_sync_date', DateTime.now().toIso8601String());
//       debugPrint("Metadata sync complete.");
//     } catch (e) {
//       debugPrint("Sync Data Error: $e");
//     }
//   }
//
//   // --- 4. Load Local Model Version ---
//   Future<void> _loadLocalVersion() async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     _localVersion = prefs.getInt('current_model_version');
//     if (mounted) setState(() {});
//   }
//
//   // --- 5. Update Check & Postpone Logic ---
//   Future<void> _checkForModelUpdate() async {
//     try {
//       final String? userId = _supabase.auth.currentUser?.id;
//       if (userId == null) return;
//
//       final dynamic remoteRes = await _supabase
//           .from('model_versions')
//           .select()
//           .eq('is_active', true)
//           .order('version', ascending: false)
//           .limit(1)
//           .maybeSingle();
//
//       if (remoteRes == null) return;
//
//       final int remoteVer = remoteRes['version'] as int;
//
//       if (_localVersion != null && _localVersion! >= remoteVer) return;
//
//       final dynamic userStatus = await _supabase
//           .from('user_model_status')
//           .select()
//           .eq('user_id', userId)
//           .maybeSingle();
//
//       bool shouldPrompt = true;
//
//       if (userStatus != null && userStatus['postponed_at'] != null) {
//         final DateTime postponedAt = DateTime.parse(
//           userStatus['postponed_at'] as String,
//         ).toUtc();
//         final int hours = userStatus['postpone_hours_requested'] as int? ?? 0;
//         final DateTime postponedUntil = postponedAt.add(Duration(hours: hours));
//
//         if (DateTime.now().toUtc().isBefore(postponedUntil)) {
//           shouldPrompt = false;
//         }
//       }
//
//       if (shouldPrompt && mounted) {
//         _showUpdatePrompt(remoteRes, userStatus);
//       }
//     } catch (e) {
//       debugPrint("Update Check Error: $e");
//     }
//   }
//
//   // --- 6. Update Promotion Dialog ---
//   void _showUpdatePrompt(dynamic remoteRes, dynamic userStatus) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: Row(
//           children: const [
//             Icon(Icons.auto_awesome, color: AppTheme.primary),
//             SizedBox(width: 8),
//             Text("AI Model Update"),
//           ],
//         ),
//         content: Text(
//           "A new AI model version v${remoteRes['version']} is available. Would you like to update now or postpone for 2 hours?"
//               "${(userStatus?['postpone_count'] ?? 0) > 0 ? '\n\nYou have postponed this ${userStatus['postpone_count']} times.' : ''}",
//         ),
//         actions: [
//           TextButton(
//             onPressed: () =>
//                 _handlePostpone(remoteRes['id'] as String, userStatus),
//             child: const Text("POSTPONE (2H)", style: TextStyle(color: Colors.red)),
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppTheme.primary,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//             onPressed: () {
//               Navigator.pop(context);
//               _startAssetDownload(
//                 remoteRes['model_url'] as String,
//                 remoteRes['labels_url'] as String?,
//                 remoteRes['version'] as int,
//                 remoteRes['id'] as String,
//               );
//             },
//             child: const Text(
//               "UPDATE NOW",
//               style: TextStyle(color: Colors.white),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // --- 7. Handle Postpone Action ---
//   Future<void> _handlePostpone(String versionId, dynamic userStatus) async {
//     try {
//       final String userId = _supabase.auth.currentUser!.id;
//       final int currentCount = userStatus?['postpone_count'] ?? 0;
//       const int hours = 2;
//
//       await _supabase.from('user_model_status').upsert({
//         'user_id': userId,
//         'pending_version_id': versionId,
//         'status': 'postponed',
//         'postponed_at': DateTime.now().toUtc().toIso8601String(),
//         'postpone_hours_requested': hours,
//         'postpone_count': currentCount + 1,
//         'updated_at': DateTime.now().toUtc().toIso8601String(),
//       }, onConflict: 'user_id');
//
//       if (mounted) {
//         Navigator.pop(context);
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text("Update postponed for $hours hours."),
//             behavior: SnackBarBehavior.floating,
//           ),
//         );
//       }
//     } catch (e) {
//       debugPrint("Postpone error: $e");
//     }
//   }
//
//   // --- 8. Asset Download Logic ---
//   Future<void> _startAssetDownload(
//       String modelUrl,
//       String? labelsUrl,
//       int version,
//       String versionId,
//       ) async {
//     if (mounted) {
//       setState(() {
//         _isSyncing = true;
//         _syncMessage = "Downloading AI Model v$version...";
//         _syncProgress = 0;
//       });
//     }
//
//     try {
//       final Directory directory = await getApplicationDocumentsDirectory();
//       final String modelPath = "${directory.path}/model_v$version.tflite";
//       await _executeFileDownload(modelUrl, modelPath);
//
//       String? labelPath;
//       if (labelsUrl != null && labelsUrl.isNotEmpty) {
//         labelPath = "${directory.path}/labels_v$version.txt";
//         await _executeFileDownload(labelsUrl, labelPath);
//       }
//
//       final SharedPreferences prefs = await SharedPreferences.getInstance();
//       await prefs.setInt('current_model_version', version);
//       await prefs.setString('current_model_path', modelPath);
//       if (labelPath != null) {
//         await prefs.setString('current_labels_path', labelPath);
//       }
//
//       final String userId = _supabase.auth.currentUser!.id;
//
//       await _supabase.from('user_model_status').upsert({
//         'user_id': userId,
//         'current_version_id': versionId,
//         'status': 'up_to_date',
//         'last_installed_at': DateTime.now().toUtc().toIso8601String(),
//         'postponed_at': null,
//         'postpone_hours_requested': null,
//         'updated_at': DateTime.now().toUtc().toIso8601String(),
//       }, onConflict: 'user_id');
//
//       if (mounted) {
//         setState(() => _isSyncing = false);
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text("AI Model updated successfully!"),
//             backgroundColor: Colors.green,
//             behavior: SnackBarBehavior.floating,
//           ),
//         );
//       }
//     } catch (e) {
//       debugPrint("Download Error: $e");
//       if (mounted) setState(() => _isSyncing = false);
//     }
//   }
//
//   Future<void> _executeFileDownload(String url, String savePath) async {
//     final Client client = Client();
//     final Request request = Request('GET', Uri.parse(url));
//     final StreamedResponse response = await client.send(request);
//     final int contentLength = response.contentLength ?? 0;
//
//     final List<int> bytes = <int>[];
//     final File file = File(savePath);
//
//     await for (final List<int> chunk in response.stream) {
//       bytes.addAll(chunk);
//       if (contentLength > 0 && mounted) {
//         setState(() => _syncProgress = bytes.length / contentLength);
//       }
//     }
//     await file.writeAsBytes(bytes);
//     client.close();
//   }
//
//   void _showLogoutDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) => AlertDialog(
//         title: const Text("Logout"),
//         content: const Text("Are you sure you want to log out?"),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text("Cancel"),
//           ),
//           TextButton(
//             onPressed: () async {
//               await _supabase.auth.signOut();
//               if (mounted) {
//                 Navigator.pushAndRemoveUntil(
//                   context,
//                   MaterialPageRoute(
//                     builder: (BuildContext context) => const AuthPage(),
//                   ),
//                       (Route<dynamic> route) => false,
//                 );
//               }
//             },
//             child: const Text("Logout", style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: AppBar(
//         title: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               "Asset Reports",
//               style: TextStyle(fontWeight: FontWeight.bold),
//             ),
//             Text(
//               _userRole.toUpperCase(),
//               style: const TextStyle(fontSize: 10, color: Colors.blueGrey),
//             ),
//           ],
//         ),
//         leading: IconButton(
//           onPressed: () => _showLogoutDialog(context),
//           icon: const Icon(Icons.logout, color: AppTheme.error),
//         ),
//         actions: [
//           if (_isSyncing)
//             const Center(
//               child: Padding(
//                 padding: EdgeInsets.only(right: 16.0),
//                 child: SizedBox(
//                   width: 20,
//                   height: 20,
//                   child: CircularProgressIndicator(strokeWidth: 2),
//                 ),
//               ),
//             ),
//           IconButton(
//             onPressed: _refreshData,
//             icon: const Icon(Icons.refresh),
//           ),
//         ],
//         bottom: _isSyncing
//             ? PreferredSize(
//           preferredSize: const Size.fromHeight(4),
//           child: LinearProgressIndicator(
//             value: _syncProgress,
//             backgroundColor: Colors.white,
//             valueColor: const AlwaysStoppedAnimation<Color>(
//               AppTheme.primary,
//             ),
//           ),
//         )
//             : null,
//       ),
//       body: Stack(
//         children: [
//           FutureBuilder<List<Map<String, dynamic>>>(
//             // --- FIXED: Using the persistent variable here ---
//             future: _reportsFuture,
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return const Center(child: CircularProgressIndicator());
//               }
//               if (snapshot.hasError) {
//                 return Center(child: Text("Error: ${snapshot.error}"));
//               }
//
//               final reports = snapshot.data ?? [];
//
//               if (reports.isEmpty) {
//                 return Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(Icons.assignment_late_outlined,
//                           size: 64, color: Colors.grey[300]),
//                       const SizedBox(height: 16),
//                       const Text("No Recent Reports Found",
//                           style: TextStyle(color: Colors.grey)),
//                     ],
//                   ),
//                 );
//               }
//
//               return ListView.builder(
//                 padding: const EdgeInsets.all(16),
//                 itemCount: reports.length,
//                 itemBuilder: (context, index) {
//                   final report = reports[index];
//                   final customerName =
//                       (report['customer'] as Map?)?['full_name'] ?? "Unknown";
//                   final date = DateTime.parse(report['report_date']).toLocal();
//                   final status =
//                       report['status']?.toString().toUpperCase() ?? "PENDING";
//
//                   return Card(
//                     elevation: 0,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       side: BorderSide(color: Colors.grey[200]!),
//                     ),
//                     margin: const EdgeInsets.only(bottom: 12),
//                     child: ListTile(
//                       contentPadding: const EdgeInsets.all(12),
//                       leading: CircleAvatar(
//                         backgroundColor: AppTheme.primary.withOpacity(0.1),
//                         child: const Icon(Icons.description,
//                             color: AppTheme.primary),
//                       ),
//                       title: Text(customerName,
//                           style: const TextStyle(fontWeight: FontWeight.bold)),
//                       subtitle: Text(
//                         "${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}",
//                       ),
//                       trailing: Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 8, vertical: 4),
//                         decoration: BoxDecoration(
//                           color: status == 'SUBMITTED'
//                               ? Colors.green[50]
//                               : Colors.orange[50],
//                           borderRadius: BorderRadius.circular(6),
//                         ),
//                         child: Text(
//                           status,
//                           style: TextStyle(
//                             fontSize: 10,
//                             fontWeight: FontWeight.bold,
//                             color: status == 'SUBMITTED'
//                                 ? Colors.green[700]
//                                 : Colors.orange[700],
//                           ),
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               );
//             },
//           ),
//           if (_isSyncing)
//             Positioned(
//               top: 0,
//               left: 0,
//               right: 0,
//               child: Container(
//                 color: AppTheme.primary.withOpacity(0.9),
//                 padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
//                 child: Row(
//                   children: [
//                     const SizedBox(
//                       width: 14,
//                       height: 14,
//                       child: CircularProgressIndicator(
//                         strokeWidth: 2,
//                         color: Colors.white,
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Text(
//                         _syncMessage,
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 13,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                     Text(
//                       "${(_syncProgress * 100).toStringAsFixed(0)}%",
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 13,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         backgroundColor: AppTheme.primary,
//         onPressed: () async {
//           await Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (BuildContext context) => const NewReportPage(),
//             ),
//           );
//           // Refresh list after returning from adding a report
//           _refreshData();
//         },
//         label: const Text(
//           "NEW REPORT",
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//         ),
//         icon: const Icon(Icons.add, color: Colors.white),
//       ),
//     );
//   }
// }




// import 'dart:convert';
// import 'dart:io';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart';
// import 'package:mobile/pages/engineer/view_report_page.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:intl/intl.dart';
// import '../../../theme.dart';
// import '../auth_page.dart';
// import 'new_report_page.dart';
//
// class ReportListPage extends StatefulWidget {
//   const ReportListPage({super.key});
//
//   @override
//   State<ReportListPage> createState() => _ReportListPageState();
// }
//
// class _ReportListPageState extends State<ReportListPage> {
//   final SupabaseClient _supabase = Supabase.instance.client;
//
//   // State Management
//   bool _isSyncing = false;
//   String _syncMessage = "";
//   double _syncProgress = 0;
//   String _userRole = 'user';
//   List<Map<String, dynamic>> _reports = [];
//   bool _isLoading = true;
//   bool _isPendingOutboxSyncing = false; // Exclusive atomic process lock flag
//
//   @override
//   void initState() {
//     super.initState();
//     _initializePage();
//   }
//
//
//
//   // --- NEW DRAWERS CATALOUGE VIEWERS ---
//   // void _openMetadataDrawer() {
//   //   showModalBottomSheet(
//   //     context: context,
//   //     isScrollControlled: true,
//   //     backgroundColor: Colors.white,
//   //     shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
//   //     builder: (context) => DraggableScrollableSheet(
//   //       initialChildSize: 0.6,
//   //       minChildSize: 0.4,
//   //       maxChildSize: 0.9,
//   //       expand: false,
//   //       builder: (context, scrollController) => Column(
//   //         children: [
//   //           Container(
//   //             margin: const EdgeInsets.symmetric(vertical: 12),
//   //             width: 40, height: 5,
//   //             decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
//   //           ),
//   //           const Text("LOCAL DATA EXPLORER", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blueGrey)),
//   //           const Divider(),
//   //           Expanded(
//   //             child: ListView(
//   //               controller: scrollController,
//   //               padding: const EdgeInsets.all(16),
//   //               children: [
//   //                 _buildDrawerOptionTile(Icons.people_alt_outlined, "Cached Customers", () => _showDataCatalogList("local_customers", "Customers")),
//   //                 _buildDrawerOptionTile(Icons.kitchen_outlined, "Master Fridges List", () => _showDataCatalogList("local_fridges", "Master Fridges")),
//   //                 _buildDrawerOptionTile(Icons.qr_code_scanner_outlined, "Seal Products Directory", () => _showDataCatalogList("local_products", "Seal Products")),
//   //                 _buildDrawerOptionTile(Icons.link_rounded, "Fridge-Seal Relationships", () => _showDataCatalogList("local_fridge_relations", "Relationships")),
//   //               ],
//   //             ),
//   //           )
//   //         ],
//   //       ),
//   //     ),
//   //   );
//   // }
//
//   void _openMetadataDrawer() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.white,
//       shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
//       builder: (context) => DraggableScrollableSheet(
//         initialChildSize: 0.5, // Reduced slightly since we have fewer options
//         minChildSize: 0.3,
//         maxChildSize: 0.8,
//         expand: false,
//         builder: (context, scrollController) => Column(
//           children: [
//             Container(
//               margin: const EdgeInsets.symmetric(vertical: 12),
//               width: 40, height: 5,
//               decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
//             ),
//             const Text("LOCAL DATA EXPLORER", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blueGrey)),
//             const Divider(),
//             Expanded(
//               child: ListView(
//                 controller: scrollController,
//                 padding: const EdgeInsets.all(16),
//                 children: [
//                   _buildDrawerOptionTile(Icons.people_alt_outlined, "Cached Customers", () => _showDataCatalogList("local_customers", "Customers")),
//                   _buildDrawerOptionTile(Icons.kitchen_outlined, "Master Fridges List", () => _showDataCatalogList("local_fridges", "Master Fridges")),
//                   _buildDrawerOptionTile(Icons.qr_code_scanner_outlined, "Seal Products Directory", () => _showDataCatalogList("local_products", "Seal Products")),
//                   // Removed the unhelpful standalone relationships tile line row entirely
//                 ],
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildDrawerOptionTile(IconData icon, String title, VoidCallback onTap) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       elevation: 0,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey[200]!)),
//       child: ListTile(
//         leading: Icon(icon, color: AppTheme.primary),
//         title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
//         trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
//         onTap: () {
//           Navigator.pop(context); // Close selection menu
//           onTap();
//         },
//       ),
//     );
//   }
//
//   void _showDataCatalogList(String prefsKey, String title) async {
//     final prefs = await SharedPreferences.getInstance();
//     final String? rawJson = prefs.getString(prefsKey);
//     List<dynamic> items = rawJson != null ? jsonDecode(rawJson) : [];
//
//     if (!mounted) return;
//
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.white,
//       shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
//       builder: (context) => DraggableScrollableSheet(
//         initialChildSize: 0.8,
//         maxChildSize: 0.95,
//         expand: false,
//         builder: (context, scrollController) => Column(
//           children: [
//             AppBar(
//               title: Text("$title (${items.length})", style: const TextStyle(fontSize: 16, color: Colors.black87)),
//               backgroundColor: Colors.transparent,
//               elevation: 0,
//               centerTitle: true,
//               leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 18), onPressed: () => Navigator.pop(context)),
//             ),
//             const Divider(height: 1),
//             Expanded(
//               child: items.isEmpty
//                   ? Center(child: Text("No local items found for $title", style: const TextStyle(color: Colors.grey)))
//                   : ListView.builder(
//                 controller: scrollController,
//                 itemCount: items.length,
//                 padding: const EdgeInsets.all(16),
//                 itemBuilder: (context, index) {
//                   final item = Map<String, dynamic>.from(items[index]);
//
//                   // If it's a fridge, wrap the layout widget inside an interactive click detector container
//                   if (prefsKey == "local_fridges") {
//                     return InkWell(
//                       onTap: () {
//                         Navigator.pop(context); // Pop active catalog list sub-drawer
//                         _showFridgeStructureDetails(item); // Summon nested detail screen sheet
//                       },
//                       borderRadius: BorderRadius.circular(12),
//                       child: _buildCatalogCard(prefsKey, item),
//                     );
//                   }
//
//                   return _buildCatalogCard(prefsKey, item);
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//   // Widget _buildCatalogCard(String prefsKey, Map<String, dynamic> item) {
//   //   String title = "Unknown Item";
//   //   String subtitle = "";
//   //
//   //   if (prefsKey == "local_customers") {
//   //     title = item['full_name'] ?? 'Unnamed';
//   //     subtitle = "Email: ${item['email'] ?? 'N/A'}\nRole: ${item['role']}";
//   //   } else if (prefsKey == "local_fridges") {
//   //     title = "${item['manufacturer'] ?? 'Unknown'} (${item['model_no'] ?? 'N/A'})";
//   //     subtitle = "S/N: ${item['serial_no'] ?? 'N/A'}\nDoors: ${item['door_count']} | Drawers: ${item['drawer_count']}";
//   //   } else if (prefsKey == "local_products") {
//   //     title = item['title'] ?? item['seal_model_number'] ?? 'Custom Gasket';
//   //     subtitle = "SKU: ${item['sku'] ?? 'N/A'}\nMaterial: ${item['material'] ?? 'N/A'} | Type: ${item['seal_type'] ?? 'N/A'}";
//   //   } else if (prefsKey == "local_fridge_relations") {
//   //     title = "Location: ${item['location'] ?? 'General'}";
//   //     final product = item['seal_products'] != null ? Map<String, dynamic>.from(item['seal_products']) : null;
//   //     subtitle = "Verified: ${item['is_verified'] == true ? 'YES' : 'NO'}\nAssigned Profile: ${product != null ? (product['title'] ?? product['seal_model_number']) : 'Unspecified'}";
//   //   }
//   //
//   //   return Card(
//   //     margin: const EdgeInsets.only(bottom: 10),
//   //     elevation: 0,
//   //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey[200]!)),
//   //     child: Padding(
//   //       padding: const EdgeInsets.all(14),
//   //       child: Column(
//   //         crossAxisAlignment: CrossAxisAlignment.start,
//   //         children: [
//   //           Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
//   //           const SizedBox(height: 6),
//   //           Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.blueGrey, height: 1.4)),
//   //         ],
//   //       ),
//   //     ),
//   //   );
//   // }
//
//
//   // --- 1. Initialization Logic ---
//
//   Widget _buildCatalogCard(String prefsKey, Map<String, dynamic> item) {
//     String title = "Unknown Item";
//     String subtitle = "";
//
//     if (prefsKey == "local_customers") {
//       title = item['full_name'] ?? 'Unnamed';
//       subtitle = "Email: ${item['email'] ?? 'N/A'}\nRole: ${item['role']}";
//     } else if (prefsKey == "local_fridges") {
//       title = "${item['manufacturer'] ?? 'Unknown'} (${item['model_no'] ?? 'N/A'})";
//       subtitle = "S/N: ${item['serial_no'] ?? 'N/A'}\nDoors: ${item['door_count']} | Drawers: ${item['drawer_count']}";
//     } else if (prefsKey == "local_products") {
//       title = item['title'] ?? item['seal_model_number'] ?? 'Custom Gasket';
//       subtitle = "SKU: ${item['sku'] ?? 'N/A'}\nMaterial: ${item['material'] ?? 'N/A'} | Type: ${item['seal_type'] ?? 'N/A'}";
//     } else if (prefsKey == "local_fridge_relations") {
//       // ✅ ENHANCED: Cross-reference relational tables on-the-fly for clean offline mapping context
//       title = "Location Tag: ${item['location'] ?? 'General'}";
//
//       String applianceContext = "Appliance: Loading model specs...";
//       String structuralContext = "Component Dimensions: Loading dimensions...";
//       String profileSpecs = "Profile Variant: Unspecified";
//
//       // 1. Recover and cross-match targets against the master Fridge table cache
//       try {
//         final String? localFridgesJson = SharedPreferences.getInstance().then((p) => p.getString('local_fridges')) as String?;
//         if (localFridgesJson != null) {
//           final List<dynamic> allFridges = jsonDecode(localFridgesJson);
//           final match = allFridges.firstWhere((f) => f['id'].toString() == item['fridge_id'].toString(), orElse: () => null);
//           if (match != null) {
//             applianceContext = "Appliance: ${match['manufacturer']} (${match['model_no']})";
//           }
//         }
//       } catch (_) {
//         applianceContext = "Appliance: Linked via ID (${item['fridge_id'].toString().substring(0, 8)}...)";
//       }
//
//       // 2. Recover and cross-match physical layout measurements from your Components catalog
//       try {
//         final String? localCompJson = SharedPreferences.getInstance().then((p) => p.getString('local_fridge_components')) as String?;
//         if (localCompJson != null && item['supported_component_id'] != null) {
//           final List<dynamic> allComps = jsonDecode(localCompJson);
//           final match = allComps.firstWhere((c) => c['id'].toString() == item['supported_component_id'].toString(), orElse: () => null);
//           if (match != null) {
//             structuralContext = "Component Size: ${match['width_mm']}mm W x ${match['height_mm']}mm H (Index: ${match['component_index']})";
//           }
//         }
//       } catch (_) {
//         structuralContext = "Component ID: ${item['supported_component_id'] != null ? item['supported_component_id'].toString().substring(0, 8) + '...' : 'N/A'}";
//       }
//
//       // 3. Extract nested profile details cleanly
//       final product = item['seal_products'] != null ? Map<String, dynamic>.from(item['seal_products']) : null;
//       if (product != null) {
//         profileSpecs = "Linked Seal: ${product['title'] ?? product['sku'] ?? 'Custom Profile'} [v] ${product['seal_type'] ?? 'N/A'}";
//       }
//
//       subtitle = "$applianceContext\n$structuralContext\n$profileSpecs\nVerified Fitment: ${item['is_verified'] == true ? 'YES ✅' : 'NO ⏳'}";
//     }
//
//     return Card(
//       margin: const EdgeInsets.only(bottom: 10),
//       elevation: 0,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey[200]!)),
//       child: Padding(
//         padding: const EdgeInsets.all(14),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
//             const SizedBox(height: 6),
//             Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.blueGrey, height: 1.4)),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Future<void> _initializePage() async {
//     // Load local reports first for instant UI
//     await _loadLocalReports();
//
//     // Start role check and background sync
//     await _checkUserRole();
//
//     if (_userRole == 'engineer') {
//       _startFullSyncProcess();
//     } else {
//       _refreshData(); // Standard refresh for non-engineers
//     }
//   }
//
//   // --- 2. Local Storage Methods ---
//   // Future<void> _loadLocalReports() async {
//   //   final prefs = await SharedPreferences.getInstance();
//   //   final String? cachedData = prefs.getString('cached_my_reports');
//   //   if (cachedData != null) {
//   //     setState(() {
//   //       _reports = List<Map<String, dynamic>>.from(jsonDecode(cachedData));
//   //       _isLoading = false;
//   //     });
//   //   }
//   // }
//
//   Future<void> _loadLocalReports() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//
//       // 1. Fetch verified server records cache layer
//       final String? cachedData = prefs.getString('cached_my_reports');
//       List<Map<String, dynamic>> combinedList = [];
//
//       if (cachedData != null) {
//         combinedList = List<Map<String, dynamic>>.from(jsonDecode(cachedData));
//       }
//
//       // --- FIXED: Fetch local customers catalog directly from cache storage to resolve reference ---
//       List<Map<String, dynamic>> localCustomersList = [];
//       final String? localCustomersJson = prefs.getString('local_customers');
//       if (localCustomersJson != null) {
//         localCustomersList = List<Map<String, dynamic>>.from(jsonDecode(localCustomersJson));
//       }
//
//       // 2. Fetch standalone offline outbox queue records
//       final List<String> currentQueue = prefs.getStringList('offline_reports_queue') ?? [];
//       List<Map<String, dynamic>> offlineItems = [];
//
//       for (String itemJson in currentQueue) {
//         try {
//           final Map<String, dynamic> rawReport = jsonDecode(itemJson);
//
//           // Map customer labels smoothly from the locally retrieved customer list
//           String customerName = "Unknown Customer";
//           if (rawReport['customer_id'] != null && localCustomersList.isNotEmpty) {
//             final match = localCustomersList.where(
//                     (c) => c['id'].toString() == rawReport['customer_id'].toString()
//             );
//             if (match.isNotEmpty) {
//               customerName = match.first['full_name'] ?? customerName;
//             }
//           }
//
//           offlineItems.add({
//             'id': rawReport['id'] ?? 'local_queued_${DateTime.now().millisecondsSinceEpoch}',
//             'report_title': rawReport['report_title'] ?? 'Untitled Report',
//             'report_date': rawReport['report_date'] ?? DateTime.now().toIso8601String(),
//             'status': 'pending sync',
//             'customer': {
//               'full_name': customerName,
//             }
//           });
//         } catch (_) {}
//       }
//
//       // Merge arrays putting outbox modifications at the top of the viewing array layout
//       setState(() {
//         _reports = [...offlineItems, ...combinedList];
//         _isLoading = false;
//       });
//     } catch (e) {
//       debugPrint("Offline Reports Merging Error: $e");
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }
//
//   Future<void> _saveReportsLocally(List<Map<String, dynamic>> data) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('cached_my_reports', jsonEncode(data));
//   }
//
//   // --- 3. Data Fetching (Filtered by Auth User) ---
//   // Future<void> _refreshData() async {
//   //   try {
//   //     final userId = _supabase.auth.currentUser?.id;
//   //     if (userId == null) return;
//   //
//   //     final dynamic data = await _supabase
//   //         .from('asset_reports')
//   //         .select('*, customer:user_profiles!customer_id(full_name)')
//   //         .eq('engineer_id', userId) // CRITICAL: Show only my reports
//   //         .order('report_date', ascending: false);
//   //
//   //     final List<Map<String, dynamic>> fetchedReports =
//   //     List<Map<String, dynamic>>.from(data as List);
//   //
//   //     if (mounted) {
//   //       setState(() {
//   //         _reports = fetchedReports;
//   //         _isLoading = false;
//   //       });
//   //       await _saveReportsLocally(fetchedReports);
//   //     }
//   //   } catch (e) {
//   //     debugPrint("Fetch Error: $e");
//   //     if (mounted) setState(() => _isLoading = false);
//   //   }
//   // }
//
//
//   // Inside _ReportListPageState in report_list_page.dart
//
//   // Future<void> _refreshData() async {
//   //   try {
//   //     final userId = _supabase.auth.currentUser?.id;
//   //     if (userId == null) return;
//   //
//   //     // UPDATE: Fetch full details (fridges and seals) to support offline viewing
//   //     final dynamic data = await _supabase
//   //         .from('asset_reports')
//   //         .select('''
//   //         *,
//   //         customer:user_profiles!customer_id(full_name, email),
//   //         fridges:assets_report_fridge(
//   //           *,
//   //           seals:asset_report_fridge_items (*)
//   //         )
//   //       ''')
//   //         .eq('engineer_id', userId)
//   //         .order('report_date', ascending: false);
//   //
//   //     final List<Map<String, dynamic>> fetchedReports =
//   //     List<Map<String, dynamic>>.from(data as List);
//   //
//   //     if (mounted) {
//   //       setState(() {
//   //         _reports = fetchedReports;
//   //         _isLoading = false;
//   //       });
//   //       // This now saves the FULL details of all reports locally
//   //       await _saveReportsLocally(fetchedReports);
//   //     }
//   //   } catch (e) {
//   //     debugPrint("Fetch Error: $e");
//   //     if (mounted) setState(() => _isLoading = false);
//   //   }
//   // }
//
//   // --- 4. Role & Sync Orchestration ---
//
//
//   Future<void> _refreshData() async {
//     try {
//       final List<ConnectivityResult> connectivityResult = await (Connectivity().checkConnectivity());
//       if (connectivityResult.contains(ConnectivityResult.none)) {
//         // Phone is offline -> Pull local cache items immediately and don't try calling Supabase
//         await _loadLocalReports();
//         return;
//       }
//
//       final userId = _supabase.auth.currentUser?.id;
//       if (userId == null) return;
//
//       final dynamic data = await _supabase
//           .from('asset_reports')
//           .select('''
//           *,
//           customer:user_profiles!customer_id(full_name, email),
//           fridges:assets_report_fridge(
//             *,
//             seals:asset_report_fridge_items (*)
//           )
//         ''')
//           .eq('engineer_id', userId)
//           .order('report_date', ascending: false);
//
//       final List<Map<String, dynamic>> fetchedReports =
//       List<Map<String, dynamic>>.from(data as List);
//
//       if (mounted) {
//         setState(() {
//           _reports = fetchedReports;
//           _isLoading = false;
//         });
//         await _saveReportsLocally(fetchedReports);
//
//         // Re-run the local processor to merge pending offline entries on top of the live list
//         await _loadLocalReports();
//       }
//     } catch (e) {
//       debugPrint("Fetch Error: $e");
//       await _loadLocalReports(); // Fallback to offline visibility state smoothly on error
//     }
//   }
//
//   Future<void> _checkUserRole() async {
//     final userId = _supabase.auth.currentUser?.id;
//     if (userId == null) return;
//     try {
//       final data = await _supabase.from('user_profiles').select('role').eq('id', userId).single();
//       if (mounted) setState(() => _userRole = data['role'] ?? 'user');
//     } catch (e) {
//       debugPrint("Role Check Error: $e");
//     }
//   }
//
//   Future<void> _startFullSyncProcess() async {
//     // 1. Check connectivity first
//     final List<ConnectivityResult> connectivityResult = await (Connectivity().checkConnectivity());
//     if (connectivityResult.contains(ConnectivityResult.none)) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("No internet connection. Cannot sync new data."),
//           backgroundColor: AppTheme.error,
//         ),
//       );
//       return;
//     }
//
//     setState(() {
//       _isSyncing = true;
//       _syncProgress = 0.1;
//       _syncMessage = "Connecting to server...";
//     });
//
//     try {
//       // 2. Fetch all metadata (Customers, Products, Fridges, Components, Relations)
//       await _triggerOutboxBackgroundSync();
//       setState(() => _syncProgress = 0.4);
//
//       await _syncMetadata();
//       setState(() => _syncProgress = 0.5);
//
//       // 3. Fetch latest reports for this engineer
//       await _refreshData();
//       setState(() => _syncProgress = 0.8);
//
//       // 4. Check for AI Model updates
//       await _checkForModelUpdate();
//       setState(() => _syncProgress = 1.0);
//
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text("All data updated successfully!"),
//             backgroundColor: AppTheme.success,
//             duration: Duration(seconds: 2),
//           ),
//         );
//       }
//     } catch (e) {
//       debugPrint("Sync Error: $e");
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Sync failed: $e"), backgroundColor: AppTheme.error),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isSyncing = false;
//           _syncMessage = "";
//         });
//       }
//     }
//   }
//   // Future<void> _syncMetadata() async {
//   //   try {
//   //     final prefs = await SharedPreferences.getInstance();
//   //     final profiles = await _supabase.from('user_profiles').select().filter('role', 'in', '("engineer","user")');
//   //     final products = await _supabase.from('seal_products').select();
//   //
//   //     await prefs.setString('local_customers', jsonEncode(profiles));
//   //     await prefs.setString('local_products', jsonEncode(products));
//   //     debugPrint("Metadata Synced.");
//   //   } catch (e) {
//   //     debugPrint("Metadata Sync Error: $e");
//   //   }
//   // }
//
//   // --- 5. AI Model Update Logic (Existing) ---
//   // Future<void> _checkForModelUpdate() async {
//   //   try {
//   //     final prefs = await SharedPreferences.getInstance();
//   //     int? localVer = prefs.getInt('current_model_version');
//   //
//   //     final dynamic remoteRes = await _supabase
//   //         .from('model_versions')
//   //         .select()
//   //         .eq('is_active', true)
//   //         .order('version', ascending: false)
//   //         .limit(1)
//   //         .maybeSingle();
//   //
//   //     if (remoteRes == null) return;
//   //     final int remoteVer = remoteRes['version'] as int;
//   //
//   //     if (localVer != null && localVer >= remoteVer) return;
//   //
//   //     // Check postpone status
//   //     final userId = _supabase.auth.currentUser!.id;
//   //     final dynamic userStatus = await _supabase.from('user_model_status').select().eq('user_id', userId).maybeSingle();
//   //
//   //     bool shouldPrompt = true;
//   //     if (userStatus != null && userStatus['postponed_at'] != null) {
//   //       final DateTime postponedAt = DateTime.parse(userStatus['postponed_at']).toUtc();
//   //       final int hours = userStatus['postpone_hours_requested'] ?? 0;
//   //       if (DateTime.now().toUtc().isBefore(postponedAt.add(Duration(hours: hours)))) {
//   //         shouldPrompt = false;
//   //       }
//   //     }
//   //
//   //     if (shouldPrompt && mounted) _showUpdatePrompt(remoteRes, userStatus);
//   //   } catch (e) {
//   //     debugPrint("Model Check Error: $e");
//   //   }
//   // }
//
//
//   Future<void> _checkForModelUpdate() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       int? localVer = prefs.getInt('current_model_version');
//
//       final dynamic remoteRes = await _supabase
//           .from('model_versions')
//           .select()
//           .eq('is_active', true)
//           .order('version', ascending: false)
//           .limit(1)
//           .maybeSingle();
//
//       if (remoteRes == null) return;
//       final int remoteVer = remoteRes['version'] as int;
//
//       // --- ADD THIS LINE TO SAVE DATA FOR PROFILE PAGE ---
//       await prefs.setInt('latest_model_version_sync', remoteVer);
//
//       if (localVer != null && localVer >= remoteVer) return;
//
//       // Check postpone status
//       final userId = _supabase.auth.currentUser!.id;
//       final dynamic userStatus = await _supabase.from('user_model_status').select().eq('user_id', userId).maybeSingle();
//
//       bool shouldPrompt = true;
//       if (userStatus != null && userStatus['postponed_at'] != null) {
//         final DateTime postponedAt = DateTime.parse(userStatus['postponed_at']).toUtc();
//         final int hours = userStatus['postpone_hours_requested'] ?? 0;
//         if (DateTime.now().toUtc().isBefore(postponedAt.add(Duration(hours: hours)))) {
//           shouldPrompt = false;
//         }
//       }
//
//       if (shouldPrompt && mounted) _showUpdatePrompt(remoteRes, userStatus);
//     } catch (e) {
//       debugPrint("Model Check Error: $e");
//     }
//   }
//
//
//   void _showUpdatePrompt(dynamic remoteRes, dynamic userStatus) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: const Text("AI Update Available"),
//         content: Text("Version v${remoteRes['version']} is ready. Update now?"),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context), child: const Text("LATER")),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(context);
//               _startAssetDownload(remoteRes['model_url'], remoteRes['labels_url'], remoteRes['version'], remoteRes['id']);
//             },
//             child: const Text("UPDATE"),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Future<void> _startAssetDownload(String mUrl, String? lUrl, int ver, String vId) async {
//     if (!mounted) return;
//     setState(() {
//       _isSyncing = true;
//       _syncMessage = "Downloading Model v$ver...";
//       _syncProgress = 0;
//     });
//
//     try {
//       final dir = await getApplicationDocumentsDirectory();
//       final mPath = "${dir.path}/model_v$ver.tflite";
//       await _executeDownload(mUrl, mPath);
//
//       if (lUrl != null) {
//         final lPath = "${dir.path}/labels_v$ver.txt";
//         await _executeDownload(lUrl, lPath);
//         final prefs = await SharedPreferences.getInstance();
//         await prefs.setString('current_labels_path', lPath);
//       }
//
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setInt('current_model_version', ver);
//       await prefs.setString('current_model_path', mPath);
//
//       await _supabase.from('user_model_status').upsert({'user_id': _supabase.auth.currentUser!.id, 'current_version_id': vId, 'status': 'up_to_date'}, onConflict: 'user_id');
//       if (mounted) setState(() => _isSyncing = false);
//     } catch (e) {
//       if (mounted) setState(() => _isSyncing = false);
//     }
//   }
//
//   // Future<void> _syncMetadata() async {
//   //   try {
//   //     final prefs = await SharedPreferences.getInstance();
//   //
//   //     // 1. Fetch all required tables
//   //     final profiles = await _supabase.from('user_profiles').select().filter('role', 'in', '("engineer","user")');
//   //     final products = await _supabase.from('seal_products').select();
//   //
//   //     // 2. Fetch Fridges and their Seal Relations (including the seal data joined)
//   //     final fridges = await _supabase.from('fridges').select();
//   //
//   //     // This join gets the relation AND the seal product details in one go
//   //     final fridgeRelations = await _supabase.from('fridge_seals_relation').select('''
//   //     *,
//   //     seal_products:seal_product_id (*,seal_model_number)
//   //   ''');
//   //
//   //     // 3. Save to Local Storage
//   //     await prefs.setString('local_customers', jsonEncode(profiles));
//   //     await prefs.setString('local_products', jsonEncode(products));
//   //     await prefs.setString('local_fridges', jsonEncode(fridges));
//   //     await prefs.setString('local_fridge_relations', jsonEncode(fridgeRelations));
//   //
//   //     debugPrint("Metadata, Fridges, and Relations Synced Locally.");
//   //   } catch (e) {
//   //     debugPrint("Metadata Sync Error: $e");
//   //   }
//   // }
//
//
//   // Future<void> _syncMetadata() async {
//   //   try {
//   //     final prefs = await SharedPreferences.getInstance();
//   //     final userId = _supabase.auth.currentUser?.id;
//   //
//   //     // 1. Fetch all required tables
//   //     final profiles = await _supabase.from('user_profiles').select().filter('role', 'in', '("engineer","user")');
//   //     final products = await _supabase.from('seal_products').select();
//   //     final fridges = await _supabase.from('fridges').select();
//   //
//   //     final fridgeRelations = await _supabase.from('fridge_seals_relation').select('''
//   //     *,
//   //     seal_products:seal_product_id (*,seal_model_number)
//   //   ''');
//   //
//   //     // --- NEW: Sync current user's specific profile for the Edit Page ---
//   //     if (userId != null) {
//   //       final myProfile = await _supabase
//   //           .from('user_profiles')
//   //           .select('full_name, phone')
//   //           .eq('id', userId)
//   //           .maybeSingle();
//   //
//   //       if (myProfile != null) {
//   //         await prefs.setString('current_user_profile', jsonEncode(myProfile));
//   //       }
//   //     }
//   //
//   //     // 2. Save to Local Storage
//   //     await prefs.setString('local_customers', jsonEncode(profiles));
//   //     await prefs.setString('local_products', jsonEncode(products));
//   //     await prefs.setString('local_fridges', jsonEncode(fridges));
//   //     await prefs.setString('local_fridge_relations', jsonEncode(fridgeRelations));
//   //
//   //     debugPrint("Metadata and User Profile Synced Locally.");
//   //   } catch (e) {
//   //     debugPrint("Metadata Sync Error: $e");
//   //   }
//   // }
//
//
//
//   Future<void> _syncMetadata() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final userId = _supabase.auth.currentUser?.id;
//
//       setState(() {
//         _syncMessage = "Syncing Catalogs & Components...";
//       });
//
//       // 1. Fetch User Profiles & Product Catalog
//       final profiles = await _supabase.from('user_profiles').select().eq('role', 'user');
//       // final profiles = await _supabase.from('user_profiles').select().filter('role', 'in', '("engineer","user")');
//       final products = await _supabase.from('seal_products').select();
//
//       // 2. Fetch Fridges Master Data
//       final fridges = await _supabase.from('fridges').select();
//
//       // 3. Fetch Fridge Components (Height, Width for each door/drawer)
//       final components = await _supabase.from('fridge_components').select();
//
//       // 4. Fetch Fridge-Seal Relations with Nested Product Info
//       // This allows you to know exactly which seal fits which fridge even while offline
//       final fridgeRelations = await _supabase.from('fridge_seals_relation').select('''
//         *,
//         seal_products:seal_product_id (*)
//       ''');
//
//       // 5. Sync current user's profile for personal settings
//       if (userId != null) {
//         final myProfile = await _supabase
//             .from('user_profiles')
//             .select('full_name, phone, email, role')
//             .eq('id', userId)
//             .maybeSingle();
//
//         if (myProfile != null) {
//           await prefs.setString('current_user_profile', jsonEncode(myProfile));
//         }
//       }
//
//       // 6. Save everything to SharedPreferences
//       // We use clear keys so other pages can access them easily
//       await prefs.setString('local_customers', jsonEncode(profiles));
//       await prefs.setString('local_products', jsonEncode(products));
//       await prefs.setString('local_fridges', jsonEncode(fridges));
//       await prefs.setString('local_fridge_components', jsonEncode(components));
//       await prefs.setString('local_fridge_relations', jsonEncode(fridgeRelations));
//
//       debugPrint("Full Database Sync Complete: Profiles, Products, Fridges, Components, and Relations.");
//     } catch (e) {
//       debugPrint("Metadata Sync Error: $e");
//     }
//   }
//
//   Future<void> _executeDownload(String url, String path) async {
//     final client = Client();
//     final response = await client.send(Request('GET', Uri.parse(url)));
//     final List<int> bytes = [];
//     await for (final chunk in response.stream) {
//       bytes.addAll(chunk);
//       if (response.contentLength != null && mounted) {
//         setState(() => _syncProgress = bytes.length / response.contentLength!);
//       }
//     }
//     await File(path).writeAsBytes(bytes);
//     client.close();
//   }
//
//   // --- 6. UI Components ---
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
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8F9FA),
//       appBar: AppBar(
//         title: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text("Gasket Guy", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
//             // Text(_userRole.toUpperCase(), style: const TextStyle(fontSize: 10, letterSpacing: 1.2, color: Colors.blueGrey)),
//             Text("Engineer", style: const TextStyle(fontSize: 10, letterSpacing: 1.2, color: Colors.blueGrey)),
//
//           ],
//         ),
//         // leading: IconButton(onPressed: _showLogoutDialog, icon: const Icon(Icons.logout, color: AppTheme.error)),
//         actions: [
//           IconButton(
//               onPressed: _openMetadataDrawer,
//               icon: const Icon(Icons.folder_shared_outlined, color: Colors.blueGrey)
//           ),
//           IconButton(onPressed: _startFullSyncProcess, icon: const Icon(Icons.sync)),
//         ],
//
//       ),
//       body: Stack(
//         children: [
//           _isLoading
//               ? const Center(child: CircularProgressIndicator())
//               : RefreshIndicator(
//             onRefresh: _refreshData,
//             child: _reports.isEmpty
//                 ? _buildEmptyState()
//                 : ListView.builder(
//               padding: const EdgeInsets.all(16),
//               itemCount: _reports.length,
//               itemBuilder: (context, index) => _buildReportCard(_reports[index]),
//             ),
//           ),
//           if (_isSyncing) _buildSyncOverlay(),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         backgroundColor: AppTheme.primary,
//         onPressed: () async {
//           await Navigator.push(context, MaterialPageRoute(builder: (c) => const NewReportPage()));
//           _refreshData();
//         },
//         label: const Text("NEW REPORT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//         icon: const Icon(Icons.add, color: Colors.white),
//       ),
//     );
//   }
//
//   Widget _buildReportCard(Map<String, dynamic> report) {
//     final date = DateTime.parse(report['report_date']).toLocal();
//     final status = (report['status'] ?? 'pending').toString().toLowerCase();
//     final String title = report['report_title'] ?? "Untitled Report";
//     final String customer = (report['customer'] as Map?)?['full_name'] ?? "Unknown Customer";
//
//     bool isQueuedLocally = status == 'pending sync' || report['id'].toString().startsWith('local_queued_');
//
//     return GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => ViewReportPage(reportId: report['id']),
//           ),
//         );
//       },
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 16),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
//         ),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(16),
//           child: IntrinsicHeight(
//             child: Row(
//               children: [
//                 // Status Indicator Bar
//                 Container(
//                   width: 6,
//                   color: status == 'submitted' ? Colors.green : Colors.orange,
//                 ),
//                 Expanded(
//                   child: Padding(
//                     padding: const EdgeInsets.all(16),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), overflow: TextOverflow.ellipsis)),
//                             const SizedBox(width: 8),
//                             _buildStatusBadge(status),
//                           ],
//                         ),
//                         const SizedBox(height: 6),
//                         Row(
//                           children: [
//                             const Icon(Icons.business, size: 14, color: Colors.grey),
//                             const SizedBox(width: 4),
//                             Text(customer, style: const TextStyle(color: Colors.blueGrey, fontSize: 13)),
//                           ],
//                         ),
//                         const Divider(height: 20),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(DateFormat('MMM dd, yyyy').format(date), style: const TextStyle(color: Colors.grey, fontSize: 12)),
//                             Text(DateFormat('hh:mm a').format(date), style: const TextStyle(color: Colors.grey, fontSize: 12)),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildStatusBadge(String status) {
//     bool isSubmitted = status == 'submitted';
//     bool isPendingSync = status == 'pending sync';
//
//     Color textCol = isPendingSync
//         ? Colors.blueGrey[800]!
//         : (isSubmitted ? Colors.green[700]! : Colors.orange[700]!);
//
//     Color bgCol = isPendingSync
//         ? Colors.blueGrey[50]!
//         : (isSubmitted ? Colors.green[50]! : Colors.orange[50]!);
//
//
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         // color: isSubmitted ? Colors.green[50] : Colors.orange[50],
//         color: bgCol,
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Text(
//         status.toUpperCase(),
//         style: TextStyle(color: textCol, fontWeight: FontWeight.bold, fontSize: 9),
//         // style: TextStyle(color: isSubmitted ? Colors.green[700] : Colors.orange[700], fontWeight: FontWeight.bold, fontSize: 9),
//       ),
//     );
//   }
//
//   Widget _buildEmptyState() {
//     return ListView( // Needs to be ListView for RefreshIndicator
//       children: [
//         SizedBox(height: MediaQuery.of(context).size.height * 0.2),
//         Center(
//           child: Column(
//             children: [
//               Icon(Icons.assignment_outlined, size: 80, color: Colors.grey[300]),
//               const SizedBox(height: 16),
//               const Text("No reports found", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
//               const Text("Your report history will appear here.", style: TextStyle(color: Colors.grey)),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildSyncOverlay() {
//     return Positioned(
//       top: 0, left: 0, right: 0,
//       child: Container(
//         color: AppTheme.primary,
//         padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//         child: Row(
//           children: [
//             const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
//             const SizedBox(width: 12),
//             Expanded(child: Text(_syncMessage, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
//             Text("${(_syncProgress * 100).toStringAsFixed(0)}%", style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Future<void> _triggerOutboxBackgroundSync() async {
//     if (_isPendingOutboxSyncing) return; // Strict execution concurrency block
//
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       List<String> currentQueue = prefs.getStringList('offline_reports_queue') ?? [];
//       if (currentQueue.isEmpty) return;
//
//       _isPendingOutboxSyncing = true;
//       debugPrint("Syncing ${currentQueue.length} offline records out of local outbox cache...");
//
//       while (currentQueue.isNotEmpty) {
//         String firstReportJson = currentQueue.first;
//         bool isSuccess = false;
//
//         try {
//           Map<String, dynamic> rawPayload = jsonDecode(firstReportJson);
//           List<dynamic> rawAssets = rawPayload['assets'] ?? [];
//
//           List<LocalAssetEntry> parsedAssets = rawAssets
//               .map((a) => LocalAssetEntry.fromJson(Map<String, dynamic>.from(a)))
//               .toList();
//
//           // ✅ FIXED: Execute the real database processing logic natively inside this class frame
//           await _processExternalUploadPipeline(
//             customerId: rawPayload['customer_id'],
//             title: rawPayload['report_title'],
//             notes: rawPayload['notes'] ?? '',
//             assets: parsedAssets,
//           );
//
//           isSuccess = true;
//         } catch (error) {
//           debugPrint("Failed processing queue asset item to remote server: $error");
//           break; // Stop execution on database errors to prevent data loss
//         }
//
//         if (isSuccess) {
//           currentQueue.removeAt(0);
//           // Delete from local cache string queue instantly on successful confirmation
//           await prefs.setStringList('offline_reports_queue', currentQueue);
//         }
//       }
//     } catch (e) {
//       debugPrint("Queue manager sync process exception: $e");
//     } finally {
//       _isPendingOutboxSyncing = false;
//       await _refreshData(); // Live refresh UI list layouts immediately
//     }
//   }
//
//   /// ✅ ADD THIS HELPER METHOD inside ReportListPage to handle background upload execution loops cleanly
//   Future<void> _processExternalUploadPipeline({
//     required String customerId,
//     required String title,
//     required String notes,
//     required List<LocalAssetEntry> assets,
//   }) async {
//     const String bucketName = 'engineer-uploads';
//
//     // 1. INSERT REPORT HEADER
//     final reportHeader = await _supabase.from('asset_reports').insert({
//       'customer_id': customerId,
//       'engineer_id': _supabase.auth.currentUser!.id,
//       'report_title': title,
//       'notes': notes,
//       'status': 'submitted',
//     }).select().single();
//
//     final String reportId = reportHeader['id'];
//
//     // 2. LOOP THROUGH FRIDGE ASSETS
//     for (var asset in assets) {
//       String? dataPlateUrl;
//
//       if (asset.dataPlateImage != null && asset.dataPlateImage!.existsSync()) {
//         final String fileName = 'plate_${DateTime.now().millisecondsSinceEpoch}.jpg';
//         final String path = 'reports/$reportId/$fileName';
//         await _supabase.storage.from(bucketName).upload(path, asset.dataPlateImage!);
//         dataPlateUrl = _supabase.storage.from(bucketName).getPublicUrl(path);
//       }
//
//       // --- NEW FRIDGE MASTER REGISTRATION / FALLBACK MECHANISM ---
//       String? targetFridgeId = asset.fridgeId;
//
//       if (targetFridgeId == null) {
//         final existingFridge = await _supabase
//             .from('fridges')
//             .select('id')
//             .eq('model_no', asset.modelNo.trim())
//             .eq('serial_no', asset.serialNo.trim())
//             .maybeSingle();
//
//         if (existingFridge != null) {
//           targetFridgeId = existingFridge['id'];
//         } else {
//           final newFridgeRecord = await _supabase.from('fridges').insert({
//             'manufacturer': asset.manufacturer.trim().isNotEmpty ? asset.manufacturer.trim() : 'Unknown',
//             'brand': asset.brand?.trim(),
//             'model_no': asset.modelNo.trim(),
//             'serial_no': asset.serialNo.trim(),
//             'door_count': asset.doorCount,
//             'drawer_count': asset.drawerCount,
//             'created_by': _supabase.auth.currentUser!.id,
//             'data_plate_image_url': dataPlateUrl,
//           }).select('id').single();
//
//           targetFridgeId = newFridgeRecord['id'];
//         }
//       } else {
//         await _supabase.from('fridges').update({
//           'door_count': asset.doorCount,
//           'drawer_count': asset.drawerCount,
//           'updated_at': DateTime.now().toIso8601String(),
//         }).eq('id', targetFridgeId);
//       }
//
//       // 3. INSERT INTO 'assets_report_fridge'
//       final assetResponse = await _supabase.from('assets_report_fridge').insert({
//         'report_id': reportId,
//         'fridge_id': targetFridgeId,
//         'area': asset.area,
//         'data_plate_url': dataPlateUrl,
//         'manufacturer': asset.brand ?? asset.manufacturer,
//         'model_no': asset.modelNo,
//         'serial_no': asset.serialNo,
//         'condition': asset.condition,
//         'door_count': asset.doorCount,
//         'drawer_count': asset.drawerCount,
//         'seals_are_common': asset.sealsAreCommon,
//         'engineer_notes': asset.description,
//       }).select().single();
//
//       final String assetId = assetResponse['id'];
//
//       // 4. LOOP THROUGH INDIVIDUAL SEALS
//       for (int index = 0; index < asset.individualSeals.length; index++) {
//         var sealItem = asset.individualSeals[index];
//         List<String> sealImageUrls = [];
//
//         for (int i = 0; i < sealItem.images.length; i++) {
//           if (sealItem.images[i].existsSync()) {
//             final String fileName = 'seal_${i}_${DateTime.now().microsecondsSinceEpoch}.jpg';
//             final String path = 'reports/$reportId/seals/$assetId/$fileName';
//             await _supabase.storage.from(bucketName).upload(path, sealItem.images[i]);
//             sealImageUrls.add(_supabase.storage.from(bucketName).getPublicUrl(path));
//           }
//         }
//
//         // 5. INSERT INTO 'asset_report_fridge_items'
//         await _supabase.from('asset_report_fridge_items').insert({
//           'report_asset_id': assetId,
//           'item_name': sealItem.itemName,
//           'seal_id': sealItem.sealId,
//           'is_unknown_seal': sealItem.sealId == null,
//           'confidence_score': sealItem.confidence,
//           'manual_seal_name': sealItem.sealName,
//           'image_urls': sealImageUrls,
//           'item_notes': sealItem.description,
//           'material': sealItem.material,
//           'seal_type': sealItem.sealType,
//           'thickness': sealItem.thickness,
//           'inner_diameter': sealItem.innerDiameter,
//           'outer_diameter': sealItem.outerDiameter,
//           'wear_percentage': sealItem.wearPercentage.toInt(),
//           'need_replacement': sealItem.needsUrgentReplacement,
//         });
//
//         // 6. UPSERT MASTER 'fridge_components'
//         String? componentUuid;
//
//         if (targetFridgeId != null) {
//           final String componentType = sealItem.itemName.toLowerCase().contains('drawer') ? 'drawer' : 'door';
//
//           final existingComp = await _supabase
//               .from('fridge_components')
//               .select()
//               .eq('fridge_id', targetFridgeId)
//               .eq('component_type', componentType)
//               .eq('component_index', index + 1)
//               .maybeSingle();
//
//           if (existingComp == null) {
//             final newComp = await _supabase.from('fridge_components').insert({
//               'fridge_id': targetFridgeId,
//               'component_type': componentType,
//               'component_index': index + 1,
//               'width_mm': sealItem.doorWidth,
//               'height_mm': sealItem.doorHeight,
//               'notes': 'Learned from component field logic.',
//             }).select('id').single();
//
//             componentUuid = newComp['id'];
//           } else {
//             final updatedComp = await _supabase.from('fridge_components').update({
//               'width_mm': sealItem.doorWidth,
//               'height_mm': sealItem.doorHeight,
//             }).eq('id', existingComp['id']).select('id').single();
//
//             componentUuid = updatedComp['id'];
//           }
//         }
//
//         // 7. SYNC 'fridge_seals_relation'
//         if (sealItem.sealId != null && targetFridgeId != null && componentUuid != null) {
//           final existingRelation = await _supabase
//               .from('fridge_seals_relation')
//               .select()
//               .eq('fridge_id', targetFridgeId)
//               .eq('seal_product_id', sealItem.sealId!)
//               .eq('location', sealItem.itemName)
//               .eq('supported_component_id', componentUuid)
//               .maybeSingle();
//
//           if (existingRelation != null) {
//             await _supabase.from('fridge_seals_relation').update({
//               'quantity': (existingRelation['quantity'] ?? 1) + 1,
//               'updated_at': DateTime.now().toIso8601String(),
//             }).eq('id', existingRelation['id']);
//           } else {
//             await _supabase.from('fridge_seals_relation').insert({
//               'fridge_id': targetFridgeId,
//               'seal_product_id': sealItem.sealId,
//               'location': sealItem.itemName,
//               'supported_component_id': componentUuid,
//               'quantity': 1,
//               'is_verified': false,
//               'confidence_score': sealItem.confidence,
//               'matching_notes': "Learned and linked via component UUID from Report: $reportId",
//               'suggested_by_user_id': _supabase.auth.currentUser!.id,
//             });
//           }
//         }
//       }
//     }
//   }
//
//   // --- NEW NESTED RELATIONAL STRUCTURE VIEWER DETAILED SHEET ---
//   void _showFridgeStructureDetails(Map<String, dynamic> fridge) async {
//     final prefs = await SharedPreferences.getInstance();
//     final String fridgeId = fridge['id'].toString();
//
//     // 1. Recover nested cache collection components frames on the fly
//     final String? localCompsJson = prefs.getString('local_fridge_components');
//     List<dynamic> allComponents = localCompsJson != null ? jsonDecode(localCompsJson) : [];
//     List<Map<String, dynamic>> matchedComponents = allComponents
//         .where((c) => c['fridge_id'].toString() == fridgeId)
//         .map((c) => Map<String, dynamic>.from(c))
//         .toList();
//
//     // 2. Recover and cross-match its linked profile assignments out of relational arrays
//     final String? localRelationsJson = prefs.getString('local_fridge_relations');
//     List<dynamic> allRelations = localRelationsJson != null ? jsonDecode(localRelationsJson) : [];
//     List<Map<String, dynamic>> matchedRelations = allRelations
//         .where((r) => r['fridge_id'].toString() == fridgeId)
//         .map((r) => Map<String, dynamic>.from(r))
//         .toList();
//
//     if (!mounted) return;
//
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.white,
//       shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
//       builder: (context) => DraggableScrollableSheet(
//         initialChildSize: 0.85,
//         maxChildSize: 0.95,
//         expand: false,
//         builder: (context, scrollController) => Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             AppBar(
//               title: Text("${fridge['manufacturer']} (${fridge['model_no']})", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
//               backgroundColor: Colors.transparent,
//               elevation: 0,
//               leading: IconButton(icon: const Icon(Icons.close, color: Colors.black87), onPressed: () => Navigator.pop(context)),
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
//               child: Text("S/N Reference: ${fridge['serial_no'] ?? 'N/A'} | Expected Layout: ${fridge['door_count']} Doors / ${fridge['drawer_count']} Drawers",
//                   style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
//             ),
//             const Divider(height: 20),
//             Expanded(
//               child: ListView(
//                 controller: scrollController,
//                 padding: const EdgeInsets.all(16),
//                 children: [
//                   const Text("REGISTERED APP COMPONENT MEASUREMENTS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey, letterSpacing: 0.5)),
//                   const SizedBox(height: 8),
//                   if (matchedComponents.isEmpty)
//                     Padding(padding: const EdgeInsets.all(12), child: Text("No physical door dimensions recorded yet.", style: TextStyle(fontSize: 13, color: Colors.grey[500], fontStyle: FontStyle.italic)))
//                   else
//                     ...matchedComponents.map((comp) {
//                       return Card(
//                         margin: const EdgeInsets.only(bottom: 8),
//                         color: Colors.grey[50],
//                         elevation: 0,
//                         child: ListTile(
//                           leading: Icon(comp['component_type'] == 'drawer' ? Icons.view_agenda_outlined : Icons.door_back_door_outlined, color: AppTheme.primary),
//                           title: Text("${comp['component_type'].toString().toUpperCase()} - Position Index #${comp['component_index']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
//                           subtitle: Text("Dimensions: ${comp['width_mm']} mm Width x ${comp['height_mm']} mm Height", style: const TextStyle(fontSize: 12)),
//                         ),
//                       );
//                     }).toList(),
//
//                   const SizedBox(height: 24),
//                   const Text("LINKED / LEARNED GASKET PROFILE SCHEMAS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey, letterSpacing: 0.5)),
//                   const SizedBox(height: 8),
//                   if (matchedRelations.isEmpty)
//                     Padding(padding: const EdgeInsets.all(12), child: Text("No validated seal profiles bound to this appliance blueprint structure.", style: TextStyle(fontSize: 13, color: Colors.grey[500], fontStyle: FontStyle.italic)))
//                   else
//                     ...matchedRelations.map((rel) {
//                       final product = rel['seal_products'] != null ? Map<String, dynamic>.from(rel['seal_products']) : null;
//                       return Card(
//                         margin: const EdgeInsets.only(bottom: 8),
//                         elevation: 0,
//                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: Colors.grey[200]!)),
//                         child: ListTile(
//                           title: Text("Location Target: ${rel['location']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.primary)),
//                           subtitle: Text(
//                             "Profile Name/Model: ${product != null ? (product['title'] ?? product['seal_model_number'] ?? 'Custom Variant') : 'Unspecified'}\nMaterial: ${product?['material'] ?? 'N/A'} | Verified Fit: ${rel['is_verified'] == true ? 'YES ✅' : 'NO ⏳'}",
//                             style: const TextStyle(fontSize: 11, height: 1.4),
//                           ),
//                         ),
//                       );
//                     }).toList(),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//
// }

import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:mobile/pages/engineer/view_report_page.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../../../theme.dart';
import '../auth_page.dart';
import 'local_database_pages.dart';
import 'new_report_page.dart';

class ReportListPage extends StatefulWidget {
  const ReportListPage({super.key});

  @override
  State<ReportListPage> createState() => _ReportListPageState();
}

class _ReportListPageState extends State<ReportListPage> {
  final SupabaseClient _supabase = Supabase.instance.client;

  // State Management
  bool _isSyncing = false;
  String _syncMessage = "";
  double _syncProgress = 0;
  String _userRole = 'user';
  List<Map<String, dynamic>> _reports = [];
  bool _isLoading = true;
  bool _isPendingOutboxSyncing = false; // Exclusive atomic process lock flag

  @override
  void initState() {
    super.initState();
    _initializePage();
  }


  // --- 1. Initialization Logic ---
  Future<void> _initializePage() async {
    // Load local reports first for instant UI
    await _loadLocalReports();

    // Start role check and background sync
    await _checkUserRole();

    if (_userRole == 'engineer') {
      _startFullSyncProcess();
    } else {
      _refreshData(); // Standard refresh for non-engineers
    }
  }

  // --- 2. Local Storage Methods ---
  // Future<void> _loadLocalReports() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final String? cachedData = prefs.getString('cached_my_reports');
  //   if (cachedData != null) {
  //     setState(() {
  //       _reports = List<Map<String, dynamic>>.from(jsonDecode(cachedData));
  //       _isLoading = false;
  //     });
  //   }
  // }

  Future<void> _loadLocalReports() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 1. Fetch verified server records cache layer
      final String? cachedData = prefs.getString('cached_my_reports');
      List<Map<String, dynamic>> combinedList = [];

      if (cachedData != null) {
        combinedList = List<Map<String, dynamic>>.from(jsonDecode(cachedData));
      }

      // --- FIXED: Fetch local customers catalog directly from cache storage to resolve reference ---
      List<Map<String, dynamic>> localCustomersList = [];
      final String? localCustomersJson = prefs.getString('local_customers');
      if (localCustomersJson != null) {
        localCustomersList = List<Map<String, dynamic>>.from(jsonDecode(localCustomersJson));
      }

      // 2. Fetch standalone offline outbox queue records
      final List<String> currentQueue = prefs.getStringList('offline_reports_queue') ?? [];
      List<Map<String, dynamic>> offlineItems = [];

      for (String itemJson in currentQueue) {
        try {
          final Map<String, dynamic> rawReport = jsonDecode(itemJson);

          // Map customer labels smoothly from the locally retrieved customer list
          String customerName = "Unknown Customer";
          if (rawReport['customer_id'] != null && localCustomersList.isNotEmpty) {
            final match = localCustomersList.where(
                    (c) => c['id'].toString() == rawReport['customer_id'].toString()
            );
            if (match.isNotEmpty) {
              customerName = match.first['full_name'] ?? customerName;
            }
          }

          offlineItems.add({
            'id': rawReport['id'] ?? 'local_queued_${DateTime.now().millisecondsSinceEpoch}',
            'report_title': rawReport['report_title'] ?? 'Untitled Report',
            'report_date': rawReport['report_date'] ?? DateTime.now().toIso8601String(),
            'status': 'pending sync',
            'customer': {
              'full_name': customerName,
            }
          });
        } catch (_) {}
      }

      // Merge arrays putting outbox modifications at the top of the viewing array layout
      setState(() {
        _reports = [...offlineItems, ...combinedList];
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Offline Reports Merging Error: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveReportsLocally(List<Map<String, dynamic>> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cached_my_reports', jsonEncode(data));
  }

  // --- 3. Data Fetching (Filtered by Auth User) ---
  // Future<void> _refreshData() async {
  //   try {
  //     final userId = _supabase.auth.currentUser?.id;
  //     if (userId == null) return;
  //
  //     final dynamic data = await _supabase
  //         .from('asset_reports')
  //         .select('*, customer:user_profiles!customer_id(full_name)')
  //         .eq('engineer_id', userId) // CRITICAL: Show only my reports
  //         .order('report_date', ascending: false);
  //
  //     final List<Map<String, dynamic>> fetchedReports =
  //     List<Map<String, dynamic>>.from(data as List);
  //
  //     if (mounted) {
  //       setState(() {
  //         _reports = fetchedReports;
  //         _isLoading = false;
  //       });
  //       await _saveReportsLocally(fetchedReports);
  //     }
  //   } catch (e) {
  //     debugPrint("Fetch Error: $e");
  //     if (mounted) setState(() => _isLoading = false);
  //   }
  // }


  // Inside _ReportListPageState in report_list_page.dart

  // Future<void> _refreshData() async {
  //   try {
  //     final userId = _supabase.auth.currentUser?.id;
  //     if (userId == null) return;
  //
  //     // UPDATE: Fetch full details (fridges and seals) to support offline viewing
  //     final dynamic data = await _supabase
  //         .from('asset_reports')
  //         .select('''
  //         *,
  //         customer:user_profiles!customer_id(full_name, email),
  //         fridges:assets_report_fridge(
  //           *,
  //           seals:asset_report_fridge_items (*)
  //         )
  //       ''')
  //         .eq('engineer_id', userId)
  //         .order('report_date', ascending: false);
  //
  //     final List<Map<String, dynamic>> fetchedReports =
  //     List<Map<String, dynamic>>.from(data as List);
  //
  //     if (mounted) {
  //       setState(() {
  //         _reports = fetchedReports;
  //         _isLoading = false;
  //       });
  //       // This now saves the FULL details of all reports locally
  //       await _saveReportsLocally(fetchedReports);
  //     }
  //   } catch (e) {
  //     debugPrint("Fetch Error: $e");
  //     if (mounted) setState(() => _isLoading = false);
  //   }
  // }

  // --- 4. Role & Sync Orchestration ---


  Future<void> _refreshData() async {
    try {
      final List<ConnectivityResult> connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult.contains(ConnectivityResult.none)) {
        // Phone is offline -> Pull local cache items immediately and don't try calling Supabase
        await _loadLocalReports();
        return;
      }

      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final dynamic data = await _supabase
          .from('asset_reports')
          .select('''
          *,
          customer:user_profiles!customer_id(full_name, email),
          fridges:assets_report_fridge(
            *,
            seals:asset_report_fridge_items (*)
          )
        ''')
          .eq('engineer_id', userId)
          .order('report_date', ascending: false);

      final List<Map<String, dynamic>> fetchedReports =
      List<Map<String, dynamic>>.from(data as List);

      if (mounted) {
        setState(() {
          _reports = fetchedReports;
          _isLoading = false;
        });
        await _saveReportsLocally(fetchedReports);

        // Re-run the local processor to merge pending offline entries on top of the live list
        await _loadLocalReports();
      }
    } catch (e) {
      debugPrint("Fetch Error: $e");
      await _loadLocalReports(); // Fallback to offline visibility state smoothly on error
    }
  }

  Future<void> _checkUserRole() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;
    try {
      final data = await _supabase.from('user_profiles').select('role').eq('id', userId).single();
      if (mounted) setState(() => _userRole = data['role'] ?? 'user');
    } catch (e) {
      debugPrint("Role Check Error: $e");
    }
  }

  Future<void> _startFullSyncProcess() async {
    // 1. Check connectivity first
    final List<ConnectivityResult> connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.none)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No internet connection. Cannot sync new data."),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    setState(() {
      _isSyncing = true;
      _syncProgress = 0.1;
      _syncMessage = "Connecting to server...";
    });

    try {
      // 2. Fetch all metadata (Customers, Products, Fridges, Components, Relations)
      await _triggerOutboxBackgroundSync();
      setState(() => _syncProgress = 0.4);

      await _syncMetadata();
      setState(() => _syncProgress = 0.5);

      // 3. Fetch latest reports for this engineer
      await _refreshData();
      setState(() => _syncProgress = 0.8);

      // 4. Check for AI Model updates
      await _checkForModelUpdate();
      setState(() => _syncProgress = 1.0);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("All data updated successfully!"),
            backgroundColor: AppTheme.success,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint("Sync Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Sync failed: $e"), backgroundColor: AppTheme.error),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSyncing = false;
          _syncMessage = "";
        });
      }
    }
  }
  // Future<void> _syncMetadata() async {
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     final profiles = await _supabase.from('user_profiles').select().filter('role', 'in', '("engineer","user")');
  //     final products = await _supabase.from('seal_products').select();
  //
  //     await prefs.setString('local_customers', jsonEncode(profiles));
  //     await prefs.setString('local_products', jsonEncode(products));
  //     debugPrint("Metadata Synced.");
  //   } catch (e) {
  //     debugPrint("Metadata Sync Error: $e");
  //   }
  // }

  // --- 5. AI Model Update Logic (Existing) ---
  // Future<void> _checkForModelUpdate() async {
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     int? localVer = prefs.getInt('current_model_version');
  //
  //     final dynamic remoteRes = await _supabase
  //         .from('model_versions')
  //         .select()
  //         .eq('is_active', true)
  //         .order('version', ascending: false)
  //         .limit(1)
  //         .maybeSingle();
  //
  //     if (remoteRes == null) return;
  //     final int remoteVer = remoteRes['version'] as int;
  //
  //     if (localVer != null && localVer >= remoteVer) return;
  //
  //     // Check postpone status
  //     final userId = _supabase.auth.currentUser!.id;
  //     final dynamic userStatus = await _supabase.from('user_model_status').select().eq('user_id', userId).maybeSingle();
  //
  //     bool shouldPrompt = true;
  //     if (userStatus != null && userStatus['postponed_at'] != null) {
  //       final DateTime postponedAt = DateTime.parse(userStatus['postponed_at']).toUtc();
  //       final int hours = userStatus['postpone_hours_requested'] ?? 0;
  //       if (DateTime.now().toUtc().isBefore(postponedAt.add(Duration(hours: hours)))) {
  //         shouldPrompt = false;
  //       }
  //     }
  //
  //     if (shouldPrompt && mounted) _showUpdatePrompt(remoteRes, userStatus);
  //   } catch (e) {
  //     debugPrint("Model Check Error: $e");
  //   }
  // }


  Future<void> _checkForModelUpdate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      int? localVer = prefs.getInt('current_model_version');

      final dynamic remoteRes = await _supabase
          .from('model_versions')
          .select()
          .eq('is_active', true)
          .order('version', ascending: false)
          .limit(1)
          .maybeSingle();

      if (remoteRes == null) return;
      final int remoteVer = remoteRes['version'] as int;

      // --- ADD THIS LINE TO SAVE DATA FOR PROFILE PAGE ---
      await prefs.setInt('latest_model_version_sync', remoteVer);

      if (localVer != null && localVer >= remoteVer) return;

      // Check postpone status
      final userId = _supabase.auth.currentUser!.id;
      final dynamic userStatus = await _supabase.from('user_model_status').select().eq('user_id', userId).maybeSingle();

      bool shouldPrompt = true;
      if (userStatus != null && userStatus['postponed_at'] != null) {
        final DateTime postponedAt = DateTime.parse(userStatus['postponed_at']).toUtc();
        final int hours = userStatus['postpone_hours_requested'] ?? 0;
        if (DateTime.now().toUtc().isBefore(postponedAt.add(Duration(hours: hours)))) {
          shouldPrompt = false;
        }
      }

      if (shouldPrompt && mounted) _showUpdatePrompt(remoteRes, userStatus);
    } catch (e) {
      debugPrint("Model Check Error: $e");
    }
  }


  void _showUpdatePrompt(dynamic remoteRes, dynamic userStatus) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("AI Update Available"),
        content: Text("Version v${remoteRes['version']} is ready. Update now?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("LATER")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _startAssetDownload(remoteRes['model_url'], remoteRes['labels_url'], remoteRes['version'], remoteRes['id']);
            },
            child: const Text("UPDATE"),
          ),
        ],
      ),
    );
  }

  Future<void> _startAssetDownload(String mUrl, String? lUrl, int ver, String vId) async {
    if (!mounted) return;
    setState(() {
      _isSyncing = true;
      _syncMessage = "Downloading Model v$ver...";
      _syncProgress = 0;
    });

    try {
      final dir = await getApplicationDocumentsDirectory();
      final mPath = "${dir.path}/model_v$ver.tflite";
      await _executeDownload(mUrl, mPath);

      if (lUrl != null) {
        final lPath = "${dir.path}/labels_v$ver.txt";
        await _executeDownload(lUrl, lPath);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('current_labels_path', lPath);
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('current_model_version', ver);
      await prefs.setString('current_model_path', mPath);

      await _supabase.from('user_model_status').upsert({'user_id': _supabase.auth.currentUser!.id, 'current_version_id': vId, 'status': 'up_to_date'}, onConflict: 'user_id');
      if (mounted) setState(() => _isSyncing = false);
    } catch (e) {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  // Future<void> _syncMetadata() async {
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //
  //     // 1. Fetch all required tables
  //     final profiles = await _supabase.from('user_profiles').select().filter('role', 'in', '("engineer","user")');
  //     final products = await _supabase.from('seal_products').select();
  //
  //     // 2. Fetch Fridges and their Seal Relations (including the seal data joined)
  //     final fridges = await _supabase.from('fridges').select();
  //
  //     // This join gets the relation AND the seal product details in one go
  //     final fridgeRelations = await _supabase.from('fridge_seals_relation').select('''
  //     *,
  //     seal_products:seal_product_id (*,seal_model_number)
  //   ''');
  //
  //     // 3. Save to Local Storage
  //     await prefs.setString('local_customers', jsonEncode(profiles));
  //     await prefs.setString('local_products', jsonEncode(products));
  //     await prefs.setString('local_fridges', jsonEncode(fridges));
  //     await prefs.setString('local_fridge_relations', jsonEncode(fridgeRelations));
  //
  //     debugPrint("Metadata, Fridges, and Relations Synced Locally.");
  //   } catch (e) {
  //     debugPrint("Metadata Sync Error: $e");
  //   }
  // }


  // Future<void> _syncMetadata() async {
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     final userId = _supabase.auth.currentUser?.id;
  //
  //     // 1. Fetch all required tables
  //     final profiles = await _supabase.from('user_profiles').select().filter('role', 'in', '("engineer","user")');
  //     final products = await _supabase.from('seal_products').select();
  //     final fridges = await _supabase.from('fridges').select();
  //
  //     final fridgeRelations = await _supabase.from('fridge_seals_relation').select('''
  //     *,
  //     seal_products:seal_product_id (*,seal_model_number)
  //   ''');
  //
  //     // --- NEW: Sync current user's specific profile for the Edit Page ---
  //     if (userId != null) {
  //       final myProfile = await _supabase
  //           .from('user_profiles')
  //           .select('full_name, phone')
  //           .eq('id', userId)
  //           .maybeSingle();
  //
  //       if (myProfile != null) {
  //         await prefs.setString('current_user_profile', jsonEncode(myProfile));
  //       }
  //     }
  //
  //     // 2. Save to Local Storage
  //     await prefs.setString('local_customers', jsonEncode(profiles));
  //     await prefs.setString('local_products', jsonEncode(products));
  //     await prefs.setString('local_fridges', jsonEncode(fridges));
  //     await prefs.setString('local_fridge_relations', jsonEncode(fridgeRelations));
  //
  //     debugPrint("Metadata and User Profile Synced Locally.");
  //   } catch (e) {
  //     debugPrint("Metadata Sync Error: $e");
  //   }
  // }


  Future<void> _syncMetadata() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = _supabase.auth.currentUser?.id;

      setState(() {
        _syncMessage = "Syncing Catalogs & Components...";
      });

      // 1. Fetch User Profiles & Product Catalog
      final profiles = await _supabase.from('user_profiles').select().eq('role', 'user');
      // final profiles = await _supabase.from('user_profiles').select().filter('role', 'in', '("engineer","user")');
      final products = await _supabase.from('seal_products').select();

      // 2. Fetch Fridges Master Data
      final fridges = await _supabase.from('fridges').select();

      // 3. Fetch Fridge Components (Height, Width for each door/drawer)
      final components = await _supabase.from('fridge_components').select();

      // 4. Fetch Fridge-Seal Relations with Nested Product Info
      // This allows you to know exactly which seal fits which fridge even while offline
      final fridgeRelations = await _supabase.from('fridge_seals_relation').select('''
        *,
        seal_products:seal_product_id (*)
      ''');

      // 5. Sync current user's profile for personal settings
      if (userId != null) {
        final myProfile = await _supabase
            .from('user_profiles')
            .select('full_name, phone, email, role')
            .eq('id', userId)
            .maybeSingle();

        if (myProfile != null) {
          await prefs.setString('current_user_profile', jsonEncode(myProfile));
        }
      }

      // 6. Save everything to SharedPreferences
      // We use clear keys so other pages can access them easily
      await prefs.setString('local_customers', jsonEncode(profiles));
      await prefs.setString('local_products', jsonEncode(products));
      await prefs.setString('local_fridges', jsonEncode(fridges));
      await prefs.setString('local_fridge_components', jsonEncode(components));
      await prefs.setString('local_fridge_relations', jsonEncode(fridgeRelations));

      debugPrint("Full Database Sync Complete: Profiles, Products, Fridges, Components, and Relations.");
    } catch (e) {
      debugPrint("Metadata Sync Error: $e");
    }
  }

  Future<void> _executeDownload(String url, String path) async {
    final client = Client();
    final response = await client.send(Request('GET', Uri.parse(url)));
    final List<int> bytes = [];
    await for (final chunk in response.stream) {
      bytes.addAll(chunk);
      if (response.contentLength != null && mounted) {
        setState(() => _syncProgress = bytes.length / response.contentLength!);
      }
    }
    await File(path).writeAsBytes(bytes);
    client.close();
  }


  // --- 6. UI Components ---
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Gasket Guy", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            // Text(_userRole.toUpperCase(), style: const TextStyle(fontSize: 10, letterSpacing: 1.2, color: Colors.blueGrey)),
            Text("Engineer", style: const TextStyle(fontSize: 10, letterSpacing: 1.2, color: Colors.blueGrey)),

          ],
        ),
        // leading: IconButton(onPressed: _showLogoutDialog, icon: const Icon(Icons.logout, color: AppTheme.error)),
        actions: [
          IconButton(onPressed: _startFullSyncProcess, icon: const Icon(Icons.sync)),
        ],

      ),
      drawer: Drawer(
        child: Container(
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drawer Top Header Area
              UserAccountsDrawerHeader(
                decoration: const BoxDecoration(color: AppTheme.primary),
                currentAccountPicture: const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.engineering, color: AppTheme.primary, size: 36),
                ),
                accountName: const Text("Engineer Dashboard", style: TextStyle(fontWeight: FontWeight.bold)),
                accountEmail: Text(_supabase.auth.currentUser?.email ?? "engineer@gasketguy.com"),
              ),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text("LOCAL DATABASES", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey[400], letterSpacing: 1.1)),
              ),

              // Menu Item 1: Customers Page Hook
              _buildDrawerMenuItem(
                icon: Icons.people_alt_outlined,
                title: "Customers",
                onTap: () {
                  Navigator.pop(context); // Close left drawer drawer
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const LocalCustomersPage()));
                },
              ),

              // Menu Item 2: Master Fridges Page Hook
              _buildDrawerMenuItem(
                icon: Icons.kitchen_outlined,
                title: "Fridges",
                onTap: () {
                  Navigator.pop(context); // Close left drawer drawer
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const LocalFridgesPage()));
                },
              ),

              // Menu Item 3: Seal Products Page Hook
              _buildDrawerMenuItem(
                icon: Icons.qr_code_scanner_outlined,
                title: "Seals",
                onTap: () {
                  Navigator.pop(context); // Close left drawer drawer
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const LocalSealsPage()));
                },
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
            onRefresh: _refreshData,
            child: _reports.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _reports.length,
              itemBuilder: (context, index) => _buildReportCard(_reports[index]),
            ),
          ),
          if (_isSyncing) _buildSyncOverlay(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primary,
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (c) => const NewReportPage()));
          _refreshData();
          _startFullSyncProcess();
        },
        label: const Text("NEW REPORT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildReportCard(Map<String, dynamic> report) {
    final date = DateTime.parse(report['report_date']).toLocal();
    final status = (report['status'] ?? 'pending').toString().toLowerCase();
    final String title = report['report_title'] ?? "Untitled Report";
    final String customer = (report['customer'] as Map?)?['full_name'] ?? "Unknown Customer";

    bool isQueuedLocally = status == 'pending sync' || report['id'].toString().startsWith('local_queued_');

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ViewReportPage(reportId: report['id']),
          ),
        );
      },
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  // Status Indicator Bar
                  Container(
                    width: 6,
                    color: status == 'submitted' ? Colors.green : Colors.orange,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), overflow: TextOverflow.ellipsis)),
                              const SizedBox(width: 8),
                              _buildStatusBadge(status),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.business, size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(customer, style: const TextStyle(color: Colors.blueGrey, fontSize: 13)),
                            ],
                          ),
                          const Divider(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(DateFormat('MMM dd, yyyy').format(date), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                              Text(DateFormat('hh:mm a').format(date), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
    );
  }

  Widget _buildStatusBadge(String status) {
    bool isSubmitted = status == 'submitted';
    bool isPendingSync = status == 'pending sync';

    Color textCol = isPendingSync
        ? Colors.blueGrey[800]!
        : (isSubmitted ? Colors.green[700]! : Colors.orange[700]!);

    Color bgCol = isPendingSync
        ? Colors.blueGrey[50]!
        : (isSubmitted ? Colors.green[50]! : Colors.orange[50]!);


    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        // color: isSubmitted ? Colors.green[50] : Colors.orange[50],
        color: bgCol,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: textCol, fontWeight: FontWeight.bold, fontSize: 9),
        // style: TextStyle(color: isSubmitted ? Colors.green[700] : Colors.orange[700], fontWeight: FontWeight.bold, fontSize: 9),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView( // Needs to be ListView for RefreshIndicator
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        Center(
          child: Column(
            children: [
              Icon(Icons.assignment_outlined, size: 80, color: Colors.grey[300]),
              const SizedBox(height: 16),
              const Text("No reports found", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
              const Text("Your report history will appear here.", style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSyncOverlay() {
    return Positioned(
      top: 0, left: 0, right: 0,
      child: Container(
        color: AppTheme.primary,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Row(
          children: [
            const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
            const SizedBox(width: 12),
            Expanded(child: Text(_syncMessage, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
            Text("${(_syncProgress * 100).toStringAsFixed(0)}%", style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Future<void> _triggerOutboxBackgroundSync() async {
    if (_isPendingOutboxSyncing) return; // Strict execution concurrency block

    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> currentQueue = prefs.getStringList('offline_reports_queue') ?? [];
      if (currentQueue.isEmpty) return;

      _isPendingOutboxSyncing = true;
      debugPrint("Syncing ${currentQueue.length} offline records out of local outbox cache...");

      while (currentQueue.isNotEmpty) {
        String firstReportJson = currentQueue.first;
        bool isSuccess = false;

        try {
          Map<String, dynamic> rawPayload = jsonDecode(firstReportJson);
          List<dynamic> rawAssets = rawPayload['assets'] ?? [];

          List<LocalAssetEntry> parsedAssets = rawAssets
              .map((a) => LocalAssetEntry.fromJson(Map<String, dynamic>.from(a)))
              .toList();

          // ✅ FIXED: Execute the real database processing logic natively inside this class frame
          await _processExternalUploadPipeline(
            customerId: rawPayload['customer_id'],
            title: rawPayload['report_title'],
            notes: rawPayload['notes'] ?? '',
            assets: parsedAssets,
          );

          isSuccess = true;
        } catch (error) {
          debugPrint("Failed processing queue asset item to remote server: $error");
          break; // Stop execution on database errors to prevent data loss
        }

        if (isSuccess) {
          currentQueue.removeAt(0);
          // Delete from local cache string queue instantly on successful confirmation
          await prefs.setStringList('offline_reports_queue', currentQueue);
        }
      }
    } catch (e) {
      debugPrint("Queue manager sync process exception: $e");
    } finally {
      _isPendingOutboxSyncing = false;
      await _refreshData(); // Live refresh UI list layouts immediately
    }
  }

  /// ✅ ADD THIS HELPER METHOD inside ReportListPage to handle background upload execution loops cleanly
  Future<void> _processExternalUploadPipeline({
    required String customerId,
    required String title,
    required String notes,
    required List<LocalAssetEntry> assets,
  }) async {
    const String bucketName = 'engineer-uploads';

    // 1. INSERT REPORT HEADER
    final reportHeader = await _supabase.from('asset_reports').insert({
      'customer_id': customerId,
      'engineer_id': _supabase.auth.currentUser!.id,
      'report_title': title,
      'notes': notes,
      'status': 'submitted',
    }).select().single();

    final String reportId = reportHeader['id'];

    // 2. LOOP THROUGH FRIDGE ASSETS
    for (var asset in assets) {
      String? dataPlateUrl;

      if (asset.dataPlateImage != null && asset.dataPlateImage!.existsSync()) {
        final String fileName = 'plate_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final String path = 'reports/$reportId/$fileName';
        await _supabase.storage.from(bucketName).upload(path, asset.dataPlateImage!);
        dataPlateUrl = _supabase.storage.from(bucketName).getPublicUrl(path);
      }

      // --- NEW FRIDGE MASTER REGISTRATION / FALLBACK MECHANISM ---
      String? targetFridgeId = asset.fridgeId;

      // if (targetFridgeId == null) {
      //   final existingFridge = await _supabase
      //       .from('fridges')
      //       .select('id')
      //       .eq('model_no', asset.modelNo.trim())
      //       .eq('serial_no', asset.serialNo.trim())
      //       .maybeSingle();
      //
      //   if (existingFridge != null) {
      //     targetFridgeId = existingFridge['id'];
      //   } else {
      //     final newFridgeRecord = await _supabase.from('fridges').insert({
      //       'manufacturer': asset.manufacturer.trim().isNotEmpty ? asset.manufacturer.trim() : 'Unknown',
      //       'brand': asset.brand?.trim(),
      //       'model_no': asset.modelNo.trim(),
      //       'serial_no': asset.serialNo.trim(),
      //       'door_count': asset.doorCount,
      //       'drawer_count': asset.drawerCount,
      //       'created_by': _supabase.auth.currentUser!.id,
      //       'data_plate_image_url': dataPlateUrl,
      //     }).select('id').single();
      //
      //     targetFridgeId = newFridgeRecord['id'];
      //   }
      // } else {
      //   await _supabase.from('fridges').update({
      //     'door_count': asset.doorCount,
      //     'drawer_count': asset.drawerCount,
      //     'updated_at': DateTime.now().toIso8601String(),
      //   }).eq('id', targetFridgeId);
      // }

      // --- ✅ 100% FIXED & COMPILE-SAFE FRIDGE MASTER REGISTRATION ---


      final String safeModel = (asset.modelNo.isNotEmpty ? asset.modelNo : 'N/A').trim();
      final String safeSerial = (asset.serialNo.isNotEmpty ? asset.serialNo : 'N/A').trim();

      String tentativeBrand = 'Generic Brand';
      if (asset.brand != null && asset.brand!.trim().isNotEmpty) {
        tentativeBrand = asset.brand!;
      } else if (asset.manufacturer.trim().isNotEmpty) {
        tentativeBrand = asset.manufacturer;
      }
      final String safeBrand = tentativeBrand.trim();

      if (targetFridgeId == null) {
        // Safe lookup to handle historical duplicates without crashing
        final existingFridge = await _supabase
            .from('fridges')
            .select('id')
            .eq('model_no', safeModel)
            .eq('serial_no', safeSerial)
            .limit(1)
            .maybeSingle();

        if (existingFridge != null) {
          targetFridgeId = existingFridge['id'];
          // Update existing record structure live
          await _supabase.from('fridges').update({
            'manufacturer': safeBrand,
            'brand': safeBrand,
            'door_count': asset.doorCount,
            'drawer_count': asset.drawerCount,
            'data_plate_image_url': dataPlateUrl ?? asset.dataPlateImage?.path,
            'updated_at': DateTime.now().toIso8601String(),
          }).eq('id', targetFridgeId!);
          debugPrint("🔄 Existing master fridge matched and updated successfully: $targetFridgeId");
        } else {
          // Safe pristine insert routine with fallback validation mapping
          final newFridgeRecord = await _supabase.from('fridges').insert({
            'manufacturer': safeBrand,
            'brand': safeBrand,
            'model_no': safeModel,
            'serial_no': safeSerial,
            'door_count': asset.doorCount,
            'drawer_count': asset.drawerCount,
            'created_by': _supabase.auth.currentUser!.id,
            'data_plate_image_url': dataPlateUrl,
          }).select('id').maybeSingle();

          // Null-coalescing guard fallback path configuration
          targetFridgeId = newFridgeRecord?['id']?.toString();
          debugPrint("🆕 No match found. Created a fresh master fridge row: $targetFridgeId");
        }
      } else {
        // Direct explicit template override update update call
        await _supabase.from('fridges').update({
          'door_count': asset.doorCount,
          'drawer_count': asset.drawerCount,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', targetFridgeId);
      }

      // Guard Clause: Ensure targetFridgeId is absolutely resolved before entering Step 3 insertion passes
      final String verifiedFridgeId = targetFridgeId ?? '00000000-0000-0000-0000-000000000000';

      // 3. INSERT INTO 'assets_report_fridge' (Using guaranteed non-null verifiedFridgeId string)
      final assetResponse = await _supabase.from('assets_report_fridge').insert({
        'report_id': reportId,
        'fridge_id': verifiedFridgeId, // ✅ Safely linked without any type mismatch errors
        'area': asset.area,
        'data_plate_url': dataPlateUrl,
        'manufacturer': asset.brand ?? asset.manufacturer,
        'model_no': asset.modelNo,
        'serial_no': asset.serialNo,
        'condition': asset.condition,
        'door_count': asset.doorCount,
        'drawer_count': asset.drawerCount,
        'seals_are_common': asset.sealsAreCommon,
        'engineer_notes': asset.description,
      }).select().single();

      // 3. INSERT INTO 'assets_report_fridge'
      // final assetResponse = await _supabase.from('assets_report_fridge').insert({
      //   'report_id': reportId,
      //   'fridge_id': targetFridgeId,
      //   'area': asset.area,
      //   'data_plate_url': dataPlateUrl,
      //   'manufacturer': asset.brand ?? asset.manufacturer,
      //   'model_no': asset.modelNo,
      //   'serial_no': asset.serialNo,
      //   'condition': asset.condition,
      //   'door_count': asset.doorCount,
      //   'drawer_count': asset.drawerCount,
      //   'seals_are_common': asset.sealsAreCommon,
      //   'engineer_notes': asset.description,
      // }).select().single();

      final String assetId = assetResponse['id'];

      // 4. LOOP THROUGH INDIVIDUAL SEALS
      for (int index = 0; index < asset.individualSeals.length; index++) {
        var sealItem = asset.individualSeals[index];
        List<String> sealImageUrls = [];

        for (int i = 0; i < sealItem.images.length; i++) {
          if (sealItem.images[i].existsSync()) {
            final String fileName = 'seal_${i}_${DateTime.now().microsecondsSinceEpoch}.jpg';
            final String path = 'reports/$reportId/seals/$assetId/$fileName';
            await _supabase.storage.from(bucketName).upload(path, sealItem.images[i]);
            sealImageUrls.add(_supabase.storage.from(bucketName).getPublicUrl(path));
          }
        }

        // 5. INSERT INTO 'asset_report_fridge_items'
        await _supabase.from('asset_report_fridge_items').insert({
          'report_asset_id': assetId,
          'item_name': sealItem.itemName,
          'seal_id': sealItem.sealId,
          'is_unknown_seal': sealItem.sealId == null,
          'confidence_score': sealItem.confidence,
          'manual_seal_name': sealItem.sealName,
          'image_urls': sealImageUrls,
          'item_notes': sealItem.description,
          'material': sealItem.material,
          'seal_type': sealItem.sealType,
          'thickness': sealItem.thickness,
          'inner_diameter': sealItem.innerDiameter,
          'outer_diameter': sealItem.outerDiameter,
          'wear_percentage': sealItem.wearPercentage.toInt(),
          'need_replacement': sealItem.needsUrgentReplacement,
        });

        // 6. UPSERT MASTER 'fridge_components'
        // String? componentUuid;
        //
        // if (targetFridgeId != null) {
        //   final String componentType = sealItem.itemName.toLowerCase().contains('drawer') ? 'drawer' : 'door';
        //
        //   final existingComp = await _supabase
        //       .from('fridge_components')
        //       .select()
        //       .eq('fridge_id', targetFridgeId)
        //       .eq('component_type', componentType)
        //       .eq('component_index', index + 1)
        //       .maybeSingle();
        //
        //   if (existingComp == null) {
        //     final newComp = await _supabase.from('fridge_components').insert({
        //       'fridge_id': targetFridgeId,
        //       'component_type': componentType,
        //       'component_index': index + 1,
        //       'width_mm': sealItem.doorWidth,
        //       'height_mm': sealItem.doorHeight,
        //       'notes': 'Learned from component field logic.',
        //     }).select('id').single();
        //
        //     componentUuid = newComp['id'];
        //   } else {
        //     final updatedComp = await _supabase.from('fridge_components').update({
        //       'width_mm': sealItem.doorWidth,
        //       'height_mm': sealItem.doorHeight,
        //     }).eq('id', existingComp['id']).select('id').single();
        //
        //     componentUuid = updatedComp['id'];
        //   }
        // }

        // --- ✅ FIXED: UPSERT MASTER 'fridge_components' BY INDEX & TYPE ---
        String? componentUuid;

        if (targetFridgeId != null) {
          final String componentType = sealItem.itemName.toLowerCase().contains('drawer') ? 'drawer' : 'door';
          final double verifiedWidth = sealItem.doorWidth > 0 ? sealItem.doorWidth : 100.0;
          final double verifiedHeight = sealItem.doorHeight > 0 ? sealItem.doorHeight : 100.0;

          // Check using .limit(1).maybeSingle() to stay secure against multiple component records
          final existingComp = await _supabase
              .from('fridge_components')
              .select('id')
              .eq('fridge_id', targetFridgeId)
              .eq('component_type', componentType)
              .eq('component_index', index + 1)
              .limit(1)
              .maybeSingle();

          if (existingComp == null) {
            // Naya component insert karo agar index position khali hai
            final newComp = await _supabase.from('fridge_components').insert({
              'fridge_id': targetFridgeId,
              'component_type': componentType,
              'component_index': index + 1,
              'width_mm': verifiedWidth,
              'height_mm': verifiedHeight,
              'notes': 'Learned from component field logic.',
            }).select('id').single();

            componentUuid = newComp['id'];
          } else {
            // Puraane component record ki dimensions update karo bina naya row banaye
            final updatedComp = await _supabase.from('fridge_components').update({
              'width_mm': verifiedWidth,
              'height_mm': verifiedHeight,
            }).eq('id', existingComp['id']).select('id').single();

            componentUuid = updatedComp['id'];
            debugPrint("🔄 Updated dimensions for existing component position: ${index + 1}");
          }
        }

        // 7. SYNC 'fridge_seals_relation'
        // 7. SYNC 'fridge_seals_relation'
        if (sealItem.sealId != null && targetFridgeId != null && componentUuid != null) {
          // ✅ FIXED: Added .limit(1) safety guard to prevent 406 multi-row crash
          final existingRelation = await _supabase
              .from('fridge_seals_relation')
              .select()
              .eq('fridge_id', targetFridgeId)
              .eq('seal_product_id', sealItem.sealId!)
              .eq('location', sealItem.itemName)
              .eq('supported_component_id', componentUuid)
              .limit(1)          // ✅ Critical guard for legacy duplicates
              .maybeSingle();

          if (existingRelation != null) {
            await _supabase.from('fridge_seals_relation').update({
              'quantity': (existingRelation['quantity'] ?? 1) + 1,
              'updated_at': DateTime.now().toIso8601String(),
            }).eq('id', existingRelation['id']);
          } else {
            await _supabase.from('fridge_seals_relation').insert({
              'fridge_id': targetFridgeId,
              'seal_product_id': sealItem.sealId,
              'location': sealItem.itemName,
              'supported_component_id': componentUuid,
              'quantity': 1,
              'is_verified': false,
              'confidence_score': sealItem.confidence,
              'matching_notes': "Learned and linked via component UUID from Report: $reportId",
              'suggested_by_user_id': _supabase.auth.currentUser!.id,
            });
          }
        }
      }
    }
  }

  Widget _buildDrawerMenuItem({required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primary, size: 22),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
      onTap: onTap,
    );
  }
}
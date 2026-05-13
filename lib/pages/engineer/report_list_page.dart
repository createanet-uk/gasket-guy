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


import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:mobile/pages/engineer/view_report_page.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
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

  // State Management
  bool _isSyncing = false;
  String _syncMessage = "";
  double _syncProgress = 0;
  String _userRole = 'user';
  List<Map<String, dynamic>> _reports = [];
  bool _isLoading = true;

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
  Future<void> _loadLocalReports() async {
    final prefs = await SharedPreferences.getInstance();
    final String? cachedData = prefs.getString('cached_my_reports');
    if (cachedData != null) {
      setState(() {
        _reports = List<Map<String, dynamic>>.from(jsonDecode(cachedData));
        _isLoading = false;
      });
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

  Future<void> _refreshData() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      // UPDATE: Fetch full details (fridges and seals) to support offline viewing
      final dynamic data = await _supabase
          .from('asset_reports')
          .select('''
          *,
          customer:user_profiles!customer_id(full_name, email),
          fridges:assets_report_fridge(
            *,
            seals:report_asset_items(*)
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
        // This now saves the FULL details of all reports locally
        await _saveReportsLocally(fetchedReports);
      }
    } catch (e) {
      debugPrint("Fetch Error: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- 4. Role & Sync Orchestration ---
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
    setState(() {
      _isSyncing = true;
      _syncMessage = "Checking for updates...";
    });

    await _syncMetadata(); // Sync Customers/Products
    await _refreshData(); // Sync Reports
    await _checkForModelUpdate(); // Sync AI Model

    if (mounted) setState(() => _isSyncing = false);
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


  Future<void> _syncMetadata() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = _supabase.auth.currentUser?.id;

      // 1. Fetch all required tables
      final profiles = await _supabase.from('user_profiles').select().filter('role', 'in', '("engineer","user")');
      final products = await _supabase.from('seal_products').select();
      final fridges = await _supabase.from('fridges').select();

      final fridgeRelations = await _supabase.from('fridge_seals_relation').select('''
      *,
      seal_products:seal_product_id (*,seal_model_number)
    ''');

      // --- NEW: Sync current user's specific profile for the Edit Page ---
      if (userId != null) {
        final myProfile = await _supabase
            .from('user_profiles')
            .select('full_name, phone')
            .eq('id', userId)
            .maybeSingle();

        if (myProfile != null) {
          await prefs.setString('current_user_profile', jsonEncode(myProfile));
        }
      }

      // 2. Save to Local Storage
      await prefs.setString('local_customers', jsonEncode(profiles));
      await prefs.setString('local_products', jsonEncode(products));
      await prefs.setString('local_fridges', jsonEncode(fridges));
      await prefs.setString('local_fridge_relations', jsonEncode(fridgeRelations));

      debugPrint("Metadata and User Profile Synced Locally.");
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isSubmitted ? Colors.green[50] : Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: isSubmitted ? Colors.green[700] : Colors.orange[700], fontWeight: FontWeight.bold, fontSize: 9),
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
}
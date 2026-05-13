// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;
// import 'package:path_provider/path_provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
//
// import '../home_page.dart';
// import '../pages/auth_page.dart';
// import '../pages/engineer/report_list_page.dart';
// import '../services/supabase_service.dart';
//
// class ModelSyncScreen extends StatefulWidget {
//   const ModelSyncScreen({super.key});
//
//   @override
//   _ModelSyncScreenState createState() => _ModelSyncScreenState();
// }
//
// class _ModelSyncScreenState extends State<ModelSyncScreen> {
//   String _status = "Initializing...";
//   double _progress = 0;
//   int? _localVersion;
//   bool _isDownloading = false;
//   final _service = SupabaseService();
//
//   @override
//   void initState() {
//     super.initState();
//     _startSyncProcess();
//   }
//
//   // --- 1. SYNC CUSTOMERS & PRODUCTS ---
//   Future<void> _syncAppData() async {
//     setState(() => _status = "Syncing Customers & Products...");
//     try {
//       final prefs = await SharedPreferences.getInstance();
//
//       // Fetch from Supabase
//       final customers = await _service.fetchCustomers();
//       final products = await _service.fetchSealProducts();
//
//       // Save Locally
//       await prefs.setString('local_customers', jsonEncode(customers));
//       await prefs.setString('local_products', jsonEncode(products));
//       await prefs.setString('last_sync_date', DateTime.now().toIso8601String());
//
//       print("Offline Data Sync Complete");
//     } catch (e) {
//       print("Data Sync Error: $e");
//       // We continue so app works with cached data if network fails here
//     }
//   }
//
//   // --- 2. MAIN SYNC PROCESS ---
//   Future<void> _startSyncProcess() async {
//     print('--- STARTING SYNC PROCESS ---');
//
//
//     final prefs = await SharedPreferences.getInstance();
//
//     String accessToken = prefs.getString('is_user_logged_in') ?? '';
//
//     // Check for session first
//       final session = Supabase.instance.client.auth.currentSession;
//       if (session == null || accessToken.isEmpty) {
//         _navigateToAuth();
//         return;
//       }
//
//     // Run Data Sync first
//     await _syncAppData();
//
//     // Then run AI Model Sync
//     await _loadLocalVersion();
//     await _checkForUpdate();
//   }
//
//   Future<void> _loadLocalVersion() async {
//     final prefs = await SharedPreferences.getInstance();
//     _localVersion = prefs.getInt('current_model_version');
//     setState(() {});
//   }
//
//   Future<void> _checkForUpdate() async {
//     setState(() => _status = "Checking for model updates...");
//
//     try {
//       final response = await Supabase.instance.client
//           .from('model_versions')
//           .select()
//           .eq('is_active', true)
//           .order('version', ascending: false)
//           .limit(1)
//           .maybeSingle();
//
//       if (response == null) {
//         _handleRedirection();
//         return;
//       }
//
//       final int remoteVer = response['version'];
//       final String modelUrl = response['model_url'];
//       final String? labelsUrl = response['labels_url'];
//
//       if (_localVersion != null && _localVersion! >= remoteVer) {
//         setState(() => _status = "Model up to date.");
//         _handleRedirection();
//         return;
//       }
//
//       await _syncAssets(modelUrl, labelsUrl, remoteVer);
//     } catch (e) {
//       print('DB_ERROR: $e');
//       _handleRedirection();
//     }
//   }
//
//   // --- 3. DOWNLOAD ASSETS ---
//   Future<void> _syncAssets(String modelUrl, String? labelsUrl, int version) async {
//     setState(() {
//       _isDownloading = true;
//       _status = "Downloading AI Model v$version...";
//     });
//
//     try {
//       final directory = await getApplicationDocumentsDirectory();
//
//       final modelPath = "${directory.path}/model_v$version.tflite";
//       await _downloadFile(modelUrl, modelPath, "Model");
//
//       String? labelPath;
//       if (labelsUrl != null && labelsUrl.isNotEmpty) {
//         labelPath = "${directory.path}/labels_v$version.txt";
//         await _downloadFile(labelsUrl, labelPath, "Labels");
//       }
//
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setInt('current_model_version', version);
//       await prefs.setString('current_model_path', modelPath);
//       if (labelPath != null) await prefs.setString('current_labels_path', labelPath);
//
//       setState(() => _status = "Setup Complete!");
//       _handleRedirection();
//     } catch (e) {
//       print('SYNC_ERROR: $e');
//       _handleRedirection();
//     }
//   }
//
//   Future<void> _downloadFile(String url, String savePath, String type) async {
//     final client = http.Client();
//     final request = http.Request('GET', Uri.parse(url));
//     final response = await client.send(request);
//     final contentLength = response.contentLength ?? 0;
//
//     List<int> bytes = [];
//     final file = File(savePath);
//
//     await for (var chunk in response.stream) {
//       bytes.addAll(chunk);
//       if (contentLength > 0 && mounted) {
//         setState(() => _progress = bytes.length / contentLength);
//       }
//     }
//     await file.writeAsBytes(bytes);
//   }
//
//   // --- 4. NAVIGATION LOGIC ---
//   void _handleRedirection() async {
//     final role = await _service.getUserRole();
//     if (!mounted) return;
//
//     Future.delayed(const Duration(milliseconds: 500), () {
//       if (role == 'engineer') {
//         Navigator.of(context).pushReplacement(
//           MaterialPageRoute(builder: (context) => const ReportListPage()),
//         );
//       } else {
//         Navigator.of(context).pushReplacement(
//           MaterialPageRoute(builder: (context) => const HomePage()),
//         );
//       }
//     });
//   }
//
//   void _navigateToAuth() {
//     Navigator.of(context).pushReplacement(
//       MaterialPageRoute(builder: (context) => const AuthPage()),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(40.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Icon(Icons.cloud_sync_rounded, size: 80, color: Colors.blue),
//               const SizedBox(height: 24),
//               const Text("Gasket Guy", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
//               const SizedBox(height: 12),
//               Text(_status, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600])),
//               const SizedBox(height: 32),
//               if (_isDownloading) ...[
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(10),
//                   child: LinearProgressIndicator(value: _progress, minHeight: 10, backgroundColor: Colors.grey[200]),
//                 ),
//                 const SizedBox(height: 8),
//                 Text("${(_progress * 100).toStringAsFixed(0)}%"),
//               ] else
//                 const CircularProgressIndicator(strokeWidth: 3),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:mobile/components/main_navigation_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../home_page.dart';
import '../pages/auth_page.dart';
import '../pages/engineer/report_list_page.dart';
import '../services/supabase_service.dart';

class ModelSyncScreen extends StatefulWidget {
  const ModelSyncScreen({super.key});

  @override
  State<ModelSyncScreen> createState() => _ModelSyncScreenState();
}

class _ModelSyncScreenState extends State<ModelSyncScreen> {
  final SupabaseService _service = SupabaseService();
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    // Start session check and redirection
    _checkSessionAndRedirect();
  }

  Future<void> _checkSessionAndRedirect() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String accessToken = prefs.getString('is_user_logged_in') ?? '';
    final Session? session = _supabase.auth.currentSession;

    // Check if session exists
    if (session == null || accessToken.isEmpty) {
      _navigateToAuth();
      return;
    }

    // Determine user role for redirection
    final role = await _service.getUserRole();
    if (!mounted) return;

    if(!(role != null && role.isNotEmpty)){
      _navigateToAuth();
    }

    if (role == 'engineer') {
      Navigator.of(context).pushReplacement(
        // MaterialPageRoute(builder: (BuildContext context) => const ReportListPage()),
        MaterialPageRoute(builder: (BuildContext context) => const MainNavigationPage()),

      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (BuildContext context) => const HomePage()),
      );
    }
  }

  void _navigateToAuth() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (BuildContext context) => const AuthPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.cloud_sync_rounded, size: 80, color: Colors.blue),
            SizedBox(height: 24),
            Text("Gasket Guy", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Text("Loading session...", style: TextStyle(color: Colors.grey)),
            SizedBox(height: 24),
            CircularProgressIndicator(strokeWidth: 3),
          ],
        ),
      ),
    );
  }
}


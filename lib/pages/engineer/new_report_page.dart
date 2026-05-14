// // // // import 'dart:io';
// // // // import 'package:flutter/material.dart';
// // // // import 'package:image_picker/image_picker.dart';
// // // // import 'package:connectivity_plus/connectivity_plus.dart';
// // // // import 'package:supabase_flutter/supabase_flutter.dart';
// // // // import '../../theme.dart';
// // // // import '../../services/supabase_service.dart';
// // // //
// // // // // Simple model to hold asset data before submission
// // // // class LocalAssetEntry {
// // // //   File? dataPlateImage;
// // // //   File? sealImage;
// // // //   String? manufacturer;
// // // //   String? modelNo;
// // // //   String? serialNo;
// // // //   String? location;
// // // //   int noOfDoors = 1;
// // // //   String? sealId; // Result from your ML
// // // //   String? condition = 'OK';
// // // //   double? height;
// // // //   double? width;
// // // //   String area = '';
// // // //
// // // //   // Seal Info
// // // //   String? manualSealName;
// // // //   bool isUnknownSeal = true;
// // // //   String variantDetails = ''; // color, thickness, etc.
// // // //
// // // //   // Counters
// // // //   int doorCount = 0;
// // // //   int drawerCount = 0;
// // // //
// // // //   LocalAssetEntry();
// // // // }
// // // //
// // // //
// // // // class NewReportPage extends StatefulWidget {
// // // //   const NewReportPage({super.key});
// // // //
// // // //   @override
// // // //   State<NewReportPage> createState() => _NewReportPageState();
// // // // }
// // // //
// // // //
// // // //
// // // // class _NewReportPageState extends State<NewReportPage> {
// // // //   final _supabase = Supabase.instance.client;
// // // //   final _authService = SupabaseService();
// // // //
// // // //   String? _selectedCustomerId;
// // // //   List<Map<String, dynamic>> _customers = [];
// // // //   List<LocalAssetEntry> _assets = [];
// // // //   bool _isLoading = true;
// // // //   bool _isSubmitting = false;
// // // //
// // // //   @override
// // // //   void initState() {
// // // //     super.initState();
// // // //     _loadInitialData();
// // // //   }
// // // //
// // // //   Future<void> _loadInitialData() async {
// // // //     try {
// // // //       final data = await _authService.fetchCustomers();
// // // //       setState(() {
// // // //         _customers = data;
// // // //         _isLoading = false;
// // // //       });
// // // //     } catch (e) {
// // // //       debugPrint("Error loading customers: $e");
// // // //       setState(() => _isLoading = false);
// // // //     }
// // // //   }
// // // //
// // // //   void _addNewAsset() {
// // // //     setState(() {
// // // //       _assets.add(LocalAssetEntry());
// // // //     });
// // // //   }
// // // //
// // // //   Future<void> _pickImage(int index, bool isDataPlate) async {
// // // //     final picker = ImagePicker();
// // // //     final pickedFile = await picker.pickImage(source: ImageSource.camera);
// // // //
// // // //     if (pickedFile != null) {
// // // //       setState(() {
// // // //         if (isDataPlate) {
// // // //           _assets[index].dataPlateImage = File(pickedFile.path);
// // // //         } else {
// // // //           _assets[index].sealImage = File(pickedFile.path);
// // // //           // Here you would trigger your existing ML Analysis Logic
// // // //           // _assets[index].sealId = await runMLInference(File(pickedFile.path));
// // // //         }
// // // //       });
// // // //     }
// // // //   }
// // // //
// // // //   Future<void> _handleSubmitReport() async {
// // // //     if (_selectedCustomerId == null || _assets.isEmpty) {
// // // //       ScaffoldMessenger.of(context).showSnackBar(
// // // //         const SnackBar(content: Text("Please select a customer and add at least one asset.")),
// // // //       );
// // // //       return;
// // // //     }
// // // //
// // // //     // 1. Check Internet Connection
// // // //     var connectivityResult = await (Connectivity().checkConnectivity());
// // // //     if (connectivityResult == ConnectivityResult.none) {
// // // //       _showNoInternetDialog();
// // // //       return;
// // // //     }
// // // //
// // // //     setState(() => _isSubmitting = true);
// // // //
// // // //     try {
// // // //       // 2. Create the Report Header
// // // //       final reportResponse = await _supabase.from('asset_reports').insert({
// // // //         'customer_id': _selectedCustomerId,
// // // //         'engineer_id': _supabase.auth.currentUser!.id,
// // // //         'status': 'submitted',
// // // //       }).select().single();
// // // //
// // // //       final reportId = reportResponse['id'];
// // // //
// // // //       // 3. Upload Assets (Simplified loop)
// // // //       for (var asset in _assets) {
// // // //         // Note: In production, upload images to Supabase Storage first to get URLs
// // // //         await _supabase.from('report_assets').insert({
// // // //           'report_id': reportId,
// // // //           'manufacturer': asset.manufacturer,
// // // //           'model_no': asset.modelNo,
// // // //           'serial_no': asset.serialNo,
// // // //           'location': asset.location,
// // // //           'no_of_doors': asset.noOfDoors,
// // // //           'condition': asset.condition,
// // // //           'manual_height': asset.height,
// // // //           'manual_width': asset.width,
// // // //         });
// // // //       }
// // // //
// // // //       if (mounted) {
// // // //         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Report Submitted Successfully!")));
// // // //         Navigator.pop(context);
// // // //       }
// // // //     } catch (e) {
// // // //       debugPrint("Submit Error: $e");
// // // //     } finally {
// // // //       if (mounted) setState(() => _isSubmitting = false);
// // // //     }
// // // //   }
// // // //
// // // //   void _showNoInternetDialog() {
// // // //     showDialog(
// // // //       context: context,
// // // //       builder: (context) => AlertDialog(
// // // //         title: const Text("Offline"),
// // // //         content: const Text("Internet connection required to submit to the office. Data is saved locally."),
// // // //         actions: [
// // // //           TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK")),
// // // //         ],
// // // //       ),
// // // //     );
// // // //   }
// // // //
// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return Scaffold(
// // // //       appBar: AppBar(title: const Text("New Asset Report")),
// // // //       body: _isLoading
// // // //           ? const Center(child: CircularProgressIndicator())
// // // //           : Column(
// // // //         children: [
// // // //           // Customer Selection Header
// // // //           Padding(
// // // //             padding: const EdgeInsets.all(16.0),
// // // //             child: DropdownButtonFormField<String>(
// // // //               decoration: const InputDecoration(labelText: "Select Customer"),
// // // //               value: _selectedCustomerId,
// // // //               items: _customers.map((c) => DropdownMenuItem(
// // // //                 value: c['id'].toString(),
// // // //                 child: Text(c['full_name'] ?? "Unknown"),
// // // //               )).toList(),
// // // //               onChanged: (val) => setState(() => _selectedCustomerId = val),
// // // //             ),
// // // //           ),
// // // //
// // // //           Expanded(
// // // //             child: ListView.builder(
// // // //               padding: const EdgeInsets.symmetric(horizontal: 16),
// // // //               itemCount: _assets.length,
// // // //               itemBuilder: (context, index) => _buildAssetCard(index),
// // // //             ),
// // // //           ),
// // // //
// // // //           Padding(
// // // //             padding: const EdgeInsets.all(16.0),
// // // //             child: Row(
// // // //               children: [
// // // //                 Expanded(
// // // //                   child: OutlinedButton.icon(
// // // //                     onPressed: _addNewAsset,
// // // //                     icon: const Icon(Icons.add),
// // // //                     label: const Text("ADD FRIDGE"),
// // // //                   ),
// // // //                 ),
// // // //                 const SizedBox(width: 12),
// // // //                 Expanded(
// // // //                   child: ElevatedButton(
// // // //                     onPressed: _isSubmitting ? null : _handleSubmitReport,
// // // //                     child: _isSubmitting
// // // //                         ? const CircularProgressIndicator(color: Colors.white)
// // // //                         : const Text("SUBMIT REPORT"),
// // // //                   ),
// // // //                 ),
// // // //               ],
// // // //             ),
// // // //           )
// // // //         ],
// // // //       ),
// // // //     );
// // // //   }
// // // //
// // // //   Widget _buildAssetCard(int index) {
// // // //     final asset = _assets[index];
// // // //     return Card(
// // // //       margin: const EdgeInsets.only(bottom: 16),
// // // //       child: Padding(
// // // //         padding: const EdgeInsets.all(12),
// // // //         child: Column(
// // // //           children: [
// // // //             Row(
// // // //               children: [
// // // //                 CircleAvatar(backgroundColor: AppTheme.primary, child: Text("${index + 1}", style: const TextStyle(color: Colors.white))),
// // // //                 const SizedBox(width: 10),
// // // //                 const Text("Fridge Asset Details", style: TextStyle(fontWeight: FontWeight.bold)),
// // // //                 const Spacer(),
// // // //                 IconButton(onPressed: () => setState(() => _assets.removeAt(index)), icon: const Icon(Icons.delete, color: Colors.red)),
// // // //               ],
// // // //             ),
// // // //             const Divider(),
// // // //
// // // //             // Photo Buttons
// // // //             Row(
// // // //               children: [
// // // //                 Expanded(
// // // //                   child: _photoButton(
// // // //                       label: "Data Plate",
// // // //                       file: asset.dataPlateImage,
// // // //                       onTap: () => _pickImage(index, true)
// // // //                   ),
// // // //                 ),
// // // //                 const SizedBox(width: 8),
// // // //                 Expanded(
// // // //                   child: _photoButton(
// // // //                       label: "Scan Seal",
// // // //                       file: asset.sealImage,
// // // //                       onTap: () => _pickImage(index, false)
// // // //                   ),
// // // //                 ),
// // // //               ],
// // // //             ),
// // // //             const SizedBox(height: 12),
// // // //
// // // //             TextField(
// // // //               decoration: const InputDecoration(labelText: "Manufacturer / Model No"),
// // // //               onChanged: (val) => asset.manufacturer = val,
// // // //             ),
// // // //             const SizedBox(height: 8),
// // // //             TextField(
// // // //               decoration: const InputDecoration(labelText: "Location (e.g. Main Kitchen)"),
// // // //               onChanged: (val) => asset.location = val,
// // // //             ),
// // // //             const SizedBox(height: 8),
// // // //             DropdownButtonFormField<String>(
// // // //               value: asset.condition,
// // // //               decoration: const InputDecoration(labelText: "Condition"),
// // // //               items: ["OK", "Partially Worn", "Needs Replacing"]
// // // //                   .map((e) => DropdownMenuItem(value: e, child: Text(e)))
// // // //                   .toList(),
// // // //               onChanged: (val) => asset.condition = val,
// // // //             ),
// // // //           ],
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }
// // // //
// // // //   Widget _photoButton({required String label, required File? file, required VoidCallback onTap}) {
// // // //     return InkWell(
// // // //       onTap: onTap,
// // // //       child: Container(
// // // //         height: 100,
// // // //         decoration: BoxDecoration(
// // // //           border: Border.all(color: AppTheme.alternate),
// // // //           borderRadius: BorderRadius.circular(8),
// // // //           image: file != null ? DecorationImage(image: FileImage(file), fit: BoxFit.cover) : null,
// // // //         ),
// // // //         child: file == null
// // // //             ? Column(
// // // //           mainAxisAlignment: MainAxisAlignment.center,
// // // //           children: [
// // // //             const Icon(Icons.camera_alt, color: AppTheme.primary),
// // // //             Text(label, style: const TextStyle(fontSize: 12)),
// // // //           ],
// // // //         )
// // // //             : null,
// // // //       ),
// // // //     );
// // // //   }
// // // // }
// // //
// // //
// // //
// // // import 'dart:convert';
// // // import 'dart:io';
// // // import 'package:flutter/material.dart';
// // // import 'package:connectivity_plus/connectivity_plus.dart';
// // // import 'package:shared_preferences/shared_preferences.dart';
// // // import 'package:supabase_flutter/supabase_flutter.dart';
// // // import '../../theme.dart';
// // // import '../../services/supabase_service.dart';
// // // import 'add_asset_page.dart'; // Ensure this matches your file path
// // //
// // // // The shared model for fridge assets
// // // class LocalAssetEntry {
// // //   String area = '';
// // //   File? dataPlateImage;
// // //   File? sealImage;
// // //   String? manufacturer;
// // //   String? modelNo;
// // //   String? serialNo;
// // //
// // //   // Seal Info
// // //   String? sealId;
// // //   String? manualSealName;
// // //   bool isUnknownSeal = true;
// // //   String variantDetails = '';
// // //
// // //   // Counters
// // //   int doorCount = 0;
// // //   int drawerCount = 0;
// // //
// // //   String condition = 'OK';
// // //   List<File> allSealImages = [];
// // //   double confidence = 0.0;
// // //
// // //
// // //   // Detailed Variants (Based on your SQL)
// // //   bool isMagnetic = false;
// // //   String? sealType;
// // //   String? material;
// // //   String? hardness;
// // //   double innerDiameter = 0;
// // //   double outerDiameter = 0;
// // //   double thickness = 0;
// // //   String? tempRange;
// // //   String? brand;
// // //   String? application;
// // //   String? description;
// // //   String? sealModelNumber;
// // //
// // //
// // //
// // //   LocalAssetEntry();
// // // }
// // //
// // // class NewReportPage extends StatefulWidget {
// // //   const NewReportPage({super.key});
// // //
// // //   @override
// // //   State<NewReportPage> createState() => _NewReportPageState();
// // // }
// // //
// // // class _NewReportPageState extends State<NewReportPage> {
// // //   final _supabase = Supabase.instance.client;
// // //   final _authService = SupabaseService();
// // //
// // //
// // //   String? _selectedCustomerId;
// // //   List<Map<String, dynamic>> _customers = [];
// // //   List<LocalAssetEntry> _assets = [];
// // //   bool _isLoading = true;
// // //   bool _isSubmitting = false;
// // //
// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     _loadInitialData();
// // //     _loadLocalData();
// // //   }
// // //
// // //   Future<void> _loadInitialData() async {
// // //     try {
// // //       // Fetching all users where role = 'user'
// // //       final data = await _authService.fetchCustomers();
// // //       setState(() {
// // //         _customers = data;
// // //         _isLoading = false;
// // //       });
// // //     } catch (e) {
// // //       debugPrint("Error loading customers: $e");
// // //       setState(() => _isLoading = false);
// // //     }
// // //   }
// // //
// // //   // Example: Loading customers in NewReportPage
// // //   Future<void> _loadLocalData() async {
// // //     final prefs = await SharedPreferences.getInstance();
// // //     final String? customerJson = prefs.getString('local_customers');
// // //
// // //     if (customerJson != null) {
// // //       setState(() {
// // //         _customers = List<Map<String, dynamic>>.from(jsonDecode(customerJson));
// // //       });
// // //     }
// // //   }
// // //
// // // // Example: Using Seal Products for the manual dropdown in AddAssetPage
// // //   Future<List<Map<String, dynamic>>> getLocalProducts() async {
// // //     final prefs = await SharedPreferences.getInstance();
// // //     final String? productJson = prefs.getString('local_products');
// // //
// // //     if (productJson != null) {
// // //       return List<Map<String, dynamic>>.from(jsonDecode(productJson));
// // //     }
// // //     return [];
// // //   }
// // //
// // //   // Jumps to the detailed entry page
// // //   void _openAddAssetPage() {
// // //     Navigator.push(
// // //       context,
// // //       MaterialPageRoute(
// // //         builder: (context) => AddAssetPage(
// // //           onSave: (newAsset) {
// // //             setState(() {
// // //               _assets.add(newAsset);
// // //             });
// // //           },
// // //         ),
// // //       ),
// // //     );
// // //   }
// // //
// // //   // Future<void> _handleSubmitReport() async {
// // //   //   if (_selectedCustomerId == null || _assets.isEmpty) {
// // //   //     ScaffoldMessenger.of(context).showSnackBar(
// // //   //       const SnackBar(content: Text("Select a customer and add at least one fridge.")),
// // //   //     );
// // //   //     return;
// // //   //   }
// // //   //
// // //   //   final List<ConnectivityResult> connectivityResult = await (Connectivity().checkConnectivity());
// // //   //   if (connectivityResult.contains(ConnectivityResult.none)) {
// // //   //     _showNoInternetDialog();
// // //   //     return;
// // //   //   }
// // //   //
// // //   //   setState(() => _isSubmitting = true);
// // //   //
// // //   //   try {
// // //   //     // 1. Insert Report Header
// // //   //     final reportResponse = await _supabase.from('asset_reports').insert({
// // //   //       'customer_id': _selectedCustomerId,
// // //   //       'engineer_id': _supabase.auth.currentUser!.id,
// // //   //       'status': 'submitted',
// // //   //     }).select().single();
// // //   //
// // //   //     final reportId = reportResponse['id'];
// // //   //
// // //   //     // 2. Loop through and insert each asset locally saved in the list
// // //   //     for (var asset in _assets) {
// // //   //       await _supabase.from('report_assets').insert({
// // //   //         'report_id': reportId,
// // //   //         'location': asset.area,
// // //   //         'model_no': asset.modelNo,
// // //   //         'no_of_doors': asset.doorCount,
// // //   //         'no_of_drawers': asset.drawerCount,
// // //   //         'condition': asset.condition,
// // //   //         'manual_profile': asset.isUnknownSeal ? "ML Pending" : asset.manualSealName,
// // //   //         'is_offline_sync': true,
// // //   //       });
// // //   //     }
// // //   //
// // //   //     if (mounted) {
// // //   //       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Full Report Submitted!")));
// // //   //       Navigator.pop(context);
// // //   //     }
// // //   //   } catch (e) {
// // //   //     debugPrint("Submit Error: $e");
// // //   //   } finally {
// // //   //     if (mounted) setState(() => _isSubmitting = false);
// // //   //   }
// // //   // }
// // //
// // //   Future<void> _handleSubmitReport() async {
// // //     // 1. Validation
// // //     if (_selectedCustomerId == null || _assets.isEmpty) {
// // //       ScaffoldMessenger.of(context).showSnackBar(
// // //         const SnackBar(content: Text("Please select a customer and add at least one fridge.")),
// // //       );
// // //       return;
// // //     }
// // //
// // //     // 2. Internet Connectivity Check
// // //     final List<ConnectivityResult> connectivityResult = await (Connectivity().checkConnectivity());
// // //     if (connectivityResult.contains(ConnectivityResult.none)) {
// // //       _showNoInternetDialog();
// // //       return;
// // //     }
// // //
// // //     setState(() => _isSubmitting = true);
// // //
// // //     try {
// // //       // 3. Create the Report Header (Parent)
// // //       // We get the ID back to link our assets
// // //       final reportHeader = await _supabase.from('asset_reports').insert({
// // //         'customer_id': _selectedCustomerId,
// // //         'engineer_id': _supabase.auth.currentUser!.id,
// // //         'status': 'submitted',
// // //       }).select().single();
// // //
// // //       final String reportId = reportHeader['id'];
// // //
// // //       // 4. Prepare and Upload Assets (Children)
// // //       // We iterate through our local list and map them to the DB columns
// // //       for (var asset in _assets) {
// // //
// // //         // OPTIONAL: Upload Data Plate Image to Supabase Storage first
// // //         String? dataPlateUrl;
// // //         if (asset.dataPlateImage != null) {
// // //           final fileName = 'plate_${DateTime.now().millisecondsSinceEpoch}.jpg';
// // //           final path = 'reports/$reportId/$fileName';
// // //
// // //           await _supabase.storage.from('images').upload(path, asset.dataPlateImage!);
// // //           dataPlateUrl = _supabase.storage.from('images').getPublicUrl(path);
// // //         }
// // //
// // //         // Insert into assets_report_fridge using the Seal ID (Normalized)
// // //         await _supabase.from('assets_report_fridge').insert({
// // //           'report_id': reportId,
// // //           'area': asset.area,
// // //           'data_plate_url': dataPlateUrl,
// // //           'manufacturer': asset.brand, // Mapping brand to manufacturer
// // //           'model_no': asset.sealModelNumber,
// // //           'door_count': asset.doorCount,
// // //           'drawer_count': asset.drawerCount,
// // //           'condition': asset.condition,
// // //           'seal_id': asset.sealId, // The Foreign Key link
// // //           'is_unknown_seal': asset.isUnknownSeal,
// // //           'confidence_score': asset.confidence,
// // //           'engineer_notes': asset.description,
// // //         });
// // //       }
// // //
// // //       if (mounted) {
// // //         ScaffoldMessenger.of(context).showSnackBar(
// // //           const SnackBar(content: Text("Report & Assets Synced Successfully!")),
// // //         );
// // //         Navigator.pop(context); // Return to list
// // //       }
// // //     } catch (e) {
// // //       debugPrint("Submit Error: $e");
// // //       if (mounted) {
// // //         ScaffoldMessenger.of(context).showSnackBar(
// // //           SnackBar(content: Text("Submission Failed: ${e.toString()}")),
// // //         );
// // //       }
// // //     } finally {
// // //       if (mounted) setState(() => _isSubmitting = false);
// // //     }
// // //   }
// // //
// // // // Helper Dialog for Offline State
// // //   void _showNoInternetDialog() {
// // //     showDialog(
// // //       context: context,
// // //       builder: (context) => AlertDialog(
// // //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
// // //         title: const Row(
// // //           children: [
// // //             Icon(Icons.wifi_off_rounded, color: Colors.red),
// // //             SizedBox(width: 10),
// // //             Text("Offline"),
// // //           ],
// // //         ),
// // //         content: const Text("You need an active internet connection to submit this report to the office database."),
// // //         actions: [
// // //           TextButton(
// // //             onPressed: () => Navigator.pop(context),
// // //             child: const Text("OK", style: TextStyle(fontWeight: FontWeight.bold)),
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //   }
// // //
// // //   // void _showNoInternetDialog() {
// // //   //   showDialog(
// // //   //     context: context,
// // //   //     builder: (context) => AlertDialog(
// // //   //       title: const Text("No Connection"),
// // //   //       content: const Text("Internet is required to sync this report to the admin panel. Please connect and try again."),
// // //   //       actions: [
// // //   //         TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK")),
// // //   //       ],
// // //   //     ),
// // //   //   );
// // //   // }
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       backgroundColor: AppTheme.primaryBackground,
// // //       appBar: AppBar(title: const Text("New Asset Report")),
// // //       body: _isLoading
// // //           ? const Center(child: CircularProgressIndicator())
// // //           : Column(
// // //         crossAxisAlignment: CrossAxisAlignment.start,
// // //         children: [
// // //           // Customer Selector
// // //           // Container(
// // //           //   padding: const EdgeInsets.all(16.0),
// // //           //   color: Colors.white,
// // //           //   child: DropdownButtonFormField<String>(
// // //           //     decoration: const InputDecoration(
// // //           //       labelText: "Select Customer",
// // //           //       border: OutlineInputBorder(),
// // //           //     ),
// // //           //     value: _selectedCustomerId,
// // //           //     items: _customers.map((c) => DropdownMenuItem(
// // //           //       value: c['id'].toString(),
// // //           //       child: Text(c['full_name'] ?? "Unnamed Client"),
// // //           //     )).toList(),
// // //           //     onChanged: (val) => setState(() => _selectedCustomerId = val),
// // //           //   ),
// // //           // ),
// // //           Padding(
// // //             padding: const EdgeInsets.symmetric(vertical: 6,horizontal: 20),
// // //             child: Text(
// // //               "Select Customer",
// // //               style: TextStyle(
// // //                 fontSize: 11,
// // //                 fontWeight: FontWeight.w600,
// // //                 color:
// // //                 AppTheme.primary.withOpacity(0.7),
// // //               ),
// // //             ),
// // //           ),
// // //           CustomCustomerDropdown(
// // //             customers: _customers,
// // //             selectedCustomerId: _selectedCustomerId,
// // //             onChanged: (id) {
// // //               setState(() {
// // //                 _selectedCustomerId = id;
// // //               });
// // //             },
// // //           ),
// // //           const Padding(
// // //             padding: EdgeInsets.all(16.0),
// // //             child: Align(
// // //               alignment: Alignment.centerLeft,
// // //               child: Text("ADDED ASSETS", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
// // //             ),
// // //           ),
// // //
// // //           Expanded(
// // //             child: _assets.isEmpty
// // //                 ? _buildEmptyState()
// // //                 : ListView.builder(
// // //               padding: const EdgeInsets.symmetric(horizontal: 16),
// // //               itemCount: _assets.length,
// // //               itemBuilder: (context, index) => _buildSummaryCard(index),
// // //             ),
// // //           ),
// // //
// // //           _buildBottomActions(),
// // //         ],
// // //       ),
// // //     );
// // //   }
// // //
// // //   Widget _buildEmptyState() {
// // //     return Center(
// // //       child: Column(
// // //         mainAxisAlignment: MainAxisAlignment.center,
// // //         children: [
// // //           Icon(Icons.kitchen_outlined, size: 64, color: Colors.grey[300]),
// // //           const SizedBox(height: 10),
// // //           const Text("No fridge data added yet", style: TextStyle(color: Colors.grey)),
// // //         ],
// // //       ),
// // //     );
// // //   }
// // //
// // //   Widget _buildSummaryCard(int index) {
// // //     final asset = _assets[index];
// // //     return Card(
// // //       elevation: 0,
// // //       shape: RoundedRectangleBorder(
// // //         borderRadius: BorderRadius.circular(12),
// // //         side: BorderSide(color: Colors.grey[200]!),
// // //       ),
// // //       margin: const EdgeInsets.only(bottom: 12),
// // //       child: ListTile(
// // //         contentPadding: const EdgeInsets.all(12),
// // //         leading: Container(
// // //           width: 50,
// // //           height: 50,
// // //           decoration: BoxDecoration(
// // //             color: AppTheme.primary.withOpacity(0.1),
// // //             borderRadius: BorderRadius.circular(8),
// // //           ),
// // //           child: const Icon(Icons.kitchen, color: AppTheme.primary),
// // //         ),
// // //         title: Text(asset.area.isEmpty ? "Unit ${index + 1}" : asset.area,
// // //             style: const TextStyle(fontWeight: FontWeight.bold)),
// // //         subtitle: Column(
// // //           crossAxisAlignment: CrossAxisAlignment.start,
// // //           children: [
// // //             Text("Doors: ${asset.doorCount} | Drawers: ${asset.drawerCount}"),
// // //             Text("Seal: ${asset.isUnknownSeal ? 'Detected' : asset.manualSealName}",
// // //                 style: const TextStyle(fontSize: 12, color: AppTheme.primary)),
// // //           ],
// // //         ),
// // //         trailing: IconButton(
// // //           icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
// // //           onPressed: () => setState(() => _assets.removeAt(index)),
// // //         ),
// // //       ),
// // //     );
// // //   }
// // //
// // //   Widget _buildBottomActions() {
// // //     return Container(
// // //       padding: const EdgeInsets.all(20),
// // //       decoration: BoxDecoration(
// // //         color: Colors.white,
// // //         boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
// // //       ),
// // //       child: Column(
// // //         children: [
// // //           SizedBox(
// // //             width: double.infinity,
// // //             child: OutlinedButton.icon(
// // //               onPressed: _openAddAssetPage,
// // //               icon: const Icon(Icons.add_a_photo_outlined),
// // //               label: const Text("ADD New Asset"),
// // //               style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)),
// // //             ),
// // //           ),
// // //           const SizedBox(height: 12),
// // //           SizedBox(
// // //             width: double.infinity,
// // //             child: ElevatedButton(
// // //               onPressed: _isSubmitting ? null : _handleSubmitReport,
// // //               style: ElevatedButton.styleFrom(
// // //                 backgroundColor: AppTheme.primary,
// // //                 padding: const EdgeInsets.symmetric(vertical: 15),
// // //               ),
// // //               child: _isSubmitting
// // //                   ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
// // //                   : const Text("SUBMIT FINAL REPORT", style: TextStyle(fontWeight: FontWeight.bold)),
// // //             ),
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //   }
// // // }
// // //
// // //
// // // class CustomCustomerDropdown extends StatefulWidget {
// // //   final List customers;
// // //   final String? selectedCustomerId;
// // //   final Function(String id) onChanged;
// // //
// // //   const CustomCustomerDropdown({
// // //     super.key,
// // //     required this.customers,
// // //     required this.selectedCustomerId,
// // //     required this.onChanged,
// // //   });
// // //
// // //   @override
// // //   State<CustomCustomerDropdown> createState() =>
// // //       _CustomCustomerDropdownState();
// // // }
// // //
// // // class _CustomCustomerDropdownState extends State<CustomCustomerDropdown> {
// // //   final LayerLink _layerLink = LayerLink();
// // //
// // //   OverlayEntry? _overlayEntry;
// // //   bool isOpen = false;
// // //   Map<String, dynamic>? get selectedCustomer {
// // //     if (widget.customers.isNotEmpty &&
// // //         widget.selectedCustomerId != null) {
// // //       final matches = widget.customers.where(
// // //             (e) => e['id'].toString() == widget.selectedCustomerId,
// // //       );
// // //
// // //       if (matches.isNotEmpty) {
// // //         return matches.first;
// // //       }
// // //     }
// // //
// // //     return null;
// // //   }
// // //   void toggleDropdown() {
// // //     if (!mounted) return;
// // //
// // //     if (isOpen) {
// // //       closeDropdown();
// // //     } else {
// // //       openDropdown();
// // //     }
// // //   }
// // //
// // //   void openDropdown() {
// // //     _overlayEntry = _createOverlayEntry();
// // //     Overlay.of(context).insert(_overlayEntry!);
// // //
// // //     setState(() {
// // //       isOpen = true;
// // //     });
// // //   }
// // //
// // //   void closeDropdown({bool updateState = true}) {
// // //     _overlayEntry?.remove();
// // //     _overlayEntry = null;
// // //
// // //     if (mounted && updateState) {
// // //       setState(() {
// // //         isOpen = false;
// // //       });
// // //     }
// // //   }
// // //
// // //   OverlayEntry _createOverlayEntry() {
// // //     RenderBox renderBox = context.findRenderObject() as RenderBox;
// // //
// // //     var size = renderBox.size;
// // //
// // //     return OverlayEntry(
// // //       builder: (context) => Positioned(
// // //         width: size.width-20,
// // //         child: CompositedTransformFollower(
// // //           link: _layerLink,
// // //           offset: const Offset(0, 70),
// // //           showWhenUnlinked: false,
// // //           child: Material(
// // //             color: Colors.transparent,
// // //             child: Container(
// // //               constraints: const BoxConstraints(maxHeight: 250),
// // //               decoration: BoxDecoration(
// // //                 color: Colors.white,
// // //                 borderRadius: BorderRadius.circular(18),
// // //                 boxShadow: [
// // //                   BoxShadow(
// // //                     color: Colors.black.withOpacity(0.08),
// // //                     blurRadius: 15,
// // //                     offset: const Offset(0, 6),
// // //                   ),
// // //                 ],
// // //               ),
// // //               child: widget.customers.isEmpty
// // //                   ? Padding(
// // //                 padding: const EdgeInsets.all(16),
// // //                 child: Text(
// // //                   widget.customers.isEmpty
// // //                       ? "No customers available"
// // //                       : selectedCustomer == null
// // //                       ? "Choose customer"
// // //                       : selectedCustomer?['full_name'] ?? "Unnamed Client",
// // //                   style: const TextStyle(
// // //                     fontSize: 14,
// // //                     fontWeight: FontWeight.w600,
// // //                     color: AppTheme.primaryText,
// // //                   ),
// // //                   overflow: TextOverflow.ellipsis,
// // //                 ),
// // //               )
// // //                   : ListView.builder(
// // //                 padding: const EdgeInsets.symmetric(vertical: 8),
// // //                 shrinkWrap: true,
// // //                 itemCount: widget.customers.length,
// // //                 itemBuilder: (context, index) {
// // //                   final customer = widget.customers[index];
// // //
// // //                   final bool isSelected =
// // //                       widget.selectedCustomerId ==
// // //                           customer['id'].toString();
// // //
// // //                   return InkWell(
// // //                     onTap: () {
// // //                       widget.onChanged(
// // //                         customer['id'].toString(),
// // //                       );
// // //
// // //                       closeDropdown();
// // //                     },
// // //                     child: Container(
// // //                       margin: const EdgeInsets.symmetric(
// // //                         horizontal: 8,
// // //                         vertical: 4,
// // //                       ),
// // //                       padding: const EdgeInsets.symmetric(
// // //                         horizontal: 16,
// // //                         vertical: 0,
// // //                       ),
// // //                       decoration: BoxDecoration(
// // //                         color: isSelected
// // //                             ? AppTheme.primary.withOpacity(0.08)
// // //                             : Colors.transparent,
// // //                         borderRadius: BorderRadius.circular(12),
// // //                       ),
// // //                       child: Row(
// // //                         children: [
// // //                           CircleAvatar(
// // //                             radius: 18,
// // //                             backgroundColor:
// // //                             AppTheme.primary.withOpacity(0.1),
// // //                             child: const Icon(
// // //                               Icons.person,
// // //                               color: AppTheme.primary,
// // //                               size: 20,
// // //                             ),
// // //                           ),
// // //
// // //                           const SizedBox(width: 12),
// // //
// // //                           Expanded(
// // //                             child: Text(
// // //                               customer['full_name'] ??
// // //                                   "Unnamed Client",
// // //                               style: TextStyle(
// // //                                 fontSize: 14,
// // //                                 fontWeight: isSelected
// // //                                     ? FontWeight.bold
// // //                                     : FontWeight.w500,
// // //                                 color: AppTheme.primaryText,
// // //                               ),
// // //                               overflow: TextOverflow.ellipsis,
// // //                             ),
// // //                           ),
// // //
// // //                           if (isSelected)
// // //                             const Icon(
// // //                               Icons.check_circle,
// // //                               color: AppTheme.primary,
// // //                               size: 20,
// // //                             ),
// // //                         ],
// // //                       ),
// // //                     ),
// // //                   );
// // //                 },
// // //               ),
// // //             ),
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }
// // //
// // //   @override
// // //   void dispose() {
// // //     closeDropdown(updateState: false);
// // //     super.dispose();
// // //   }
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //
// // //     return Center(
// // //       child: SizedBox(
// // //         width: MediaQuery.of(context).size.width-20,
// // //         child: CompositedTransformTarget(
// // //           link: _layerLink,
// // //           child: GestureDetector(
// // //             onTap: widget.customers.isEmpty
// // //                 ? null
// // //                 : toggleDropdown,
// // //             child: Container(
// // //               padding: const EdgeInsets.symmetric(
// // //                 horizontal: 18,
// // //                 vertical: 16,
// // //               ),
// // //               decoration: BoxDecoration(
// // //                 color: Colors.white,
// // //                 borderRadius: BorderRadius.circular(16),
// // //                 border: Border.all(
// // //                   color: isOpen
// // //                       ? AppTheme.primary
// // //                       : AppTheme.primary.withOpacity(0.1),
// // //                   width: isOpen ? 2 : 1.5,
// // //                 ),
// // //                 boxShadow: [
// // //                   BoxShadow(
// // //                     color: Colors.black.withOpacity(0.03),
// // //                     blurRadius: 10,
// // //                     offset: const Offset(0, 4),
// // //                   ),
// // //                 ],
// // //               ),
// // //               child: Row(
// // //                 children: [
// // //                   Icon(
// // //                     Icons.person_pin_rounded,
// // //                     color: widget.customers.isEmpty
// // //                         ? Colors.grey
// // //                         : AppTheme.primary,
// // //                   ),
// // //
// // //                   const SizedBox(width: 14),
// // //
// // //                   Expanded(
// // //                     child: Column(
// // //                       crossAxisAlignment: CrossAxisAlignment.start,
// // //                       children: [
// // //
// // //
// // //                     Text(
// // //                     widget.customers.isEmpty
// // //                     ? "No customers found"
// // //                         : selectedCustomer == null
// // //                     ? "Choose customer"
// // //                           : selectedCustomer?['full_name'] ??
// // //                       "Unnamed Client",)                      ],
// // //                     ),
// // //                   ),
// // //
// // //                   AnimatedRotation(
// // //                     turns: isOpen ? 0.5 : 0,
// // //                     duration: const Duration(milliseconds: 250),
// // //                     child: Icon(
// // //                       Icons.keyboard_arrow_down_rounded,
// // //                       color: widget.customers.isEmpty
// // //                           ? Colors.grey.shade100
// // //                           :  AppTheme.primary,
// // //                     ),
// // //                   ),
// // //                 ],
// // //               ),
// // //             ),
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// // import 'dart:convert';
// // import 'dart:io';
// // import 'package:flutter/material.dart';
// // import 'package:connectivity_plus/connectivity_plus.dart';
// // import 'package:intl/intl.dart'; // REQUIRED: For Date Formatting
// // import 'package:shared_preferences/shared_preferences.dart';
// // import 'package:supabase_flutter/supabase_flutter.dart';
// // import '../../theme.dart';
// // import '../../services/supabase_service.dart';
// // import 'add_asset_page.dart';
// //
// // // The shared model for fridge assets
// // class LocalAssetEntry {
// //   String area = '';
// //   File? dataPlateImage;
// //   File? sealImage;
// //   String? manufacturer;
// //   String? modelNo;
// //   String? serialNo;
// //
// //   // Client Feedback: Toggle for common seals
// //   bool sealsAreCommon = true;
// //
// //   // Seal Info
// //   String? sealId;
// //   String? manualSealName;
// //   bool isUnknownSeal = true;
// //   String variantDetails = '';
// //
// //   // Counters
// //   int doorCount = 0;
// //   int drawerCount = 0;
// //
// //   String condition = 'OK';
// //   List<File> allSealImages = [];
// //   double confidence = 0.0;
// //
// //   // Detailed Variants
// //   bool isMagnetic = false;
// //   String? sealType;
// //   String? material;
// //   String? hardness;
// //   double innerDiameter = 0;
// //   double outerDiameter = 0;
// //   double thickness = 0;
// //   String? tempRange;
// //   String? brand;
// //   String? application;
// //   String? description;
// //   String? sealModelNumber;
// //
// //   LocalAssetEntry();
// // }
// //
// // class NewReportPage extends StatefulWidget {
// //   const NewReportPage({super.key});
// //
// //   @override
// //   State<NewReportPage> createState() => _NewReportPageState();
// // }
// //
// // class _NewReportPageState extends State<NewReportPage> {
// //   final _supabase = Supabase.instance.client;
// //   final _authService = SupabaseService();
// //
// //   // Client Feedback: Controllers for Title and Notes
// //   final TextEditingController _titleController = TextEditingController();
// //   final TextEditingController _reportNotesController = TextEditingController();
// //
// //   String? _selectedCustomerId;
// //   List<Map<String, dynamic>> _customers = [];
// //   List<LocalAssetEntry> _assets = [];
// //   bool _isLoading = true;
// //   bool _isSubmitting = false;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _loadInitialData();
// //     _loadLocalData();
// //   }
// //
// //   @override
// //   void dispose() {
// //     _titleController.dispose();
// //     _reportNotesController.dispose();
// //     super.dispose();
// //   }
// //
// //   Future<void> _loadInitialData() async {
// //     try {
// //       final data = await _authService.fetchCustomers();
// //       setState(() {
// //         _customers = data;
// //         _isLoading = false;
// //       });
// //     } catch (e) {
// //       debugPrint("Error loading customers: $e");
// //       setState(() => _isLoading = false);
// //     }
// //   }
// //
// //   Future<void> _loadLocalData() async {
// //     final prefs = await SharedPreferences.getInstance();
// //     final String? customerJson = prefs.getString('local_customers');
// //     if (customerJson != null) {
// //       setState(() {
// //         _customers = List<Map<String, dynamic>>.from(jsonDecode(customerJson));
// //       });
// //     }
// //   }
// //
// //   // Auto-Title Generation Logic
// //   void _generateReportTitle(String customerName) {
// //     final String dateStr = DateFormat('dd/MM/yyyy').format(DateTime.now());
// //     setState(() {
// //       _titleController.text = "${customerName}_$dateStr";
// //     });
// //   }
// //
// //   void _openAddAssetPage() {
// //     Navigator.push(
// //       context,
// //       MaterialPageRoute(
// //         builder: (context) => AddAssetPage(
// //           onSave: (newAsset) {
// //             setState(() {
// //               _assets.add(newAsset);
// //             });
// //           },
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Future<void> _handleSubmitReport() async {
// //     if (_selectedCustomerId == null || _assets.isEmpty || _titleController.text.isEmpty) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         const SnackBar(content: Text("Title, Customer and at least one asset are required.")),
// //       );
// //       return;
// //     }
// //
// //     final List<ConnectivityResult> connectivityResult = await (Connectivity().checkConnectivity());
// //     if (connectivityResult.contains(ConnectivityResult.none)) {
// //       _showNoInternetDialog();
// //       return;
// //     }
// //
// //     setState(() => _isSubmitting = true);
// //
// //     try {
// //       // Create Report Header with Title and Notes
// //       final reportHeader = await _supabase.from('asset_reports').insert({
// //         'customer_id': _selectedCustomerId,
// //         'engineer_id': _supabase.auth.currentUser!.id,
// //         'report_title': _titleController.text.trim(),
// //         'notes': _reportNotesController.text.trim(),
// //         'status': 'submitted',
// //       }).select().single();
// //
// //       final String reportId = reportHeader['id'];
// //
// //       for (var asset in _assets) {
// //         String? dataPlateUrl;
// //         if (asset.dataPlateImage != null) {
// //           final fileName = 'plate_${DateTime.now().millisecondsSinceEpoch}.jpg';
// //           final path = 'reports/$reportId/$fileName';
// //           await _supabase.storage.from('images').upload(path, asset.dataPlateImage!);
// //           dataPlateUrl = _supabase.storage.from('images').getPublicUrl(path);
// //         }
// //
// //         await _supabase.from('assets_report_fridge').insert({
// //           'report_id': reportId,
// //           'area': asset.area,
// //           'data_plate_url': dataPlateUrl,
// //           'manufacturer': asset.brand,
// //           'model_no': asset.sealModelNumber,
// //           'door_count': asset.doorCount,
// //           'drawer_count': asset.drawerCount,
// //           'condition': asset.condition,
// //           'seal_id': asset.sealId,
// //           'is_unknown_seal': asset.isUnknownSeal,
// //           'confidence_score': asset.confidence,
// //           'engineer_notes': asset.description,
// //         });
// //       }
// //
// //       if (mounted) {
// //         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Full Report Submitted!")));
// //         Navigator.pop(context);
// //       }
// //     } catch (e) {
// //       debugPrint("Submit Error: $e");
// //     } finally {
// //       if (mounted) setState(() => _isSubmitting = false);
// //     }
// //   }
// //
// //   void _showNoInternetDialog() {
// //     showDialog(
// //       context: context,
// //       builder: (context) => AlertDialog(
// //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
// //         title: const Row(children: [Icon(Icons.wifi_off_rounded, color: Colors.red), SizedBox(width: 10), Text("Offline")]),
// //         content: const Text("Active internet required to submit to the office database."),
// //         actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK", style: TextStyle(fontWeight: FontWeight.bold)))],
// //       ),
// //     );
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: AppTheme.primaryBackground,
// //       appBar: AppBar(title: const Text("New Asset Report")),
// //       body: _isLoading
// //           ? const Center(child: CircularProgressIndicator())
// //           : Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           // 1. Customer Selection
// //           Padding(
// //             padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 20),
// //             child: Text("Select Customer", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.primary.withOpacity(0.7))),
// //           ),
// //           CustomCustomerDropdown(
// //             customers: _customers,
// //             selectedCustomerId: _selectedCustomerId,
// //             onChanged: (id) {
// //               setState(() => _selectedCustomerId = id);
// //               // Trigger Auto-Title
// //               final cust = _customers.firstWhere((e) => e['id'].toString() == id);
// //               _generateReportTitle(cust['full_name'] ?? "Client");
// //             },
// //           ),
// //
// //           // 2. Report Details (Title & Notes)
// //           Padding(
// //             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
// //             child: Column(
// //               children: [
// //                 TextField(
// //                   controller: _titleController,
// //                   decoration: const InputDecoration(labelText: "Report Title", hintText: "CustomerName_Date", border: OutlineInputBorder()),
// //                 ),
// //                 const SizedBox(height: 12),
// //                 TextField(
// //                   controller: _reportNotesController,
// //                   maxLines: 2,
// //                   decoration: const InputDecoration(labelText: "General Report Notes", hintText: "Add any site observations...", border: OutlineInputBorder()),
// //                 ),
// //               ],
// //             ),
// //           ),
// //
// //           const Padding(
// //             padding: EdgeInsets.symmetric(horizontal: 20),
// //             child: Text("ADDED ASSETS", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 12)),
// //           ),
// //
// //           Expanded(
// //             child: _assets.isEmpty
// //                 ? _buildEmptyState()
// //                 : ListView.builder(
// //               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
// //               itemCount: _assets.length,
// //               itemBuilder: (context, index) => _buildSummaryCard(index),
// //             ),
// //           ),
// //
// //           _buildBottomActions(),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildEmptyState() {
// //     return Center(
// //       child: Column(
// //         mainAxisAlignment: MainAxisAlignment.center,
// //         children: [
// //           Icon(Icons.kitchen_outlined, size: 64, color: Colors.grey[300]),
// //           const SizedBox(height: 10),
// //           const Text("No fridge data added yet", style: TextStyle(color: Colors.grey)),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildSummaryCard(int index) {
// //     final asset = _assets[index];
// //     return Card(
// //       elevation: 0,
// //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey[200]!)),
// //       margin: const EdgeInsets.only(bottom: 12),
// //       child: ListTile(
// //         contentPadding: const EdgeInsets.all(12),
// //         leading: Container(
// //           width: 50, height: 50,
// //           decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
// //           child: const Icon(Icons.kitchen, color: AppTheme.primary),
// //         ),
// //         title: Text(asset.area.isEmpty ? "Unit ${index + 1}" : asset.area, style: const TextStyle(fontWeight: FontWeight.bold)),
// //         subtitle: Text("Doors: ${asset.doorCount} | Drawers: ${asset.drawerCount}\nCommon Seals: ${asset.sealsAreCommon ? 'YES' : 'NO'}"),
// //         trailing: IconButton(icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent), onPressed: () => setState(() => _assets.removeAt(index))),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildBottomActions() {
// //     return Container(
// //       padding: const EdgeInsets.all(20),
// //       decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
// //       child: Column(
// //         children: [
// //           SizedBox(
// //             width: double.infinity,
// //             child: OutlinedButton.icon(
// //               onPressed: _openAddAssetPage,
// //               icon: const Icon(Icons.add_a_photo_outlined),
// //               label: const Text("ADD NEW ASSET"),
// //               style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)),
// //             ),
// //           ),
// //           const SizedBox(height: 12),
// //           SizedBox(
// //             width: double.infinity,
// //             child: ElevatedButton(
// //               onPressed: _isSubmitting ? null : _handleSubmitReport,
// //               style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, padding: const EdgeInsets.symmetric(vertical: 15)),
// //               child: _isSubmitting
// //                   ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
// //                   : const Text("SUBMIT FINAL REPORT", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
// //
// // // ... Keep your CustomCustomerDropdown class exactly as it was ...
// // class CustomCustomerDropdown extends StatefulWidget {
// //   final List customers;
// //   final String? selectedCustomerId;
// //   final Function(String id) onChanged;
// //
// //   const CustomCustomerDropdown({
// //     super.key,
// //     required this.customers,
// //     required this.selectedCustomerId,
// //     required this.onChanged,
// //   });
// //
// //   @override
// //   State<CustomCustomerDropdown> createState() =>
// //       _CustomCustomerDropdownState();
// // }
// //
// // class _CustomCustomerDropdownState extends State<CustomCustomerDropdown> {
// //   final LayerLink _layerLink = LayerLink();
// //
// //   OverlayEntry? _overlayEntry;
// //   bool isOpen = false;
// //   Map<String, dynamic>? get selectedCustomer {
// //     if (widget.customers.isNotEmpty &&
// //         widget.selectedCustomerId != null) {
// //       final matches = widget.customers.where(
// //             (e) => e['id'].toString() == widget.selectedCustomerId,
// //       );
// //
// //       if (matches.isNotEmpty) {
// //         return matches.first;
// //       }
// //     }
// //
// //     return null;
// //   }
// //   void toggleDropdown() {
// //     if (!mounted) return;
// //
// //     if (isOpen) {
// //       closeDropdown();
// //     } else {
// //       openDropdown();
// //     }
// //   }
// //
// //   void openDropdown() {
// //     _overlayEntry = _createOverlayEntry();
// //     Overlay.of(context).insert(_overlayEntry!);
// //
// //     setState(() {
// //       isOpen = true;
// //     });
// //   }
// //
// //   void closeDropdown({bool updateState = true}) {
// //     _overlayEntry?.remove();
// //     _overlayEntry = null;
// //
// //     if (mounted && updateState) {
// //       setState(() {
// //         isOpen = false;
// //       });
// //     }
// //   }
// //
// //   OverlayEntry _createOverlayEntry() {
// //     RenderBox renderBox = context.findRenderObject() as RenderBox;
// //
// //     var size = renderBox.size;
// //
// //     return OverlayEntry(
// //       builder: (context) => Positioned(
// //         width: size.width-20,
// //         child: CompositedTransformFollower(
// //           link: _layerLink,
// //           offset: const Offset(0, 70),
// //           showWhenUnlinked: false,
// //           child: Material(
// //             color: Colors.transparent,
// //             child: Container(
// //               constraints: const BoxConstraints(maxHeight: 250),
// //               decoration: BoxDecoration(
// //                 color: Colors.white,
// //                 borderRadius: BorderRadius.circular(18),
// //                 boxShadow: [
// //                   BoxShadow(
// //                     color: Colors.black.withOpacity(0.08),
// //                     blurRadius: 15,
// //                     offset: const Offset(0, 6),
// //                   ),
// //                 ],
// //               ),
// //               child: widget.customers.isEmpty
// //                   ? Padding(
// //                 padding: const EdgeInsets.all(16),
// //                 child: Text(
// //                   widget.customers.isEmpty
// //                       ? "No customers available"
// //                       : selectedCustomer == null
// //                       ? "Choose customer"
// //                       : selectedCustomer?['full_name'] ?? "Unnamed Client",
// //                   style: const TextStyle(
// //                     fontSize: 14,
// //                     fontWeight: FontWeight.w600,
// //                     color: AppTheme.primaryText,
// //                   ),
// //                   overflow: TextOverflow.ellipsis,
// //                 ),
// //               )
// //                   : ListView.builder(
// //                 padding: const EdgeInsets.symmetric(vertical: 8),
// //                 shrinkWrap: true,
// //                 itemCount: widget.customers.length,
// //                 itemBuilder: (context, index) {
// //                   final customer = widget.customers[index];
// //
// //                   final bool isSelected =
// //                       widget.selectedCustomerId ==
// //                           customer['id'].toString();
// //
// //                   return InkWell(
// //                     onTap: () {
// //                       widget.onChanged(
// //                         customer['id'].toString(),
// //                       );
// //
// //                       closeDropdown();
// //                     },
// //                     child: Container(
// //                       margin: const EdgeInsets.symmetric(
// //                         horizontal: 8,
// //                         vertical: 4,
// //                       ),
// //                       padding: const EdgeInsets.symmetric(
// //                         horizontal: 16,
// //                         vertical: 0,
// //                       ),
// //                       decoration: BoxDecoration(
// //                         color: isSelected
// //                             ? AppTheme.primary.withOpacity(0.08)
// //                             : Colors.transparent,
// //                         borderRadius: BorderRadius.circular(12),
// //                       ),
// //                       child: Row(
// //                         children: [
// //                           CircleAvatar(
// //                             radius: 18,
// //                             backgroundColor:
// //                             AppTheme.primary.withOpacity(0.1),
// //                             child: const Icon(
// //                               Icons.person,
// //                               color: AppTheme.primary,
// //                               size: 20,
// //                             ),
// //                           ),
// //
// //                           const SizedBox(width: 12),
// //
// //                           Expanded(
// //                             child: Text(
// //                               customer['full_name'] ??
// //                                   "Unnamed Client",
// //                               style: TextStyle(
// //                                 fontSize: 14,
// //                                 fontWeight: isSelected
// //                                     ? FontWeight.bold
// //                                     : FontWeight.w500,
// //                                 color: AppTheme.primaryText,
// //                               ),
// //                               overflow: TextOverflow.ellipsis,
// //                             ),
// //                           ),
// //
// //                           if (isSelected)
// //                             const Icon(
// //                               Icons.check_circle,
// //                               color: AppTheme.primary,
// //                               size: 20,
// //                             ),
// //                         ],
// //                       ),
// //                     ),
// //                   );
// //                 },
// //               ),
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   @override
// //   void dispose() {
// //     closeDropdown(updateState: false);
// //     super.dispose();
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //
// //     return Center(
// //       child: SizedBox(
// //         width: MediaQuery.of(context).size.width-20,
// //         child: CompositedTransformTarget(
// //           link: _layerLink,
// //           child: GestureDetector(
// //             onTap: widget.customers.isEmpty
// //                 ? null
// //                 : toggleDropdown,
// //             child: Container(
// //               padding: const EdgeInsets.symmetric(
// //                 horizontal: 18,
// //                 vertical: 16,
// //               ),
// //               decoration: BoxDecoration(
// //                 color: Colors.white,
// //                 borderRadius: BorderRadius.circular(16),
// //                 border: Border.all(
// //                   color: isOpen
// //                       ? AppTheme.primary
// //                       : AppTheme.primary.withOpacity(0.1),
// //                   width: isOpen ? 2 : 1.5,
// //                 ),
// //                 boxShadow: [
// //                   BoxShadow(
// //                     color: Colors.black.withOpacity(0.03),
// //                     blurRadius: 10,
// //                     offset: const Offset(0, 4),
// //                   ),
// //                 ],
// //               ),
// //               child: Row(
// //                 children: [
// //                   Icon(
// //                     Icons.person_pin_rounded,
// //                     color: widget.customers.isEmpty
// //                         ? Colors.grey
// //                         : AppTheme.primary,
// //                   ),
// //
// //                   const SizedBox(width: 14),
// //
// //                   Expanded(
// //                     child: Column(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //
// //
// //                         Text(
// //                           widget.customers.isEmpty
// //                               ? "No customers found"
// //                               : selectedCustomer == null
// //                               ? "Choose customer"
// //                               : selectedCustomer?['full_name'] ??
// //                               "Unnamed Client",)                      ],
// //                     ),
// //                   ),
// //
// //                   AnimatedRotation(
// //                     turns: isOpen ? 0.5 : 0,
// //                     duration: const Duration(milliseconds: 250),
// //                     child: Icon(
// //                       Icons.keyboard_arrow_down_rounded,
// //                       color: widget.customers.isEmpty
// //                           ? Colors.grey.shade100
// //                           :  AppTheme.primary,
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
//
//
//
//
// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:intl/intl.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../../theme.dart';
// import '../../services/supabase_service.dart';
// import 'add_asset_page.dart';
//
// class LocalAssetEntry {
//   String area = '';
//   File? dataPlateImage;
//   File? sealImage;
//   // String? manufacturer;
//   // String? modelNo;
//   // String? serialNo;
//   String manufacturer = '';
//   String modelNo = '';
//   String serialNo = '';
//   bool sealsAreCommon = true;
//   String? sealId;
//   String? manualSealName;
//   bool isUnknownSeal = true;
//   String variantDetails = '';
//   int doorCount = 0;
//   int drawerCount = 0;
//   String condition = 'OK';
//   List<File> allSealImages = [];
//   double confidence = 0.0;
//
//
//   List<IndividualSeal> individualSeals = [];
//
//   bool isMagnetic = false;
//   String? sealType;
//   String? material;
//   String? hardness;
//   double innerDiameter = 0;
//   double outerDiameter = 0;
//   double thickness = 0;
//   String? tempRange;
//   String? brand;
//   String? application;
//   String? description;
//   String? sealModelNumber;
//
//   LocalAssetEntry();
// }
//
// // --- ADD THIS HELPER CLASS AS WELL ---
// // class IndividualSeal {
// //   final String itemName;
// //   bool isIdentified = false;
// //   String? sealId;
// //   String? sealName;
// //   double confidence = 0.0;
// //   List<File> images = [];
// //
// //   // Variant Fields
// //   bool isMagnetic = false;
// //   String? sealType;
// //   String? material;
// //   String? hardness;
// //   double innerDiameter = 0;
// //   double outerDiameter = 0;
// //   double thickness = 0;
// //   String? tempRange;
// //   String? brand;
// //   String? application;
// //   String? description;
// //   String? sealModelNumber;
// //
// //   // UI Controllers
// //   late Map<String, TextEditingController> ctrls;
// //
// //   IndividualSeal({required this.itemName}) {
// //     ctrls = {
// //       'type': TextEditingController(),
// //       'material': TextEditingController(),
// //       'hardness': TextEditingController(),
// //       'inner': TextEditingController(),
// //       'outer': TextEditingController(),
// //       'thickness': TextEditingController(),
// //       'modelNum': TextEditingController(),
// //       'temp': TextEditingController(),
// //       'brand': TextEditingController(),
// //       'app': TextEditingController(),
// //       'desc': TextEditingController(),
// //     };
// //   }
// //
// //   void updateControllers() {
// //     ctrls['type']!.text = sealType ?? '';
// //     ctrls['material']!.text = material ?? '';
// //     ctrls['hardness']!.text = hardness ?? '';
// //     ctrls['inner']!.text = innerDiameter.toString();
// //     ctrls['outer']!.text = outerDiameter.toString();
// //     ctrls['thickness']!.text = thickness.toString();
// //     ctrls['modelNum']!.text = sealModelNumber ?? '';
// //     ctrls['temp']!.text = tempRange ?? '';
// //     ctrls['brand']!.text = brand ?? '';
// //     ctrls['app']!.text = application ?? '';
// //     ctrls['desc']!.text = description ?? '';
// //   }
// //
// //   void disposeControllers() {
// //     ctrls.forEach((k, v) => v.dispose());
// //   }
// // }
//
//
//
// class IndividualSeal {
//   final String itemName;
//   bool isIdentified = false;
//   String? sealId;
//   String? sealName;
//   double confidence = 0.0;
//   List<File> images = [];
//
//   // Variant Fields
//   bool isMagnetic = false;
//   String? sealType;
//   String? material;
//   String? hardness;
//   double innerDiameter = 0;
//   double outerDiameter = 0;
//   double thickness = 0;
//   String? tempRange;
//   String? brand;
//   String? application;
//   String? description;
//   String? sealModelNumber;
//
//   // UI Controllers - Must match the keys used in the sync loop
//   late Map<String, TextEditingController> ctrls;
//
//   IndividualSeal({required this.itemName}) {
//     ctrls = {
//       'type': TextEditingController(),
//       'material': TextEditingController(),
//       'hardness': TextEditingController(),
//       'inner': TextEditingController(),
//       'outer': TextEditingController(),
//       'thickness': TextEditingController(),
//       'modelNum': TextEditingController(),
//       'temp': TextEditingController(),
//       'brand': TextEditingController(),
//       'app': TextEditingController(),
//       'desc': TextEditingController(),
//     };
//   }
//
//   // This utility updates the text in the controllers if you auto-fill from DB
//   void updateControllers() {
//     ctrls['type']!.text = sealType ?? '';
//     ctrls['material']!.text = material ?? '';
//     ctrls['hardness']!.text = hardness ?? '';
//     ctrls['inner']!.text = innerDiameter.toString();
//     ctrls['outer']!.text = outerDiameter.toString();
//     ctrls['thickness']!.text = thickness.toString();
//     ctrls['modelNum']!.text = sealModelNumber ?? '';
//     ctrls['temp']!.text = tempRange ?? '';
//     ctrls['brand']!.text = brand ?? '';
//     ctrls['app']!.text = application ?? '';
//     ctrls['desc']!.text = description ?? '';
//   }
//
//   void disposeControllers() {
//     ctrls.forEach((k, v) => v.dispose());
//   }
// }
//
// class NewReportPage extends StatefulWidget {
//   const NewReportPage({super.key});
//
//   @override
//   State<NewReportPage> createState() => _NewReportPageState();
// }
//
// class _NewReportPageState extends State<NewReportPage> {
//   final _supabase = Supabase.instance.client;
//   final _authService = SupabaseService();
//
//   final TextEditingController _titleController = TextEditingController();
//   final TextEditingController _reportNotesController = TextEditingController();
//
//   String? _selectedCustomerId;
//   List<Map<String, dynamic>> _customers = [];
//   List<LocalAssetEntry> _assets = [];
//   bool _isLoading = true;
//   bool _isSubmitting = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadInitialData();
//     _loadLocalData();
//   }
//
//   @override
//   void dispose() {
//     _titleController.dispose();
//     _reportNotesController.dispose();
//     super.dispose();
//   }
//
//   // Future<void> _loadInitialData() async {
//   //   try {
//   //     final data = await _authService.fetchCustomers();
//   //     setState(() {
//   //       _customers = data;
//   //       _isLoading = false;
//   //     });
//   //   } catch (e) {
//   //     debugPrint("Error loading customers: $e");
//   //     setState(() => _isLoading = false);
//   //   }
//   // }
//   //
//   // Future<void> _loadLocalData() async {
//   //   final prefs = await SharedPreferences.getInstance();
//   //   final String? customerJson = prefs.getString('local_customers');
//   //   if (customerJson != null) {
//   //     setState(() {
//   //       _customers = List<Map<String, dynamic>>.from(jsonDecode(customerJson));
//   //     });
//   //   }
//   // }
//
//
//   Future<void> _loadInitialData() async {
//     // 1. Load local data first so the user sees something immediately
//     await _loadLocalData();
//
//     // 2. If we already have customers from local storage, stop showing the spinner
//     if (_customers.isNotEmpty) {
//       setState(() => _isLoading = false);
//     }
//
//     // 3. Try to update the list from the server in the background
//     try {
//       final List<ConnectivityResult> connectivityResult = await (Connectivity().checkConnectivity());
//
//       // Only attempt server fetch if NOT offline
//       if (!connectivityResult.contains(ConnectivityResult.none)) {
//         final data = await _authService.fetchCustomers();
//         if (data.isNotEmpty) {
//           setState(() {
//             _customers = data;
//           });
//           // Cache the fresh data for the next offline session
//           final prefs = await SharedPreferences.getInstance();
//           await prefs.setString('local_customers', jsonEncode(data));
//         }
//       }
//     } catch (e) {
//       debugPrint("Offline or Error updating customers: $e");
//     } finally {
//       // 4. Ensure loader is hidden regardless of success or failure
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }
//
//   Future<void> _loadLocalData() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final String? customerJson = prefs.getString('local_customers');
//       if (customerJson != null) {
//         final List<dynamic> decodedData = jsonDecode(customerJson);
//         setState(() {
//           _customers = List<Map<String, dynamic>>.from(decodedData);
//         });
//       }
//     } catch (e) {
//       debugPrint("Error reading SharedPreferences: $e");
//     }
//   }
//
//   void _generateReportTitle(String customerName) {
//     final String dateStr = DateFormat('dd/MM/yyyy').format(DateTime.now());
//     setState(() {
//       _titleController.text = "${customerName}_$dateStr";
//     });
//   }
//
//   void _openAddAssetPage() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => AddAssetPage(
//           onSave: (newAsset) {
//             setState(() {
//               _assets.add(newAsset);
//             });
//           },
//         ),
//       ),
//     );
//   }
//
//
//
//   // Future<void> _handleSubmitReport() async {
//   //   // 1. Validation
//   //   if (_selectedCustomerId == null || _assets.isEmpty || _titleController.text.trim().isEmpty) {
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       const SnackBar(content: Text("Title, Customer and at least one asset are required.")),
//   //     );
//   //     return;
//   //   }
//   //
//   //   // 2. Connectivity Check
//   //   final List<ConnectivityResult> connectivityResult = await (Connectivity().checkConnectivity());
//   //   if (connectivityResult.contains(ConnectivityResult.none)) {
//   //     _showNoInternetDialog();
//   //     return;
//   //   }
//   //
//   //   setState(() => _isSubmitting = true);
//   //
//   //   // Define the bucket name once for easy updates
//   //   const String bucketName = 'engineer-uploads';
//   //
//   //   try {
//   //     // 3. Insert the Main Report Header into 'asset_reports'
//   //     final reportHeader = await _supabase.from('asset_reports').insert({
//   //       'customer_id': _selectedCustomerId,
//   //       'engineer_id': _supabase.auth.currentUser!.id,
//   //       'report_title': _titleController.text.trim(),
//   //       'notes': _reportNotesController.text.trim(),
//   //       'status': 'submitted',
//   //     }).select().single();
//   //
//   //     final String reportId = reportHeader['id'];
//   //
//   //     // 4. Loop through each Fridge Asset
//   //     for (var asset in _assets) {
//   //       // A. Upload Data Plate Image to Storage
//   //       String? dataPlateUrl;
//   //       if (asset.dataPlateImage != null) {
//   //         final String fileName = 'plate_${DateTime.now().millisecondsSinceEpoch}.jpg';
//   //         final String path = 'reports/$reportId/$fileName';
//   //
//   //         await _supabase.storage.from(bucketName).upload(path, asset.dataPlateImage!);
//   //         dataPlateUrl = _supabase.storage.from(bucketName).getPublicUrl(path);
//   //       }
//   //
//   //       // B. Insert the Asset record into 'assets_report_fridge'
//   //       final assetResponse = await _supabase.from('assets_report_fridge').insert({
//   //         'report_id': reportId,
//   //         'area': asset.area,
//   //         'data_plate_url': dataPlateUrl,
//   //         'manufacturer': asset.brand,
//   //         'door_count': asset.doorCount,
//   //         'drawer_count': asset.drawerCount,
//   //         'seals_are_common': asset.sealsAreCommon, // Matches updated SQL
//   //         'engineer_notes': asset.description,
//   //       }).select().single();
//   //
//   //       final String assetId = assetResponse['id'];
//   //
//   //       // 5. Loop through individual items (Doors/Drawers) for this Asset
//   //       for (var sealItem in asset.individualSeals) {
//   //         List<String> sealImageUrls = [];
//   //
//   //         // Upload all images captured for this specific door
//   //         for (int i = 0; i < sealItem.images.length; i++) {
//   //           final String fileName = 'seal_${i}_${DateTime.now().microsecondsSinceEpoch}.jpg';
//   //           final String path = 'reports/$reportId/seals/$assetId/$fileName';
//   //
//   //           await _supabase.storage.from(bucketName).upload(path, sealItem.images[i]);
//   //           sealImageUrls.add(_supabase.storage.from(bucketName).getPublicUrl(path));
//   //         }
//   //
//   //         // C. Insert child record into 'report_asset_items'
//   //         await _supabase.from('report_asset_items').insert({
//   //           'report_asset_id': assetId,
//   //           'item_name': sealItem.itemName,
//   //           'seal_id': sealItem.sealId,
//   //           'manual_seal_name': sealItem.sealName,
//   //           'confidence_score': sealItem.confidence,
//   //           'image_urls': sealImageUrls, // Array of strings
//   //           'item_notes': sealItem.description,
//   //           // Individual Variant Specs
//   //           'material': sealItem.material,
//   //           'seal_type': sealItem.sealType,
//   //           'thickness': sealItem.thickness,
//   //           'inner_diameter': sealItem.innerDiameter,
//   //           'outer_diameter': sealItem.outerDiameter,
//   //         });
//   //       }
//   //     }
//   //
//   //     if (mounted) {
//   //       ScaffoldMessenger.of(context).showSnackBar(
//   //         const SnackBar(
//   //           content: Text("Report, Assets, and Images Synced Successfully!"),
//   //           backgroundColor: Colors.green,
//   //         ),
//   //       );
//   //       Navigator.pop(context);
//   //     }
//   //   } catch (e) {
//   //     debugPrint("Submit Error: $e");
//   //     if (mounted) {
//   //       ScaffoldMessenger.of(context).showSnackBar(
//   //         SnackBar(
//   //           content: Text("Error: ${e.toString()}"),
//   //           backgroundColor: Colors.red,
//   //         ),
//   //       );
//   //     }
//   //   } finally {
//   //     if (mounted) setState(() => _isSubmitting = false);
//   //   }
//   // }
//
//
//   Future<void> _handleSubmitReport() async {
//
//     if (_selectedCustomerId == null ||
//         _assets.isEmpty ||
//         _titleController.text.trim().isEmpty) {
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text(
//             "Title, Customer and at least one asset are required.",
//           ),
//         ),
//       );
//       return;
//     }
//
//     final List<ConnectivityResult> connectivityResult =
//     await (Connectivity().checkConnectivity());
//
//     if (connectivityResult.contains(ConnectivityResult.none)) {
//       _showNoInternetDialog();
//       return;
//     }
//
//     setState(() => _isSubmitting = true);
//
//     const String bucketName = 'engineer-uploads';
//
//     try {
//
//       /* ─────────────────────────────────────────────
//        CREATE REPORT
//     ───────────────────────────────────────────── */
//
//       final reportHeader =
//       await _supabase
//           .from('asset_reports')
//           .insert({
//         'customer_id': _selectedCustomerId,
//         'engineer_id': _supabase.auth.currentUser!.id,
//         'report_title': _titleController.text.trim(),
//         'notes': _reportNotesController.text.trim(),
//         'status': 'submitted',
//       })
//           .select()
//           .single();
//
//       final String reportId = reportHeader['id'];
//
//       /* ─────────────────────────────────────────────
//        LOOP ASSETS
//     ───────────────────────────────────────────── */
//
//       for (var asset in _assets) {
//
//         String? dataPlateUrl;
//
//         /* ───────── Upload Plate ───────── */
//
//         if (asset.dataPlateImage != null) {
//
//           final String fileName =
//               'plate_${DateTime.now().millisecondsSinceEpoch}.jpg';
//
//           final String path =
//               'reports/$reportId/$fileName';
//
//           await _supabase.storage
//               .from(bucketName)
//               .upload(path, asset.dataPlateImage!);
//
//           dataPlateUrl =
//               _supabase.storage
//                   .from(bucketName)
//                   .getPublicUrl(path);
//         }
//
//         /* ─────────────────────────────────────────────
//          INSERT FRIDGE MASTER
//       ───────────────────────────────────────────── */
//
//         final fridgeResponse =
//         await _supabase
//             .from('fridges')
//             .insert({
//
//           'manufacturer': asset.manufacturer,
//           'brand': asset.brand,
//
//           'model_no': asset.modelNo,
//           'serial_no': asset.serialNo,
//
//           'door_count': asset.doorCount,
//           'drawer_count': asset.drawerCount,
//
//           'data_plate_image_url': dataPlateUrl,
//
//           'created_by':
//           _supabase.auth.currentUser!.id,
//
//           'metadata': {
//             'source': 'mobile_app',
//             'report_title': _titleController.text,
//           }
//
//         })
//             .select()
//             .single();
//
//         final String fridgeId = fridgeResponse['id'];
//
//         /* ─────────────────────────────────────────────
//          INSERT REPORT ASSET SNAPSHOT
//       ───────────────────────────────────────────── */
//
//         final assetResponse =
//         await _supabase
//             .from('assets_report_fridge')
//             .insert({
//
//           'report_id': reportId,
//
//           'area': asset.area,
//
//           'data_plate_url': dataPlateUrl,
//
//           'manufacturer': asset.manufacturer,
//           'model_no': asset.modelNo,
//           'serial_no': asset.serialNo,
//
//           'condition': asset.condition,
//
//           'door_count': asset.doorCount,
//           'drawer_count': asset.drawerCount,
//
//           'seals_are_common':
//           asset.sealsAreCommon,
//
//           'engineer_notes':
//           asset.description,
//
//         })
//             .select()
//             .single();
//
//         final String assetId = assetResponse['id'];
//
//         /* ─────────────────────────────────────────────
//          LOOP INDIVIDUAL SEALS
//       ───────────────────────────────────────────── */
//
//         for (var sealItem in asset.individualSeals) {
//
//           List<String> sealImageUrls = [];
//
//           /* ───────── Upload Seal Images ───────── */
//
//           for (int i = 0; i < sealItem.images.length; i++) {
//
//             final String fileName =
//                 'seal_${i}_${DateTime.now().microsecondsSinceEpoch}.jpg';
//
//             final String path =
//                 'reports/$reportId/seals/$assetId/$fileName';
//
//             await _supabase.storage
//                 .from(bucketName)
//                 .upload(path, sealItem.images[i]);
//
//             sealImageUrls.add(
//               _supabase.storage
//                   .from(bucketName)
//                   .getPublicUrl(path),
//             );
//           }
//
//           /* ─────────────────────────────────────────────
//            INSERT REPORT ITEM
//         ───────────────────────────────────────────── */
//
//           await _supabase
//               .from('report_asset_items')
//               .insert({
//
//             'report_asset_id': assetId,
//
//             'item_name': sealItem.itemName,
//
//             'seal_id': sealItem.sealId,
//
//             'is_unknown_seal':
//             sealItem.sealId == null,
//
//             'confidence_score':
//             sealItem.confidence,
//
//             'manual_seal_name':
//             sealItem.sealName,
//
//             'image_urls':
//             sealImageUrls,
//
//             'item_notes':
//             sealItem.description,
//
//             'material':
//             sealItem.material,
//
//             'seal_type':
//             sealItem.sealType,
//
//             'thickness':
//             sealItem.thickness,
//
//             'inner_diameter':
//             sealItem.innerDiameter,
//
//             'outer_diameter':
//             sealItem.outerDiameter,
//
//           });
//
//           /* ─────────────────────────────────────────────
//            INSERT FRIDGE ↔ SEAL RELATION
//         ───────────────────────────────────────────── */
//
//           if (sealItem.sealId != null) {
//
//             await _supabase
//                 .from('fridge_seals_relation')
//                 .insert({
//
//               'fridge_id': fridgeId,
//
//               'seal_product_id':
//               sealItem.sealId,
//
//               'location':
//               sealItem.itemName,
//
//               'quantity': 1,
//
//               'is_primary': true,
//
//               'confidence_score':
//               sealItem.confidence,
//
//               'matching_notes':
//               sealItem.description,
//
//             });
//           }
//         }
//       }
//
//       if (mounted) {
//
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text(
//               "Report Synced Successfully!",
//             ),
//             backgroundColor: Colors.green,
//           ),
//         );
//
//         Navigator.pop(context);
//       }
//
//     } catch (e) {
//
//       debugPrint("Submit Error: $e");
//
//       if (mounted) {
//
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text("Error: $e"),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//
//     } finally {
//
//       if (mounted) {
//         setState(() => _isSubmitting = false);
//       }
//     }
//   }
//
//
//
//   void _showNoInternetDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: const Row(children: [Icon(Icons.wifi_off_rounded, color: Colors.red), SizedBox(width: 10), Text("Offline")]),
//         content: const Text("Active internet required to submit to the office database."),
//         actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK", style: TextStyle(fontWeight: FontWeight.bold)))],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppTheme.primaryBackground,
//       appBar: AppBar(title: const Text("New Asset Report")),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : CustomScrollView(
//         slivers: [
//           SliverToBoxAdapter(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // 1. Customer Selection
//                 Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 20),
//                   child: Text("Select Customer", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.primary.withOpacity(0.7))),
//                 ),
//                 CustomCustomerDropdown(
//                   customers: _customers,
//                   selectedCustomerId: _selectedCustomerId,
//                   onChanged: (id) {
//                     setState(() => _selectedCustomerId = id);
//                     final cust = _customers.firstWhere((e) => e['id'].toString() == id);
//                     _generateReportTitle(cust['full_name'] ?? "Client");
//                   },
//                 ),
//
//                 // 2. Report Details
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//                   child: Column(
//                     children: [
//                       TextField(
//                         controller: _titleController,
//                         decoration: const InputDecoration(labelText: "Report Title", border: OutlineInputBorder()),
//                       ),
//                       const SizedBox(height: 12),
//                       TextField(
//                         controller: _reportNotesController,
//                         maxLines: 2,
//                         decoration: const InputDecoration(labelText: "General Report Notes", border: OutlineInputBorder()),
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 const Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//                   child: Text("ADDED ASSETS", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 12)),
//                 ),
//               ],
//             ),
//           ),
//
//           // 3. Asset List
//           SliverPadding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             sliver: SliverList(
//               delegate: SliverChildBuilderDelegate(
//                     (context, index) => _buildSummaryCard(index),
//                 childCount: _assets.length,
//               ),
//             ),
//           ),
//
//           // 4. Fill remaining space to keep buttons at bottom
//           SliverFillRemaining(
//             hasScrollBody: false,
//             child: Column(
//               children: [
//                 if (_assets.isEmpty) _buildEmptyState(),
//                 const Spacer(),
//                 _buildBottomActions(),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildEmptyState() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 40),
//       child: Center(
//         child: Column(
//           children: [
//             Icon(Icons.kitchen_outlined, size: 64, color: Colors.grey[300]),
//             const SizedBox(height: 10),
//             const Text("No fridge data added yet", style: TextStyle(color: Colors.grey)),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // Widget _buildSummaryCard(int index) {
//   //   final asset = _assets[index];
//   //   return Card(
//   //     elevation: 0,
//   //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey[200]!)),
//   //     margin: const EdgeInsets.only(bottom: 12),
//   //     child: ListTile(
//   //       contentPadding: const EdgeInsets.all(12),
//   //       leading: Container(
//   //         width: 50, height: 50,
//   //         decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
//   //         child: const Icon(Icons.kitchen, color: AppTheme.primary),
//   //       ),
//   //       title: Text(asset.area.isEmpty ? "Unit ${index + 1}" : asset.area, style: const TextStyle(fontWeight: FontWeight.bold)),
//   //       subtitle: Text("Doors: ${asset.doorCount} | Drawers: ${asset.drawerCount}\nCommon Seals: ${asset.sealsAreCommon ? 'YES' : 'NO'}"),
//   //       trailing: IconButton(icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent), onPressed: () => setState(() => _assets.removeAt(index))),
//   //     ),
//   //   );
//   // }
//
//
//   Widget _buildSummaryCard(int index) {
//     final asset = _assets[index];
//     return Card(
//       elevation: 0,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey[200]!)),
//       margin: const EdgeInsets.only(bottom: 12),
//       child: ExpansionTile( // Using ExpansionTile to see details
//         leading: asset.dataPlateImage != null
//             ? ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(asset.dataPlateImage!, width: 50, height: 50, fit: BoxFit.cover))
//             : const Icon(Icons.kitchen, color: AppTheme.primary),
//         title: Text(asset.area.isEmpty ? "Unit ${index + 1}" : asset.area, style: const TextStyle(fontWeight: FontWeight.bold)),
//         subtitle: Text("Doors: ${asset.doorCount} | Drawers: ${asset.drawerCount}"),
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(12.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: asset.individualSeals.map((s) => Text("• ${s.itemName}: ${s.sealName ?? 'Not Identified'}", style: const TextStyle(fontSize: 12))).toList(),
//             ),
//           ),
//           TextButton.icon(
//             onPressed: () => setState(() => _assets.removeAt(index)),
//             icon: const Icon(Icons.delete, color: Colors.red, size: 18),
//             label: const Text("Remove Appliance", style: TextStyle(color: Colors.red)),
//           )
//         ],
//       ),
//     );
//   }
//
//   Widget _buildBottomActions() {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
//       child: Column(
//         children: [
//           SizedBox(
//             width: double.infinity,
//             child: OutlinedButton.icon(
//               onPressed: _openAddAssetPage,
//               icon: const Icon(Icons.add_a_photo_outlined),
//               label: const Text("ADD NEW ASSET"),
//               style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)),
//             ),
//           ),
//           const SizedBox(height: 12),
//           SizedBox(
//             width: double.infinity,
//             child: ElevatedButton(
//               onPressed: _isSubmitting ? null : _handleSubmitReport,
//               style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, padding: const EdgeInsets.symmetric(vertical: 15)),
//               child: _isSubmitting
//                   ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
//                   : const Text("SUBMIT FINAL REPORT", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // ... Keep your CustomCustomerDropdown class ...
// class CustomCustomerDropdown extends StatefulWidget {
//   final List customers;
//   final String? selectedCustomerId;
//   final Function(String id) onChanged;
//
//   const CustomCustomerDropdown({
//     super.key,
//     required this.customers,
//     required this.selectedCustomerId,
//     required this.onChanged,
//   });
//
//   @override
//   State<CustomCustomerDropdown> createState() =>
//       _CustomCustomerDropdownState();
// }
//
// class _CustomCustomerDropdownState extends State<CustomCustomerDropdown> {
//   final LayerLink _layerLink = LayerLink();
//
//   OverlayEntry? _overlayEntry;
//   bool isOpen = false;
//   Map<String, dynamic>? get selectedCustomer {
//     if (widget.customers.isNotEmpty &&
//         widget.selectedCustomerId != null) {
//       final matches = widget.customers.where(
//             (e) => e['id'].toString() == widget.selectedCustomerId,
//       );
//
//       if (matches.isNotEmpty) {
//         return matches.first;
//       }
//     }
//
//     return null;
//   }
//   void toggleDropdown() {
//     if (!mounted) return;
//
//     if (isOpen) {
//       closeDropdown();
//     } else {
//       openDropdown();
//     }
//   }
//
//   void openDropdown() {
//     _overlayEntry = _createOverlayEntry();
//     Overlay.of(context).insert(_overlayEntry!);
//
//     setState(() {
//       isOpen = true;
//     });
//   }
//
//   void closeDropdown({bool updateState = true}) {
//     _overlayEntry?.remove();
//     _overlayEntry = null;
//
//     if (mounted && updateState) {
//       setState(() {
//         isOpen = false;
//       });
//     }
//   }
//
//   OverlayEntry _createOverlayEntry() {
//     RenderBox renderBox = context.findRenderObject() as RenderBox;
//
//     var size = renderBox.size;
//
//     return OverlayEntry(
//       builder: (context) => Positioned(
//         width: size.width-20,
//         child: CompositedTransformFollower(
//           link: _layerLink,
//           offset: const Offset(0, 70),
//           showWhenUnlinked: false,
//           child: Material(
//             color: Colors.transparent,
//             child: Container(
//               constraints: const BoxConstraints(maxHeight: 250),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(18),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.08),
//                     blurRadius: 15,
//                     offset: const Offset(0, 6),
//                   ),
//                 ],
//               ),
//               child: widget.customers.isEmpty
//                   ? Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Text(
//                   widget.customers.isEmpty
//                       ? "No customers available"
//                       : selectedCustomer == null
//                       ? "Choose customer"
//                       : selectedCustomer?['full_name'] ?? "Unnamed Client",
//                   style: const TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600,
//                     color: AppTheme.primaryText,
//                   ),
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               )
//                   : ListView.builder(
//                 padding: const EdgeInsets.symmetric(vertical: 8),
//                 shrinkWrap: true,
//                 itemCount: widget.customers.length,
//                 itemBuilder: (context, index) {
//                   final customer = widget.customers[index];
//
//                   final bool isSelected =
//                       widget.selectedCustomerId ==
//                           customer['id'].toString();
//
//                   return InkWell(
//                     onTap: () {
//                       widget.onChanged(
//                         customer['id'].toString(),
//                       );
//
//                       closeDropdown();
//                     },
//                     child: Container(
//                       margin: const EdgeInsets.symmetric(
//                         horizontal: 8,
//                         vertical: 4,
//                       ),
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 16,
//                         vertical: 0,
//                       ),
//                       decoration: BoxDecoration(
//                         color: isSelected
//                             ? AppTheme.primary.withOpacity(0.08)
//                             : Colors.transparent,
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Row(
//                         children: [
//                           CircleAvatar(
//                             radius: 18,
//                             backgroundColor:
//                             AppTheme.primary.withOpacity(0.1),
//                             child: const Icon(
//                               Icons.person,
//                               color: AppTheme.primary,
//                               size: 20,
//                             ),
//                           ),
//
//                           const SizedBox(width: 12),
//
//                           Expanded(
//                             child: Text(
//                               customer['full_name'] ??
//                                   "Unnamed Client",
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 fontWeight: isSelected
//                                     ? FontWeight.bold
//                                     : FontWeight.w500,
//                                 color: AppTheme.primaryText,
//                               ),
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ),
//
//                           if (isSelected)
//                             const Icon(
//                               Icons.check_circle,
//                               color: AppTheme.primary,
//                               size: 20,
//                             ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     closeDropdown(updateState: false);
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//
//     return Center(
//       child: SizedBox(
//         width: MediaQuery.of(context).size.width-20,
//         child: CompositedTransformTarget(
//           link: _layerLink,
//           child: GestureDetector(
//             onTap: widget.customers.isEmpty
//                 ? null
//                 : toggleDropdown,
//             child: Container(
//               padding: const EdgeInsets.symmetric(
//                 horizontal: 18,
//                 vertical: 16,
//               ),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(16),
//                 border: Border.all(
//                   color: isOpen
//                       ? AppTheme.primary
//                       : AppTheme.primary.withOpacity(0.1),
//                   width: isOpen ? 2 : 1.5,
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.03),
//                     blurRadius: 10,
//                     offset: const Offset(0, 4),
//                   ),
//                 ],
//               ),
//               child: Row(
//                 children: [
//                   Icon(
//                     Icons.person_pin_rounded,
//                     color: widget.customers.isEmpty
//                         ? Colors.grey
//                         : AppTheme.primary,
//                   ),
//
//                   const SizedBox(width: 14),
//
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//
//
//                         Text(
//                           widget.customers.isEmpty
//                               ? "No customers found"
//                               : selectedCustomer == null
//                               ? "Choose customer"
//                               : selectedCustomer?['full_name'] ??
//                               "Unnamed Client",)                      ],
//                     ),
//                   ),
//
//                   AnimatedRotation(
//                     turns: isOpen ? 0.5 : 0,
//                     duration: const Duration(milliseconds: 250),
//                     child: Icon(
//                       Icons.keyboard_arrow_down_rounded,
//                       color: widget.customers.isEmpty
//                           ? Colors.grey.shade100
//                           :  AppTheme.primary,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }



import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../theme.dart';
import '../../services/supabase_service.dart';
import 'add_asset_page.dart';

class LocalAssetEntry {
  String? fridgeId; // Populated by Edge Function in AddAssetPage
  String area = '';
  File? dataPlateImage;
  File? sealImage;
  String manufacturer = '';
  String modelNo = '';
  String serialNo = '';
  bool sealsAreCommon = true;
  String? sealId;
  String? manualSealName;
  bool isUnknownSeal = true;
  String variantDetails = '';
  int doorCount = 0;
  int drawerCount = 0;
  String condition = 'OK';
  List<File> allSealImages = [];
  double confidence = 0.0;
  String description = '';
  String? brand;

  List<IndividualSeal> individualSeals = [];

  // Variant Fields
  bool isMagnetic = false;
  String? sealType;
  String? material;
  String? hardness;
  double innerDiameter = 0;
  double outerDiameter = 0;
  double thickness = 0;
  String? tempRange;
  String? application;
  String? sealModelNumber;

  LocalAssetEntry();
}

class IndividualSeal {
  String itemName;
  bool isIdentified = false;
  String? sealId;
  String? sealName;
  double confidence = 0.0;
  List<File> images = [];

  // --- NEW FIELDS ---
  double doorHeight = 0.0;
  double doorWidth = 0.0;
  double wearPercentage = 0.0; // Slider value 0-100
  bool needsUrgentReplacement = false;
  // ------------------

  // Variant Fields
  bool isMagnetic = false;
  String? sealType;
  String? material;
  String? hardness;
  double innerDiameter = 0;
  double outerDiameter = 0;
  double thickness = 0;
  String? tempRange;
  String? brand;
  String? application;
  String? description;
  String? sealModelNumber;

  late Map<String, TextEditingController> ctrls;

  IndividualSeal({required this.itemName}) {
    ctrls = {
      'type': TextEditingController(),
      'material': TextEditingController(),
      'hardness': TextEditingController(),
      'inner': TextEditingController(),
      'outer': TextEditingController(),
      'thickness': TextEditingController(),
      'modelNum': TextEditingController(),
      'temp': TextEditingController(),
      'brand': TextEditingController(),
      'app': TextEditingController(),
      'desc': TextEditingController(),
      // New Controllers for Dimensions
      'height': TextEditingController(),
      'width': TextEditingController(),
    };
  }

  void updateControllers() {
    ctrls['type']!.text = sealType ?? '';
    ctrls['material']!.text = material ?? '';
    ctrls['hardness']!.text = hardness ?? '';
    ctrls['inner']!.text = innerDiameter.toString();
    ctrls['outer']!.text = outerDiameter.toString();
    ctrls['thickness']!.text = thickness.toString();
    ctrls['modelNum']!.text = sealModelNumber ?? '';
    ctrls['temp']!.text = tempRange ?? '';
    ctrls['brand']!.text = brand ?? '';
    ctrls['app']!.text = application ?? '';
    ctrls['desc']!.text = description ?? '';
    ctrls['height']!.text = doorHeight > 0 ? doorHeight.toString() : '';
    ctrls['width']!.text = doorWidth > 0 ? doorWidth.toString() : '';
  }

  void disposeControllers() {
    ctrls.forEach((k, v) => v.dispose());
  }
}

class NewReportPage extends StatefulWidget {
  const NewReportPage({super.key});

  @override
  State<NewReportPage> createState() => _NewReportPageState();
}

class _NewReportPageState extends State<NewReportPage> {
  final _supabase = Supabase.instance.client;
  final _authService = SupabaseService();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _reportNotesController = TextEditingController();

  String? _selectedCustomerId;
  List<Map<String, dynamic>> _customers = [];
  List<LocalAssetEntry> _assets = [];
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _reportNotesController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    await _loadLocalData();
    if (_customers.isNotEmpty) {
      setState(() => _isLoading = false);
    }

    try {
      final List<ConnectivityResult> connectivityResult = await (Connectivity().checkConnectivity());
      if (!connectivityResult.contains(ConnectivityResult.none)) {
        final data = await _authService.fetchCustomers();
        if (data.isNotEmpty) {
          setState(() => _customers = data);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('local_customers', jsonEncode(data));
        }
      }
    } catch (e) {
      debugPrint("Offline or Error updating customers: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadLocalData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? customerJson = prefs.getString('local_customers');
      if (customerJson != null) {
        final List<dynamic> decodedData = jsonDecode(customerJson);
        setState(() => _customers = List<Map<String, dynamic>>.from(decodedData));
      }
    } catch (e) {
      debugPrint("Error reading SharedPreferences: $e");
    }
  }

  void _generateReportTitle(String customerName) {
    final String dateStr = DateFormat('dd/MM/yyyy').format(DateTime.now());
    setState(() {
      _titleController.text = "${customerName}_$dateStr";
    });
  }

  void _openAddAssetPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddAssetPage(
          onSave: (newAsset) {
            setState(() => _assets.add(newAsset));
          },
        ),
      ),
    );
  }

  // Future<void> _handleSubmitReport() async {
  //   if (_selectedCustomerId == null || _assets.isEmpty || _titleController.text.trim().isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("Title, Customer and at least one asset are required.")),
  //     );
  //     return;
  //   }
  //
  //   final List<ConnectivityResult> connectivityResult = await (Connectivity().checkConnectivity());
  //   if (connectivityResult.contains(ConnectivityResult.none)) {
  //     _showNoInternetDialog();
  //     return;
  //   }
  //
  //   setState(() => _isSubmitting = true);
  //   const String bucketName = 'engineer-uploads';
  //
  //   try {
  //     // 1. INSERT REPORT HEADER
  //     final reportHeader = await _supabase.from('asset_reports').insert({
  //       'customer_id': _selectedCustomerId,
  //       'engineer_id': _supabase.auth.currentUser!.id,
  //       'report_title': _titleController.text.trim(),
  //       'notes': _reportNotesController.text.trim(),
  //       'status': 'submitted',
  //     }).select().single();
  //
  //     final String reportId = reportHeader['id'];
  //
  //     // 2. LOOP THROUGH ASSETS
  //     for (var asset in _assets) {
  //       String? dataPlateUrl;
  //
  //       // Upload Data Plate Image
  //       if (asset.dataPlateImage != null) {
  //         final String fileName = 'plate_${DateTime.now().millisecondsSinceEpoch}.jpg';
  //         final String path = 'reports/$reportId/$fileName';
  //         await _supabase.storage.from(bucketName).upload(path, asset.dataPlateImage!);
  //         dataPlateUrl = _supabase.storage.from(bucketName).getPublicUrl(path);
  //       }
  //
  //       // 3. INSERT SNAPSHOT INTO 'assets_report_fridge' (Linking to existing Fridge ID)
  //       final assetResponse = await _supabase.from('assets_report_fridge').insert({
  //         'report_id': reportId,
  //         'fridge_id': asset.fridgeId, // Data from Edge Function result
  //         'area': asset.area,
  //         'data_plate_url': dataPlateUrl,
  //         'manufacturer': asset.manufacturer,
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
  //       for (var sealItem in asset.individualSeals) {
  //         List<String> sealImageUrls = [];
  //
  //         // Upload Seal Images
  //         for (int i = 0; i < sealItem.images.length; i++) {
  //           final String fileName = 'seal_${i}_${DateTime.now().microsecondsSinceEpoch}.jpg';
  //           final String path = 'reports/$reportId/seals/$assetId/$fileName';
  //           await _supabase.storage.from(bucketName).upload(path, sealItem.images[i]);
  //           sealImageUrls.add(_supabase.storage.from(bucketName).getPublicUrl(path));
  //         }
  //
  //         // 5. INSERT INTO 'report_asset_items'
  //         await _supabase.from('report_asset_items').insert({
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
  //         });
  //
  //         // 6. UPDATE RELATION (Link Seal to Fridge master if identified)
  //         if (sealItem.sealId != null && asset.fridgeId != null) {
  //           await _supabase.from('fridge_seals_relation').insert({
  //             'fridge_id': asset.fridgeId,
  //             'seal_product_id': sealItem.sealId,
  //             'location': sealItem.itemName,
  //             'quantity': 1,
  //             'is_primary': true,
  //             'confidence_score': sealItem.confidence,
  //             'matching_notes': sealItem.description,
  //           });
  //         }
  //       }
  //     }
  //
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text("Report Synced Successfully!"), backgroundColor: Colors.green),
  //       );
  //       Navigator.pop(context);
  //     }
  //   } catch (e) {
  //     debugPrint("Submit Error: $e");
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
  //       );
  //     }
  //   } finally {
  //     if (mounted) setState(() => _isSubmitting = false);
  //   }
  // }


  // Future<void> _handleSubmitReport() async {
  //   if (_selectedCustomerId == null || _assets.isEmpty || _titleController.text.trim().isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("Title, Customer and at least one asset are required.")),
  //     );
  //     return;
  //   }
  //
  //   final List<ConnectivityResult> connectivityResult = await (Connectivity().checkConnectivity());
  //   if (connectivityResult.contains(ConnectivityResult.none)) {
  //     _showNoInternetDialog();
  //     return;
  //   }
  //
  //   setState(() => _isSubmitting = true);
  //   const String bucketName = 'engineer-uploads';
  //
  //   try {
  //     // 1. INSERT REPORT HEADER
  //     final reportHeader = await _supabase.from('asset_reports').insert({
  //       'customer_id': _selectedCustomerId,
  //       'engineer_id': _supabase.auth.currentUser!.id,
  //       'report_title': _titleController.text.trim(),
  //       'notes': _reportNotesController.text.trim(),
  //       'status': 'submitted',
  //     }).select().single();
  //
  //     final String reportId = reportHeader['id'];
  //
  //     // 2. LOOP THROUGH ASSETS
  //     for (var asset in _assets) {
  //       String? dataPlateUrl;
  //
  //       if (asset.dataPlateImage != null) {
  //         final String fileName = 'plate_${DateTime.now().millisecondsSinceEpoch}.jpg';
  //         final String path = 'reports/$reportId/$fileName';
  //         await _supabase.storage.from(bucketName).upload(path, asset.dataPlateImage!);
  //         dataPlateUrl = _supabase.storage.from(bucketName).getPublicUrl(path);
  //       }
  //
  //       // 3. INSERT INTO 'assets_report_fridge'
  //       final assetResponse = await _supabase.from('assets_report_fridge').insert({
  //         'report_id': reportId,
  //         'fridge_id': asset.fridgeId,
  //         'area': asset.area,
  //         'data_plate_url': dataPlateUrl,
  //         'manufacturer': asset.brand ?? asset.manufacturer, // Using Brand logic
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
  //       for (var sealItem in asset.individualSeals) {
  //         List<String> sealImageUrls = [];
  //
  //         for (int i = 0; i < sealItem.images.length; i++) {
  //           final String fileName = 'seal_${i}_${DateTime.now().microsecondsSinceEpoch}.jpg';
  //           final String path = 'reports/$reportId/seals/$assetId/$fileName';
  //           await _supabase.storage.from(bucketName).upload(path, sealItem.images[i]);
  //           sealImageUrls.add(_supabase.storage.from(bucketName).getPublicUrl(path));
  //         }
  //
  //         // 5. INSERT INTO 'report_asset_items' (Snapshot for the report)
  //         await _supabase.from('report_asset_items').insert({
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
  //         });
  //
  //         // 6. UPDATE MANY-TO-MANY RELATIONSHIP (Global Lookup Table)
  //         // If we have a Fridge ID and a Seal ID, we ensure this relation exists
  //         if (sealItem.sealId != null && asset.fridgeId != null) {
  //
  //           // Check if this specific Fridge + Seal + Location combo already exists
  //           final existingRelation = await _supabase
  //               .from('fridge_seals_relation')
  //               .select()
  //               .eq('fridge_id', asset.fridgeId as Object)
  //               .eq('seal_product_id', sealItem.sealId as Object)
  //               .eq('location', sealItem.itemName)
  //               .maybeSingle();
  //
  //           // If it doesn't exist, insert it.
  //           // This "learns" that this seal fits this fridge for future engineers.
  //           if (existingRelation == null) {
  //             await _supabase.from('fridge_seals_relation').insert({
  //               'fridge_id': asset.fridgeId,
  //               'seal_product_id': sealItem.sealId,
  //               'location': sealItem.itemName,
  //               'quantity': 1,
  //               'is_primary': false, // Mark as secondary/engineer-added
  //               'confidence_score': sealItem.confidence,
  //               'matching_notes': "Learned from Report: $reportId",
  //             });
  //           }
  //         }
  //       }
  //     }
  //
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text("Report & New Relations Synced!"), backgroundColor: Colors.green),
  //       );
  //       Navigator.pop(context);
  //     }
  //   } catch (e) {
  //     debugPrint("Submit Error: $e");
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text("Submission Failed: $e"), backgroundColor: Colors.red),
  //       );
  //     }
  //   } finally {
  //     if (mounted) setState(() => _isSubmitting = false);
  //   }
  // }

  // Future<void> _handleSubmitReport() async {
  //   if (_selectedCustomerId == null || _assets.isEmpty || _titleController.text.trim().isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("Title, Customer and at least one asset are required.")),
  //     );
  //     return;
  //   }
  //
  //   final List<ConnectivityResult> connectivityResult = await (Connectivity().checkConnectivity());
  //   if (connectivityResult.contains(ConnectivityResult.none)) {
  //     _showNoInternetDialog();
  //     return;
  //   }
  //
  //   setState(() => _isSubmitting = true);
  //   const String bucketName = 'engineer-uploads';
  //
  //   try {
  //     // 1. INSERT REPORT HEADER
  //     final reportHeader = await _supabase.from('asset_reports').insert({
  //       'customer_id': _selectedCustomerId,
  //       'engineer_id': _supabase.auth.currentUser!.id,
  //       'report_title': _titleController.text.trim(),
  //       'notes': _reportNotesController.text.trim(),
  //       'status': 'submitted',
  //     }).select().single();
  //
  //     final String reportId = reportHeader['id'];
  //
  //     // 2. LOOP THROUGH ASSETS
  //     for (var asset in _assets) {
  //       String? dataPlateUrl;
  //
  //       // Upload Data Plate Image
  //       if (asset.dataPlateImage != null) {
  //         final String fileName = 'plate_${DateTime.now().millisecondsSinceEpoch}.jpg';
  //         final String path = 'reports/$reportId/$fileName';
  //         await _supabase.storage.from(bucketName).upload(path, asset.dataPlateImage!);
  //         dataPlateUrl = _supabase.storage.from(bucketName).getPublicUrl(path);
  //       }
  //
  //       // --- NEW: AUTO-CORRECT FRIDGES MASTER TABLE ---
  //       // If we have a fridgeId, ensure the door/drawer counts are correct in the master table
  //       if (asset.fridgeId != null) {
  //         await _supabase.from('fridges').update({
  //           'door_count': asset.doorCount,
  //           'drawer_count': asset.drawerCount,
  //           'updated_at': DateTime.now().toIso8601String(),
  //         }).eq('id', asset.fridgeId!);
  //       }
  //
  //       // 3. INSERT INTO 'assets_report_fridge' (The report snapshot)
  //       final assetResponse = await _supabase.from('assets_report_fridge').insert({
  //         'report_id': reportId,
  //         'fridge_id': asset.fridgeId,
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
  //       for (var sealItem in asset.individualSeals) {
  //         List<String> sealImageUrls = [];
  //
  //         // Upload Seal Images
  //         for (int i = 0; i < sealItem.images.length; i++) {
  //           final String fileName = 'seal_${i}_${DateTime.now().microsecondsSinceEpoch}.jpg';
  //           final String path = 'reports/$reportId/seals/$assetId/$fileName';
  //           await _supabase.storage.from(bucketName).upload(path, sealItem.images[i]);
  //           sealImageUrls.add(_supabase.storage.from(bucketName).getPublicUrl(path));
  //         }
  //
  //         // 5. INSERT INTO 'report_asset_items'
  //         await _supabase.from('report_asset_items').insert({
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
  //         });
  //
  //         // 6. UPDATE MANY-TO-MANY RELATIONSHIP
  //         if (sealItem.sealId != null && asset.fridgeId != null) {
  //           final existingRelation = await _supabase
  //               .from('fridge_seals_relation')
  //               .select()
  //               .eq('fridge_id', asset.fridgeId!)
  //               .eq('seal_product_id', sealItem.sealId!)
  //               .eq('location', sealItem.itemName)
  //               .maybeSingle();
  //
  //           if (existingRelation == null) {
  //             await _supabase.from('fridge_seals_relation').insert({
  //               'fridge_id': asset.fridgeId,
  //               'seal_product_id': sealItem.sealId,
  //               'location': sealItem.itemName,
  //               'quantity': 1,
  //               'is_primary': false,
  //               'confidence_score': sealItem.confidence,
  //               'matching_notes': "Learned from Report: $reportId",
  //             });
  //           }
  //         }
  //       }
  //     }
  //
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text("Report submitted and Fridge data updated!"), backgroundColor: Colors.green),
  //       );
  //       Navigator.pop(context);
  //     }
  //   } catch (e) {
  //     debugPrint("Submit Error: $e");
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text("Submission Failed: $e"), backgroundColor: Colors.red),
  //       );
  //     }
  //   } finally {
  //     if (mounted) setState(() => _isSubmitting = false);
  //   }
  // }




  Future<void> _handleSubmitReport() async {
    if (_selectedCustomerId == null || _assets.isEmpty || _titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Title, Customer and at least one asset are required.")),
      );
      return;
    }

    final List<ConnectivityResult> connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.none)) {
      _showNoInternetDialog();
      return;
    }

    setState(() => _isSubmitting = true);
    const String bucketName = 'engineer-uploads';

    try {
      // 1. INSERT REPORT HEADER
      final reportHeader = await _supabase.from('asset_reports').insert({
        'customer_id': _selectedCustomerId,
        'engineer_id': _supabase.auth.currentUser!.id,
        'report_title': _titleController.text.trim(),
        'notes': _reportNotesController.text.trim(),
        'status': 'submitted',
      }).select().single();

      final String reportId = reportHeader['id'];

      // 2. LOOP THROUGH FRIDGE ASSETS
      for (var asset in _assets) {
        String? dataPlateUrl;

        // Upload Data Plate Image if it exists
        if (asset.dataPlateImage != null) {
          final String fileName = 'plate_${DateTime.now().millisecondsSinceEpoch}.jpg';
          final String path = 'reports/$reportId/$fileName';
          await _supabase.storage.from(bucketName).upload(path, asset.dataPlateImage!);
          dataPlateUrl = _supabase.storage.from(bucketName).getPublicUrl(path);
        }

        // AUTO-CORRECT FRIDGES MASTER QUANTITIES
        if (asset.fridgeId != null) {
          await _supabase.from('fridges').update({
            'door_count': asset.doorCount,
            'drawer_count': asset.drawerCount,
            'updated_at': DateTime.now().toIso8601String(),
          }).eq('id', asset.fridgeId!);
        }

        // 3. INSERT SNAPSHOT INTO 'assets_report_fridge' (Report Snapshot)
        final assetResponse = await _supabase.from('assets_report_fridge').insert({
          'report_id': reportId,
          'fridge_id': asset.fridgeId,
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

        final String assetId = assetResponse['id'];

        // 4. LOOP THROUGH INDIVIDUAL SEALS ON THIS ASSET
        for (int index = 0; index < asset.individualSeals.length; index++) {
          var sealItem = asset.individualSeals[index];
          List<String> sealImageUrls = [];

          // Upload Multiple Seal Images
          for (int i = 0; i < sealItem.images.length; i++) {
            final String fileName = 'seal_${i}_${DateTime.now().microsecondsSinceEpoch}.jpg';
            final String path = 'reports/$reportId/seals/$assetId/$fileName';
            await _supabase.storage.from(bucketName).upload(path, sealItem.images[i]);
            sealImageUrls.add(_supabase.storage.from(bucketName).getPublicUrl(path));
          }

          // 5. INSERT SNAPSHOT INTO 'report_asset_items' (Includes Wear & Replacement metrics)
          await _supabase.from('report_asset_items').insert({
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
            // Updated custom data parameters
            'wear_percentage': sealItem.wearPercentage.toInt(),
            'need_replacement': sealItem.needsUrgentReplacement,
          });

          // 6. UPSERT DATA INTO MASTER 'fridge_components' TABLE & GET THE COMPONENT UUID
          String? componentUuid;

          if (asset.fridgeId != null) {
            final String componentType = sealItem.itemName.toLowerCase().contains('drawer') ? 'drawer' : 'door';

            // Check if this component position configuration index already exists for this fridge
            final existingComp = await _supabase
                .from('fridge_components')
                .select()
                .eq('fridge_id', asset.fridgeId!)
                .eq('component_type', componentType)
                .eq('component_index', index + 1)
                .maybeSingle();

            if (existingComp == null) {
              // Record doesn't exist -> Insert fresh and select its generated ID back
              final newComp = await _supabase.from('fridge_components').insert({
                'fridge_id': asset.fridgeId,
                'component_type': componentType,
                'component_index': index + 1,
                'width_mm': sealItem.doorWidth,
                'height_mm': sealItem.doorHeight,
                'notes': 'Learned from component field logic.',
              }).select('id').single();

              componentUuid = newComp['id'];
            } else {
              // Record exists -> Update measurements and fetch its existing ID back
              final updatedComp = await _supabase.from('fridge_components').update({
                'width_mm': sealItem.doorWidth,
                'height_mm': sealItem.doorHeight,
              }).eq('id', existingComp['id']).select('id').single();

              componentUuid = updatedComp['id'];
            }
          }

          // 7. SYNC MANY-TO-MANY RELATIONSHIP WITH COMPONENTS LINKED INSIDE ARRAY
          if (sealItem.sealId != null && asset.fridgeId != null) {
            final existingRelation = await _supabase
                .from('fridge_seals_relation')
                .select()
                .eq('fridge_id', asset.fridgeId!)
                .eq('seal_product_id', sealItem.sealId!)
                .eq('location', sealItem.itemName)
                .maybeSingle();

            List<String> currentComponentIds = [];

            if (existingRelation != null) {
              // Existing Relation Found -> Pull current linked array elements
              if (existingRelation['supported_component_ids'] != null) {
                currentComponentIds = List<String>.from(existingRelation['supported_component_ids']);
              }

              // Append component token to unique listing array cleanly
              if (componentUuid != null && !currentComponentIds.contains(componentUuid)) {
                currentComponentIds.add(componentUuid);
              }

              // Save back the updated component linkage safely
              await _supabase.from('fridge_seals_relation').update({
                'supported_component_ids': currentComponentIds,
                'updated_at': DateTime.now().toIso8601String(),
              }).eq('id', existingRelation['id']);

            } else {
              // No Relation Found -> Create completely new relationship mapping layout row
              if (componentUuid != null) {
                currentComponentIds.add(componentUuid);
              }

              // await _supabase.from('fridge_seals_relation').insert({
              //   'fridge_id': asset.fridgeId,
              //   'seal_product_id': sealItem.sealId,
              //   'location': sealItem.itemName,
              //   'supported_component_ids': currentComponentIds,
              //   'quantity': 1,
              //   'is_primary': false,
              //   'confidence_score': sealItem.confidence,
              //   'matching_notes': "Learned and relational linked via component index from Report: $reportId",
              //   'suggested_by_user_id': _supabase.auth.currentUser!.id,
              // });

              //  TO THIS (Correct Fixed Code)
              await _supabase.from('fridge_seals_relation').insert({
                'fridge_id': asset.fridgeId,
                'seal_product_id': sealItem.sealId,
                'location': sealItem.itemName,
                'supported_component_ids': currentComponentIds,
                'is_verified': false, // ✅ FIXED: Changed to match your database schema column
                'confidence_score': sealItem.confidence,
                'matching_notes': "Learned and relational linked via component index from Report: $reportId",
                'suggested_by_user_id': _supabase.auth.currentUser!.id,
              });
            }
          }
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Report metrics, wear states, and dimensions saved!"), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint("Submit Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Submission Failed: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }


  void _showNoInternetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(children: [Icon(Icons.wifi_off_rounded, color: Colors.red), SizedBox(width: 10), Text("Offline")]),
        content: const Text("Active internet required to submit to the office database."),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBackground,
      appBar: AppBar(title: const Text("New Asset Report")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 20),
                  child: Text("Select Customer", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.primary.withOpacity(0.7))),
                ),
                CustomCustomerDropdown(
                  customers: _customers,
                  selectedCustomerId: _selectedCustomerId,
                  onChanged: (id) {
                    setState(() => _selectedCustomerId = id);
                    final cust = _customers.firstWhere((e) => e['id'].toString() == id);
                    _generateReportTitle(cust['full_name'] ?? "Client");
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Column(
                    children: [
                      TextField(
                        controller: _titleController,
                        decoration: const InputDecoration(labelText: "Report Title", border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _reportNotesController,
                        maxLines: 2,
                        decoration: const InputDecoration(labelText: "General Report Notes", border: OutlineInputBorder()),
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text("ADDED ASSETS", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 12)),
                ),
              ],
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildSummaryCard(index),
                childCount: _assets.length,
              ),
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              children: [
                if (_assets.isEmpty) _buildEmptyState(),
                const Spacer(),
                _buildBottomActions(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.kitchen_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 10),
            const Text("No fridge data added yet", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(int index) {
    final asset = _assets[index];
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey[200]!)),
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: asset.dataPlateImage != null
            ? ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(asset.dataPlateImage!, width: 50, height: 50, fit: BoxFit.cover))
            : const Icon(Icons.kitchen, color: AppTheme.primary),
        title: Text(asset.area.isEmpty ? "Unit ${index + 1}" : asset.area, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("Doors: ${asset.doorCount} | Drawers: ${asset.drawerCount}"),
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: asset.individualSeals.map((s) => Text("• ${s.itemName}: ${s.sealName ?? 'Not Identified'}", style: const TextStyle(fontSize: 12))).toList(),
            ),
          ),
          TextButton.icon(
            onPressed: () => setState(() => _assets.removeAt(index)),
            icon: const Icon(Icons.delete, color: Colors.red, size: 18),
            label: const Text("Remove Appliance", style: TextStyle(color: Colors.red)),
          )
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _openAddAssetPage,
              icon: const Icon(Icons.add_a_photo_outlined),
              label: const Text("ADD NEW ASSET"),
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _handleSubmitReport,
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, padding: const EdgeInsets.symmetric(vertical: 15)),
              child: _isSubmitting
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text("SUBMIT FINAL REPORT", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomCustomerDropdown extends StatefulWidget {
  final List customers;
  final String? selectedCustomerId;
  final Function(String id) onChanged;

  const CustomCustomerDropdown({
    super.key,
    required this.customers,
    required this.selectedCustomerId,
    required this.onChanged,
  });

  @override
  State<CustomCustomerDropdown> createState() => _CustomCustomerDropdownState();
}

class _CustomCustomerDropdownState extends State<CustomCustomerDropdown> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool isOpen = false;

  Map<String, dynamic>? get selectedCustomer {
    if (widget.customers.isNotEmpty && widget.selectedCustomerId != null) {
      final matches = widget.customers.where((e) => e['id'].toString() == widget.selectedCustomerId);
      return matches.isNotEmpty ? matches.first : null;
    }
    return null;
  }

  void toggleDropdown() => isOpen ? closeDropdown() : openDropdown();

  void openDropdown() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() => isOpen = true);
  }

  void closeDropdown({bool updateState = true}) {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted && updateState) setState(() => isOpen = false);
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;
    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width - 20,
        child: CompositedTransformFollower(
          link: _layerLink,
          offset: const Offset(0, 70),
          showWhenUnlinked: false,
          child: Material(
            color: Colors.transparent,
            child: Container(
              constraints: const BoxConstraints(maxHeight: 250),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 6))],
              ),
              child: widget.customers.isEmpty
                  ? const Padding(padding: EdgeInsets.all(16), child: Text("No customers available"))
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                shrinkWrap: true,
                itemCount: widget.customers.length,
                itemBuilder: (context, index) {
                  final customer = widget.customers[index];
                  final bool isSelected = widget.selectedCustomerId == customer['id'].toString();
                  return InkWell(
                    onTap: () {
                      widget.onChanged(customer['id'].toString());
                      closeDropdown();
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.primary.withOpacity(0.08) : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(radius: 18, backgroundColor: AppTheme.primary.withOpacity(0.1), child: const Icon(Icons.person, color: AppTheme.primary, size: 20)),
                          const SizedBox(width: 12),
                          Expanded(child: Text(customer['full_name'] ?? "Unnamed Client", style: TextStyle(fontSize: 14, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500))),
                          if (isSelected) const Icon(Icons.check_circle, color: AppTheme.primary, size: 20),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    closeDropdown(updateState: false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width - 20,
        child: CompositedTransformTarget(
          link: _layerLink,
          child: GestureDetector(
            onTap: widget.customers.isEmpty ? null : toggleDropdown,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isOpen ? AppTheme.primary : AppTheme.primary.withOpacity(0.1), width: isOpen ? 2 : 1.5),
              ),
              child: Row(
                children: [
                  Icon(Icons.person_pin_rounded, color: widget.customers.isEmpty ? Colors.grey : AppTheme.primary),
                  const SizedBox(width: 14),
                  Expanded(child: Text(selectedCustomer?['full_name'] ?? "Choose customer")),
                  AnimatedRotation(turns: isOpen ? 0.5 : 0, duration: const Duration(milliseconds: 250), child: Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.primary)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
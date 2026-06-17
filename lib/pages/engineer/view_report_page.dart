// // // import 'dart:convert';
// // //
// // // import 'package:flutter/material.dart';
// // // import 'package:shared_preferences/shared_preferences.dart';
// // // import 'package:supabase_flutter/supabase_flutter.dart';
// // // import 'package:intl/intl.dart';
// // // import '../../../theme.dart';
// // // import '../../components/image_previewer.dart';
// // //
// // // class ViewReportPage extends StatefulWidget {
// // //   final String reportId;
// // //   const ViewReportPage({super.key, required this.reportId});
// // //
// // //   @override
// // //   State<ViewReportPage> createState() => _ViewReportPageState();
// // // }
// // //
// // // class _ViewReportPageState extends State<ViewReportPage> {
// // //   final SupabaseClient _supabase = Supabase.instance.client;
// // //   bool _isLoading = true;
// // //   Map<String, dynamic>? _report;
// // //
// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     _fetchReportDetails();
// // //   }
// // //
// // //   // Future<void> _fetchReportDetails() async {
// // //   //   try {
// // //   //     // Fetches Report -> Customer -> Fridge Assets -> Individual Seal Items
// // //   //     final data = await _supabase.from('asset_reports').select('''
// // //   //       *,
// // //   //       customer:user_profiles!customer_id(full_name, email),
// // //   //       fridges:assets_report_fridge(
// // //   //         *,
// // //   //         seals:report_asset_items(*)
// // //   //       )
// // //   //     ''').eq('id', widget.reportId).single();
// // //   //
// // //   //     setState(() {
// // //   //       _report = data;
// // //   //       _isLoading = false;
// // //   //     });
// // //   //   } catch (e) {
// // //   //     debugPrint("Error fetching report: $e");
// // //   //     if (mounted) setState(() => _isLoading = false);
// // //   //   }
// // //   // }
// // //
// // //
// // //   // Inside _ViewReportPageState in view_report_page.dart
// // //
// // //   Future<void> _fetchReportDetails() async {
// // //     try {
// // //       final prefs = await SharedPreferences.getInstance();
// // //       final String? cachedData = prefs.getString('cached_my_reports');
// // //
// // //       if (cachedData != null) {
// // //         final List<dynamic> allReports = jsonDecode(cachedData);
// // //
// // //         // Find the specific report by ID from the local list
// // //         final report = allReports.firstWhere(
// // //               (r) => r['id'] == widget.reportId,
// // //           orElse: () => null,
// // //         );
// // //
// // //         if (report != null) {
// // //           setState(() {
// // //             _report = report;
// // //             _isLoading = false;
// // //           });
// // //           return; // Exit early since we found it locally
// // //         }
// // //       }
// // //
// // //       // Fallback: If not found locally, try fetching from Supabase (online only)
// // //       final onlineData = await _supabase.from('asset_reports').select('''
// // //         *,
// // //         customer:user_profiles!customer_id(full_name, email),
// // //         fridges:assets_report_fridge(*, seals:asset_report_fridge_items(*))
// // //       ''').eq('id', widget.reportId).single();
// // //
// // //       setState(() {
// // //         _report = onlineData;
// // //         _isLoading = false;
// // //       });
// // //     } catch (e) {
// // //       debugPrint("Error: $e");
// // //       if (mounted) setState(() => _isLoading = false);
// // //     }
// // //   }
// // //
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
// // //     if (_report == null) return const Scaffold(body: Center(child: Text("Report data not found")));
// // //
// // //     final fridges = _report!['fridges'] as List;
// // //
// // //     return Scaffold(
// // //       backgroundColor: const Color(0xFFF8F9FA),
// // //       appBar: AppBar(
// // //         title: Text(_report!['report_title'] ?? "Report Summary"),
// // //         elevation: 0,
// // //       ),
// // //       body: SingleChildScrollView(
// // //         padding: const EdgeInsets.all(16),
// // //         child: Column(
// // //           crossAxisAlignment: CrossAxisAlignment.start,
// // //           children: [
// // //             _buildReportHeader(),
// // //             const SizedBox(height: 24),
// // //             const Text("ASSET DETAILS",
// // //                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blueGrey, letterSpacing: 1.1)),
// // //             const SizedBox(height: 12),
// // //             ...fridges.map((f) => _buildFridgeDetailCard(f)).toList(),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }
// // //
// // //   Widget _buildReportHeader() {
// // //     final customer = _report!['customer'];
// // //     final date = DateTime.parse(_report!['report_date']).toLocal();
// // //
// // //     return Container(
// // //       padding: const EdgeInsets.all(20),
// // //       decoration: BoxDecoration(
// // //         color: Colors.white,
// // //         borderRadius: BorderRadius.circular(16),
// // //         boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15)],
// // //       ),
// // //       child: Column(
// // //         crossAxisAlignment: CrossAxisAlignment.start,
// // //         children: [
// // //           Row(
// // //             children: [
// // //               const CircleAvatar(
// // //                   backgroundColor: AppTheme.primary,
// // //                   child: Icon(Icons.business, color: Colors.white)
// // //               ),
// // //               const SizedBox(width: 12),
// // //               Expanded(
// // //                 child: Column(
// // //                   crossAxisAlignment: CrossAxisAlignment.start,
// // //                   children: [
// // //                     Text(customer['full_name'] ?? "Client", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
// // //                     Text(DateFormat('MMMM dd, yyyy').format(date), style: const TextStyle(color: Colors.grey, fontSize: 12)),
// // //                   ],
// // //                 ),
// // //               ),
// // //             ],
// // //           ),
// // //           if (_report!['notes'] != null && _report!['notes'].toString().isNotEmpty) ...[
// // //             const Divider(height: 30),
// // //             const Text("GENERAL NOTES", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
// // //             const SizedBox(height: 4),
// // //             Text(_report!['notes'], style: const TextStyle(fontSize: 14)),
// // //           ]
// // //         ],
// // //       ),
// // //     );
// // //   }
// // //
// // //   Widget _buildFridgeDetailCard(Map<String, dynamic> fridge) {
// // //     final seals = fridge['seals'] as List;
// // //
// // //     return Container(
// // //       margin: const EdgeInsets.only(bottom: 20),
// // //       decoration: BoxDecoration(
// // //         color: Colors.white,
// // //         borderRadius: BorderRadius.circular(16),
// // //         border: Border.all(color: Colors.grey[200]!),
// // //       ),
// // //       child: Column(
// // //         crossAxisAlignment: CrossAxisAlignment.start,
// // //         children: [
// // //           // Fridge Header Info
// // //           Container(
// // //             padding: const EdgeInsets.all(16),
// // //             decoration: BoxDecoration(
// // //               color: Colors.grey[50],
// // //               borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
// // //             ),
// // //             child: Row(
// // //               children: [
// // //                 // const Icon(Icons.kitchen, color: AppTheme.primary),
// // //                 ClipRRect(
// // //                   borderRadius: BorderRadius.circular(6),
// // //                   child: Image.asset(
// // //                     // Logic flag to load drawers overview if no explicit door quantities exist
// // //                     (fridge['drawer_count'] ?? 0) > 0 && (fridge['door_count'] ?? 0) == 0
// // //                         ? 'assets/images/drawer.jpeg'
// // //                         : 'assets/images/door.jpeg',
// // //                     width: 32,
// // //                     height: 32,
// // //                     fit: BoxFit.cover,
// // //                   ),
// // //                 ),
// // //                 const SizedBox(width: 12),
// // //                 Expanded(
// // //                   child: Column(
// // //                     crossAxisAlignment: CrossAxisAlignment.start,
// // //                     children: [
// // //                       Text("${fridge['manufacturer']} - ${fridge['model_no']}",
// // //                           style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
// // //                       Text("Area: ${fridge['area'] ?? 'N/A'} | S/N: ${fridge['serial_no'] ?? 'N/A'}",
// // //                           style: const TextStyle(fontSize: 12, color: Colors.grey)),
// // //                     ],
// // //                   ),
// // //                 ),
// // //               ],
// // //             ),
// // //           ),
// // //
// // //           // Data Plate Image Logic
// // //           Padding(
// // //             padding: const EdgeInsets.all(16),
// // //             child: Column(
// // //               crossAxisAlignment: CrossAxisAlignment.start,
// // //               children: [
// // //                 const Text("DATA PLATE PHOTO", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
// // //                 const SizedBox(height: 8),
// // //                 fridge['data_plate_url'] != null
// // //                     ? // --- UPDATED: Using the common ImagePreviewer component ---
// // //                 ImagePreviewer(
// // //                   url: fridge['data_plate_url'], // Passes the network URL from your fridge data
// // //                   height: 180,
// // //                   width: double.infinity,
// // //                   fit: BoxFit.fitHeight,
// // //                   borderRadius: BorderRadius.circular(12),
// // //                 )
// // //                     : _buildImagePlaceholder("No data plate photo captured"),
// // //               ],
// // //             ),
// // //           ),
// // //
// // //           const Divider(height: 1),
// // //
// // //           // Seals Section
// // //           ...seals.map((seal) => _buildSealItemRow(seal)).toList(),
// // //           const SizedBox(height: 8),
// // //         ],
// // //       ),
// // //     );
// // //   }
// // //
// // //   // Widget _buildSealItemRow(Map<String, dynamic> seal) {
// // //   //   final List<dynamic> imageUrls = seal['image_urls'] ?? [];
// // //   //
// // //   //   return Column(
// // //   //     crossAxisAlignment: CrossAxisAlignment.start,
// // //   //     children: [
// // //   //       Padding(
// // //   //         padding: const EdgeInsets.all(16.0),
// // //   //         child: Column(
// // //   //           crossAxisAlignment: CrossAxisAlignment.start,
// // //   //           children: [
// // //   //             Row(
// // //   //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //   //               children: [
// // //   //                 Text(seal['item_name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primary)),
// // //   //                 // SEAL MODEL NUMBER HIGHLIGHT
// // //   //                 Container(
// // //   //                   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
// // //   //                   decoration: BoxDecoration(
// // //   //                     color: AppTheme.primary.withOpacity(0.1),
// // //   //                     borderRadius: BorderRadius.circular(8),
// // //   //                   ),
// // //   //                   child: Text(
// // //   //                     "Model: ${seal['manual_seal_name'] ?? 'Custom'}",
// // //   //                     style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primary),
// // //   //                   ),
// // //   //                 ),
// // //   //               ],
// // //   //             ),
// // //   //             const SizedBox(height: 12),
// // //   //
// // //   //             // Technical Specs
// // //   //             Row(
// // //   //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //   //               children: [
// // //   //                 _buildSpecItem("Type", seal['seal_type'] ?? 'N/A'),
// // //   //                 _buildSpecItem("Material", seal['material'] ?? 'N/A'),
// // //   //                 _buildSpecItem("Size (mm)", "${seal['inner_diameter']} x ${seal['outer_diameter']}"),
// // //   //               ],
// // //   //             ),
// // //   //
// // //   //             const SizedBox(height: 16),
// // //   //             const Text("SEAL PHOTOS", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
// // //   //             const SizedBox(height: 8),
// // //   //
// // //   //             // Seal Images Logic with Placeholder
// // //   //             imageUrls.isNotEmpty
// // //   //                 ? SizedBox(
// // //   //               height: 110,
// // //   //               child: ListView.builder(
// // //   //                 scrollDirection: Axis.horizontal,
// // //   //                 itemCount: imageUrls.length,
// // //   //                 itemBuilder: (context, index) => Padding(
// // //   //                   padding: const EdgeInsets.only(right: 10),
// // //   //                   child: ImagePreviewer(
// // //   //                     url: imageUrls[index],
// // //   //                     // FIX: Use 'imageUrls' instead of 'item.images'
// // //   //                     galleryItems: imageUrls,
// // //   //                     initialIndex: index,
// // //   //                     width: 110,
// // //   //                     height: 110,
// // //   //                     fit: BoxFit.cover,
// // //   //                     borderRadius: BorderRadius.circular(10),
// // //   //                   ),
// // //   //                 ),
// // //   //               ),
// // //   //             )
// // //   //                 : _buildImagePlaceholder("No seal photos available for this item", height: 60),
// // //   //           ],
// // //   //         ),
// // //   //       ),
// // //   //       const Divider(height: 1),
// // //   //     ],
// // //   //   );
// // //   // }
// // //
// // //
// // //
// // //   // Widget _buildSealItemRow(Map<String, dynamic> seal) {
// // //   //   final List<dynamic> imageUrls = seal['image_urls'] ?? [];
// // //   //   final bool needsReplacement = seal['need_replacement'] ?? false;
// // //   //   final int wear = (seal['wear_percentage'] ?? 0).toInt();
// // //   //
// // //   //   // Determine Wear Color for the view page
// // //   //   Color wearColor;
// // //   //   if (wear < 30) wearColor = AppTheme.success;
// // //   //   else if (wear < 70) wearColor = AppTheme.tertiary;
// // //   //   else wearColor = AppTheme.error;
// // //   //
// // //   //   return Column(
// // //   //     crossAxisAlignment: CrossAxisAlignment.start,
// // //   //     children: [
// // //   //       // Urgent Replacement Banner (Only shows if true)
// // //   //       if (needsReplacement)
// // //   //         Container(
// // //   //           width: double.infinity,
// // //   //           color: AppTheme.error.withOpacity(0.1),
// // //   //           padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
// // //   //           child: Row(
// // //   //             children: [
// // //   //               const Icon(Icons.report_problem_rounded, color: AppTheme.error, size: 14),
// // //   //               const SizedBox(width: 8),
// // //   //               const Text(
// // //   //                 "URGENT REPLACEMENT REQUIRED",
// // //   //                 style: TextStyle(color: AppTheme.error, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
// // //   //               ),
// // //   //             ],
// // //   //           ),
// // //   //         ),
// // //   //
// // //   //       Padding(
// // //   //         padding: const EdgeInsets.all(16.0),
// // //   //         child: Column(
// // //   //           crossAxisAlignment: CrossAxisAlignment.start,
// // //   //           children: [
// // //   //             Row(
// // //   //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //   //               children: [
// // //   //                 Text(seal['item_name'],
// // //   //                     style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primaryText)),
// // //   //                 Container(
// // //   //                   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
// // //   //                   decoration: BoxDecoration(
// // //   //                     color: AppTheme.primary.withOpacity(0.1),
// // //   //                     borderRadius: BorderRadius.circular(8),
// // //   //                   ),
// // //   //                   child: Text(
// // //   //                     seal['manual_seal_name'] ?? 'Custom Seal',
// // //   //                     style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primary),
// // //   //                   ),
// // //   //                 ),
// // //   //               ],
// // //   //             ),
// // //   //             const SizedBox(height: 16),
// // //   //
// // //   //             // Enhanced Data Grid for View Page
// // //   //             Row(
// // //   //               crossAxisAlignment: CrossAxisAlignment.start,
// // //   //               children: [
// // //   //                 Expanded(child: _buildSpecItem("Material", seal['material'] ?? 'N/A')),
// // //   //                 Expanded(child: _buildSpecItem("Type", seal['seal_type'] ?? 'N/A')),
// // //   //                 Expanded(child: _buildSpecItem("Thickness", "${seal['thickness'] ?? 0}mm")),
// // //   //               ],
// // //   //             ),
// // //   //             const SizedBox(height: 12),
// // //   //             Row(
// // //   //               crossAxisAlignment: CrossAxisAlignment.start,
// // //   //               children: [
// // //   //                 // --- SHOWING NEW DIMENSIONS ---
// // //   //                 Expanded(child: _buildSpecItem("Dimensions", "${seal['inner_diameter']} x ${seal['outer_diameter']} mm")),
// // //   //
// // //   //                 // --- SHOWING WEAR LEVEL ---
// // //   //                 Expanded(
// // //   //                   child: Column(
// // //   //                     crossAxisAlignment: CrossAxisAlignment.start,
// // //   //                     children: [
// // //   //                       const Text("Wear Level", style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w500)),
// // //   //                       Row(
// // //   //                         children: [
// // //   //                           Text("$wear%", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: wearColor)),
// // //   //                           const SizedBox(width: 4),
// // //   //                           Icon(Icons.circle, size: 8, color: wearColor),
// // //   //                         ],
// // //   //                       ),
// // //   //                     ],
// // //   //                   ),
// // //   //                 ),
// // //   //                 const Expanded(child: SizedBox()), // Spacer to keep 3 column look
// // //   //               ],
// // //   //             ),
// // //   //
// // //   //             const SizedBox(height: 20),
// // //   //             const Text("SEAL PHOTOS", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
// // //   //             const SizedBox(height: 8),
// // //   //
// // //   //             imageUrls.isNotEmpty
// // //   //                 ? SizedBox(
// // //   //               height: 110,
// // //   //               child: ListView.builder(
// // //   //                 scrollDirection: Axis.horizontal,
// // //   //                 itemCount: imageUrls.length,
// // //   //                 itemBuilder: (context, index) => Padding(
// // //   //                   padding: const EdgeInsets.only(right: 10),
// // //   //                   child: ImagePreviewer(
// // //   //                     url: imageUrls[index],
// // //   //                     galleryItems: imageUrls,
// // //   //                     initialIndex: index,
// // //   //                     width: 110,
// // //   //                     height: 110,
// // //   //                     fit: BoxFit.cover,
// // //   //                     borderRadius: BorderRadius.circular(10),
// // //   //                   ),
// // //   //                 ),
// // //   //               ),
// // //   //             )
// // //   //                 : _buildImagePlaceholder("No photos provided", height: 60),
// // //   //
// // //   //             // Item specific notes if they exist
// // //   //             if (seal['item_notes'] != null && seal['item_notes'].toString().isNotEmpty) ...[
// // //   //               const SizedBox(height: 16),
// // //   //               Container(
// // //   //                 width: double.infinity,
// // //   //                 padding: const EdgeInsets.all(12),
// // //   //                 decoration: BoxDecoration(
// // //   //                   color: Colors.grey[50],
// // //   //                   borderRadius: BorderRadius.circular(8),
// // //   //                   border: Border.all(color: Colors.grey[200]!),
// // //   //                 ),
// // //   //                 child: Text(
// // //   //                   "Note: ${seal['item_notes']}",
// // //   //                   style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.black87),
// // //   //                 ),
// // //   //               ),
// // //   //             ],
// // //   //           ],
// // //   //         ),
// // //   //       ),
// // //   //       const Divider(height: 1),
// // //   //     ],
// // //   //   );
// // //   // }
// // //
// // //
// // //
// // //   Widget _buildSealItemRow(Map<String, dynamic> seal) {
// // //     final List<dynamic> imageUrls = seal['image_urls'] ?? [];
// // //     final bool needsReplacement = seal['need_replacement'] ?? false;
// // //     final int wear = (seal['wear_percentage'] ?? 0).toInt();
// // //
// // //     // Color logic
// // //     Color wearColor;
// // //     if (wear < 30) wearColor = AppTheme.success;
// // //     else if (wear < 70) wearColor = AppTheme.tertiary;
// // //     else wearColor = AppTheme.error;
// // //
// // //     return Container(
// // //       // HIGHLIGHT: Entire container gets a red border if urgent
// // //       margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
// // //       decoration: BoxDecoration(
// // //         color: Colors.white,
// // //         borderRadius: BorderRadius.circular(12),
// // //         border: needsReplacement
// // //             ? Border.all(color: AppTheme.error, width: 2)
// // //             : Border.all(color: Colors.transparent),
// // //       ),
// // //       child: Column(
// // //         crossAxisAlignment: CrossAxisAlignment.start,
// // //         children: [
// // //           // 1. URGENT TOP BANNER
// // //           if (needsReplacement)
// // //             Container(
// // //               width: double.infinity,
// // //               decoration: const BoxDecoration(
// // //                 color: AppTheme.error,
// // //                 borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
// // //               ),
// // //               padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
// // //               child: const Row(
// // //                 children: [
// // //                   Icon(Icons.warning_rounded, color: Colors.white, size: 16),
// // //                   SizedBox(width: 8),
// // //                   Text(
// // //                     "ACTION REQUIRED: URGENT REPLACEMENT",
// // //                     style: TextStyle(
// // //                         color: Colors.white,
// // //                         fontSize: 11,
// // //                         fontWeight: FontWeight.bold,
// // //                         letterSpacing: 1.0
// // //                     ),
// // //                   ),
// // //                 ],
// // //               ),
// // //             ),
// // //
// // //           Padding(
// // //             padding: const EdgeInsets.all(16.0),
// // //             child: Column(
// // //               crossAxisAlignment: CrossAxisAlignment.start,
// // //               children: [
// // //                 // 2. HEADER WITH ITEM NAME & BADGE
// // //                 Row(
// // //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //                   children: [
// // //
// // //                     Row(
// // //                       children: [
// // //                         ClipRRect(
// // //                           borderRadius: BorderRadius.circular(6),
// // //                           child: Image.asset(
// // //                             seal['item_name'].toString().toLowerCase().contains('drawer')
// // //                                 ? 'assets/images/drawer.jpeg'
// // //                                 : 'assets/images/door.jpeg',
// // //                             width: 36,
// // //                             height: 36,
// // //                             fit: BoxFit.cover,
// // //                           ),
// // //                         ),
// // //                         const SizedBox(width: 12),
// // //                         Column(
// // //                           crossAxisAlignment: CrossAxisAlignment.start,
// // //                           children: [
// // //                             Text(
// // //                                 seal['item_name'].toString().toUpperCase(),
// // //                                 style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 0.5)
// // //                             ),
// // //                             const SizedBox(height: 2),
// // //                             Text(
// // //                               "Model: ${seal['manual_seal_name'] ?? 'Custom'}",
// // //                               style: TextStyle(fontSize: 12, color: AppTheme.secondaryText, fontWeight: FontWeight.w500),
// // //                             ),
// // //                           ],
// // //                         ),
// // //                       ],
// // //                     ),
// // //
// // //                     // 3. WEAR PERCENTAGE CHIP
// // //                     Container(
// // //                       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
// // //                       decoration: BoxDecoration(
// // //                         color: wearColor.withOpacity(0.1),
// // //                         borderRadius: BorderRadius.circular(20),
// // //                         border: Border.all(color: wearColor.withOpacity(0.3)),
// // //                       ),
// // //                       child: Row(
// // //                         children: [
// // //                           Icon(Icons.speed_rounded, size: 14, color: wearColor),
// // //                           const SizedBox(width: 4),
// // //                           Text(
// // //                             "$wear% WEAR",
// // //                             style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: wearColor),
// // //                           ),
// // //                         ],
// // //                       ),
// // //                     ),
// // //                   ],
// // //                 ),
// // //
// // //                 const Padding(
// // //                   padding: EdgeInsets.symmetric(vertical: 12),
// // //                   child: Divider(height: 1),
// // //                 ),
// // //
// // //                 // 4. TECHNICAL SPECS GRID
// // //                 Row(
// // //                   children: [
// // //                     Expanded(child: _buildSpecItem("HEIGHT", "${seal['height_mm'] ?? seal['doorHeight'] ?? 0} mm")),
// // //                     Expanded(child: _buildSpecItem("WIDTH", "${seal['width_mm'] ?? seal['doorWidth'] ?? 0} mm")),
// // //                     Expanded(child: _buildSpecItem("THICKNESS", "${seal['thickness'] ?? 0} mm")),
// // //                   ],
// // //                 ),
// // //                 const SizedBox(height: 16),
// // //                 Row(
// // //                   children: [
// // //                     Expanded(child: _buildSpecItem("MATERIAL", seal['material'] ?? 'N/A')),
// // //                     Expanded(child: _buildSpecItem("TYPE", seal['seal_type'] ?? 'N/A')),
// // //                     const Expanded(child: SizedBox()),
// // //                   ],
// // //                 ),
// // //
// // //                 const SizedBox(height: 20),
// // //                 const Text("CAPTURED PHOTOS", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
// // //                 const SizedBox(height: 8),
// // //
// // //                 // 5. IMAGE GALLERY
// // //                 imageUrls.isNotEmpty
// // //                     ? SizedBox(
// // //                   height: 90,
// // //                   child: ListView.builder(
// // //                     scrollDirection: Axis.horizontal,
// // //                     itemCount: imageUrls.length,
// // //                     itemBuilder: (context, index) => Padding(
// // //                       padding: const EdgeInsets.only(right: 10),
// // //                       child: ImagePreviewer(
// // //                         url: imageUrls[index],
// // //                         galleryItems: imageUrls,
// // //                         initialIndex: index,
// // //                         width: 90,
// // //                         height: 90,
// // //                         fit: BoxFit.cover,
// // //                         borderRadius: BorderRadius.circular(8),
// // //                       ),
// // //                     ),
// // //                   ),
// // //                 )
// // //                     : _buildImagePlaceholder("No photos provided", height: 60),
// // //
// // //                 // 6. ENGINEER NOTES
// // //                 if (seal['item_notes'] != null && seal['item_notes'].toString().isNotEmpty) ...[
// // //                   const SizedBox(height: 16),
// // //                   Container(
// // //                     width: double.infinity,
// // //                     padding: const EdgeInsets.all(12),
// // //                     decoration: BoxDecoration(
// // //                       color: Colors.grey[50],
// // //                       borderRadius: BorderRadius.circular(8),
// // //                     ),
// // //                     child: Text(
// // //                       "Note: ${seal['item_notes']}",
// // //                       style: const TextStyle(fontSize: 12, color: Colors.black87),
// // //                     ),
// // //                   ),
// // //                 ],
// // //               ],
// // //             ),
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //   }
// // //
// // //   Widget _buildSpecItem(String label, String value) {
// // //     return Column(
// // //       crossAxisAlignment: CrossAxisAlignment.start,
// // //       children: [
// // //         Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w500)),
// // //         Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
// // //       ],
// // //     );
// // //   }
// // //
// // //   Widget _buildImagePlaceholder(String message, {double height = 100, double width = double.infinity}) {
// // //     return Container(
// // //       height: height,
// // //       width: width,
// // //       decoration: BoxDecoration(
// // //         color: Colors.grey[100],
// // //         borderRadius: BorderRadius.circular(12),
// // //         border: Border.all(color: Colors.grey[200]!),
// // //       ),
// // //       child: Column(
// // //         mainAxisAlignment: MainAxisAlignment.center,
// // //         children: [
// // //           Icon(Icons.image_not_supported_outlined, color: Colors.grey[400], size: 24),
// // //           const SizedBox(height: 4),
// // //           Text(
// // //             message,
// // //             textAlign: TextAlign.center,
// // //             style: TextStyle(color: Colors.grey[500], fontSize: 11, fontStyle: FontStyle.italic),
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //   }
// // //
// // //   void _showFullScreenImage(String url) {
// // //     showDialog(
// // //       context: context,
// // //       builder: (context) => Dialog(
// // //         backgroundColor: Colors.transparent,
// // //         insetPadding: EdgeInsets.zero,
// // //         child: Stack(
// // //           alignment: Alignment.topRight,
// // //           children: [
// // //             InteractiveViewer(child: Image.network(url, fit: BoxFit.contain, width: double.infinity, height: double.infinity)),
// // //             IconButton(icon: const Icon(Icons.close, color: Colors.white, size: 30), onPressed: () => Navigator.pop(context)),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }
// //
// //
// //
// //
// // import 'dart:convert';
// // import 'dart:developer';
// // import 'dart:io';
// //
// // import 'package:flutter/material.dart';
// // import 'package:shared_preferences/shared_preferences.dart';
// // import 'package:supabase_flutter/supabase_flutter.dart';
// // import 'package:intl/intl.dart';
// // import '../../../theme.dart';
// // import '../../components/image_previewer.dart';
// //
// // class ViewReportPage extends StatefulWidget {
// //   final String reportId;
// //   const ViewReportPage({super.key, required this.reportId});
// //
// //   @override
// //   State<ViewReportPage> createState() => _ViewReportPageState();
// // }
// //
// // class _ViewReportPageState extends State<ViewReportPage> {
// //   final SupabaseClient _supabase = Supabase.instance.client;
// //   bool _isLoading = true;
// //   Map<String, dynamic>? _report;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _fetchReportDetails();
// //   }
// //
// //   // Future<void> _fetchReportDetails() async {
// //   //   try {
// //   //     // Fetches Report -> Customer -> Fridge Assets -> Individual Seal Items
// //   //     final data = await _supabase.from('asset_reports').select('''
// //   //       *,
// //   //       customer:user_profiles!customer_id(full_name, email),
// //   //       fridges:assets_report_fridge(
// //   //         *,
// //   //         seals:report_asset_items(*)
// //   //       )
// //   //     ''').eq('id', widget.reportId).single();
// //   //
// //   //     setState(() {
// //   //       _report = data;
// //   //       _isLoading = false;
// //   //     });
// //   //   } catch (e) {
// //   //     debugPrint("Error fetching report: $e");
// //   //     if (mounted) setState(() => _isLoading = false);
// //   //   }
// //   // }
// //
// //
// //   // Inside _ViewReportPageState in view_report_page.dart
// //
// //   Future<void> _fetchReportDetails() async {
// //     try {
// //       final prefs = await SharedPreferences.getInstance();
// //       final String cleanSearchId = widget.reportId.toString().trim().toLowerCase();
// //
// //       // 1. Check local offline queue (saved as a String List)
// //       final List<String> currentQueue = prefs.getStringList('offline_reports_queue') ?? [];
// //       for (String itemJson in currentQueue) {
// //         try {
// //           final Map<String, dynamic> rawReport = jsonDecode(itemJson);
// //           final String currentId = (rawReport['id'] ?? '').toString().trim().toLowerCase();
// //
// //           if (currentId == cleanSearchId) {
// //             setState(() {
// //               _report = rawReport;
// //               _isLoading = false;
// //             });
// //             return;
// //           }
// //         } catch (_) {}
// //       }
// //
// //       // 2. Check local server cache
// //       final String? cachedData = prefs.getString('cached_my_reports');
// //       if (cachedData != null) {
// //         final List<dynamic> allReports = jsonDecode(cachedData);
// //         for (var cachedItem in allReports) {
// //           final Map<String, dynamic> rawReport = Map<String, dynamic>.from(cachedItem);
// //           final String currentId = (rawReport['id'] ?? '').toString().trim().toLowerCase();
// //
// //           if (currentId == cleanSearchId) {
// //             setState(() {
// //               _report = rawReport;
// //               _isLoading = false;
// //             });
// //             return;
// //           }
// //         }
// //       }
// //
// //         final onlineData = await _supabase.from('asset_reports').select('''
// //           *,
// //           customer:user_profiles!customer_id(full_name, email),
// //           fridges:assets_report_fridge(
// //             *,
// //             seals:asset_report_fridge_items(*),
// //             fridge:fridges(
// //               *,
// //               components:fridge_components(*)
// //             )
// //           )
// //         ''').eq('id', widget.reportId).single();
// //
// //         log(
// //             '🎯 SUCCESS: Live payload fetched from [Supabase Cloud Server]!',
// //             name: 'ViewReportPage.fetch.online'
// //         );
// //         log('📦 Live Payload Object Data Structure: $onlineData', name: 'ViewReportPage.fetch.payload');
// //
// //       // 3. Fallback: Online query to Supabase
// //       // final onlineData = await _supabase.from('asset_reports').select('''
// //       //   *,
// //       //   customer:user_profiles!customer_id(full_name, email),
// //       //   fridges:assets_report_fridge(*, seals:asset_report_fridge_items(*))
// //       // ''').eq('id', widget.reportId).single();
// //
// //       setState(() {
// //         _report = onlineData;
// //         _isLoading = false;
// //       });
// //     } catch (e) {
// //       debugPrint("Error fetching details: $e");
// //       if (mounted) setState(() => _isLoading = false);
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
// //     if (_report == null) return const Scaffold(body: Center(child: Text("Report data not found")));
// //
// //     // final fridges = _report!['fridges'] as List;
// //
// //     // Map list variables across online ('fridges') and local outbox ('assets') schemas
// //     final fridges = _report!['fridges'] ?? _report!['assets'] ?? [];
// //
// //     return Scaffold(
// //       backgroundColor: const Color(0xFFF8F9FA),
// //       appBar: AppBar(
// //         title: Text(_report!['report_title'] ?? "Report Summary"),
// //         elevation: 0,
// //       ),
// //       body: SingleChildScrollView(
// //         padding: const EdgeInsets.all(16),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             _buildReportHeader(),
// //             const SizedBox(height: 24),
// //             const Text("ASSET DETAILS",
// //                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blueGrey, letterSpacing: 1.1)),
// //             const SizedBox(height: 12),
// //             ...fridges.map((f) => _buildFridgeDetailCard(f)).toList(),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   // Widget _buildReportHeader() {
// //   //   final customer = _report!['customer'];
// //   //   final date = DateTime.parse(_report!['report_date']).toLocal();
// //   //
// //   //   return Container(
// //   //     padding: const EdgeInsets.all(20),
// //   //     decoration: BoxDecoration(
// //   //       color: Colors.white,
// //   //       borderRadius: BorderRadius.circular(16),
// //   //       boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15)],
// //   //     ),
// //   //     child: Column(
// //   //       crossAxisAlignment: CrossAxisAlignment.start,
// //   //       children: [
// //   //         Row(
// //   //           children: [
// //   //             const CircleAvatar(
// //   //                 backgroundColor: AppTheme.primary,
// //   //                 child: Icon(Icons.business, color: Colors.white)
// //   //             ),
// //   //             const SizedBox(width: 12),
// //   //             Expanded(
// //   //               child: Column(
// //   //                 crossAxisAlignment: CrossAxisAlignment.start,
// //   //                 children: [
// //   //                   Text(customer['full_name'] ?? "Client", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
// //   //                   Text(DateFormat('MMMM dd, yyyy').format(date), style: const TextStyle(color: Colors.grey, fontSize: 12)),
// //   //                 ],
// //   //               ),
// //   //             ),
// //   //           ],
// //   //         ),
// //   //         if (_report!['notes'] != null && _report!['notes'].toString().isNotEmpty) ...[
// //   //           const Divider(height: 30),
// //   //           const Text("GENERAL NOTES", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
// //   //           const SizedBox(height: 4),
// //   //           Text(_report!['notes'], style: const TextStyle(fontSize: 14)),
// //   //         ]
// //   //       ],
// //   //     ),
// //   //   );
// //   // }
// //
// //   Widget _buildReportHeader() {
// //     final customer = _report!['customer'];
// //     String displayCustomerName = "Client";
// //
// //     // ✅ FIXED: Fallback to cross-reference the local customers catalog if 'customer' map is missing offline
// //     if (customer != null && customer is Map) {
// //       displayCustomerName = customer['full_name'] ?? "Client";
// //     } else {
// //       // Direct offline lookups inside the local cached customer catalog files
// //       try {
// //         final String? localCustJson = SharedPreferences.getInstance()
// //             .then((prefs) => prefs.getString('local_customers')) as String?;
// //         if (localCustJson != null) {
// //           final List<dynamic> localCustomersList = jsonDecode(localCustJson);
// //           final match = localCustomersList.where(
// //                   (c) => c['id'].toString() == _report!['customer_id'].toString()
// //           );
// //           if (match.isNotEmpty) {
// //             displayCustomerName = match.first['full_name'] ?? "Client";
// //           }
// //         }
// //       } catch (_) {
// //         displayCustomerName = "Offline Pending Client";
// //       }
// //     }
// //
// //     // Safely fallback if 'report_date' field key name doesn't exist on local model structures
// //     final String dateString = _report!['report_date'] ?? _report!['queued_at'] ?? DateTime.now().toIso8601String();
// //     final date = DateTime.parse(dateString).toLocal();
// //
// //     return Container(
// //       padding: const EdgeInsets.all(20),
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(16),
// //         boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15)],
// //       ),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           Row(
// //             children: [
// //               const CircleAvatar(
// //                   backgroundColor: AppTheme.primary,
// //                   child: Icon(Icons.business, color: Colors.white)
// //               ),
// //               const SizedBox(width: 12),
// //               Expanded(
// //                 child: Column(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     Text(displayCustomerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
// //                     Text(DateFormat('MMMM dd, yyyy').format(date), style: const TextStyle(color: Colors.grey, fontSize: 12)),
// //                   ],
// //                 ),
// //               ),
// //             ],
// //           ),
// //           if (_report!['notes'] != null && _report!['notes'].toString().isNotEmpty) ...[
// //             const Divider(height: 30),
// //             const Text("GENERAL NOTES", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
// //             const SizedBox(height: 4),
// //             Text(_report!['notes'], style: const TextStyle(fontSize: 14)),
// //           ]
// //         ],
// //       ),
// //     );
// //   }
// //
// //   // Widget _buildFridgeDetailCard(Map<String, dynamic> fridge) {
// //   //   // final seals = fridge['seals'] as List;
// //   //
// //   //   // Map arrays across online ('seals') and local outbox ('individualSeals') keys
// //   //   final seals = fridge['seals'] ?? fridge['individualSeals'] ?? [];
// //   //
// //   //
// //   //
// //   //   return Container(
// //   //     margin: const EdgeInsets.only(bottom: 20),
// //   //     decoration: BoxDecoration(
// //   //       color: Colors.white,
// //   //       borderRadius: BorderRadius.circular(16),
// //   //       border: Border.all(color: Colors.grey[200]!),
// //   //     ),
// //   //     child: Column(
// //   //       crossAxisAlignment: CrossAxisAlignment.start,
// //   //       children: [
// //   //         // Fridge Header Info
// //   //         Container(
// //   //           padding: const EdgeInsets.all(16),
// //   //           decoration: BoxDecoration(
// //   //             color: Colors.grey[50],
// //   //             borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
// //   //           ),
// //   //           child: Row(
// //   //             children: [
// //   //               // const Icon(Icons.kitchen, color: AppTheme.primary),
// //   //               ClipRRect(
// //   //                 borderRadius: BorderRadius.circular(6),
// //   //                 child: Image.asset(
// //   //                   // Logic flag to load drawers overview if no explicit door quantities exist
// //   //                   (fridge['drawer_count'] ?? 0) > 0 && (fridge['door_count'] ?? 0) == 0
// //   //                       ? 'assets/images/drawer.jpeg'
// //   //                       : 'assets/images/door.jpeg',
// //   //                   width: 32,
// //   //                   height: 32,
// //   //                   fit: BoxFit.cover,
// //   //                 ),
// //   //               ),
// //   //               const SizedBox(width: 12),
// //   //               Expanded(
// //   //                 child: Column(
// //   //                   crossAxisAlignment: CrossAxisAlignment.start,
// //   //                   children: [
// //   //                     Text("${fridge['manufacturer']} - ${fridge['model_no']}",
// //   //                         style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
// //   //                     Text("Area: ${fridge['area'] ?? 'N/A'} | S/N: ${fridge['serial_no'] ?? 'N/A'}",
// //   //                         style: const TextStyle(fontSize: 12, color: Colors.grey)),
// //   //                   ],
// //   //                 ),
// //   //               ),
// //   //             ],
// //   //           ),
// //   //         ),
// //   //
// //   //         // Data Plate Image Logic
// //   //         Padding(
// //   //           padding: const EdgeInsets.all(16),
// //   //           child: Column(
// //   //             crossAxisAlignment: CrossAxisAlignment.start,
// //   //             children: [
// //   //               const Text("DATA PLATE PHOTO", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
// //   //               const SizedBox(height: 8),
// //   //               fridge['data_plate_url'] != null
// //   //                   ? // --- UPDATED: Using the common ImagePreviewer component ---
// //   //               ImagePreviewer(
// //   //                 url: fridge['data_plate_url'], // Passes the network URL from your fridge data
// //   //                 height: 180,
// //   //                 width: double.infinity,
// //   //                 fit: BoxFit.fitHeight,
// //   //                 borderRadius: BorderRadius.circular(12),
// //   //               )
// //   //                   : _buildImagePlaceholder("No data plate photo captured"),
// //   //             ],
// //   //           ),
// //   //         ),
// //   //
// //   //         const Divider(height: 1),
// //   //
// //   //         // Seals Section
// //   //         ...seals.map((seal) => _buildSealItemRow(seal)).toList(),
// //   //         const SizedBox(height: 8),
// //   //       ],
// //   //     ),
// //   //   );
// //   // }
// //
// //
// //   Widget _buildFridgeDetailCard(Map<String, dynamic> fridge) {
// //     // Map arrays across online ('seals') and local outbox ('individualSeals') keys safely
// //     final seals = fridge['seals'] ?? fridge['individualSeals'] ?? [];
// //
// //     // Safely parse counts, supporting potential naming schema differences
// //     final int drawerCount = fridge['drawer_count'] ?? fridge['drawerCount'] ?? 0;
// //     final int doorCount = fridge['door_count'] ?? fridge['doorCount'] ?? 0;
// //
// //     // Extract paths and determine if it's a remote network path or a local file system path
// //     final String? dataPlatePath = fridge['data_plate_url'] ?? fridge['dataPlateImagePath'];
// //     final bool isNetworkImage = dataPlatePath != null && (dataPlatePath.startsWith('http://') || dataPlatePath.startsWith('https://'));
// //
// //     return Container(
// //       margin: const EdgeInsets.only(bottom: 20),
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(16),
// //         border: Border.all(color: Colors.grey[200]!),
// //       ),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           // Fridge Header Info
// //           Container(
// //             padding: const EdgeInsets.all(16),
// //             decoration: BoxDecoration(
// //               color: Colors.grey[50],
// //               borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
// //             ),
// //             child: Row(
// //               children: [
// //                 ClipRRect(
// //                   borderRadius: BorderRadius.circular(6),
// //                   child: Image.asset(
// //                     drawerCount > 0 && doorCount == 0
// //                         ? 'assets/images/drawer.jpeg'
// //                         : 'assets/images/door.jpeg',
// //                     width: 32,
// //                     height: 32,
// //                     fit: BoxFit.cover,
// //                   ),
// //                 ),
// //                 const SizedBox(width: 12),
// //                 Expanded(
// //                   child: Column(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       Text("${fridge['manufacturer'] ?? 'Unknown'} - ${fridge['model_no'] ?? fridge['modelNo'] ?? 'N/A'}",
// //                           style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
// //                       Text("Area: ${fridge['area'] ?? 'N/A'} | S/N: ${fridge['serial_no'] ?? fridge['serialNo'] ?? 'N/A'}",
// //                           style: const TextStyle(fontSize: 12, color: Colors.grey)),
// //                     ],
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //
// //           // Data Plate Image Component Wrapper Area
// //           Padding(
// //             padding: const EdgeInsets.all(16),
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 const Text("DATA PLATE PHOTO", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
// //                 const SizedBox(height: 8),
// //
// //                 // ✅ FIXED: Evaluates and handles local Files vs cloud URLs dynamically inline
// //                 dataPlatePath != null
// //                     ? (isNetworkImage
// //                     ? ImagePreviewer(
// //                   url: dataPlatePath,
// //                   height: 180,
// //                   width: double.infinity,
// //                   fit: BoxFit.cover,
// //                   borderRadius: BorderRadius.circular(12),
// //                 )
// //                     : ClipRRect(
// //                   borderRadius: BorderRadius.circular(12),
// //                   child: Image.file(
// //                     File(dataPlatePath),
// //                     height: 180,
// //                     width: double.infinity,
// //                     fit: BoxFit.cover,
// //                   ),
// //                 ))
// //                     : _buildImagePlaceholder("No data plate photo captured"),
// //               ],
// //             ),
// //           ),
// //
// //           const Divider(height: 1),
// //
// //           // Seals Section Map Loop
// //           ...seals.map((seal) => _buildSealItemRow(Map<String, dynamic>.from(seal))).toList(),
// //           const SizedBox(height: 8),
// //         ],
// //       ),
// //     );
// //   }
// //
// //
// //   // Widget _buildSealItemRow(Map<String, dynamic> seal) {
// //   //   final List<dynamic> imageUrls = seal['image_urls'] ?? [];
// //   //
// //   //   return Column(
// //   //     crossAxisAlignment: CrossAxisAlignment.start,
// //   //     children: [
// //   //       Padding(
// //   //         padding: const EdgeInsets.all(16.0),
// //   //         child: Column(
// //   //           crossAxisAlignment: CrossAxisAlignment.start,
// //   //           children: [
// //   //             Row(
// //   //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //   //               children: [
// //   //                 Text(seal['item_name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primary)),
// //   //                 // SEAL MODEL NUMBER HIGHLIGHT
// //   //                 Container(
// //   //                   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
// //   //                   decoration: BoxDecoration(
// //   //                     color: AppTheme.primary.withOpacity(0.1),
// //   //                     borderRadius: BorderRadius.circular(8),
// //   //                   ),
// //   //                   child: Text(
// //   //                     "Model: ${seal['manual_seal_name'] ?? 'Custom'}",
// //   //                     style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primary),
// //   //                   ),
// //   //                 ),
// //   //               ],
// //   //             ),
// //   //             const SizedBox(height: 12),
// //   //
// //   //             // Technical Specs
// //   //             Row(
// //   //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //   //               children: [
// //   //                 _buildSpecItem("Type", seal['seal_type'] ?? 'N/A'),
// //   //                 _buildSpecItem("Material", seal['material'] ?? 'N/A'),
// //   //                 _buildSpecItem("Size (mm)", "${seal['inner_diameter']} x ${seal['outer_diameter']}"),
// //   //               ],
// //   //             ),
// //   //
// //   //             const SizedBox(height: 16),
// //   //             const Text("SEAL PHOTOS", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
// //   //             const SizedBox(height: 8),
// //   //
// //   //             // Seal Images Logic with Placeholder
// //   //             imageUrls.isNotEmpty
// //   //                 ? SizedBox(
// //   //               height: 110,
// //   //               child: ListView.builder(
// //   //                 scrollDirection: Axis.horizontal,
// //   //                 itemCount: imageUrls.length,
// //   //                 itemBuilder: (context, index) => Padding(
// //   //                   padding: const EdgeInsets.only(right: 10),
// //   //                   child: ImagePreviewer(
// //   //                     url: imageUrls[index],
// //   //                     // FIX: Use 'imageUrls' instead of 'item.images'
// //   //                     galleryItems: imageUrls,
// //   //                     initialIndex: index,
// //   //                     width: 110,
// //   //                     height: 110,
// //   //                     fit: BoxFit.cover,
// //   //                     borderRadius: BorderRadius.circular(10),
// //   //                   ),
// //   //                 ),
// //   //               ),
// //   //             )
// //   //                 : _buildImagePlaceholder("No seal photos available for this item", height: 60),
// //   //           ],
// //   //         ),
// //   //       ),
// //   //       const Divider(height: 1),
// //   //     ],
// //   //   );
// //   // }
// //
// //
// //
// //   // Widget _buildSealItemRow(Map<String, dynamic> seal) {
// //   //   final List<dynamic> imageUrls = seal['image_urls'] ?? [];
// //   //   final bool needsReplacement = seal['need_replacement'] ?? false;
// //   //   final int wear = (seal['wear_percentage'] ?? 0).toInt();
// //   //
// //   //   // Determine Wear Color for the view page
// //   //   Color wearColor;
// //   //   if (wear < 30) wearColor = AppTheme.success;
// //   //   else if (wear < 70) wearColor = AppTheme.tertiary;
// //   //   else wearColor = AppTheme.error;
// //   //
// //   //   return Column(
// //   //     crossAxisAlignment: CrossAxisAlignment.start,
// //   //     children: [
// //   //       // Urgent Replacement Banner (Only shows if true)
// //   //       if (needsReplacement)
// //   //         Container(
// //   //           width: double.infinity,
// //   //           color: AppTheme.error.withOpacity(0.1),
// //   //           padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
// //   //           child: Row(
// //   //             children: [
// //   //               const Icon(Icons.report_problem_rounded, color: AppTheme.error, size: 14),
// //   //               const SizedBox(width: 8),
// //   //               const Text(
// //   //                 "URGENT REPLACEMENT REQUIRED",
// //   //                 style: TextStyle(color: AppTheme.error, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
// //   //               ),
// //   //             ],
// //   //           ),
// //   //         ),
// //   //
// //   //       Padding(
// //   //         padding: const EdgeInsets.all(16.0),
// //   //         child: Column(
// //   //           crossAxisAlignment: CrossAxisAlignment.start,
// //   //           children: [
// //   //             Row(
// //   //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //   //               children: [
// //   //                 Text(seal['item_name'],
// //   //                     style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primaryText)),
// //   //                 Container(
// //   //                   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
// //   //                   decoration: BoxDecoration(
// //   //                     color: AppTheme.primary.withOpacity(0.1),
// //   //                     borderRadius: BorderRadius.circular(8),
// //   //                   ),
// //   //                   child: Text(
// //   //                     seal['manual_seal_name'] ?? 'Custom Seal',
// //   //                     style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primary),
// //   //                   ),
// //   //                 ),
// //   //               ],
// //   //             ),
// //   //             const SizedBox(height: 16),
// //   //
// //   //             // Enhanced Data Grid for View Page
// //   //             Row(
// //   //               crossAxisAlignment: CrossAxisAlignment.start,
// //   //               children: [
// //   //                 Expanded(child: _buildSpecItem("Material", seal['material'] ?? 'N/A')),
// //   //                 Expanded(child: _buildSpecItem("Type", seal['seal_type'] ?? 'N/A')),
// //   //                 Expanded(child: _buildSpecItem("Thickness", "${seal['thickness'] ?? 0}mm")),
// //   //               ],
// //   //             ),
// //   //             const SizedBox(height: 12),
// //   //             Row(
// //   //               crossAxisAlignment: CrossAxisAlignment.start,
// //   //               children: [
// //   //                 // --- SHOWING NEW DIMENSIONS ---
// //   //                 Expanded(child: _buildSpecItem("Dimensions", "${seal['inner_diameter']} x ${seal['outer_diameter']} mm")),
// //   //
// //   //                 // --- SHOWING WEAR LEVEL ---
// //   //                 Expanded(
// //   //                   child: Column(
// //   //                     crossAxisAlignment: CrossAxisAlignment.start,
// //   //                     children: [
// //   //                       const Text("Wear Level", style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w500)),
// //   //                       Row(
// //   //                         children: [
// //   //                           Text("$wear%", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: wearColor)),
// //   //                           const SizedBox(width: 4),
// //   //                           Icon(Icons.circle, size: 8, color: wearColor),
// //   //                         ],
// //   //                       ),
// //   //                     ],
// //   //                   ),
// //   //                 ),
// //   //                 const Expanded(child: SizedBox()), // Spacer to keep 3 column look
// //   //               ],
// //   //             ),
// //   //
// //   //             const SizedBox(height: 20),
// //   //             const Text("SEAL PHOTOS", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
// //   //             const SizedBox(height: 8),
// //   //
// //   //             imageUrls.isNotEmpty
// //   //                 ? SizedBox(
// //   //               height: 110,
// //   //               child: ListView.builder(
// //   //                 scrollDirection: Axis.horizontal,
// //   //                 itemCount: imageUrls.length,
// //   //                 itemBuilder: (context, index) => Padding(
// //   //                   padding: const EdgeInsets.only(right: 10),
// //   //                   child: ImagePreviewer(
// //   //                     url: imageUrls[index],
// //   //                     galleryItems: imageUrls,
// //   //                     initialIndex: index,
// //   //                     width: 110,
// //   //                     height: 110,
// //   //                     fit: BoxFit.cover,
// //   //                     borderRadius: BorderRadius.circular(10),
// //   //                   ),
// //   //                 ),
// //   //               ),
// //   //             )
// //   //                 : _buildImagePlaceholder("No photos provided", height: 60),
// //   //
// //   //             // Item specific notes if they exist
// //   //             if (seal['item_notes'] != null && seal['item_notes'].toString().isNotEmpty) ...[
// //   //               const SizedBox(height: 16),
// //   //               Container(
// //   //                 width: double.infinity,
// //   //                 padding: const EdgeInsets.all(12),
// //   //                 decoration: BoxDecoration(
// //   //                   color: Colors.grey[50],
// //   //                   borderRadius: BorderRadius.circular(8),
// //   //                   border: Border.all(color: Colors.grey[200]!),
// //   //                 ),
// //   //                 child: Text(
// //   //                   "Note: ${seal['item_notes']}",
// //   //                   style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.black87),
// //   //                 ),
// //   //               ),
// //   //             ],
// //   //           ],
// //   //         ),
// //   //       ),
// //   //       const Divider(height: 1),
// //   //     ],
// //   //   );
// //   // }
// //
// //
// //   // Widget _buildSealItemRow(Map<String, dynamic> seal) {
// //   //   final List<dynamic> imageUrls = seal['image_urls'] ?? seal['imagePaths'] ?? [];
// //   //   final int wear = (seal['wear_percentage'] ?? seal['wearPercentage'] ?? 0).toInt();
// //   //
// //   //   // ✅ FIXES THE SUBTYPE CAST CRASH: Safely parses dynamic or String fields to Boolean
// //   //   final dynamic rawReplacementValue = seal['need_replacement'] ?? seal['needsUrgentReplacement'];
// //   //   bool needsReplacement = false;
// //   //   if (rawReplacementValue != null) {
// //   //     if (rawReplacementValue is bool) {
// //   //       needsReplacement = rawReplacementValue;
// //   //     } else if (rawReplacementValue is String) {
// //   //       final sanitizedStr = rawReplacementValue.trim().toLowerCase();
// //   //       needsReplacement =
// //   //       (sanitizedStr == 'true' || sanitizedStr == 't' || sanitizedStr == '1');
// //   //     }
// //   //   }
// //   //
// //   //   // Color logic
// //   //   Color wearColor;
// //   //   if (wear < 30) wearColor = AppTheme.success;
// //   //   else if (wear < 70) wearColor = AppTheme.tertiary;
// //   //   else wearColor = AppTheme.error;
// //   //
// //   //   return Container(
// //   //     // HIGHLIGHT: Entire container gets a red border if urgent
// //   //     margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
// //   //     decoration: BoxDecoration(
// //   //       color: Colors.white,
// //   //       borderRadius: BorderRadius.circular(12),
// //   //       border: needsReplacement
// //   //           ? Border.all(color: AppTheme.error, width: 2)
// //   //           : Border.all(color: Colors.transparent),
// //   //     ),
// //   //     child: Column(
// //   //       crossAxisAlignment: CrossAxisAlignment.start,
// //   //       children: [
// //   //         // 1. URGENT TOP BANNER
// //   //         if (needsReplacement)
// //   //           Container(
// //   //             width: double.infinity,
// //   //             decoration: const BoxDecoration(
// //   //               color: AppTheme.error,
// //   //               borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
// //   //             ),
// //   //             padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
// //   //             child: const Row(
// //   //               children: [
// //   //                 Icon(Icons.warning_rounded, color: Colors.white, size: 16),
// //   //                 SizedBox(width: 8),
// //   //                 Text(
// //   //                   "ACTION REQUIRED: URGENT REPLACEMENT",
// //   //                   style: TextStyle(
// //   //                       color: Colors.white,
// //   //                       fontSize: 11,
// //   //                       fontWeight: FontWeight.bold,
// //   //                       letterSpacing: 1.0
// //   //                   ),
// //   //                 ),
// //   //               ],
// //   //             ),
// //   //           ),
// //   //
// //   //         Padding(
// //   //           padding: const EdgeInsets.all(16.0),
// //   //           child: Column(
// //   //             crossAxisAlignment: CrossAxisAlignment.start,
// //   //             children: [
// //   //               // 2. HEADER WITH ITEM NAME & BADGE
// //   //               Row(
// //   //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //   //                 children: [
// //   //
// //   //                   Row(
// //   //                     children: [
// //   //                       ClipRRect(
// //   //                         borderRadius: BorderRadius.circular(6),
// //   //                         child: Image.asset(
// //   //                           seal['item_name'].toString().toLowerCase().contains('drawer')
// //   //                               ? 'assets/images/drawer.jpeg'
// //   //                               : 'assets/images/door.jpeg',
// //   //                           width: 36,
// //   //                           height: 36,
// //   //                           fit: BoxFit.cover,
// //   //                         ),
// //   //                       ),
// //   //                       const SizedBox(width: 12),
// //   //                       Column(
// //   //                         crossAxisAlignment: CrossAxisAlignment.start,
// //   //                         children: [
// //   //                           Text(
// //   //                               seal['item_name'].toString().toUpperCase(),
// //   //                               style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 0.5)
// //   //                           ),
// //   //                           const SizedBox(height: 2),
// //   //                           Text(
// //   //                             "Model: ${seal['manual_seal_name'] ?? 'Custom'}",
// //   //                             style: TextStyle(fontSize: 12, color: AppTheme.secondaryText, fontWeight: FontWeight.w500),
// //   //                           ),
// //   //                         ],
// //   //                       ),
// //   //                     ],
// //   //                   ),
// //   //
// //   //                   // 3. WEAR PERCENTAGE CHIP
// //   //                   Container(
// //   //                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
// //   //                     decoration: BoxDecoration(
// //   //                       color: wearColor.withOpacity(0.1),
// //   //                       borderRadius: BorderRadius.circular(20),
// //   //                       border: Border.all(color: wearColor.withOpacity(0.3)),
// //   //                     ),
// //   //                     child: Row(
// //   //                       children: [
// //   //                         Icon(Icons.speed_rounded, size: 14, color: wearColor),
// //   //                         const SizedBox(width: 4),
// //   //                         Text(
// //   //                           "$wear% WEAR",
// //   //                           style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: wearColor),
// //   //                         ),
// //   //                       ],
// //   //                     ),
// //   //                   ),
// //   //                 ],
// //   //               ),
// //   //
// //   //               const Padding(
// //   //                 padding: EdgeInsets.symmetric(vertical: 12),
// //   //                 child: Divider(height: 1),
// //   //               ),
// //   //
// //   //               // 4. TECHNICAL SPECS GRID
// //   //               Row(
// //   //                 children: [
// //   //                   Expanded(child: _buildSpecItem("HEIGHT", "${seal['height_mm'] ?? seal['doorHeight'] ?? 0} mm")),
// //   //                   Expanded(child: _buildSpecItem("WIDTH", "${seal['width_mm'] ?? seal['doorWidth'] ?? 0} mm")),
// //   //                   Expanded(child: _buildSpecItem("THICKNESS", "${seal['thickness'] ?? 0} mm")),
// //   //                 ],
// //   //               ),
// //   //               const SizedBox(height: 16),
// //   //               Row(
// //   //                 children: [
// //   //                   Expanded(child: _buildSpecItem("MATERIAL", seal['material'] ?? 'N/A')),
// //   //                   Expanded(child: _buildSpecItem("TYPE", seal['seal_type'] ?? 'N/A')),
// //   //                   const Expanded(child: SizedBox()),
// //   //                 ],
// //   //               ),
// //   //
// //   //               const SizedBox(height: 20),
// //   //               const Text("CAPTURED PHOTOS", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
// //   //               const SizedBox(height: 8),
// //   //
// //   //               // 5. IMAGE GALLERY
// //   //               // imageUrls.isNotEmpty
// //   //               //     ? SizedBox(
// //   //               //   height: 90,
// //   //               //   child: ListView.builder(
// //   //               //     scrollDirection: Axis.horizontal,
// //   //               //     itemCount: imageUrls.length,
// //   //               //     itemBuilder: (context, index) => Padding(
// //   //               //       padding: const EdgeInsets.only(right: 10),
// //   //               //       child: ImagePreviewer(
// //   //               //         url: imageUrls[index],
// //   //               //         galleryItems: imageUrls,
// //   //               //         initialIndex: index,
// //   //               //         width: 90,
// //   //               //         height: 90,
// //   //               //         fit: BoxFit.cover,
// //   //               //         borderRadius: BorderRadius.circular(8),
// //   //               //       ),
// //   //               //     ),
// //   //               //   ),
// //   //               // )
// //   //               //     : _buildImagePlaceholder("No photos provided", height: 60),
// //   //
// //   //               imageUrls.isNotEmpty
// //   //                   ? SizedBox(
// //   //                 height: 90,
// //   //                 child: ListView.builder(
// //   //                   scrollDirection: Axis.horizontal,
// //   //                   itemCount: imageUrls.length,
// //   //                   itemBuilder: (context, index) {
// //   //                     final String path = imageUrls[index].toString();
// //   //                     // Check if it's a web URL or a local device storage path string
// //   //                     final bool isNetwork = path.startsWith('http://') || path.startsWith('https://');
// //   //
// //   //                     return Padding(
// //   //                       padding: const EdgeInsets.only(right: 10),
// //   //                       child: isNetwork
// //   //                           ? ImagePreviewer(
// //   //                         url: path,
// //   //                         galleryItems: imageUrls,
// //   //                         initialIndex: index,
// //   //                         width: 90,
// //   //                         height: 90,
// //   //                         fit: BoxFit.cover,
// //   //                         borderRadius: BorderRadius.circular(8),
// //   //                       )
// //   //                           : ClipRRect(
// //   //                         borderRadius: BorderRadius.circular(8),
// //   //                         child: Image.file(
// //   //                           File(path),
// //   //                           width: 90,
// //   //                           height: 90,
// //   //                           fit: BoxFit.cover,
// //   //                           errorBuilder: (context, error, stackTrace) =>
// //   //                               _buildImagePlaceholder("File error", height: 90, width: 90),
// //   //                         ),
// //   //                       ),
// //   //                     );
// //   //                   },
// //   //                 ),
// //   //               )
// //   //                   : _buildImagePlaceholder("No photos provided", height: 60),
// //   //
// //   //               // 6. ENGINEER NOTES
// //   //               if (seal['item_notes'] != null && seal['item_notes'].toString().isNotEmpty) ...[
// //   //                 const SizedBox(height: 16),
// //   //                 Container(
// //   //                   width: double.infinity,
// //   //                   padding: const EdgeInsets.all(12),
// //   //                   decoration: BoxDecoration(
// //   //                     color: Colors.grey[50],
// //   //                     borderRadius: BorderRadius.circular(8),
// //   //                   ),
// //   //                   child: Text(
// //   //                     "Note: ${seal['item_notes']}",
// //   //                     style: const TextStyle(fontSize: 12, color: Colors.black87),
// //   //                   ),
// //   //                 ),
// //   //               ],
// //   //             ],
// //   //           ),
// //   //         ),
// //   //       ],
// //   //     ),
// //   //   );
// //   // }
// //
// //   Widget _buildSealItemRow(Map<String, dynamic> seal) {
// //     print('seal::  $seal');
// //     final List<dynamic> imageUrls = seal['image_urls'] ?? seal['imagePaths'] ?? [];
// //     final int wear = (seal['wear_percentage'] ?? seal['wearPercentage'] ?? 0).toInt();
// //
// //     // ✅ FIXED: Read either the online database column name or fallback to the local object map key
// //     final String componentLabel = (seal['item_name'] ?? seal['itemName'] ?? 'Component').toString();
// //
// //     // ✅ FIXED: Pull the profile model number seamlessly from both network data row variants
// //     final String profileModel = (seal['manual_seal_name'] ?? seal['sealModelNumber'] ?? seal['sealName'] ?? 'Custom').toString();
// //
// //     // FIXES THE SUBTYPE CAST CRASH: Safely parses dynamic or String fields to Boolean
// //     final dynamic rawReplacementValue = seal['need_replacement'] ?? seal['needsUrgentReplacement'];
// //     bool needsReplacement = false;
// //     if (rawReplacementValue != null) {
// //       if (rawReplacementValue is bool) {
// //         needsReplacement = rawReplacementValue;
// //       } else if (rawReplacementValue is String) {
// //         final sanitizedStr = rawReplacementValue.trim().toLowerCase();
// //         needsReplacement =
// //         (sanitizedStr == 'true' || sanitizedStr == 't' || sanitizedStr == '1');
// //       }
// //     }
// //
// //     // Color logic
// //     Color wearColor;
// //     if (wear < 30) wearColor = AppTheme.success;
// //     else if (wear < 70) wearColor = AppTheme.tertiary;
// //     else wearColor = AppTheme.error;
// //
// //     return Container(
// //       margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(12),
// //         border: needsReplacement
// //             ? Border.all(color: AppTheme.error, width: 2)
// //             : Border.all(color: Colors.transparent),
// //       ),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           if (needsReplacement)
// //             Container(
// //               width: double.infinity,
// //               decoration: const BoxDecoration(
// //                 color: AppTheme.error,
// //                 borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
// //               ),
// //               padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
// //               child: const Row(
// //                 children: [
// //                   Icon(Icons.warning_rounded, color: Colors.white, size: 16),
// //                   SizedBox(width: 8),
// //                   Text(
// //                     "ACTION REQUIRED: URGENT REPLACEMENT",
// //                     style: TextStyle(
// //                         color: Colors.white,
// //                         fontSize: 11,
// //                         fontWeight: FontWeight.bold,
// //                         letterSpacing: 1.0
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //
// //           Padding(
// //             padding: const EdgeInsets.all(16.0),
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 Row(
// //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                   children: [
// //                     Row(
// //                       children: [
// //                         ClipRRect(
// //                           borderRadius: BorderRadius.circular(6),
// //                           child: Image.asset(
// //                             // ✅ FIXED: Uses the unified component label value to dictate target asset asset graphics
// //                             componentLabel.toLowerCase().contains('drawer')
// //                                 ? 'assets/images/drawer.jpeg'
// //                                 : 'assets/images/door.jpeg',
// //                             width: 36,
// //                             height: 36,
// //                             fit: BoxFit.cover,
// //                           ),
// //                         ),
// //                         const SizedBox(width: 12),
// //                         Column(
// //                           crossAxisAlignment: CrossAxisAlignment.start,
// //                           children: [
// //                             Text(
// //                               // ✅ FIXED: Displays the safe normalized asset label cleanly
// //                                 componentLabel.toUpperCase(),
// //                                 style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 0.5)
// //                             ),
// //                             const SizedBox(height: 2),
// //                             Text(
// //                               // ✅ FIXED: Displays the correct profile layout tracking model string safely
// //                               "Model: $profileModel",
// //                               style: TextStyle(fontSize: 12, color: AppTheme.secondaryText, fontWeight: FontWeight.w500),
// //                             ),
// //                           ],
// //                         ),
// //                       ],
// //                     ),
// //
// //                     Container(
// //                       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
// //                       decoration: BoxDecoration(
// //                         color: wearColor.withOpacity(0.1),
// //                         borderRadius: BorderRadius.circular(20),
// //                         border: Border.all(color: wearColor.withOpacity(0.3)),
// //                       ),
// //                       child: Row(
// //                         children: [
// //                           Icon(Icons.speed_rounded, size: 14, color: wearColor),
// //                           const SizedBox(width: 4),
// //                           Text(
// //                             "$wear% WEAR",
// //                             style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: wearColor),
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //
// //                 const Padding(
// //                   padding: EdgeInsets.symmetric(vertical: 12),
// //                   child: Divider(height: 1),
// //                 ),
// //
// //                 Row(
// //                   children: [
// //                     Expanded(child: _buildSpecItem("HEIGHT", "${seal['height_mm'] ?? seal['doorHeight'] ?? 0} mm")),
// //                     Expanded(child: _buildSpecItem("WIDTH", "${seal['width_mm'] ?? seal['doorWidth'] ?? 0} mm")),
// //                     Expanded(child: _buildSpecItem("THICKNESS", "${seal['thickness'] ?? 0} mm")),
// //                   ],
// //                 ),
// //                 const SizedBox(height: 16),
// //                 Row(
// //                   children: [
// //                     Expanded(child: _buildSpecItem("MATERIAL", seal['material'] ?? 'N/A')),
// //                     Expanded(child: _buildSpecItem("TYPE", seal['seal_type'] ?? 'N/A')),
// //                     const Expanded(child: SizedBox()),
// //                   ],
// //                 ),
// //
// //                 const SizedBox(height: 20),
// //                 const Text("CAPTURED PHOTOS", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
// //                 const SizedBox(height: 8),
// //
// //                 imageUrls.isNotEmpty
// //                     ? SizedBox(
// //                   height: 90,
// //                   child: ListView.builder(
// //                     scrollDirection: Axis.horizontal,
// //                     itemCount: imageUrls.length,
// //                     itemBuilder: (context, index) {
// //                       final String path = imageUrls[index].toString();
// //                       final bool isNetwork = path.startsWith('http://') || path.startsWith('https://');
// //
// //                       return Padding(
// //                         padding: const EdgeInsets.only(right: 10),
// //                         child: isNetwork
// //                             ? ImagePreviewer(
// //                           url: path,
// //                           galleryItems: imageUrls,
// //                           initialIndex: index,
// //                           width: 90,
// //                           height: 90,
// //                           fit: BoxFit.cover,
// //                           borderRadius: BorderRadius.circular(8),
// //                         )
// //                             : ClipRRect(
// //                           borderRadius: BorderRadius.circular(8),
// //                           child: Image.file(
// //                             File(path),
// //                             width: 90,
// //                             height: 90,
// //                             fit: BoxFit.cover,
// //                             errorBuilder: (context, error, stackTrace) =>
// //                                 _buildImagePlaceholder("File error", height: 90, width: 90),
// //                           ),
// //                         ),
// //                       );
// //                     },
// //                   ),
// //                 )
// //                     : _buildImagePlaceholder("No photos provided", height: 60),
// //
// //                 if (seal['item_notes'] != null && seal['item_notes'].toString().isNotEmpty) ...[
// //                   const SizedBox(height: 16),
// //                   Container(
// //                     width: double.infinity,
// //                     padding: const EdgeInsets.all(12),
// //                     decoration: BoxDecoration(
// //                       color: Colors.grey[50],
// //                       borderRadius: BorderRadius.circular(8),
// //                     ),
// //                     child: Text(
// //                       "Note: ${seal['item_notes']}",
// //                       style: const TextStyle(fontSize: 12, color: Colors.black87),
// //                     ),
// //                   ),
// //                 ],
// //               ],
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildSpecItem(String label, String value) {
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w500)),
// //         Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
// //       ],
// //     );
// //   }
// //
// //   Widget _buildImagePlaceholder(String message, {double height = 100, double width = double.infinity}) {
// //     return Container(
// //       height: height,
// //       width: width,
// //       decoration: BoxDecoration(
// //         color: Colors.grey[100],
// //         borderRadius: BorderRadius.circular(12),
// //         border: Border.all(color: Colors.grey[200]!),
// //       ),
// //       child: Column(
// //         mainAxisAlignment: MainAxisAlignment.center,
// //         children: [
// //           Icon(Icons.image_not_supported_outlined, color: Colors.grey[400], size: 24),
// //           const SizedBox(height: 4),
// //           Text(
// //             message,
// //             textAlign: TextAlign.center,
// //             style: TextStyle(color: Colors.grey[500], fontSize: 11, fontStyle: FontStyle.italic),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   void _showFullScreenImage(String url) {
// //     showDialog(
// //       context: context,
// //       builder: (context) => Dialog(
// //         backgroundColor: Colors.transparent,
// //         insetPadding: EdgeInsets.zero,
// //         child: Stack(
// //           alignment: Alignment.topRight,
// //           children: [
// //             InteractiveViewer(child: Image.network(url, fit: BoxFit.contain, width: double.infinity, height: double.infinity)),
// //             IconButton(icon: const Icon(Icons.close, color: Colors.white, size: 30), onPressed: () => Navigator.pop(context)),
// //           ],
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
// import 'dart:developer';
// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:intl/intl.dart';
// import '../../../theme.dart';
// import '../../components/image_previewer.dart';
//
// class ViewReportPage extends StatefulWidget {
//   final String reportId;
//   const ViewReportPage({super.key, required this.reportId});
//
//   @override
//   State<ViewReportPage> createState() => _ViewReportPageState();
// }
//
// class _ViewReportPageState extends State<ViewReportPage> {
//   final SupabaseClient _supabase = Supabase.instance.client;
//   bool _isLoading = true;
//   Map<String, dynamic>? _report;
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchReportDetails();
//   }
//
//   Future<void> _fetchReportDetails() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final String cleanSearchId = widget.reportId.toString().trim().toLowerCase();
//
//       // 1. Check local offline queue (saved as a String List)
//       final List<String> currentQueue =
//           prefs.getStringList('offline_reports_queue') ?? [];
//       for (String itemJson in currentQueue) {
//         try {
//           final Map<String, dynamic> rawReport = jsonDecode(itemJson);
//           final String currentId =
//           (rawReport['id'] ?? '').toString().trim().toLowerCase();
//
//           if (currentId == cleanSearchId) {
//             // --- OFFLINE QUEUE ITEM: Enrich seals with local component data ---
//             final enrichedReport =
//             await _enrichOfflineReportWithComponents(rawReport, prefs);
//             setState(() {
//               _report = enrichedReport;
//               _isLoading = false;
//             });
//             return;
//           }
//         } catch (_) {}
//       }
//
//       // 2. Check local server cache
//       final String? cachedData = prefs.getString('cached_my_reports');
//       if (cachedData != null) {
//         final List<dynamic> allReports = jsonDecode(cachedData);
//         for (var cachedItem in allReports) {
//           final Map<String, dynamic> rawReport =
//           Map<String, dynamic>.from(cachedItem);
//           final String currentId =
//           (rawReport['id'] ?? '').toString().trim().toLowerCase();
//
//           if (currentId == cleanSearchId) {
//             // --- CACHED REPORT: Enrich with component dimensions if missing ---
//             final enrichedReport =
//             await _enrichCachedReportWithComponents(rawReport, prefs);
//             setState(() {
//               _report = enrichedReport;
//               _isLoading = false;
//             });
//             return;
//           }
//         }
//       }
//
//       // 3. Fallback: Online query to Supabase with full component join
//       final onlineData = await _supabase.from('asset_reports').select('''
//           *,
//           customer:user_profiles!customer_id(full_name, email),
//           fridges:assets_report_fridge(
//             *,
//             seals:asset_report_fridge_items(*),
//             fridge:fridges(
//               *,
//               components:fridge_components(*)
//             )
//           )
//         ''').eq('id', widget.reportId).single();
//
//       log(
//         '🎯 SUCCESS: Live payload fetched from [Supabase Cloud Server]!',
//         name: 'ViewReportPage.fetch.online',
//       );
//
//       // --- ONLINE DATA: Merge component dimensions into each seal item ---
//       final enrichedOnlineData = _mergeComponentDimensionsIntoSeals(onlineData);
//
//       setState(() {
//         _report = enrichedOnlineData;
//         _isLoading = false;
//       });
//     } catch (e) {
//       debugPrint("Error fetching details: $e");
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }
//
//   /// Merges fridge_components height/width into each seal item for ONLINE data.
//   /// This matches component by index position (seal index 0 = component_index 1).
//   Map<String, dynamic> _mergeComponentDimensionsIntoSeals(
//       Map<String, dynamic> report,
//       ) {
//     try {
//       final List<dynamic> fridges = report['fridges'] ?? [];
//
//       final List<Map<String, dynamic>> enrichedFridges = fridges.map((fridge) {
//         final Map<String, dynamic> fridgeMap =
//         Map<String, dynamic>.from(fridge);
//
//         // Extract components from the nested fridge master record
//         final fridgeMaster = fridgeMap['fridge'];
//         List<dynamic> components = [];
//         if (fridgeMaster != null && fridgeMaster is Map) {
//           components = fridgeMaster['components'] ?? [];
//         }
//
//         // Build a lookup map: component_index -> component record
//         final Map<int, Map<String, dynamic>> componentByIndex = {};
//         for (var comp in components) {
//           if (comp is Map) {
//             final int idx = (comp['component_index'] ?? 0) as int;
//             componentByIndex[idx] = Map<String, dynamic>.from(comp);
//           }
//         }
//
//         // Enrich each seal item with its matching component dimensions
//         final List<dynamic> seals = fridgeMap['seals'] ?? [];
//         final List<Map<String, dynamic>> enrichedSeals = [];
//
//         for (int i = 0; i < seals.length; i++) {
//           final Map<String, dynamic> sealMap =
//           Map<String, dynamic>.from(seals[i]);
//
//           // component_index in DB is 1-based (index + 1)
//           final int componentIndex = i + 1;
//           final matchedComponent = componentByIndex[componentIndex];
//
//           if (matchedComponent != null) {
//             // Inject height and width from fridge_components into the seal item
//             sealMap['height_mm'] = matchedComponent['height_mm'];
//             sealMap['width_mm'] = matchedComponent['width_mm'];
//           } else {
//             // Ensure keys exist even if no component found
//             sealMap['height_mm'] = sealMap['height_mm'] ?? 0;
//             sealMap['width_mm'] = sealMap['width_mm'] ?? 0;
//           }
//
//           enrichedSeals.add(sealMap);
//         }
//
//         fridgeMap['seals'] = enrichedSeals;
//         return fridgeMap;
//       }).toList();
//
//       final Map<String, dynamic> enrichedReport =
//       Map<String, dynamic>.from(report);
//       enrichedReport['fridges'] = enrichedFridges;
//       return enrichedReport;
//     } catch (e) {
//       debugPrint("Component merge error (online): $e");
//       return report;
//     }
//   }
//
//   /// Enriches CACHED server reports with component data from local storage.
//   Future<Map<String, dynamic>> _enrichCachedReportWithComponents(
//       Map<String, dynamic> report,
//       SharedPreferences prefs,
//       ) async {
//     try {
//       // Load local fridge components from sync
//       final String? componentsJson = prefs.getString('local_fridge_components');
//       if (componentsJson == null) return report;
//
//       final List<dynamic> allComponents = jsonDecode(componentsJson);
//
//       final List<dynamic> fridges = report['fridges'] ?? [];
//       final List<Map<String, dynamic>> enrichedFridges = fridges.map((fridge) {
//         final Map<String, dynamic> fridgeMap =
//         Map<String, dynamic>.from(fridge);
//
//         // Get the fridge_id to filter relevant components
//         final String? fridgeId = fridgeMap['fridge_id']?.toString();
//
//         // Build component index lookup for this specific fridge
//         final Map<int, Map<String, dynamic>> componentByIndex = {};
//         if (fridgeId != null) {
//           for (var comp in allComponents) {
//             if (comp is Map &&
//                 comp['fridge_id']?.toString() == fridgeId) {
//               final int idx = (comp['component_index'] ?? 0) as int;
//               componentByIndex[idx] = Map<String, dynamic>.from(comp);
//             }
//           }
//         }
//
//         // Enrich seal items with component dimensions
//         final List<dynamic> seals = fridgeMap['seals'] ?? [];
//         final List<Map<String, dynamic>> enrichedSeals = [];
//
//         for (int i = 0; i < seals.length; i++) {
//           final Map<String, dynamic> sealMap =
//           Map<String, dynamic>.from(seals[i]);
//           final int componentIndex = i + 1;
//           final matchedComponent = componentByIndex[componentIndex];
//
//           if (matchedComponent != null) {
//             sealMap['height_mm'] = matchedComponent['height_mm'];
//             sealMap['width_mm'] = matchedComponent['width_mm'];
//           } else {
//             sealMap['height_mm'] = sealMap['height_mm'] ?? 0;
//             sealMap['width_mm'] = sealMap['width_mm'] ?? 0;
//           }
//
//           enrichedSeals.add(sealMap);
//         }
//
//         fridgeMap['seals'] = enrichedSeals;
//         return fridgeMap;
//       }).toList();
//
//       final Map<String, dynamic> enrichedReport =
//       Map<String, dynamic>.from(report);
//       enrichedReport['fridges'] = enrichedFridges;
//       return enrichedReport;
//     } catch (e) {
//       debugPrint("Component merge error (cached): $e");
//       return report;
//     }
//   }
//
//   /// Enriches OFFLINE QUEUE reports using local component cache + local seal data.
//   Future<Map<String, dynamic>> _enrichOfflineReportWithComponents(
//       Map<String, dynamic> report,
//       SharedPreferences prefs,
//       ) async {
//     try {
//       // For offline queue items, dimensions are stored inside IndividualSeal.toJson()
//       // as 'doorHeight' and 'doorWidth'. We just need to map them to the display keys.
//       final List<dynamic> assets = report['assets'] ?? [];
//
//       final List<Map<String, dynamic>> mappedFridges = assets.map((asset) {
//         final Map<String, dynamic> assetMap =
//         Map<String, dynamic>.from(asset);
//
//         final List<dynamic> individualSeals =
//             assetMap['individualSeals'] ?? [];
//
//         final List<Map<String, dynamic>> mappedSeals =
//         individualSeals.map((seal) {
//           final Map<String, dynamic> sealMap =
//           Map<String, dynamic>.from(seal);
//
//           // Map offline local keys to display keys used in _buildSealItemRow
//           sealMap['height_mm'] = sealMap['doorHeight'] ?? 0;
//           sealMap['width_mm'] = sealMap['doorWidth'] ?? 0;
//           sealMap['item_name'] = sealMap['itemName'] ?? '';
//           sealMap['manual_seal_name'] =
//               sealMap['sealName'] ?? sealMap['sealModelNumber'] ?? '';
//           sealMap['wear_percentage'] = sealMap['wearPercentage'] ?? 0;
//           sealMap['need_replacement'] =
//               sealMap['needsUrgentReplacement'] ?? false;
//           sealMap['seal_type'] = sealMap['sealType'];
//           // sealMap['image_urls'] = sealMap['imagePaths'] ?? [];
//           sealMap['item_notes'] = sealMap['description'];
//           // Normalize offline image paths properly
//           final List<dynamic> localPaths = sealMap['imagePaths'] ?? [];
//           final List<String> normalizedPaths = [];
//
//           for (var p in localPaths) {
//             if (p != null && p.toString().isNotEmpty) {
//               final String path = p.toString();
//
//               // Ensure file still exists before adding
//               if (File(path).existsSync()) {
//                 normalizedPaths.add(path);
//               }
//             }
//           }
//
//           sealMap['image_urls'] = normalizedPaths;
//
//           return sealMap;
//         }).toList();
//
//         assetMap['seals'] = mappedSeals;
//         return assetMap;
//       }).toList();
//
//       final Map<String, dynamic> enrichedReport =
//       Map<String, dynamic>.from(report);
//       enrichedReport['fridges'] = mappedFridges;
//       return enrichedReport;
//     } catch (e) {
//       debugPrint("Component merge error (offline): $e");
//       return report;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     }
//     if (_report == null) {
//       return const Scaffold(
//         body: Center(child: Text("Report data not found")),
//       );
//     }
//
//     // Map list variables across online ('fridges') and local outbox ('assets') schemas
//     final fridges = _report!['fridges'] ?? _report!['assets'] ?? [];
//
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8F9FA),
//       appBar: AppBar(
//         title: Text(_report!['report_title'] ?? "Report Summary"),
//         elevation: 0,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildReportHeader(),
//             const SizedBox(height: 24),
//             const Text(
//               "ASSET DETAILS",
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 12,
//                 color: Colors.blueGrey,
//                 letterSpacing: 1.1,
//               ),
//             ),
//             const SizedBox(height: 12),
//             ...fridges
//                 .map((f) => _buildFridgeDetailCard(
//               Map<String, dynamic>.from(f),
//             ))
//                 .toList(),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildReportHeader() {
//     final customer = _report!['customer'];
//     String displayCustomerName = "Client";
//
//     if (customer != null && customer is Map) {
//       displayCustomerName = customer['full_name'] ?? "Client";
//     } else {
//       // Fallback: try to resolve from local customers cache synchronously
//       // (async not possible here, but we try best-effort from already-loaded report)
//       displayCustomerName = "Offline Pending Client";
//     }
//
//     final String dateString =
//         _report!['report_date'] ??
//             _report!['queued_at'] ??
//             DateTime.now().toIso8601String();
//     final date = DateTime.parse(dateString).toLocal();
//
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 15,
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               const CircleAvatar(
//                 backgroundColor: AppTheme.primary,
//                 child: Icon(Icons.business, color: Colors.white),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       displayCustomerName,
//                       style: const TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 16,
//                       ),
//                     ),
//                     Text(
//                       DateFormat('MMMM dd, yyyy').format(date),
//                       style: const TextStyle(
//                         color: Colors.grey,
//                         fontSize: 12,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           if (_report!['notes'] != null &&
//               _report!['notes'].toString().isNotEmpty) ...[
//             const Divider(height: 30),
//             const Text(
//               "GENERAL NOTES",
//               style: TextStyle(
//                 fontSize: 10,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.grey,
//               ),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               _report!['notes'],
//               style: const TextStyle(fontSize: 14),
//             ),
//           ],
//         ],
//       ),
//     );
//   }
//
//   Widget _buildFridgeDetailCard(Map<String, dynamic> fridge) {
//     // Map arrays across online ('seals') and local outbox ('seals' after enrichment)
//     final seals = fridge['seals'] ?? fridge['individualSeals'] ?? [];
//
//     final int drawerCount =
//         fridge['drawer_count'] ?? fridge['drawerCount'] ?? 0;
//     final int doorCount = fridge['door_count'] ?? fridge['doorCount'] ?? 0;
//
//     final String? dataPlatePath =
//         fridge['data_plate_url'] ?? fridge['dataPlateImagePath'];
//     final bool isNetworkImage = dataPlatePath != null &&
//         (dataPlatePath.startsWith('http://') ||
//             dataPlatePath.startsWith('https://'));
//
//     return Container(
//       margin: const EdgeInsets.only(bottom: 20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: Colors.grey[200]!),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Fridge Header Info
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.grey[50],
//               borderRadius:
//               const BorderRadius.vertical(top: Radius.circular(16)),
//             ),
//             child: Row(
//               children: [
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(6),
//                   child: Image.asset(
//                     drawerCount > 0 && doorCount == 0
//                         ? 'assets/images/drawer.jpeg'
//                         : 'assets/images/door.jpeg',
//                     width: 32,
//                     height: 32,
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         "${fridge['manufacturer'] ?? 'Unknown'} - ${fridge['model_no'] ?? fridge['modelNo'] ?? 'N/A'}",
//                         style: const TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 15,
//                         ),
//                       ),
//                       Text(
//                         "Area: ${fridge['area'] ?? 'N/A'} | S/N: ${fridge['serial_no'] ?? fridge['serialNo'] ?? 'N/A'}",
//                         style: const TextStyle(
//                           fontSize: 12,
//                           color: Colors.grey,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           // Data Plate Image
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   "DATA PLATE PHOTO",
//                   style: TextStyle(
//                     fontSize: 10,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.grey,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 dataPlatePath != null
//                     ? (isNetworkImage
//                     ? ImagePreviewer(
//                   url: dataPlatePath,
//                   height: 180,
//                   width: double.infinity,
//                   fit: BoxFit.cover,
//                   borderRadius: BorderRadius.circular(12),
//                 )
//                     : ClipRRect(
//                   borderRadius: BorderRadius.circular(12),
//                   child: Image.file(
//                     File(dataPlatePath),
//                     height: 180,
//                     width: double.infinity,
//                     fit: BoxFit.cover,
//                   ),
//                 ))
//                     : _buildImagePlaceholder("No data plate photo captured"),
//               ],
//             ),
//           ),
//
//           const Divider(height: 1),
//
//           // Seals Section
//           ...seals
//               .map(
//                 (seal) => _buildSealItemRow(
//               Map<String, dynamic>.from(seal),
//             ),
//           )
//               .toList(),
//           const SizedBox(height: 8),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSealItemRow(Map<String, dynamic> seal) {
//     print('seal::  $seal');
//
//     final List<dynamic> imageUrls =
//         seal['image_urls'] ?? seal['imagePaths'] ?? [];
//     final int wear =
//     (seal['wear_percentage'] ?? seal['wearPercentage'] ?? 0).toInt();
//
//     final String componentLabel =
//     (seal['item_name'] ?? seal['itemName'] ?? 'Component').toString();
//
//     final String profileModel = (seal['manual_seal_name'] ??
//         seal['sealModelNumber'] ??
//         seal['sealName'] ??
//         'Custom')
//         .toString();
//
//     final dynamic rawReplacementValue =
//         seal['need_replacement'] ?? seal['needsUrgentReplacement'];
//     bool needsReplacement = false;
//     if (rawReplacementValue != null) {
//       if (rawReplacementValue is bool) {
//         needsReplacement = rawReplacementValue;
//       } else if (rawReplacementValue is String) {
//         final sanitizedStr = rawReplacementValue.trim().toLowerCase();
//         needsReplacement =
//         (sanitizedStr == 'true' || sanitizedStr == 't' || sanitizedStr == '1');
//       }
//     }
//
//     // --- FIXED: Read height/width from enriched keys (set during fetch enrichment) ---
//     // height_mm and width_mm are injected by _mergeComponentDimensionsIntoSeals
//     // For offline: mapped from doorHeight/doorWidth in _enrichOfflineReportWithComponents
//     final dynamic rawHeight = seal['height_mm'] ?? seal['doorHeight'] ?? 0;
//     final dynamic rawWidth = seal['width_mm'] ?? seal['doorWidth'] ?? 0;
//     final double heightVal = (rawHeight is num) ? rawHeight.toDouble() : 0.0;
//     final double widthVal = (rawWidth is num) ? rawWidth.toDouble() : 0.0;
//
//     // Format display: show 0 as "N/A" for better UX
//     final String heightDisplay =
//     heightVal > 0 ? "${heightVal.toStringAsFixed(1)}" : "N/A";
//     final String widthDisplay =
//     widthVal > 0 ? "${widthVal.toStringAsFixed(1)}" : "N/A";
//
//     Color wearColor;
//     if (wear < 30) {
//       wearColor = AppTheme.success;
//     } else if (wear < 70) {
//       wearColor = AppTheme.tertiary;
//     } else {
//       wearColor = AppTheme.error;
//     }
//
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: needsReplacement
//             ? Border.all(color: AppTheme.error, width: 2)
//             : Border.all(color: Colors.transparent),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           if (needsReplacement)
//             Container(
//               width: double.infinity,
//               decoration: const BoxDecoration(
//                 color: AppTheme.error,
//                 borderRadius:
//                 BorderRadius.vertical(top: Radius.circular(10)),
//               ),
//               padding:
//               const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//               child: const Row(
//                 children: [
//                   Icon(Icons.warning_rounded, color: Colors.white, size: 16),
//                   SizedBox(width: 8),
//                   Text(
//                     "ACTION REQUIRED: URGENT REPLACEMENT",
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 11,
//                       fontWeight: FontWeight.bold,
//                       letterSpacing: 1.0,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Row(
//                       children: [
//                         ClipRRect(
//                           borderRadius: BorderRadius.circular(6),
//                           child: Image.asset(
//                             componentLabel.toLowerCase().contains('drawer')
//                                 ? 'assets/images/drawer.jpeg'
//                                 : 'assets/images/door.jpeg',
//                             width: 36,
//                             height: 36,
//                             fit: BoxFit.cover,
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               componentLabel.toUpperCase(),
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.w900,
//                                 fontSize: 15,
//                                 letterSpacing: 0.5,
//                               ),
//                             ),
//                             const SizedBox(height: 2),
//                             Text(
//                               "Model: $profileModel",
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 color: AppTheme.secondaryText,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 12,
//                         vertical: 6,
//                       ),
//                       decoration: BoxDecoration(
//                         color: wearColor.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(20),
//                         border: Border.all(
//                           color: wearColor.withOpacity(0.3),
//                         ),
//                       ),
//                       child: Row(
//                         children: [
//                           Icon(Icons.speed_rounded,
//                               size: 14, color: wearColor),
//                           const SizedBox(width: 4),
//                           Text(
//                             "$wear% WEAR",
//                             style: TextStyle(
//                               fontSize: 11,
//                               fontWeight: FontWeight.bold,
//                               color: wearColor,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//                 const Padding(
//                   padding: EdgeInsets.symmetric(vertical: 12),
//                   child: Divider(height: 1),
//                 ),
//
//                 // --- FIXED: Use enriched height/width values ---
//                 Row(
//                   children: [
//                     Expanded(
//                       child: _buildSpecItem("HEIGHT", "$heightDisplay mm"),
//                     ),
//                     Expanded(
//                       child: _buildSpecItem("WIDTH", "$widthDisplay mm"),
//                     ),
//                     Expanded(
//                       child: _buildSpecItem(
//                         "THICKNESS",
//                         "${seal['thickness'] ?? 0} mm",
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 16),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: _buildSpecItem(
//                         "MATERIAL",
//                         seal['material'] ?? 'N/A',
//                       ),
//                     ),
//                     Expanded(
//                       child: _buildSpecItem(
//                         "TYPE",
//                         seal['seal_type'] ?? seal['sealType'] ?? 'N/A',
//                       ),
//                     ),
//                     const Expanded(child: SizedBox()),
//                   ],
//                 ),
//
//                 const SizedBox(height: 20),
//                 const Text(
//                   "CAPTURED PHOTOS",
//                   style: TextStyle(
//                     fontSize: 10,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.grey,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//
//                 imageUrls.isNotEmpty
//                     ? SizedBox(
//                   height: 90,
//                   child: ListView.builder(
//                     scrollDirection: Axis.horizontal,
//                     itemCount: imageUrls.length,
//                     itemBuilder: (context, index) {
//                       final String path =
//                       imageUrls[index].toString();
//                       final bool isNetwork =
//                           path.startsWith('http://') ||
//                               path.startsWith('https://');
//
//                       return Padding(
//                         padding: const EdgeInsets.only(right: 10),
//                         child: isNetwork
//                             ? ImagePreviewer(
//                           url: path,
//                           galleryItems: imageUrls,
//                           initialIndex: index,
//                           width: 90,
//                           height: 90,
//                           fit: BoxFit.cover,
//                           borderRadius:
//                           BorderRadius.circular(8),
//                         )
//                             : ClipRRect(
//                           borderRadius:
//                           BorderRadius.circular(8),
//                           child: Image.file(
//                             File(path),
//                             width: 90,
//                             height: 90,
//                             fit: BoxFit.cover,
//                             errorBuilder: (context, error,
//                                 stackTrace) =>
//                                 _buildImagePlaceholder(
//                                   "File error",
//                                   height: 90,
//                                   width: 90,
//                                 ),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 )
//                     : _buildImagePlaceholder(
//                   "No photos provided",
//                   height: 60,
//                 ),
//
//                 if (seal['item_notes'] != null &&
//                     seal['item_notes'].toString().isNotEmpty) ...[
//                   const SizedBox(height: 16),
//                   Container(
//                     width: double.infinity,
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: Colors.grey[50],
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Text(
//                       "Note: ${seal['item_notes']}",
//                       style: const TextStyle(
//                         fontSize: 12,
//                         color: Colors.black87,
//                       ),
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSpecItem(String label, String value) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: const TextStyle(
//             fontSize: 10,
//             color: Colors.grey,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         Text(
//           value,
//           style: const TextStyle(
//             fontSize: 12,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildImagePlaceholder(
//       String message, {
//         double height = 100,
//         double width = double.infinity,
//       }) {
//     return Container(
//       height: height,
//       width: width,
//       decoration: BoxDecoration(
//         color: Colors.grey[100],
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey[200]!),
//       ),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.image_not_supported_outlined,
//             color: Colors.grey[400],
//             size: 24,
//           ),
//           const SizedBox(height: 4),
//           Text(
//             message,
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               color: Colors.grey[500],
//               fontSize: 11,
//               fontStyle: FontStyle.italic,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showFullScreenImage(String url) {
//     showDialog(
//       context: context,
//       builder: (context) => Dialog(
//         backgroundColor: Colors.transparent,
//         insetPadding: EdgeInsets.zero,
//         child: Stack(
//           alignment: Alignment.topRight,
//           children: [
//             InteractiveViewer(
//               child: Image.network(
//                 url,
//                 fit: BoxFit.contain,
//                 width: double.infinity,
//                 height: double.infinity,
//               ),
//             ),
//             IconButton(
//               icon: const Icon(Icons.close, color: Colors.white, size: 30),
//               onPressed: () => Navigator.pop(context),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../../../theme.dart';
import '../../components/image_previewer.dart';
import 'edit_report_page.dart';

class ViewReportPage extends StatefulWidget {
  final String reportId;
  const ViewReportPage({super.key, required this.reportId});

  @override
  State<ViewReportPage> createState() => _ViewReportPageState();
}

class _ViewReportPageState extends State<ViewReportPage> {
  final SupabaseClient _supabase = Supabase.instance.client;
  bool _isLoading = true;
  Map<String, dynamic>? _report;

  @override
  void initState() {
    super.initState();
    _fetchReportDetails();
  }

  Future<void> _fetchReportDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String cleanSearchId = widget.reportId.toString().trim().toLowerCase();

      // 1. Check local offline queue (saved as a String List)
      final List<String> currentQueue =
          prefs.getStringList('offline_reports_queue') ?? [];
      for (String itemJson in currentQueue) {
        try {
          final Map<String, dynamic> rawReport = jsonDecode(itemJson);
          final String currentId =
          (rawReport['id'] ?? '').toString().trim().toLowerCase();

          if (currentId == cleanSearchId) {
            // --- OFFLINE QUEUE ITEM: Enrich seals with local component data ---
            final enrichedReport =
            await _enrichOfflineReportWithComponents(rawReport, prefs);
            setState(() {
              _report = enrichedReport;
              _isLoading = false;
            });
            return;
          }
        } catch (_) {}
      }

      // 2. Check local server cache
      final String? cachedData = prefs.getString('cached_my_reports');
      if (cachedData != null) {
        final List<dynamic> allReports = jsonDecode(cachedData);
        for (var cachedItem in allReports) {
          final Map<String, dynamic> rawReport =
          Map<String, dynamic>.from(cachedItem);
          final String currentId =
          (rawReport['id'] ?? '').toString().trim().toLowerCase();

          if (currentId == cleanSearchId) {
            // --- CACHED REPORT: Enrich with component dimensions if missing ---
            final enrichedReport =
            await _enrichCachedReportWithComponents(rawReport, prefs);
            setState(() {
              _report = enrichedReport;
              _isLoading = false;
            });
            return;
          }
        }
      }

      // 3. Fallback: Online query to Supabase with full component join
      final onlineData = await _supabase.from('asset_reports').select('''
          *,
          gg_number,
          customer:user_profiles!customer_id(full_name, email),
          fridges:assets_report_fridge(
            *,
            seals:asset_report_fridge_items(*),
            fridge:fridges(
              *,
              components:fridge_components(*)
            )
          )
        ''').eq('id', widget.reportId).single();

      log(
        '🎯 SUCCESS: Live payload fetched from [Supabase Cloud Server]!',
        name: 'ViewReportPage.fetch.online',
      );

      // --- ONLINE DATA: Merge component dimensions into each seal item ---
      final enrichedOnlineData = _mergeComponentDimensionsIntoSeals(onlineData);

      setState(() {
        _report = enrichedOnlineData;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching details: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Force a live Supabase fetch — bypasses stale cache, used after editing.
  Future<void> _fetchFromSupabase() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final onlineData = await _supabase.from('asset_reports').select('''
          *,
          gg_number,
          customer:user_profiles!customer_id(full_name, email),
          fridges:assets_report_fridge(
            *,
            seals:asset_report_fridge_items(*),
            fridge:fridges(
              *,
              components:fridge_components(*)
            )
          )
        ''').eq('id', widget.reportId).single();
      final enriched = _mergeComponentDimensionsIntoSeals(onlineData);
      if (mounted) setState(() { _report = enriched; _isLoading = false; });
    } catch (e) {
      debugPrint('Force refresh error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Merges fridge_components height/width into each seal item for ONLINE data.
  Map<String, dynamic> _mergeComponentDimensionsIntoSeals(
      Map<String, dynamic> report,
      ) {
    try {
      final List<dynamic> fridges = report['fridges'] ?? [];

      final List<Map<String, dynamic>> enrichedFridges = fridges.map((fridge) {
        final Map<String, dynamic> fridgeMap =
        Map<String, dynamic>.from(fridge);

        final fridgeMaster = fridgeMap['fridge'];
        List<dynamic> components = [];
        if (fridgeMaster != null && fridgeMaster is Map) {
          components = fridgeMaster['components'] ?? [];
        }

        final Map<int, Map<String, dynamic>> componentByIndex = {};
        for (var comp in components) {
          if (comp is Map) {
            final int idx = (comp['component_index'] ?? 0) as int;
            componentByIndex[idx] = Map<String, dynamic>.from(comp);
          }
        }

        final List<dynamic> seals = fridgeMap['seals'] ?? [];
        final List<Map<String, dynamic>> enrichedSeals = [];

        for (int i = 0; i < seals.length; i++) {
          final Map<String, dynamic> sealMap =
          Map<String, dynamic>.from(seals[i]);

          final int componentIndex = i + 1;
          final matchedComponent = componentByIndex[componentIndex];

          if (matchedComponent != null) {
            sealMap['height_mm'] = matchedComponent['height_mm'];
            sealMap['width_mm'] = matchedComponent['width_mm'];
          } else {
            sealMap['height_mm'] = sealMap['height_mm'] ?? 0;
            sealMap['width_mm'] = sealMap['width_mm'] ?? 0;
          }

          enrichedSeals.add(sealMap);
        }

        fridgeMap['seals'] = enrichedSeals;
        return fridgeMap;
      }).toList();

      final Map<String, dynamic> enrichedReport =
      Map<String, dynamic>.from(report);
      enrichedReport['fridges'] = enrichedFridges;
      return enrichedReport;
    } catch (e) {
      debugPrint("Component merge error (online): $e");
      return report;
    }
  }

  /// Enriches CACHED server reports with component data from local storage.
  Future<Map<String, dynamic>> _enrichCachedReportWithComponents(
      Map<String, dynamic> report,
      SharedPreferences prefs,
      ) async {
    try {
      final String? componentsJson = prefs.getString('local_fridge_components');
      if (componentsJson == null) return report;

      final List<dynamic> allComponents = jsonDecode(componentsJson);

      final List<dynamic> fridges = report['fridges'] ?? [];
      final List<Map<String, dynamic>> enrichedFridges = fridges.map((fridge) {
        final Map<String, dynamic> fridgeMap =
        Map<String, dynamic>.from(fridge);

        final String? fridgeId = fridgeMap['fridge_id']?.toString();

        final Map<int, Map<String, dynamic>> componentByIndex = {};
        if (fridgeId != null) {
          for (var comp in allComponents) {
            if (comp is Map &&
                comp['fridge_id']?.toString() == fridgeId) {
              final int idx = (comp['component_index'] ?? 0) as int;
              componentByIndex[idx] = Map<String, dynamic>.from(comp);
            }
          }
        }

        final List<dynamic> seals = fridgeMap['seals'] ?? [];
        final List<Map<String, dynamic>> enrichedSeals = [];

        for (int i = 0; i < seals.length; i++) {
          final Map<String, dynamic> sealMap =
          Map<String, dynamic>.from(seals[i]);
          final int componentIndex = i + 1;
          final matchedComponent = componentByIndex[componentIndex];

          if (matchedComponent != null) {
            sealMap['height_mm'] = matchedComponent['height_mm'];
            sealMap['width_mm'] = matchedComponent['width_mm'];
          } else {
            sealMap['height_mm'] = sealMap['height_mm'] ?? 0;
            sealMap['width_mm'] = sealMap['width_mm'] ?? 0;
          }

          enrichedSeals.add(sealMap);
        }

        fridgeMap['seals'] = enrichedSeals;
        return fridgeMap;
      }).toList();

      final Map<String, dynamic> enrichedReport =
      Map<String, dynamic>.from(report);
      enrichedReport['fridges'] = enrichedFridges;
      return enrichedReport;
    } catch (e) {
      debugPrint("Component merge error (cached): $e");
      return report;
    }
  }

  /// Enriches OFFLINE QUEUE reports using local component cache + local seal data.
  Future<Map<String, dynamic>> _enrichOfflineReportWithComponents(
      Map<String, dynamic> report,
      SharedPreferences prefs,
      ) async {
    try {
      final List<dynamic> assets = report['assets'] ?? [];

      final List<Map<String, dynamic>> mappedFridges = assets.map((asset) {
        final Map<String, dynamic> assetMap =
        Map<String, dynamic>.from(asset);

        final List<dynamic> individualSeals =
            assetMap['individualSeals'] ?? [];

        final List<Map<String, dynamic>> mappedSeals =
        individualSeals.map((seal) {
          final Map<String, dynamic> sealMap =
          Map<String, dynamic>.from(seal);

          sealMap['height_mm'] = sealMap['doorHeight'] ?? 0;
          sealMap['width_mm'] = sealMap['doorWidth'] ?? 0;
          sealMap['item_name'] = sealMap['itemName'] ?? '';
          sealMap['manual_seal_name'] =
              sealMap['sealName'] ?? sealMap['sealModelNumber'] ?? '';
          sealMap['wear_percentage'] = sealMap['wearPercentage'] ?? 0;
          sealMap['need_replacement'] =
              sealMap['needsUrgentReplacement'] ?? false;
          sealMap['seal_type'] = sealMap['sealType'];
          sealMap['item_notes'] = sealMap['description'];

          // Normalize offline image paths properly
          final List<dynamic> localPaths = sealMap['imagePaths'] ?? [];
          final List<String> normalizedPaths = [];

          for (var p in localPaths) {
            if (p != null && p.toString().isNotEmpty) {
              // Clean local filesystem protocol signatures out of storage values safely
              String cleanPath = p.toString().replaceAll('file://', '');
              cleanPath = Uri.decodeComponent(cleanPath);

              if (cleanPath.isNotEmpty) {
                normalizedPaths.add(cleanPath);
              }
            }
          }

          sealMap['image_urls'] = normalizedPaths;
          return sealMap;
        }).toList();

        assetMap['seals'] = mappedSeals;
        return assetMap;
      }).toList();

      final Map<String, dynamic> enrichedReport =
      Map<String, dynamic>.from(report);
      enrichedReport['fridges'] = mappedFridges;
      return enrichedReport;
    } catch (e) {
      debugPrint("Component merge error (offline): $e");
      return report;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_report == null) {
      return const Scaffold(
        body: Center(child: Text("Report data not found")),
      );
    }

    final fridges = _report!['fridges'] ?? _report!['assets'] ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(_report!['report_title'] ?? "Report Summary"),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            tooltip: 'Edit Report',
            onPressed: () async {
              final updated = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => EditReportPage(reportId: widget.reportId),
                ),
              );
              if (updated == true && mounted) {
                _fetchFromSupabase();
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildReportHeader(),
            const SizedBox(height: 24),
            const Text(
              "ASSET DETAILS",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.blueGrey,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 12),
            ...fridges
                .map((f) => _buildFridgeDetailCard(
              Map<String, dynamic>.from(f),
            ))
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildReportHeader() {
    final customer = _report!['customer'];
    String displayCustomerName = "Client";

    if (customer != null && customer is Map) {
      displayCustomerName = customer['full_name'] ?? "Client";
    } else {
      displayCustomerName = "Offline Pending Client";
    }

    final String dateString =
        _report!['report_date'] ??
            _report!['queued_at'] ??
            DateTime.now().toIso8601String();
    final date = DateTime.parse(dateString).toLocal();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: AppTheme.primary,
                child: Icon(Icons.business, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayCustomerName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      DateFormat('MMMM dd, yyyy').format(date),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),


          if (_report!['notes'] != null &&
              _report!['notes'].toString().isNotEmpty) ...[
            const Divider(height: 30),
            const Text(
              "GENERAL NOTES",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _report!['notes'],
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFridgeDetailCard(Map<String, dynamic> fridge) {
    final seals = fridge['seals'] ?? fridge['individualSeals'] ?? [];

    final int drawerCount =
        fridge['drawer_count'] ?? fridge['drawerCount'] ?? 0;
    final int doorCount = fridge['door_count'] ?? fridge['doorCount'] ?? 0;

    final String? dataPlatePath =
        fridge['data_plate_url'] ?? fridge['dataPlateImagePath'];
    final bool isNetworkImage = dataPlatePath != null &&
        (dataPlatePath.startsWith('http://') ||
            dataPlatePath.startsWith('https://'));

    final String assetGgNumber = (fridge['gg_number'] ?? 'N/A').toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius:
              const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.asset(
                    drawerCount > 0 && doorCount == 0
                        ? 'assets/images/drawer.jpeg'
                        : 'assets/images/door.jpeg',
                    width: 32,
                    height: 32,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${fridge['manufacturer'] ?? 'Unknown'} - ${fridge['model_no'] ?? fridge['modelNo'] ?? 'N/A'}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        "Area: ${fridge['area'] ?? 'N/A'} | S/N: ${fridge['serial_no'] ?? fridge['serialNo'] ?? 'N/A'}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // ✅ ADDED INLINE INSIDE CARD HEADER: Show dynamic row tags seamlessly
                      Text("GG Number: $assetGgNumber", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "DATA PLATE PHOTO",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                dataPlatePath != null
                    ? (isNetworkImage
                    ? ImagePreviewer(
                  url: dataPlatePath,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  borderRadius: BorderRadius.circular(12),
                )
                    : ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(dataPlatePath.replaceAll('file://', '')),
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ))
                    : _buildImagePlaceholder("No data plate photo captured"),
              ],
            ),
          ),

          const Divider(height: 1),

          ...seals
              .map(
                (seal) => _buildSealItemRow(
              Map<String, dynamic>.from(seal),
            ),
          )
              .toList(),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildSealItemRow(Map<String, dynamic> seal) {
    print('seal::  $seal');

    final List<dynamic> imageUrls =
        seal['image_urls'] ?? seal['imagePaths'] ?? [];
    final int wear =
    (seal['wear_percentage'] ?? seal['wearPercentage'] ?? 0).toInt();

    final String componentLabel =
    (seal['item_name'] ?? seal['itemName'] ?? 'Component').toString();

    final String profileModel = (seal['manual_seal_name'] ??
        seal['sealModelNumber'] ??
        seal['sealName'] ??
        'Custom')
        .toString();

    final dynamic rawReplacementValue =
        seal['need_replacement'] ?? seal['needsUrgentReplacement'];
    bool needsReplacement = false;
    if (rawReplacementValue != null) {
      if (rawReplacementValue is bool) {
        needsReplacement = rawReplacementValue;
      } else if (rawReplacementValue is String) {
        final sanitizedStr = rawReplacementValue.trim().toLowerCase();
        needsReplacement =
        (sanitizedStr == 'true' || sanitizedStr == 't' || sanitizedStr == '1');
      }
    }

    final dynamic rawHeight = seal['height_mm'] ?? seal['doorHeight'] ?? 0;
    final dynamic rawWidth = seal['width_mm'] ?? seal['doorWidth'] ?? 0;
    final double heightVal = (rawHeight is num) ? rawHeight.toDouble() : 0.0;
    final double widthVal = (rawWidth is num) ? rawWidth.toDouble() : 0.0;

    final String heightDisplay =
    heightVal > 0 ? "${heightVal.toStringAsFixed(1)}" : "N/A";
    final String widthDisplay =
    widthVal > 0 ? "${widthVal.toStringAsFixed(1)}" : "N/A";

    Color wearColor;
    if (wear < 34) {
      wearColor = AppTheme.success;
    } else if (wear < 67) {
      wearColor = AppTheme.tertiary;
    } else {
      wearColor = AppTheme.error;
    }

    String wearStatus;
    if (wear <= 33) {
      wearStatus = "OK";
    } else if (wear <= 66) {
      wearStatus = "SPLIT";
    } else {
      wearStatus = "NEED REPLACEMENT";
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: needsReplacement
            ? Border.all(color: AppTheme.error, width: 2)
            : Border.all(color: Colors.transparent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (needsReplacement)
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppTheme.error,
                borderRadius:
                BorderRadius.vertical(top: Radius.circular(10)),
              ),
              padding:
              const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: const Row(
                children: [
                  Icon(Icons.warning_rounded, color: Colors.white, size: 16),
                  SizedBox(width: 8),
                  Text(
                    "ACTION REQUIRED: URGENT REPLACEMENT",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.asset(
                            componentLabel.toLowerCase().contains('drawer')
                                ? 'assets/images/drawer.jpeg'
                                : 'assets/images/door.jpeg',
                            width: 36,
                            height: 36,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              componentLabel.toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "Model: $profileModel",
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.secondaryText,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: wearColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: wearColor.withOpacity(0.3),
                        ),
                      ),
                      // child: Row(
                      //   children: [
                      //     Icon(Icons.speed_rounded,
                      //         size: 14, color: wearColor),
                      //     const SizedBox(width: 4),
                      //     Text(
                      //       "$wear% WEAR",
                      //       style: TextStyle(
                      //         fontSize: 11,
                      //         fontWeight: FontWeight.bold,
                      //         color: wearColor,
                      //       ),
                      //     ),
                      //   ],
                      // ),

                      child: Row(
                        children: [
                          Icon(Icons.speed_rounded, size: 14, color: wearColor),
                          const SizedBox(width: 4),
                          Text(
                            // ✅ UPDATED: Status string dynamically appended along with the raw % wear label
                            "$wearStatus ($wear% WEAR)",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: wearColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1),
                ),

                Row(
                  children: [
                    Expanded(
                      child: _buildSpecItem(
                          componentLabel.toLowerCase().contains('drawer') ? "DRAWER HEIGHT" : "DOOR HEIGHT",
                          "$heightDisplay mm"
                      ),
                    ),
                    Expanded(
                      child: _buildSpecItem(
                          componentLabel.toLowerCase().contains('drawer') ? "DRAWER WIDTH" : "DOOR WIDTH",
                          "$widthDisplay mm"
                      ),
                    ),
                    Expanded(
                      child: _buildSpecItem(
                        "THICKNESS",
                        "${seal['thickness'] ?? 0} mm",
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildSpecItem(
                        "MATERIAL",
                        seal['material'] ?? 'N/A',
                      ),
                    ),
                    Expanded(
                      child: _buildSpecItem(
                        "TYPE",
                        seal['seal_type'] ?? seal['sealType'] ?? 'N/A',
                      ),
                    ),
                    const Expanded(child: SizedBox()),
                  ],
                ),

                const SizedBox(height: 20),
                const Text(
                  "CAPTURED PHOTOS",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),

                imageUrls.isNotEmpty
                    ? SizedBox(
                  height: 90,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: imageUrls.length,
                    itemBuilder: (context, index) {
                      final String path = imageUrls[index].toString();
                      final bool isNetwork =
                          path.startsWith('http://') ||
                              path.startsWith('https://');

                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: isNetwork
                            ? ImagePreviewer(
                          url: path,
                          galleryItems: imageUrls,
                          initialIndex: index,
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                          borderRadius:
                          BorderRadius.circular(8),
                        )
                            : ClipRRect(
                          borderRadius:
                          BorderRadius.circular(8),
                          child: Image.file(
                            File(path),
                            width: 90,
                            height: 90,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error,
                                stackTrace) =>
                                _buildImagePlaceholder(
                                  "File error",
                                  height: 90,
                                  width: 90,
                                ),
                          ),
                        ),
                      );
                    },
                  ),
                )
                    : _buildImagePlaceholder(
                  "No photos provided",
                  height: 60,
                ),

                if (seal['item_notes'] != null &&
                    seal['item_notes'].toString().isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "Note: ${seal['item_notes']}",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder(
      String message, {
        double height = 100,
        double width = double.infinity,
      }) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            color: Colors.grey[400],
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 11,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  void _showFullScreenImage(String url) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            InteractiveViewer(
              child: Image.network(
                url,
                fit: BoxFit.contain,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../../../theme.dart';
import '../../components/image_previewer.dart';

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

  // Future<void> _fetchReportDetails() async {
  //   try {
  //     // Fetches Report -> Customer -> Fridge Assets -> Individual Seal Items
  //     final data = await _supabase.from('asset_reports').select('''
  //       *,
  //       customer:user_profiles!customer_id(full_name, email),
  //       fridges:assets_report_fridge(
  //         *,
  //         seals:report_asset_items(*)
  //       )
  //     ''').eq('id', widget.reportId).single();
  //
  //     setState(() {
  //       _report = data;
  //       _isLoading = false;
  //     });
  //   } catch (e) {
  //     debugPrint("Error fetching report: $e");
  //     if (mounted) setState(() => _isLoading = false);
  //   }
  // }


  // Inside _ViewReportPageState in view_report_page.dart

  Future<void> _fetchReportDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? cachedData = prefs.getString('cached_my_reports');

      if (cachedData != null) {
        final List<dynamic> allReports = jsonDecode(cachedData);

        // Find the specific report by ID from the local list
        final report = allReports.firstWhere(
              (r) => r['id'] == widget.reportId,
          orElse: () => null,
        );

        if (report != null) {
          setState(() {
            _report = report;
            _isLoading = false;
          });
          return; // Exit early since we found it locally
        }
      }

      // Fallback: If not found locally, try fetching from Supabase (online only)
      final onlineData = await _supabase.from('asset_reports').select('''
        *,
        customer:user_profiles!customer_id(full_name, email),
        fridges:assets_report_fridge(*, seals:report_asset_items(*))
      ''').eq('id', widget.reportId).single();

      setState(() {
        _report = onlineData;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_report == null) return const Scaffold(body: Center(child: Text("Report data not found")));

    final fridges = _report!['fridges'] as List;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(_report!['report_title'] ?? "Report Summary"),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildReportHeader(),
            const SizedBox(height: 24),
            const Text("ASSET DETAILS",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blueGrey, letterSpacing: 1.1)),
            const SizedBox(height: 12),
            ...fridges.map((f) => _buildFridgeDetailCard(f)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildReportHeader() {
    final customer = _report!['customer'];
    final date = DateTime.parse(_report!['report_date']).toLocal();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                  backgroundColor: AppTheme.primary,
                  child: Icon(Icons.business, color: Colors.white)
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(customer['full_name'] ?? "Client", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(DateFormat('MMMM dd, yyyy').format(date), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          if (_report!['notes'] != null && _report!['notes'].toString().isNotEmpty) ...[
            const Divider(height: 30),
            const Text("GENERAL NOTES", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 4),
            Text(_report!['notes'], style: const TextStyle(fontSize: 14)),
          ]
        ],
      ),
    );
  }

  Widget _buildFridgeDetailCard(Map<String, dynamic> fridge) {
    final seals = fridge['seals'] as List;

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
          // Fridge Header Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                const Icon(Icons.kitchen, color: AppTheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${fridge['manufacturer']} - ${fridge['model_no']}",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      Text("Area: ${fridge['area'] ?? 'N/A'} | S/N: ${fridge['serial_no'] ?? 'N/A'}",
                          style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Data Plate Image Logic
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("DATA PLATE PHOTO", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 8),
                fridge['data_plate_url'] != null
                    ? // --- UPDATED: Using the common ImagePreviewer component ---
                ImagePreviewer(
                  url: fridge['data_plate_url'], // Passes the network URL from your fridge data
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.fitHeight,
                  borderRadius: BorderRadius.circular(12),
                )
                    : _buildImagePlaceholder("No data plate photo captured"),
              ],
            ),
          ),

          const Divider(height: 1),

          // Seals Section
          ...seals.map((seal) => _buildSealItemRow(seal)).toList(),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildSealItemRow(Map<String, dynamic> seal) {
    final List<dynamic> imageUrls = seal['image_urls'] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(seal['item_name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primary)),
                  // SEAL MODEL NUMBER HIGHLIGHT
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "Model: ${seal['manual_seal_name'] ?? 'Custom'}",
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Technical Specs
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSpecItem("Type", seal['seal_type'] ?? 'N/A'),
                  _buildSpecItem("Material", seal['material'] ?? 'N/A'),
                  _buildSpecItem("Size (mm)", "${seal['inner_diameter']} x ${seal['outer_diameter']}"),
                ],
              ),

              const SizedBox(height: 16),
              const Text("SEAL PHOTOS", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 8),

              // Seal Images Logic with Placeholder
              imageUrls.isNotEmpty
                  ? SizedBox(
                height: 110,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: imageUrls.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: ImagePreviewer(
                      url: imageUrls[index],
                      // FIX: Use 'imageUrls' instead of 'item.images'
                      galleryItems: imageUrls,
                      initialIndex: index,
                      width: 110,
                      height: 110,
                      fit: BoxFit.cover,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              )
                  : _buildImagePlaceholder("No seal photos available for this item", height: 60),
            ],
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }

  Widget _buildSpecItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w500)),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildImagePlaceholder(String message, {double height = 100, double width = double.infinity}) {
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
          Icon(Icons.image_not_supported_outlined, color: Colors.grey[400], size: 24),
          const SizedBox(height: 4),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500], fontSize: 11, fontStyle: FontStyle.italic),
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
            InteractiveViewer(child: Image.network(url, fit: BoxFit.contain, width: double.infinity, height: double.infinity)),
            IconButton(icon: const Icon(Icons.close, color: Colors.white, size: 30), onPressed: () => Navigator.pop(context)),
          ],
        ),
      ),
    );
  }
}
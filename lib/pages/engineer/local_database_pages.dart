import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../theme.dart';

// ==========================================
// 1. SEPARATE PAGE: CACHED CUSTOMERS LIST
// ==========================================
class LocalCustomersPage extends StatefulWidget {
  const LocalCustomersPage({super.key});

  @override
  State<LocalCustomersPage> createState() => _LocalCustomersPageState();
}

class _LocalCustomersPageState extends State<LocalCustomersPage> {
  List<dynamic> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? rawJson = prefs.getString('local_customers');
    if (mounted) {
      setState(() {
        _items = rawJson != null ? jsonDecode(rawJson) : [];
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(title: Text("Customers (${_items.length})")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (_items.isEmpty
          ? const Center(child: Text("No customers found.", style: TextStyle(color: Colors.grey)))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final client = Map<String, dynamic>.from(_items[index]);
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey[200]!)),
            child: ListTile(
              leading: CircleAvatar(backgroundColor: AppTheme.primary.withOpacity(0.1), child: const Icon(Icons.person, color: AppTheme.primary)),
              title: Text(client['full_name'] ?? 'Unnamed Client', style: const TextStyle(fontWeight: FontWeight.bold)),
              // subtitle: Text("Email: ${client['email'] ?? 'N/A'}\nAccount ID: ${client['id']}"),
              subtitle: Text("Email: ${client['email'] ?? 'N/A'}"),

            ),
          );
        },
      )),
    );
  }
}


// ==========================================
// 2. SEPARATE PAGE: MASTER FRIDGES LIST
// ==========================================
// class LocalFridgesPage extends StatefulWidget {
//   const LocalFridgesPage({super.key});
//
//   @override
//   State<LocalFridgesPage> createState() => _LocalFridgesPageState();
// }
//
// class _LocalFridgesPageState extends State<LocalFridgesPage> {
//   List<dynamic> _items = [];
//   bool _loading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadData();
//   }
//
//   void _loadData() async {
//     final prefs = await SharedPreferences.getInstance();
//     final String? rawJson = prefs.getString('local_fridges');
//     if (mounted) {
//       setState(() {
//         _items = rawJson != null ? jsonDecode(rawJson) : [];
//         _loading = false;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8F9FA),
//       appBar: AppBar(title: Text("Master Fridges List (${_items.length})")),
//       body: _loading
//           ? const Center(child: CircularProgressIndicator())
//           : (_items.isEmpty
//           ? const Center(child: Text("No master fridges cached.", style: TextStyle(color: Colors.grey)))
//           : ListView.builder(
//         padding: const EdgeInsets.all(16),
//         itemCount: _items.length,
//         itemBuilder: (context, index) {
//           final fridge = Map<String, dynamic>.from(_items[index]);
//           final int doors = fridge['door_count'] ?? 0;
//           final int drawers = fridge['drawer_count'] ?? 0;
//
//           return Card(
//             margin: const EdgeInsets.only(bottom: 12),
//             elevation: 0,
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey[200]!)),
//             child: ListTile(
//               leading: Icon(drawers > 0 && doors == 0 ? Icons.view_agenda_outlined : Icons.door_back_door_outlined, color: AppTheme.primary, size: 28),
//               title: Text("${fridge['manufacturer']} - ${fridge['model_no']}", style: const TextStyle(fontWeight: FontWeight.bold)),
//               subtitle: Text("S/N: ${fridge['serial_no'] ?? 'N/A'}\nLayout Matrix: $doors Doors / $drawers Drawers"),
//             ),
//           );
//         },
//       )),
//     );
//   }
// }



// ==========================================
// 2. SEPARATE PAGE: INTERACTIVE MASTER FRIDGES LIST
// ==========================================
class LocalFridgesPage extends StatefulWidget {
  const LocalFridgesPage({super.key});

  @override
  State<LocalFridgesPage> createState() => _LocalFridgesPageState();
}

class _LocalFridgesPageState extends State<LocalFridgesPage> {
  List<dynamic> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? rawJson = prefs.getString('local_fridges');
    if (mounted) {
      setState(() {
        _items = rawJson != null ? jsonDecode(rawJson) : [];
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(title: Text("Fridges (${_items.length})")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (_items.isEmpty
          ? const Center(child: Text("No fridges Found.", style: TextStyle(color: Colors.grey)))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final fridge = Map<String, dynamic>.from(_items[index]);
          final int doors = fridge['door_count'] ?? 0;
          final int drawers = fridge['drawer_count'] ?? 0;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey[200]!)),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                // ✅ Navigates to the comprehensive layout detail screen mapping components & seals
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LocalFridgeDetailsPage(fridge: fridge),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: ListTile(
                  leading: Icon(drawers > 0 && doors == 0 ? Icons.view_agenda_outlined : Icons.door_back_door_outlined, color: AppTheme.primary, size: 28),
                  title: Text("${fridge['manufacturer']} - ${fridge['model_no']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("S/N: ${fridge['serial_no'] ?? 'N/A'}\nLayout Matrix: $doors Doors / $drawers Drawers"),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
                ),
              ),
            ),
          );
        },
      )),
    );
  }
}

// ==========================================
// NEW SEPARATE PAGE: FRIDGE COMPONENTS & LINKED SEALS MATRIX
// ==========================================
class LocalFridgeDetailsPage extends StatefulWidget {
  final Map<String, dynamic> fridge;
  const LocalFridgeDetailsPage({super.key, required this.fridge});

  @override
  State<LocalFridgeDetailsPage> createState() => _LocalFridgeDetailsPageState();
}

class _LocalFridgeDetailsPageState extends State<LocalFridgeDetailsPage> {
  List<dynamic> _matchedComponents = [];
  List<dynamic> _matchedRelations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRelationalSpecs();
  }

  void _loadRelationalSpecs() async {
    final prefs = await SharedPreferences.getInstance();
    final String fridgeId = widget.fridge['id'].toString();

    // Read stored lists
    final List<dynamic> localComponents = jsonDecode(prefs.getString('local_fridge_components') ?? '[]');
    final List<dynamic> localRelations = jsonDecode(prefs.getString('local_fridge_relations') ?? '[]');

    if (mounted) {
      setState(() {
        // Filter out items that match our active selected fridge model ID
        _matchedComponents = localComponents.where((c) => c['fridge_id'].toString() == fridgeId).toList();
        _matchedRelations = localRelations.where((r) => r['fridge_id'].toString() == fridgeId).toList();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final int doors = widget.fridge['door_count'] ?? 0;
    final int drawers = widget.fridge['drawer_count'] ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text("${widget.fridge['manufacturer']} Structural Specs"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Top Info Identity Panel Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${widget.fridge['manufacturer']} — ${widget.fridge['model_no']}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 6),
                Text("Serial Number: ${widget.fridge['serial_no'] ?? 'N/A'}", style: const TextStyle(fontSize: 13, color: Colors.blueGrey)),
                const Divider(height: 20),
                Row(
                  children: [
                    Icon(Icons.door_back_door_outlined, size: 16, color: AppTheme.primary),
                    const SizedBox(width: 4),
                    Text("$doors Doors", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                    const SizedBox(width: 16),
                    Icon(Icons.view_agenda_outlined, size: 16, color: AppTheme.primary),
                    const SizedBox(width: 4),
                    Text("$drawers Drawers", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                  ],
                )
              ],
            ),
          ),

          const SizedBox(height: 24),
          const Text("PHYSICAL HARDWARE COMPONENTS LIST", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey, letterSpacing: 0.6)),
          const SizedBox(height: 8),

          if (_matchedComponents.isEmpty)
            _buildEmptyStateCard("No physical measurements recorded for this configuration.")
          else
            ..._matchedComponents.map((comp) {
              final isDrawer = comp['component_type'] == 'drawer';
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.grey[150] ?? const Color(0xFFEEEEEE))),
                color: const Color(0xFFFDFDFD),
                child: ListTile(
                  leading: Icon(isDrawer ? Icons.view_agenda_outlined : Icons.door_back_door_outlined, color: AppTheme.primary, size: 20),
                  title: Text("${comp['component_type'].toString().toUpperCase()} (Slot Slot index #${comp['component_index']})", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: Text("Dimensions: ${comp['width_mm']}mm Width × ${comp['height_mm']}mm Height", style: const TextStyle(fontSize: 12)),
                ),
              );
            }).toList(),

          const SizedBox(height: 24),
          const Text("MAPPED STRUCTURAL GASKET / SEAL RELATIONSHIPS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey, letterSpacing: 0.6)),
          const SizedBox(height: 8),

          if (_matchedRelations.isEmpty)
            _buildEmptyStateCard("No active seal product models mapped to these dimensions.")
          else
            ..._matchedRelations.map((rel) {
              // Extract embedded map fields populated inside the database relation model
              final product = rel['seal_products'] != null ? Map<String, dynamic>.from(rel['seal_products']) : null;

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey[200] ?? const Color(0xFFEEEEEE)),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: product == null
                      ? null
                      : () {
                    // ✅ Direct Link: Tapping the link card instantly pushes user into the full standalone seals specifications profile screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LocalSealDetailsPage(seal: product),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.link, size: 14, color: AppTheme.primary),
                                  const SizedBox(width: 6),
                                  Text(
                                    "Location Slot Placement: ${rel['location'] ?? 'Universal Matrix'}",
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.primary),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                // "Model Reference: ${product != null ? (product['title'] ?? product['seal_model_number'] ?? 'Gasket Profile') : 'Custom Handcut Mold'}\nMaterial Compound: ${product?['material'] ?? 'N/A'} | Verified Match: ${rel['is_verified'] == true ? 'YES ✅' : 'PENDING ⏳'}",
                                "Model Reference: ${product != null ? (product['title'] ?? product['seal_model_number'] ?? 'Gasket Profile') : 'Custom Handcut Mold'}\nMaterial Compound: ${product?['material'] ?? 'N/A'} ",
                                style: const TextStyle(fontSize: 12, height: 1.4, color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                        if (product != null)
                          const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.primary),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildEmptyStateCard(String noticeText) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey[200]!)),
      child: Text(noticeText, style: TextStyle(fontSize: 13, color: Colors.grey[400], fontStyle: FontStyle.italic)),
    );
  }
}

// ==========================================
// 3. SEPARATE PAGE: SEAL PRODUCTS CATALOGUE
// ==========================================
class LocalSealsPage extends StatefulWidget {
  const LocalSealsPage({super.key});

  @override
  State<LocalSealsPage> createState() => _LocalSealsPageState();
}

class _LocalSealsPageState extends State<LocalSealsPage> {
  List<dynamic> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? rawJson = prefs.getString('local_products');
    if (mounted) {
      setState(() {
        _items = rawJson != null ? jsonDecode(rawJson) : [];
        _loading = false;
      });
    }
  }

  void _navigateToSealDetails(Map<String, dynamic> seal) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LocalSealDetailsPage(seal: seal)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(title: Text("Seal Product Directory (${_items.length})")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (_items.isEmpty
          ? const Center(child: Text("No seal profiles.", style: TextStyle(color: Colors.grey)))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final seal = Map<String, dynamic>.from(_items[index]);
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey[200]!)),
            child: ListTile(
              onTap: () => _navigateToSealDetails(seal), // ✅ Linked card directly to open full details page
              leading: const Icon(Icons.qr_code_scanner_outlined, color: AppTheme.primary, size: 26),
              title: Text(seal['title'] ?? seal['seal_model_number'] ?? 'Custom Gasket', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("SKU Part: ${seal['sku'] ?? 'N/A'}\nType: ${seal['seal_type'] ?? 'N/A'} | Compound: ${seal['material'] ?? 'N/A'}"),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
            ),
          );
        },
      )),
    );
  }
}


// ==========================================
// 4. SEPARATE PAGE: FULL SEAL SPECIFICATION DETAILS
// ==========================================
class LocalSealDetailsPage extends StatelessWidget {
  final Map<String, dynamic> seal;
  const LocalSealDetailsPage({super.key, required this.seal});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text(seal['title'] ?? 'Technical Specification')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(seal['title'] ?? seal['seal_model_number'] ?? 'Custom Profile Gasket', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primary)),
                const SizedBox(height: 4),
                Text("SKU Identification: ${seal['sku'] ?? 'N/A'}", style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text("TECHNICAL PROPERTIES PROFILE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey, letterSpacing: 0.5)),
          const SizedBox(height: 10),
          _specRow("Profile Type Configuration", seal['seal_type'] ?? 'N/A'),
          _specRow("Base Material Compound", seal['material'] ?? 'N/A'),
          _specRow("Shore Hardness Rating", seal['hardness'] ?? 'N/A'),
          _specRow("Inner Extrusion Dimension", "${seal['inner_diameter'] ?? 0} mm"),
          _specRow("Outer Extrusion Dimension", "${seal['outer_diameter'] ?? 0} mm"),
          _specRow("Profile Core Thickness", "${seal['thickness'] ?? 0} mm"),
          _specRow("Thermal Operation Range", seal['temperature_range'] ?? 'Standard'),
          _specRow("Brand Origin Identity", seal['brand'] ?? 'Generic Vendor'),

          if (seal['description'] != null && seal['description'].toString().trim().isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text("APPLICATION DIRECTIVES", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFEEEEEE))),
              child: Text(seal['description'], style: const TextStyle(fontSize: 13, height: 1.4, color: Colors.black87)),
            ),
          ]
        ],
      ),
    );
  }

  Widget _specRow(String title, String val) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF5F5F5)))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 13, color: Colors.blueGrey)),
          Text(val, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
        ],
      ),
    );
  }
}
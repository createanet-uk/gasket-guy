// // // // // import 'dart:io';
// // // // // import 'package:flutter/material.dart';
// // // // // import 'package:image_picker/image_picker.dart';
// // // // // import '../../components/seal_detection_component.dart';
// // // // // import '../../theme.dart';
// // // // // import 'new_report_page.dart'; // Import your model
// // // // //
// // // // // class AddAssetPage extends StatefulWidget {
// // // // //   final Function(LocalAssetEntry) onSave;
// // // // //   const AddAssetPage({super.key, required this.onSave});
// // // // //
// // // // //
// // // // //
// // // // //   @override
// // // // //   State<AddAssetPage> createState() => _AddAssetPageState();
// // // // // }
// // // // //
// // // // //
// // // // //
// // // // // class _AddAssetPageState extends State<AddAssetPage> {
// // // // //   final LocalAssetEntry _entry = LocalAssetEntry();
// // // // //   final _picker = ImagePicker();
// // // // //
// // // // //   Widget _buildSectionTitle(String title) {
// // // // //     return Padding(
// // // // //       padding: const EdgeInsets.symmetric(vertical: 8),
// // // // //       child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.secondaryText)),
// // // // //     );
// // // // //   }
// // // // //
// // // // //   Widget _buildCounter(String label, int value, Function(int) onChanged) {
// // // // //     return Column(
// // // // //       children: [
// // // // //         Text(label, style: const TextStyle(fontSize: 12)),
// // // // //         Row(
// // // // //           children: [
// // // // //             IconButton(onPressed: () => onChanged(value > 0 ? value - 1 : 0), icon: const Icon(Icons.remove_circle_outline)),
// // // // //             Text("$value", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
// // // // //             IconButton(onPressed: () => onChanged(value + 1), icon: const Icon(Icons.add_circle_outline)),
// // // // //           ],
// // // // //         ),
// // // // //       ],
// // // // //     );
// // // // //   }
// // // // //
// // // // //   void _showSealDetection() async {
// // // // //     final result = await showModalBottomSheet<SealDetectionResult>(
// // // // //       context: context,
// // // // //       isScrollControlled: true,
// // // // //       backgroundColor: Colors.transparent,
// // // // //       builder: (context) => const SealDetectionComponent(),
// // // // //     );
// // // // //
// // // // //     if (result != null) {
// // // // //       setState(() {
// // // // //         _entry.isUnknownSeal = false;
// // // // //         _entry.manualSealName = result.label;
// // // // //         _entry.sealImage = result.images.isNotEmpty ? result.images.first : null;
// // // // //         // Store the full list of images if needed for submission
// // // // //       });
// // // // //     }
// // // // //   }
// // // // //
// // // // //   @override
// // // // //   Widget build(BuildContext context) {
// // // // //     return Scaffold(
// // // // //       appBar: AppBar(title: const Text("Add Fridge Detail")),
// // // // //       body: SingleChildScrollView(
// // // // //         padding: const EdgeInsets.all(16),
// // // // //         child: Column(
// // // // //           crossAxisAlignment: CrossAxisAlignment.start,
// // // // //           children: [
// // // // //             // 1. Area Block
// // // // //             _buildSectionTitle("LOCATION"),
// // // // //             TextField(
// // // // //               decoration: const InputDecoration(hintText: "e.g. Kitchen, Pastry, Front of House"),
// // // // //               onChanged: (val) => _entry.area = val,
// // // // //             ),
// // // // //             const SizedBox(height: 20),
// // // // //
// // // // //             // 2. Data Plate Block
// // // // //             _buildSectionTitle("FRIDGE DATA PLATE"),
// // // // //             InkWell(
// // // // //               onTap: () async {
// // // // //                 final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
// // // // //                 if (photo != null) setState(() => _entry.dataPlateImage = File(photo.path));
// // // // //               },
// // // // //               child: Container(
// // // // //                 height: 150,
// // // // //                 width: double.infinity,
// // // // //                 decoration: BoxDecoration(
// // // // //                   color: Colors.grey[200],
// // // // //                   borderRadius: BorderRadius.circular(12),
// // // // //                   image: _entry.dataPlateImage != null ? DecorationImage(image: FileImage(_entry.dataPlateImage!), fit: BoxFit.cover) : null,
// // // // //                 ),
// // // // //                 child: _entry.dataPlateImage == null ? const Icon(Icons.camera_enhance, size: 40, color: AppTheme.primary) : null,
// // // // //               ),
// // // // //             ),
// // // // //             const SizedBox(height: 20),
// // // // //
// // // // //             // 3. Seal Verification Block
// // // // //             _buildSectionTitle("SEAL IDENTIFICATION"),
// // // // //             Row(
// // // // //               children: [
// // // // //                 Expanded(
// // // // //                   child: ChoiceChip(
// // // // //                     label: const Text("Unknown (Scan)"),
// // // // //                     selected: _entry.isUnknownSeal,
// // // // //                     onSelected: (val) => setState(() => _entry.isUnknownSeal = true),
// // // // //                   ),
// // // // //                 ),
// // // // //                 const SizedBox(width: 10),
// // // // //                 Expanded(
// // // // //                   child: ChoiceChip(
// // // // //                     label: const Text("I know the Seal"),
// // // // //                     selected: !_entry.isUnknownSeal,
// // // // //                     onSelected: (val) => setState(() => _entry.isUnknownSeal = false),
// // // // //                   ),
// // // // //                 ),
// // // // //               ],
// // // // //             ),
// // // // //             if (_entry.isUnknownSeal)
// // // // //               // ElevatedButton.icon(
// // // // //               //   style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accent1),
// // // // //               //   onPressed: () {
// // // // //               //     /* Call your existing ML detection page here */
// // // // //               //   },
// // // // //               //   icon: const Icon(Icons.qr_code_scanner),
// // // // //               //   label: const Text("DETECT SEAL (ML)"),
// // // // //               // )
// // // // //
// // // // //               ElevatedButton.icon(
// // // // //                 style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accent1),
// // // // //                 onPressed: _showSealDetection, // Trigger the component
// // // // //                 icon: const Icon(Icons.qr_code_scanner),
// // // // //                 label: const Text("DETECT SEAL (ML)"),
// // // // //               )
// // // // //             else
// // // // //               TextField(
// // // // //                 decoration: const InputDecoration(hintText: "Enter Seal SKU or ID"),
// // // // //                 onChanged: (val) => _entry.manualSealName = val,
// // // // //               ),
// // // // //             const SizedBox(height: 20),
// // // // //
// // // // //             // 4. Variant Details
// // // // //             _buildSectionTitle("SEAL VARIANTS"),
// // // // //             TextField(
// // // // //               maxLines: 2,
// // // // //               decoration: const InputDecoration(hintText: "Color, Thickness, Height, Width, etc."),
// // // // //               onChanged: (val) => _entry.variantDetails = val,
// // // // //             ),
// // // // //             const SizedBox(height: 20),
// // // // //
// // // // //             // 5. Counters
// // // // //             _buildSectionTitle("QUANTITIES"),
// // // // //             Row(
// // // // //               mainAxisAlignment: MainAxisAlignment.spaceAround,
// // // // //               children: [
// // // // //                 _buildCounter("NO. OF DOORS", _entry.doorCount, (val) => setState(() => _entry.doorCount = val)),
// // // // //                 _buildCounter("NO. OF DRAWERS", _entry.drawerCount, (val) => setState(() => _entry.drawerCount = val)),
// // // // //               ],
// // // // //             ),
// // // // //             const SizedBox(height: 40),
// // // // //
// // // // //             ElevatedButton(
// // // // //               onPressed: () {
// // // // //                 widget.onSave(_entry);
// // // // //                 Navigator.pop(context);
// // // // //               },
// // // // //               child: const Text("SAVE ASSET"),
// // // // //             ),
// // // // //           ],
// // // // //         ),
// // // // //       ),
// // // // //     );
// // // // //   }
// // // // // }
// // // //
// // // //
// // // //
// // // // import 'dart:io';
// // // // import 'package:flutter/material.dart';
// // // // import 'package:image_picker/image_picker.dart';
// // // // import '../../components/seal_detection_component.dart';
// // // // import '../../theme.dart';
// // // // import 'new_report_page.dart';
// // // //
// // // // class AddAssetPage extends StatefulWidget {
// // // //   final Function(LocalAssetEntry) onSave;
// // // //   const AddAssetPage({super.key, required this.onSave});
// // // //
// // // //   @override
// // // //   State<AddAssetPage> createState() => _AddAssetPageState();
// // // // }
// // // //
// // // // class _AddAssetPageState extends State<AddAssetPage> {
// // // //   final LocalAssetEntry _entry = LocalAssetEntry();
// // // //   final _picker = ImagePicker();
// // // //
// // // //   // Helper for Section Titles
// // // //   Widget _buildSectionTitle(String title) {
// // // //     return Padding(
// // // //       padding: const EdgeInsets.only(top: 20, bottom: 8),
// // // //       child: Text(
// // // //         title,
// // // //         style: const TextStyle(
// // // //           fontWeight: FontWeight.bold,
// // // //           color: AppTheme.primary,
// // // //           letterSpacing: 1.1,
// // // //           fontSize: 13,
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }
// // // //
// // // //   // Helper for Variant Input Fields
// // // //   Widget _buildVariantField(String label, String hint, Function(String) onChanged, {bool isNumeric = false}) {
// // // //     return Padding(
// // // //       padding: const EdgeInsets.only(bottom: 12),
// // // //       child: TextField(
// // // //         keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
// // // //         decoration: InputDecoration(
// // // //           labelText: label,
// // // //           hintText: hint,
// // // //           isDense: true,
// // // //           border: const OutlineInputBorder(),
// // // //         ),
// // // //         onChanged: onChanged,
// // // //       ),
// // // //     );
// // // //   }
// // // //
// // // //   // Helper for Counters
// // // //   Widget _buildCounter(String label, int value, Function(int) onChanged) {
// // // //     return Column(
// // // //       children: [
// // // //         Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
// // // //         Row(
// // // //           mainAxisSize: MainAxisSize.min,
// // // //           children: [
// // // //             IconButton(
// // // //               onPressed: () => onChanged(value > 0 ? value - 1 : 0),
// // // //               icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
// // // //             ),
// // // //             Container(
// // // //               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
// // // //               decoration: BoxDecoration(
// // // //                 border: Border.all(color: Colors.grey[300]!),
// // // //                 borderRadius: BorderRadius.circular(8),
// // // //               ),
// // // //               child: Text("$value", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
// // // //             ),
// // // //             IconButton(
// // // //               onPressed: () => onChanged(value + 1),
// // // //               icon: const Icon(Icons.add_circle_outline, color: Colors.green),
// // // //             ),
// // // //           ],
// // // //         ),
// // // //       ],
// // // //     );
// // // //   }
// // // //
// // // //   void _showSealDetection() async {
// // // //     final result = await showModalBottomSheet<SealDetectionResult>(
// // // //       context: context,
// // // //       isScrollControlled: true,
// // // //       backgroundColor: Colors.transparent,
// // // //       builder: (context) => const SealDetectionComponent(),
// // // //     );
// // // //
// // // //     if (result != null) {
// // // //       setState(() {
// // // //         _entry.isUnknownSeal = false;
// // // //         _entry.manualSealName = result.label;
// // // //         _entry.sealImage = result.images.isNotEmpty ? result.images.first : null;
// // // //         _entry.allSealImages = result.images; // Store all for submission
// // // //         _entry.confidence = result.confidence;
// // // //       });
// // // //     }
// // // //   }
// // // //
// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return Scaffold(
// // // //       backgroundColor: Colors.white,
// // // //       appBar: AppBar(
// // // //         title: const Text("Add Fridge Detail"),
// // // //         elevation: 0,
// // // //       ),
// // // //       body: SingleChildScrollView(
// // // //         padding: const EdgeInsets.all(16),
// // // //         child: Column(
// // // //           crossAxisAlignment: CrossAxisAlignment.start,
// // // //           children: [
// // // //             // 1. Area Block
// // // //             _buildSectionTitle("1. LOCATION"),
// // // //             TextField(
// // // //               decoration: const InputDecoration(
// // // //                 hintText: "e.g. Main Kitchen, Pastry Area",
// // // //                 prefixIcon: Icon(Icons.location_on_outlined),
// // // //               ),
// // // //               onChanged: (val) => _entry.area = val,
// // // //             ),
// // // //
// // // //             // 2. Data Plate Block
// // // //             _buildSectionTitle("2. FRIDGE DATA PLATE"),
// // // //             InkWell(
// // // //               onTap: () async {
// // // //                 final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
// // // //                 if (photo != null) setState(() => _entry.dataPlateImage = File(photo.path));
// // // //               },
// // // //               child: Container(
// // // //                 height: 150,
// // // //                 width: double.infinity,
// // // //                 decoration: BoxDecoration(
// // // //                   color: Colors.grey[50],
// // // //                   borderRadius: BorderRadius.circular(12),
// // // //                   border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
// // // //                   image: _entry.dataPlateImage != null
// // // //                       ? DecorationImage(image: FileImage(_entry.dataPlateImage!), fit: BoxFit.cover)
// // // //                       : null,
// // // //                 ),
// // // //                 child: _entry.dataPlateImage == null
// // // //                     ? const Column(
// // // //                   mainAxisAlignment: MainAxisAlignment.center,
// // // //                   children: [
// // // //                     Icon(Icons.camera_enhance_outlined, size: 40, color: Colors.grey),
// // // //                     Text("Tap to capture Data Plate", style: TextStyle(color: Colors.grey, fontSize: 12)),
// // // //                   ],
// // // //                 )
// // // //                     : const Align(
// // // //                   alignment: Alignment.bottomRight,
// // // //                   child: Padding(
// // // //                     padding: EdgeInsets.all(8.0),
// // // //                     child: CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.edit, size: 20)),
// // // //                   ),
// // // //                 ),
// // // //               ),
// // // //             ),
// // // //
// // // //             // 3. Seal Identification Block
// // // //             _buildSectionTitle("3. SEAL IDENTIFICATION"),
// // // //             Row(
// // // //               children: [
// // // //                 Expanded(
// // // //                   child: ChoiceChip(
// // // //                     label: const Center(child: Text("Scan (ML)")),
// // // //                     selected: _entry.isUnknownSeal || _entry.sealImage != null,
// // // //                     onSelected: (val) => setState(() => _entry.isUnknownSeal = true),
// // // //                   ),
// // // //                 ),
// // // //                 const SizedBox(width: 10),
// // // //                 Expanded(
// // // //                   child: ChoiceChip(
// // // //                     label: const Center(child: Text("Manual Entry")),
// // // //                     selected: !_entry.isUnknownSeal && _entry.sealImage == null,
// // // //                     onSelected: (val) {
// // // //                       setState(() {
// // // //                         _entry.isUnknownSeal = false;
// // // //                         _entry.sealImage = null;
// // // //                         _entry.manualSealName = "";
// // // //                       });
// // // //                     },
// // // //                   ),
// // // //                 ),
// // // //               ],
// // // //             ),
// // // //             const SizedBox(height: 12),
// // // //
// // // //             // Display ML Result if exists
// // // //             if (_entry.sealImage != null)
// // // //               Container(
// // // //                 padding: const EdgeInsets.all(12),
// // // //                 margin: const EdgeInsets.only(bottom: 12),
// // // //                 decoration: BoxDecoration(
// // // //                   color: Colors.green[50],
// // // //                   borderRadius: BorderRadius.circular(12),
// // // //                   border: Border.all(color: Colors.green[200]!),
// // // //                 ),
// // // //                 child: Row(
// // // //                   children: [
// // // //                     ClipRRect(
// // // //                       borderRadius: BorderRadius.circular(8),
// // // //                       child: Image.file(_entry.sealImage!, width: 60, height: 60, fit: BoxFit.cover),
// // // //                     ),
// // // //                     const SizedBox(width: 12),
// // // //                     Expanded(
// // // //                       child: Column(
// // // //                         crossAxisAlignment: CrossAxisAlignment.start,
// // // //                         children: [
// // // //                           Text(_entry.manualSealName ?? "Detected Seal",
// // // //                               style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
// // // //                           Text("Confidence: ${(_entry.confidence * 100).toStringAsFixed(1)}%",
// // // //                               style: TextStyle(color: Colors.green[700], fontSize: 12)),
// // // //                         ],
// // // //                       ),
// // // //                     ),
// // // //                     IconButton(
// // // //                       onPressed: _showSealDetection,
// // // //                       icon: const Icon(Icons.refresh, color: Colors.green),
// // // //                     )
// // // //                   ],
// // // //                 ),
// // // //               )
// // // //             else if (_entry.isUnknownSeal)
// // // //               ElevatedButton.icon(
// // // //                 style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accent1, minimumSize: const Size(double.infinity, 50)),
// // // //                 onPressed: _showSealDetection,
// // // //                 icon: const Icon(Icons.qr_code_scanner),
// // // //                 label: const Text("OPEN ML SCANNER"),
// // // //               )
// // // //             else
// // // //               TextField(
// // // //                 decoration: const InputDecoration(hintText: "Enter Seal SKU or ID Manually"),
// // // //                 onChanged: (val) => _entry.manualSealName = val,
// // // //               ),
// // // //
// // // //             // 4. Detailed Variant Details
// // // //             _buildSectionTitle("4. SEAL VARIANTS & SPECS"),
// // // //             SwitchListTile(
// // // //               title: const Text("Magnetic Seal?", style: TextStyle(fontSize: 14)),
// // // //               value: _entry.isMagnetic,
// // // //               onChanged: (val) => setState(() => _entry.isMagnetic = val),
// // // //               activeColor: AppTheme.primary,
// // // //             ),
// // // //             const SizedBox(height: 8),
// // // //             _buildVariantField("Seal Type", "e.g. Compression, Dart", (val) => _entry.sealType = val),
// // // //             _buildVariantField("Material", "e.g. PVC, Rubber", (val) => _entry.material = val),
// // // //             _buildVariantField("Hardness", "e.g. 70 Shore A", (val) => _entry.hardness = val),
// // // //
// // // //             Row(
// // // //               children: [
// // // //                 Expanded(child: _buildVariantField("Inner Dia", "mm", (val) => _entry.innerDiameter = double.tryParse(val) ?? 0, isNumeric: true)),
// // // //                 const SizedBox(width: 10),
// // // //                 Expanded(child: _buildVariantField("Outer Dia", "mm", (val) => _entry.outerDiameter = double.tryParse(val) ?? 0, isNumeric: true)),
// // // //               ],
// // // //             ),
// // // //             Row(
// // // //               children: [
// // // //                 Expanded(child: _buildVariantField("Thickness", "mm", (val) => _entry.thickness = double.tryParse(val) ?? 0, isNumeric: true)),
// // // //                 const SizedBox(width: 10),
// // // //                 Expanded(child: _buildVariantField("Model #", "Seal Model", (val) => _entry.sealModelNumber = val)),
// // // //               ],
// // // //             ),
// // // //
// // // //             _buildVariantField("Temperature Range", "e.g. -20C to 80C", (val) => _entry.tempRange = val),
// // // //             _buildVariantField("Brand", "e.g. Foster, Polar", (val) => _entry.brand = val),
// // // //             _buildVariantField("Application", "e.g. Walk-in Fridge", (val) => _entry.application = val),
// // // //
// // // //             TextField(
// // // //               maxLines: 3,
// // // //               decoration: const InputDecoration(labelText: "Description/Notes", border: OutlineInputBorder()),
// // // //               onChanged: (val) => _entry.description = val,
// // // //             ),
// // // //
// // // //             // 5. Counters
// // // //             _buildSectionTitle("5. QUANTITIES"),
// // // //             Container(
// // // //               padding: const EdgeInsets.all(16),
// // // //               decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)),
// // // //               child: Row(
// // // //                 mainAxisAlignment: MainAxisAlignment.spaceAround,
// // // //                 children: [
// // // //                   _buildCounter("DOORS", _entry.doorCount, (val) => setState(() => _entry.doorCount = val)),
// // // //                   _buildCounter("DRAWERS", _entry.drawerCount, (val) => setState(() => _entry.drawerCount = val)),
// // // //                 ],
// // // //               ),
// // // //             ),
// // // //
// // // //             const SizedBox(height: 40),
// // // //
// // // //             ElevatedButton(
// // // //               style: ElevatedButton.styleFrom(
// // // //                 minimumSize: const Size(double.infinity, 60),
// // // //                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// // // //               ),
// // // //               onPressed: () {
// // // //                 if (_entry.area.isEmpty) {
// // // //                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter a location")));
// // // //                   return;
// // // //                 }
// // // //                 widget.onSave(_entry);
// // // //                 Navigator.pop(context);
// // // //               },
// // // //               child: const Text("SAVE FRIDGE ASSET", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
// // // //             ),
// // // //             const SizedBox(height: 20),
// // // //           ],
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }
// // // // }
// // //
// // //
// // // import 'dart:convert';
// // // import 'dart:io';
// // // import 'package:flutter/material.dart';
// // // import 'package:image_picker/image_picker.dart';
// // // import 'package:shared_preferences/shared_preferences.dart';
// // // import '../../components/seal_detection_component.dart';
// // // import '../../theme.dart';
// // // import 'new_report_page.dart';
// // //
// // // class AddAssetPage extends StatefulWidget {
// // //   final Function(LocalAssetEntry) onSave;
// // //   const AddAssetPage({super.key, required this.onSave});
// // //
// // //   @override
// // //   State<AddAssetPage> createState() => _AddAssetPageState();
// // // }
// // //
// // // class _AddAssetPageState extends State<AddAssetPage> {
// // //   final LocalAssetEntry _entry = LocalAssetEntry();
// // //   final _picker = ImagePicker();
// // //
// // //   // Controllers to allow programmatic updates (Auto-fill)
// // //   final Map<String, TextEditingController> _controllers = {
// // //     'type': TextEditingController(),
// // //     'material': TextEditingController(),
// // //     'hardness': TextEditingController(),
// // //     'inner': TextEditingController(),
// // //     'outer': TextEditingController(),
// // //     'thickness': TextEditingController(),
// // //     'modelNum': TextEditingController(),
// // //     'temp': TextEditingController(),
// // //     'brand': TextEditingController(),
// // //     'app': TextEditingController(),
// // //     'desc': TextEditingController(),
// // //   };
// // //
// // //   @override
// // //   void dispose() {
// // //     _controllers.forEach((key, controller) => controller.dispose());
// // //     super.dispose();
// // //   }
// // //
// // //   // --- AUTO-FILL LOGIC ---
// // //   Future<void> _autoFillFromDatabase(String sealLabel) async {
// // //     try {
// // //       final prefs = await SharedPreferences.getInstance();
// // //       final String? productsJson = prefs.getString('local_products');
// // //
// // //       if (productsJson != null) {
// // //         final List<dynamic> products = jsonDecode(productsJson);
// // //
// // //         // Find the product where title or sku matches the ML label
// // //         final product = products.firstWhere(
// // //               (p) => p['title'].toString().toLowerCase() == sealLabel.toLowerCase() ||
// // //               p['sku'].toString().toLowerCase() == sealLabel.toLowerCase(),
// // //           orElse: () => null,
// // //         );
// // //
// // //         if (product != null) {
// // //           setState(() {
// // //             _entry.isMagnetic = product['is_magnetic'] ?? false;
// // //             _entry.sealType = product['seal_type'] ?? '';
// // //             _entry.material = product['material'] ?? '';
// // //             _entry.hardness = product['hardness'] ?? '';
// // //             _entry.innerDiameter = (product['inner_diameter'] ?? 0).toDouble();
// // //             _entry.outerDiameter = (product['outer_diameter'] ?? 0).toDouble();
// // //             _entry.thickness = (product['thickness'] ?? 0).toDouble();
// // //             _entry.tempRange = product['temperature_range'] ?? '';
// // //             _entry.brand = product['brand'] ?? '';
// // //             _entry.application = product['application'] ?? '';
// // //             _entry.description = product['description'] ?? '';
// // //             _entry.sealModelNumber = product['seal_model_number'] ?? '';
// // //
// // //             // Update Controllers so UI shows the values
// // //             _controllers['type']!.text = _entry.sealType!;
// // //             _controllers['material']!.text = _entry.material!;
// // //             _controllers['hardness']!.text = _entry.hardness!;
// // //             _controllers['inner']!.text = _entry.innerDiameter.toString();
// // //             _controllers['outer']!.text = _entry.outerDiameter.toString();
// // //             _controllers['thickness']!.text = _entry.thickness.toString();
// // //             _controllers['modelNum']!.text = _entry.sealModelNumber!;
// // //             _controllers['temp']!.text = _entry.tempRange!;
// // //             _controllers['brand']!.text = _entry.brand!;
// // //             _controllers['app']!.text = _entry.application!;
// // //             _controllers['desc']!.text = _entry.description!;
// // //           });
// // //
// // //           ScaffoldMessenger.of(context).showSnackBar(
// // //             const SnackBar(content: Text("Specs auto-filled from database"), duration: Duration(seconds: 1)),
// // //           );
// // //         }
// // //       }
// // //     } catch (e) {
// // //       debugPrint("Auto-fill error: $e");
// // //     }
// // //   }
// // //
// // //   void _showSealDetection() async {
// // //     final result = await showModalBottomSheet<SealDetectionResult>(
// // //       context: context,
// // //       isScrollControlled: true,
// // //       backgroundColor: Colors.transparent,
// // //       builder: (context) => const SealDetectionComponent(),
// // //     );
// // //
// // //     if (result != null) {
// // //       setState(() {
// // //         _entry.isUnknownSeal = false;
// // //         _entry.manualSealName = result.label;
// // //         _entry.sealImage = result.images.isNotEmpty ? result.images.first : null;
// // //         _entry.allSealImages = result.images;
// // //         _entry.confidence = result.confidence;
// // //       });
// // //
// // //       // TRIGGER AUTO-FILL
// // //       _autoFillFromDatabase(result.label);
// // //     }
// // //   }
// // //
// // //   // --- UI BUILDERS ---
// // //   Widget _buildSectionTitle(String title) {
// // //     return Padding(
// // //       padding: const EdgeInsets.only(top: 20, bottom: 8),
// // //       child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary, letterSpacing: 1.1, fontSize: 13)),
// // //     );
// // //   }
// // //
// // //   Widget _buildVariantField(String label, String hint, TextEditingController controller, Function(String) onChanged, {bool isNumeric = false}) {
// // //     return Padding(
// // //       padding: const EdgeInsets.only(bottom: 12),
// // //       child: TextField(
// // //         controller: controller, // Use controller for auto-fill support
// // //         keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
// // //         decoration: InputDecoration(
// // //           labelText: label,
// // //           hintText: hint,
// // //           isDense: true,
// // //           border: const OutlineInputBorder(),
// // //         ),
// // //         onChanged: onChanged,
// // //       ),
// // //     );
// // //   }
// // //
// // //   Widget _buildCounter(String label, int value, Function(int) onChanged) {
// // //     return Column(
// // //       children: [
// // //         Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
// // //         Row(
// // //           mainAxisSize: MainAxisSize.min,
// // //           children: [
// // //             IconButton(onPressed: () => onChanged(value > 0 ? value - 1 : 0), icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent)),
// // //             Container(
// // //               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
// // //               decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(8)),
// // //               child: Text("$value", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
// // //             ),
// // //             IconButton(onPressed: () => onChanged(value + 1), icon: const Icon(Icons.add_circle_outline, color: Colors.green)),
// // //           ],
// // //         ),
// // //       ],
// // //     );
// // //   }
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       backgroundColor: Colors.white,
// // //       appBar: AppBar(title: const Text("Add Asset Detail"), elevation: 0),
// // //       body: SingleChildScrollView(
// // //         padding: const EdgeInsets.all(16),
// // //         child: Column(
// // //           crossAxisAlignment: CrossAxisAlignment.start,
// // //           children: [
// // //             _buildSectionTitle("1. LOCATION"),
// // //             TextField(
// // //               decoration: const InputDecoration(hintText: "e.g. Main Kitchen", prefixIcon: Icon(Icons.location_on_outlined)),
// // //               onChanged: (val) => _entry.area = val,
// // //             ),
// // //
// // //             _buildSectionTitle("2. FRIDGE DATA PLATE"),
// // //             InkWell(
// // //               onTap: () async {
// // //                 final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
// // //                 if (photo != null) setState(() => _entry.dataPlateImage = File(photo.path));
// // //               },
// // //               child: Container(
// // //                 height: 150, width: double.infinity,
// // //                 decoration: BoxDecoration(
// // //                   color: Colors.grey[50], borderRadius: BorderRadius.circular(12),
// // //                   border: Border.all(color: Colors.grey[300]!),
// // //                   image: _entry.dataPlateImage != null ? DecorationImage(image: FileImage(_entry.dataPlateImage!), fit: BoxFit.cover) : null,
// // //                 ),
// // //                 child: _entry.dataPlateImage == null
// // //                     ? const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.camera_enhance_outlined, size: 40, color: Colors.grey), Text("Tap to capture Data Plate", style: TextStyle(color: Colors.grey, fontSize: 12))])
// // //                     : const Align(alignment: Alignment.bottomRight, child: Padding(padding: EdgeInsets.all(8.0), child: CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.edit, size: 20)))),
// // //               ),
// // //             ),
// // //
// // //             _buildSectionTitle("3. SEAL IDENTIFICATION"),
// // //             Row(
// // //               children: [
// // //                 Expanded(child: ChoiceChip(label: const Center(child: Text("Scan (ML)")), selected: _entry.isUnknownSeal || _entry.sealImage != null, onSelected: (val) => setState(() => _entry.isUnknownSeal = true))),
// // //                 const SizedBox(width: 10),
// // //                 Expanded(child: ChoiceChip(label: const Center(child: Text("Manual Entry")), selected: !_entry.isUnknownSeal && _entry.sealImage == null, onSelected: (val) { setState(() { _entry.isUnknownSeal = false; _entry.sealImage = null; _entry.manualSealName = ""; }); })),
// // //               ],
// // //             ),
// // //             const SizedBox(height: 12),
// // //
// // //             if (_entry.sealImage != null)
// // //               Container(
// // //                 padding: const EdgeInsets.all(12), margin: const EdgeInsets.only(bottom: 12),
// // //                 decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.green[200]!)),
// // //                 child: Row(children: [
// // //                   ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(_entry.sealImage!, width: 60, height: 60, fit: BoxFit.cover)),
// // //                   const SizedBox(width: 12),
// // //                   Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(_entry.manualSealName ?? "Detected Seal", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), Text("Confidence: ${(_entry.confidence * 100).toStringAsFixed(1)}%", style: TextStyle(color: Colors.green[700], fontSize: 12))])),
// // //                   IconButton(onPressed: _showSealDetection, icon: const Icon(Icons.refresh, color: Colors.green))
// // //                 ]),
// // //               )
// // //             else if (_entry.isUnknownSeal)
// // //               ElevatedButton.icon(
// // //                 style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accent1, minimumSize: const Size(double.infinity, 50)),
// // //                 onPressed: _showSealDetection,
// // //                 icon: const Icon(Icons.qr_code_scanner),
// // //                 label: const Text("OPEN ML SCANNER"),
// // //               )
// // //             else
// // //               TextField(
// // //                 decoration: const InputDecoration(hintText: "Enter Seal SKU or ID Manually"),
// // //                 onChanged: (val) {
// // //                   _entry.manualSealName = val;
// // //                   _autoFillFromDatabase(val); // Try to auto-fill even during manual typing
// // //                 },
// // //               ),
// // //
// // //             _buildSectionTitle("4. SEAL VARIANTS & SPECS"),
// // //             SwitchListTile(
// // //               title: const Text("Magnetic Seal?", style: TextStyle(fontSize: 14)),
// // //               value: _entry.isMagnetic,
// // //               onChanged: (val) => setState(() => _entry.isMagnetic = val),
// // //               activeColor: AppTheme.primary,
// // //             ),
// // //             _buildVariantField("Seal Type", "e.g. Compression", _controllers['type']!, (val) => _entry.sealType = val),
// // //             _buildVariantField("Material", "e.g. PVC", _controllers['material']!, (val) => _entry.material = val),
// // //             _buildVariantField("Hardness", "e.g. 70 Shore", _controllers['hardness']!, (val) => _entry.hardness = val),
// // //
// // //             Row(children: [
// // //               Expanded(child: _buildVariantField("Inner Dia", "mm", _controllers['inner']!, (val) => _entry.innerDiameter = double.tryParse(val) ?? 0, isNumeric: true)),
// // //               const SizedBox(width: 10),
// // //               Expanded(child: _buildVariantField("Outer Dia", "mm", _controllers['outer']!, (val) => _entry.outerDiameter = double.tryParse(val) ?? 0, isNumeric: true)),
// // //             ]),
// // //             Row(children: [
// // //               Expanded(child: _buildVariantField("Thickness", "mm", _controllers['thickness']!, (val) => _entry.thickness = double.tryParse(val) ?? 0, isNumeric: true)),
// // //               const SizedBox(width: 10),
// // //               Expanded(child: _buildVariantField("Model #", "Seal Model", _controllers['modelNum']!, (val) => _entry.sealModelNumber = val)),
// // //             ]),
// // //
// // //             _buildVariantField("Temperature Range", "e.g. -20C to 80C", _controllers['temp']!, (val) => _entry.tempRange = val),
// // //             _buildVariantField("Brand", "e.g. Foster", _controllers['brand']!, (val) => _entry.brand = val),
// // //             _buildVariantField("Application", "e.g. Fridge", _controllers['app']!, (val) => _entry.application = val),
// // //
// // //             TextField(
// // //               controller: _controllers['desc'],
// // //               maxLines: 3,
// // //               decoration: const InputDecoration(labelText: "Description/Notes", border: OutlineInputBorder()),
// // //               onChanged: (val) => _entry.description = val,
// // //             ),
// // //
// // //             _buildSectionTitle("5. QUANTITIES"),
// // //             Container(
// // //               padding: const EdgeInsets.all(16),
// // //               decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)),
// // //               child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
// // //                 _buildCounter("DOORS", _entry.doorCount, (val) => setState(() => _entry.doorCount = val)),
// // //                 _buildCounter("DRAWERS", _entry.drawerCount, (val) => setState(() => _entry.drawerCount = val)),
// // //               ]),
// // //             ),
// // //
// // //             const SizedBox(height: 40),
// // //             ElevatedButton(
// // //               style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 60), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
// // //               onPressed: () {
// // //                 if (_entry.area.isEmpty) {
// // //                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter a location")));
// // //                   return;
// // //                 }
// // //                 widget.onSave(_entry);
// // //                 Navigator.pop(context);
// // //               },
// // //               child: const Text("SAVE FRIDGE ASSET", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
// // //             ),
// // //             const SizedBox(height: 20),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }
// //
// //
// //
// // import 'dart:convert';
// // import 'dart:io';
// // import 'package:flutter/material.dart';
// // import 'package:image_picker/image_picker.dart';
// // import 'package:shared_preferences/shared_preferences.dart';
// // import '../../components/seal_detection_component.dart';
// // import '../../theme.dart';
// // import 'new_report_page.dart';
// //
// // class AddAssetPage extends StatefulWidget {
// //   final Function(LocalAssetEntry) onSave;
// //   const AddAssetPage({super.key, required this.onSave});
// //
// //   @override
// //   State<AddAssetPage> createState() => _AddAssetPageState();
// // }
// //
// // class _AddAssetPageState extends State<AddAssetPage> {
// //   final LocalAssetEntry _entry = LocalAssetEntry();
// //   final _picker = ImagePicker();
// //
// //   // Controllers for all variant fields
// //   final Map<String, TextEditingController> _controllers = {
// //     'type': TextEditingController(),
// //     'material': TextEditingController(),
// //     'hardness': TextEditingController(),
// //     'inner': TextEditingController(),
// //     'outer': TextEditingController(),
// //     'thickness': TextEditingController(),
// //     'modelNum': TextEditingController(),
// //     'temp': TextEditingController(),
// //     'brand': TextEditingController(),
// //     'app': TextEditingController(),
// //     'desc': TextEditingController(),
// //   };
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     // Initialize the list with at least one item
// //     _syncIndividualItemsList();
// //   }
// //
// //   @override
// //   void dispose() {
// //     _controllers.forEach((key, controller) => controller.dispose());
// //     super.dispose();
// //   }
// //
// //   // --- FIXED LOGIC: Syncs list without losing already scanned data ---
// //   void _syncIndividualItemsList() {
// //     int totalNeeded = _entry.doorCount + _entry.drawerCount;
// //     if (_entry.sealsAreCommon) {
// //       if (_entry.individualSeals.isEmpty) {
// //         _entry.individualSeals = [IndividualSeal(itemName: "Common Seal")];
// //       }
// //     } else {
// //       // Create a temporary list to hold results
// //       List<IndividualSeal> newList = [];
// //       for (int i = 0; i < totalNeeded; i++) {
// //         String label = i < _entry.doorCount
// //             ? "Door ${i + 1}"
// //             : "Drawer ${i - _entry.doorCount + 1}";
// //
// //         // If we already have data for this index, keep it, otherwise create new
// //         if (i < _entry.individualSeals.length) {
// //           newList.add(_entry.individualSeals[i]);
// //         } else {
// //           newList.add(IndividualSeal(itemName: label));
// //         }
// //       }
// //       _entry.individualSeals = newList;
// //     }
// //   }
// //
// //   Future<void> _autoFillFromDatabase(String sealLabel, {int? itemIndex}) async {
// //     try {
// //       final prefs = await SharedPreferences.getInstance();
// //       final String? productsJson = prefs.getString('local_products');
// //       if (productsJson == null) return;
// //
// //       final List<dynamic> products = jsonDecode(productsJson);
// //       final product = products.firstWhere(
// //             (p) => p['title'].toString().toLowerCase() == sealLabel.toLowerCase() ||
// //             p['sku'].toString().toLowerCase() == sealLabel.toLowerCase(),
// //         orElse: () => null,
// //       );
// //
// //       if (product != null) {
// //         setState(() {
// //           // Update the specific item specs
// //           int idx = itemIndex ?? 0;
// //           if (_entry.individualSeals.isNotEmpty) {
// //             var item = _entry.individualSeals[idx];
// //             item.sealId = product['id'].toString();
// //             item.sealName = product['title'];
// //           }
// //
// //           // Always update Global Variant Fields for the report
// //           _entry.isMagnetic = product['is_magnetic'] ?? false;
// //           _entry.sealType = product['seal_type'] ?? '';
// //           _entry.material = product['material'] ?? '';
// //           _entry.hardness = product['hardness'] ?? '';
// //           _entry.innerDiameter = (product['inner_diameter'] ?? 0).toDouble();
// //           _entry.outerDiameter = (product['outer_diameter'] ?? 0).toDouble();
// //           _entry.thickness = (product['thickness'] ?? 0).toDouble();
// //           _entry.tempRange = product['temperature_range'] ?? '';
// //           _entry.brand = product['brand'] ?? '';
// //           _entry.application = product['application'] ?? '';
// //           _entry.sealModelNumber = product['seal_model_number'] ?? '';
// //
// //           _controllers['type']!.text = _entry.sealType!;
// //           _controllers['material']!.text = _entry.material!;
// //           _controllers['hardness']!.text = _entry.hardness!;
// //           _controllers['inner']!.text = _entry.innerDiameter.toString();
// //           _controllers['outer']!.text = _entry.outerDiameter.toString();
// //           _controllers['thickness']!.text = _entry.thickness.toString();
// //           _controllers['modelNum']!.text = _entry.sealModelNumber!;
// //           _controllers['temp']!.text = _entry.tempRange!;
// //           _controllers['brand']!.text = _entry.brand!;
// //           _controllers['app']!.text = _entry.application!;
// //         });
// //       }
// //     } catch (e) {
// //       debugPrint("Auto-fill error: $e");
// //     }
// //   }
// //
// //   void _showSealDetection(int index) async {
// //     final result = await showModalBottomSheet<SealDetectionResult>(
// //       context: context,
// //       isScrollControlled: true,
// //       backgroundColor: Colors.transparent,
// //       builder: (context) => const SealDetectionComponent(),
// //     );
// //
// //     if (result != null) {
// //       setState(() {
// //         var item = _entry.individualSeals[index];
// //         item.isIdentified = true;
// //         item.sealName = result.label;
// //         item.images = result.images;
// //         item.confidence = result.confidence;
// //
// //         // If common, set the main seal image for the preview
// //         if (_entry.sealsAreCommon) {
// //           _entry.sealImage = result.images.isNotEmpty ? result.images.first : null;
// //           _entry.isUnknownSeal = false;
// //         }
// //       });
// //       _autoFillFromDatabase(result.label, itemIndex: index);
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: Colors.white,
// //       appBar: AppBar(title: const Text("Add Asset Detail"), elevation: 0),
// //       body: SingleChildScrollView(
// //         padding: const EdgeInsets.all(16),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             _sectionHeader("1. LOCATION"),
// //             TextField(
// //               decoration: const InputDecoration(hintText: "e.g. Main Kitchen", border: OutlineInputBorder()),
// //               onChanged: (val) => _entry.area = val,
// //             ),
// //
// //             _sectionHeader("2. DATA PLATE"),
// //             _buildDataPlatePicker(),
// //
// //             _sectionHeader("3. QUANTITIES"),
// //             Container(
// //               padding: const EdgeInsets.all(12),
// //               decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)),
// //               child: Row(
// //                 mainAxisAlignment: MainAxisAlignment.spaceAround,
// //                 children: [
// //                   _buildCounter("DOORS", _entry.doorCount, (val) {
// //                     setState(() { _entry.doorCount = val; _syncIndividualItemsList(); });
// //                   }),
// //                   _buildCounter("DRAWERS", _entry.drawerCount, (val) {
// //                     setState(() { _entry.drawerCount = val; _syncIndividualItemsList(); });
// //                   }),
// //                 ],
// //               ),
// //             ),
// //
// //             _sectionHeader("4. SEAL CONFIGURATION"),
// //             SwitchListTile(
// //               title: const Text("All items use the same seal?"),
// //               value: _entry.sealsAreCommon,
// //               activeColor: AppTheme.primary,
// //               onChanged: (val) {
// //                 setState(() {
// //                   _entry.sealsAreCommon = val;
// //                   _syncIndividualItemsList();
// //                 });
// //               },
// //             ),
// //
// //             const Divider(),
// //
// //             // DYNAMIC IDENTIFICATION BLOCKS
// //             ...List.generate(_entry.individualSeals.length, (index) {
// //               return _buildItemCard(index, _entry.individualSeals[index]);
// //             }),
// //
// //             _sectionHeader("5. SEAL VARIANTS & SPECS"),
// //             SwitchListTile(
// //               title: const Text("Magnetic Seal?"),
// //               value: _entry.isMagnetic,
// //               onChanged: (val) => setState(() => _entry.isMagnetic = val),
// //               activeColor: AppTheme.primary,
// //             ),
// //             _variantInput("Seal Type", _controllers['type']!, (v) => _entry.sealType = v),
// //             _variantInput("Material", _controllers['material']!, (v) => _entry.material = v),
// //             _variantInput("Hardness", _controllers['hardness']!, (v) => _entry.hardness = v),
// //
// //             Row(children: [
// //               Expanded(child: _variantInput("Inner Dia", _controllers['inner']!, (v) => _entry.innerDiameter = double.tryParse(v) ?? 0, isNum: true)),
// //               const SizedBox(width: 10),
// //               Expanded(child: _variantInput("Outer Dia", _controllers['outer']!, (v) => _entry.outerDiameter = double.tryParse(v) ?? 0, isNum: true)),
// //             ]),
// //             Row(children: [
// //               Expanded(child: _variantInput("Thickness", _controllers['thickness']!, (v) => _entry.thickness = double.tryParse(v) ?? 0, isNum: true)),
// //               const SizedBox(width: 10),
// //               Expanded(child: _variantInput("Model #", _controllers['modelNum']!, (v) => _entry.sealModelNumber = v)),
// //             ]),
// //
// //             _variantInput("Temperature Range", _controllers['temp']!, (v) => _entry.tempRange = v),
// //             _variantInput("Brand", _controllers['brand']!, (v) => _entry.brand = v),
// //             _variantInput("Application", _controllers['app']!, (v) => _entry.application = v),
// //
// //             TextField(
// //               controller: _controllers['desc'],
// //               maxLines: 3,
// //               decoration: const InputDecoration(labelText: "Description/Notes", border: OutlineInputBorder()),
// //               onChanged: (val) => _entry.description = val,
// //             ),
// //
// //             const SizedBox(height: 40),
// //             ElevatedButton(
// //               style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 60)),
// //               onPressed: () {
// //                 if (_entry.area.isEmpty) {
// //                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter a location")));
// //                   return;
// //                 }
// //                 widget.onSave(_entry);
// //                 Navigator.pop(context);
// //               },
// //               child: const Text("SAVE FRIDGE ASSET", style: TextStyle(fontWeight: FontWeight.bold)),
// //             ),
// //             const SizedBox(height: 20),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildItemCard(int index, IndividualSeal item) {
// //     return Card(
// //       margin: const EdgeInsets.only(bottom: 12),
// //       color: item.isIdentified ? Colors.green[50] : Colors.grey[50],
// //       child: Padding(
// //         padding: const EdgeInsets.all(12.0),
// //         child: Column(
// //           children: [
// //             Row(children: [
// //               Icon(item.isIdentified ? Icons.check_circle : Icons.qr_code_scanner, color: item.isIdentified ? Colors.green : Colors.grey),
// //               const SizedBox(width: 8),
// //               Text(item.itemName, style: const TextStyle(fontWeight: FontWeight.bold)),
// //             ]),
// //             if (item.images.isNotEmpty) ...[
// //               const SizedBox(height: 10),
// //               SizedBox(
// //                 height: 60,
// //                 child: ListView.builder(
// //                   scrollDirection: Axis.horizontal,
// //                   itemCount: item.images.length,
// //                   itemBuilder: (c, i) => Padding(
// //                     padding: const EdgeInsets.only(right: 8),
// //                     child: ClipRRect(borderRadius: BorderRadius.circular(6), child: Image.file(item.images[i], width: 60, fit: BoxFit.cover)),
// //                   ),
// //                 ),
// //               ),
// //             ],
// //             Row(children: [
// //               Expanded(child: Text(item.isIdentified ? "SKU: ${item.sealName}" : "Not scanned")),
// //               TextButton(onPressed: () => _showSealDetection(index), child: Text(item.isIdentified ? "RE-SCAN" : "SCAN")),
// //             ]),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _variantInput(String label, TextEditingController ctrl, Function(String) onC, {bool isNum = false}) => Padding(
// //     padding: const EdgeInsets.only(bottom: 12),
// //     child: TextField(
// //       controller: ctrl,
// //       keyboardType: isNum ? TextInputType.number : TextInputType.text,
// //       decoration: InputDecoration(labelText: label, border: const OutlineInputBorder(), isDense: true),
// //       onChanged: onC,
// //     ),
// //   );
// //
// //   Widget _sectionHeader(String t) => Padding(padding: const EdgeInsets.only(top: 20, bottom: 8), child: Text(t, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary, fontSize: 13)));
// //
// //   Widget _buildCounter(String label, int value, Function(int) onChanged) => Column(children: [Text(label, style: const TextStyle(fontSize: 10)), Row(children: [IconButton(icon: const Icon(Icons.remove), onPressed: () => onChanged(value > 0 ? value - 1 : 0)), Text("$value", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), IconButton(icon: const Icon(Icons.add), onPressed: () => onChanged(value + 1))])]);
// //
// //   Widget _buildDataPlatePicker() => InkWell(
// //     onTap: () async {
// //       final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
// //       if (photo != null) setState(() => _entry.dataPlateImage = File(photo.path));
// //     },
// //     child: Container(
// //       height: 120, width: double.infinity,
// //       decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[300]!)),
// //       child: _entry.dataPlateImage == null
// //           ? const Icon(Icons.camera_alt, color: Colors.grey)
// //           : ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(_entry.dataPlateImage!, fit: BoxFit.cover)),
// //     ),
// //   );
// // }
//
//
//
//
// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../components/seal_detection_component.dart';
// import '../../theme.dart';
// import 'new_report_page.dart';
//
// class AddAssetPage extends StatefulWidget {
//   final Function(LocalAssetEntry) onSave;
//   const AddAssetPage({super.key, required this.onSave});
//
//   @override
//   State<AddAssetPage> createState() => _AddAssetPageState();
// }
//
// class _AddAssetPageState extends State<AddAssetPage> {
//   final LocalAssetEntry _entry = LocalAssetEntry();
//   final _picker = ImagePicker();
//
//   // Controllers for all original variant fields
//   final Map<String, TextEditingController> _controllers = {
//     'type': TextEditingController(),
//     'material': TextEditingController(),
//     'hardness': TextEditingController(),
//     'inner': TextEditingController(),
//     'outer': TextEditingController(),
//     'thickness': TextEditingController(),
//     'modelNum': TextEditingController(),
//     'temp': TextEditingController(),
//     'brand': TextEditingController(),
//     'app': TextEditingController(),
//     'desc': TextEditingController(),
//   };
//
//   @override
//   void initState() {
//     super.initState();
//     _syncIndividualItemsList();
//   }
//
//   @override
//   void dispose() {
//     _controllers.forEach((key, controller) => controller.dispose());
//     super.dispose();
//   }
//
//   void _syncIndividualItemsList() {
//     int totalNeeded = _entry.doorCount + _entry.drawerCount;
//     setState(() {
//       if (_entry.sealsAreCommon) {
//         if (_entry.individualSeals.isEmpty) {
//           _entry.individualSeals = [IndividualSeal(itemName: "Common Seal")];
//         } else if (_entry.individualSeals.length > 1) {
//           _entry.individualSeals = [_entry.individualSeals[0]];
//         }
//       } else {
//         List<IndividualSeal> newList = [];
//         for (int i = 0; i < totalNeeded; i++) {
//           String label = i < _entry.doorCount
//               ? "Door ${i + 1}"
//               : "Drawer ${i - _entry.doorCount + 1}";
//
//           if (i < _entry.individualSeals.length) {
//             newList.add(_entry.individualSeals[i]);
//           } else {
//             newList.add(IndividualSeal(itemName: label));
//           }
//         }
//         _entry.individualSeals = newList;
//       }
//     });
//   }
//
//   Future<void> _autoFillFromDatabase(String sealLabel, int index) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final String? productsJson = prefs.getString('local_products');
//       if (productsJson == null) return;
//
//       final List<dynamic> products = jsonDecode(productsJson);
//       final product = products.firstWhere(
//             (p) => p['title'].toString().toLowerCase() == sealLabel.toLowerCase() ||
//             p['sku'].toString().toLowerCase() == sealLabel.toLowerCase(),
//         orElse: () => null,
//       );
//
//       if (product != null) {
//         setState(() {
//           var item = _entry.individualSeals[index];
//           item.sealId = product['id'].toString();
//           item.sealName = product['title'];
//           item.sealType = product['seal_type'] ?? '';
//           item.material = product['material'] ?? '';
//           item.modelNum = product['seal_model_number'] ?? '';
//
//           if (index == 0 || _entry.sealsAreCommon) {
//             _entry.isMagnetic = product['is_magnetic'] ?? false;
//             _entry.sealType = product['seal_type'] ?? '';
//             _entry.material = product['material'] ?? '';
//             _entry.hardness = product['hardness'] ?? '';
//             _entry.innerDiameter = (product['inner_diameter'] ?? 0).toDouble();
//             _entry.outerDiameter = (product['outer_diameter'] ?? 0).toDouble();
//             _entry.thickness = (product['thickness'] ?? 0).toDouble();
//             _entry.tempRange = product['temperature_range'] ?? '';
//             _entry.brand = product['brand'] ?? '';
//             _entry.application = product['application'] ?? '';
//             _entry.sealModelNumber = product['seal_model_number'] ?? '';
//
//             _controllers['type']!.text = _entry.sealType!;
//             _controllers['material']!.text = _entry.material!;
//             _controllers['hardness']!.text = _entry.hardness!;
//             _controllers['inner']!.text = _entry.innerDiameter.toString();
//             _controllers['outer']!.text = _entry.outerDiameter.toString();
//             _controllers['thickness']!.text = _entry.thickness.toString();
//             _controllers['modelNum']!.text = _entry.sealModelNumber!;
//             _controllers['temp']!.text = _entry.tempRange!;
//             _controllers['brand']!.text = _entry.brand!;
//             _controllers['app']!.text = _entry.application!;
//           }
//         });
//       }
//     } catch (e) {
//       debugPrint("Auto-fill error: $e");
//     }
//   }
//
//   void _showSealDetection(int index) async {
//     final result = await showModalBottomSheet<SealDetectionResult>(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => const SealDetectionComponent(),
//     );
//
//     if (result != null) {
//       setState(() {
//         var item = _entry.individualSeals[index];
//         item.isIdentified = true;
//         item.sealName = result.label;
//         item.images = result.images;
//         item.confidence = result.confidence;
//
//         if (_entry.sealsAreCommon) {
//           _entry.sealImage = result.images.isNotEmpty ? result.images.first : null;
//           _entry.isUnknownSeal = false;
//         }
//       });
//       _autoFillFromDatabase(result.label, index);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(title: const Text("Add Asset Detail"), elevation: 0),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildSectionTitle("1. LOCATION"),
//               TextField(
//                 decoration: const InputDecoration(hintText: "e.g. Main Kitchen", border: OutlineInputBorder()),
//                 onChanged: (val) => _entry.area = val,
//               ),
//
//               _buildSectionTitle("2. FRIDGE DATA PLATE"),
//               _buildDataPlatePicker(),
//
//               _buildSectionTitle("3. QUANTITIES"),
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceAround,
//                   children: [
//                     _counterWidget("DOORS", _entry.doorCount, (val) {
//                       _entry.doorCount = val;
//                       _syncIndividualItemsList();
//                     }),
//                     _counterWidget("DRAWERS", _entry.drawerCount, (val) {
//                       _entry.drawerCount = val;
//                       _syncIndividualItemsList();
//                     }),
//                   ],
//                 ),
//               ),
//
//               _buildSectionTitle("4. SEAL CONFIGURATION"),
//               SwitchListTile(
//                 contentPadding: EdgeInsets.zero,
//                 title: const Text("Use same seal for all items?", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
//                 value: _entry.sealsAreCommon,
//                 activeColor: AppTheme.primary,
//                 onChanged: (val) {
//                   _entry.sealsAreCommon = val;
//                   _syncIndividualItemsList();
//                 },
//               ),
//
//               const Divider(),
//
//               // Dynamic Identification Blocks
//               ...List.generate(_entry.individualSeals.length, (index) {
//                 return _buildItemVariantCard(index, _entry.individualSeals[index]);
//               }),
//
//               _buildSectionTitle("5. GLOBAL VARIANTS & SPECS"),
//               SwitchListTile(
//                 contentPadding: EdgeInsets.zero,
//                 title: const Text("Magnetic Seal?", style: TextStyle(fontSize: 14)),
//                 value: _entry.isMagnetic,
//                 onChanged: (val) => setState(() => _entry.isMagnetic = val),
//                 activeColor: AppTheme.primary,
//               ),
//               _variantInputWidget("Seal Type", _controllers['type']!, (v) => _entry.sealType = v),
//               _variantInputWidget("Material", _controllers['material']!, (v) => _entry.material = v),
//               _variantInputWidget("Hardness", _controllers['hardness']!, (v) => _entry.hardness = v),
//
//               Row(children: [
//                 Expanded(child: _variantInputWidget("Inner Dia", _controllers['inner']!, (v) => _entry.innerDiameter = double.tryParse(v) ?? 0, isNum: true)),
//                 const SizedBox(width: 10),
//                 Expanded(child: _variantInputWidget("Outer Dia", _controllers['outer']!, (v) => _entry.outerDiameter = double.tryParse(v) ?? 0, isNum: true)),
//               ]),
//               Row(children: [
//                 Expanded(child: _variantInputWidget("Thickness", _controllers['thickness']!, (v) => _entry.thickness = double.tryParse(v) ?? 0, isNum: true)),
//                 const SizedBox(width: 10),
//                 Expanded(child: _variantInputWidget("Model #", _controllers['modelNum']!, (v) => _entry.sealModelNumber = v)),
//               ]),
//
//               _variantInputWidget("Temperature Range", _controllers['temp']!, (v) => _entry.tempRange = v),
//               _variantInputWidget("Brand", _controllers['brand']!, (v) => _entry.brand = v),
//               _variantInputWidget("Application", _controllers['app']!, (v) => _entry.application = v),
//
//               TextField(
//                 controller: _controllers['desc'],
//                 maxLines: 3,
//                 decoration: const InputDecoration(labelText: "Description/Notes", border: OutlineInputBorder()),
//                 onChanged: (val) => _entry.description = val,
//               ),
//
//               const SizedBox(height: 40),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 18)),
//                   onPressed: () {
//                     if (_entry.area.isEmpty) {
//                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Location required")));
//                       return;
//                     }
//                     widget.onSave(_entry);
//                     Navigator.pop(context);
//                   },
//                   child: const Text("SAVE FRIDGE ASSET", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//                 ),
//               ),
//               const SizedBox(height: 30),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildItemVariantCard(int index, IndividualSeal item) {
//     return Card(
//       elevation: 0,
//       margin: const EdgeInsets.only(bottom: 16),
//       color: item.isIdentified ? Colors.green[50] : Colors.grey[50],
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey[200]!)),
//       child: Padding(
//         padding: const EdgeInsets.all(12.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(children: [
//               Icon(item.isIdentified ? Icons.check_circle : Icons.qr_code_scanner, color: item.isIdentified ? Colors.green : Colors.grey),
//               const SizedBox(width: 8),
//               Text(item.itemName, style: const TextStyle(fontWeight: FontWeight.bold)),
//               const Spacer(),
//               if (item.isIdentified) Text("${(item.confidence * 100).toStringAsFixed(0)}% Match", style: const TextStyle(fontSize: 10, color: Colors.green)),
//             ]),
//
//             if (item.images.isNotEmpty) ...[
//               const SizedBox(height: 10),
//               SizedBox(
//                 height: 70,
//                 child: ListView.builder(
//                   scrollDirection: Axis.horizontal,
//                   shrinkWrap: true,
//                   physics: const ClampingScrollPhysics(),
//                   itemCount: item.images.length,
//                   itemBuilder: (c, i) => Padding(
//                     padding: const EdgeInsets.only(right: 8),
//                     child: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(item.images[i], width: 70, height: 70, fit: BoxFit.cover)),
//                   ),
//                 ),
//               ),
//             ],
//
//             const SizedBox(height: 8),
//             Row(
//               children: [
//                 Expanded(child: Text(item.isIdentified ? "SKU: ${item.sealName}" : "Not scanned", style: const TextStyle(fontSize: 13))),
//                 SizedBox(
//                   width: 100, // Fixed width to prevent crash
//                   child: ElevatedButton(
//                     onPressed: () => _showSealDetection(index),
//                     style: ElevatedButton.styleFrom(visualDensity: VisualDensity.compact),
//                     child: Text(item.isIdentified ? "RE-SCAN" : "SCAN"),
//                   ),
//                 ),
//               ],
//             ),
//
//             if (item.isIdentified) ...[
//               const Divider(),
//               _specLabelText("Type: ${item.sealType}"),
//               _specLabelText("Material: ${item.material}"),
//               _specLabelText("Model: ${item.modelNum}"),
//             ]
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _specLabelText(String text) => Text(text, style: const TextStyle(fontSize: 11, color: Colors.black54));
//
//   // HELPER METHOD: _variantInputWidget
//   Widget _variantInputWidget(String label, TextEditingController ctrl, Function(dynamic) onC, {bool isNum = false}) => Padding(
//     padding: const EdgeInsets.only(bottom: 12),
//     child: TextField(
//       controller: ctrl,
//       keyboardType: isNum ? TextInputType.number : TextInputType.text,
//       decoration: InputDecoration(labelText: label, border: const OutlineInputBorder(), isDense: true),
//       onChanged: (val) {
//         if (isNum) {
//           onC(double.tryParse(val) ?? 0);
//         } else {
//           onC(val);
//         }
//       },
//     ),
//   );
//
//   Widget _buildSectionTitle(String title) => Padding(
//     padding: const EdgeInsets.only(top: 20, bottom: 8),
//     child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary, fontSize: 13)),
//   );
//
//   Widget _counterWidget(String label, int value, Function(int) onChanged) => Column(
//     children: [
//       Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
//       Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: () => setState(() => onChanged(value > 0 ? value - 1 : 0))),
//           Text("$value", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//           IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () => setState(() => onChanged(value + 1))),
//         ],
//       ),
//     ],
//   );
//
//   Widget _buildDataPlatePicker() => InkWell(
//     onTap: () async {
//       final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
//       if (photo != null) setState(() => _entry.dataPlateImage = File(photo.path));
//     },
//     child: Container(
//       height: 120, width: double.infinity,
//       decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[300]!)),
//       child: _entry.dataPlateImage == null
//           ? const Icon(Icons.camera_alt, color: Colors.grey)
//           : ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(_entry.dataPlateImage!, fit: BoxFit.cover)),
//     ),
//   );
// }



import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../components/seal_detection_component.dart';
import '../../theme.dart';
import 'new_report_page.dart';

class AddAssetPage extends StatefulWidget {
  final Function(LocalAssetEntry) onSave;
  const AddAssetPage({super.key, required this.onSave});

  @override
  State<AddAssetPage> createState() => _AddAssetPageState();
}

class _AddAssetPageState extends State<AddAssetPage> {
  final LocalAssetEntry _entry = LocalAssetEntry();
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _syncIndividualItemsList();
  }

  @override
  void dispose() {
    // Dispose all controllers within each individual seal
    for (var seal in _entry.individualSeals) {
      seal.disposeControllers();
    }
    super.dispose();
  }



  void _syncIndividualItemsList() {
    int totalNeeded = _entry.doorCount + _entry.drawerCount;
    setState(() {
      if (_entry.sealsAreCommon) {
        if (_entry.individualSeals.isEmpty) {
          _entry.individualSeals = [IndividualSeal(itemName: "Common Seal")];
        } else if (_entry.individualSeals.length > 1) {
          _entry.individualSeals = [_entry.individualSeals[0]];
        }
      } else {
        List<IndividualSeal> newList = [];
        for (int i = 0; i < totalNeeded; i++) {
          String label = i < _entry.doorCount
              ? "Door ${i + 1}"
              : "Drawer ${i - _entry.doorCount + 1}";

          if (i < _entry.individualSeals.length) {
            newList.add(_entry.individualSeals[i]);
          } else {
            newList.add(IndividualSeal(itemName: label));
          }
        }
        _entry.individualSeals = newList;
      }
    });
  }

  Future<void> _autoFillFromDatabase(String sealLabel, int index) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? productsJson = prefs.getString('local_products');
      if (productsJson == null) return;

      final List<dynamic> products = jsonDecode(productsJson);
      final product = products.firstWhere(
            (p) => p['title'].toString().toLowerCase() == sealLabel.toLowerCase() ||
            p['sku'].toString().toLowerCase() == sealLabel.toLowerCase(),
        orElse: () => null,
      );

      if (product != null) {
        setState(() {
          var item = _entry.individualSeals[index];
          item.sealId = product['id'].toString();
          item.sealName = product['title'];

          // Map DB values to THIS specific item's controllers/model
          item.isMagnetic = product['is_magnetic'] ?? false;
          item.sealType = product['seal_type'] ?? '';
          item.material = product['material'] ?? '';
          item.hardness = product['hardness'] ?? '';
          item.innerDiameter = (product['inner_diameter'] ?? 0).toDouble();
          item.outerDiameter = (product['outer_diameter'] ?? 0).toDouble();
          item.thickness = (product['thickness'] ?? 0).toDouble();
          item.tempRange = product['temperature_range'] ?? '';
          item.brand = product['brand'] ?? '';
          item.application = product['application'] ?? '';
          item.sealModelNumber = product['seal_model_number'] ?? '';
          item.description = product['description'] ?? '';

          // Sync the UI controllers for THIS card
          item.updateControllers();
        });
      }
    } catch (e) {
      debugPrint("Auto-fill error: $e");
    }
  }

  void _showSealDetection(int index) async {
    final result = await showModalBottomSheet<SealDetectionResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SealDetectionComponent(),
    );

    if (result != null) {
      setState(() {
        var item = _entry.individualSeals[index];
        item.isIdentified = true;
        item.sealName = result.label;
        item.images = result.images;
        item.confidence = result.confidence;

        if (_entry.sealsAreCommon) {
          _entry.sealImage = result.images.isNotEmpty ? result.images.first : null;
        }
      });
      _autoFillFromDatabase(result.label, index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Add Asset Detail"), elevation: 0),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("1. LOCATION"),
              TextField(
                decoration: const InputDecoration(hintText: "e.g. Main Kitchen", border: OutlineInputBorder()),
                onChanged: (val) => _entry.area = val,
              ),

              _buildSectionTitle("2. FRIDGE DATA PLATE"),
              _buildDataPlatePicker(),

              _buildSectionTitle("3. QUANTITIES"),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _counterWidget("DOORS", _entry.doorCount, (val) {
                      _entry.doorCount = val;
                      _syncIndividualItemsList();
                    }),
                    _counterWidget("DRAWERS", _entry.drawerCount, (val) {
                      _entry.drawerCount = val;
                      _syncIndividualItemsList();
                    }),
                  ],
                ),
              ),

              _buildSectionTitle("4. SEAL CONFIGURATION"),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text("Use same seal for all items?", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                value: _entry.sealsAreCommon,
                activeColor: AppTheme.primary,
                onChanged: (val) {
                  _entry.sealsAreCommon = val;
                  _syncIndividualItemsList();
                },
              ),

              const Divider(),

              // --- DYNAMIC ITEMS WITH INDIVIDUAL VARIANTS ---
              Column(
                children: List.generate(_entry.individualSeals.length, (index) {
                  return _buildItemVariantCard(index, _entry.individualSeals[index]);
                }),
              ),

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 18)),
                  // onPressed: () {
                  //   if (_entry.area.isEmpty) {
                  //     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Location required")));
                  //     return;
                  //   }
                  //   widget.onSave(_entry);
                  //   Navigator.pop(context);
                  // },
                  onPressed: () {
                    // 1. Basic Location Validation
                    if (_entry.area.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Location required (e.g. Main Kitchen)")),
                      );
                      return;
                    }

                    // 2. Identification Validation
                    // Ensures every door/drawer has been scanned or manually filled
                    bool allIdentified = _entry.individualSeals.every((s) => s.isIdentified);
                    if (!allIdentified) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please identify all seals before saving")),
                      );
                      return;
                    }

                    // 3. Complete Data Sync
                    // Iterates through every individual seal card and pulls data from its controllers
                    for (var seal in _entry.individualSeals) {
                      seal.sealType = seal.ctrls['type']!.text;
                      seal.material = seal.ctrls['material']!.text;
                      seal.hardness = seal.ctrls['hardness']!.text;

                      // Numeric conversions
                      seal.innerDiameter = double.tryParse(seal.ctrls['inner']!.text) ?? 0.0;
                      seal.outerDiameter = double.tryParse(seal.ctrls['outer']!.text) ?? 0.0;
                      seal.thickness = double.tryParse(seal.ctrls['thickness']!.text) ?? 0.0;

                      seal.sealModelNumber = seal.ctrls['modelNum']!.text;
                      seal.tempRange = seal.ctrls['temp']!.text;
                      seal.brand = seal.ctrls['brand']!.text;
                      seal.application = seal.ctrls['app']!.text;
                      seal.description = seal.ctrls['desc']!.text;
                    }

                    // 4. Return to NewReportPage
                    // widget.onSave passes the entire _entry (including data plate image,
                    // counters, and the list of individual seals with their photos)
                    widget.onSave(_entry);
                    Navigator.pop(context);
                  },
                  child: const Text("SAVE FRIDGE ASSET", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemVariantCard(int index, IndividualSeal item) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 24),
      color: item.isIdentified ? Colors.green[50]!.withOpacity(0.3) : Colors.grey[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey[200]!)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(item.isIdentified ? Icons.check_circle : Icons.qr_code_scanner, color: item.isIdentified ? Colors.green : Colors.grey),
              const SizedBox(width: 8),
              Text(item.itemName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const Spacer(),
              if (item.isIdentified) Text("${(item.confidence * 100).toStringAsFixed(0)}% Match", style: const TextStyle(fontSize: 10, color: Colors.green)),
            ]),

            if (item.images.isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  itemCount: item.images.length,
                  itemBuilder: (c, i) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(item.images[i], width: 80, height: 80, fit: BoxFit.cover)),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: Text(item.isIdentified ? "SKU: ${item.sealName}" : "Not scanned", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
                SizedBox(
                  width: 110,
                  child: ElevatedButton(
                    onPressed: () => _showSealDetection(index),
                    style: ElevatedButton.styleFrom(visualDensity: VisualDensity.compact),
                    child: Text(item.isIdentified ? "RE-SCAN" : "SCAN SEAL"),
                  ),
                ),
              ],
            ),

            const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider()),

            // --- INDIVIDUAL VARIANT FIELDS FOR EACH SEAL ---
            _variantInputWidget("Seal Type", item.ctrls['type']!, (v) => item.sealType = v),
            _variantInputWidget("Material", item.ctrls['material']!, (v) => item.material = v),
            _variantInputWidget("Hardness", item.ctrls['hardness']!, (v) => item.hardness = v),

            Row(children: [
              Expanded(child: _variantInputWidget("Inner Dia (mm)", item.ctrls['inner']!, (v) => item.innerDiameter = double.tryParse(v.toString()) ?? 0, isNum: true)),
              const SizedBox(width: 10),
              Expanded(child: _variantInputWidget("Outer Dia (mm)", item.ctrls['outer']!, (v) => item.outerDiameter = double.tryParse(v.toString()) ?? 0, isNum: true)),
            ]),
            Row(children: [
              Expanded(child: _variantInputWidget("Thickness (mm)", item.ctrls['thickness']!, (v) => item.thickness = double.tryParse(v.toString()) ?? 0, isNum: true)),
              const SizedBox(width: 10),
              Expanded(child: _variantInputWidget("Model #", item.ctrls['modelNum']!, (v) => item.sealModelNumber = v)),
            ]),

            _variantInputWidget("Temperature Range", item.ctrls['temp']!, (v) => item.tempRange = v),
            _variantInputWidget("Brand", item.ctrls['brand']!, (v) => item.brand = v),
            _variantInputWidget("Application", item.ctrls['app']!, (v) => item.application = v),

            const SizedBox(height: 8),
            TextField(
              controller: item.ctrls['desc'],
              maxLines: 2,
              decoration: const InputDecoration(labelText: "Notes for this seal", border: OutlineInputBorder(), isDense: true),
              onChanged: (val) => item.description = val,
            ),
          ],
        ),
      ),
    );
  }

  // HELPER: _variantInputWidget
  Widget _variantInputWidget(String label, TextEditingController ctrl, Function(dynamic) onC, {bool isNum = false}) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      controller: ctrl,
      keyboardType: isNum ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder(), isDense: true),
      onChanged: (val) {
        if (isNum) {
          onC(double.tryParse(val) ?? 0);
        } else {
          onC(val);
        }
      },
    ),
  );

  Widget _buildSectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(top: 20, bottom: 8),
    child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary, fontSize: 13)),
  );

  Widget _counterWidget(String label, int value, Function(int) onChanged) => Column(
    children: [
      Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
      Row(mainAxisSize: MainAxisSize.min, children: [
        IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: () => setState(() => onChanged(value > 0 ? value - 1 : 0))),
        Text("$value", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () => setState(() => onChanged(value + 1))),
      ])
    ],
  );

  Widget _buildDataPlatePicker() => InkWell(
    onTap: () async {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo != null) setState(() => _entry.dataPlateImage = File(photo.path));
    },
    child: Container(
      height: 120, width: double.infinity,
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[300]!)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _entry.dataPlateImage == null
              ? const Icon(Icons.qr_code_scanner_outlined, color: Colors.grey)
              : ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(_entry.dataPlateImage!, fit: BoxFit.cover)),
          Text("Tap to capture Data Plate", style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    ),
  );
}
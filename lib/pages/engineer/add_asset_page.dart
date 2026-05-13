// // // // // // // // import 'dart:io';
// // // // // // // // import 'package:flutter/material.dart';
// // // // // // // // import 'package:image_picker/image_picker.dart';
// // // // // // // // import '../../components/seal_detection_component.dart';
// // // // // // // // import '../../theme.dart';
// // // // // // // // import 'new_report_page.dart'; // Import your model
// // // // // // // //
// // // // // // // // class AddAssetPage extends StatefulWidget {
// // // // // // // //   final Function(LocalAssetEntry) onSave;
// // // // // // // //   const AddAssetPage({super.key, required this.onSave});
// // // // // // // //
// // // // // // // //
// // // // // // // //
// // // // // // // //   @override
// // // // // // // //   State<AddAssetPage> createState() => _AddAssetPageState();
// // // // // // // // }
// // // // // // // //
// // // // // // // //
// // // // // // // //
// // // // // // // // class _AddAssetPageState extends State<AddAssetPage> {
// // // // // // // //   final LocalAssetEntry _entry = LocalAssetEntry();
// // // // // // // //   final _picker = ImagePicker();
// // // // // // // //
// // // // // // // //   Widget _buildSectionTitle(String title) {
// // // // // // // //     return Padding(
// // // // // // // //       padding: const EdgeInsets.symmetric(vertical: 8),
// // // // // // // //       child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.secondaryText)),
// // // // // // // //     );
// // // // // // // //   }
// // // // // // // //
// // // // // // // //   Widget _buildCounter(String label, int value, Function(int) onChanged) {
// // // // // // // //     return Column(
// // // // // // // //       children: [
// // // // // // // //         Text(label, style: const TextStyle(fontSize: 12)),
// // // // // // // //         Row(
// // // // // // // //           children: [
// // // // // // // //             IconButton(onPressed: () => onChanged(value > 0 ? value - 1 : 0), icon: const Icon(Icons.remove_circle_outline)),
// // // // // // // //             Text("$value", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
// // // // // // // //             IconButton(onPressed: () => onChanged(value + 1), icon: const Icon(Icons.add_circle_outline)),
// // // // // // // //           ],
// // // // // // // //         ),
// // // // // // // //       ],
// // // // // // // //     );
// // // // // // // //   }
// // // // // // // //
// // // // // // // //   void _showSealDetection() async {
// // // // // // // //     final result = await showModalBottomSheet<SealDetectionResult>(
// // // // // // // //       context: context,
// // // // // // // //       isScrollControlled: true,
// // // // // // // //       backgroundColor: Colors.transparent,
// // // // // // // //       builder: (context) => const SealDetectionComponent(),
// // // // // // // //     );
// // // // // // // //
// // // // // // // //     if (result != null) {
// // // // // // // //       setState(() {
// // // // // // // //         _entry.isUnknownSeal = false;
// // // // // // // //         _entry.manualSealName = result.label;
// // // // // // // //         _entry.sealImage = result.images.isNotEmpty ? result.images.first : null;
// // // // // // // //         // Store the full list of images if needed for submission
// // // // // // // //       });
// // // // // // // //     }
// // // // // // // //   }
// // // // // // // //
// // // // // // // //   @override
// // // // // // // //   Widget build(BuildContext context) {
// // // // // // // //     return Scaffold(
// // // // // // // //       appBar: AppBar(title: const Text("Add Fridge Detail")),
// // // // // // // //       body: SingleChildScrollView(
// // // // // // // //         padding: const EdgeInsets.all(16),
// // // // // // // //         child: Column(
// // // // // // // //           crossAxisAlignment: CrossAxisAlignment.start,
// // // // // // // //           children: [
// // // // // // // //             // 1. Area Block
// // // // // // // //             _buildSectionTitle("LOCATION"),
// // // // // // // //             TextField(
// // // // // // // //               decoration: const InputDecoration(hintText: "e.g. Kitchen, Pastry, Front of House"),
// // // // // // // //               onChanged: (val) => _entry.area = val,
// // // // // // // //             ),
// // // // // // // //             const SizedBox(height: 20),
// // // // // // // //
// // // // // // // //             // 2. Data Plate Block
// // // // // // // //             _buildSectionTitle("FRIDGE DATA PLATE"),
// // // // // // // //             InkWell(
// // // // // // // //               onTap: () async {
// // // // // // // //                 final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
// // // // // // // //                 if (photo != null) setState(() => _entry.dataPlateImage = File(photo.path));
// // // // // // // //               },
// // // // // // // //               child: Container(
// // // // // // // //                 height: 150,
// // // // // // // //                 width: double.infinity,
// // // // // // // //                 decoration: BoxDecoration(
// // // // // // // //                   color: Colors.grey[200],
// // // // // // // //                   borderRadius: BorderRadius.circular(12),
// // // // // // // //                   image: _entry.dataPlateImage != null ? DecorationImage(image: FileImage(_entry.dataPlateImage!), fit: BoxFit.cover) : null,
// // // // // // // //                 ),
// // // // // // // //                 child: _entry.dataPlateImage == null ? const Icon(Icons.camera_enhance, size: 40, color: AppTheme.primary) : null,
// // // // // // // //               ),
// // // // // // // //             ),
// // // // // // // //             const SizedBox(height: 20),
// // // // // // // //
// // // // // // // //             // 3. Seal Verification Block
// // // // // // // //             _buildSectionTitle("SEAL IDENTIFICATION"),
// // // // // // // //             Row(
// // // // // // // //               children: [
// // // // // // // //                 Expanded(
// // // // // // // //                   child: ChoiceChip(
// // // // // // // //                     label: const Text("Unknown (Scan)"),
// // // // // // // //                     selected: _entry.isUnknownSeal,
// // // // // // // //                     onSelected: (val) => setState(() => _entry.isUnknownSeal = true),
// // // // // // // //                   ),
// // // // // // // //                 ),
// // // // // // // //                 const SizedBox(width: 10),
// // // // // // // //                 Expanded(
// // // // // // // //                   child: ChoiceChip(
// // // // // // // //                     label: const Text("I know the Seal"),
// // // // // // // //                     selected: !_entry.isUnknownSeal,
// // // // // // // //                     onSelected: (val) => setState(() => _entry.isUnknownSeal = false),
// // // // // // // //                   ),
// // // // // // // //                 ),
// // // // // // // //               ],
// // // // // // // //             ),
// // // // // // // //             if (_entry.isUnknownSeal)
// // // // // // // //               // ElevatedButton.icon(
// // // // // // // //               //   style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accent1),
// // // // // // // //               //   onPressed: () {
// // // // // // // //               //     /* Call your existing ML detection page here */
// // // // // // // //               //   },
// // // // // // // //               //   icon: const Icon(Icons.qr_code_scanner),
// // // // // // // //               //   label: const Text("DETECT SEAL (ML)"),
// // // // // // // //               // )
// // // // // // // //
// // // // // // // //               ElevatedButton.icon(
// // // // // // // //                 style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accent1),
// // // // // // // //                 onPressed: _showSealDetection, // Trigger the component
// // // // // // // //                 icon: const Icon(Icons.qr_code_scanner),
// // // // // // // //                 label: const Text("DETECT SEAL (ML)"),
// // // // // // // //               )
// // // // // // // //             else
// // // // // // // //               TextField(
// // // // // // // //                 decoration: const InputDecoration(hintText: "Enter Seal SKU or ID"),
// // // // // // // //                 onChanged: (val) => _entry.manualSealName = val,
// // // // // // // //               ),
// // // // // // // //             const SizedBox(height: 20),
// // // // // // // //
// // // // // // // //             // 4. Variant Details
// // // // // // // //             _buildSectionTitle("SEAL VARIANTS"),
// // // // // // // //             TextField(
// // // // // // // //               maxLines: 2,
// // // // // // // //               decoration: const InputDecoration(hintText: "Color, Thickness, Height, Width, etc."),
// // // // // // // //               onChanged: (val) => _entry.variantDetails = val,
// // // // // // // //             ),
// // // // // // // //             const SizedBox(height: 20),
// // // // // // // //
// // // // // // // //             // 5. Counters
// // // // // // // //             _buildSectionTitle("QUANTITIES"),
// // // // // // // //             Row(
// // // // // // // //               mainAxisAlignment: MainAxisAlignment.spaceAround,
// // // // // // // //               children: [
// // // // // // // //                 _buildCounter("NO. OF DOORS", _entry.doorCount, (val) => setState(() => _entry.doorCount = val)),
// // // // // // // //                 _buildCounter("NO. OF DRAWERS", _entry.drawerCount, (val) => setState(() => _entry.drawerCount = val)),
// // // // // // // //               ],
// // // // // // // //             ),
// // // // // // // //             const SizedBox(height: 40),
// // // // // // // //
// // // // // // // //             ElevatedButton(
// // // // // // // //               onPressed: () {
// // // // // // // //                 widget.onSave(_entry);
// // // // // // // //                 Navigator.pop(context);
// // // // // // // //               },
// // // // // // // //               child: const Text("SAVE ASSET"),
// // // // // // // //             ),
// // // // // // // //           ],
// // // // // // // //         ),
// // // // // // // //       ),
// // // // // // // //     );
// // // // // // // //   }
// // // // // // // // }
// // // // // // //
// // // // // // //
// // // // // // //
// // // // // // // import 'dart:io';
// // // // // // // import 'package:flutter/material.dart';
// // // // // // // import 'package:image_picker/image_picker.dart';
// // // // // // // import '../../components/seal_detection_component.dart';
// // // // // // // import '../../theme.dart';
// // // // // // // import 'new_report_page.dart';
// // // // // // //
// // // // // // // class AddAssetPage extends StatefulWidget {
// // // // // // //   final Function(LocalAssetEntry) onSave;
// // // // // // //   const AddAssetPage({super.key, required this.onSave});
// // // // // // //
// // // // // // //   @override
// // // // // // //   State<AddAssetPage> createState() => _AddAssetPageState();
// // // // // // // }
// // // // // // //
// // // // // // // class _AddAssetPageState extends State<AddAssetPage> {
// // // // // // //   final LocalAssetEntry _entry = LocalAssetEntry();
// // // // // // //   final _picker = ImagePicker();
// // // // // // //
// // // // // // //   // Helper for Section Titles
// // // // // // //   Widget _buildSectionTitle(String title) {
// // // // // // //     return Padding(
// // // // // // //       padding: const EdgeInsets.only(top: 20, bottom: 8),
// // // // // // //       child: Text(
// // // // // // //         title,
// // // // // // //         style: const TextStyle(
// // // // // // //           fontWeight: FontWeight.bold,
// // // // // // //           color: AppTheme.primary,
// // // // // // //           letterSpacing: 1.1,
// // // // // // //           fontSize: 13,
// // // // // // //         ),
// // // // // // //       ),
// // // // // // //     );
// // // // // // //   }
// // // // // // //
// // // // // // //   // Helper for Variant Input Fields
// // // // // // //   Widget _buildVariantField(String label, String hint, Function(String) onChanged, {bool isNumeric = false}) {
// // // // // // //     return Padding(
// // // // // // //       padding: const EdgeInsets.only(bottom: 12),
// // // // // // //       child: TextField(
// // // // // // //         keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
// // // // // // //         decoration: InputDecoration(
// // // // // // //           labelText: label,
// // // // // // //           hintText: hint,
// // // // // // //           isDense: true,
// // // // // // //           border: const OutlineInputBorder(),
// // // // // // //         ),
// // // // // // //         onChanged: onChanged,
// // // // // // //       ),
// // // // // // //     );
// // // // // // //   }
// // // // // // //
// // // // // // //   // Helper for Counters
// // // // // // //   Widget _buildCounter(String label, int value, Function(int) onChanged) {
// // // // // // //     return Column(
// // // // // // //       children: [
// // // // // // //         Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
// // // // // // //         Row(
// // // // // // //           mainAxisSize: MainAxisSize.min,
// // // // // // //           children: [
// // // // // // //             IconButton(
// // // // // // //               onPressed: () => onChanged(value > 0 ? value - 1 : 0),
// // // // // // //               icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
// // // // // // //             ),
// // // // // // //             Container(
// // // // // // //               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
// // // // // // //               decoration: BoxDecoration(
// // // // // // //                 border: Border.all(color: Colors.grey[300]!),
// // // // // // //                 borderRadius: BorderRadius.circular(8),
// // // // // // //               ),
// // // // // // //               child: Text("$value", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
// // // // // // //             ),
// // // // // // //             IconButton(
// // // // // // //               onPressed: () => onChanged(value + 1),
// // // // // // //               icon: const Icon(Icons.add_circle_outline, color: Colors.green),
// // // // // // //             ),
// // // // // // //           ],
// // // // // // //         ),
// // // // // // //       ],
// // // // // // //     );
// // // // // // //   }
// // // // // // //
// // // // // // //   void _showSealDetection() async {
// // // // // // //     final result = await showModalBottomSheet<SealDetectionResult>(
// // // // // // //       context: context,
// // // // // // //       isScrollControlled: true,
// // // // // // //       backgroundColor: Colors.transparent,
// // // // // // //       builder: (context) => const SealDetectionComponent(),
// // // // // // //     );
// // // // // // //
// // // // // // //     if (result != null) {
// // // // // // //       setState(() {
// // // // // // //         _entry.isUnknownSeal = false;
// // // // // // //         _entry.manualSealName = result.label;
// // // // // // //         _entry.sealImage = result.images.isNotEmpty ? result.images.first : null;
// // // // // // //         _entry.allSealImages = result.images; // Store all for submission
// // // // // // //         _entry.confidence = result.confidence;
// // // // // // //       });
// // // // // // //     }
// // // // // // //   }
// // // // // // //
// // // // // // //   @override
// // // // // // //   Widget build(BuildContext context) {
// // // // // // //     return Scaffold(
// // // // // // //       backgroundColor: Colors.white,
// // // // // // //       appBar: AppBar(
// // // // // // //         title: const Text("Add Fridge Detail"),
// // // // // // //         elevation: 0,
// // // // // // //       ),
// // // // // // //       body: SingleChildScrollView(
// // // // // // //         padding: const EdgeInsets.all(16),
// // // // // // //         child: Column(
// // // // // // //           crossAxisAlignment: CrossAxisAlignment.start,
// // // // // // //           children: [
// // // // // // //             // 1. Area Block
// // // // // // //             _buildSectionTitle("1. LOCATION"),
// // // // // // //             TextField(
// // // // // // //               decoration: const InputDecoration(
// // // // // // //                 hintText: "e.g. Main Kitchen, Pastry Area",
// // // // // // //                 prefixIcon: Icon(Icons.location_on_outlined),
// // // // // // //               ),
// // // // // // //               onChanged: (val) => _entry.area = val,
// // // // // // //             ),
// // // // // // //
// // // // // // //             // 2. Data Plate Block
// // // // // // //             _buildSectionTitle("2. FRIDGE DATA PLATE"),
// // // // // // //             InkWell(
// // // // // // //               onTap: () async {
// // // // // // //                 final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
// // // // // // //                 if (photo != null) setState(() => _entry.dataPlateImage = File(photo.path));
// // // // // // //               },
// // // // // // //               child: Container(
// // // // // // //                 height: 150,
// // // // // // //                 width: double.infinity,
// // // // // // //                 decoration: BoxDecoration(
// // // // // // //                   color: Colors.grey[50],
// // // // // // //                   borderRadius: BorderRadius.circular(12),
// // // // // // //                   border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
// // // // // // //                   image: _entry.dataPlateImage != null
// // // // // // //                       ? DecorationImage(image: FileImage(_entry.dataPlateImage!), fit: BoxFit.cover)
// // // // // // //                       : null,
// // // // // // //                 ),
// // // // // // //                 child: _entry.dataPlateImage == null
// // // // // // //                     ? const Column(
// // // // // // //                   mainAxisAlignment: MainAxisAlignment.center,
// // // // // // //                   children: [
// // // // // // //                     Icon(Icons.camera_enhance_outlined, size: 40, color: Colors.grey),
// // // // // // //                     Text("Tap to capture Data Plate", style: TextStyle(color: Colors.grey, fontSize: 12)),
// // // // // // //                   ],
// // // // // // //                 )
// // // // // // //                     : const Align(
// // // // // // //                   alignment: Alignment.bottomRight,
// // // // // // //                   child: Padding(
// // // // // // //                     padding: EdgeInsets.all(8.0),
// // // // // // //                     child: CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.edit, size: 20)),
// // // // // // //                   ),
// // // // // // //                 ),
// // // // // // //               ),
// // // // // // //             ),
// // // // // // //
// // // // // // //             // 3. Seal Identification Block
// // // // // // //             _buildSectionTitle("3. SEAL IDENTIFICATION"),
// // // // // // //             Row(
// // // // // // //               children: [
// // // // // // //                 Expanded(
// // // // // // //                   child: ChoiceChip(
// // // // // // //                     label: const Center(child: Text("Scan (ML)")),
// // // // // // //                     selected: _entry.isUnknownSeal || _entry.sealImage != null,
// // // // // // //                     onSelected: (val) => setState(() => _entry.isUnknownSeal = true),
// // // // // // //                   ),
// // // // // // //                 ),
// // // // // // //                 const SizedBox(width: 10),
// // // // // // //                 Expanded(
// // // // // // //                   child: ChoiceChip(
// // // // // // //                     label: const Center(child: Text("Manual Entry")),
// // // // // // //                     selected: !_entry.isUnknownSeal && _entry.sealImage == null,
// // // // // // //                     onSelected: (val) {
// // // // // // //                       setState(() {
// // // // // // //                         _entry.isUnknownSeal = false;
// // // // // // //                         _entry.sealImage = null;
// // // // // // //                         _entry.manualSealName = "";
// // // // // // //                       });
// // // // // // //                     },
// // // // // // //                   ),
// // // // // // //                 ),
// // // // // // //               ],
// // // // // // //             ),
// // // // // // //             const SizedBox(height: 12),
// // // // // // //
// // // // // // //             // Display ML Result if exists
// // // // // // //             if (_entry.sealImage != null)
// // // // // // //               Container(
// // // // // // //                 padding: const EdgeInsets.all(12),
// // // // // // //                 margin: const EdgeInsets.only(bottom: 12),
// // // // // // //                 decoration: BoxDecoration(
// // // // // // //                   color: Colors.green[50],
// // // // // // //                   borderRadius: BorderRadius.circular(12),
// // // // // // //                   border: Border.all(color: Colors.green[200]!),
// // // // // // //                 ),
// // // // // // //                 child: Row(
// // // // // // //                   children: [
// // // // // // //                     ClipRRect(
// // // // // // //                       borderRadius: BorderRadius.circular(8),
// // // // // // //                       child: Image.file(_entry.sealImage!, width: 60, height: 60, fit: BoxFit.cover),
// // // // // // //                     ),
// // // // // // //                     const SizedBox(width: 12),
// // // // // // //                     Expanded(
// // // // // // //                       child: Column(
// // // // // // //                         crossAxisAlignment: CrossAxisAlignment.start,
// // // // // // //                         children: [
// // // // // // //                           Text(_entry.manualSealName ?? "Detected Seal",
// // // // // // //                               style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
// // // // // // //                           Text("Confidence: ${(_entry.confidence * 100).toStringAsFixed(1)}%",
// // // // // // //                               style: TextStyle(color: Colors.green[700], fontSize: 12)),
// // // // // // //                         ],
// // // // // // //                       ),
// // // // // // //                     ),
// // // // // // //                     IconButton(
// // // // // // //                       onPressed: _showSealDetection,
// // // // // // //                       icon: const Icon(Icons.refresh, color: Colors.green),
// // // // // // //                     )
// // // // // // //                   ],
// // // // // // //                 ),
// // // // // // //               )
// // // // // // //             else if (_entry.isUnknownSeal)
// // // // // // //               ElevatedButton.icon(
// // // // // // //                 style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accent1, minimumSize: const Size(double.infinity, 50)),
// // // // // // //                 onPressed: _showSealDetection,
// // // // // // //                 icon: const Icon(Icons.qr_code_scanner),
// // // // // // //                 label: const Text("OPEN ML SCANNER"),
// // // // // // //               )
// // // // // // //             else
// // // // // // //               TextField(
// // // // // // //                 decoration: const InputDecoration(hintText: "Enter Seal SKU or ID Manually"),
// // // // // // //                 onChanged: (val) => _entry.manualSealName = val,
// // // // // // //               ),
// // // // // // //
// // // // // // //             // 4. Detailed Variant Details
// // // // // // //             _buildSectionTitle("4. SEAL VARIANTS & SPECS"),
// // // // // // //             SwitchListTile(
// // // // // // //               title: const Text("Magnetic Seal?", style: TextStyle(fontSize: 14)),
// // // // // // //               value: _entry.isMagnetic,
// // // // // // //               onChanged: (val) => setState(() => _entry.isMagnetic = val),
// // // // // // //               activeColor: AppTheme.primary,
// // // // // // //             ),
// // // // // // //             const SizedBox(height: 8),
// // // // // // //             _buildVariantField("Seal Type", "e.g. Compression, Dart", (val) => _entry.sealType = val),
// // // // // // //             _buildVariantField("Material", "e.g. PVC, Rubber", (val) => _entry.material = val),
// // // // // // //             _buildVariantField("Hardness", "e.g. 70 Shore A", (val) => _entry.hardness = val),
// // // // // // //
// // // // // // //             Row(
// // // // // // //               children: [
// // // // // // //                 Expanded(child: _buildVariantField("Inner Dia", "mm", (val) => _entry.innerDiameter = double.tryParse(val) ?? 0, isNumeric: true)),
// // // // // // //                 const SizedBox(width: 10),
// // // // // // //                 Expanded(child: _buildVariantField("Outer Dia", "mm", (val) => _entry.outerDiameter = double.tryParse(val) ?? 0, isNumeric: true)),
// // // // // // //               ],
// // // // // // //             ),
// // // // // // //             Row(
// // // // // // //               children: [
// // // // // // //                 Expanded(child: _buildVariantField("Thickness", "mm", (val) => _entry.thickness = double.tryParse(val) ?? 0, isNumeric: true)),
// // // // // // //                 const SizedBox(width: 10),
// // // // // // //                 Expanded(child: _buildVariantField("Model #", "Seal Model", (val) => _entry.sealModelNumber = val)),
// // // // // // //               ],
// // // // // // //             ),
// // // // // // //
// // // // // // //             _buildVariantField("Temperature Range", "e.g. -20C to 80C", (val) => _entry.tempRange = val),
// // // // // // //             _buildVariantField("Brand", "e.g. Foster, Polar", (val) => _entry.brand = val),
// // // // // // //             _buildVariantField("Application", "e.g. Walk-in Fridge", (val) => _entry.application = val),
// // // // // // //
// // // // // // //             TextField(
// // // // // // //               maxLines: 3,
// // // // // // //               decoration: const InputDecoration(labelText: "Description/Notes", border: OutlineInputBorder()),
// // // // // // //               onChanged: (val) => _entry.description = val,
// // // // // // //             ),
// // // // // // //
// // // // // // //             // 5. Counters
// // // // // // //             _buildSectionTitle("5. QUANTITIES"),
// // // // // // //             Container(
// // // // // // //               padding: const EdgeInsets.all(16),
// // // // // // //               decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)),
// // // // // // //               child: Row(
// // // // // // //                 mainAxisAlignment: MainAxisAlignment.spaceAround,
// // // // // // //                 children: [
// // // // // // //                   _buildCounter("DOORS", _entry.doorCount, (val) => setState(() => _entry.doorCount = val)),
// // // // // // //                   _buildCounter("DRAWERS", _entry.drawerCount, (val) => setState(() => _entry.drawerCount = val)),
// // // // // // //                 ],
// // // // // // //               ),
// // // // // // //             ),
// // // // // // //
// // // // // // //             const SizedBox(height: 40),
// // // // // // //
// // // // // // //             ElevatedButton(
// // // // // // //               style: ElevatedButton.styleFrom(
// // // // // // //                 minimumSize: const Size(double.infinity, 60),
// // // // // // //                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// // // // // // //               ),
// // // // // // //               onPressed: () {
// // // // // // //                 if (_entry.area.isEmpty) {
// // // // // // //                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter a location")));
// // // // // // //                   return;
// // // // // // //                 }
// // // // // // //                 widget.onSave(_entry);
// // // // // // //                 Navigator.pop(context);
// // // // // // //               },
// // // // // // //               child: const Text("SAVE FRIDGE ASSET", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
// // // // // // //             ),
// // // // // // //             const SizedBox(height: 20),
// // // // // // //           ],
// // // // // // //         ),
// // // // // // //       ),
// // // // // // //     );
// // // // // // //   }
// // // // // // // }
// // // // // //
// // // // // //
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
//   // Controllers to allow programmatic updates (Auto-fill)
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
//   void dispose() {
//     _controllers.forEach((key, controller) => controller.dispose());
//     super.dispose();
//   }
//
//   // --- AUTO-FILL LOGIC ---
//   Future<void> _autoFillFromDatabase(String sealLabel) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final String? productsJson = prefs.getString('local_products');
//
//       if (productsJson != null) {
//         final List<dynamic> products = jsonDecode(productsJson);
//
//         // Find the product where title or sku matches the ML label
//         final product = products.firstWhere(
//               (p) => p['title'].toString().toLowerCase() == sealLabel.toLowerCase() ||
//               p['sku'].toString().toLowerCase() == sealLabel.toLowerCase(),
//           orElse: () => null,
//         );
//
//         if (product != null) {
//           setState(() {
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
//             _entry.description = product['description'] ?? '';
//             _entry.sealModelNumber = product['seal_model_number'] ?? '';
//
//             // Update Controllers so UI shows the values
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
//             _controllers['desc']!.text = _entry.description!;
//           });
//
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text("Specs auto-filled from database"), duration: Duration(seconds: 1)),
//           );
//         }
//       }
//     } catch (e) {
//       debugPrint("Auto-fill error: $e");
//     }
//   }
//
//   void _showSealDetection() async {
//     final result = await showModalBottomSheet<SealDetectionResult>(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => const SealDetectionComponent(),
//     );
//
//     if (result != null) {
//       setState(() {
//         _entry.isUnknownSeal = false;
//         _entry.manualSealName = result.label;
//         _entry.sealImage = result.images.isNotEmpty ? result.images.first : null;
//         _entry.allSealImages = result.images;
//         _entry.confidence = result.confidence;
//       });
//
//       // TRIGGER AUTO-FILL
//       _autoFillFromDatabase(result.label);
//     }
//   }
//
//   // --- UI BUILDERS ---
//   Widget _buildSectionTitle(String title) {
//     return Padding(
//       padding: const EdgeInsets.only(top: 20, bottom: 8),
//       child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary, letterSpacing: 1.1, fontSize: 13)),
//     );
//   }
//
//   Widget _buildVariantField(String label, String hint, TextEditingController controller, Function(String) onChanged, {bool isNumeric = false}) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: TextField(
//         controller: controller, // Use controller for auto-fill support
//         keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
//         decoration: InputDecoration(
//           labelText: label,
//           hintText: hint,
//           isDense: true,
//           border: const OutlineInputBorder(),
//         ),
//         onChanged: onChanged,
//       ),
//     );
//   }
//
//   Widget _buildCounter(String label, int value, Function(int) onChanged) {
//     return Column(
//       children: [
//         Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
//         Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             IconButton(onPressed: () => onChanged(value > 0 ? value - 1 : 0), icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent)),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//               decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(8)),
//               child: Text("$value", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             ),
//             IconButton(onPressed: () => onChanged(value + 1), icon: const Icon(Icons.add_circle_outline, color: Colors.green)),
//           ],
//         ),
//       ],
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(title: const Text("Add Asset Detail"), elevation: 0),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildSectionTitle("1. LOCATION"),
//             TextField(
//               decoration: const InputDecoration(hintText: "e.g. Main Kitchen", prefixIcon: Icon(Icons.location_on_outlined)),
//               onChanged: (val) => _entry.area = val,
//             ),
//
//             _buildSectionTitle("2. FRIDGE DATA PLATE"),
//             InkWell(
//               onTap: () async {
//                 final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
//                 if (photo != null) setState(() => _entry.dataPlateImage = File(photo.path));
//               },
//               child: Container(
//                 height: 150, width: double.infinity,
//                 decoration: BoxDecoration(
//                   color: Colors.grey[50], borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: Colors.grey[300]!),
//                   image: _entry.dataPlateImage != null ? DecorationImage(image: FileImage(_entry.dataPlateImage!), fit: BoxFit.cover) : null,
//                 ),
//                 child: _entry.dataPlateImage == null
//                     ? const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.camera_enhance_outlined, size: 40, color: Colors.grey), Text("Tap to capture Data Plate", style: TextStyle(color: Colors.grey, fontSize: 12))])
//                     : const Align(alignment: Alignment.bottomRight, child: Padding(padding: EdgeInsets.all(8.0), child: CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.edit, size: 20)))),
//               ),
//             ),
//
//             _buildSectionTitle("3. SEAL IDENTIFICATION"),
//             Row(
//               children: [
//                 Expanded(child: ChoiceChip(label: const Center(child: Text("Scan (ML)")), selected: _entry.isUnknownSeal || _entry.sealImage != null, onSelected: (val) => setState(() => _entry.isUnknownSeal = true))),
//                 const SizedBox(width: 10),
//                 Expanded(child: ChoiceChip(label: const Center(child: Text("Manual Entry")), selected: !_entry.isUnknownSeal && _entry.sealImage == null, onSelected: (val) { setState(() { _entry.isUnknownSeal = false; _entry.sealImage = null; _entry.manualSealName = ""; }); })),
//               ],
//             ),
//             const SizedBox(height: 12),
//
//             if (_entry.sealImage != null)
//               Container(
//                 padding: const EdgeInsets.all(12), margin: const EdgeInsets.only(bottom: 12),
//                 decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.green[200]!)),
//                 child: Row(children: [
//                   ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(_entry.sealImage!, width: 60, height: 60, fit: BoxFit.cover)),
//                   const SizedBox(width: 12),
//                   Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(_entry.manualSealName ?? "Detected Seal", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), Text("Confidence: ${(_entry.confidence * 100).toStringAsFixed(1)}%", style: TextStyle(color: Colors.green[700], fontSize: 12))])),
//                   IconButton(onPressed: _showSealDetection, icon: const Icon(Icons.refresh, color: Colors.green))
//                 ]),
//               )
//             else if (_entry.isUnknownSeal)
//               ElevatedButton.icon(
//                 style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accent1, minimumSize: const Size(double.infinity, 50)),
//                 onPressed: _showSealDetection,
//                 icon: const Icon(Icons.qr_code_scanner),
//                 label: const Text("OPEN ML SCANNER"),
//               )
//             else
//               TextField(
//                 decoration: const InputDecoration(hintText: "Enter Seal SKU or ID Manually"),
//                 onChanged: (val) {
//                   _entry.manualSealName = val;
//                   _autoFillFromDatabase(val); // Try to auto-fill even during manual typing
//                 },
//               ),
//
//             _buildSectionTitle("4. SEAL VARIANTS & SPECS"),
//             SwitchListTile(
//               title: const Text("Magnetic Seal?", style: TextStyle(fontSize: 14)),
//               value: _entry.isMagnetic,
//               onChanged: (val) => setState(() => _entry.isMagnetic = val),
//               activeColor: AppTheme.primary,
//             ),
//             _buildVariantField("Seal Type", "e.g. Compression", _controllers['type']!, (val) => _entry.sealType = val),
//             _buildVariantField("Material", "e.g. PVC", _controllers['material']!, (val) => _entry.material = val),
//             _buildVariantField("Hardness", "e.g. 70 Shore", _controllers['hardness']!, (val) => _entry.hardness = val),
//
//             Row(children: [
//               Expanded(child: _buildVariantField("Inner Dia", "mm", _controllers['inner']!, (val) => _entry.innerDiameter = double.tryParse(val) ?? 0, isNumeric: true)),
//               const SizedBox(width: 10),
//               Expanded(child: _buildVariantField("Outer Dia", "mm", _controllers['outer']!, (val) => _entry.outerDiameter = double.tryParse(val) ?? 0, isNumeric: true)),
//             ]),
//             Row(children: [
//               Expanded(child: _buildVariantField("Thickness", "mm", _controllers['thickness']!, (val) => _entry.thickness = double.tryParse(val) ?? 0, isNumeric: true)),
//               const SizedBox(width: 10),
//               Expanded(child: _buildVariantField("Model #", "Seal Model", _controllers['modelNum']!, (val) => _entry.sealModelNumber = val)),
//             ]),
//
//             _buildVariantField("Temperature Range", "e.g. -20C to 80C", _controllers['temp']!, (val) => _entry.tempRange = val),
//             _buildVariantField("Brand", "e.g. Foster", _controllers['brand']!, (val) => _entry.brand = val),
//             _buildVariantField("Application", "e.g. Fridge", _controllers['app']!, (val) => _entry.application = val),
//
//             TextField(
//               controller: _controllers['desc'],
//               maxLines: 3,
//               decoration: const InputDecoration(labelText: "Description/Notes", border: OutlineInputBorder()),
//               onChanged: (val) => _entry.description = val,
//             ),
//
//             _buildSectionTitle("5. QUANTITIES"),
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)),
//               child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
//                 _buildCounter("DOORS", _entry.doorCount, (val) => setState(() => _entry.doorCount = val)),
//                 _buildCounter("DRAWERS", _entry.drawerCount, (val) => setState(() => _entry.drawerCount = val)),
//               ]),
//             ),
//
//             const SizedBox(height: 40),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 60), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
//               onPressed: () {
//                 if (_entry.area.isEmpty) {
//                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter a location")));
//                   return;
//                 }
//                 widget.onSave(_entry);
//                 Navigator.pop(context);
//               },
//               child: const Text("SAVE FRIDGE ASSET", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//             ),
//             const SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }
// }
// // // // //
// // // // //
// // // // //

// // // //
// // // //
// // // //
// // // //


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


// //
// //
// //
// //
// // import 'dart:convert';
// // import 'dart:io';
// // import 'package:flutter/material.dart';
// // import 'package:http/http.dart' as http;
// // import 'package:image_picker/image_picker.dart';
// // import 'package:shared_preferences/shared_preferences.dart';
// // import 'package:supabase_flutter/supabase_flutter.dart';
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
// //   // Controllers for Fridge Data fields
// //   final TextEditingController _manufacturerController = TextEditingController();
// //   final TextEditingController _modelController = TextEditingController();
// //   final TextEditingController _serialController = TextEditingController();
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _syncIndividualItemsList();
// //   }
// //
// //   @override
// //   void dispose() {
// //     _manufacturerController.dispose();
// //     _modelController.dispose();
// //     _serialController.dispose();
// //     for (var seal in _entry.individualSeals) {
// //       seal.disposeControllers();
// //     }
// //     super.dispose();
// //   }
// //
// //   void _syncIndividualItemsList() {
// //     int totalNeeded = _entry.doorCount + _entry.drawerCount;
// //     setState(() {
// //       if (_entry.sealsAreCommon) {
// //         if (_entry.individualSeals.isEmpty) {
// //           _entry.individualSeals = [IndividualSeal(itemName: "Common Seal")];
// //         } else if (_entry.individualSeals.length > 1) {
// //           _entry.individualSeals = [_entry.individualSeals[0]];
// //         }
// //       } else {
// //         List<IndividualSeal> newList = [];
// //         for (int i = 0; i < totalNeeded; i++) {
// //           String label = i < _entry.doorCount
// //               ? "Door ${i + 1}"
// //               : "Drawer ${i - _entry.doorCount + 1}";
// //
// //           if (i < _entry.individualSeals.length) {
// //             newList.add(_entry.individualSeals[i]);
// //           } else {
// //             newList.add(IndividualSeal(itemName: label));
// //           }
// //         }
// //         _entry.individualSeals = newList;
// //       }
// //     });
// //   }
// //
// //   Future<void> _uploadAndExtractFridgePlate(File imageFile) async {
// //     try {
// //       final supabase = Supabase.instance.client;
// //
// //       showDialog(
// //         context: context,
// //         barrierDismissible: false,
// //         builder: (_) => const Center(child: CircularProgressIndicator()),
// //       );
// //
// //       final fileName = 'fridge_plates/${DateTime.now().millisecondsSinceEpoch}.jpg';
// //
// //       await supabase.storage.from('fridge-plates').upload(fileName, imageFile);
// //       final imageUrl = supabase.storage.from('fridge-plates').getPublicUrl(fileName);
// //
// //       final response = await http.post(
// //         Uri.parse('https://brrdkdabcoilwebmbrlx.supabase.co/functions/v1/extract-fridge-plate'),
// //         headers: {
// //           'Content-Type': 'application/json',
// //           'apikey': 'YOUR_SUPABASE_ANON_KEY', // Replace with your actual key
// //           'Authorization': 'Bearer YOUR_SUPABASE_ANON_KEY', // Replace with your actual key
// //         },
// //         body: jsonEncode({
// //           "imageUrl": imageUrl,
// //           "createdBy": supabase.auth.currentUser?.id,
// //         }),
// //       );
// //
// //       if (mounted) Navigator.pop(context);
// //
// //       if (response.statusCode != 200) {
// //         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Extraction failed")));
// //         return;
// //       }
// //
// //       final data = jsonDecode(response.body);
// //       final extracted = data["extracted"];
// //
// //       setState(() {
// //         _entry.fridgeId = data["fridge_id"];
// //         _entry.manufacturer = extracted["manufacturer"] ?? "";
// //         _entry.modelNo = extracted["model_no"] ?? "";
// //         _entry.serialNo = extracted["serial_no"] ?? "";
// //         _entry.doorCount = extracted["door_count"] ?? 0;
// //         _entry.drawerCount = extracted["drawer_count"] ?? 0;
// //
// //         _manufacturerController.text = _entry.manufacturer;
// //         _modelController.text = _entry.modelNo;
// //         _serialController.text = _entry.serialNo;
// //       });
// //
// //       _syncIndividualItemsList();
// //       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Fridge data extracted successfully")));
// //     } catch (e) {
// //       if (mounted) Navigator.pop(context);
// //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
// //     }
// //   }
// //
// //   Future<void> _autoFillFromDatabase(String sealLabel, int index) async {
// //     try {
// //       final prefs = await SharedPreferences.getInstance();
// //       final String? productsJson = prefs.getString('local_products');
// //       if (productsJson == null) return;
// //
// //       final List<dynamic> products = jsonDecode(productsJson);
// //       final product = products.firstWhere(
// //             (p) => p['title'].toString().toLowerCase() == sealLabel.toLowerCase() || p['sku'].toString().toLowerCase() == sealLabel.toLowerCase(),
// //         orElse: () => null,
// //       );
// //
// //       if (product != null) {
// //         setState(() {
// //           var item = _entry.individualSeals[index];
// //           item.sealId = product['id'].toString();
// //           item.sealName = product['title'];
// //           item.isMagnetic = product['is_magnetic'] ?? false;
// //           item.sealType = product['seal_type'] ?? '';
// //           item.material = product['material'] ?? '';
// //           item.hardness = product['hardness'] ?? '';
// //           item.innerDiameter = (product['inner_diameter'] ?? 0).toDouble();
// //           item.outerDiameter = (product['outer_diameter'] ?? 0).toDouble();
// //           item.thickness = (product['thickness'] ?? 0).toDouble();
// //           item.tempRange = product['temperature_range'] ?? '';
// //           item.brand = product['brand'] ?? '';
// //           item.application = product['application'] ?? '';
// //           item.sealModelNumber = product['seal_model_number'] ?? '';
// //           item.description = product['description'] ?? '';
// //           item.updateControllers();
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
// //         if (_entry.sealsAreCommon) {
// //           _entry.sealImage = result.images.isNotEmpty ? result.images.first : null;
// //         }
// //       });
// //       _autoFillFromDatabase(result.label, index);
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: Colors.white,
// //       appBar: AppBar(title: const Text("Add Asset Detail"), elevation: 0),
// //       body: SingleChildScrollView(
// //         child: Padding(
// //           padding: const EdgeInsets.all(16),
// //           child: Column(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               _buildSectionTitle("1. LOCATION"),
// //               TextField(
// //                 decoration: const InputDecoration(hintText: "e.g. Main Kitchen", border: OutlineInputBorder()),
// //                 onChanged: (val) => _entry.area = val,
// //               ),
// //
// //               _buildSectionTitle("2. FRIDGE DATA PLATE"),
// //               _buildDataPlatePicker(),
// //
// //               const SizedBox(height: 16),
// //               // Manual/Autofilled Fridge Fields
// //               Container(
// //                 padding: const EdgeInsets.all(12),
// //                 decoration: BoxDecoration(color: Colors.blueGrey[50], borderRadius: BorderRadius.circular(12)),
// //                 child: Column(
// //                   spacing: 8,
// //                   children: [
// //                     TextField(
// //                       controller: _manufacturerController,
// //                       decoration: const InputDecoration(labelText: "Manufacturer", isDense: true),
// //                       onChanged: (val) => _entry.manufacturer = val,
// //                     ),
// //                     TextField(
// //                       controller: _modelController,
// //                       decoration: const InputDecoration(labelText: "Model Number", isDense: true),
// //                     ),
// //                     TextField(
// //                       controller: _serialController,
// //                       decoration: const InputDecoration(labelText: "Serial Number", isDense: true),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //
// //               _buildSectionTitle("3. QUANTITIES"),
// //               Container(
// //                 padding: const EdgeInsets.all(12),
// //                 decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)),
// //                 child: Row(
// //                   mainAxisAlignment: MainAxisAlignment.spaceAround,
// //                   children: [
// //                     _counterWidget("DOORS", _entry.doorCount, (val) {
// //                       _entry.doorCount = val;
// //                       _syncIndividualItemsList();
// //                     }),
// //                     _counterWidget("DRAWERS", _entry.drawerCount, (val) {
// //                       _entry.drawerCount = val;
// //                       _syncIndividualItemsList();
// //                     }),
// //                   ],
// //                 ),
// //               ),
// //
// //               _buildSectionTitle("4. SEAL CONFIGURATION"),
// //               SwitchListTile(
// //                 contentPadding: EdgeInsets.zero,
// //                 title: const Text("Use same seal for all items?", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
// //                 value: _entry.sealsAreCommon,
// //                 activeColor: AppTheme.primary,
// //                 onChanged: (val) {
// //                   _entry.sealsAreCommon = val;
// //                   _syncIndividualItemsList();
// //                 },
// //               ),
// //
// //               const Divider(),
// //
// //               Column(
// //                 children: List.generate(_entry.individualSeals.length, (index) {
// //                   return _buildItemVariantCard(index, _entry.individualSeals[index]);
// //                 }),
// //               ),
// //
// //               const SizedBox(height: 30),
// //               SizedBox(
// //                 width: double.infinity,
// //                 child: ElevatedButton(
// //                   style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 18)),
// //                   onPressed: () {
// //                     if (_entry.area.isEmpty) {
// //                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Location required")));
// //                       return;
// //                     }
// //                     // Final Sync of Controller values
// //                     _entry.modelNo = _modelController.text;
// //                     _entry.serialNo = _serialController.text;
// //                     _entry.manufacturer = _manufacturerController.text;
// //
// //                     for (var seal in _entry.individualSeals) {
// //                       seal.sealType = seal.ctrls['type']!.text;
// //                       seal.material = seal.ctrls['material']!.text;
// //                       seal.hardness = seal.ctrls['hardness']!.text;
// //                       seal.innerDiameter = double.tryParse(seal.ctrls['inner']!.text) ?? 0.0;
// //                       seal.outerDiameter = double.tryParse(seal.ctrls['outer']!.text) ?? 0.0;
// //                       seal.thickness = double.tryParse(seal.ctrls['thickness']!.text) ?? 0.0;
// //                       seal.sealModelNumber = seal.ctrls['modelNum']!.text;
// //                       seal.tempRange = seal.ctrls['temp']!.text;
// //                       seal.brand = seal.ctrls['brand']!.text;
// //                       seal.application = seal.ctrls['app']!.text;
// //                       seal.description = seal.ctrls['desc']!.text;
// //                     }
// //
// //                     widget.onSave(_entry);
// //                     Navigator.pop(context);
// //                   },
// //                   child: const Text("SAVE FRIDGE ASSET", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
// //                 ),
// //               ),
// //               const SizedBox(height: 30),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildItemVariantCard(int index, IndividualSeal item) {
// //     return Card(
// //       elevation: 0,
// //       margin: const EdgeInsets.only(bottom: 24),
// //       color: item.isIdentified ? Colors.green[50]!.withOpacity(0.3) : Colors.grey[50],
// //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey[200]!)),
// //       child: Padding(
// //         padding: const EdgeInsets.all(16.0),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             Row(children: [
// //               Icon(item.isIdentified ? Icons.check_circle : Icons.qr_code_scanner, color: item.isIdentified ? Colors.green : Colors.grey),
// //               const SizedBox(width: 8),
// //               Text(item.itemName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
// //               const Spacer(),
// //               if (item.isIdentified) Text("${(item.confidence * 100).toStringAsFixed(0)}% Match", style: const TextStyle(fontSize: 10, color: Colors.green)),
// //             ]),
// //             if (item.images.isNotEmpty) ...[
// //               const SizedBox(height: 12),
// //               SizedBox(
// //                 height: 80,
// //                 child: ListView.builder(
// //                   scrollDirection: Axis.horizontal,
// //                   shrinkWrap: true,
// //                   physics: const ClampingScrollPhysics(),
// //                   itemCount: item.images.length,
// //                   itemBuilder: (c, i) => Padding(
// //                     padding: const EdgeInsets.only(right: 8),
// //                     child: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(item.images[i], width: 80, height: 80, fit: BoxFit.cover)),
// //                   ),
// //                 ),
// //               ),
// //             ],
// //             const SizedBox(height: 12),
// //             Row(
// //               children: [
// //                 Expanded(child: Text(item.isIdentified ? "SKU: ${item.sealName}" : "Not scanned", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
// //                 SizedBox(
// //                   width: 110,
// //                   child: ElevatedButton(
// //                     onPressed: () => _showSealDetection(index),
// //                     style: ElevatedButton.styleFrom(visualDensity: VisualDensity.compact),
// //                     child: Text(item.isIdentified ? "RE-SCAN" : "SCAN SEAL"),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //             const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider()),
// //             _variantInputWidget("Seal Type", item.ctrls['type']!, (v) => item.sealType = v),
// //             _variantInputWidget("Material", item.ctrls['material']!, (v) => item.material = v),
// //             _variantInputWidget("Hardness", item.ctrls['hardness']!, (v) => item.hardness = v),
// //             Row(children: [
// //               Expanded(child: _variantInputWidget("Inner Dia (mm)", item.ctrls['inner']!, (v) => item.innerDiameter = double.tryParse(v.toString()) ?? 0, isNum: true)),
// //               const SizedBox(width: 10),
// //               Expanded(child: _variantInputWidget("Outer Dia (mm)", item.ctrls['outer']!, (v) => item.outerDiameter = double.tryParse(v.toString()) ?? 0, isNum: true)),
// //             ]),
// //             Row(children: [
// //               Expanded(child: _variantInputWidget("Thickness (mm)", item.ctrls['thickness']!, (v) => item.thickness = double.tryParse(v.toString()) ?? 0, isNum: true)),
// //               const SizedBox(width: 10),
// //               Expanded(child: _variantInputWidget("Model #", item.ctrls['modelNum']!, (v) => item.sealModelNumber = v)),
// //             ]),
// //             _variantInputWidget("Temperature Range", item.ctrls['temp']!, (v) => item.tempRange = v),
// //             _variantInputWidget("Brand", item.ctrls['brand']!, (v) => item.brand = v),
// //             _variantInputWidget("Application", item.ctrls['app']!, (v) => item.application = v),
// //             const SizedBox(height: 8),
// //             TextField(
// //               controller: item.ctrls['desc'],
// //               maxLines: 2,
// //               decoration: const InputDecoration(labelText: "Notes for this seal", border: OutlineInputBorder(), isDense: true),
// //               onChanged: (val) => item.description = val,
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _variantInputWidget(String label, TextEditingController ctrl, Function(dynamic) onC, {bool isNum = false}) => Padding(
// //     padding: const EdgeInsets.only(bottom: 12),
// //     child: TextField(
// //       controller: ctrl,
// //       keyboardType: isNum ? TextInputType.number : TextInputType.text,
// //       decoration: InputDecoration(labelText: label, border: const OutlineInputBorder(), isDense: true),
// //       onChanged: (val) {
// //         if (isNum) {
// //           onC(double.tryParse(val) ?? 0);
// //         } else {
// //           onC(val);
// //         }
// //       },
// //     ),
// //   );
// //
// //   Widget _buildSectionTitle(String title) => Padding(
// //     padding: const EdgeInsets.only(top: 20, bottom: 8),
// //     child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary, fontSize: 13)),
// //   );
// //
// //   Widget _counterWidget(String label, int value, Function(int) onChanged) => Column(
// //     children: [
// //       Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
// //       Row(mainAxisSize: MainAxisSize.min, children: [
// //         IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: () => setState(() => onChanged(value > 0 ? value - 1 : 0))),
// //         Text("$value", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
// //         IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () => setState(() => onChanged(value + 1))),
// //       ])
// //     ],
// //   );
// //
// //   Widget _buildDataPlatePicker() => InkWell(
// //     onTap: () async {
// //       // Show Source Choice (Camera or Gallery)
// //       final ImageSource? source = await showModalBottomSheet<ImageSource>(
// //         context: context,
// //         builder: (context) => SafeArea(
// //           child: Column(
// //             mainAxisSize: MainAxisSize.min,
// //             children: [
// //               ListTile(leading: const Icon(Icons.camera_alt), title: const Text('Camera'), onTap: () => Navigator.pop(context, ImageSource.camera)),
// //               ListTile(leading: const Icon(Icons.photo_library), title: const Text('Gallery'), onTap: () => Navigator.pop(context, ImageSource.gallery)),
// //             ],
// //           ),
// //         ),
// //       );
// //
// //       if (source == null) return;
// //
// //       final XFile? photo = await _picker.pickImage(source: source);
// //       if (photo != null) {
// //         final file = File(photo.path);
// //         setState(() => _entry.dataPlateImage = file);
// //         await _uploadAndExtractFridgePlate(file);
// //       }
// //     },
// //     child: Container(
// //       height: 120, width: double.infinity,
// //       decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[300]!)),
// //       child: _entry.dataPlateImage == null
// //           ? const Column(
// //         mainAxisAlignment: MainAxisAlignment.center,
// //         children: [
// //           Icon(Icons.add_a_photo_outlined, color: Colors.grey),
// //           Text("Tap to capture Data Plate", style: TextStyle(color: Colors.grey, fontSize: 12)),
// //         ],
// //       )
// //           : ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(_entry.dataPlateImage!, fit: BoxFit.cover)),
// //     ),
// //   );
// // }
//
//












































import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../components/image_previewer.dart';
import '../../components/seal_detection_component.dart';
import '../../theme.dart';
import 'new_report_page.dart';


class AddAssetPage extends StatefulWidget {
  final Function(LocalAssetEntry) onSave;
  const AddAssetPage({super.key, required this.onSave});

  @override
  State<AddAssetPage> createState() => _AddAssetPageState();
}

// class _AddAssetPageState extends State<AddAssetPage> {
// Update your class line to look like this:
class _AddAssetPageState extends State<AddAssetPage> with SingleTickerProviderStateMixin {
  final LocalAssetEntry _entry = LocalAssetEntry();
  final _picker = ImagePicker();
  late AnimationController _scanController;
  bool _isExtracting = false;
  String? _extractionError;


  // Controllers for Fridge Data fields
  final TextEditingController _brandController = TextEditingController(); // Changed from Manufacturer
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _serialController = TextEditingController();
  List<Map<String, dynamic>> _allProducts = [];

  @override
  void initState() {
    super.initState();
    _syncIndividualItemsList();
    // Initialize the scanning animation (2 seconds per loop)
    _loadLocalProducts();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _scanController.dispose(); // Clean up
    _brandController.dispose();
    _modelController.dispose();

    _serialController.dispose();
    for (var seal in _entry.individualSeals) {
      seal.disposeControllers();
    }
    super.dispose();
  }


  // Helper method to show a searchable product list

  void _showProductSearch(int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        List<Map<String, dynamic>> filtered = List.from(_allProducts);

        return StatefulBuilder(
          builder: (context, setModalState) => DraggableScrollableSheet(
            initialChildSize: 0.8,
            maxChildSize: 0.95,
            minChildSize: 0.5,
            expand: false,
            builder: (_, controller) => Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              // We use a Scaffold inside the modal to provide a clean layout structure
              child: Scaffold(
                backgroundColor: Colors.transparent,
                body: Column(
                  children: [
                    // Drag Handle
                    Center(
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        width: 40, height: 4,
                        decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const Text("Select Seal Model", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Search Model # or SKU...",
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                        onChanged: (val) {
                          setModalState(() {
                            if (val.isEmpty) {
                              filtered = List.from(_allProducts);
                            } else {
                              filtered = _allProducts.where((p) =>
                              p['seal_model_number'].toString().toLowerCase().contains(val.toLowerCase()) ||
                                  p['title'].toString().toLowerCase().contains(val.toLowerCase())
                              ).toList();
                            }
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: filtered.isEmpty
                          ? const Center(child: Text("No products found locally"))
                          : ListView.builder(
                        controller: controller,
                        itemCount: filtered.length,
                        itemBuilder: (context, i) {
                          final p = filtered[i];
                          return ListTile(
                            leading: const Icon(Icons.qr_code, color: AppTheme.primary),
                            title: Text(p['seal_model_number'] ?? 'No Model #', style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(p['title'] ?? ''),
                            trailing: const Icon(Icons.add_circle_outline, color: Colors.green),
                            onTap: () {
                              Navigator.pop(context);
                              _autoFillFromSelectedProduct(p, index);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }


// Logic to populate the spec fields (Section 4 in image 1000166586.jpg)
  void _autoFillFromSelectedProduct(Map<String, dynamic> p, int index) {
    setState(() {
      var item = _entry.individualSeals[index];
      item.isIdentified = true;
      item.sealId = p['id'].toString();
      item.sealName = p['title'];

      // Technical Data Auto-Fill
      item.sealType = p['seal_type'] ?? '';
      item.material = p['material'] ?? '';
      item.hardness = p['hardness'] ?? '';
      item.innerDiameter = (p['inner_diameter'] ?? 0).toDouble();
      item.outerDiameter = (p['outer_diameter'] ?? 0).toDouble();
      item.thickness = (p['thickness'] ?? 0).toDouble();
      item.sealModelNumber = p['seal_model_number'] ?? '';
      item.brand = p['brand'] ?? '';

      item.updateControllers(); // Pushes data to TextFields
    });
  }

  Future<void> _loadLocalProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? productsJson = prefs.getString('local_products');
      if (productsJson != null) {
        setState(() {
          _allProducts = List<Map<String, dynamic>>.from(jsonDecode(productsJson));
        });
      }
    } catch (e) {
      debugPrint("Error loading local products: $e");
    }
  }


  Future<void> _pickDataPlateImage() async {
    // 1. Show selection for Camera or Gallery
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    // 2. Pick the image
    final XFile? photo = await _picker.pickImage(source: source);

    if (photo != null) {
      final file = File(photo.path);

      // 3. Update the local entry state
      setState(() {
        _entry.dataPlateImage = file;
      });

      // 4. Trigger the OCR/Edge Function
      await _uploadAndExtractFridgePlate(file);
    }
  }


  // --- 1. LOCAL SEARCH & AUTO-POPULATION LOGIC ---

  Future<List<Map<String, dynamic>>> _findMatchingFridges() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? fridgesJson = prefs.getString('local_fridges');
      if (fridgesJson == null) return [];

      final List<dynamic> allFridges = jsonDecode(fridgesJson);
      final String searchBrand = _brandController.text.trim().toLowerCase();
      final String searchModel = _modelController.text.trim().toLowerCase();

      if (searchBrand.isEmpty && searchModel.isEmpty) return [];

      return allFridges.where((f) {
        // Search in both brand and manufacturer fields for safety
        final fBrand = (f['brand'] ?? f['manufacturer'] ?? "").toString().toLowerCase();
        final fModel = (f['model_no'] ?? "").toString().toLowerCase();

        bool brandMatch = searchBrand.isEmpty || fBrand.contains(searchBrand);
        bool modelMatch = searchModel.isEmpty || fModel.contains(searchModel);

        return brandMatch && modelMatch;
      }).map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) {
      debugPrint("Local Search Error: $e");
      return [];
    }
  }

  Widget _buildScanningOverlay() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return AnimatedBuilder(
          animation: _scanController,
          builder: (context, child) {
            return Stack(
              children: [
                // Faint overlay that only covers the image area
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                  ),
                ),
                // The Moving "Laser" Line
                Positioned(
                  // Constraints.maxHeight is now the image height, not the container height
                  top: _scanController.value * constraints.maxHeight,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 3,
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withOpacity(0.8),
                          blurRadius: 10,
                          spreadRadius: 2,
                        )
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // void _showFridgeSelection(List<Map<String, dynamic>> matches) {
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
  //     builder: (context) => DraggableScrollableSheet(
  //       initialChildSize: 0.6,
  //       maxChildSize: 0.9,
  //       expand: false,
  //       builder: (_, controller) => Column(
  //         children: [
  //           Container(
  //             margin: const EdgeInsets.symmetric(vertical: 12),
  //             width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
  //           ),
  //           const Padding(
  //             padding: EdgeInsets.only(bottom: 16),
  //             child: Text("Select Correct Fridge Model", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
  //           ),
  //           Expanded(
  //             child: ListView.builder(
  //               controller: controller,
  //               itemCount: matches.length,
  //               itemBuilder: (context, i) {
  //                 final f = matches[i];
  //                 final sealModel = f['seal_model_number'] ?? 'N/A';
  //                 // return ListTile(
  //                 //   leading: const Icon(Icons.kitchen, color: AppTheme.primary),
  //                 //   title: Text("${f['brand'] ?? f['manufacturer']} - ${f['model_no']}"),
  //                 //   subtitle: Text("Doors: ${f['door_count']} | Drawers: ${f['drawer_count']}"),
  //                 //   trailing: const Icon(Icons.chevron_right),
  //                 //   onTap: () {
  //                 //     Navigator.pop(context);
  //                 //     _applyFridgeConfiguration(f);
  //                 //   },
  //                 // );
  //
  //                 return ListTile(
  //                   leading: const Icon(Icons.kitchen, color: AppTheme.primary),
  //                   title: Text("${f['brand'] ?? f['manufacturer']} - ${f['model_no']}"),
  //                   subtitle: Column( // Use a Column to show multiple lines of data
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       Text("Doors: ${f['door_count']} | Drawers: ${f['drawer_count']}"),
  //                       Text("Seal Model: $sealModel", style: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold)),
  //                     ],
  //                   ),
  //                   trailing: const Icon(Icons.chevron_right),
  //                   onTap: () {
  //                     Navigator.pop(context);
  //                     _applyFridgeConfiguration(f);
  //                   },
  //                 );
  //               },
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }



  void _showFridgeSelection(List<Map<String, dynamic>> matches) async {
    final prefs = await SharedPreferences.getInstance();
    final String? relationsJson = prefs.getString('local_fridge_relations');
    List<dynamic> allRelations = relationsJson != null ? jsonDecode(relationsJson) : [];

    // 1. We create a list of "Display Items" that combines Fridge + Relation data
    List<Map<String, dynamic>> displayItems = [];

    for (var fridge in matches) {
      // Find ALL relations for this specific fridge model
      final fridgeRels = allRelations.where((r) => r['fridge_id'] == fridge['id']).toList();

      if (fridgeRels.isEmpty) {
        // If no relations exist, just add the fridge itself
        displayItems.add({'fridge': fridge, 'rel': null});
      } else {
        // Add a separate entry for EVERY relation found
        for (var rel in fridgeRels) {
          displayItems.add({'fridge': fridge, 'rel': rel});
        }
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, controller) => Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text("Select Configuration", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            Expanded(
              child: ListView.builder(
                controller: controller,
                itemCount: displayItems.length,
                itemBuilder: (context, i) {
                  final item = displayItems[i];
                  final f = item['fridge'];
                  final r = item['rel'];

                  String sealModel = 'N/A';
                  String location = 'General';

                  if (r != null && r['seal_products'] != null) {
                    sealModel = r['seal_products']['seal_model_number'] ?? 'N/A';
                    location = r['location'] ?? 'Universal';
                  }

                  return ListTile(
                    leading: const Icon(Icons.kitchen, color: AppTheme.primary),
                    title: Text("${f['brand'] ?? f['manufacturer']} - ${f['model_no']}"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Location: $location", style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600)),
                        Text("Seal Model: $sealModel", style: const TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.pop(context);
                      _applyFridgeConfiguration(f, selectedRelationId: r?['id']);                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Future<void> _applyFridgeConfiguration(Map<String, dynamic> fridge) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final String? relationsJson = prefs.getString('local_fridge_relations');
  //   if (relationsJson == null) return;
  //
  //   List<dynamic> allRelations = jsonDecode(relationsJson);
  //   List<dynamic> fridgeRelations = allRelations.where((r) => r['fridge_id'] == fridge['id']).toList();
  //
  //   setState(() {
  //     _entry.fridgeId = fridge['id'];
  //     _entry.brand = fridge['brand'] ?? fridge['manufacturer'];
  //     _entry.modelNo = fridge['model_no'];
  //     _entry.doorCount = fridge['door_count'] ?? 0;
  //     _entry.drawerCount = fridge['drawer_count'] ?? 0;
  //
  //     _brandController.text = _entry.brand!;
  //     _modelController.text = _entry.modelNo;
  //
  //     // Determine configuration
  //     final uniqueSeals = fridgeRelations.map((r) => r['seal_product_id']).toSet();
  //     _entry.sealsAreCommon = uniqueSeals.length <= 1;
  //
  //     _entry.individualSeals.clear();
  //
  //     if (fridgeRelations.isEmpty) {
  //       _syncIndividualItemsList();
  //     } else {
  //       for (var rel in fridgeRelations) {
  //         final sealData = rel['seal_products'];
  //         final item = IndividualSeal(itemName: rel['location'] ?? "Item");
  //
  //         if (sealData != null) {
  //           item.sealId = sealData['id'];
  //           item.sealName = sealData['title'];
  //           item.isIdentified = true;
  //           item.sealType = sealData['seal_type'] ?? '';
  //           item.material = sealData['material'] ?? '';
  //           item.innerDiameter = (sealData['inner_diameter'] ?? 0).toDouble();
  //           item.outerDiameter = (sealData['outer_diameter'] ?? 0).toDouble();
  //           item.thickness = (sealData['thickness'] ?? 0).toDouble();
  //           item.brand = sealData['brand'] ?? '';
  //           item.updateControllers();
  //         }
  //         _entry.individualSeals.add(item);
  //       }
  //     }
  //   });
  //
  //   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Fridge Asset and Seals Populated")));
  // }


  // Future<void> _applyFridgeConfiguration(Map<String, dynamic> fridge) async {
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     final String? relationsJson = prefs.getString('local_fridge_relations');
  //     if (relationsJson == null) return;
  //
  //     List<dynamic> allRelations = jsonDecode(relationsJson);
  //     // Filter relations for THIS specific fridge
  //     List<dynamic> fridgeRelations = allRelations.where((r) => r['fridge_id'] == fridge['id']).toList();
  //
  //     setState(() {
  //       // 1. Populate Fridge Header Data
  //       _entry.fridgeId = fridge['id'];
  //       _entry.brand = fridge['brand'] ?? fridge['manufacturer'];
  //       _entry.modelNo = fridge['model_no'];
  //       _entry.doorCount = fridge['door_count'] ?? 0;
  //       _entry.drawerCount = fridge['drawer_count'] ?? 0;
  //
  //       // Update Top-level Controllers
  //       _brandController.text = _entry.brand!;
  //       _modelController.text = _entry.modelNo;
  //
  //       // 2. Determine if seals are common or different
  //       final uniqueSeals = fridgeRelations.map((r) => r['seal_product_id']).toSet();
  //       _entry.sealsAreCommon = uniqueSeals.length <= 1;
  //
  //       // 3. Clear existing list and populate from relations
  //       _entry.individualSeals.clear();
  //
  //       if (fridgeRelations.isEmpty) {
  //         // Fallback to default empty items if no database relations found
  //         _syncIndividualItemsList();
  //       } else {
  //         for (var rel in fridgeRelations) {
  //           final sealData = rel['seal_products'];
  //           final item = IndividualSeal(itemName: rel['location'] ?? "Item");
  //
  //           if (sealData != null) {
  //             // Identifier Info
  //             item.sealId = sealData['id'];
  //             item.sealName = sealData['title'];
  //             item.isIdentified = true;
  //
  //             // Physical Attributes
  //             item.sealType = sealData['seal_type'] ?? '';
  //             item.material = sealData['material'] ?? '';
  //             item.hardness = sealData['hardness'] ?? '';
  //             item.innerDiameter = (sealData['inner_diameter'] ?? 0).toDouble();
  //             item.outerDiameter = (sealData['outer_diameter'] ?? 0).toDouble();
  //             item.thickness = (sealData['thickness'] ?? 0).toDouble();
  //
  //             // Brand & Product Info
  //             item.brand = sealData['brand'] ?? '';
  //             item.sealModelNumber = sealData['seal_model_number'] ?? ''; // <--- ADDED THIS LINE
  //             item.tempRange = sealData['temperature_range'] ?? '';
  //             item.application = sealData['application'] ?? '';
  //             item.description = sealData['description'] ?? '';
  //
  //             // This pushes all assigned values above into the TextEditingControllers
  //             item.updateControllers();
  //           }
  //           _entry.individualSeals.add(item);
  //         }
  //       }
  //     });
  //
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text("Fridge Asset and Seal Models Populated"),
  //         backgroundColor: Colors.green,
  //       ),
  //     );
  //   } catch (e) {
  //     debugPrint("Error applying fridge configuration: $e");
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Error loading configuration: $e"), backgroundColor: Colors.red),
  //     );
  //   }
  // }



  Future<void> _applyFridgeConfiguration(Map<String, dynamic> fridge, {String? selectedRelationId}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? relationsJson = prefs.getString('local_fridge_relations');
      if (relationsJson == null) return;

      List<dynamic> allRelations = jsonDecode(relationsJson);

      // 1. Get ALL relations for this fridge model
      List<dynamic> fridgeRelations = allRelations.where((r) => r['fridge_id'] == fridge['id']).toList();

      // 2. Filter logic for the specific selection
      List<dynamic> targetRelations;
      if (selectedRelationId != null) {
        // If a specific seal was tapped, we only want to auto-fill that one seal's details
        targetRelations = fridgeRelations.where((r) => r['id'] == selectedRelationId).toList();
      } else {
        targetRelations = fridgeRelations;
      }

      setState(() {
        // --- FRIDGE HEADER DATA ---
        _entry.fridgeId = fridge['id'];
        _entry.brand = fridge['brand'] ?? fridge['manufacturer'];
        _entry.modelNo = fridge['model_no'];
        _entry.serialNo = _serialController.text;

        // Update Top-level UI Controllers
        _brandController.text = _entry.brand!;
        _modelController.text = _entry.modelNo;

        // --- QUANTITY LOGIC FIX ---
        // We always take the master counts from the fridge table so they are never "0"
        // unless the fridge actually has 0 in the database.
        _entry.doorCount = fridge['door_count'] ?? 0;
        _entry.drawerCount = fridge['drawer_count'] ?? 0;

        // --- SEAL LIST POPULATION ---
        _entry.individualSeals.clear();

        if (targetRelations.isEmpty) {
          _syncIndividualItemsList();
        } else {
          for (var rel in targetRelations) {
            final sealData = rel['seal_products'];
            final item = IndividualSeal(itemName: rel['location'] ?? "Selected Item");

            if (sealData != null) {
              item.sealId = sealData['id'];
              item.sealName = sealData['title'];
              item.isIdentified = true;
              item.sealType = sealData['seal_type'] ?? '';
              item.material = sealData['material'] ?? '';
              item.hardness = sealData['hardness'] ?? '';
              item.innerDiameter = (sealData['inner_diameter'] ?? 0).toDouble();
              item.outerDiameter = (sealData['outer_diameter'] ?? 0).toDouble();
              item.thickness = (sealData['thickness'] ?? 0).toDouble();
              item.brand = sealData['brand'] ?? '';
              item.sealModelNumber = sealData['seal_model_number'] ?? '';
              item.tempRange = sealData['temperature_range'] ?? '';
              item.application = sealData['application'] ?? '';
              item.description = sealData['description'] ?? '';

              item.updateControllers();
            }
            _entry.individualSeals.add(item);
          }
        }

        // If we only populated one specific seal, set common to true so the UI is simple
        _entry.sealsAreCommon = _entry.individualSeals.length <= 1;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Configuration Applied Successfully"), backgroundColor: Colors.green),
      );
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  // --- 2. EXISTING CORE LOGIC ---

  // void _syncIndividualItemsList() {
  //   int totalNeeded = _entry.doorCount + _entry.drawerCount;
  //   setState(() {
  //     if (_entry.sealsAreCommon) {
  //       if (_entry.individualSeals.isEmpty) {
  //         _entry.individualSeals = [IndividualSeal(itemName: "Common Seal")];
  //       } else if (_entry.individualSeals.length > 1) {
  //         _entry.individualSeals = [_entry.individualSeals[0]];
  //       }
  //     } else {
  //       List<IndividualSeal> newList = [];
  //       for (int i = 0; i < totalNeeded; i++) {
  //         String label = i < _entry.doorCount ? "Door ${i + 1}" : "Drawer ${i - _entry.doorCount + 1}";
  //         if (i < _entry.individualSeals.length) {
  //           newList.add(_entry.individualSeals[i]);
  //         } else {
  //           newList.add(IndividualSeal(itemName: label));
  //         }
  //       }
  //       _entry.individualSeals = newList;
  //     }
  //   });
  // }



  void _syncIndividualItemsList() {
    int totalNeeded = _entry.doorCount + _entry.drawerCount;
    setState(() {
      if (_entry.sealsAreCommon) {
        // --- CASE: ALL SEALS ARE SAME ---
        if (_entry.individualSeals.isEmpty) {
          _entry.individualSeals = [IndividualSeal(itemName: "Common Seal")];
        } else {
          // Keep the data from the first seal but rename it to "Common Seal"
          _entry.individualSeals[0].itemName = "Common Seal";
          // Trim the list to just the one common entry
          if (_entry.individualSeals.length > 1) {
            _entry.individualSeals = [_entry.individualSeals.sublist(0, 1).first];
          }
        }
      } else {
        // --- CASE: SEALS ARE DIFFERENT ---
        List<IndividualSeal> newList = [];
        for (int i = 0; i < totalNeeded; i++) {
          String correctLabel = i < _entry.doorCount
              ? "Door ${i + 1}"
              : "Drawer ${i - _entry.doorCount + 1}";

          if (i < _entry.individualSeals.length) {
            // REUSE the existing seal data but FORCE the name to update
            // This prevents "Common Seal" from sticking around as "Door 1"
            var existingItem = _entry.individualSeals[i];
            existingItem.itemName = correctLabel;
            newList.add(existingItem);
          } else {
            newList.add(IndividualSeal(itemName: correctLabel));
          }
        }
        _entry.individualSeals = newList;
      }
    });
  }


  // Future<void> _uploadAndExtractFridgePlate(File imageFile) async {
  //   try {
  //     final supabase = Supabase.instance.client;
  //     showDialog(
  //       context: context,
  //       barrierDismissible: false,
  //       builder: (_) => const Center(child: CircularProgressIndicator()),
  //     );
  //
  //     // 1. Upload to Storage
  //     final fileName = 'fridge_plates/${DateTime.now().millisecondsSinceEpoch}.jpg';
  //     await supabase.storage.from('fridge-plates').upload(fileName, imageFile);
  //     final imageUrl = supabase.storage.from('fridge-plates').getPublicUrl(fileName);
  //
  //     // 2. Call Edge Function for OCR Extraction
  //     final response = await http.post(
  //       Uri.parse('https://brrdkdabcoilwebmbrlx.supabase.co/functions/v1/extract-fridge-plate'),
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'apikey': 'YOUR_SUPABASE_ANON_KEY',
  //         'Authorization': 'Bearer YOUR_SUPABASE_ANON_KEY',
  //       },
  //       body: jsonEncode({
  //         "imageUrl": imageUrl,
  //         "createdBy": supabase.auth.currentUser?.id
  //       }),
  //     );
  //
  //     if (mounted) Navigator.pop(context); // Close loading dialog
  //
  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       final extracted = data["extracted"];
  //
  //       setState(() {
  //         // AUTO-FILL the UI fields immediately
  //         _entry.brand = extracted["manufacturer"] ?? "";
  //         _entry.modelNo = extracted["model_no"] ?? "";
  //         _entry.serialNo = extracted["serial_no"] ?? "";
  //
  //         // Update controllers so the user sees the text in the textfields
  //         _brandController.text = _entry.brand!;
  //         _modelController.text = _entry.modelNo;
  //         _serialController.text = _entry.serialNo;
  //       });
  //
  //       // 3. AUTO-SEARCH LOCAL DATABASE
  //       final matches = await _findMatchingFridges();
  //
  //       if (matches.isNotEmpty) {
  //         // Data found -> Open the selection list
  //         _showFridgeSelection(matches);
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //             content: Text("Found ${matches.length} matches in database"),
  //             backgroundColor: Colors.green,
  //           ),
  //         );
  //       } else {
  //         // Data NOT found -> Clear feedback to user
  //         _syncIndividualItemsList(); // Revert to manual quantity sync
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(
  //             content: Text("No matching fridge configuration found in local list. Please enter details manually."),
  //             backgroundColor: Colors.orange,
  //             duration: Duration(seconds: 4),
  //           ),
  //         );
  //       }
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text("Extraction failed. Please type manually.")),
  //       );
  //     }
  //   } catch (e) {
  //     if (mounted) Navigator.pop(context);
  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
  //   }
  // }


  Future<void> _uploadAndExtractFridgePlate(File imageFile) async {
    try {
      setState(() {
        _isExtracting = true;
        _extractionError = null; // Clear old errors
      });
      _scanController.repeat(reverse: true);

      final supabase = Supabase.instance.client;
      final fileName = 'fridge_plates/${DateTime.now().millisecondsSinceEpoch}.jpg';

      await supabase.storage.from('fridge-plates').upload(fileName, imageFile);
      final imageUrl = supabase.storage.from('fridge-plates').getPublicUrl(fileName);

      final response = await http.post(
        Uri.parse('https://brrdkdabcoilwebmbrlx.supabase.co/functions/v1/extract-fridge-plate'),
        headers: {
          'Content-Type': 'application/json',
          'apikey': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJycmRrZGFiY29pbHdlYm1icmx4Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3NDk1MjM1NiwiZXhwIjoyMDkwNTI4MzU2fQ.R3RTkWxSbUrD_AjnMwC5cT5rgw5jF4MV6XCIn5MxT5w',
          'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJycmRrZGFiY29pbHdlYm1icmx4Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3NDk1MjM1NiwiZXhwIjoyMDkwNTI4MzU2fQ.R3RTkWxSbUrD_AjnMwC5cT5rgw5jF4MV6XCIn5MxT5w',

        },
        body: jsonEncode({"imageUrl": imageUrl, "createdBy": supabase.auth.currentUser?.id}),
      ).timeout(const Duration(seconds: 20)); // Add a timeout

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final extracted = data["extracted"];

        setState(() {
          _entry.brand = extracted["manufacturer"] ?? "";
          _entry.modelNo = extracted["model_no"] ?? "";
          _entry.serialNo = extracted["serial_no"] ?? "";
          _brandController.text = _entry.brand!;
          _modelController.text = _entry.modelNo;
          _serialController.text = _entry.serialNo;
        });

        final matches = await _findMatchingFridges();
        if (matches.isNotEmpty) {
          _showFridgeSelection(matches);
        } else {
          // Clear fields didn't find specific data, but OCR worked
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Text extracted, but no matching seal found in database."))
          );
        }
      } else {
        // Logic for Server side error
        setState(() => _extractionError = "Could not read the plate clearly. Please type the Model No. manually to find compatible seals.");
      }
    } catch (e) {
      // Logic for Connection/Network error
      setState(() => _extractionError = "Connection failed. You can still search by typing the Model No. manually below.");
      debugPrint("Extraction Error: $e");
    } finally {
      if (mounted) {
        setState(() => _isExtracting = false);
        _scanController.stop();
      }
    }
  }

  Future<void> _autoFillFromDatabase(String sealLabel, int index) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? productsJson = prefs.getString('local_products');
      if (productsJson == null) return;

      final List<dynamic> products = jsonDecode(productsJson);
      final product = products.firstWhere(
            (p) => p['title'].toString().toLowerCase() == sealLabel.toLowerCase() || p['sku'].toString().toLowerCase() == sealLabel.toLowerCase(),
        orElse: () => null,
      );

      if (product != null) {
        setState(() {
          var item = _entry.individualSeals[index];
          item.sealId = product['id'].toString();
          item.sealName = product['title'];
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

              const SizedBox(height: 16),
              // Manual/Autofilled Fridge Fields
              // Container(
              //   padding: const EdgeInsets.all(12),
              //   decoration: BoxDecoration(color: Colors.blueGrey[50], borderRadius: BorderRadius.circular(12)),
              //   child: Column(
              //     children: [
              //       TextField(
              //         controller: _brandController,
              //         decoration: const InputDecoration(labelText: "Brand / Manufacturer", isDense: true),
              //         onChanged: (val) => _entry.brand = val,
              //       ),
              //       const SizedBox(height: 8),
              //       TextField(
              //         controller: _modelController,
              //         decoration: InputDecoration(
              //           labelText: "Model Number",
              //           isDense: true,
              //           suffixIcon: IconButton(
              //             icon: const Icon(Icons.search, color: AppTheme.primary),
              //             onPressed: () async {
              //               final matches = await _findMatchingFridges();
              //               if (matches.isNotEmpty) {
              //                 _showFridgeSelection(matches);
              //               } else {
              //                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No local matches found")));
              //               }
              //             },
              //           ),
              //         ),
              //         onEditingComplete: () async {
              //           final matches = await _findMatchingFridges();
              //           if (matches.isNotEmpty) _showFridgeSelection(matches);
              //         },
              //       ),
              //       const SizedBox(height: 8),
              //       TextField(
              //         controller: _serialController,
              //         decoration: const InputDecoration(labelText: "Serial Number", isDense: true),
              //         onChanged: (val) => _entry.serialNo = val,
              //       ),
              //     ],
              //   ),
              // ),


              if (_isExtracting)
                _buildFridgeDataShimmer()
              else if (_extractionError != null)
                _buildErrorState() // This will now show your helpful message
              else
                _buildFridgeFields(),
              // MODIFIED SECTION
              // _isExtracting
              //     ? _buildFridgeDataShimmer() // Show Skeleton while AI is thinking
              //     : Container(
              //   padding: const EdgeInsets.all(12),
              //   decoration: BoxDecoration(color: Colors.blueGrey[50], borderRadius: BorderRadius.circular(12)),
              //   child: Column(
              //     children: [
              //       TextField(
              //         controller: _brandController,
              //         decoration: const InputDecoration(labelText: "Brand / Manufacturer", isDense: true),
              //         onChanged: (val) => _entry.brand = val,
              //       ),
              //       const SizedBox(height: 8),
              //       TextField(
              //         controller: _modelController,
              //         decoration: InputDecoration(
              //           labelText: "Model Number",
              //           isDense: true,
              //           suffixIcon: IconButton(
              //             icon: const Icon(Icons.search, color: AppTheme.primary),
              //             onPressed: () async {
              //               final matches = await _findMatchingFridges();
              //               if (matches.isNotEmpty) {
              //                 _showFridgeSelection(matches);
              //               } else {
              //                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No local matches found")));
              //               }
              //             },
              //           ),
              //         ),
              //         onEditingComplete: () async {
              //           final matches = await _findMatchingFridges();
              //           if (matches.isNotEmpty) _showFridgeSelection(matches);
              //         },
              //       ),
              //       const SizedBox(height: 8),
              //       TextField(
              //         controller: _serialController,
              //         decoration: const InputDecoration(labelText: "Serial Number", isDense: true),
              //         onChanged: (val) => _entry.serialNo = val,
              //       ),
              //     ],
              //   ),
              // ),

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
                  onPressed: () {
                    if (_entry.area.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Location required")));
                      return;
                    }
                    _entry.modelNo = _modelController.text;
                    _entry.serialNo = _serialController.text;
                    _entry.brand = _brandController.text;

                    for (var seal in _entry.individualSeals) {
                      seal.sealType = seal.ctrls['type']!.text;
                      seal.material = seal.ctrls['material']!.text;
                      seal.hardness = seal.ctrls['hardness']!.text;
                      seal.innerDiameter = double.tryParse(seal.ctrls['inner']!.text) ?? 0.0;
                      seal.outerDiameter = double.tryParse(seal.ctrls['outer']!.text) ?? 0.0;
                      seal.thickness = double.tryParse(seal.ctrls['thickness']!.text) ?? 0.0;
                      seal.sealModelNumber = seal.ctrls['modelNum']!.text;
                      seal.tempRange = seal.ctrls['temp']!.text;
                      seal.brand = seal.ctrls['brand']!.text;
                      seal.application = seal.ctrls['app']!.text;
                      seal.description = seal.ctrls['desc']!.text;
                    }

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

  // --- UI HELPER WIDGETS (Unchanged from original except where needed) ---

  // Widget _buildItemVariantCard(int index, IndividualSeal item) {
  //   return Card(
  //     elevation: 0,
  //     margin: const EdgeInsets.only(bottom: 24),
  //     color: item.isIdentified ? Colors.green[50]!.withOpacity(0.3) : Colors.grey[50],
  //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey[200]!)),
  //     child: Padding(
  //       padding: const EdgeInsets.all(16.0),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Row(children: [
  //             Icon(item.isIdentified ? Icons.check_circle : Icons.qr_code_scanner, color: item.isIdentified ? Colors.green : Colors.grey),
  //             const SizedBox(width: 8),
  //             Text(item.itemName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
  //             const Spacer(),
  //             if (item.isIdentified) Text("${(item.confidence * 100).toStringAsFixed(0)}% Match", style: const TextStyle(fontSize: 10, color: Colors.green)),
  //           ]),
  //           // if (item.images.isNotEmpty) ...[
  //           //   const SizedBox(height: 12),
  //           //   SizedBox(
  //           //     height: 80,
  //           //     child: ListView.builder(
  //           //       scrollDirection: Axis.horizontal,
  //           //       shrinkWrap: true,
  //           //       itemCount: item.images.length,
  //           //       itemBuilder: (c, i) => Padding(
  //           //         padding: const EdgeInsets.only(right: 8),
  //           //         child: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(item.images[i], width: 80, height: 80, fit: BoxFit.cover)),
  //           //       ),
  //           //     ),
  //           //   ),
  //           // ],
  //           if (item.images.isNotEmpty) ...[
  //             const SizedBox(height: 12),
  //             SizedBox(
  //               height: 80,
  //               // child: ListView.builder(
  //               //   scrollDirection: Axis.horizontal,
  //               //   shrinkWrap: true,
  //               //   itemCount: item.images.length,
  //               //   itemBuilder: (c, i) => Padding(
  //               //     padding: const EdgeInsets.only(right: 8),
  //               //     // --- UPDATED: Using ImagePreviewer for tap-to-zoom support ---
  //               //     child: ImagePreviewer(
  //               //       file: item.images[i], // Passes the local File
  //               //       width: 80,
  //               //       height: 80,
  //               //       fit: BoxFit.cover,
  //               //       borderRadius: BorderRadius.circular(8),
  //               //     ),
  //               //   ),
  //               // ),
  //               child: ListView.builder(
  //                 scrollDirection: Axis.horizontal,
  //                 shrinkWrap: true,
  //                 physics: const ClampingScrollPhysics(),
  //                 itemCount: item.images.length,
  //                 itemBuilder: (c, i) => Padding(
  //                   padding: const EdgeInsets.only(right: 8),
  //                   child: ImagePreviewer(
  //                     file: item.images[i], // The specific file for this thumbnail
  //                     galleryItems: item.images, // FIX: Pass the full list to enable swiping
  //                     initialIndex: i, // FIX: Start the gallery at the image the user tapped
  //                     width: 80,
  //                     height: 80,
  //                     fit: BoxFit.cover,
  //                     borderRadius: BorderRadius.circular(8),
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ],
  //           const SizedBox(height: 12),
  //           // Row(
  //           //   children: [
  //           //     Expanded(child: Text(item.isIdentified ? "SKU: ${item.sealName}" : "Not scanned", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
  //           //     SizedBox(
  //           //       width: 110,
  //           //       child: ElevatedButton(
  //           //         onPressed: () => _showSealDetection(index),
  //           //         style: ElevatedButton.styleFrom(visualDensity: VisualDensity.compact),
  //           //         child: Text(item.isIdentified ? "RE-SCAN" : "SCAN SEAL"),
  //           //       ),
  //           //     ),
  //           //   ],
  //           // ),
  //
  //           // Inside _buildItemVariantCard, replace the Row containing the SCAN SEAL button
  //           Row(
  //             children: [
  //               Expanded(
  //                   child: Text(
  //                       item.isIdentified ? "Model: ${item.sealModelNumber}" : "Not identified",
  //                       style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)
  //                   )
  //               ),
  //               const SizedBox(width: 8),
  //               // Button for ML Scanning (Left button in image 1000166586.jpg logic)
  //               IconButton(
  //                 onPressed: () => _showSealDetection(index),
  //                 icon: const Icon(Icons.qr_code_scanner, color: AppTheme.primary),
  //                 tooltip: "Scan with AI",
  //               ),
  //               // Button for Manual Selection (Dropdown/Populate logic)
  //               ElevatedButton(
  //                 onPressed: () => _showProductSearch(index),
  //                 style: ElevatedButton.styleFrom(
  //                   visualDensity: VisualDensity.compact,
  //                   backgroundColor: Colors.blueGrey[700],
  //                 ),
  //                 child: const Text("SELECT MODEL"),
  //               ),
  //             ],
  //           ),
  //           const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider()),
  //           _variantInputWidget("Seal Type", item.ctrls['type']!, (v) => item.sealType = v),
  //           _variantInputWidget("Material", item.ctrls['material']!, (v) => item.material = v),
  //           _variantInputWidget("Hardness", item.ctrls['hardness']!, (v) => item.hardness = v),
  //           Row(children: [
  //             Expanded(child: _variantInputWidget("Inner Dia (mm)", item.ctrls['inner']!, (v) => item.innerDiameter = double.tryParse(v.toString()) ?? 0, isNum: true)),
  //             const SizedBox(width: 10),
  //             Expanded(child: _variantInputWidget("Outer Dia (mm)", item.ctrls['outer']!, (v) => item.outerDiameter = double.tryParse(v.toString()) ?? 0, isNum: true)),
  //           ]),
  //           Row(children: [
  //             Expanded(child: _variantInputWidget("Thickness (mm)", item.ctrls['thickness']!, (v) => item.thickness = double.tryParse(v.toString()) ?? 0, isNum: true)),
  //             const SizedBox(width: 10),
  //             Expanded(child: _variantInputWidget("Model #", item.ctrls['modelNum']!, (v) => item.sealModelNumber = v)),
  //           ]),
  //           _variantInputWidget("Temperature Range", item.ctrls['temp']!, (v) => item.tempRange = v),
  //           _variantInputWidget("Brand", item.ctrls['brand']!, (v) => item.brand = v),
  //           _variantInputWidget("Application", item.ctrls['app']!, (v) => item.application = v),
  //           const SizedBox(height: 8),
  //           TextField(
  //             controller: item.ctrls['desc'],
  //             maxLines: 2,
  //             decoration: const InputDecoration(labelText: "Notes for this seal", border: OutlineInputBorder(), isDense: true),
  //             onChanged: (val) => item.description = val,
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }



  Widget _buildItemVariantCard(int index, IndividualSeal item) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 24),
      color: item.isIdentified ? Colors.green[50]!.withOpacity(0.3) : Colors.grey[50],
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey[200]!)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Status Icon and Item Name
            Row(children: [
              Icon(
                  item.isIdentified ? Icons.check_circle : Icons.qr_code_scanner,
                  color: item.isIdentified ? Colors.green : Colors.grey),
              const SizedBox(width: 8),
              Text(item.itemName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const Spacer(),
              if (item.isIdentified)
                Text("${(item.confidence * 100).toStringAsFixed(0)}% Match",
                    style: const TextStyle(fontSize: 10, color: Colors.green)),
            ]),

            // Image Gallery Section
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
                    child: ImagePreviewer(
                      file: item.images[i],
                      galleryItems: item.images, // Support swiping through all images
                      initialIndex: i,           // Open tapped image first
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),

            // FIXED ACTION ROW: Prevents infinite width crash
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item.isIdentified
                        ? "Model: ${item.sealModelNumber}"
                        : "Model Not Selected",
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => _showSealDetection(index),
                      icon: const Icon(Icons.qr_code_scanner, color: AppTheme.primary),
                      visualDensity: VisualDensity.compact,
                      tooltip: "Scan with AI",
                    ),
                    const SizedBox(width: 4),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 120),
                      child: ElevatedButton(
                        onPressed: () => _showProductSearch(index),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          visualDensity: VisualDensity.compact,
                          backgroundColor: Colors.blueGrey[800],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text(
                          "SELECT Seal",
                          style: TextStyle(fontSize: 10),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider()),

            // RESTORED INPUT FIELDS FROM OLD CARD
            _variantInputWidget("Seal Type", item.ctrls['type']!, (v) => item.sealType = v),
            _variantInputWidget("Material", item.ctrls['material']!, (v) => item.material = v),
            _variantInputWidget("Hardness", item.ctrls['hardness']!, (v) => item.hardness = v),

            // Dimensions Row 1
            Row(children: [
              Expanded(
                  child: _variantInputWidget(
                      "Inner Dia (mm)",
                      item.ctrls['inner']!,
                          (v) => item.innerDiameter = double.tryParse(v.toString()) ?? 0,
                      isNum: true)),
              const SizedBox(width: 10),
              Expanded(
                  child: _variantInputWidget(
                      "Outer Dia (mm)",
                      item.ctrls['outer']!,
                          (v) => item.outerDiameter = double.tryParse(v.toString()) ?? 0,
                      isNum: true)),
            ]),

            // Dimensions Row 2
            Row(children: [
              Expanded(
                  child: _variantInputWidget(
                      "Thickness (mm)",
                      item.ctrls['thickness']!,
                          (v) => item.thickness = double.tryParse(v.toString()) ?? 0,
                      isNum: true)),
              const SizedBox(width: 10),
              Expanded(
                  child: _variantInputWidget(
                      "Model #",
                      item.ctrls['modelNum']!,
                          (v) => item.sealModelNumber = v)),
            ]),

            _variantInputWidget("Temperature Range", item.ctrls['temp']!, (v) => item.tempRange = v),
            _variantInputWidget("Brand", item.ctrls['brand']!, (v) => item.brand = v),
            _variantInputWidget("Application", item.ctrls['app']!, (v) => item.application = v),

            const SizedBox(height: 8),

            // RESTORED Notes Field
            TextField(
              controller: item.ctrls['desc'],
              maxLines: 2,
              style: const TextStyle(fontSize: 13),
              decoration: const InputDecoration(
                  labelText: "Notes for this seal",
                  border: OutlineInputBorder(),
                  isDense: true),
              onChanged: (val) => item.description = val,
            ),
          ],
        ),
      ),
    );
  }

  Widget _variantInputWidget(String label, TextEditingController ctrl, Function(dynamic) onC, {bool isNum = false}) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      controller: ctrl,
      keyboardType: isNum ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder(), isDense: true),
      onChanged: (val) => onC(isNum ? (double.tryParse(val) ?? 0) : val),
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

  // Widget _buildDataPlatePicker() => InkWell(
  //   onTap: () async {
  //     final ImageSource? source = await showModalBottomSheet<ImageSource>(
  //       context: context,
  //       builder: (context) => SafeArea(
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             ListTile(leading: const Icon(Icons.camera_alt), title: const Text('Camera'), onTap: () => Navigator.pop(context, ImageSource.camera)),
  //             ListTile(leading: const Icon(Icons.photo_library), title: const Text('Gallery'), onTap: () => Navigator.pop(context, ImageSource.gallery)),
  //           ],
  //         ),
  //       ),
  //     );
  //     if (source == null) return;
  //     final XFile? photo = await _picker.pickImage(source: source);
  //     if (photo != null) {
  //       final file = File(photo.path);
  //       setState(() => _entry.dataPlateImage = file);
  //       await _uploadAndExtractFridgePlate(file);
  //     }
  //   },
  //   child: Container(
  //     height: 120, width: double.infinity,
  //     decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[300]!)),
  //     child: _entry.dataPlateImage == null
  //         ? const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_a_photo_outlined, color: Colors.grey), Text("Tap to capture Data Plate", style: TextStyle(color: Colors.grey, fontSize: 12))])
  //         : ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(_entry.dataPlateImage!, fit: BoxFit.cover)),
  //   ),
  // );



  // Widget _buildDataPlatePicker() {
  //   const double containerHeight = 220.0; // Increased height for better visibility
  //
  //   return InkWell(
  //     onTap: _isExtracting ? null : () async { // Disable while scanning
  //       final ImageSource? source = await showModalBottomSheet<ImageSource>(
  //         context: context,
  //         builder: (context) => SafeArea(
  //           child: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               ListTile(
  //                   leading: const Icon(Icons.camera_alt),
  //                   title: const Text('Camera'),
  //                   onTap: () => Navigator.pop(context, ImageSource.camera)),
  //               ListTile(
  //                   leading: const Icon(Icons.photo_library),
  //                   title: const Text('Gallery'),
  //                   onTap: () => Navigator.pop(context, ImageSource.gallery)),
  //             ],
  //           ),
  //         ),
  //       );
  //
  //       if (source == null) return;
  //
  //       final XFile? photo = await _picker.pickImage(source: source);
  //       if (photo != null) {
  //         final file = File(photo.path);
  //         setState(() {
  //           _entry.dataPlateImage = file;
  //           // Note: _isExtracting should be set to true inside _uploadAndExtractFridgePlate
  //         });
  //         await _uploadAndExtractFridgePlate(file);
  //       }
  //     },
  //     child: Container(
  //       height: containerHeight,
  //       width: double.infinity,
  //       decoration: BoxDecoration(
  //         color: Colors.grey[100],
  //         borderRadius: BorderRadius.circular(12),
  //         border: Border.all(color: Colors.grey[300]!),
  //       ),
  //       child: Stack( // Main stack for the container
  //         alignment: Alignment.center,
  //         children: [
  //           // 1. PLACEHOLDER OR IMAGE LAYER
  //           if (_entry.dataPlateImage == null)
  //             const Column(
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               children: [
  //                 Icon(Icons.add_a_photo_outlined, color: Colors.grey, size: 40),
  //                 SizedBox(height: 8),
  //                 Text("Tap to capture Data Plate",
  //                     style: TextStyle(color: Colors.grey, fontSize: 14)),
  //               ],
  //             )
  //           else
  //           // 2. IMAGE + SCANNING ANIMATION BUNDLE
  //             ClipRRect( // Clips everything inside to the image's bounds
  //               borderRadius: BorderRadius.circular(12),
  //               child: Stack( // Nested stack just for the image and its overlays
  //                 children: [
  //                   Image.file(
  //                     _entry.dataPlateImage!,
  //                     fit: BoxFit.contain, // FIX: Full image now visible
  //                   ),
  //                   // THE SCANNING ANIMATION LAYER - now inside the image stack
  //                   if (_isExtracting)
  //                     Positioned.fill(
  //                       child: LayoutBuilder(
  //                         builder: (context, constraints) {
  //                           // Define the height of the scan line based on the visible image's height
  //                           const double lineHeight = 3.0;
  //                           return AnimatedBuilder(
  //                             animation: _scanController,
  //                             builder: (context, child) {
  //                               return Stack(
  //                                 children: [
  //                                   // Faint overlay to make scanning obvious
  //                                   Container(
  //                                     decoration: BoxDecoration(
  //                                       color: AppTheme.primary.withOpacity(0.1),
  //                                       borderRadius: BorderRadius.circular(12),
  //                                     ),
  //                                   ),
  //                                   // The Moving "Laser" Line
  //                                   Positioned(
  //                                     // Constraints.maxHeight ensures the line stays within the image
  //                                     top: (_scanController.value * constraints.maxHeight) - (lineHeight / 2),
  //                                     left: 0,
  //                                     right: 0,
  //                                     child: Container(
  //                                       height: lineHeight,
  //                                       decoration: BoxDecoration(
  //                                         color: AppTheme.primary,
  //                                         boxShadow: [
  //                                           BoxShadow(
  //                                             color: AppTheme.primary.withOpacity(0.6),
  //                                             blurRadius: 12,
  //                                             spreadRadius: 2,
  //                                           ),
  //                                         ],
  //                                       ),
  //                                     ),
  //                                   ),
  //                                 ],
  //                               );
  //                             },
  //                           );
  //                         },
  //                       ),
  //                     ),
  //                 ],
  //               ),
  //             ),
  //         ],
  //       ),
  //     ),
  //   );
  // }


  // Widget _buildDataPlatePicker() {
  //   const double containerHeight = 220.0;
  //
  //   return Container(
  //     height: containerHeight,
  //     width: double.infinity,
  //     decoration: BoxDecoration(
  //       color: Colors.grey[100],
  //       borderRadius: BorderRadius.circular(12),
  //       border: Border.all(color: Colors.grey[300]!),
  //     ),
  //     child: Stack(
  //       alignment: Alignment.center,
  //       children: [
  //         // 1. PLACEHOLDER (Only shows if no image exists)
  //         if (_entry.dataPlateImage == null)
  //           InkWell(
  //             onTap: () => _pickDataPlateImage(),
  //             child: const Column(
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               children: [
  //                 Icon(Icons.add_a_photo_outlined, color: Colors.grey, size: 40),
  //                 SizedBox(height: 8),
  //                 Text("Tap to capture Data Plate",
  //                     style: TextStyle(color: Colors.grey, fontSize: 14)),
  //               ],
  //             ),
  //           )
  //         else
  //         // 2. IMAGE + SCANNING ANIMATION BUNDLE
  //           ClipRRect(
  //             borderRadius: BorderRadius.circular(12),
  //             child: Stack(
  //               children: [
  //                 // --- INTEGRATED COMPONENT: ImagePreviewer ---
  //                 ImagePreviewer(
  //                   file: _entry.dataPlateImage,
  //                   width: double.infinity,
  //                   height: double.infinity,
  //                   fit: BoxFit.contain,
  //                   borderRadius: BorderRadius.circular(12),
  //                 ),
  //
  //                 // THE SCANNING ANIMATION LAYER
  //                 if (_isExtracting)
  //                   Positioned.fill(
  //                     child: LayoutBuilder(
  //                       builder: (context, constraints) {
  //                         const double lineHeight = 3.0;
  //                         return AnimatedBuilder(
  //                           animation: _scanController,
  //                           builder: (context, child) {
  //                             return Stack(
  //                               children: [
  //                                 Container(
  //                                   decoration: BoxDecoration(
  //                                     color: AppTheme.primary.withOpacity(0.1),
  //                                     borderRadius: BorderRadius.circular(12),
  //                                   ),
  //                                 ),
  //                                 Positioned(
  //                                   top: (_scanController.value * constraints.maxHeight) - (lineHeight / 2),
  //                                   left: 0,
  //                                   right: 0,
  //                                   child: Container(
  //                                     height: lineHeight,
  //                                     decoration: BoxDecoration(
  //                                       color: AppTheme.primary,
  //                                       boxShadow: [
  //                                         BoxShadow(
  //                                           color: AppTheme.primary.withOpacity(0.6),
  //                                           blurRadius: 12,
  //                                           spreadRadius: 2,
  //                                         ),
  //                                       ],
  //                                     ),
  //                                   ),
  //                                 ),
  //                               ],
  //                             );
  //                           },
  //                         );
  //                       },
  //                     ),
  //                   ),
  //
  //                 // --- RE-SCAN BUTTON ---
  //                 if (!_isExtracting)
  //                   Positioned(
  //                     top: 8,
  //                     right: 8,
  //                     child: GestureDetector(
  //                       onTap: () => _pickDataPlateImage(),
  //                       child: Container(
  //                         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  //                         decoration: BoxDecoration(
  //                           color: Colors.black.withOpacity(0.7),
  //                           borderRadius: BorderRadius.circular(20),
  //                         ),
  //                         child: const Row(
  //                           mainAxisSize: MainAxisSize.min,
  //                           children: [
  //                             Icon(Icons.refresh, color: Colors.white, size: 14),
  //                             SizedBox(width: 4),
  //                             Text("RE-SCAN",
  //                                 style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
  //                           ],
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //               ],
  //             ),
  //           ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildDataPlatePicker() {
    const double containerHeight = 220.0;

    return Container(
      height: containerHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: _entry.dataPlateImage == null
            ? InkWell(
          onTap: () => _pickDataPlateImage(),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_a_photo_outlined, color: Colors.grey, size: 40),
              SizedBox(height: 8),
              Text("Tap to capture Data Plate", style: TextStyle(color: Colors.grey, fontSize: 14)),
            ],
          ),
        )
            : Stack(
          alignment: Alignment.center, // CRITICAL: Centers scanning layer on the image
          children: [
            // 1. THE IMAGE (Calculates its own size based on BoxFit.contain)
            ImagePreviewer(
              file: _entry.dataPlateImage,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.contain,
            ),

            // 2. THE SCANNING ANIMATION LAYER (Restricted to Image)
            if (_isExtracting)
            // FittedBox ensures the child (scanning overlay) matches
            // the exact dimensions of the ImagePreviewer's image content.
              Positioned.fill(
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: FutureBuilder<Size>(
                    future: _getImageSize(_entry.dataPlateImage!),
                    builder: (context, snapshot) {
                      final size = snapshot.data ?? const Size(100, 100);
                      return SizedBox(
                        width: size.width,
                        height: size.height,
                        child: _buildScanningOverlay(),
                      );
                    },
                  ),
                ),
              ),

            // 3. RE-SCAN BUTTON
            if (!_isExtracting)
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () => _pickDataPlateImage(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.refresh, color: Colors.white, size: 12),
                        SizedBox(width: 4),
                        Text("RE-SCAN", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

// Helper to get the natural aspect ratio of the file to help FittedBox
  Future<Size> _getImageSize(File file) async {
    final data = await file.readAsBytes();
    final image = await decodeImageFromList(data);
    return Size(image.width.toDouble(), image.height.toDouble());
  }


  // 1. IMPROVED SHIMMER
  Widget _buildFridgeDataShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.white,
      child: Column(
        children: List.generate(3, (index) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(width: 80, height: 10, color: Colors.white), // Label ghost
              const SizedBox(height: 6),
              Container(width: double.infinity, height: 45, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))), // Input ghost
            ],
          ),
        )),
      ),
    );
  }

// 2. ERROR STATE UI
  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.red[200]!)),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(
            child: Text(_extractionError!, style: const TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.w500)),
          ),
          TextButton(
              onPressed: () => setState(() => _extractionError = null),
              child: const Text("TYPE MANUALLY")
          )
        ],
      ),
    );
  }

// 3. ENCAPSULATED FIELDS (To keep build method clean)
  Widget _buildFridgeFields() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.blueGrey[50], borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          TextField(
            controller: _brandController,
            decoration: const InputDecoration(labelText: "Brand", isDense: true),
            onChanged: (val) => _entry.brand = val,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _modelController,
            decoration: InputDecoration(
              labelText: "Model Number",
              isDense: true,
              // 1. ADD SEARCH ICON BUTTON
              suffixIcon: IconButton(
                icon: const Icon(Icons.search, color: AppTheme.primary),
                onPressed: () => _handleManualSearch(),
              ),
            ),
            // 2. TRIGGER SEARCH ON KEYBOARD "DONE/SEARCH" ACTION
            textInputAction: TextInputAction.search,
            onSubmitted: (val) => _handleManualSearch(),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _serialController,
            decoration: const InputDecoration(labelText: "Serial Number", isDense: true),
            onChanged: (val) => _entry.serialNo = val,
          ),
        ],
      ),
    );
  }

// 3. HELPER METHOD TO TRIGGER THE SEARCH LOGIC
  Future<void> _handleManualSearch() async {
    // Sync the current entry state
    _entry.brand = _brandController.text;
    _entry.modelNo = _modelController.text;

    // Show a small feedback snackbar if searching
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Searching local database..."), duration: Duration(milliseconds: 500)),
    );

    final matches = await _findMatchingFridges();

    if (matches.isNotEmpty) {
      _showFridgeSelection(matches);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No configuration found for this model. Please configure manually."),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }
}















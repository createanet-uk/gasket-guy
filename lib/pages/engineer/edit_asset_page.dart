import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../components/image_previewer.dart';
import '../../components/seal_detection_component.dart';
import '../../theme.dart';
import 'new_report_page.dart';

class EditAssetPage extends StatefulWidget {
  final LocalAssetEntry asset;
  final Function(LocalAssetEntry) onUpdate;

  const EditAssetPage({super.key, required this.asset, required this.onUpdate});

  @override
  State<EditAssetPage> createState() => _EditAssetPageState();
}

class _EditAssetPageState extends State<EditAssetPage> with SingleTickerProviderStateMixin {
  late LocalAssetEntry _editableEntry;
  late AnimationController _scanController;
  bool _isExtracting = false;
  String? _extractionError;

  late TextEditingController _brandController;
  late TextEditingController _modelController;
  late TextEditingController _serialController;
  List<Map<String, dynamic>> _allProducts = [];

  @override
  void initState() {
    super.initState();
    // Clone the reference so we don't manipulate the master list dynamically without clicking save
    _editableEntry = widget.asset;

    _brandController = TextEditingController(text: _editableEntry.brand ?? _editableEntry.manufacturer);
    _modelController = TextEditingController(text: _editableEntry.modelNo);
    _serialController = TextEditingController(text: _editableEntry.serialNo);

    // Ensure all controller text frames inside items match incoming states
    for (var seal in _editableEntry.individualSeals) {
      seal.updateControllers();
    }

    _loadLocalProducts();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _scanController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _serialController.dispose();
    super.dispose();
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
              child: Scaffold(
                backgroundColor: Colors.transparent,
                body: Column(
                  children: [
                    Center(
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        width: 40, height: 4,
                        decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const Text("Change Seal Model Selection", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
                          ? const Center(child: Text("No products found"))
                          : ListView.builder(
                        controller: controller,
                        itemCount: filtered.length,
                        itemBuilder: (context, i) {
                          final p = filtered[i];
                          return ListTile(
                            leading: const Icon(Icons.qr_code, color: AppTheme.primary),
                            title: Text(p['seal_model_number'] ?? 'No Model #', style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(p['title'] ?? ''),
                            trailing: const Icon(Icons.check_circle_outline, color: AppTheme.primary),
                            onTap: () {
                              Navigator.pop(context);
                              _overrideSealSelection(p, index);
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

  void _overrideSealSelection(Map<String, dynamic> p, int index) {
    setState(() {
      var item = _editableEntry.individualSeals[index];
      item.images = []; // Flush scanning gallery on hard override fix
      item.confidence = 0.0;
      item.isIdentified = true;
      item.sealId = p['id'].toString();
      item.sealName = p['title'] ?? '';
      item.sealType = p['seal_type'] ?? '';
      item.material = p['material'] ?? '';
      item.hardness = p['hardness'] ?? '';
      item.innerDiameter = (p['inner_diameter'] ?? 0).toDouble();
      item.outerDiameter = (p['outer_diameter'] ?? 0).toDouble();
      item.thickness = (p['thickness'] ?? 0).toDouble();
      item.sealModelNumber = p['seal_model_number'] ?? '';
      item.brand = p['brand'] ?? '';
      item.tempRange = p['temperature_range'] ?? '';
      item.application = p['application'] ?? '';

      item.updateControllers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Edit: ${_editableEntry.area.isEmpty ? 'Appliance' : _editableEntry.area}"),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("RE-ENTER SUB-LOCATION / AREA"),
            TextField(
              controller: TextEditingController(text: _editableEntry.area),
              decoration: const InputDecoration(border: OutlineInputBorder()),
              onChanged: (val) => _editableEntry.area = val,
            ),

            _buildSectionTitle("VERIFY COMPONENT VARIANTS"),
            Column(
              children: List.generate(_editableEntry.individualSeals.length, (index) {
                return _buildItemVariantCard(index, _editableEntry.individualSeals[index]);
              }),
            ),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Push Controllers back to memory models safely before passing backwards
                  for (var seal in _editableEntry.individualSeals) {
                    seal.doorHeight = double.tryParse(seal.ctrls['height']!.text) ?? 0.0;
                    seal.doorWidth = double.tryParse(seal.ctrls['width']!.text) ?? 0.0;
                  }
                  widget.onUpdate(_editableEntry);
                  Navigator.pop(context);
                },
                child: const Text("SAVE CHANGES", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemVariantCard(int index, IndividualSeal item) {
    final bool isReady = item.isIdentified && (item.sealModelNumber?.isNotEmpty ?? false);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color statusColor = isReady ? AppTheme.primary : AppTheme.secondary;
    final Color cardBackground = isDark ? AppTheme.cardBg : AppTheme.secondaryBackground;
    final Color innerContainerBg = isDark ? AppTheme.innerContainerBg : AppTheme.primaryBackground;

    String wearStatus;
    Color wearColor;
    if (item.wearPercentage < 30) {
      wearStatus = "Excellent Condition";
      wearColor = AppTheme.success;
    } else if (item.wearPercentage < 70) {
      wearStatus = "Fair Condition";
      wearColor = AppTheme.tertiary;
    } else if (item.wearPercentage < 90) {
      wearStatus = "Heavy Wear";
      wearColor = Colors.orange;
    } else {
      wearStatus = "REPLACE URGENTLY";
      wearColor = AppTheme.error;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: item.needsUrgentReplacement ? AppTheme.error : AppTheme.alternate,
          width: item.needsUrgentReplacement ? 2.0 : 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  item.needsUrgentReplacement ? Icons.report_problem_rounded : (isReady ? Icons.verified_user_rounded : Icons.radio_button_unchecked_rounded),
                  color: item.needsUrgentReplacement ? AppTheme.error : statusColor,
                ),
                const SizedBox(width: 10),
                Text(item.itemName.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                const Spacer(),
                if (item.isIdentified)
                  Text(item.sealModelNumber ?? '', style: TextStyle(fontSize: 12, color: AppTheme.secondary, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildSmallTextField(label: "DOOR HEIGHT (mm)", controller: item.ctrls['height']!, isDark: isDark, onChanged: (val) => item.doorHeight = double.tryParse(val) ?? 0)),
                const SizedBox(width: 12),
                Expanded(child: _buildSmallTextField(label: "DOOR WIDTH (mm)", controller: item.ctrls['width']!, isDark: isDark, onChanged: (val) => item.doorWidth = double.tryParse(val) ?? 0)),
              ],
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _showProductSearch(index),
                  icon: const Icon(Icons.edit_note_rounded, size: 16, color: Colors.white),
                  label: const Text("FIX / CHANGE SEAL", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.tertiary, minimumSize: const Size(0, 42)),
                ),
              ],
            ),
            if (isReady) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: innerContainerBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.alternate)),
                child: _buildTechSpecGrid(item, isDark),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("WEAR ASSESSMENT", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                Text("${item.wearPercentage.toInt()}%", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: wearColor)),
              ],
            ),
            Slider(
              value: item.wearPercentage,
              min: 0, max: 100,
              activeColor: wearColor,
              inactiveColor: AppTheme.alternate,
              onChanged: (val) {
                setState(() {
                  item.wearPercentage = val;
                  item.needsUrgentReplacement = (val >= 90);
                });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(wearStatus, style: TextStyle(color: wearColor, fontSize: 11, fontWeight: FontWeight.bold)),
                GestureDetector(
                  onTap: () => setState(() => item.needsUrgentReplacement = !item.needsUrgentReplacement),
                  child: Row(
                    children: [
                      Text("URGENT REPLACEMENT", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: item.needsUrgentReplacement ? AppTheme.error : AppTheme.secondaryText)),
                      const SizedBox(width: 4),
                      Checkbox(
                        value: item.needsUrgentReplacement,
                        activeColor: AppTheme.error,
                        onChanged: (val) => setState(() => item.needsUrgentReplacement = val ?? false),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallTextField({required String label, required TextEditingController controller, required bool isDark, required Function(String) onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          onChanged: onChanged,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
        ),
      ],
    );
  }

  Widget _buildTechSpecGrid(IndividualSeal item, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _buildInfoRow("Seal Name", item.sealName, isDark)),
            Expanded(child: _buildInfoRow("Seal Type", item.sealType, isDark)),
            Expanded(child: _buildInfoRow("Material", item.material, isDark)),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(child: _buildInfoRow("Hardness", item.hardness, isDark)),
            Expanded(child: _buildInfoRow("Inner Dia", item.innerDiameter > 0 ? "${item.innerDiameter} mm" : null, isDark)),
            Expanded(child: _buildInfoRow("Outer Dia", item.outerDiameter > 0 ? "${item.outerDiameter} mm" : null, isDark)),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String? value, bool isDark) {
    final String displayValue = (value == null || value.trim().isEmpty) ? "—" : value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: const TextStyle(fontSize: 8, color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(displayValue, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
      ],
    );
  }

  Widget _buildSectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(top: 10, bottom: 8),
    child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary, fontSize: 13)),
  );
}
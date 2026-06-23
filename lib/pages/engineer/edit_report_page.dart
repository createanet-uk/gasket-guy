import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../theme.dart';

// ---------------------------------------------------------------------------
// Private state holders — one per assets_report_fridge row
// ---------------------------------------------------------------------------

class _FridgeEditState {
  final String arfId; // assets_report_fridge.id
  final String? fridgeId; // fridges.id (may be null for legacy rows)
  final TextEditingController areaCtrl;
  final TextEditingController ggNumberCtrl;
  final TextEditingController manufacturerCtrl;
  final TextEditingController modelCtrl;
  final TextEditingController serialCtrl;
  final TextEditingController engineerNotesCtrl;
  final List<_SealEditState> seals;

  _FridgeEditState({
    required this.arfId,
    this.fridgeId,
    required String area,
    required String ggNumber,
    required String manufacturer,
    required String model,
    required String serial,
    required String engineerNotes,
    required this.seals,
  })  : areaCtrl = TextEditingController(text: area),
        ggNumberCtrl = TextEditingController(text: ggNumber),
        manufacturerCtrl = TextEditingController(text: manufacturer),
        modelCtrl = TextEditingController(text: model),
        serialCtrl = TextEditingController(text: serial),
        engineerNotesCtrl = TextEditingController(text: engineerNotes);

  void dispose() {
    areaCtrl.dispose();
    ggNumberCtrl.dispose();
    manufacturerCtrl.dispose();
    modelCtrl.dispose();
    serialCtrl.dispose();
    engineerNotesCtrl.dispose();
    for (final s in seals) {
      s.dispose();
    }
  }
}

// ---------------------------------------------------------------------------
// Private state holder — one per asset_report_fridge_items row
// ---------------------------------------------------------------------------

class _SealEditState {
  final String itemId; // asset_report_fridge_items.id
  final String itemName;
  String? sealId;
  String manualSealName;
  String sealType;
  String sealModelNumber;
  bool isMagnetic;
  bool isIdentified;
  bool isDartToDart;
  double wearPercentage;
  bool needsUrgentReplacement;
  final TextEditingController heightCtrl;
  final TextEditingController widthCtrl;
  final TextEditingController notesCtrl;

  _SealEditState({
    required this.itemId,
    required this.itemName,
    this.sealId,
    required this.manualSealName,
    required this.sealType,
    required this.sealModelNumber,
    required this.isMagnetic,
    required this.isIdentified,
    required this.isDartToDart,
    required this.wearPercentage,
    required this.needsUrgentReplacement,
    required double height,
    required double width,
    required String notes,
  })  : heightCtrl = TextEditingController(text: height > 0 ? height.toStringAsFixed(1) : ''),
        widthCtrl = TextEditingController(text: width > 0 ? width.toStringAsFixed(1) : ''),
        notesCtrl = TextEditingController(text: notes);

  void dispose() {
    heightCtrl.dispose();
    widthCtrl.dispose();
    notesCtrl.dispose();
  }
}

// ---------------------------------------------------------------------------
// EditReportPage
// ---------------------------------------------------------------------------

class EditReportPage extends StatefulWidget {
  final String reportId;
  const EditReportPage({super.key, required this.reportId});

  @override
  State<EditReportPage> createState() => _EditReportPageState();
}

class _EditReportPageState extends State<EditReportPage> {
  final SupabaseClient _supabase = Supabase.instance.client;

  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  late TextEditingController _titleCtrl;
  late TextEditingController _reportNotesCtrl;
  final List<_FridgeEditState> _fridgeStates = [];
  List<Map<String, dynamic>> _allProducts = [];

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController();
    _reportNotesCtrl = TextEditingController();
    _loadProducts();
    _fetchReport();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _reportNotesCtrl.dispose();
    for (final f in _fridgeStates) {
      f.dispose();
    }
    super.dispose();
  }

  // -------------------------------------------------------------------------
  // Data loading
  // -------------------------------------------------------------------------

  Future<void> _loadProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('local_products');
      if (raw != null) {
        setState(() {
          _allProducts = List<Map<String, dynamic>>.from(jsonDecode(raw));
        });
      }
    } catch (_) {}
  }

  Future<void> _fetchReport() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.contains(ConnectivityResult.none)) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'No internet connection. Editing requires an online connection.';
      });
      return;
    }

    try {
      final data = await _supabase.from('asset_reports').select('''
        id, report_title, notes, status,
        customer:user_profiles!customer_id(full_name),
        fridges:assets_report_fridge(
          *,
          seals:asset_report_fridge_items(*),
          fridge:fridges(
            id,
            components:fridge_components(component_index, height_mm, width_mm)
          )
        )
      ''').eq('id', widget.reportId).single();

      _titleCtrl.text = data['report_title'] ?? '';
      _reportNotesCtrl.text = data['notes'] ?? '';

      _fridgeStates.clear();
      for (final fridge in (data['fridges'] as List? ?? [])) {
        // Build a component_index → dimensions map from fridge_components
        final Map<int, Map<String, dynamic>> compByIndex = {};
        final fridgeMaster = fridge['fridge'];
        if (fridgeMaster is Map) {
          for (final c in (fridgeMaster['components'] as List? ?? [])) {
            if (c is Map) {
              final idx = (c['component_index'] ?? 0) as int;
              compByIndex[idx] = Map<String, dynamic>.from(c);
            }
          }
        }

        final seals = <_SealEditState>[];
        final sealList = fridge['seals'] as List? ?? [];
        for (int i = 0; i < sealList.length; i++) {
          final seal = sealList[i];
          final comp = compByIndex[i + 1];
          final double height = ((comp?['height_mm'] ?? 0) as num).toDouble();
          final double width = ((comp?['width_mm'] ?? 0) as num).toDouble();

          seals.add(_SealEditState(
            itemId: seal['id'].toString(),
            itemName: seal['item_name'] ?? '',
            sealId: seal['seal_id']?.toString(),
            manualSealName: seal['manual_seal_name'] ?? '',
            sealType: seal['seal_type'] ?? '',
            sealModelNumber: '',
            isMagnetic: false,
            isIdentified: seal['seal_id'] != null,
            isDartToDart: false,
            wearPercentage: ((seal['wear_percentage'] ?? 0) as num).toDouble(),
            needsUrgentReplacement: seal['need_replacement'] == true,
            height: height,
            width: width,
            notes: seal['item_notes'] ?? '',
          ));
        }

        _fridgeStates.add(_FridgeEditState(
          arfId: fridge['id'].toString(),
          fridgeId: fridge['fridge_id']?.toString(),
          area: fridge['area'] ?? '',
          ggNumber: fridge['gg_number'] ?? '',
          manufacturer: fridge['manufacturer'] ?? '',
          model: fridge['model_no'] ?? '',
          serial: fridge['serial_no'] ?? '',
          engineerNotes: fridge['engineer_notes'] ?? '',
          seals: seals,
        ));
      }

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load report: $e';
      });
    }
  }

  // -------------------------------------------------------------------------
  // Save
  // -------------------------------------------------------------------------

  Future<void> _saveChanges() async {
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.contains(ConnectivityResult.none)) {
      _showSnack('No internet connection. Cannot save changes offline.', isError: true);
      return;
    }

    setState(() => _isSaving = true);

    try {
      // 1. Update asset_reports
      await _supabase.from('asset_reports').update({
        'report_title': _titleCtrl.text.trim(),
        'notes': _reportNotesCtrl.text.trim(),
      }).eq('id', widget.reportId);

      // 2. Update each fridge
      for (final fridge in _fridgeStates) {
        // Update assets_report_fridge (the report-specific copy of the data)
        await _supabase.from('assets_report_fridge').update({
          'area': fridge.areaCtrl.text.trim(),
          'gg_number': fridge.ggNumberCtrl.text.trim().toUpperCase(),
          'manufacturer': fridge.manufacturerCtrl.text.trim(),
          'model_no': fridge.modelCtrl.text.trim(),
          'serial_no': fridge.serialCtrl.text.trim(),
          'engineer_notes': fridge.engineerNotesCtrl.text.trim(),
        }).eq('id', fridge.arfId);

        // Also keep the master fridges record in sync if we have its ID
        if (fridge.fridgeId != null) {
          await _supabase.from('fridges').update({
            'manufacturer': fridge.manufacturerCtrl.text.trim(),
            'model_no': fridge.modelCtrl.text.trim(),
            'serial_no': fridge.serialCtrl.text.trim(),
          }).eq('id', fridge.fridgeId!);
        }

        // 3. Update each seal item
        for (int i = 0; i < fridge.seals.length; i++) {
          final seal = fridge.seals[i];
          final double height = double.tryParse(seal.heightCtrl.text) ?? 0.0;
          final double width = double.tryParse(seal.widthCtrl.text) ?? 0.0;

          await _supabase.from('asset_report_fridge_items').update({
            'seal_id': seal.sealId,
            'manual_seal_name': seal.manualSealName,
            'seal_type': seal.sealType,
            'wear_percentage': seal.wearPercentage.toInt(),
            'need_replacement': seal.needsUrgentReplacement,
            'item_notes': seal.notesCtrl.text.trim(),
          }).eq('id', seal.itemId);

          // Update fridge_components dimensions if we have the fridge ID
          if (fridge.fridgeId != null && (height > 0 || width > 0)) {
            final existing = await _supabase
                .from('fridge_components')
                .select('id')
                .eq('fridge_id', fridge.fridgeId!)
                .eq('component_index', i + 1)
                .limit(1)
                .maybeSingle();

            if (existing != null) {
              await _supabase.from('fridge_components').update({
                'height_mm': height > 0 ? height : null,
                'width_mm': width > 0 ? width : null,
              }).eq('id', existing['id']);
            }
          }
        }
      }

      // 4. Refresh local report cache
      await _refreshLocalCache();

      if (mounted) {
        _showSnack('Report updated successfully.');
        Navigator.pop(context, true); // true signals that the caller should refresh
      }
    } catch (e) {
      debugPrint('Edit report save error: $e');
      if (mounted) {
        _showSnack('Save failed: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _refreshLocalCache() async {
    try {
      final engineerId = _supabase.auth.currentUser?.id;
      if (engineerId == null) return;

      final reports = await _supabase.from('asset_reports').select('''
        *,
        customer:user_profiles!customer_id(full_name, email),
        fridges:assets_report_fridge(
          *,
          seals:asset_report_fridge_items(*)
        )
      ''').eq('engineer_id', engineerId).order('created_at', ascending: false);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cached_my_reports', jsonEncode(reports));
    } catch (e) {
      debugPrint('Cache refresh error (non-fatal): $e');
    }
  }

  // -------------------------------------------------------------------------
  // Product search bottom sheet
  // -------------------------------------------------------------------------

  void _showSealSearch(_SealEditState seal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        List<Map<String, dynamic>> filtered = List.from(_allProducts);
        return StatefulBuilder(
          builder: (ctx, setModal) => DraggableScrollableSheet(
            initialChildSize: 0.8,
            maxChildSize: 0.95,
            minChildSize: 0.5,
            expand: false,
            builder: (_, scrollCtrl) => Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const Text(
                    'Change Seal Product',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search model # or name...',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (val) {
                        setModal(() {
                          if (val.isEmpty) {
                            filtered = List.from(_allProducts);
                          } else {
                            final q = val.toLowerCase();
                            filtered = _allProducts.where((p) =>
                                (p['seal_model_number'] ?? '').toString().toLowerCase().contains(q) ||
                                (p['title'] ?? '').toString().toLowerCase().contains(q)).toList();
                          }
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: filtered.isEmpty
                        ? const Center(child: Text('No products found'))
                        : ListView.builder(
                            controller: scrollCtrl,
                            itemCount: filtered.length,
                            itemBuilder: (_, i) {
                              final p = filtered[i];
                              return ListTile(
                                leading: const Icon(Icons.qr_code, color: AppTheme.primary),
                                title: Text(
                                  p['seal_model_number'] ?? 'No Model #',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(p['title'] ?? ''),
                                onTap: () {
                                  Navigator.pop(ctx);
                                  setState(() {
                                    seal.sealId = p['id'].toString();
                                    seal.manualSealName = p['title'] ?? '';
                                    seal.sealType = p['seal_type'] ?? '';
                                    seal.sealModelNumber = p['seal_model_number'] ?? '';
                                    seal.isMagnetic = p['is_magnetic'] == true;
                                    seal.isDartToDart = p['is_dart_to_dart'] == true;
                                    seal.isIdentified = true;
                                  });
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // -------------------------------------------------------------------------
  // UI helpers
  // -------------------------------------------------------------------------

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppTheme.error : AppTheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Report'), elevation: 0),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.wifi_off_rounded, size: 48, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _fetchReport,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Edit Report'),
        elevation: 0,
        actions: [
          _isSaving
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    ),
                  ),
                )
              : TextButton(
                  onPressed: _saveChanges,
                  child: const Text(
                    'SAVE',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildReportSection(),
            const SizedBox(height: 24),
            const Text(
              'ASSET DETAILS',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.blueGrey,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 12),
            for (final fridge in _fridgeStates) ...[
              _buildFridgeCard(fridge),
              const SizedBox(height: 16),
            ],
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text(
                      'SAVE CHANGES',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        letterSpacing: 0.5,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Report-level section
  // -------------------------------------------------------------------------

  Widget _buildReportSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'REPORT DETAILS',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppTheme.primary,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 16),
          _buildField('Report Title', _titleCtrl),
          const SizedBox(height: 12),
          _buildField('General Notes', _reportNotesCtrl, maxLines: 3),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Fridge card
  // -------------------------------------------------------------------------

  Widget _buildFridgeCard(_FridgeEditState fridge) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                const Icon(Icons.kitchen_rounded, color: AppTheme.primary, size: 20),
                const SizedBox(width: 10),
                const Text(
                  'APPLIANCE',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionLabel('LOCATION'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _buildField('Area / Sub-Location', fridge.areaCtrl)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildField('GG Number', fridge.ggNumberCtrl)),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSectionLabel('APPLIANCE INFO'),
                const SizedBox(height: 8),
                _buildField('Manufacturer / Brand', fridge.manufacturerCtrl),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _buildField('Model No.', fridge.modelCtrl)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildField('Serial No.', fridge.serialCtrl)),
                  ],
                ),
                const SizedBox(height: 8),
                _buildField('Engineer Notes', fridge.engineerNotesCtrl, maxLines: 2),
              ],
            ),
          ),

          const Divider(height: 1),

          // Seal items
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: _buildSectionLabel('SEAL ITEMS'),
          ),
          for (final seal in fridge.seals) ...[
            _buildSealCard(seal),
          ],
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Seal card
  // -------------------------------------------------------------------------

  Widget _buildSealCard(_SealEditState seal) {

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: seal.needsUrgentReplacement ? AppTheme.error : Colors.grey[200]!,
          width: seal.needsUrgentReplacement ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Item name + current seal
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      seal.itemName.toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      seal.sealModelNumber.isNotEmpty ? seal.sealModelNumber : (seal.manualSealName.isNotEmpty ? seal.manualSealName : 'No seal assigned'),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.secondaryText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showSealSearch(seal),
                icon: const Icon(Icons.edit_rounded, size: 14, color: Colors.white),
                label: const Text(
                  'CHANGE',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.tertiary,
                  minimumSize: const Size(0, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Dimensions
          Row(
            children: [
              Expanded(
                child: _buildSmallField(
                  label: seal.itemName.toLowerCase().contains('drawer') ? 'DRAWER HEIGHT (mm)' : 'DOOR HEIGHT (mm)',
                  ctrl: seal.heightCtrl,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSmallField(
                  label: seal.itemName.toLowerCase().contains('drawer') ? 'DRAWER WIDTH (mm)' : 'DOOR WIDTH (mm)',
                  ctrl: seal.widthCtrl,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text('MEASURED', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.secondaryText)),
          const SizedBox(height: 6),
          Row(
            children: [
              _wearChip(
                label: 'EDGE TO EDGE',
                color: AppTheme.primary,
                isSelected: !seal.isDartToDart,
                onTap: () => setState(() => seal.isDartToDart = false),
              ),
              const SizedBox(width: 8),
              _wearChip(
                label: 'DART TO DART',
                color: AppTheme.primary,
                isSelected: seal.isDartToDart,
                onTap: () => setState(() => seal.isDartToDart = true),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Wear condition selector
          const Text('WEAR CONDITION', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              _wearChip(label: 'OK', color: AppTheme.success, isSelected: !seal.needsUrgentReplacement, onTap: () => setState(() { seal.wearPercentage = 10; seal.needsUrgentReplacement = false; })),
              const SizedBox(width: 12),
              _wearChip(label: 'SPLIT', color: AppTheme.error, isSelected: seal.needsUrgentReplacement, onTap: () => setState(() { seal.wearPercentage = 50; seal.needsUrgentReplacement = true; })),
            ],
          ),

          const SizedBox(height: 8),

          // Item notes
          _buildSmallField(label: 'ITEM NOTES', ctrl: seal.notesCtrl, maxLines: 2),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Widget builders
  // -------------------------------------------------------------------------

  Widget _buildField(String label, TextEditingController ctrl, {int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildSmallField({
    required String label,
    required TextEditingController ctrl,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 4),
        TextField(
          controller: ctrl,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: AppTheme.primary,
          letterSpacing: 0.8,
        ),
      );

  Widget _wearChip({required String label, required Color color, required bool isSelected, required VoidCallback onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.12) : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isSelected ? color : Colors.grey[300]!, width: isSelected ? 2 : 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(isSelected ? Icons.check_circle_rounded : Icons.circle_outlined, size: 18, color: isSelected ? color : Colors.grey[400]),
              const SizedBox(height: 4),
              Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: isSelected ? color : Colors.grey[500])),
            ],
          ),
        ),
      ),
    );
  }
}

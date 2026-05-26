
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/pages/auth_page.dart';
import 'package:mobile/theme.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

import 'package:mobile/vision/rubber_camera_detector.dart';

class PredictionResult {
  final String label;
  final double confidence;
  PredictionResult(this.label, this.confidence);
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<File> imageFiles = [];
  List<PredictionResult> topPredictions = [];
  PredictionResult? selectedResult;

  String statusMessage = "Add images to start analysis";
  bool isBusy = false;
  bool isUnmatched = false;

  Interpreter? interpreter;
  List<String> labels = [];
  bool isModelLoaded = false;
  bool isInitializing = false;

  List<int>? inputShape;
  TensorType? inputType;

  final double matchThreshold = 0.50;
  final int minimumImages = 3;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await initApp();
    });
  }

  // =============================================
  // INIT & MODEL LOADING
  // =============================================

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Logout"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const AuthPage()),
                      (route) => false,
                );
              }
            },
            child: const Text("Logout",
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> initApp() async {
    if (isInitializing) return;
    setState(() {
      isInitializing = true;
      statusMessage = "Loading AI Model...";
    });

    await loadModelAndLabels();
    await _printModelVersionFile();

    setState(() => isInitializing = false);
  }

  Future<void> _printModelVersionFile() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final prefs = await SharedPreferences.getInstance();
      final version = prefs.getInt('current_model_version') ?? 0;

      final fileName = "model_v$version.txt";
      final filePath = "${directory.path}/$fileName";
      final file = File(filePath);

      if (await file.exists()) {
        final content = await file.readAsString();
        debugPrint('--- VERSION FILE CONTENT ($fileName) ---');
        debugPrint(content);
        debugPrint('-----------------------------------------');
      }
    } catch (e) {
      debugPrint('VERSION_FILE_ERROR: $e');
    }
  }

  Future<void> loadModelAndLabels() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? savedModelPath = prefs.getString('current_model_path');
      final String? savedLabelsPath =
      prefs.getString('current_labels_path');
      final int? version = prefs.getInt('current_model_version');

      if (savedLabelsPath != null && File(savedLabelsPath).existsSync()) {
        final data = await File(savedLabelsPath).readAsString();
        labels =
            data.split('\n').where((e) => e.trim().isNotEmpty).toList();
      } else {
        final data =
        await rootBundle.loadString('assets/model1/labels.txt');
        labels =
            data.split('\n').where((e) => e.trim().isNotEmpty).toList();
      }

      if (savedModelPath != null && File(savedModelPath).existsSync()) {
        interpreter = await Interpreter.fromFile(File(savedModelPath));
      } else {
        interpreter =
        await Interpreter.fromAsset('assets/model1/model.tflite');
      }

      if (interpreter != null) {
        inputShape = interpreter!.getInputTensor(0).shape;
        inputType = interpreter!.getInputTensor(0).type;
        setState(() {
          isModelLoaded = true;
          statusMessage = "AI System Ready (v${version ?? 'Asset'})";
        });
      }
    } catch (e) {
      debugPrint("HOMEPAGE_LOAD_ERROR: $e");
      setState(() {
        isModelLoaded = false;
        statusMessage = "Model Load Error";
      });
    }
  }

  // =============================================
  // INFERENCE
  // =============================================

  Future<void> runMultiInference() async {
    if (imageFiles.isEmpty || !isModelLoaded) return;

    if (imageFiles.length < minimumImages) {
      _showMinimumWarning();
      return;
    }

    await _runInference(force: false);
  }

  Future<void> _forceRunInference() async {
    await _runInference(force: true);
  }

  Future<void> _runInference({required bool force}) async {
    if (imageFiles.isEmpty || !isModelLoaded) return;

    setState(() {
      isBusy = true;
      selectedResult = null;
      statusMessage = force
          ? "Analyzing (fewer images may reduce accuracy)..."
          : "Aggregating geometric data...";
    });

    try {
      List<List<double>> allScores = [];

      for (int idx = 0; idx < imageFiles.length; idx++) {
        setState(() {
          statusMessage =
          "Processing image ${idx + 1} of ${imageFiles.length}...";
        });

        final bytes = await imageFiles[idx].readAsBytes();
        img.Image? image = img.decodeImage(bytes);
        if (image == null) continue;

        int height = inputShape![1];
        int width = inputShape![2];

        img.Image resized =
        img.copyResize(image, width: width, height: height);

        var input = List.generate(
          1,
              (_) => List.generate(
            height,
                (y) => List.generate(width, (x) {
              final pixel = resized.getPixel(x, y);
              return [
                pixel.r.toDouble(),
                pixel.g.toDouble(),
                pixel.b.toDouble()
              ];
            }),
          ),
        );

        var output =
        List.generate(1, (_) => List.filled(labels.length, 0.0));
        interpreter!.run(input, output);
        allScores.add(List<double>.from(output[0]));
      }

      if (allScores.isEmpty) throw Exception("No images could be processed");

      List<double> averagedScores = List.filled(labels.length, 0.0);
      for (int i = 0; i < labels.length; i++) {
        double sum = 0;
        for (int j = 0; j < allScores.length; j++) {
          sum += allScores[j][i];
        }
        averagedScores[i] = sum / allScores.length;
      }

      List<PredictionResult> results = [];
      for (int i = 0; i < labels.length; i++) {
        results.add(PredictionResult(labels[i], averagedScores[i]));
      }

      results.sort((a, b) => b.confidence.compareTo(a.confidence));

      setState(() {
        isBusy = false;
        selectedResult = null;

        bool hasHighConfidence =
            results.isNotEmpty && results[0].confidence >= matchThreshold;
        bool hasClearGap = results.length > 1
            ? (results[0].confidence - results[1].confidence) > 0.12
            : true;

        if (!hasHighConfidence || !hasClearGap) {
          isUnmatched = true;
          statusMessage = "Data Not Matched";
          topPredictions = [];
        } else {
          isUnmatched = false;
          statusMessage = force
              ? "Analysis Complete (${imageFiles.length} images · accuracy may vary)"
              : "Analysis Complete (${imageFiles.length} images analyzed)";
          topPredictions = results.take(3).toList();
        }
      });
    } catch (e) {
      debugPrint("Inference Error: $e");
      setState(() {
        statusMessage = "Analysis Failed";
        isBusy = false;
      });
    }
  }

  // =============================================
  // SELECTION — tap shifts the indigo border
  // =============================================

  void _toggleSelection(PredictionResult res) {
    setState(() {
      selectedResult =
      selectedResult?.label == res.label ? null : res;
    });
  }

  // =============================================
  // IMAGE MANAGEMENT
  // =============================================

  void clearImages() => setState(() {
    imageFiles = [];
    topPredictions = [];
    selectedResult = null;
    isUnmatched = false;
    statusMessage = "AI System Ready";
  });

  Future<void> addImage(ImageSource source) async {
    final picker = ImagePicker();

    if (source == ImageSource.gallery) {
      try {
        final List<XFile> pickedFiles = await picker.pickMultiImage();
        if (pickedFiles.isEmpty) return;

        setState(() {
          imageFiles
              .addAll(pickedFiles.map((f) => File(f.path)).toList());
          selectedResult = null;
          isUnmatched = false;
          topPredictions = [];
          statusMessage = _getImageCountStatus();
        });
      } catch (e) {
        debugPrint("Gallery error: $e");
      }
    } else {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const RubberCameraDetectorPage(),
        ),
      );

      if (result == null) return;

      List<File> newFiles = [];
      if (result is List) {
        for (var item in result) {
          if (item is Map && item['path'] != null) {
            newFiles.add(File(item['path'].toString()));
          }
        }
      } else if (result is File) {
        newFiles.add(result);
      } else if (result is String) {
        newFiles.add(File(result));
      } else if (result is Map && result['path'] != null) {
        newFiles.add(File(result['path'].toString()));
      }

      if (newFiles.isNotEmpty) {
        setState(() {
          imageFiles.addAll(newFiles);
          selectedResult = null;
          isUnmatched = false;
          topPredictions = [];
          statusMessage = _getImageCountStatus();
        });
      }
    }
  }

  String _getImageCountStatus() {
    if (imageFiles.isEmpty) return "Add images to start analysis";
    if (imageFiles.length < minimumImages) {
      int needed = minimumImages - imageFiles.length;
      return "${imageFiles.length} image${imageFiles.length > 1 ? 's' : ''} added · Add $needed more for better analysis";
    }
    return "${imageFiles.length} image${imageFiles.length > 1 ? 's' : ''} ready for analysis";
  }

  void _showMinimumWarning() {
    int needed = minimumImages - imageFiles.length;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.info_outline,
                  color: Colors.orange, size: 24),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text("More Images Needed",
                  style: TextStyle(fontSize: 17)),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "You currently have ${imageFiles.length} image${imageFiles.length > 1 ? 's' : ''}.",
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              "Please add at least $needed more image${needed > 1 ? 's' : ''} for better and more accurate analysis.",
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
                border:
                Border.all(color: Colors.blue.withOpacity(0.15)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lightbulb_outline,
                      size: 18, color: Colors.blue),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Tip: Minimum 3 images from different angles gives the best results!",
                      style:
                      TextStyle(fontSize: 12, color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Got it"),
          ),
          if (imageFiles.isNotEmpty)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _forceRunInference();
              },
              child: Text("Analyze Anyway",
                  style: TextStyle(color: Colors.orange[700])),
            ),
        ],
      ),
    );
  }

  void _showImagePreview(File imageFile, int index) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          alignment: Alignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(imageFile, fit: BoxFit.contain),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                      color: Colors.black54, shape: BoxShape.circle),
                  child: const Icon(Icons.close,
                      color: Colors.white, size: 20),
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    imageFiles.removeAt(index);
                    topPredictions.clear();
                    selectedResult = null;
                    isUnmatched = false;
                    statusMessage = _getImageCountStatus();
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.delete, color: Colors.white, size: 18),
                      SizedBox(width: 6),
                      Text("Remove",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "${index + 1} / ${imageFiles.length}",
                  style: const TextStyle(
                      color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Clear All Images?"),
        content: Text(
            "This will remove all ${imageFiles.length} images and reset the analysis."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              clearImages();
            },
            child: const Text("Clear All",
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // =============================================
  // BUILD
  // =============================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (imageFiles.isNotEmpty) _buildImageCountBanner(),
            if (imageFiles.isNotEmpty) const SizedBox(height: 16),

            _buildImageGallery(),
            const SizedBox(height: 20),

            if (imageFiles.isNotEmpty &&
                imageFiles.length < minimumImages)
              _buildMinimumImagesTip(),

            _buildStatusHeader(),

            if (isBusy || isInitializing) _buildLoadingSection(),

            if (!isBusy && !isInitializing && isUnmatched)
              _buildErrorCard(),

            if (!isBusy &&
                !isInitializing &&
                !isUnmatched &&
                topPredictions.isNotEmpty) ...[
              ...topPredictions.asMap().entries.map(
                    (e) => _buildResultTile(
                  e.value,
                  rank: e.key + 1,
                  isHighlyRecommended: e.key == 0,
                ),
              ),
              if (selectedResult != null) _buildSelectionBanner(),
            ],

            const SizedBox(height: 24),
            if (!isBusy) _buildActionButtons(),

            if (imageFiles.isNotEmpty && !isBusy) ...[
              const SizedBox(height: 12),
              _buildVerifyButton(),
            ],
          ],
        ),
      ),
    );
  }

  // =============================================
  // APP BAR — plain text, no image
  // =============================================

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      centerTitle: true,
      // ── Plain text title, no logo image ──
      title: const Text(
        "Gasket Guy",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black87,
          fontSize: 20,
        ),
      ),
      actions: [
        if (imageFiles.isNotEmpty)
          IconButton(
            onPressed: _showClearConfirmation,
            icon:
            const Icon(Icons.delete_sweep_rounded, color: Colors.red),
            tooltip: "Clear all images",
          ),
        // IconButton(
        //   onPressed: () => _showLogoutDialog(context),
        //   icon: const Icon(Icons.logout, color: AppTheme.error),
        //   tooltip: "Logout",
        // ),
        // IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded, color: Colors.grey)),
        // const SizedBox(width: 8),
      ],
    );
  }

  // =============================================
  // IMAGE COUNT BANNER
  // =============================================

  Widget _buildImageCountBanner() {
    final bool isEnough = imageFiles.length >= minimumImages;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isEnough
            ? Colors.green.withOpacity(0.06)
            : Colors.orange.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isEnough
              ? Colors.green.withOpacity(0.25)
              : Colors.orange.withOpacity(0.25),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isEnough
                  ? Colors.green.withOpacity(0.15)
                  : Colors.orange.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isEnough
                  ? Icons.check_circle_outline
                  : Icons.photo_library,
              color: isEnough ? Colors.green : Colors.orange,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${imageFiles.length} Image${imageFiles.length > 1 ? 's' : ''} Added",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isEnough
                        ? Colors.green[800]
                        : Colors.orange[800],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isEnough
                      ? "Ready for analysis! More images = better accuracy."
                      : "Add at least ${minimumImages - imageFiles.length} more for better results.",
                  style: TextStyle(
                    fontSize: 11,
                    color: isEnough
                        ? Colors.green[600]
                        : Colors.orange[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =============================================
  // IMAGE GALLERY
  // =============================================

  Widget _buildImageGallery() {
    if (imageFiles.isEmpty) return _buildEmptyGallery();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Captured Profiles",
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87),
            ),
            Text("Tap to preview",
                style: TextStyle(fontSize: 11, color: Colors.grey[500])),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 130,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: imageFiles.length,
            itemBuilder: (context, index) =>
                _buildImageThumbnail(index),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyGallery() {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.indigo.withOpacity(0.15),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.indigo.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.add_photo_alternate_outlined,
                size: 36, color: Colors.indigo),
          ),
          const SizedBox(height: 12),
          const Text(
            "No profiles added yet",
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: Colors.black54),
          ),
          const SizedBox(height: 4),
          Text(
            "Use Camera or Gallery to add images",
            style: TextStyle(fontSize: 12, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  Widget _buildImageThumbnail(int index) {
    return GestureDetector(
      onTap: () => _showImagePreview(imageFiles[index], index),
      child: Container(
        width: 110,
        margin: EdgeInsets.only(right: 10, left: index == 0 ? 2 : 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(imageFiles[index],
                  width: 110, height: 130, fit: BoxFit.cover),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.5),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 6,
              left: 8,
              child: Text("#${index + 1}",
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12)),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    imageFiles.removeAt(index);
                    topPredictions.clear();
                    selectedResult = null;
                    isUnmatched = false;
                    statusMessage = _getImageCountStatus();
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close,
                      color: Colors.white, size: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =============================================
  // MINIMUM IMAGES TIP
  // =============================================

  Widget _buildMinimumImagesTip() {
    int needed = minimumImages - imageFiles.length;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.blue.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb_outline,
              color: Colors.blue[400], size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style:
                TextStyle(fontSize: 12, color: Colors.blue[700]),
                children: [
                  const TextSpan(
                      text: "Tip: ",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(
                    text:
                    "Add at least $needed more image${needed > 1 ? 's' : ''} for better accuracy. "
                        "Minimum $minimumImages images recommended.",
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =============================================
  // STATUS HEADER
  // =============================================

  Widget _buildStatusHeader() {
    IconData icon;
    Color color;

    if (isUnmatched) {
      icon = Icons.error_outline;
      color = Colors.red;
    } else if (isBusy || isInitializing) {
      icon = Icons.hourglass_top;
      color = Colors.orange;
    } else if (selectedResult != null) {
      icon = Icons.touch_app_rounded;
      color = Colors.indigo;
    } else if (topPredictions.isNotEmpty) {
      icon = Icons.check_circle_outline;
      color = Colors.green;
    } else {
      icon = Icons.info_outline;
      color = Colors.indigo;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              statusMessage.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: color,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =============================================
  // LOADING
  // =============================================

  Widget _buildLoadingSection() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(
              strokeWidth: 4,
              valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.indigo.withOpacity(0.7)),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            statusMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // =============================================
  // ACTION BUTTONS
  // =============================================

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: const LinearGradient(
                colors: [Colors.indigo, Color(0xFF3949AB)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.indigo.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () => addImage(ImageSource.camera),
              icon: const Icon(Icons.camera_alt_rounded, size: 20),
              label: const Text("Camera",
                  style: TextStyle(fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: Colors.indigo.withOpacity(0.3), width: 1.5),
            ),
            child: OutlinedButton.icon(
              onPressed: () => addImage(ImageSource.gallery),
              icon: Icon(Icons.photo_library_rounded,
                  size: 20, color: Colors.indigo[600]),
              label: Text("Gallery",
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.indigo[600])),
              style: OutlinedButton.styleFrom(
                side: BorderSide.none,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // =============================================
  // VERIFY BUTTON
  // =============================================

  Widget _buildVerifyButton() {
    final bool isEnough = imageFiles.length >= minimumImages;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          colors: isEnough
              ? [Colors.green[600]!, Colors.green[700]!]
              : [Colors.orange[400]!, Colors.orange[600]!],
        ),
        boxShadow: [
          BoxShadow(
            color: (isEnough ? Colors.green : Colors.orange)
                .withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: runMultiInference,
        icon: Icon(
          isEnough
              ? Icons.analytics_rounded
              : Icons.warning_amber_rounded,
          size: 22,
        ),
        label: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "VERIFY PROFILES",
              style:
              TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            if (!isEnough)
              Text(
                "(${imageFiles.length}/$minimumImages minimum images)",
                style: const TextStyle(
                    fontSize: 10, fontWeight: FontWeight.w400),
              ),
          ],
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  // =============================================
  // RESULT TILE — indigo border shifts to selected
  // =============================================

  Widget _buildResultTile(
      PredictionResult res, {
        required int rank,
        required bool isHighlyRecommended,
      }) {
    final bool isSelected = selectedResult?.label == res.label;

    // Rank colours (never change on selection)
    Color rankColor;
    IconData rankIcon;
    switch (rank) {
      case 1:
        rankColor = Colors.indigo;
        rankIcon = Icons.emoji_events;
        break;
      case 2:
        rankColor = Colors.blueGrey;
        rankIcon = Icons.looks_two;
        break;
      default:
        rankColor = Colors.grey;
        rankIcon = Icons.looks_3;
    }

    // ── Border logic ──────────────────────────────────────────
    // Selected   → thick indigo border (2.5)
    // Best match (unselected) → thin indigo border (1)
    // Others     → very light grey border (1)
    final Color borderColor = isSelected
        ? Colors.indigo
        : isHighlyRecommended
        ? Colors.indigo.withOpacity(0.3)
        : Colors.grey.withOpacity(0.15);

    final double borderWidth = isSelected ? 2.5 : 1.0;

    // ── Background ────────────────────────────────────────────
    final Color bgColor = isSelected
        ? Colors.indigo.withOpacity(0.04)
        : Colors.white;

    return GestureDetector(
      onTap: () => _toggleSelection(res),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: borderWidth),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: Colors.indigo.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              )
            else if (isHighlyRecommended)
              BoxShadow(
                color: Colors.indigo.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Rank badge
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: rankColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(rankIcon,
                            size: 20, color: rankColor),
                      ),
                      const SizedBox(width: 12),

                      // Label + badge
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              res.label,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: isHighlyRecommended
                                    ? Colors.indigo
                                    : Colors.black87,
                              ),
                            ),
                            if (isHighlyRecommended)
                              Container(
                                margin:
                                const EdgeInsets.only(top: 4),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                      colors: [
                                        Colors.indigo,
                                        Colors.blue
                                      ]),
                                  borderRadius:
                                  BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  "⭐ Best Match",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight:
                                      FontWeight.bold),
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Confidence %
                      Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.end,
                        children: [
                          Text(
                            "${(res.confidence * 100).toStringAsFixed(1)}%",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: rankColor,
                            ),
                          ),
                          Text(
                            "confidence",
                            style: TextStyle(
                                fontSize: 9,
                                color: Colors.grey[400]),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Progress bar — indigo when selected
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: res.confidence,
                      minHeight: 8,
                      backgroundColor: Colors.grey[100],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isSelected ? Colors.indigo : rankColor,
                      ),
                    ),
                  ),

                  // "Tap to select" hint only on unselected tiles
                  if (!isSelected)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        "Tap to select",
                        style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[400]),
                      ),
                    ),

                  // "Selected" row inside tile
                  if (isSelected)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle,
                              size: 14,
                              color: Colors.indigo[700]),
                          const SizedBox(width: 5),
                          Text(
                            "Selected",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.indigo[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // Top-right indigo check badge when selected
            if (isSelected)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.indigo,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check,
                      color: Colors.white, size: 14),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // =============================================
  // SELECTION BANNER — indigo themed
  // =============================================

  Widget _buildSelectionBanner() {
    return Container(
      margin: const EdgeInsets.only(top: 4, bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.indigo.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.indigo.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.indigo.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.check_circle_outline,
                color: Colors.indigo, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Selected Result",
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo[800]),
                ),
                Text(
                  selectedResult!.label,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                ),
              ],
            ),
          ),
          Text(
            "${(selectedResult!.confidence * 100).toStringAsFixed(1)}%",
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.indigo),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => setState(() => selectedResult = null),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close,
                  color: Colors.redAccent, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  // =============================================
  // ERROR CARD
  // =============================================

  Widget _buildErrorCard() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.search_off_rounded,
                color: Colors.orange, size: 44),
          ),
          const SizedBox(height: 16),
          const Text(
            "No Match Found",
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Text(
            "The AI couldn't confidently identify the gasket profile. "
                "Try capturing clearer images with better lighting and different angles.",
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.grey[600], fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => addImage(ImageSource.camera),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: Colors.orange.withOpacity(0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_a_photo,
                      size: 18, color: Colors.orange[700]),
                  const SizedBox(width: 8),
                  Text("Add More Images",
                      style: TextStyle(color: Colors.orange[700])),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
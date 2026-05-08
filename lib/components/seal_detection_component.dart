// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:tflite_flutter/tflite_flutter.dart';
// import 'package:image/image.dart' as img;
// import 'package:path_provider/path_provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../home_page.dart';
// import '../theme.dart';
//
// // Model to return to the AddAssetPage
// class SealDetectionResult {
//   final String label;
//   final double confidence;
//   final List<File> images;
//
//   SealDetectionResult({
//     required this.label,
//     required this.confidence,
//     required this.images,
//   });
// }
//
// class SealDetectionComponent extends StatefulWidget {
//   const SealDetectionComponent({super.key});
//
//   @override
//   State<SealDetectionComponent> createState() => _SealDetectionComponentState();
// }
//
// class _SealDetectionComponentState extends State<SealDetectionComponent> {
//   List<File> imageFiles = [];
//   List<PredictionResult> topPredictions = [];
//   PredictionResult? selectedResult; // Track which result the engineer tapped
//
//   String statusMessage = "Add images to start analysis";
//   bool isBusy = false;
//   bool isModelLoaded = false;
//   bool isInitializing = false;
//   bool isUnmatched = false;
//
//   Interpreter? interpreter;
//   List<String> labels = [];
//   List<int>? inputShape;
//   final int maxImageLimit = 5;
//   final double matchThreshold = 0.50;
//
//   @override
//   void initState() {
//     super.initState();
//     _initApp();
//   }
//
//   Future<void> _initApp() async {
//     setState(() {
//       isInitializing = true;
//       statusMessage = "Loading AI Model...";
//     });
//     await _loadModelAndLabels();
//     setState(() => isInitializing = false);
//   }
//
//   Future<void> _loadModelAndLabels() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final String? savedModelPath = prefs.getString('current_model_path');
//       final String? savedLabelsPath = prefs.getString('current_labels_path');
//
//       // Load Labels
//       if (savedLabelsPath != null && File(savedLabelsPath).existsSync()) {
//         final data = await File(savedLabelsPath).readAsString();
//         labels = data.split('\n').where((e) => e.trim().isNotEmpty).toList();
//       } else {
//         final data = await rootBundle.loadString('assets/model1/labels.txt');
//         labels = data.split('\n').where((e) => e.trim().isNotEmpty).toList();
//       }
//
//       // Load Model
//       if (savedModelPath != null && File(savedModelPath).existsSync()) {
//         interpreter = await Interpreter.fromFile(File(savedModelPath));
//       } else {
//         interpreter = await Interpreter.fromAsset('assets/model1/model.tflite');
//       }
//
//       if (interpreter != null) {
//         inputShape = interpreter!.getInputTensor(0).shape;
//         setState(() {
//           isModelLoaded = true;
//           statusMessage = "AI System Ready";
//         });
//       }
//     } catch (e) {
//       setState(() => statusMessage = "Model Load Error");
//     }
//   }
//
//   Future<void> _runInference() async {
//     if (imageFiles.isEmpty || !isModelLoaded) return;
//     setState(() {
//       isBusy = true;
//       statusMessage = "Analyzing profile geometry...";
//       topPredictions = [];
//       selectedResult = null;
//     });
//
//     try {
//       List<List<double>> allScores = [];
//       for (var file in imageFiles) {
//         final bytes = await file.readAsBytes();
//         img.Image? image = img.decodeImage(bytes);
//         if (image == null) continue;
//
//         int h = inputShape![1];
//         int w = inputShape![2];
//         img.Image resized = img.copyResize(image, width: w, height: h);
//
//         var input = List.generate(1, (_) => List.generate(h, (y) => List.generate(w, (x) {
//           final pixel = resized.getPixel(x, y);
//           return [pixel.r.toDouble(), pixel.g.toDouble(), pixel.b.toDouble()];
//         })));
//
//         var output = List.generate(1, (_) => List.filled(labels.length, 0.0));
//         interpreter!.run(input, output);
//         allScores.add(List<double>.from(output[0]));
//       }
//
//       // Average scores
//       List<double> avg = List.filled(labels.length, 0.0);
//       for (int i = 0; i < labels.length; i++) {
//         double sum = 0;
//         for (var score in allScores) sum += score[i];
//         avg[i] = sum / allScores.length;
//       }
//
//       List<PredictionResult> res = [];
//       for (int i = 0; i < labels.length; i++) {
//         res.add(PredictionResult(labels[i], avg[i]));
//       }
//       res.sort((a, b) => b.confidence.compareTo(a.confidence));
//
//       setState(() {
//         isBusy = false;
//         if (res.isEmpty || res[0].confidence < matchThreshold) {
//           isUnmatched = true;
//           statusMessage = "No Match Found";
//         } else {
//           isUnmatched = false;
//           statusMessage = "Select the correct seal below";
//           topPredictions = res.take(3).toList();
//           selectedResult = topPredictions[0]; // Auto-select top one
//         }
//       });
//     } catch (e) {
//       setState(() {
//         isBusy = false;
//         statusMessage = "Analysis Failed";
//       });
//     }
//   }
//
//   void _confirmSelection() {
//     if (selectedResult == null) return;
//
//     // Pass back the data to the AddAssetPage
//     Navigator.pop(context, SealDetectionResult(
//       label: selectedResult!.label,
//       confidence: selectedResult!.confidence,
//       images: List.from(imageFiles),
//     ));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: MediaQuery.of(context).size.height * 0.85,
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//       ),
//       child: Column(
//         children: [
//           _buildHandle(),
//           Expanded(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.all(24),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   _buildImageGallery(),
//                   const SizedBox(height: 16),
//                   _buildStatusHeader(),
//                   if (isBusy || isInitializing)
//                     const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
//                   else if (isUnmatched)
//                     _buildErrorCard()
//                   else if (topPredictions.isNotEmpty)
//                       ...topPredictions.map((res) => _buildSelectableResult(res)),
//                   const SizedBox(height: 32),
//                 ],
//               ),
//             ),
//           ),
//           _buildBottomActions(),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSelectableResult(PredictionResult res) {
//     bool isSelected = selectedResult?.label == res.label;
//     return GestureDetector(
//       onTap: () => setState(() => selectedResult = res),
//       child: Card(
//         margin: const EdgeInsets.only(bottom: 12),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16),
//           side: BorderSide(color: isSelected ? AppTheme.primary : Colors.grey[200]!, width: isSelected ? 2 : 1),
//         ),
//         color: isSelected ? AppTheme.primary.withOpacity(0.05) : Colors.white,
//         child: ListTile(
//           leading: Icon(isSelected ? Icons.check_circle : Icons.circle_outlined, color: isSelected ? AppTheme.primary : Colors.grey),
//           title: Text(res.label, style: const TextStyle(fontWeight: FontWeight.bold)),
//           trailing: Text("${(res.confidence * 100).toStringAsFixed(1)}%"),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildBottomActions() {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
//       child: Column(
//         children: [
//           if (imageFiles.length < maxImageLimit && !isBusy)
//             Row(children: [
//               Expanded(child: ElevatedButton.icon(onPressed: () => _addImage(ImageSource.camera), icon: const Icon(Icons.add_a_photo), label: const Text("Capture"), style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white))),
//               const SizedBox(width: 12),
//               Expanded(child: OutlinedButton.icon(onPressed: () => _addImage(ImageSource.gallery), icon: const Icon(Icons.add_photo_alternate), label: const Text("Gallery"))),
//             ]),
//           const SizedBox(height: 12),
//           if (imageFiles.isNotEmpty && !isBusy)
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: selectedResult != null ? _confirmSelection : _runInference,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: selectedResult != null ? Colors.green[700] : AppTheme.primary,
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                 ),
//                 child: Text(selectedResult != null ? "CONFIRM SELECTION" : "VERIFY PROFILES"),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
//
//   // Reuse your buildStatusHeader, buildImageGallery, buildErrorCard, and addImage methods here...
//   // [Truncated for brevity, but keep logic from your original code]
//
//   Widget _buildHandle() => Container(margin: const EdgeInsets.only(top: 12), height: 5, width: 40, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)));
//
//
//   void _addImage(ImageSource source) async { /* Same as your original code logic */ }
//
//   _buildImageGallery() {}
//
//   _buildErrorCard() {}
//
//   _buildStatusHeader() {}
// }


import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme.dart';

// Prediction Result internal model
class PredictionResult {
  final String label;
  final double confidence;
  PredictionResult(this.label, this.confidence);
}

// Data model returned to the AddAssetPage
class SealDetectionResult {
  final String label;
  final double confidence;
  final List<File> images;

  SealDetectionResult({
    required this.label,
    required this.confidence,
    required this.images,
  });
}

class SealDetectionComponent extends StatefulWidget {
  const SealDetectionComponent({super.key});

  @override
  State<SealDetectionComponent> createState() => _SealDetectionComponentState();
}

class _SealDetectionComponentState extends State<SealDetectionComponent> {
  List<File> imageFiles = [];
  List<PredictionResult> topPredictions = [];
  PredictionResult? selectedResult;

  String statusMessage = "Add images to start analysis";
  bool isBusy = false;
  bool isModelLoaded = false;
  bool isInitializing = false;
  bool isUnmatched = false;

  Interpreter? interpreter;
  List<String> labels = [];
  List<int>? inputShape;
  TensorType? inputType;

  final int maxImageLimit = 5;
  final double matchThreshold = 0.50;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    setState(() {
      isInitializing = true;
      statusMessage = "Loading AI Model...";
    });
    await _loadModelAndLabels();
    setState(() => isInitializing = false);
  }

  Future<void> _loadModelAndLabels() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? savedModelPath = prefs.getString('current_model_path');
      final String? savedLabelsPath = prefs.getString('current_labels_path');

      // 1. Load Labels
      if (savedLabelsPath != null && File(savedLabelsPath).existsSync()) {
        final data = await File(savedLabelsPath).readAsString();
        labels = data.split('\n').where((e) => e.trim().isNotEmpty).toList();
      } else {
        final data = await rootBundle.loadString('assets/model1/labels.txt');
        labels = data.split('\n').where((e) => e.trim().isNotEmpty).toList();
      }

      // 2. Load Model
      if (savedModelPath != null && File(savedModelPath).existsSync()) {
        interpreter = await Interpreter.fromFile(File(savedModelPath));
      } else {
        interpreter = await Interpreter.fromAsset('assets/model1/model.tflite');
      }

      if (interpreter != null) {
        inputShape = interpreter!.getInputTensor(0).shape;
        inputType = interpreter!.getInputTensor(0).type;
        setState(() {
          isModelLoaded = true;
          statusMessage = "AI System Ready";
        });
      }
    } catch (e) {
      setState(() => statusMessage = "Model Load Error");
    }
  }

  Future<void> _runInference() async {
    if (imageFiles.isEmpty || !isModelLoaded) return;
    setState(() {
      isBusy = true;
      statusMessage = "Analyzing profile geometry...";
      topPredictions = [];
      selectedResult = null;
    });

    try {
      List<List<double>> allScores = [];
      for (var file in imageFiles) {
        final bytes = await file.readAsBytes();
        img.Image? image = img.decodeImage(bytes);
        if (image == null) continue;

        int h = inputShape![1];
        int w = inputShape![2];
        img.Image resized = img.copyResize(image, width: w, height: h);

        var input = List.generate(1, (_) => List.generate(h, (y) => List.generate(w, (x) {
          final pixel = resized.getPixel(x, y);
          return [pixel.r.toDouble(), pixel.g.toDouble(), pixel.b.toDouble()];
        })));

        var output = List.generate(1, (_) => List.filled(labels.length, 0.0));
        interpreter!.run(input, output);
        allScores.add(List<double>.from(output[0]));
      }

      // Average scores
      List<double> avg = List.filled(labels.length, 0.0);
      for (int i = 0; i < labels.length; i++) {
        double sum = 0;
        for (var score in allScores) sum += score[i];
        avg[i] = sum / allScores.length;
      }

      List<PredictionResult> res = [];
      for (int i = 0; i < labels.length; i++) {
        res.add(PredictionResult(labels[i], avg[i]));
      }
      res.sort((a, b) => b.confidence.compareTo(a.confidence));

      setState(() {
        isBusy = false;
        bool hasClearGap = res.length > 1 ? (res[0].confidence - res[1].confidence) > 0.12 : true;

        if (res.isEmpty || res[0].confidence < matchThreshold || !hasClearGap) {
          isUnmatched = true;
          statusMessage = "Data Not Matched";
        } else {
          isUnmatched = false;
          statusMessage = "Select the correct seal below";
          topPredictions = res.take(3).toList();
          selectedResult = topPredictions[0];
        }
      });
    } catch (e) {
      setState(() {
        isBusy = false;
        statusMessage = "Analysis Failed";
      });
    }
  }

  void _confirmSelection() {
    if (selectedResult == null) return;
    Navigator.pop(context, SealDetectionResult(
      label: selectedResult!.label,
      confidence: selectedResult!.confidence,
      images: List.from(imageFiles),
    ));
  }

  void _addImage(ImageSource source) async {
    if (imageFiles.length >= maxImageLimit) {
      _showLimitWarning(maxImageLimit, 0);
      return;
    }

    final picker = ImagePicker();
    if (source == ImageSource.gallery) {
      int remaining = maxImageLimit - imageFiles.length;
      final List<XFile> picked = await picker.pickMultiImage();
      if (picked.isEmpty) return;

      setState(() {
        if (picked.length > remaining) _showLimitWarning(picked.length, remaining);
        imageFiles.addAll(picked.take(remaining).map((x) => File(x.path)));
        _resetStatus();
      });
    } else {
      final picked = await picker.pickImage(source: ImageSource.camera);
      if (picked != null) {
        setState(() {
          imageFiles.add(File(picked.path));
          _resetStatus();
        });
      }
    }
  }

  void _resetStatus() {
    isUnmatched = false;
    topPredictions = [];
    selectedResult = null;
    statusMessage = "${imageFiles.length} profiles ready for analysis";
  }

  void _showLimitWarning(int attempted, int allowed) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Limit Warning"),
        content: Text("Maximum $maxImageLimit images allowed."),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          _buildHandle(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildImageGallery(),
                  const SizedBox(height: 16),
                  _buildStatusHeader(),
                  if (isBusy || isInitializing)
                    const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
                  else if (isUnmatched)
                    _buildErrorCard()
                  else if (topPredictions.isNotEmpty)
                      ...topPredictions.asMap().entries.map((e) => _buildSelectableResult(e.value)),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          _buildBottomActions(),
        ],
      ),
    );
  }

  Widget _buildSelectableResult(PredictionResult res) {
    bool isSelected = selectedResult?.label == res.label;
    return GestureDetector(
      onTap: () => setState(() => selectedResult = res),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: isSelected ? AppTheme.primary : Colors.grey[200]!, width: isSelected ? 2 : 1),
        ),
        color: isSelected ? AppTheme.primary.withOpacity(0.05) : Colors.white,
        child: ListTile(
          leading: Icon(isSelected ? Icons.check_circle : Icons.circle_outlined, color: isSelected ? AppTheme.primary : Colors.grey),
          title: Text(res.label, style: const TextStyle(fontWeight: FontWeight.bold)),
          trailing: Text("${(res.confidence * 100).toStringAsFixed(1)}%"),
        ),
      ),
    );
  }

  Widget _buildBottomActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        children: [
          if (imageFiles.length < maxImageLimit && !isBusy)
            Row(children: [
              Expanded(child: ElevatedButton.icon(onPressed: () => _addImage(ImageSource.camera), icon: const Icon(Icons.add_a_photo), label: const Text("Capture"), style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)))),
              const SizedBox(width: 12),
              Expanded(child: OutlinedButton.icon(onPressed: () => _addImage(ImageSource.gallery), icon: const Icon(Icons.add_photo_alternate), label: const Text("Gallery"), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)))),
            ]),
          const SizedBox(height: 12),
          if (imageFiles.isNotEmpty && !isBusy)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selectedResult != null ? _confirmSelection : (isModelLoaded ? _runInference : null),
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedResult != null ? Colors.green[700] : AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                ),
                child: Text(selectedResult != null ? "CONFIRM SELECTION" : "VERIFY PROFILES"),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImageGallery() {
    return SizedBox(
      height: 120,
      child: imageFiles.isEmpty
          ? Container(
        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(20)),
        child: const Center(child: Text("No profiles added yet", style: TextStyle(color: Colors.grey))),
      )
          : ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: imageFiles.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return Stack(children: [
            Container(width: 120, decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), image: DecorationImage(image: FileImage(imageFiles[index]), fit: BoxFit.cover))),
            Positioned(top: 4, right: 4, child: GestureDetector(onTap: () => setState(() => imageFiles.removeAt(index)), child: Container(padding: const EdgeInsets.all(2), decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle), child: const Icon(Icons.close, color: Colors.white, size: 18)))),
          ]);
        },
      ),
    );
  }

  Widget _buildStatusHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(statusMessage.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: isUnmatched ? Colors.red : Colors.indigo)),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.orange[50], borderRadius: BorderRadius.circular(20)),
      child: Column(children: [
        Icon(Icons.warning_amber_rounded, color: Colors.orange[400], size: 48),
        const SizedBox(height: 12),
        const Text("No Reliable Match Found", style: TextStyle(fontWeight: FontWeight.bold)),
        const Text("Try clearer photos or manual entry.", textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
      ]),
    );
  }

  Widget _buildHandle() => Container(margin: const EdgeInsets.only(top: 12), height: 5, width: 40, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)));
}
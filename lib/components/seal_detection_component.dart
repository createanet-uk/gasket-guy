// // // // import 'dart:io';
// // // // import 'package:flutter/material.dart';
// // // // import 'package:flutter/services.dart';
// // // // import 'package:image_picker/image_picker.dart';
// // // // import 'package:tflite_flutter/tflite_flutter.dart';
// // // // import 'package:image/image.dart' as img;
// // // // import 'package:path_provider/path_provider.dart';
// // // // import 'package:shared_preferences/shared_preferences.dart';
// // // // import '../home_page.dart';
// // // // import '../theme.dart';
// // // //
// // // // // Model to return to the AddAssetPage
// // // // class SealDetectionResult {
// // // //   final String label;
// // // //   final double confidence;
// // // //   final List<File> images;
// // // //
// // // //   SealDetectionResult({
// // // //     required this.label,
// // // //     required this.confidence,
// // // //     required this.images,
// // // //   });
// // // // }
// // // //
// // // // class SealDetectionComponent extends StatefulWidget {
// // // //   const SealDetectionComponent({super.key});
// // // //
// // // //   @override
// // // //   State<SealDetectionComponent> createState() => _SealDetectionComponentState();
// // // // }
// // // //
// // // // class _SealDetectionComponentState extends State<SealDetectionComponent> {
// // // //   List<File> imageFiles = [];
// // // //   List<PredictionResult> topPredictions = [];
// // // //   PredictionResult? selectedResult; // Track which result the engineer tapped
// // // //
// // // //   String statusMessage = "Add images to start analysis";
// // // //   bool isBusy = false;
// // // //   bool isModelLoaded = false;
// // // //   bool isInitializing = false;
// // // //   bool isUnmatched = false;
// // // //
// // // //   Interpreter? interpreter;
// // // //   List<String> labels = [];
// // // //   List<int>? inputShape;
// // // //   final int maxImageLimit = 5;
// // // //   final double matchThreshold = 0.50;
// // // //
// // // //   @override
// // // //   void initState() {
// // // //     super.initState();
// // // //     _initApp();
// // // //   }
// // // //
// // // //   Future<void> _initApp() async {
// // // //     setState(() {
// // // //       isInitializing = true;
// // // //       statusMessage = "Loading AI Model...";
// // // //     });
// // // //     await _loadModelAndLabels();
// // // //     setState(() => isInitializing = false);
// // // //   }
// // // //
// // // //   Future<void> _loadModelAndLabels() async {
// // // //     try {
// // // //       final prefs = await SharedPreferences.getInstance();
// // // //       final String? savedModelPath = prefs.getString('current_model_path');
// // // //       final String? savedLabelsPath = prefs.getString('current_labels_path');
// // // //
// // // //       // Load Labels
// // // //       if (savedLabelsPath != null && File(savedLabelsPath).existsSync()) {
// // // //         final data = await File(savedLabelsPath).readAsString();
// // // //         labels = data.split('\n').where((e) => e.trim().isNotEmpty).toList();
// // // //       } else {
// // // //         final data = await rootBundle.loadString('assets/model1/labels.txt');
// // // //         labels = data.split('\n').where((e) => e.trim().isNotEmpty).toList();
// // // //       }
// // // //
// // // //       // Load Model
// // // //       if (savedModelPath != null && File(savedModelPath).existsSync()) {
// // // //         interpreter = await Interpreter.fromFile(File(savedModelPath));
// // // //       } else {
// // // //         interpreter = await Interpreter.fromAsset('assets/model1/model.tflite');
// // // //       }
// // // //
// // // //       if (interpreter != null) {
// // // //         inputShape = interpreter!.getInputTensor(0).shape;
// // // //         setState(() {
// // // //           isModelLoaded = true;
// // // //           statusMessage = "AI System Ready";
// // // //         });
// // // //       }
// // // //     } catch (e) {
// // // //       setState(() => statusMessage = "Model Load Error");
// // // //     }
// // // //   }
// // // //
// // // //   Future<void> _runInference() async {
// // // //     if (imageFiles.isEmpty || !isModelLoaded) return;
// // // //     setState(() {
// // // //       isBusy = true;
// // // //       statusMessage = "Analyzing profile geometry...";
// // // //       topPredictions = [];
// // // //       selectedResult = null;
// // // //     });
// // // //
// // // //     try {
// // // //       List<List<double>> allScores = [];
// // // //       for (var file in imageFiles) {
// // // //         final bytes = await file.readAsBytes();
// // // //         img.Image? image = img.decodeImage(bytes);
// // // //         if (image == null) continue;
// // // //
// // // //         int h = inputShape![1];
// // // //         int w = inputShape![2];
// // // //         img.Image resized = img.copyResize(image, width: w, height: h);
// // // //
// // // //         var input = List.generate(1, (_) => List.generate(h, (y) => List.generate(w, (x) {
// // // //           final pixel = resized.getPixel(x, y);
// // // //           return [pixel.r.toDouble(), pixel.g.toDouble(), pixel.b.toDouble()];
// // // //         })));
// // // //
// // // //         var output = List.generate(1, (_) => List.filled(labels.length, 0.0));
// // // //         interpreter!.run(input, output);
// // // //         allScores.add(List<double>.from(output[0]));
// // // //       }
// // // //
// // // //       // Average scores
// // // //       List<double> avg = List.filled(labels.length, 0.0);
// // // //       for (int i = 0; i < labels.length; i++) {
// // // //         double sum = 0;
// // // //         for (var score in allScores) sum += score[i];
// // // //         avg[i] = sum / allScores.length;
// // // //       }
// // // //
// // // //       List<PredictionResult> res = [];
// // // //       for (int i = 0; i < labels.length; i++) {
// // // //         res.add(PredictionResult(labels[i], avg[i]));
// // // //       }
// // // //       res.sort((a, b) => b.confidence.compareTo(a.confidence));
// // // //
// // // //       setState(() {
// // // //         isBusy = false;
// // // //         if (res.isEmpty || res[0].confidence < matchThreshold) {
// // // //           isUnmatched = true;
// // // //           statusMessage = "No Match Found";
// // // //         } else {
// // // //           isUnmatched = false;
// // // //           statusMessage = "Select the correct seal below";
// // // //           topPredictions = res.take(3).toList();
// // // //           selectedResult = topPredictions[0]; // Auto-select top one
// // // //         }
// // // //       });
// // // //     } catch (e) {
// // // //       setState(() {
// // // //         isBusy = false;
// // // //         statusMessage = "Analysis Failed";
// // // //       });
// // // //     }
// // // //   }
// // // //
// // // //   void _confirmSelection() {
// // // //     if (selectedResult == null) return;
// // // //
// // // //     // Pass back the data to the AddAssetPage
// // // //     Navigator.pop(context, SealDetectionResult(
// // // //       label: selectedResult!.label,
// // // //       confidence: selectedResult!.confidence,
// // // //       images: List.from(imageFiles),
// // // //     ));
// // // //   }
// // // //
// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return Container(
// // // //       height: MediaQuery.of(context).size.height * 0.85,
// // // //       decoration: const BoxDecoration(
// // // //         color: Colors.white,
// // // //         borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
// // // //       ),
// // // //       child: Column(
// // // //         children: [
// // // //           _buildHandle(),
// // // //           Expanded(
// // // //             child: SingleChildScrollView(
// // // //               padding: const EdgeInsets.all(24),
// // // //               child: Column(
// // // //                 crossAxisAlignment: CrossAxisAlignment.stretch,
// // // //                 children: [
// // // //                   _buildImageGallery(),
// // // //                   const SizedBox(height: 16),
// // // //                   _buildStatusHeader(),
// // // //                   if (isBusy || isInitializing)
// // // //                     const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
// // // //                   else if (isUnmatched)
// // // //                     _buildErrorCard()
// // // //                   else if (topPredictions.isNotEmpty)
// // // //                       ...topPredictions.map((res) => _buildSelectableResult(res)),
// // // //                   const SizedBox(height: 32),
// // // //                 ],
// // // //               ),
// // // //             ),
// // // //           ),
// // // //           _buildBottomActions(),
// // // //         ],
// // // //       ),
// // // //     );
// // // //   }
// // // //
// // // //   Widget _buildSelectableResult(PredictionResult res) {
// // // //     bool isSelected = selectedResult?.label == res.label;
// // // //     return GestureDetector(
// // // //       onTap: () => setState(() => selectedResult = res),
// // // //       child: Card(
// // // //         margin: const EdgeInsets.only(bottom: 12),
// // // //         shape: RoundedRectangleBorder(
// // // //           borderRadius: BorderRadius.circular(16),
// // // //           side: BorderSide(color: isSelected ? AppTheme.primary : Colors.grey[200]!, width: isSelected ? 2 : 1),
// // // //         ),
// // // //         color: isSelected ? AppTheme.primary.withOpacity(0.05) : Colors.white,
// // // //         child: ListTile(
// // // //           leading: Icon(isSelected ? Icons.check_circle : Icons.circle_outlined, color: isSelected ? AppTheme.primary : Colors.grey),
// // // //           title: Text(res.label, style: const TextStyle(fontWeight: FontWeight.bold)),
// // // //           trailing: Text("${(res.confidence * 100).toStringAsFixed(1)}%"),
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }
// // // //
// // // //   Widget _buildBottomActions() {
// // // //     return Padding(
// // // //       padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
// // // //       child: Column(
// // // //         children: [
// // // //           if (imageFiles.length < maxImageLimit && !isBusy)
// // // //             Row(children: [
// // // //               Expanded(child: ElevatedButton.icon(onPressed: () => _addImage(ImageSource.camera), icon: const Icon(Icons.add_a_photo), label: const Text("Capture"), style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white))),
// // // //               const SizedBox(width: 12),
// // // //               Expanded(child: OutlinedButton.icon(onPressed: () => _addImage(ImageSource.gallery), icon: const Icon(Icons.add_photo_alternate), label: const Text("Gallery"))),
// // // //             ]),
// // // //           const SizedBox(height: 12),
// // // //           if (imageFiles.isNotEmpty && !isBusy)
// // // //             SizedBox(
// // // //               width: double.infinity,
// // // //               child: ElevatedButton(
// // // //                 onPressed: selectedResult != null ? _confirmSelection : _runInference,
// // // //                 style: ElevatedButton.styleFrom(
// // // //                   backgroundColor: selectedResult != null ? Colors.green[700] : AppTheme.primary,
// // // //                   foregroundColor: Colors.white,
// // // //                   padding: const EdgeInsets.symmetric(vertical: 16),
// // // //                 ),
// // // //                 child: Text(selectedResult != null ? "CONFIRM SELECTION" : "VERIFY PROFILES"),
// // // //               ),
// // // //             ),
// // // //         ],
// // // //       ),
// // // //     );
// // // //   }
// // // //
// // // //   // Reuse your buildStatusHeader, buildImageGallery, buildErrorCard, and addImage methods here...
// // // //   // [Truncated for brevity, but keep logic from your original code]
// // // //
// // // //   Widget _buildHandle() => Container(margin: const EdgeInsets.only(top: 12), height: 5, width: 40, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)));
// // // //
// // // //
// // // //   void _addImage(ImageSource source) async { /* Same as your original code logic */ }
// // // //
// // // //   _buildImageGallery() {}
// // // //
// // // //   _buildErrorCard() {}
// // // //
// // // //   _buildStatusHeader() {}
// // // // }
// // //
// // //
// // // import 'dart:io';
// // // import 'package:flutter/material.dart';
// // // import 'package:flutter/services.dart';
// // // import 'package:image_picker/image_picker.dart';
// // // import 'package:tflite_flutter/tflite_flutter.dart';
// // // import 'package:image/image.dart' as img;
// // // import 'package:path_provider/path_provider.dart';
// // // import 'package:shared_preferences/shared_preferences.dart';
// // // import '../theme.dart';
// // //
// // // // Prediction Result internal model
// // // class PredictionResult {
// // //   final String label;
// // //   final double confidence;
// // //   PredictionResult(this.label, this.confidence);
// // // }
// // //
// // // // Data model returned to the AddAssetPage
// // // class SealDetectionResult {
// // //   final String label;
// // //   final double confidence;
// // //   final List<File> images;
// // //
// // //   SealDetectionResult({
// // //     required this.label,
// // //     required this.confidence,
// // //     required this.images,
// // //   });
// // // }
// // //
// // // class SealDetectionComponent extends StatefulWidget {
// // //   const SealDetectionComponent({super.key});
// // //
// // //   @override
// // //   State<SealDetectionComponent> createState() => _SealDetectionComponentState();
// // // }
// // //
// // // class _SealDetectionComponentState extends State<SealDetectionComponent> {
// // //   List<File> imageFiles = [];
// // //   List<PredictionResult> topPredictions = [];
// // //   PredictionResult? selectedResult;
// // //
// // //   String statusMessage = "Add images to start analysis";
// // //   bool isBusy = false;
// // //   bool isModelLoaded = false;
// // //   bool isInitializing = false;
// // //   bool isUnmatched = false;
// // //
// // //   Interpreter? interpreter;
// // //   List<String> labels = [];
// // //   List<int>? inputShape;
// // //   TensorType? inputType;
// // //
// // //   final int maxImageLimit = 5;
// // //   final double matchThreshold = 0.50;
// // //
// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     _initApp();
// // //   }
// // //
// // //   Future<void> _initApp() async {
// // //     setState(() {
// // //       isInitializing = true;
// // //       statusMessage = "Loading AI Model...";
// // //     });
// // //     await _loadModelAndLabels();
// // //     setState(() => isInitializing = false);
// // //   }
// // //
// // //   Future<void> _loadModelAndLabels() async {
// // //     try {
// // //       final prefs = await SharedPreferences.getInstance();
// // //       final String? savedModelPath = prefs.getString('current_model_path');
// // //       final String? savedLabelsPath = prefs.getString('current_labels_path');
// // //
// // //       // 1. Load Labels
// // //       if (savedLabelsPath != null && File(savedLabelsPath).existsSync()) {
// // //         final data = await File(savedLabelsPath).readAsString();
// // //         labels = data.split('\n').where((e) => e.trim().isNotEmpty).toList();
// // //       } else {
// // //         final data = await rootBundle.loadString('assets/model1/labels.txt');
// // //         labels = data.split('\n').where((e) => e.trim().isNotEmpty).toList();
// // //       }
// // //
// // //       // 2. Load Model
// // //       if (savedModelPath != null && File(savedModelPath).existsSync()) {
// // //         interpreter = await Interpreter.fromFile(File(savedModelPath));
// // //       } else {
// // //         interpreter = await Interpreter.fromAsset('assets/model1/model.tflite');
// // //       }
// // //
// // //       if (interpreter != null) {
// // //         inputShape = interpreter!.getInputTensor(0).shape;
// // //         inputType = interpreter!.getInputTensor(0).type;
// // //         setState(() {
// // //           isModelLoaded = true;
// // //           statusMessage = "AI System Ready";
// // //         });
// // //       }
// // //     } catch (e) {
// // //       setState(() => statusMessage = "Model Load Error");
// // //     }
// // //   }
// // //
// // //   Future<void> _runInference() async {
// // //     if (imageFiles.isEmpty || !isModelLoaded) return;
// // //     setState(() {
// // //       isBusy = true;
// // //       statusMessage = "Analyzing profile geometry...";
// // //       topPredictions = [];
// // //       selectedResult = null;
// // //     });
// // //
// // //     try {
// // //       List<List<double>> allScores = [];
// // //       for (var file in imageFiles) {
// // //         final bytes = await file.readAsBytes();
// // //         img.Image? image = img.decodeImage(bytes);
// // //         if (image == null) continue;
// // //
// // //         int h = inputShape![1];
// // //         int w = inputShape![2];
// // //         img.Image resized = img.copyResize(image, width: w, height: h);
// // //
// // //         var input = List.generate(1, (_) => List.generate(h, (y) => List.generate(w, (x) {
// // //           final pixel = resized.getPixel(x, y);
// // //           return [pixel.r.toDouble(), pixel.g.toDouble(), pixel.b.toDouble()];
// // //         })));
// // //
// // //         var output = List.generate(1, (_) => List.filled(labels.length, 0.0));
// // //         interpreter!.run(input, output);
// // //         allScores.add(List<double>.from(output[0]));
// // //       }
// // //
// // //       // Average scores
// // //       List<double> avg = List.filled(labels.length, 0.0);
// // //       for (int i = 0; i < labels.length; i++) {
// // //         double sum = 0;
// // //         for (var score in allScores) sum += score[i];
// // //         avg[i] = sum / allScores.length;
// // //       }
// // //
// // //       List<PredictionResult> res = [];
// // //       for (int i = 0; i < labels.length; i++) {
// // //         res.add(PredictionResult(labels[i], avg[i]));
// // //       }
// // //       res.sort((a, b) => b.confidence.compareTo(a.confidence));
// // //
// // //       setState(() {
// // //         isBusy = false;
// // //         bool hasClearGap = res.length > 1 ? (res[0].confidence - res[1].confidence) > 0.12 : true;
// // //
// // //         if (res.isEmpty || res[0].confidence < matchThreshold || !hasClearGap) {
// // //           isUnmatched = true;
// // //           statusMessage = "Data Not Matched";
// // //         } else {
// // //           isUnmatched = false;
// // //           statusMessage = "Select the correct seal below";
// // //           topPredictions = res.take(3).toList();
// // //           selectedResult = topPredictions[0];
// // //         }
// // //       });
// // //     } catch (e) {
// // //       setState(() {
// // //         isBusy = false;
// // //         statusMessage = "Analysis Failed";
// // //       });
// // //     }
// // //   }
// // //
// // //   void _confirmSelection() {
// // //     if (selectedResult == null) return;
// // //     Navigator.pop(context, SealDetectionResult(
// // //       label: selectedResult!.label,
// // //       confidence: selectedResult!.confidence,
// // //       images: List.from(imageFiles),
// // //     ));
// // //   }
// // //
// // //   void _addImage(ImageSource source) async {
// // //     if (imageFiles.length >= maxImageLimit) {
// // //       _showLimitWarning(maxImageLimit, 0);
// // //       return;
// // //     }
// // //
// // //     final picker = ImagePicker();
// // //     if (source == ImageSource.gallery) {
// // //       int remaining = maxImageLimit - imageFiles.length;
// // //       final List<XFile> picked = await picker.pickMultiImage();
// // //       if (picked.isEmpty) return;
// // //
// // //       setState(() {
// // //         if (picked.length > remaining) _showLimitWarning(picked.length, remaining);
// // //         imageFiles.addAll(picked.take(remaining).map((x) => File(x.path)));
// // //         _resetStatus();
// // //       });
// // //     } else {
// // //       final picked = await picker.pickImage(source: ImageSource.camera);
// // //       if (picked != null) {
// // //         setState(() {
// // //           imageFiles.add(File(picked.path));
// // //           _resetStatus();
// // //         });
// // //       }
// // //     }
// // //   }
// // //
// // //   void _resetStatus() {
// // //     isUnmatched = false;
// // //     topPredictions = [];
// // //     selectedResult = null;
// // //     statusMessage = "${imageFiles.length} profiles ready for analysis";
// // //   }
// // //
// // //   void _showLimitWarning(int attempted, int allowed) {
// // //     showDialog(
// // //       context: context,
// // //       builder: (context) => AlertDialog(
// // //         title: const Text("Limit Warning"),
// // //         content: Text("Maximum $maxImageLimit images allowed."),
// // //         actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))],
// // //       ),
// // //     );
// // //   }
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Container(
// // //       height: MediaQuery.of(context).size.height * 0.85,
// // //       decoration: const BoxDecoration(
// // //         color: Colors.white,
// // //         borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
// // //       ),
// // //       child: Column(
// // //         children: [
// // //           _buildHandle(),
// // //           Expanded(
// // //             child: SingleChildScrollView(
// // //               padding: const EdgeInsets.all(24),
// // //               child: Column(
// // //                 crossAxisAlignment: CrossAxisAlignment.stretch,
// // //                 children: [
// // //                   _buildImageGallery(),
// // //                   const SizedBox(height: 16),
// // //                   _buildStatusHeader(),
// // //                   if (isBusy || isInitializing)
// // //                     const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
// // //                   else if (isUnmatched)
// // //                     _buildErrorCard()
// // //                   else if (topPredictions.isNotEmpty)
// // //                       ...topPredictions.asMap().entries.map((e) => _buildSelectableResult(e.value)),
// // //                   const SizedBox(height: 32),
// // //                 ],
// // //               ),
// // //             ),
// // //           ),
// // //           _buildBottomActions(),
// // //         ],
// // //       ),
// // //     );
// // //   }
// // //
// // //   Widget _buildSelectableResult(PredictionResult res) {
// // //     bool isSelected = selectedResult?.label == res.label;
// // //     return GestureDetector(
// // //       onTap: () => setState(() => selectedResult = res),
// // //       child: Card(
// // //         margin: const EdgeInsets.only(bottom: 12),
// // //         shape: RoundedRectangleBorder(
// // //           borderRadius: BorderRadius.circular(16),
// // //           side: BorderSide(color: isSelected ? AppTheme.primary : Colors.grey[200]!, width: isSelected ? 2 : 1),
// // //         ),
// // //         color: isSelected ? AppTheme.primary.withOpacity(0.05) : Colors.white,
// // //         child: ListTile(
// // //           leading: Icon(isSelected ? Icons.check_circle : Icons.circle_outlined, color: isSelected ? AppTheme.primary : Colors.grey),
// // //           title: Text(res.label, style: const TextStyle(fontWeight: FontWeight.bold)),
// // //           trailing: Text("${(res.confidence * 100).toStringAsFixed(1)}%"),
// // //         ),
// // //       ),
// // //     );
// // //   }
// // //
// // //   Widget _buildBottomActions() {
// // //     return Padding(
// // //       padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
// // //       child: Column(
// // //         children: [
// // //           if (imageFiles.length < maxImageLimit && !isBusy)
// // //             Row(children: [
// // //               Expanded(child: ElevatedButton.icon(onPressed: () => _addImage(ImageSource.camera), icon: const Icon(Icons.add_a_photo), label: const Text("Capture"), style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)))),
// // //               const SizedBox(width: 12),
// // //               Expanded(child: OutlinedButton.icon(onPressed: () => _addImage(ImageSource.gallery), icon: const Icon(Icons.add_photo_alternate), label: const Text("Gallery"), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)))),
// // //             ]),
// // //           const SizedBox(height: 12),
// // //           if (imageFiles.isNotEmpty && !isBusy)
// // //             SizedBox(
// // //               width: double.infinity,
// // //               child: ElevatedButton(
// // //                 onPressed: selectedResult != null ? _confirmSelection : (isModelLoaded ? _runInference : null),
// // //                 style: ElevatedButton.styleFrom(
// // //                   backgroundColor: selectedResult != null ? Colors.green[700] : AppTheme.primary,
// // //                   foregroundColor: Colors.white,
// // //                   padding: const EdgeInsets.symmetric(vertical: 20),
// // //                 ),
// // //                 child: Text(selectedResult != null ? "CONFIRM SELECTION" : "VERIFY PROFILES"),
// // //               ),
// // //             ),
// // //         ],
// // //       ),
// // //     );
// // //   }
// // //
// // //   Widget _buildImageGallery() {
// // //     return SizedBox(
// // //       height: 120,
// // //       child: imageFiles.isEmpty
// // //           ? Container(
// // //         decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(20)),
// // //         child: const Center(child: Text("No profiles added yet", style: TextStyle(color: Colors.grey))),
// // //       )
// // //           : ListView.separated(
// // //         scrollDirection: Axis.horizontal,
// // //         itemCount: imageFiles.length,
// // //         separatorBuilder: (_, __) => const SizedBox(width: 12),
// // //         itemBuilder: (context, index) {
// // //           return Stack(children: [
// // //             Container(width: 120, decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), image: DecorationImage(image: FileImage(imageFiles[index]), fit: BoxFit.cover))),
// // //             Positioned(top: 4, right: 4, child: GestureDetector(onTap: () => setState(() => imageFiles.removeAt(index)), child: Container(padding: const EdgeInsets.all(2), decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle), child: const Icon(Icons.close, color: Colors.white, size: 18)))),
// // //           ]);
// // //         },
// // //       ),
// // //     );
// // //   }
// // //
// // //   Widget _buildStatusHeader() {
// // //     return Padding(
// // //       padding: const EdgeInsets.symmetric(vertical: 8.0),
// // //       child: Text(statusMessage.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: isUnmatched ? Colors.red : Colors.indigo)),
// // //     );
// // //   }
// // //
// // //   Widget _buildErrorCard() {
// // //     return Container(
// // //       padding: const EdgeInsets.all(24),
// // //       decoration: BoxDecoration(color: Colors.orange[50], borderRadius: BorderRadius.circular(20)),
// // //       child: Column(children: [
// // //         Icon(Icons.warning_amber_rounded, color: Colors.orange[400], size: 48),
// // //         const SizedBox(height: 12),
// // //         const Text("No Reliable Match Found", style: TextStyle(fontWeight: FontWeight.bold)),
// // //         const Text("Try clearer photos or manual entry.", textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
// // //       ]),
// // //     );
// // //   }
// // //
// // //   Widget _buildHandle() => Container(margin: const EdgeInsets.only(top: 12), height: 5, width: 40, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)));
// // // }
// //
// //
// // import 'dart:io';
// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:image_picker/image_picker.dart';
// // import 'package:tflite_flutter/tflite_flutter.dart';
// // import 'package:image/image.dart' as img;
// // import 'package:shared_preferences/shared_preferences.dart';
// // import '../theme.dart';
// //
// // // --- CRITICAL FIX 1: MOVE THIS OUTSIDE THE STATE CLASS ---
// // // This ensures other pages can see the class definition during compilation.
// // class SealDetectionResult {
// //   final String label;
// //   final double confidence;
// //   final List<File> images;
// //
// //   SealDetectionResult({
// //     required this.label,
// //     required this.confidence,
// //     required this.images,
// //   });
// // }
// //
// // class PredictionResult {
// //   final String label;
// //   final double confidence;
// //   PredictionResult(this.label, this.confidence);
// // }
// //
// // class SealDetectionComponent extends StatefulWidget {
// //   const SealDetectionComponent({super.key});
// //
// //   @override
// //   State<SealDetectionComponent> createState() => _SealDetectionComponentState();
// // }
// //
// // class _SealDetectionComponentState extends State<SealDetectionComponent> {
// //   List<File> imageFiles = [];
// //   List<PredictionResult> topPredictions = [];
// //   PredictionResult? selectedResult;
// //
// //   String statusMessage = "Add images to start analysis";
// //   bool isBusy = false;
// //   bool isModelLoaded = false;
// //   bool isInitializing = false;
// //   bool isUnmatched = false;
// //
// //   Interpreter? interpreter;
// //   List<String> labels = [];
// //   List<int>? inputShape;
// //
// //   final int maxImageLimit = 5;
// //   final double matchThreshold = 0.50;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _initApp();
// //   }
// //
// //   // --- CRITICAL FIX 2: PROPER CLEANUP ---
// //   @override
// //   void dispose() {
// //     interpreter?.close();
// //     super.dispose();
// //   }
// //
// //   Future<void> _initApp() async {
// //     if (!mounted) return;
// //     setState(() {
// //       isInitializing = true;
// //       statusMessage = "Loading AI Model...";
// //     });
// //     await _loadModelAndLabels();
// //     if (mounted) setState(() => isInitializing = false);
// //   }
// //
// //   Future<void> _loadModelAndLabels() async {
// //     try {
// //       final prefs = await SharedPreferences.getInstance();
// //       final String? savedModelPath = prefs.getString('current_model_path');
// //       final String? savedLabelsPath = prefs.getString('current_labels_path');
// //
// //       // Load Labels
// //       if (savedLabelsPath != null && File(savedLabelsPath).existsSync()) {
// //         final data = await File(savedLabelsPath).readAsString();
// //         labels = data.split('\n').where((e) => e.trim().isNotEmpty).toList();
// //       } else {
// //         final data = await rootBundle.loadString('assets/model1/labels.txt');
// //         labels = data.split('\n').where((e) => e.trim().isNotEmpty).toList();
// //       }
// //
// //       // Load Model
// //       if (savedModelPath != null && File(savedModelPath).existsSync()) {
// //         interpreter = await Interpreter.fromFile(File(savedModelPath));
// //       } else {
// //         interpreter = await Interpreter.fromAsset('assets/model1/model.tflite');
// //       }
// //
// //       if (interpreter != null) {
// //         inputShape = interpreter!.getInputTensor(0).shape;
// //         if (mounted) {
// //           setState(() {
// //             isModelLoaded = true;
// //             statusMessage = "AI System Ready";
// //           });
// //         }
// //       }
// //     } catch (e) {
// //       if (mounted) setState(() => statusMessage = "Model Load Error");
// //     }
// //   }
// //
// //   Future<void> _runInference() async {
// //     if (imageFiles.isEmpty || !isModelLoaded) return;
// //     setState(() {
// //       isBusy = true;
// //       statusMessage = "Analyzing profile geometry...";
// //     });
// //
// //     try {
// //       List<List<double>> allScores = [];
// //       for (var file in imageFiles) {
// //         final bytes = await file.readAsBytes();
// //         img.Image? originalImage = img.decodeImage(bytes);
// //         if (originalImage == null) continue;
// //
// //         int h = inputShape![1];
// //         int w = inputShape![2];
// //
// //         // --- CRITICAL FIX 3: PIXEL NORMALIZATION ---
// //         // Most TFLite models expect 0.0 - 1.0 or -1.0 - 1.0, not 0-255.
// //         img.Image resized = img.copyResize(originalImage, width: w, height: h);
// //
// //         var input = List.generate(1, (_) => List.generate(h, (y) => List.generate(w, (x) {
// //           final pixel = resized.getPixel(x, y);
// //           // Normalizing to 0.0 - 1.0 (Check your model requirements)
// //           return [pixel.r / 255.0, pixel.g / 255.0, pixel.b / 255.0];
// //         })));
// //
// //         var output = List.generate(1, (_) => List.filled(labels.length, 0.0));
// //         interpreter!.run(input, output);
// //         allScores.add(List<double>.from(output[0]));
// //       }
// //
// //       // Average scores logic
// //       List<double> avg = List.filled(labels.length, 0.0);
// //       for (int i = 0; i < labels.length; i++) {
// //         double sum = 0;
// //         for (var score in allScores) sum += score[i];
// //         avg[i] = sum / allScores.length;
// //       }
// //
// //       List<PredictionResult> res = [];
// //       for (int i = 0; i < labels.length; i++) {
// //         res.add(PredictionResult(labels[i], avg[i]));
// //       }
// //       res.sort((a, b) => b.confidence.compareTo(a.confidence));
// //
// //       if (mounted) {
// //         setState(() {
// //           isBusy = false;
// //           if (res.isEmpty || res[0].confidence < matchThreshold) {
// //             isUnmatched = true;
// //             statusMessage = "No Match Found";
// //           } else {
// //             isUnmatched = false;
// //             statusMessage = "Select the correct seal";
// //             topPredictions = res.take(3).toList();
// //             selectedResult = topPredictions[0];
// //           }
// //         });
// //       }
// //     } catch (e) {
// //       if (mounted) setState(() { isBusy = false; statusMessage = "Inference Error"; });
// //     }
// //   }
// //
// //   void _confirmSelection() {
// //     if (selectedResult == null) return;
// //     Navigator.pop(context, SealDetectionResult(
// //       label: selectedResult!.label,
// //       confidence: selectedResult!.confidence,
// //       images: List.from(imageFiles),
// //     ));
// //   }
// //
// //   void _addImage(ImageSource source) async {
// //     final picker = ImagePicker();
// //     if (source == ImageSource.gallery) {
// //       final List<XFile> picked = await picker.pickMultiImage();
// //       if (picked.isNotEmpty) {
// //         setState(() {
// //           imageFiles.addAll(picked.map((x) => File(x.path)));
// //           if (imageFiles.length > maxImageLimit) imageFiles = imageFiles.sublist(0, maxImageLimit);
// //           _resetStatus();
// //         });
// //       }
// //     } else {
// //       final XFile? picked = await picker.pickImage(source: ImageSource.camera);
// //       if (picked != null) {
// //         setState(() {
// //           imageFiles.add(File(picked.path));
// //           _resetStatus();
// //         });
// //       }
// //     }
// //   }
// //
// //   void _resetStatus() {
// //     isUnmatched = false;
// //     topPredictions = [];
// //     selectedResult = null;
// //     statusMessage = "${imageFiles.length} images added";
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       height: MediaQuery.of(context).size.height * 0.85,
// //       padding: const EdgeInsets.symmetric(horizontal: 20),
// //       decoration: const BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
// //       ),
// //       child: Column(
// //         children: [
// //           _buildHandle(),
// //           const SizedBox(height: 20),
// //           _buildImageGallery(),
// //           const SizedBox(height: 16),
// //           _buildStatusHeader(),
// //           const Divider(),
// //           Expanded(
// //             child: isBusy
// //                 ? const Center(child: CircularProgressIndicator())
// //                 : _buildMainContent(),
// //           ),
// //           _buildBottomActions(),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildMainContent() {
// //     if (isUnmatched) return _buildErrorCard();
// //     if (topPredictions.isNotEmpty) {
// //       return ListView(
// //         children: topPredictions.map((res) => _buildSelectableResult(res)).toList(),
// //       );
// //     }
// //     return const Center(child: Text("Add profile photos to begin analysis", style: TextStyle(color: Colors.grey)));
// //   }
// //
// //   Widget _buildSelectableResult(PredictionResult res) {
// //     bool isSelected = selectedResult?.label == res.label;
// //     return GestureDetector(
// //       onTap: () => setState(() => selectedResult = res),
// //       child: Card(
// //         elevation: 0,
// //         margin: const EdgeInsets.only(bottom: 12),
// //         shape: RoundedRectangleBorder(
// //           borderRadius: BorderRadius.circular(16),
// //           side: BorderSide(color: isSelected ? AppTheme.primary : Colors.grey[200]!, width: 2),
// //         ),
// //         color: isSelected ? AppTheme.primary.withOpacity(0.05) : Colors.white,
// //         child: ListTile(
// //           leading: Icon(isSelected ? Icons.check_circle : Icons.circle_outlined, color: isSelected ? AppTheme.primary : Colors.grey),
// //           title: Text(res.label, style: const TextStyle(fontWeight: FontWeight.bold)),
// //           trailing: Text("${(res.confidence * 100).toStringAsFixed(1)}%"),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildBottomActions() {
// //     return Padding(
// //       padding: const EdgeInsets.only(bottom: 24, top: 10),
// //       child: Column(
// //         children: [
// //           if (imageFiles.length < maxImageLimit && !isBusy)
// //             Row(children: [
// //               Expanded(child: ElevatedButton.icon(onPressed: () => _addImage(ImageSource.camera), icon: const Icon(Icons.camera_alt), label: const Text("Camera"))),
// //               const SizedBox(width: 12),
// //               Expanded(child: OutlinedButton.icon(onPressed: () => _addImage(ImageSource.gallery), icon: const Icon(Icons.photo_library), label: const Text("Gallery"))),
// //             ]),
// //           const SizedBox(height: 12),
// //           if (imageFiles.isNotEmpty)
// //             SizedBox(
// //               width: double.infinity,
// //               child: ElevatedButton(
// //                 onPressed: selectedResult != null ? _confirmSelection : _runInference,
// //                 style: ElevatedButton.styleFrom(
// //                   backgroundColor: selectedResult != null ? Colors.green : AppTheme.primary,
// //                   padding: const EdgeInsets.symmetric(vertical: 16),
// //                 ),
// //                 child: Text(selectedResult != null ? "CONFIRM" : "RUN AI ANALYSIS"),
// //               ),
// //             ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildImageGallery() {
// //     return SizedBox(
// //       height: 100,
// //       child: ListView.builder(
// //         scrollDirection: Axis.horizontal,
// //         itemCount: imageFiles.length,
// //         itemBuilder: (context, index) => Stack(
// //           children: [
// //             Container(
// //               width: 100, margin: const EdgeInsets.only(right: 8),
// //               decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), image: DecorationImage(image: FileImage(imageFiles[index]), fit: BoxFit.cover)),
// //             ),
// //             Positioned(right: 12, top: 4, child: GestureDetector(onTap: () => setState(() => imageFiles.removeAt(index)), child: const CircleAvatar(radius: 10, backgroundColor: Colors.red, child: Icon(Icons.close, size: 12, color: Colors.white)))),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildStatusHeader() => Text(statusMessage.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.1));
// //
// //   Widget _buildErrorCard() => Column(mainAxisAlignment: MainAxisAlignment.center, children: const [Icon(Icons.warning, color: Colors.orange, size: 48), SizedBox(height: 12), Text("No exact match found. Try again with better lighting.")]);
// //
// //   Widget _buildHandle() => Container(margin: const EdgeInsets.only(top: 12), height: 5, width: 40, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)));
// // }
//
//
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:tflite_flutter/tflite_flutter.dart';
// import 'package:image/image.dart' as img;
// import 'package:shared_preferences/shared_preferences.dart';
// import '../theme.dart';
//
// /// --- DATA MODELS (Top level to prevent lookup errors) ---
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
// class PredictionResult {
//   final String label;
//   final double confidence;
//   PredictionResult(this.label, this.confidence);
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
//   PredictionResult? selectedResult;
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
//
//   final int maxImageLimit = 5;
//   final double matchThreshold = 0.50;
//
//   @override
//   void initState() {
//     super.initState();
//     _initApp();
//   }
//
//   @override
//   void dispose() {
//     interpreter?.close();
//     super.dispose();
//   }
//
//   Future<void> _initApp() async {
//     setState(() {
//       isInitializing = true;
//       statusMessage = "Initializing AI...";
//     });
//     await _loadModelAndLabels();
//     if (mounted) setState(() => isInitializing = false);
//   }
//
//   Future<void> _loadModelAndLabels() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final String? savedModelPath = prefs.getString('current_model_path');
//       final String? savedLabelsPath = prefs.getString('current_labels_path');
//
//       if (savedLabelsPath != null && File(savedLabelsPath).existsSync()) {
//         final data = await File(savedLabelsPath).readAsString();
//         labels = data.split('\n').where((e) => e.trim().isNotEmpty).toList();
//       } else {
//         final data = await rootBundle.loadString('assets/model1/labels.txt');
//         labels = data.split('\n').where((e) => e.trim().isNotEmpty).toList();
//       }
//
//       if (savedModelPath != null && File(savedModelPath).existsSync()) {
//         interpreter = await Interpreter.fromFile(File(savedModelPath));
//       } else {
//         interpreter = await Interpreter.fromAsset('assets/model1/model.tflite');
//       }
//
//       if (interpreter != null) {
//         inputShape = interpreter!.getInputTensor(0).shape;
//         if (mounted) {
//           setState(() {
//             isModelLoaded = true;
//             statusMessage = "AI System Ready";
//           });
//         }
//       }
//     } catch (e) {
//       if (mounted) setState(() => statusMessage = "Model Load Error");
//     }
//   }
//
//   Future<void> _runInference() async {
//     if (imageFiles.isEmpty || !isModelLoaded) return;
//     setState(() {
//       isBusy = true;
//       statusMessage = "Analyzing Geometry...";
//     });
//
//     try {
//       List<List<double>> allScores = [];
//       for (var file in imageFiles) {
//         final bytes = await file.readAsBytes();
//         img.Image? originalImage = img.decodeImage(bytes);
//         if (originalImage == null) continue;
//
//         int h = inputShape![1];
//         int w = inputShape![2];
//         img.Image resized = img.copyResize(originalImage, width: w, height: h);
//
//         var input = List.generate(1, (_) => List.generate(h, (y) => List.generate(w, (x) {
//           final pixel = resized.getPixel(x, y);
//           return [pixel.r / 255.0, pixel.g / 255.0, pixel.b / 255.0];
//         })));
//
//         var output = List.generate(1, (_) => List.filled(labels.length, 0.0));
//         interpreter!.run(input, output);
//         allScores.add(List<double>.from(output[0]));
//       }
//
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
//       if (mounted) {
//         setState(() {
//           isBusy = false;
//           if (res.isEmpty || res[0].confidence < matchThreshold) {
//             isUnmatched = true;
//             statusMessage = "No Match Found";
//           } else {
//             isUnmatched = false;
//             statusMessage = "Verify Identification";
//             topPredictions = res.take(3).toList();
//             selectedResult = topPredictions[0];
//           }
//         });
//       }
//     } catch (e) {
//       if (mounted) setState(() { isBusy = false; statusMessage = "Analysis Failed"; });
//     }
//   }
//
//   void _confirmSelection() {
//     if (selectedResult == null) return;
//     Navigator.pop(context, SealDetectionResult(
//       label: selectedResult!.label,
//       confidence: selectedResult!.confidence,
//       images: List.from(imageFiles),
//     ));
//   }
//
//   void _addImage(ImageSource source) async {
//     final picker = ImagePicker();
//     if (source == ImageSource.gallery) {
//       final List<XFile> picked = await picker.pickMultiImage();
//       if (picked.isNotEmpty) {
//         setState(() {
//           imageFiles.addAll(picked.map((x) => File(x.path)));
//           if (imageFiles.length > maxImageLimit) imageFiles = imageFiles.sublist(0, maxImageLimit);
//           _resetStatus();
//         });
//       }
//     } else {
//       final XFile? picked = await picker.pickImage(source: source);
//       if (picked != null) {
//         setState(() {
//           imageFiles.add(File(picked.path));
//           _resetStatus();
//         });
//       }
//     }
//   }
//
//   void _resetStatus() {
//     isUnmatched = false;
//     topPredictions = [];
//     selectedResult = null;
//     statusMessage = "${imageFiles.length} photos ready";
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: MediaQuery.of(context).size.height * 0.9,
//       decoration: const BoxDecoration(
//         color: AppTheme.primaryBackground,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
//       ),
//       child: Column(
//         children: [
//           _buildHandle(),
//           const SizedBox(height: 10),
//           _buildHeader(),
//           Expanded(
//             child: SingleChildScrollView(
//               physics: const BouncingScrollPhysics(),
//               padding: const EdgeInsets.symmetric(horizontal: 20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   const SizedBox(height: 20),
//                   _buildImageGallery(),
//                   const SizedBox(height: 24),
//                   if (isBusy || isInitializing)
//                     _buildLoadingState()
//                   else if (isUnmatched)
//                     _buildErrorCard()
//                   else if (topPredictions.isNotEmpty)
//                       ...topPredictions.map((res) => _buildSelectableResult(res))
//                     else
//                       _buildEmptyState(),
//                   const SizedBox(height: 40),
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
//   Widget _buildHeader() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 24),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text("Seal Identifier", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
//               Text(statusMessage, style: TextStyle(color: isUnmatched ? Colors.red : AppTheme.primary, fontWeight: FontWeight.w600, fontSize: 13)),
//             ],
//           ),
//           IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_fullscreen_rounded, color: Colors.grey)),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildLoadingState() {
//     return Column(
//       children: [
//         const SizedBox(height: 60),
//         const CircularProgressIndicator(strokeWidth: 3),
//         const SizedBox(height: 20),
//         Text("AI is processing images...", style: TextStyle(color: Colors.grey[600])),
//       ],
//     );
//   }
//
//   Widget _buildEmptyState() {
//     return Container(
//       padding: const EdgeInsets.all(40),
//       decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey[200]!)),
//       child: Column(
//         children: [
//           Icon(Icons.photo_library_outlined, size: 48, color: Colors.grey[300]),
//           const SizedBox(height: 12),
//           const Text("No profile photos yet", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSelectableResult(PredictionResult res) {
//     bool isSelected = selectedResult?.label == res.label;
//     double percent = res.confidence * 100;
//
//     return GestureDetector(
//       onTap: () => setState(() => selectedResult = res),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         margin: const EdgeInsets.only(bottom: 16),
//         decoration: BoxDecoration(
//           color: isSelected ? AppTheme.primary.withOpacity(0.08) : Colors.white,
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(color: isSelected ? AppTheme.primary : Colors.grey[200]!, width: isSelected ? 2 : 1),
//           boxShadow: isSelected ? [BoxShadow(color: AppTheme.primary.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))] : [],
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(10),
//                 decoration: BoxDecoration(color: isSelected ? AppTheme.primary : Colors.grey[100], shape: BoxShape.circle),
//                 child: Icon(isSelected ? Icons.check : Icons.fingerprint, color: isSelected ? Colors.white : Colors.grey, size: 20),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(res.label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//                     const SizedBox(height: 4),
//                     LinearProgressIndicator(value: res.confidence, backgroundColor: Colors.grey[200], color: isSelected ? AppTheme.primary : Colors.blueGrey, minHeight: 4),
//                   ],
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Text("${percent.toStringAsFixed(1)}%", style: TextStyle(fontWeight: FontWeight.w900, color: isSelected ? AppTheme.primary : Colors.grey[600])),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildImageGallery() {
//     return SizedBox(
//       height: 120,
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         itemCount: imageFiles.length,
//         itemBuilder: (context, index) => Container(
//           width: 110,
//           margin: const EdgeInsets.only(right: 12),
//           child: Stack(
//             children: [
//               Positioned.fill(
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(16),
//                   child: Image.file(imageFiles[index], fit: BoxFit.cover),
//                 ),
//               ),
//               Positioned(
//                 top: 5, right: 5,
//                 child: GestureDetector(
//                   onTap: () => setState(() => imageFiles.removeAt(index)),
//                   child: Container(
//                     padding: const EdgeInsets.all(4),
//                     decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
//                     child: const Icon(Icons.close, size: 14, color: Colors.white),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildBottomActions() {
//     return Container(
//       padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
//       decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))]),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           if (imageFiles.length < maxImageLimit && !isBusy)
//             Row(children: [
//               Expanded(
//                 child: _actionButton(
//                   icon: Icons.camera_alt_rounded,
//                   label: "Camera",
//                   onPressed: () => _addImage(ImageSource.camera),
//                   isPrimary: false,
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: _actionButton(
//                   icon: Icons.photo_library_rounded,
//                   label: "Gallery",
//                   onPressed: () => _addImage(ImageSource.gallery),
//                   isPrimary: false,
//                 ),
//               ),
//             ]),
//           const SizedBox(height: 12),
//           if (imageFiles.isNotEmpty)
//             SizedBox(
//               width: double.infinity,
//               child: _actionButton(
//                 icon: selectedResult != null ? Icons.verified_user_rounded : Icons.analytics_rounded,
//                 label: selectedResult != null ? "CONFIRM SELECTION" : "RUN ANALYSIS",
//                 onPressed: selectedResult != null ? _confirmSelection : _runInference,
//                 isPrimary: true,
//                 color: selectedResult != null ? Colors.green[600] : AppTheme.primary,
//               ),
//             ),
//         ],
//       ),
//     );
//   }
//
//   Widget _actionButton({required IconData icon, required String label, required VoidCallback onPressed, bool isPrimary = true, Color? color}) {
//     return ElevatedButton.icon(
//       onPressed: onPressed,
//       icon: Icon(icon, size: 18),
//       label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
//       style: ElevatedButton.styleFrom(
//         backgroundColor: isPrimary ? (color ?? AppTheme.primary) : Colors.grey[100],
//         foregroundColor: isPrimary ? Colors.white : Colors.black87,
//         elevation: 0,
//         padding: const EdgeInsets.symmetric(vertical: 16),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       ),
//     );
//   }
//
//   Widget _buildErrorCard() {
//     return Container(
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.red[100]!)),
//       child: Column(
//         children: [
//           const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 40),
//           const SizedBox(height: 12),
//           const Text("No Reliable Match", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red)),
//           const SizedBox(height: 4),
//           Text("The AI couldn't find a strong match. Try different angles or lighting.", textAlign: TextAlign.center, style: TextStyle(color: Colors.red[900], fontSize: 12)),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildHandle() => Container(margin: const EdgeInsets.only(top: 12), height: 4, width: 40, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)));
// }


import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:shared_preferences/shared_preferences.dart';
import '../theme.dart';
import 'image_previewer.dart';

/// --- DATA MODELS (Top level to prevent lookup errors) ---
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

class PredictionResult {
  final String label;
  final double confidence;
  PredictionResult(this.label, this.confidence);
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

  final int maxImageLimit = 5;
  final double matchThreshold = 0.50;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  @override
  void dispose() {
    interpreter?.close();
    super.dispose();
  }

  Future<void> _initApp() async {
    setState(() {
      isInitializing = true;
      statusMessage = "Initializing AI...";
    });
    await _loadModelAndLabels();
    if (mounted) setState(() => isInitializing = false);
  }

  Future<void> _loadModelAndLabels() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? savedModelPath = prefs.getString('current_model_path');
      final String? savedLabelsPath = prefs.getString('current_labels_path');

      if (savedLabelsPath != null && File(savedLabelsPath).existsSync()) {
        final data = await File(savedLabelsPath).readAsString();
        labels = data.split('\n').where((e) => e.trim().isNotEmpty).toList();
      } else {
        final data = await rootBundle.loadString('assets/model1/labels.txt');
        labels = data.split('\n').where((e) => e.trim().isNotEmpty).toList();
      }

      if (savedModelPath != null && File(savedModelPath).existsSync()) {
        interpreter = await Interpreter.fromFile(File(savedModelPath));
      } else {
        interpreter = await Interpreter.fromAsset('assets/model1/model.tflite');
      }

      if (interpreter != null) {
        inputShape = interpreter!.getInputTensor(0).shape;
        if (mounted) {
          setState(() {
            isModelLoaded = true;
            statusMessage = "AI System Ready";
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => statusMessage = "Model Load Error");
    }
  }

  Future<void> _runInference() async {
    if (imageFiles.isEmpty || !isModelLoaded) return;
    setState(() {
      isBusy = true;
      statusMessage = "Analyzing Geometry...";
    });

    try {
      List<List<double>> allScores = [];
      for (var file in imageFiles) {
        final bytes = await file.readAsBytes();
        img.Image? originalImage = img.decodeImage(bytes);
        if (originalImage == null) continue;

        int h = inputShape![1];
        int w = inputShape![2];
        img.Image resized = img.copyResize(originalImage, width: w, height: h);

        var input = List.generate(1, (_) => List.generate(h, (y) => List.generate(w, (x) {
          final pixel = resized.getPixel(x, y);
          return [pixel.r / 255.0, pixel.g / 255.0, pixel.b / 255.0];
        })));

        var output = List.generate(1, (_) => List.filled(labels.length, 0.0));
        interpreter!.run(input, output);
        allScores.add(List<double>.from(output[0]));
      }

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

      if (mounted) {
        setState(() {
          isBusy = false;
          if (res.isEmpty || res[0].confidence < matchThreshold) {
            isUnmatched = true;
            statusMessage = "No Match Found";
          } else {
            isUnmatched = false;
            statusMessage = "Verify Identification";
            topPredictions = res.take(3).toList();
            selectedResult = topPredictions[0];
          }
        });
      }
    } catch (e) {
      if (mounted) setState(() { isBusy = false; statusMessage = "Analysis Failed"; });
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
    final picker = ImagePicker();
    if (source == ImageSource.gallery) {
      final List<XFile> picked = await picker.pickMultiImage();
      if (picked.isNotEmpty) {
        setState(() {
          imageFiles.addAll(picked.map((x) => File(x.path)));
          if (imageFiles.length > maxImageLimit) imageFiles = imageFiles.sublist(0, maxImageLimit);
          _resetStatus();
        });
      }
    } else {
      final XFile? picked = await picker.pickImage(source: source);
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
    statusMessage = "${imageFiles.length} photos ready";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: AppTheme.primaryBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          _buildHandle(),
          const SizedBox(height: 10),
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  _buildImageGallery(),
                  const SizedBox(height: 24),
                  _buildMainContent(), // Unified content management
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          _buildBottomActions(),
        ],
      ),
    );
  }

  /// --- FIX: This logic now properly checks imageFiles.isEmpty ---
  Widget _buildMainContent() {
    if (isBusy || isInitializing) {
      return _buildLoadingState();
    }

    if (imageFiles.isEmpty) {
      return _buildEmptyState();
    }

    if (isUnmatched) {
      return _buildErrorCard();
    }

    if (topPredictions.isNotEmpty) {
      return Column(
        children: topPredictions.map((res) => _buildSelectableResult(res)).toList(),
      );
    }

    // Default "waiting for analysis" state after images are added
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.primary.withOpacity(0.1))
      ),
      child: Column(
        children: [
          Icon(Icons.insights_rounded, color: AppTheme.primary.withOpacity(0.5), size: 32),
          const SizedBox(height: 12),
          const Text(
            "Tap 'RUN ANALYSIS' to identify the seal profile",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.blueGrey),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Seal Identifier", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Text(statusMessage, style: TextStyle(color: isUnmatched ? Colors.red : AppTheme.primary, fontWeight: FontWeight.w600, fontSize: 13)),
            ],
          ),
          IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: [
        const SizedBox(height: 60),
        const CircularProgressIndicator(strokeWidth: 3),
        const SizedBox(height: 20),
        Text("AI is processing images...", style: TextStyle(color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey[200]!)),
      child: Column(
        children: [
          Icon(Icons.photo_library_outlined, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 12),
          const Text("No profile photos yet", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildSelectableResult(PredictionResult res) {
    bool isSelected = selectedResult?.label == res.label;
    double percent = res.confidence * 100;

    return GestureDetector(
      onTap: () => setState(() => selectedResult = res),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary.withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppTheme.primary : Colors.grey[200]!, width: isSelected ? 2 : 1),
          boxShadow: isSelected ? [BoxShadow(color: AppTheme.primary.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))] : [],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: isSelected ? AppTheme.primary : Colors.grey[100], shape: BoxShape.circle),
                child: Icon(isSelected ? Icons.check : Icons.fingerprint, color: isSelected ? Colors.white : Colors.grey, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(res.label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(value: res.confidence, backgroundColor: Colors.grey[200], color: isSelected ? AppTheme.primary : Colors.blueGrey, minHeight: 4),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Text("${percent.toStringAsFixed(1)}%", style: TextStyle(fontWeight: FontWeight.w900, color: isSelected ? AppTheme.primary : Colors.grey[600])),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageGallery() {
    if (imageFiles.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 120,
      // child: ListView.builder(
      //   scrollDirection: Axis.horizontal,
      //   itemCount: imageFiles.length,
      //   itemBuilder: (context, index) => Container(
      //     width: 110,
      //     margin: const EdgeInsets.only(right: 12),
      //     child: Stack(
      //       children: [
      //         Positioned.fill(
      //           child: ClipRRect(
      //             borderRadius: BorderRadius.circular(16),
      //             child: Image.file(imageFiles[index], fit: BoxFit.cover),
      //           ),
      //         ),
      //         Positioned(
      //           top: 5, right: 5,
      //           child: GestureDetector(
      //             onTap: () => setState(() => imageFiles.removeAt(index)),
      //             child: Container(
      //               padding: const EdgeInsets.all(4),
      //               decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
      //               child: const Icon(Icons.close, size: 14, color: Colors.white),
      //             ),
      //           ),
      //         ),
      //       ],
      //     ),
      //   ),
      // ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: imageFiles.length,
        itemBuilder: (context, index) => Container(
          width: 110,
          margin: const EdgeInsets.only(right: 12),
          child: Stack(
            children: [
              // 1. THE IMAGE PREVIEWER
              Positioned.fill(
                child: ImagePreviewer(
                  file: imageFiles[index],
                  galleryItems: imageFiles, // Enables swiping through all picked files
                  initialIndex: index,
                  width: 110,
                  height: 110,
                  fit: BoxFit.cover,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),

              // 2. THE DELETE BUTTON (Kept on top of the previewer)
              Positioned(
                top: 8, // Slightly adjusted for better alignment with the new radius
                right: 8,
                child: GestureDetector(
                  onTap: () => setState(() => imageFiles.removeAt(index)),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, size: 14, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))]),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (imageFiles.length < maxImageLimit && !isBusy)
            Row(children: [
              Expanded(
                child: _actionButton(
                  icon: Icons.camera_alt_rounded,
                  label: "Camera",
                  onPressed: () => _addImage(ImageSource.camera),
                  isPrimary: false,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _actionButton(
                  icon: Icons.photo_library_rounded,
                  label: "Gallery",
                  onPressed: () => _addImage(ImageSource.gallery),
                  isPrimary: false,
                ),
              ),
            ]),
          const SizedBox(height: 12),
          if (imageFiles.isNotEmpty)
            SizedBox(
              width: double.infinity,
              child: _actionButton(
                icon: selectedResult != null ? Icons.verified_user_rounded : Icons.analytics_rounded,
                label: selectedResult != null ? "CONFIRM SELECTION" : "RUN ANALYSIS",
                onPressed: selectedResult != null ? _confirmSelection : _runInference,
                isPrimary: true,
                color: selectedResult != null ? Colors.green[600] : AppTheme.primary,
              ),
            ),
        ],
      ),
    );
  }

  Widget _actionButton({required IconData icon, required String label, required VoidCallback onPressed, bool isPrimary = true, Color? color}) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? (color ?? AppTheme.primary) : Colors.grey[100],
        foregroundColor: isPrimary ? Colors.white : Colors.black87,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.red[100]!)),
      child: Column(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 40),
          const SizedBox(height: 12),
          const Text("No Reliable Match", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red)),
          const SizedBox(height: 4),
          Text("The AI couldn't find a strong match. Try different angles or lighting.", textAlign: TextAlign.center, style: TextStyle(color: Colors.red[900], fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildHandle() => Container(margin: const EdgeInsets.only(top: 12), height: 4, width: 40, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)));
}
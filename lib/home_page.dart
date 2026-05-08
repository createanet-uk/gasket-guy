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

// Using package-based import to resolve class recognition issues
// Note: If your package name in pubspec.yaml is different from 'mobile',
// please update 'mobile' to your actual project name.
import 'package:mobile/vision/rubber_camera_detector.dart';

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});
//
//   @override
//   State<HomePage> createState() => _HomePageState();
// }
//
// class PredictionResult {
//   final String label;
//   final double confidence;
//
//   PredictionResult(this.label, this.confidence);
// }
//
// class _HomePageState extends State<HomePage> {
//   List<File> imageFiles = [];
//   List<PredictionResult> topPredictions = [];
//   String statusMessage = "Add images to start analysis";
//   bool isBusy = false;
//   bool isUnmatched = false;
//
//   Interpreter? interpreter;
//   List<String> labels = [];
//   bool isModelLoaded = false;
//   bool isInitializing = false;
//
//   List<int>? inputShape;
//   TensorType? inputType;
//
//   final double matchThreshold = 0.50;
//   final int maxImageLimit = 5;
//
//   @override
//   void initState() {
//     super.initState();
//     // initApp();
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       await initApp();
//     });
//   }
//
//   Future<void> initApp() async {
//     if (isInitializing) return;
//     setState(() {
//       isInitializing = true;
//       statusMessage = "Loading AI Model...";
//     });
//
//     await loadLabels();
//     await loadModel();
//
//     setState(() {
//       isInitializing = false;
//     });
//   }
//
//   Future<void> loadModel() async {
//     try {
//       // Load model from assets
//       interpreter = await Interpreter.fromAsset(
//         'assets/model1/model.tflite',
//       );
//
//       if (interpreter != null) {
//         inputShape = interpreter!.getInputTensor(0).shape;
//         inputType = interpreter!.getInputTensor(0).type;
//         setState(() {
//           isModelLoaded = true;
//           statusMessage = "AI System Ready";
//         });
//       }
//     } catch (e) {
//       debugPrint("Model Load Error: $e");
//       setState(() {
//         isModelLoaded = false;
//         statusMessage = "Model Load Error: Check path or file";
//       });
//     }
//   }
//
//   Future<void> loadLabels() async {
//     try {
//       final data = await rootBundle.loadString('assets/model1/labels.txt');
//       labels = data.split('\n').where((e) => e.trim().isNotEmpty).toList();
//     } catch (e) {
//       debugPrint("Label loading error: $e");
//     }
//   }
//
//   // ================= INFERENCE LOGIC =================
//   Future<void> runMultiInference() async {
//     if (imageFiles.isEmpty) return;
//
//     if (!isModelLoaded) {
//       setState(() => statusMessage = "Model not loaded, retrying...");
//       await initApp();
//
//       if (!isModelLoaded) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text("Model could not be loaded. Please check assets folder."),
//             backgroundColor: Colors.red,
//           ),
//         );
//         return;
//       }
//     }
//
//     setState(() {
//       isBusy = true;
//       statusMessage = "Aggregating geometric data...";
//     });
//
//     try {
//       List<List<double>> allScores = [];
//
//       for (var file in imageFiles) {
//         final bytes = await file.readAsBytes();
//         img.Image? image = img.decodeImage(bytes);
//         if (image == null) continue;
//
//         int height = inputShape![1];
//         int width = inputShape![2];
//
//         // Resize image to match model input
//         img.Image resized = img.copyResize(image, width: width, height: height);
//
//         // Prepare Input Tensor [1, height, width, 3]
//         var input = List.generate(
//           1,
//               (_) => List.generate(
//             height,
//                 (y) => List.generate(width, (x) {
//               final pixel = resized.getPixel(x, y);
//               // Normalize pixel values to 0.0 - 1.0
//               return [
//                 pixel.r.toDouble(),
//                 pixel.g.toDouble(),
//                 pixel.b.toDouble(),
//               ];
//               // return [
//               //   (pixel.r / 127.5) - 1.0,
//               //   (pixel.g / 127.5) - 1.0,
//               //   (pixel.b / 127.5) - 1.0,
//               // ];
//             }),
//           ),
//         );
//
//         // Prepare Output Tensor [1, num_labels]
//         var output = List.generate(1, (_) => List.filled(labels.length, 0.0));
//
//         // Run Inference
//         interpreter!.run(input, output);
//         allScores.add(List<double>.from(output[0]));
//       }
//
//       if (allScores.isEmpty) throw Exception("No images could be processed");
//
//       // Averaging scores for multi-image precision
//       List<double> averagedScores = List.filled(labels.length, 0.0);
//       for (int i = 0; i < labels.length; i++) {
//         double sum = 0;
//         for (int j = 0; j < allScores.length; j++) {
//           sum += allScores[j][i];
//         }
//         averagedScores[i] = sum / allScores.length;
//       }
//
//       List<PredictionResult> results = [];
//       for (int i = 0; i < labels.length; i++) {
//         results.add(PredictionResult(labels[i], averagedScores[i]));
//       }
//
//       results.sort((a, b) => b.confidence.compareTo(a.confidence));
//
//       setState(() {
//         isBusy = false;
//         bool hasHighConfidence =
//             results.isNotEmpty && results[0].confidence >= matchThreshold;
//
//         bool hasClearGap = results.length > 1
//             ? (results[0].confidence - results[1].confidence) > 0.12
//             : true;
//
//         if (!hasHighConfidence || !hasClearGap) {
//           isUnmatched = true;
//           statusMessage = "Data Not Matched";
//           topPredictions = [];
//         } else {
//           isUnmatched = false;
//           statusMessage = "High Precision Analysis Complete";
//           topPredictions = results.take(3).toList();
//         }
//       });
//     } catch (e) {
//       debugPrint("Inference Error Detailed: $e");
//       setState(() {
//         statusMessage = "Analysis Failed: Technical Error";
//         isBusy = false;
//       });
//     }
//   }
//
//   void _showLimitWarning(int attempted, int allowed) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Row(
//           children: [
//             Icon(Icons.warning_amber_rounded, color: Colors.orange),
//             SizedBox(width: 10),
//             Text("Limit Warning"),
//           ],
//         ),
//         content: Text(
//           "You selected $attempted images, but only $allowed slots are available (Max: 5).",
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text("Okay"),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Future<void> addImage(ImageSource source) async {
//     if (imageFiles.length >= maxImageLimit) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Maximum 5 images are allowed.")),
//       );
//       return;
//     }
//
//     final picker = ImagePicker();
//
//     if (source == ImageSource.gallery) {
//       try {
//         int remainingSlots = maxImageLimit - imageFiles.length;
//         final List<XFile> pickedFiles = await picker.pickMultiImage();
//
//         if (pickedFiles.isEmpty) return;
//
//         setState(() {
//           if (pickedFiles.length > remainingSlots) {
//             _showLimitWarning(pickedFiles.length, remainingSlots);
//           }
//
//           var filesToAdd = pickedFiles
//               .take(remainingSlots)
//               .map((xFile) => File(xFile.path));
//           imageFiles.addAll(filesToAdd);
//
//           isUnmatched = false;
//           topPredictions = [];
//           statusMessage = "${imageFiles.length} profiles ready for analysis";
//         });
//       } catch (e) {
//         debugPrint("Gallery error: $e");
//       }
//     } else {
//       final result = await Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (_) => const RubberCameraDetectorPage(),
//         ),
//       );
//
//       if (result == null) return;
//
//       List<File> newFiles = [];
//       if (result is List) {
//         for (var item in result) {
//           if (item is Map && item['path'] != null) {
//             newFiles.add(File(item['path'].toString()));
//           }
//         }
//       } else if (result is File) {
//         newFiles.add(result);
//       } else if (result is String) {
//         newFiles.add(File(result));
//       } else if (result is Map && result['path'] != null) {
//         newFiles.add(File(result['path'].toString()));
//       }
//
//       if (newFiles.isNotEmpty) {
//         setState(() {
//           int remainingSlots = maxImageLimit - imageFiles.length;
//           if (newFiles.length > remainingSlots) {
//             _showLimitWarning(newFiles.length, remainingSlots);
//           }
//
//           imageFiles.addAll(newFiles.take(remainingSlots));
//           isUnmatched = false;
//           topPredictions = [];
//           statusMessage = "${imageFiles.length} profiles ready for analysis";
//         });
//       }
//     }
//   }
//
//   void clearImages() {
//     setState(() {
//       imageFiles = [];
//       topPredictions = [];
//       isUnmatched = false;
//       statusMessage = isModelLoaded ? "AI System Ready" : "Add images to start analysis";
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         title: const Text(
//           "Gasket Guy",
//           style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
//         ),
//         centerTitle: true,
//         actions: [
//           if (imageFiles.isNotEmpty)
//             IconButton(
//               onPressed: clearImages,
//               icon: const Icon(Icons.delete_sweep, color: Colors.red),
//             ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             _buildImageGallery(),
//             const SizedBox(height: 16),
//             _buildPrecisionTip(),
//             const SizedBox(height: 24),
//             _buildStatusHeader(),
//             const SizedBox(height: 16),
//             if (isBusy || isInitializing)
//               const Center(
//                 child: Padding(
//                   padding: EdgeInsets.all(40),
//                   child: CircularProgressIndicator(),
//                 ),
//               )
//             else if (isUnmatched)
//               _buildErrorCard()
//             else if (topPredictions.isNotEmpty)
//                 ...topPredictions.asMap().entries.map((entry) {
//                   int idx = entry.key;
//                   PredictionResult res = entry.value;
//                   return _buildResultTile(res, isHighlyRecommended: idx == 0);
//                 }),
//             const SizedBox(height: 32),
//             if (imageFiles.length < maxImageLimit && !isBusy)
//               _buildActionButtons(),
//             if (imageFiles.isNotEmpty && !isBusy)
//               _buildVerifyButton(),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // --- UI Helper Components ---
//   Widget _buildImageGallery() {
//     return SizedBox(
//       height: 120,
//       child: imageFiles.isEmpty
//           ? Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           border: Border.all(color: Colors.grey[300]!, width: 2),
//           borderRadius: BorderRadius.circular(20),
//         ),
//         child: const Center(
//           child: Text(
//             "No profiles added yet",
//             style: TextStyle(color: Colors.grey),
//           ),
//         ),
//       )
//           : ListView.separated(
//         scrollDirection: Axis.horizontal,
//         itemCount: imageFiles.length,
//         separatorBuilder: (_, __) => const SizedBox(width: 12),
//         itemBuilder: (context, index) {
//           return Stack(
//             children: [
//               Container(
//                 width: 120,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(16),
//                   border: Border.all(color: Colors.grey[200]!),
//                   image: DecorationImage(
//                     image: FileImage(imageFiles[index]),
//                     // fit: BoxFit.fitHeight,
//                   ),
//                 ),
//               ),
//               Positioned(
//                 top: 4,
//                 right: 4,
//                 child: GestureDetector(
//                   onTap: () => setState(() => imageFiles.removeAt(index)),
//                   child: Container(
//                     padding: const EdgeInsets.all(2),
//                     decoration: const BoxDecoration(
//                       color: Colors.black54,
//                       shape: BoxShape.circle,
//                     ),
//                     child: const Icon(
//                       Icons.close,
//                       color: Colors.white,
//                       size: 18,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildPrecisionTip() {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.indigo[50],
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.indigo.withOpacity(0.1)),
//       ),
//       child: const Row(
//         children: [
//           Icon(Icons.auto_graph, size: 20, color: Colors.indigo),
//           SizedBox(width: 10),
//           Expanded(
//             child: Text(
//               "Precision Tip: Taking photos from different angles (up to 5) increases match accuracy.",
//               style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.indigo),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildStatusHeader() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Expanded(
//           child: Text(
//             statusMessage.toUpperCase(),
//             overflow: TextOverflow.ellipsis,
//             style: TextStyle(
//               fontSize: 10,
//               fontWeight: FontWeight.w900,
//               color: !isModelLoaded ? Colors.red[700] : (isUnmatched ? Colors.orange[900] : Colors.indigo[300]),
//               letterSpacing: 1.5,
//             ),
//           ),
//         ),
//         if (!isModelLoaded && !isInitializing)
//           TextButton(
//             onPressed: initApp,
//             child: const Text("RETRY LOAD", style: TextStyle(fontSize: 10, color: Colors.blue, fontWeight: FontWeight.bold)),
//           ),
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//           decoration: BoxDecoration(
//             color: Colors.grey[200],
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: Text(
//             "Photos: ${imageFiles.length}/$maxImageLimit",
//             style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildActionButtons() {
//     return Row(
//       children: [
//         Expanded(
//           child: ElevatedButton.icon(
//             onPressed: () => addImage(ImageSource.camera),
//             icon: const Icon(Icons.add_a_photo),
//             label: const Text("Capture"),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.indigo,
//               foregroundColor: Colors.white,
//               padding: const EdgeInsets.symmetric(vertical: 16),
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//             ),
//           ),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: OutlinedButton.icon(
//             onPressed: () => addImage(ImageSource.gallery),
//             icon: const Icon(Icons.add_photo_alternate),
//             label: const Text("Gallery"),
//             style: OutlinedButton.styleFrom(
//               padding: const EdgeInsets.symmetric(vertical: 16),
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildVerifyButton() {
//     return Padding(
//       padding: const EdgeInsets.only(top: 16.0),
//       child: ElevatedButton.icon(
//         onPressed: runMultiInference,
//         icon: const Icon(Icons.verified_user_outlined),
//         label: Text(isModelLoaded ? "VERIFY ${imageFiles.length} PROFILES" : "RETRY & VERIFY"),
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Colors.green[700],
//           foregroundColor: Colors.white,
//           padding: const EdgeInsets.symmetric(vertical: 20),
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildResultTile(PredictionResult res, {required bool isHighlyRecommended}) {
//     return Card(
//       elevation: isHighlyRecommended ? 2 : 0,
//       margin: const EdgeInsets.only(bottom: 12),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//         side: BorderSide(
//           color: isHighlyRecommended ? Colors.indigo : Colors.indigo.withOpacity(0.1),
//           width: isHighlyRecommended ? 2 : 1,
//         ),
//       ),
//       color: Colors.white,
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       res.label,
//                       style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                     ),
//                     if (isHighlyRecommended)
//                       const Text(
//                         "HIGHLY RECOMMENDED MATCH",
//                         style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5),
//                       ),
//                   ],
//                 ),
//                 Text(
//                   "${(res.confidence * 100).toStringAsFixed(1)}%",
//                   style: TextStyle(fontWeight: FontWeight.w900, color: Colors.indigo[700], fontSize: 18),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             ClipRRect(
//               borderRadius: BorderRadius.circular(4),
//               child: LinearProgressIndicator(
//                 value: res.confidence,
//                 minHeight: 8,
//                 backgroundColor: Colors.indigo[50],
//                 color: isHighlyRecommended ? Colors.indigo : Colors.indigo[200],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildErrorCard() {
//     return Container(
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         color: Colors.orange[50],
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: Colors.orange.withOpacity(0.2)),
//       ),
//       child: Column(
//         children: [
//           Icon(Icons.search_off_rounded, color: Colors.orange[400], size: 48),
//           const SizedBox(height: 12),
//           Text(
//             "No Match Found",
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange[900]),
//           ),
//           const SizedBox(height: 8),
//           const Text(
//             "This object does not match our database. For better results, take clear cross-section photos from different angles.",
//             textAlign: TextAlign.center,
//             style: TextStyle(color: Colors.black54, fontSize: 13),
//           ),
//         ],
//       ),
//     );
//   }
// }


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
  final int maxImageLimit = 5;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await initApp();
    });
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
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
        print('--- VERSION FILE CONTENT ($fileName) ---');
        print(content);
        print('-----------------------------------------');
      }
    } catch (e) {
      print('VERSION_FILE_ERROR: $e');
    }
  }

  Future<void> loadModelAndLabels() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? savedModelPath = prefs.getString('current_model_path');
      final String? savedLabelsPath = prefs.getString('current_labels_path');
      final int? version = prefs.getInt('current_model_version');

      // 1. Load Labels
      if (savedLabelsPath != null && File(savedLabelsPath).existsSync()) {
        print('HOMEPAGE_LOAD: Loading dynamic labels from $savedLabelsPath');
        final data = await File(savedLabelsPath).readAsString();
        labels = data.split('\n').where((e) => e.trim().isNotEmpty).toList();
      } else {
        print('HOMEPAGE_LOAD: Loading default labels from assets...');
        final data = await rootBundle.loadString('assets/model1/labels.txt');
        labels = data.split('\n').where((e) => e.trim().isNotEmpty).toList();
      }

      // 2. Load Model
      if (savedModelPath != null && File(savedModelPath).existsSync()) {
        print('HOMEPAGE_LOAD: Loading dynamic model from $savedModelPath (v$version)');
        interpreter = await Interpreter.fromFile(File(savedModelPath));
      } else {
        print('HOMEPAGE_LOAD: No dynamic model found, loading from assets...');
        interpreter = await Interpreter.fromAsset('assets/model1/model.tflite');
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
      print("HOMEPAGE_LOAD_ERROR: $e");
      setState(() {
        isModelLoaded = false;
        statusMessage = "Model Load Error";
      });
    }
  }

  Future<void> runMultiInference() async {
    if (imageFiles.isEmpty || !isModelLoaded) return;

    setState(() {
      isBusy = true;
      statusMessage = "Aggregating geometric data...";
    });

    try {
      List<List<double>> allScores = [];

      for (var file in imageFiles) {
        final bytes = await file.readAsBytes();
        img.Image? image = img.decodeImage(bytes);
        if (image == null) continue;

        int height = inputShape![1];
        int width = inputShape![2];

        img.Image resized = img.copyResize(image, width: width, height: height);

        var input = List.generate(1, (_) => List.generate(height, (y) => List.generate(width, (x) {
          final pixel = resized.getPixel(x, y);
          return [pixel.r.toDouble(), pixel.g.toDouble(), pixel.b.toDouble()];
        })));

        var output = List.generate(1, (_) => List.filled(labels.length, 0.0));
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
        bool hasHighConfidence = results.isNotEmpty && results[0].confidence >= matchThreshold;
        bool hasClearGap = results.length > 1 ? (results[0].confidence - results[1].confidence) > 0.12 : true;

        if (!hasHighConfidence || !hasClearGap) {
          isUnmatched = true;
          statusMessage = "Data Not Matched";
          topPredictions = [];
        } else {
          isUnmatched = false;
          statusMessage = "Analysis Complete";
          topPredictions = results.take(3).toList();
        }
      });
    } catch (e) {
      print("Inference Error: $e");
      setState(() {
        statusMessage = "Analysis Failed";
        isBusy = false;
      });
    }
  }

  // --- UI Components ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(

        backgroundColor: Colors.white,
        title: const Text("Gasket Guy", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        centerTitle: true,
        actions: [
          if (imageFiles.isNotEmpty)
            IconButton(onPressed: clearImages, icon: const Icon(Icons.delete_sweep, color: Colors.red)),
          InkWell(
            // onTap: () async {
            //   // 1. Sign out from Supabase
            //   await Supabase.instance.client.auth.signOut();
            //
            //   // 2. Navigate back to AuthPage and clear the navigation stack
            //   if (context.mounted) {
            //     Navigator.pushAndRemoveUntil(
            //       context,
            //       MaterialPageRoute(builder: (context) => const AuthPage()),
            //           (route) => false, // This removes all previous routes (Home, etc.)
            //     );
            //   }
            // },
            onTap: () => _showLogoutDialog(context),
            child: const Icon(
              Icons.logout,
              color: AppTheme.error, // Using the error color from your theme
            ),
          ),
          SizedBox(width: 20,)
        ],
      ),
      body: SingleChildScrollView(
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
                ...topPredictions.asMap().entries.map((e) => _buildResultTile(e.value, isHighlyRecommended: e.key == 0)),
            const SizedBox(height: 32),
            if (imageFiles.length < maxImageLimit && !isBusy) _buildActionButtons(),
            if (imageFiles.isNotEmpty && !isBusy) _buildVerifyButton(),
          ],
        ),
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

  Widget _buildActionButtons() {
    return Row(children: [
      Expanded(child: ElevatedButton.icon(onPressed: () => addImage(ImageSource.camera), icon: const Icon(Icons.add_a_photo), label: const Text("Capture"), style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)))),
      const SizedBox(width: 12),
      Expanded(child: OutlinedButton.icon(onPressed: () => addImage(ImageSource.gallery), icon: const Icon(Icons.add_photo_alternate), label: const Text("Gallery"), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)))),
    ]);
  }

  Widget _buildVerifyButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: ElevatedButton(onPressed: runMultiInference, style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700], foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 20)), child: const Text("VERIFY PROFILES")),
    );
  }

  Widget _buildResultTile(PredictionResult res, {required bool isHighlyRecommended}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: isHighlyRecommended ? Colors.indigo : Colors.grey[200]!)),
      child: ListTile(
        title: Text(res.label, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: LinearProgressIndicator(value: res.confidence),
        trailing: Text("${(res.confidence * 100).toStringAsFixed(1)}%"),
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(padding: const EdgeInsets.all(24), child: const Column(children: [Icon(Icons.warning, color: Colors.orange, size: 48), Text("No Match Found")]));
  }

  void clearImages() => setState(() { imageFiles = []; topPredictions = []; isUnmatched = false; statusMessage = "AI System Ready"; });

  Future<void> addImage(ImageSource source) async {
    if (imageFiles.length >= maxImageLimit) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Maximum 5 images are allowed.")),
      );
      return;
    }

    final picker = ImagePicker();

    if (source == ImageSource.gallery) {
      try {
        int remainingSlots = maxImageLimit - imageFiles.length;
        final List<XFile> pickedFiles = await picker.pickMultiImage();

        if (pickedFiles.isEmpty) return;

        setState(() {
          if (pickedFiles.length > remainingSlots) {
            _showLimitWarning(pickedFiles.length, remainingSlots);
          }

          var filesToAdd = pickedFiles
              .take(remainingSlots)
              .map((xFile) => File(xFile.path));
          imageFiles.addAll(filesToAdd);

          isUnmatched = false;
          topPredictions = [];
          statusMessage = "${imageFiles.length} profiles ready for analysis";
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
          int remainingSlots = maxImageLimit - imageFiles.length;
          if (newFiles.length > remainingSlots) {
            _showLimitWarning(newFiles.length, remainingSlots);
          }

          imageFiles.addAll(newFiles.take(remainingSlots));
          isUnmatched = false;
          topPredictions = [];
          statusMessage = "${imageFiles.length} profiles ready for analysis";
        });
      }
    }
  }

  void _showLimitWarning(int attempted, int allowed) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 10),
            Text("Limit Warning"),
          ],
        ),
        content: Text(
          "You selected $attempted images, but only $allowed slots are available (Max: 5).",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Okay"),
          ),
        ],
      ),
    );
  }

  // Future<void> addImage(ImageSource source) async {
  //   final picker = ImagePicker();
  //   if (source == ImageSource.gallery) {
  //     final picked = await picker.pickMultiImage();
  //     if (picked.isNotEmpty) setState(() => imageFiles.addAll(picked.take(maxImageLimit - imageFiles.length).map((e) => File(e.path))));
  //   } else {
  //     final picked = await picker.pickImage(source: source);
  //     if (picked != null) setState(() => imageFiles.add(File(picked.path)));
  //   }
  // }
}
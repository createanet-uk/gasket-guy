// // // // // // // // // import 'dart:io';
// // // // // // // // // import 'dart:math';
// // // // // // // // //
// // // // // // // // // import 'package:flutter/material.dart';
// // // // // // // // // import 'package:flutter/services.dart';
// // // // // // // // // import 'package:image/image.dart' as img;
// // // // // // // // // import 'package:image_picker/image_picker.dart';
// // // // // // // // // import 'package:tflite_flutter/tflite_flutter.dart';
// // // // // // // // //
// // // // // // // // // void main() {
// // // // // // // // //   runApp(const MyApp());
// // // // // // // // // }
// // // // // // // // //
// // // // // // // // // late Interpreter interpreter;
// // // // // // // // // List<String> labels = [];
// // // // // // // // //
// // // // // // // // // class MyApp extends StatelessWidget {
// // // // // // // // //   const MyApp({super.key});
// // // // // // // // //
// // // // // // // // //   @override
// // // // // // // // //   Widget build(BuildContext context) {
// // // // // // // // //     return MaterialApp(
// // // // // // // // //       title: 'Rubber Model Detection',
// // // // // // // // //       theme: ThemeData(
// // // // // // // // //         colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
// // // // // // // // //       ),
// // // // // // // // //       home: const HomePage(),
// // // // // // // // //     );
// // // // // // // // //   }
// // // // // // // // // }
// // // // // // // // //
// // // // // // // // // class HomePage extends StatefulWidget {
// // // // // // // // //   const HomePage({super.key});
// // // // // // // // //
// // // // // // // // //   @override
// // // // // // // // //   State<HomePage> createState() => _HomePageState();
// // // // // // // // // }
// // // // // // // // //
// // // // // // // // // class _HomePageState extends State<HomePage> {
// // // // // // // // //   File? _image;
// // // // // // // // //   String result = "No prediction yet";
// // // // // // // // //
// // // // // // // // //   @override
// // // // // // // // //   void initState() {
// // // // // // // // //     super.initState();
// // // // // // // // //     loadModel();
// // // // // // // // //     loadLabels();
// // // // // // // // //   }
// // // // // // // // //
// // // // // // // // //   Future<void> loadModel() async {
// // // // // // // // //     interpreter = await Interpreter.fromAsset('model/rubber_model.tflite');
// // // // // // // // //   }
// // // // // // // // //
// // // // // // // // //   Future<void> loadLabels() async {
// // // // // // // // //     final data = await rootBundle.loadString('assets/model/oldlabels.txt');
// // // // // // // // //     labels = data.split('\n').where((e) => e.isNotEmpty).toList();
// // // // // // // // //   }
// // // // // // // // //
// // // // // // // // //   Future<void> pickImage() async {
// // // // // // // // //     final picker = ImagePicker();
// // // // // // // // //     final pickedFile = await picker.pickImage(source: ImageSource.gallery);
// // // // // // // // //
// // // // // // // // //     if (pickedFile == null) return;
// // // // // // // // //
// // // // // // // // //     setState(() {
// // // // // // // // //       _image = File(pickedFile.path);
// // // // // // // // //       result = "Processing...";
// // // // // // // // //     });
// // // // // // // // //
// // // // // // // // //     await runModel(_image!);
// // // // // // // // //   }
// // // // // // // // //
// // // // // // // // //   Future<void> runModel(File imageFile) async {
// // // // // // // // //     final bytes = await imageFile.readAsBytes();
// // // // // // // // //     img.Image? originalImage = img.decodeImage(bytes);
// // // // // // // // //
// // // // // // // // //     if (originalImage == null) return;
// // // // // // // // //
// // // // // // // // //     var input = preprocess(originalImage);
// // // // // // // // //
// // // // // // // // //     var output =
// // // // // // // // //     List.generate(1, (_) => List.filled(labels.length, 0.0));
// // // // // // // // //
// // // // // // // // //     interpreter.run(input, output);
// // // // // // // // //
// // // // // // // // //     int maxIndex = 0;
// // // // // // // // //     double maxScore = 0;
// // // // // // // // //
// // // // // // // // //     for (int i = 0; i < labels.length; i++) {
// // // // // // // // //       if (output[0][i] > maxScore) {
// // // // // // // // //         maxScore = output[0][i];
// // // // // // // // //         maxIndex = i;
// // // // // // // // //       }
// // // // // // // // //     }
// // // // // // // // //
// // // // // // // // //     setState(() {
// // // // // // // // //       result =
// // // // // // // // //       "Model: ${labels[maxIndex]}\nConfidence: ${(maxScore * 100).toStringAsFixed(2)}%";
// // // // // // // // //     });
// // // // // // // // //   }
// // // // // // // // //
// // // // // // // // //   List<List<List<List<double>>>> preprocess(img.Image image) {
// // // // // // // // //     var resized = img.copyResize(image, width: 224, height: 224);
// // // // // // // // //
// // // // // // // // //     return [
// // // // // // // // //       List.generate(224, (y) =>
// // // // // // // // //           List.generate(224, (x) {
// // // // // // // // //             var pixel = resized.getPixel(x, y);
// // // // // // // // //             return [
// // // // // // // // //               pixel.r / 255.0,
// // // // // // // // //               pixel.g / 255.0,
// // // // // // // // //               pixel.b / 255.0,
// // // // // // // // //             ];
// // // // // // // // //           }))
// // // // // // // // //     ];
// // // // // // // // //   }
// // // // // // // // //
// // // // // // // // //   @override
// // // // // // // // //   Widget build(BuildContext context) {
// // // // // // // // //     return Scaffold(
// // // // // // // // //       appBar: AppBar(
// // // // // // // // //         title: const Text("Rubber Model Detection"),
// // // // // // // // //       ),
// // // // // // // // //       body: Column(
// // // // // // // // //         mainAxisAlignment: MainAxisAlignment.center,
// // // // // // // // //         children: [
// // // // // // // // //           _image != null
// // // // // // // // //               ? Image.file(_image!, height: 200)
// // // // // // // // //               : const Text("No image selected"),
// // // // // // // // //
// // // // // // // // //           const SizedBox(height: 20),
// // // // // // // // //
// // // // // // // // //           Text(
// // // // // // // // //             result,
// // // // // // // // //             textAlign: TextAlign.center,
// // // // // // // // //             style: const TextStyle(fontSize: 18),
// // // // // // // // //           ),
// // // // // // // // //
// // // // // // // // //           const SizedBox(height: 20),
// // // // // // // // //
// // // // // // // // //           ElevatedButton(
// // // // // // // // //             onPressed: pickImage,
// // // // // // // // //             child: const Text("Select Image"),
// // // // // // // // //           ),
// // // // // // // // //         ],
// // // // // // // // //       ),
// // // // // // // // //     );
// // // // // // // // //   }
// // // // // // // // // }
// // // // // // // // //
// // // // // // // // //
// // // // // // // // //
// // // // // // // // //
// // // // // // // // //
// // // // // // // //
// // // // // // // //
// // // // // // // //
// // // // // // // //
// // // // // // // // import 'dart:io';
// // // // // // // // import 'package:flutter/material.dart';
// // // // // // // // import 'package:flutter/services.dart';
// // // // // // // // import 'package:image_picker/image_picker.dart';
// // // // // // // // import 'package:tflite_flutter/tflite_flutter.dart';
// // // // // // // // import 'package:image/image.dart' hide Image;
// // // // // // // // void main() {
// // // // // // // //   runApp(const MyApp());
// // // // // // // // }
// // // // // // // //
// // // // // // // // class MyApp extends StatelessWidget {
// // // // // // // //   const MyApp({super.key});
// // // // // // // //
// // // // // // // //   @override
// // // // // // // //   Widget build(BuildContext context) {
// // // // // // // //     return MaterialApp(
// // // // // // // //       title: 'Rubber Model Detection',
// // // // // // // //       theme: ThemeData(
// // // // // // // //         colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
// // // // // // // //       ),
// // // // // // // //       home: const HomePage(),
// // // // // // // //     );
// // // // // // // //   }
// // // // // // // // }
// // // // // // // //
// // // // // // // // class HomePage extends StatefulWidget {
// // // // // // // //   const HomePage({super.key});
// // // // // // // //
// // // // // // // //   @override
// // // // // // // //   State<HomePage> createState() => _HomePageState();
// // // // // // // // }
// // // // // // // //
// // // // // // // // class _HomePageState extends State<HomePage> {
// // // // // // // //   File? _image;
// // // // // // // //   String result = "No prediction yet";
// // // // // // // //   late Interpreter interpreter;
// // // // // // // //   List<String> labels = [];
// // // // // // // //
// // // // // // // //   @override
// // // // // // // //   void initState() {
// // // // // // // //     super.initState();
// // // // // // // //     _loadModel();
// // // // // // // //     _loadLabels();
// // // // // // // //   }
// // // // // // // //
// // // // // // // //   Future<void> _loadModel() async {
// // // // // // // //     interpreter = await Interpreter.fromAsset('assets/model/rubber_model.tflite');
// // // // // // // //   }
// // // // // // // //
// // // // // // // //   Future<void> _loadLabels() async {
// // // // // // // //     final data = await rootBundle.loadString('assets/model/oldlabels.txt');
// // // // // // // //     labels = data.split('\n').where((e) => e.isNotEmpty).toList();
// // // // // // // //   }
// // // // // // // //
// // // // // // // //   Future<void> _pickImage() async {
// // // // // // // //     final picker = ImagePicker();
// // // // // // // //     final pickedFile = await picker.pickImage(source: ImageSource.gallery);
// // // // // // // //
// // // // // // // //     if (pickedFile == null) return;
// // // // // // // //
// // // // // // // //     setState(() {
// // // // // // // //       _image = File(pickedFile.path);
// // // // // // // //       result = "Processing...";
// // // // // // // //     });
// // // // // // // //
// // // // // // // //     await _runModel(_image!);
// // // // // // // //   }
// // // // // // // //
// // // // // // // //   Future<void> _runModel(File imageFile) async {
// // // // // // // //     final bytes = await imageFile.readAsBytes();
// // // // // // // //     final image = decodeImage(bytes)!;
// // // // // // // //
// // // // // // // //     final resized = copyResize(image, width: 224, height: 224);
// // // // // // // //
// // // // // // // //     var input = List.generate(
// // // // // // // //       1,
// // // // // // // //           (_) => List.generate(
// // // // // // // //         224,
// // // // // // // //             (y) => List.generate(
// // // // // // // //           224,
// // // // // // // //               (x) {
// // // // // // // //             final pixel = resized.getPixel(x, y);
// // // // // // // //             return [
// // // // // // // //               pixel.r / 255.0,
// // // // // // // //               pixel.g / 255.0,
// // // // // // // //               pixel.b / 255.0,
// // // // // // // //             ];
// // // // // // // //           },
// // // // // // // //         ),
// // // // // // // //       ),
// // // // // // // //     );
// // // // // // // //
// // // // // // // //     var output = List.generate(1, (_) => List.filled(labels.length, 0.0));
// // // // // // // //
// // // // // // // //     interpreter.run(input, output);
// // // // // // // //
// // // // // // // //     int maxIndex = 0;
// // // // // // // //     double maxScore = 0;
// // // // // // // //
// // // // // // // //     for (int i = 0; i < labels.length; i++) {
// // // // // // // //       if (output[0][i] > maxScore) {
// // // // // // // //         maxScore = output[0][i];
// // // // // // // //         maxIndex = i;
// // // // // // // //       }
// // // // // // // //     }
// // // // // // // //
// // // // // // // //     setState(() {
// // // // // // // //       result =
// // // // // // // //       "Model: ${labels[maxIndex]}\nConfidence: ${(maxScore * 100).toStringAsFixed(2)}%";
// // // // // // // //     });
// // // // // // // //   }
// // // // // // // //
// // // // // // // //   @override
// // // // // // // //   Widget build(BuildContext context) {
// // // // // // // //     return Scaffold(
// // // // // // // //       appBar: AppBar(
// // // // // // // //         title: const Text("Rubber Model Detection"),
// // // // // // // //       ),
// // // // // // // //       body: Column(
// // // // // // // //         mainAxisAlignment: MainAxisAlignment.center,
// // // // // // // //         children: [
// // // // // // // //           _image != null
// // // // // // // //               ? Image.file(_image!, height: 200)
// // // // // // // //               : const Text("No image selected"),
// // // // // // // //           const SizedBox(height: 20),
// // // // // // // //           Text(
// // // // // // // //             result,
// // // // // // // //             textAlign: TextAlign.center,
// // // // // // // //             style: const TextStyle(fontSize: 18),
// // // // // // // //           ),
// // // // // // // //           const SizedBox(height: 20),
// // // // // // // //           ElevatedButton(
// // // // // // // //             onPressed: _pickImage,
// // // // // // // //             child: const Text("Select Image"),
// // // // // // // //           ),
// // // // // // // //         ],
// // // // // // // //       ),
// // // // // // // //     );
// // // // // // // //   }
// // // // // // // // }
// // // // // // //
// // // // // // //
// // // // // // //
// // // // // // //
// // // // // // // import 'dart:io';
// // // // // // // import 'package:flutter/material.dart';
// // // // // // // import 'package:flutter/services.dart';
// // // // // // // import 'package:image_picker/image_picker.dart';
// // // // // // // import 'package:tflite_flutter/tflite_flutter.dart';
// // // // // // // import 'package:image/image.dart' hide Image;
// // // // // // //
// // // // // // // void main() {
// // // // // // //   runApp(const MyApp());
// // // // // // // }
// // // // // // //
// // // // // // // class MyApp extends StatelessWidget {
// // // // // // //   const MyApp({super.key});
// // // // // // //
// // // // // // //   @override
// // // // // // //   Widget build(BuildContext context) {
// // // // // // //     return MaterialApp(
// // // // // // //       title: 'Rubber Model Detection',
// // // // // // //       theme: ThemeData(
// // // // // // //         colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
// // // // // // //       ),
// // // // // // //       home: const HomePage(),
// // // // // // //     );
// // // // // // //   }
// // // // // // // }
// // // // // // //
// // // // // // // class HomePage extends StatefulWidget {
// // // // // // //   const HomePage({super.key});
// // // // // // //
// // // // // // //   @override
// // // // // // //   State<HomePage> createState() => _HomePageState();
// // // // // // // }
// // // // // // //
// // // // // // // class _HomePageState extends State<HomePage> {
// // // // // // //   File? _image;
// // // // // // //   String result = "No prediction yet";
// // // // // // //
// // // // // // //   late Interpreter interpreter;
// // // // // // //   List<String> labels = [];
// // // // // // //   bool isModelLoaded = false;
// // // // // // //
// // // // // // //   @override
// // // // // // //   void initState() {
// // // // // // //     super.initState();
// // // // // // //     _initAll();
// // // // // // //   }
// // // // // // //
// // // // // // //   Future<void> _initAll() async {
// // // // // // //     await _loadModel();
// // // // // // //     await _loadLabels();
// // // // // // //   }
// // // // // // //
// // // // // // //   Future<void> _loadModel() async {
// // // // // // //     try {
// // // // // // //       interpreter = await Interpreter.fromAsset(
// // // // // // //         'assets/model/rubber_model.tflite',
// // // // // // //       );
// // // // // // //       setState(() {
// // // // // // //         isModelLoaded = true;
// // // // // // //       });
// // // // // // //     } catch (e) {
// // // // // // //       setState(() {
// // // // // // //         result = "❌ Model load error: $e";
// // // // // // //       });
// // // // // // //     }
// // // // // // //   }
// // // // // // //
// // // // // // //   Future<void> _loadLabels() async {
// // // // // // //     try {
// // // // // // //       final data =
// // // // // // //       await rootBundle.loadString('assets/model/oldlabels.txt');
// // // // // // //       labels =
// // // // // // //           data.split('\n').where((e) => e.trim().isNotEmpty).toList();
// // // // // // //     } catch (e) {
// // // // // // //       setState(() {
// // // // // // //         result = "❌ Label load error: $e";
// // // // // // //       });
// // // // // // //     }
// // // // // // //   }
// // // // // // //
// // // // // // //   Future<void> _pickImage() async {
// // // // // // //     if (!isModelLoaded) {
// // // // // // //       setState(() {
// // // // // // //         result = "⏳ Model not loaded yet";
// // // // // // //       });
// // // // // // //       return;
// // // // // // //     }
// // // // // // //
// // // // // // //     final picker = ImagePicker();
// // // // // // //     final pickedFile =
// // // // // // //     await picker.pickImage(source: ImageSource.gallery);
// // // // // // //
// // // // // // //     if (pickedFile == null) return;
// // // // // // //
// // // // // // //     setState(() {
// // // // // // //       _image = File(pickedFile.path);
// // // // // // //       result = "Processing...";
// // // // // // //     });
// // // // // // //
// // // // // // //     await _runModel(_image!);
// // // // // // //   }
// // // // // // //
// // // // // // //   Future<void> _runModel(File imageFile) async {
// // // // // // //     try {
// // // // // // //       final bytes = await imageFile.readAsBytes();
// // // // // // //       final image = decodeImage(bytes);
// // // // // // //
// // // // // // //       if (image == null) {
// // // // // // //         setState(() {
// // // // // // //           result = "❌ Invalid image";
// // // // // // //         });
// // // // // // //         return;
// // // // // // //       }
// // // // // // //
// // // // // // //       final resized = copyResize(image, width: 224, height: 224);
// // // // // // //
// // // // // // //       // FLOAT MODEL INPUT
// // // // // // //       var input = List.generate(
// // // // // // //         1,
// // // // // // //             (_) => List.generate(
// // // // // // //           224,
// // // // // // //               (y) => List.generate(
// // // // // // //             224,
// // // // // // //                 (x) {
// // // // // // //               final pixel = resized.getPixel(x, y);
// // // // // // //               return [
// // // // // // //                 pixel.r / 255.0,
// // // // // // //                 pixel.g / 255.0,
// // // // // // //                 pixel.b / 255.0,
// // // // // // //               ];
// // // // // // //             },
// // // // // // //           ),
// // // // // // //         ),
// // // // // // //       );
// // // // // // //
// // // // // // //       var output =
// // // // // // //       List.generate(1, (_) => List.filled(labels.length, 0.0));
// // // // // // //
// // // // // // //       interpreter.run(input, output);
// // // // // // //
// // // // // // //       print("Output: $output"); // debug
// // // // // // //
// // // // // // //       int maxIndex = 0;
// // // // // // //       double maxScore = 0;
// // // // // // //
// // // // // // //       for (int i = 0; i < labels.length; i++) {
// // // // // // //         if (output[0][i] > maxScore) {
// // // // // // //           maxScore = output[0][i];
// // // // // // //           maxIndex = i;
// // // // // // //         }
// // // // // // //       }
// // // // // // //
// // // // // // //       // LOW CONFIDENCE CHECK
// // // // // // //       if (maxScore < 0.5) {
// // // // // // //         setState(() {
// // // // // // //           result = "❌ Data not found (low confidence)";
// // // // // // //         });
// // // // // // //         return;
// // // // // // //       }
// // // // // // //
// // // // // // //       setState(() {
// // // // // // //         result =
// // // // // // //         "Model: ${labels[maxIndex]}\nConfidence: ${(maxScore * 100).toStringAsFixed(2)}%";
// // // // // // //       });
// // // // // // //     } catch (e) {
// // // // // // //       setState(() {
// // // // // // //         result = "❌ Error: $e";
// // // // // // //       });
// // // // // // //       print("ERROR: $e");
// // // // // // //     }
// // // // // // //   }
// // // // // // //
// // // // // // //   @override
// // // // // // //   Widget build(BuildContext context) {
// // // // // // //     return Scaffold(
// // // // // // //       appBar: AppBar(
// // // // // // //         title: const Text("Rubber Model Detection"),
// // // // // // //       ),
// // // // // // //       body: Center(
// // // // // // //         child: Column(
// // // // // // //           mainAxisAlignment: MainAxisAlignment.center,
// // // // // // //           children: [
// // // // // // //             _image != null
// // // // // // //                 ? Image.file(_image!, height: 200)
// // // // // // //                 : const Text("No image selected"),
// // // // // // //
// // // // // // //             const SizedBox(height: 20),
// // // // // // //
// // // // // // //             Text(
// // // // // // //               result,
// // // // // // //               textAlign: TextAlign.center,
// // // // // // //               style: const TextStyle(fontSize: 18),
// // // // // // //             ),
// // // // // // //
// // // // // // //             const SizedBox(height: 20),
// // // // // // //
// // // // // // //             ElevatedButton(
// // // // // // //               onPressed: isModelLoaded ? _pickImage : null,
// // // // // // //               child: Text(
// // // // // // //                 isModelLoaded
// // // // // // //                     ? "Select Image"
// // // // // // //                     : "Loading Model...",
// // // // // // //               ),
// // // // // // //             ),
// // // // // // //           ],
// // // // // // //         ),
// // // // // // //       ),
// // // // // // //     );
// // // // // // //   }
// // // // // // // }
// // // // // //
// // // // // //
// // // // // //
// // // // // // import 'dart:io';
// // // // // // import 'package:flutter/material.dart';
// // // // // // import 'package:flutter/services.dart';
// // // // // // import 'package:image_picker/image_picker.dart';
// // // // // // import 'package:tflite_flutter/tflite_flutter.dart';
// // // // // // import 'package:image/image.dart' as img;
// // // // // //
// // // // // // void main() {
// // // // // //   runApp(const MyApp());
// // // // // // }
// // // // // //
// // // // // // class MyApp extends StatelessWidget {
// // // // // //   const MyApp({super.key});
// // // // // //
// // // // // //   @override
// // // // // //   Widget build(BuildContext context) {
// // // // // //     return const MaterialApp(
// // // // // //       debugShowCheckedModeBanner: false,
// // // // // //       home: HomePage(),
// // // // // //     );
// // // // // //   }
// // // // // // }
// // // // // //
// // // // // // class HomePage extends StatefulWidget {
// // // // // //   const HomePage({super.key});
// // // // // //
// // // // // //   @override
// // // // // //   State<HomePage> createState() => _HomePageState();
// // // // // // }
// // // // // //
// // // // // // class _HomePageState extends State<HomePage> {
// // // // // //   File? imageFile;
// // // // // //   String result = "No prediction yet";
// // // // // //
// // // // // //   late Interpreter interpreter;
// // // // // //   List<String> labels = [];
// // // // // //   bool isLoaded = false;
// // // // // //
// // // // // //   late List<int> inputShape;
// // // // // //   late TensorType inputType;
// // // // // //
// // // // // //   @override
// // // // // //   void initState() {
// // // // // //     super.initState();
// // // // // //     init();
// // // // // //   }
// // // // // //
// // // // // //   Future<void> init() async {
// // // // // //     await loadModel();
// // // // // //     await loadLabels();
// // // // // //   }
// // // // // //
// // // // // //   Future<void> loadModel() async {
// // // // // //     try {
// // // // // //       interpreter = await Interpreter.fromAsset(
// // // // // //         'assets/model/rubber_model.tflite',
// // // // // //       );
// // // // // //
// // // // // //       inputShape = interpreter.getInputTensor(0).shape;
// // // // // //       inputType = interpreter.getInputTensor(0).type;
// // // // // //
// // // // // //       print("INPUT SHAPE: $inputShape");
// // // // // //       print("INPUT TYPE: $inputType");
// // // // // //
// // // // // //       print("OUTPUT SHAPE: ${interpreter.getOutputTensor(0).shape}");
// // // // // //       print("OUTPUT TYPE: ${interpreter.getOutputTensor(0).type}");
// // // // // //
// // // // // //       setState(() {
// // // // // //         isLoaded = true;
// // // // // //       });
// // // // // //     } catch (e) {
// // // // // //       setState(() {
// // // // // //         result = "Model load error: $e";
// // // // // //       });
// // // // // //     }
// // // // // //   }
// // // // // //
// // // // // //   Future<void> loadLabels() async {
// // // // // //     final data = await rootBundle.loadString('assets/model/oldlabels.txt');
// // // // // //     labels = data.split('\n').where((e) => e.trim().isNotEmpty).toList();
// // // // // //   }
// // // // // //
// // // // // //   Future<void> pickImage() async {
// // // // // //     if (!isLoaded) {
// // // // // //       setState(() => result = "Model not loaded yet");
// // // // // //       return;
// // // // // //     }
// // // // // //
// // // // // //     final picker = ImagePicker();
// // // // // //     final picked = await picker.pickImage(source: ImageSource.gallery);
// // // // // //
// // // // // //     if (picked == null) return;
// // // // // //
// // // // // //     setState(() {
// // // // // //       imageFile = File(picked.path);
// // // // // //       result = "Processing...";
// // // // // //     });
// // // // // //
// // // // // //     await runModel(imageFile!);
// // // // // //   }
// // // // // //
// // // // // //   Future<void> runModel(File file) async {
// // // // // //     try {
// // // // // //       final bytes = await file.readAsBytes();
// // // // // //       img.Image? image = img.decodeImage(bytes);
// // // // // //
// // // // // //       if (image == null) {
// // // // // //         setState(() => result = "Invalid image");
// // // // // //         return;
// // // // // //       }
// // // // // //
// // // // // //       int height = inputShape[1];
// // // // // //       int width = inputShape[2];
// // // // // //
// // // // // //       img.Image resized = img.copyResize(image, width: width, height: height);
// // // // // //
// // // // // //       var input;
// // // // // //
// // // // // //       // ✅ FLOAT MODEL
// // // // // //       if (inputType == TensorType.float32) {
// // // // // //         input = List.generate(
// // // // // //           1,
// // // // // //               (_) => List.generate(
// // // // // //             height,
// // // // // //                 (y) => List.generate(
// // // // // //               width,
// // // // // //                   (x) {
// // // // // //                 final pixel = resized.getPixel(x, y);
// // // // // //
// // // // // //                 return [
// // // // // //                   (pixel.r - 127.5) / 127.5,
// // // // // //                   (pixel.g - 127.5) / 127.5,
// // // // // //                   (pixel.b - 127.5) / 127.5,
// // // // // //                 ];
// // // // // //               },
// // // // // //             ),
// // // // // //           ),
// // // // // //         );
// // // // // //       } else {
// // // // // //         // ✅ UINT8 MODEL
// // // // // //         input = List.generate(
// // // // // //           1,
// // // // // //               (_) => List.generate(
// // // // // //             height,
// // // // // //                 (y) => List.generate(
// // // // // //               width,
// // // // // //                   (x) {
// // // // // //                 final pixel = resized.getPixel(x, y);
// // // // // //
// // // // // //                 return [
// // // // // //                   pixel.r,
// // // // // //                   pixel.g,
// // // // // //                   pixel.b,
// // // // // //                 ];
// // // // // //               },
// // // // // //             ),
// // // // // //           ),
// // // // // //         );
// // // // // //       }
// // // // // //
// // // // // //       var output = List.generate(1, (_) => List.filled(labels.length, 0.0));
// // // // // //
// // // // // //       interpreter.run(input, output);
// // // // // //
// // // // // //       print("RAW OUTPUT: ${output[0]}");
// // // // // //
// // // // // //       int maxIndex = 0;
// // // // // //       double maxScore = output[0][0];
// // // // // //
// // // // // //       for (int i = 1; i < labels.length; i++) {
// // // // // //         if (output[0][i] > maxScore) {
// // // // // //           maxScore = output[0][i];
// // // // // //           maxIndex = i;
// // // // // //         }
// // // // // //       }
// // // // // //
// // // // // //       // ✅ LOW CONFIDENCE FILTER
// // // // // //       if (maxScore < 0.5) {
// // // // // //         setState(() {
// // // // // //           result = "❌ Data not found";
// // // // // //         });
// // // // // //         return;
// // // // // //       }
// // // // // //
// // // // // //       setState(() {
// // // // // //         result =
// // // // // //         "Prediction: ${labels[maxIndex]}\nConfidence: ${(maxScore * 100).toStringAsFixed(2)}%";
// // // // // //       });
// // // // // //     } catch (e) {
// // // // // //       setState(() {
// // // // // //         result = "❌ Error: $e";
// // // // // //       });
// // // // // //       print("ERROR: $e");
// // // // // //     }
// // // // // //   }
// // // // // //
// // // // // //   @override
// // // // // //   Widget build(BuildContext context) {
// // // // // //     return Scaffold(
// // // // // //       appBar: AppBar(title: const Text("Model Tester")),
// // // // // //       body: Center(
// // // // // //         child: Column(
// // // // // //           mainAxisAlignment: MainAxisAlignment.center,
// // // // // //           children: [
// // // // // //             imageFile != null
// // // // // //                 ? Image.file(imageFile!, height: 200)
// // // // // //                 : const Text("No image selected"),
// // // // // //             const SizedBox(height: 20),
// // // // // //             Text(result, textAlign: TextAlign.center),
// // // // // //             const SizedBox(height: 20),
// // // // // //             ElevatedButton(
// // // // // //               onPressed: isLoaded ? pickImage : null,
// // // // // //               child: Text(isLoaded ? "Select Image" : "Loading Model..."),
// // // // // //             ),
// // // // // //           ],
// // // // // //         ),
// // // // // //       ),
// // // // // //     );
// // // // // //   }
// // // // // // }
// // // // //
// // // // //
// // // // //
// // // // // import 'dart:io';
// // // // // import 'package:flutter/material.dart';
// // // // // import 'package:flutter/services.dart';
// // // // // import 'package:image_picker/image_picker.dart';
// // // // // import 'package:tflite_flutter/tflite_flutter.dart';
// // // // // import 'package:image/image.dart' as img;
// // // // //
// // // // // void main() {
// // // // //   runApp(const MyApp());
// // // // // }
// // // // //
// // // // // class MyApp extends StatelessWidget {
// // // // //   const MyApp({super.key});
// // // // //
// // // // //   @override
// // // // //   Widget build(BuildContext context) {
// // // // //     return MaterialApp(
// // // // //       debugShowCheckedModeBanner: false,
// // // // //       title: 'Rubber Seal Classifier',
// // // // //       theme: ThemeData(
// // // // //         useMaterial3: true,
// // // // //         colorScheme: ColorScheme.fromSeed(
// // // // //           seedColor: Colors.indigo,
// // // // //           brightness: Brightness.light,
// // // // //         ),
// // // // //       ),
// // // // //       home: const HomePage(),
// // // // //     );
// // // // //   }
// // // // // }
// // // // //
// // // // // class HomePage extends StatefulWidget {
// // // // //   const HomePage({super.key});
// // // // //
// // // // //   @override
// // // // //   State<HomePage> createState() => _HomePageState();
// // // // // }
// // // // //
// // // // // class _HomePageState extends State<HomePage> {
// // // // //   File? imageFile;
// // // // //   String prediction = "Ready to Scan";
// // // // //   double confidence = 0.0;
// // // // //   bool isBusy = false;
// // // // //
// // // // //   late Interpreter interpreter;
// // // // //   List<String> labels = [];
// // // // //   bool isModelLoaded = false;
// // // // //
// // // // //   late List<int> inputShape;
// // // // //   late TensorType inputType;
// // // // //
// // // // //   @override
// // // // //   void initState() {
// // // // //     super.initState();
// // // // //     initApp();
// // // // //   }
// // // // //
// // // // //   Future<void> initApp() async {
// // // // //     await loadModel();
// // // // //     await loadLabels();
// // // // //   }
// // // // //
// // // // //   Future<void> loadModel() async {
// // // // //     try {
// // // // //       // Ensure model path matches your pubspec.yaml assets section
// // // // //       interpreter = await Interpreter.fromAsset('assets/model/rubber_model.tflite');
// // // // //
// // // // //       inputShape = interpreter.getInputTensor(0).shape;
// // // // //       inputType = interpreter.getInputTensor(0).type;
// // // // //
// // // // //       debugPrint("INPUT SHAPE: $inputShape");
// // // // //       setState(() {
// // // // //         isModelLoaded = true;
// // // // //       });
// // // // //     } catch (e) {
// // // // //       setState(() {
// // // // //         prediction = "Model load error: $e";
// // // // //       });
// // // // //     }
// // // // //   }
// // // // //
// // // // //   Future<void> loadLabels() async {
// // // // //     try {
// // // // //       final data = await rootBundle.loadString('assets/model/oldlabels.txt');
// // // // //       labels = data.split('\n').where((e) => e.trim().isNotEmpty).toList();
// // // // //     } catch (e) {
// // // // //       debugPrint("Label loading error: $e");
// // // // //     }
// // // // //   }
// // // // //
// // // // //   Future<void> pickAndRun(ImageSource source) async {
// // // // //     if (!isModelLoaded) return;
// // // // //
// // // // //     final picker = ImagePicker();
// // // // //     final picked = await picker.pickImage(source: source);
// // // // //
// // // // //     if (picked == null) return;
// // // // //
// // // // //     setState(() {
// // // // //       imageFile = File(picked.path);
// // // // //       isBusy = true;
// // // // //       prediction = "Analyzing Profile...";
// // // // //     });
// // // // //
// // // // //     await runInference(imageFile!);
// // // // //   }
// // // // //
// // // // //   Future<void> runInference(File file) async {
// // // // //     try {
// // // // //       final bytes = await file.readAsBytes();
// // // // //       img.Image? image = img.decodeImage(bytes);
// // // // //
// // // // //       if (image == null) {
// // // // //         setState(() {
// // // // //           prediction = "Invalid image format";
// // // // //           isBusy = false;
// // // // //         });
// // // // //         return;
// // // // //       }
// // // // //
// // // // //       // Model usually expects 224x224
// // // // //       int height = inputShape[1];
// // // // //       int width = inputShape[2];
// // // // //
// // // // //       img.Image resized = img.copyResize(image, width: width, height: height);
// // // // //
// // // // //       // ✅ MATCHING train.py LOGIC
// // // // //       // The model in train.py has internal rescaling [layers.Rescaling(1./127.5, offset=-1.0)]
// // // // //       // So we must pass RAW double values (0.0 to 255.0).
// // // // //       var input = List.generate(
// // // // //         1,
// // // // //             (_) => List.generate(
// // // // //           height,
// // // // //               (y) => List.generate(
// // // // //             width,
// // // // //                 (x) {
// // // // //               final pixel = resized.getPixel(x, y);
// // // // //               return [
// // // // //                 pixel.r.toDouble(),
// // // // //                 pixel.g.toDouble(),
// // // // //                 pixel.b.toDouble(),
// // // // //               ];
// // // // //             },
// // // // //           ),
// // // // //         ),
// // // // //       );
// // // // //
// // // // //       var output = List.generate(1, (_) => List.filled(labels.length, 0.0));
// // // // //
// // // // //       // Run inference
// // // // //       interpreter.run(input, output);
// // // // //
// // // // //       List<double> resultList = List<double>.from(output[0]);
// // // // //       int maxIndex = 0;
// // // // //       double maxScore = resultList[0];
// // // // //
// // // // //       for (int i = 1; i < resultList.length; i++) {
// // // // //         if (resultList[i] > maxScore) {
// // // // //           maxScore = resultList[i];
// // // // //           maxIndex = i;
// // // // //         }
// // // // //       }
// // // // //
// // // // //       setState(() {
// // // // //         isBusy = false;
// // // // //         if (maxScore < 0.4) {
// // // // //           prediction = "Unknown Profile";
// // // // //           confidence = maxScore;
// // // // //         } else {
// // // // //           prediction = labels[maxIndex];
// // // // //           confidence = maxScore;
// // // // //         }
// // // // //       });
// // // // //     } catch (e) {
// // // // //       setState(() {
// // // // //         prediction = "Analysis Error";
// // // // //         isBusy = false;
// // // // //       });
// // // // //       debugPrint("ERROR: $e");
// // // // //     }
// // // // //   }
// // // // //
// // // // //   @override
// // // // //   Widget build(BuildContext context) {
// // // // //     return Scaffold(
// // // // //       backgroundColor: Colors.grey[50],
// // // // //       appBar: AppBar(
// // // // //         title: const Text("Rubber Classifier", style: TextStyle(fontWeight: FontWeight.bold)),
// // // // //         centerTitle: true,
// // // // //         backgroundColor: Colors.white,
// // // // //         elevation: 0,
// // // // //       ),
// // // // //       body: SingleChildScrollView(
// // // // //         padding: const EdgeInsets.all(24),
// // // // //         child: Column(
// // // // //           crossAxisAlignment: CrossAxisAlignment.stretch,
// // // // //           children: [
// // // // //             // Image Preview Container
// // // // //             Container(
// // // // //               height: 300,
// // // // //               decoration: BoxDecoration(
// // // // //                 color: Colors.white,
// // // // //                 borderRadius: BorderRadius.circular(24),
// // // // //                 boxShadow: [
// // // // //                   BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10)),
// // // // //                 ],
// // // // //               ),
// // // // //               clipBehavior: Clip.antiAlias,
// // // // //               child: imageFile != null
// // // // //                   ? Image.file(imageFile!, fit: BoxFit.contain)
// // // // //                   : Column(
// // // // //                 mainAxisAlignment: MainAxisAlignment.center,
// // // // //                 children: [
// // // // //                   Icon(Icons.image_search, size: 64, color: Colors.indigo[200]),
// // // // //                   const SizedBox(height: 12),
// // // // //                   const Text("No Image Selected", style: TextStyle(color: Colors.grey)),
// // // // //                 ],
// // // // //               ),
// // // // //             ),
// // // // //             const SizedBox(height: 32),
// // // // //
// // // // //             // Result Card
// // // // //             Card(
// // // // //               elevation: 0,
// // // // //               shape: RoundedRectangleBorder(
// // // // //                 borderRadius: BorderRadius.circular(20),
// // // // //                 side: BorderSide(color: Colors.indigo.withOpacity(0.1)),
// // // // //               ),
// // // // //               color: Colors.white,
// // // // //               child: Padding(
// // // // //                 padding: const EdgeInsets.all(24),
// // // // //                 child: Column(
// // // // //                   children: [
// // // // //                     Text(
// // // // //                       prediction,
// // // // //                       style: TextStyle(
// // // // //                         fontSize: 24,
// // // // //                         fontWeight: FontWeight.bold,
// // // // //                         color: confidence > 0.7 ? Colors.indigo : Colors.black87,
// // // // //                       ),
// // // // //                       textAlign: TextAlign.center,
// // // // //                     ),
// // // // //                     if (confidence > 0 && !isBusy) ...[
// // // // //                       const SizedBox(height: 16),
// // // // //                       ClipRRect(
// // // // //                         borderRadius: BorderRadius.circular(10),
// // // // //                         child: LinearProgressIndicator(
// // // // //                           value: confidence,
// // // // //                           minHeight: 8,
// // // // //                           backgroundColor: Colors.indigo[50],
// // // // //                           color: Colors.indigo,
// // // // //                         ),
// // // // //                       ),
// // // // //                       const SizedBox(height: 8),
// // // // //                       Text(
// // // // //                         "${(confidence * 100).toStringAsFixed(2)}% Confidence",
// // // // //                         style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
// // // // //                       ),
// // // // //                     ],
// // // // //                     if (isBusy) ...[
// // // // //                       const SizedBox(height: 16),
// // // // //                       const CircularProgressIndicator(),
// // // // //                     ]
// // // // //                   ],
// // // // //                 ),
// // // // //               ),
// // // // //             ),
// // // // //             const SizedBox(height: 32),
// // // // //
// // // // //             // Action Buttons
// // // // //             Row(
// // // // //               children: [
// // // // //                 Expanded(
// // // // //                   child: ElevatedButton.icon(
// // // // //                     onPressed: isModelLoaded ? () => pickAndRun(ImageSource.camera) : null,
// // // // //                     icon: const Icon(Icons.camera_alt),
// // // // //                     label: const Text("Camera"),
// // // // //                     style: ElevatedButton.styleFrom(
// // // // //                       padding: const EdgeInsets.symmetric(vertical: 16),
// // // // //                       backgroundColor: Colors.indigo,
// // // // //                       foregroundColor: Colors.white,
// // // // //                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
// // // // //                     ),
// // // // //                   ),
// // // // //                 ),
// // // // //                 const SizedBox(width: 16),
// // // // //                 Expanded(
// // // // //                   child: OutlinedButton.icon(
// // // // //                     onPressed: isModelLoaded ? () => pickAndRun(ImageSource.gallery) : null,
// // // // //                     icon: const Icon(Icons.photo_library),
// // // // //                     label: const Text("Gallery"),
// // // // //                     style: OutlinedButton.styleFrom(
// // // // //                       padding: const EdgeInsets.symmetric(vertical: 16),
// // // // //                       side: const BorderSide(color: Colors.indigo),
// // // // //                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
// // // // //                     ),
// // // // //                   ),
// // // // //                 ),
// // // // //               ],
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
// // // //
// // // //
// // // //
// // // // import 'dart:io';
// // // // import 'package:flutter/material.dart';
// // // // import 'package:flutter/services.dart';
// // // // import 'package:image_picker/image_picker.dart';
// // // // import 'package:tflite_flutter/tflite_flutter.dart';
// // // // import 'package:image/image.dart' as img;
// // // //
// // // // void main() {
// // // //   runApp(const MyApp());
// // // // }
// // // //
// // // // class MyApp extends StatelessWidget {
// // // //   const MyApp({super.key});
// // // //
// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return MaterialApp(
// // // //       debugShowCheckedModeBanner: false,
// // // //       title: 'Rubber Seal Classifier',
// // // //       theme: ThemeData(
// // // //         useMaterial3: true,
// // // //         colorScheme: ColorScheme.fromSeed(
// // // //           seedColor: Colors.indigo,
// // // //           brightness: Brightness.light,
// // // //         ),
// // // //       ),
// // // //       home: const HomePage(),
// // // //     );
// // // //   }
// // // // }
// // // //
// // // // class HomePage extends StatefulWidget {
// // // //   const HomePage({super.key});
// // // //
// // // //   @override
// // // //   State<HomePage> createState() => _HomePageState();
// // // // }
// // // //
// // // // class PredictionResult {
// // // //   final String label;
// // // //   final double confidence;
// // // //
// // // //   PredictionResult(this.label, this.confidence);
// // // // }
// // // //
// // // // class _HomePageState extends State<HomePage> {
// // // //   File? imageFile;
// // // //   List<PredictionResult> topPredictions = [];
// // // //   String statusMessage = "Ready to Scan";
// // // //   bool isBusy = false;
// // // //   bool isUnmatched = false;
// // // //
// // // //   late Interpreter interpreter;
// // // //   List<String> labels = [];
// // // //   bool isModelLoaded = false;
// // // //
// // // //   late List<int> inputShape;
// // // //   late TensorType inputType;
// // // //
// // // //   @override
// // // //   void initState() {
// // // //     super.initState();
// // // //     initApp();
// // // //   }
// // // //
// // // //   Future<void> initApp() async {
// // // //     await loadModel();
// // // //     await loadLabels();
// // // //   }
// // // //
// // // //   Future<void> loadModel() async {
// // // //     try {
// // // //       interpreter = await Interpreter.fromAsset('assets/model/rubber_model.tflite');
// // // //       inputShape = interpreter.getInputTensor(0).shape;
// // // //       inputType = interpreter.getInputTensor(0).type;
// // // //       setState(() {
// // // //         isModelLoaded = true;
// // // //       });
// // // //     } catch (e) {
// // // //       setState(() {
// // // //         statusMessage = "Model load error: $e";
// // // //       });
// // // //     }
// // // //   }
// // // //
// // // //   Future<void> loadLabels() async {
// // // //     try {
// // // //       final data = await rootBundle.loadString('assets/model/oldlabels.txt');
// // // //       labels = data.split('\n').where((e) => e.trim().isNotEmpty).toList();
// // // //     } catch (e) {
// // // //       debugPrint("Label loading error: $e");
// // // //     }
// // // //   }
// // // //
// // // //   Future<void> pickAndRun(ImageSource source) async {
// // // //     if (!isModelLoaded) return;
// // // //
// // // //     final picker = ImagePicker();
// // // //     final picked = await picker.pickImage(source: source);
// // // //
// // // //     if (picked == null) return;
// // // //
// // // //     setState(() {
// // // //       imageFile = File(picked.path);
// // // //       isBusy = true;
// // // //       isUnmatched = false;
// // // //       statusMessage = "Analyzing Profile...";
// // // //       topPredictions = [];
// // // //     });
// // // //
// // // //     await runInference(imageFile!);
// // // //   }
// // // //
// // // //   Future<void> runInference(File file) async {
// // // //     try {
// // // //       final bytes = await file.readAsBytes();
// // // //       img.Image? image = img.decodeImage(bytes);
// // // //
// // // //       if (image == null) {
// // // //         setState(() {
// // // //           statusMessage = "Invalid image format";
// // // //           isBusy = false;
// // // //         });
// // // //         return;
// // // //       }
// // // //
// // // //       int height = inputShape[1];
// // // //       int width = inputShape[2];
// // // //       img.Image resized = img.copyResize(image, width: width, height: height);
// // // //
// // // //       var input = List.generate(
// // // //         1,
// // // //             (_) => List.generate(
// // // //           height,
// // // //               (y) => List.generate(
// // // //             width,
// // // //                 (x) {
// // // //               final pixel = resized.getPixel(x, y);
// // // //               return [
// // // //                 pixel.r.toDouble(),
// // // //                 pixel.g.toDouble(),
// // // //                 pixel.b.toDouble(),
// // // //               ];
// // // //             },
// // // //           ),
// // // //         ),
// // // //       );
// // // //
// // // //       var output = List.generate(1, (_) => List.filled(labels.length, 0.0));
// // // //       interpreter.run(input, output);
// // // //
// // // //       List<double> resultList = List<double>.from(output[0]);
// // // //
// // // //       // Map labels to their scores
// // // //       List<PredictionResult> results = [];
// // // //       for (int i = 0; i < labels.length; i++) {
// // // //         results.add(PredictionResult(labels[i], resultList[i]));
// // // //       }
// // // //
// // // //       // Sort by confidence descending
// // // //       results.sort((a, b) => b.confidence.compareTo(a.confidence));
// // // //
// // // //       setState(() {
// // // //         isBusy = false;
// // // //         // Threshold check: If the top result is very weak, declare as unmatched
// // // //         if (results.isNotEmpty && results[0].confidence < 0.35) {
// // // //           isUnmatched = true;
// // // //           statusMessage = "Data Not Matched";
// // // //           topPredictions = [];
// // // //         } else {
// // // //           isUnmatched = false;
// // // //           statusMessage = "Analysis Complete";
// // // //           // Take top 3
// // // //           topPredictions = results.take(3).toList();
// // // //         }
// // // //       });
// // // //     } catch (e) {
// // // //       setState(() {
// // // //         statusMessage = "Analysis Error";
// // // //         isBusy = false;
// // // //       });
// // // //       debugPrint("ERROR: $e");
// // // //     }
// // // //   }
// // // //
// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return Scaffold(
// // // //       backgroundColor: Colors.grey[50],
// // // //       appBar: AppBar(
// // // //         title: const Text("Rubber Classifier", style: TextStyle(fontWeight: FontWeight.bold)),
// // // //         centerTitle: true,
// // // //         backgroundColor: Colors.white,
// // // //         elevation: 0,
// // // //       ),
// // // //       body: SingleChildScrollView(
// // // //         padding: const EdgeInsets.all(24),
// // // //         child: Column(
// // // //           crossAxisAlignment: CrossAxisAlignment.stretch,
// // // //           children: [
// // // //             // Image Preview
// // // //             Container(
// // // //               height: 280,
// // // //               decoration: BoxDecoration(
// // // //                 color: Colors.white,
// // // //                 borderRadius: BorderRadius.circular(24),
// // // //                 boxShadow: [
// // // //                   BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10)),
// // // //                 ],
// // // //               ),
// // // //               clipBehavior: Clip.antiAlias,
// // // //               child: imageFile != null
// // // //                   ? Image.file(imageFile!, fit: BoxFit.contain)
// // // //                   : Column(
// // // //                 mainAxisAlignment: MainAxisAlignment.center,
// // // //                 children: [
// // // //                   Icon(Icons.image_search, size: 64, color: Colors.indigo[200]),
// // // //                   const SizedBox(height: 12),
// // // //                   const Text("No Image Selected", style: TextStyle(color: Colors.grey)),
// // // //                 ],
// // // //               ),
// // // //             ),
// // // //             const SizedBox(height: 24),
// // // //
// // // //             // Status Message
// // // //             Text(
// // // //               statusMessage,
// // // //               style: TextStyle(
// // // //                 fontSize: 14,
// // // //                 fontWeight: FontWeight.w600,
// // // //                 color: isUnmatched ? Colors.redAccent : Colors.indigo[300],
// // // //                 letterSpacing: 1.1,
// // // //               ),
// // // //               textAlign: TextAlign.center,
// // // //             ),
// // // //             const SizedBox(height: 16),
// // // //
// // // //             // Results Section
// // // //             if (isBusy)
// // // //               const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
// // // //             else if (isUnmatched)
// // // //               _buildErrorCard()
// // // //             else if (topPredictions.isNotEmpty)
// // // //                 ...topPredictions.asMap().entries.map((entry) {
// // // //                   int idx = entry.key;
// // // //                   PredictionResult res = entry.value;
// // // //                   return _buildResultTile(res, isHighlyRecommended: idx == 0);
// // // //                 }),
// // // //
// // // //             const SizedBox(height: 32),
// // // //
// // // //             // Buttons
// // // //             Row(
// // // //               children: [
// // // //                 Expanded(
// // // //                   child: ElevatedButton.icon(
// // // //                     onPressed: isModelLoaded && !isBusy ? () => pickAndRun(ImageSource.camera) : null,
// // // //                     icon: const Icon(Icons.camera_alt),
// // // //                     label: const Text("Camera"),
// // // //                     style: ElevatedButton.styleFrom(
// // // //                       padding: const EdgeInsets.symmetric(vertical: 16),
// // // //                       backgroundColor: Colors.indigo,
// // // //                       foregroundColor: Colors.white,
// // // //                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
// // // //                     ),
// // // //                   ),
// // // //                 ),
// // // //                 const SizedBox(width: 16),
// // // //                 Expanded(
// // // //                   child: OutlinedButton.icon(
// // // //                     onPressed: isModelLoaded && !isBusy ? () => pickAndRun(ImageSource.gallery) : null,
// // // //                     icon: const Icon(Icons.photo_library),
// // // //                     label: const Text("Gallery"),
// // // //                     style: OutlinedButton.styleFrom(
// // // //                       padding: const EdgeInsets.symmetric(vertical: 16),
// // // //                       side: const BorderSide(color: Colors.indigo),
// // // //                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
// // // //                     ),
// // // //                   ),
// // // //                 ),
// // // //               ],
// // // //             ),
// // // //           ],
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }
// // // //
// // // //   Widget _buildResultTile(PredictionResult res, {required bool isHighlyRecommended}) {
// // // //     return Card(
// // // //       elevation: isHighlyRecommended ? 2 : 0,
// // // //       margin: const EdgeInsets.only(bottom: 12),
// // // //       shape: RoundedRectangleBorder(
// // // //         borderRadius: BorderRadius.circular(16),
// // // //         side: BorderSide(
// // // //           color: isHighlyRecommended ? Colors.indigo : Colors.indigo.withOpacity(0.1),
// // // //           width: isHighlyRecommended ? 2 : 1,
// // // //         ),
// // // //       ),
// // // //       color: Colors.white,
// // // //       child: Padding(
// // // //         padding: const EdgeInsets.all(16),
// // // //         child: Column(
// // // //           crossAxisAlignment: CrossAxisAlignment.start,
// // // //           children: [
// // // //             Row(
// // // //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // // //               children: [
// // // //                 Row(
// // // //                   children: [
// // // //                     Text(
// // // //                       res.label,
// // // //                       style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
// // // //                     ),
// // // //                     if (isHighlyRecommended)
// // // //                       Container(
// // // //                         margin: const EdgeInsets.only(left: 8),
// // // //                         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
// // // //                         decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(6)),
// // // //                         child: Text("HIGHLY RECOMMENDED",
// // // //                             style: TextStyle(color: Colors.green[700], fontSize: 10, fontWeight: FontWeight.w900)),
// // // //                       ),
// // // //                   ],
// // // //                 ),
// // // //                 Text("${(res.confidence * 100).toStringAsFixed(1)}%",
// // // //                     style: TextStyle(fontWeight: FontWeight.w900, color: Colors.indigo[700])),
// // // //               ],
// // // //             ),
// // // //             const SizedBox(height: 12),
// // // //             ClipRRect(
// // // //               borderRadius: BorderRadius.circular(4),
// // // //               child: LinearProgressIndicator(
// // // //                 value: res.confidence,
// // // //                 minHeight: 6,
// // // //                 backgroundColor: Colors.indigo[50],
// // // //                 color: isHighlyRecommended ? Colors.indigo : Colors.indigo[200],
// // // //               ),
// // // //             ),
// // // //           ],
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }
// // // //
// // // //   Widget _buildErrorCard() {
// // // //     return Container(
// // // //       padding: const EdgeInsets.all(24),
// // // //       decoration: BoxDecoration(
// // // //         color: Colors.red[50],
// // // //         borderRadius: BorderRadius.circular(20),
// // // //         // FIXED: Used Border.all() instead of BorderSide
// // // //         border: Border.all(color: Colors.red.withOpacity(0.2)),
// // // //       ),
// // // //       child: Column(
// // // //         children: [
// // // //           Icon(Icons.warning_amber_rounded, color: Colors.red[400], size: 48),
// // // //           const SizedBox(height: 12),
// // // //           Text(
// // // //             "Profile Not Found",
// // // //             style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red[900]),
// // // //           ),
// // // //           const SizedBox(height: 8),
// // // //           Text(
// // // //             "The scanned object does not match any known rubber models in our database.",
// // // //             textAlign: TextAlign.center,
// // // //             style: TextStyle(color: Colors.red[700]),
// // // //           ),
// // // //         ],
// // // //       ),
// // // //     );
// // // //   }
// // // // }
// // //
// // //
// // // import 'dart:io';
// // // import 'package:flutter/material.dart';
// // // import 'package:flutter/services.dart';
// // // import 'package:image_picker/image_picker.dart';
// // // import 'package:tflite_flutter/tflite_flutter.dart';
// // // import 'package:image/image.dart' as img;
// // //
// // // void main() {
// // //   runApp(const MyApp());
// // // }
// // //
// // // class MyApp extends StatelessWidget {
// // //   const MyApp({super.key});
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return MaterialApp(
// // //       debugShowCheckedModeBanner: false,
// // //       title: 'Rubber Seal Classifier',
// // //       theme: ThemeData(
// // //         useMaterial3: true,
// // //         colorScheme: ColorScheme.fromSeed(
// // //           seedColor: Colors.indigo,
// // //           brightness: Brightness.light,
// // //         ),
// // //       ),
// // //       home: const HomePage(),
// // //     );
// // //   }
// // // }
// // //
// // // class HomePage extends StatefulWidget {
// // //   const HomePage({super.key});
// // //
// // //   @override
// // //   State<HomePage> createState() => _HomePageState();
// // // }
// // //
// // // class PredictionResult {
// // //   final String label;
// // //   final double confidence;
// // //
// // //   PredictionResult(this.label, this.confidence);
// // // }
// // //
// // // class _HomePageState extends State<HomePage> {
// // //   File? imageFile;
// // //   List<PredictionResult> topPredictions = [];
// // //   String statusMessage = "Ready to Scan";
// // //   bool isBusy = false;
// // //   bool isUnmatched = false;
// // //
// // //   late Interpreter interpreter;
// // //   List<String> labels = [];
// // //   bool isModelLoaded = false;
// // //
// // //   late List<int> inputShape;
// // //   late TensorType inputType;
// // //
// // //   // ✅ CRITICAL: Rejection Threshold
// // //   // For an industrial model with 4 classes, any result below 70%
// // //   // is likely a false positive (random object).
// // //   final double matchThreshold = 0.70;
// // //
// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     initApp();
// // //   }
// // //
// // //   Future<void> initApp() async {
// // //     await loadModel();
// // //     await loadLabels();
// // //   }
// // //
// // //   Future<void> loadModel() async {
// // //     try {
// // //       interpreter = await Interpreter.fromAsset('assets/model/rubber_model.tflite');
// // //       inputShape = interpreter.getInputTensor(0).shape;
// // //       inputType = interpreter.getInputTensor(0).type;
// // //       setState(() {
// // //         isModelLoaded = true;
// // //       });
// // //     } catch (e) {
// // //       setState(() {
// // //         statusMessage = "Model load error: $e";
// // //       });
// // //     }
// // //   }
// // //
// // //   Future<void> loadLabels() async {
// // //     try {
// // //       final data = await rootBundle.loadString('assets/model/oldlabels.txt');
// // //       labels = data.split('\n').where((e) => e.trim().isNotEmpty).toList();
// // //     } catch (e) {
// // //       debugPrint("Label loading error: $e");
// // //     }
// // //   }
// // //
// // //   Future<void> pickAndRun(ImageSource source) async {
// // //     if (!isModelLoaded) return;
// // //
// // //     final picker = ImagePicker();
// // //     final picked = await picker.pickImage(source: source);
// // //
// // //     if (picked == null) return;
// // //
// // //     setState(() {
// // //       imageFile = File(picked.path);
// // //       isBusy = true;
// // //       isUnmatched = false;
// // //       statusMessage = "Analyzing Profile...";
// // //       topPredictions = [];
// // //     });
// // //
// // //     await runInference(imageFile!);
// // //   }
// // //
// // //   Future<void> runInference(File file) async {
// // //     try {
// // //       final bytes = await file.readAsBytes();
// // //       img.Image? image = img.decodeImage(bytes);
// // //
// // //       if (image == null) {
// // //         setState(() {
// // //           statusMessage = "Invalid image format";
// // //           isBusy = false;
// // //         });
// // //         return;
// // //       }
// // //
// // //       int height = inputShape[1];
// // //       int width = inputShape[2];
// // //       img.Image resized = img.copyResize(image, width: width, height: height);
// // //
// // //       var input = List.generate(
// // //         1,
// // //             (_) => List.generate(
// // //           height,
// // //               (y) => List.generate(
// // //             width,
// // //                 (x) {
// // //               final pixel = resized.getPixel(x, y);
// // //               return [
// // //                 pixel.r.toDouble(),
// // //                 pixel.g.toDouble(),
// // //                 pixel.b.toDouble(),
// // //               ];
// // //             },
// // //           ),
// // //         ),
// // //       );
// // //
// // //       var output = List.generate(1, (_) => List.filled(labels.length, 0.0));
// // //       interpreter.run(input, output);
// // //
// // //       List<double> resultList = List<double>.from(output[0]);
// // //
// // //       List<PredictionResult> results = [];
// // //       for (int i = 0; i < labels.length; i++) {
// // //         results.add(PredictionResult(labels[i], resultList[i]));
// // //       }
// // //
// // //       results.sort((a, b) => b.confidence.compareTo(a.confidence));
// // //
// // //       setState(() {
// // //         isBusy = false;
// // //         // Check if the top result meets our strict industrial threshold
// // //         if (results.isNotEmpty && results[0].confidence < matchThreshold) {
// // //           isUnmatched = true;
// // //           statusMessage = "Data Not Matched";
// // //           topPredictions = [];
// // //         } else {
// // //           isUnmatched = false;
// // //           statusMessage = "Top Matches Found";
// // //           topPredictions = results.take(3).toList();
// // //         }
// // //       });
// // //     } catch (e) {
// // //       setState(() {
// // //         statusMessage = "Analysis Error";
// // //         isBusy = false;
// // //       });
// // //       debugPrint("ERROR: $e");
// // //     }
// // //   }
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       backgroundColor: Colors.grey[50],
// // //       appBar: AppBar(
// // //         title: const Text("Rubber Classifier", style: TextStyle(fontWeight: FontWeight.bold)),
// // //         centerTitle: true,
// // //         backgroundColor: Colors.white,
// // //         elevation: 0,
// // //       ),
// // //       body: SingleChildScrollView(
// // //         padding: const EdgeInsets.all(24),
// // //         child: Column(
// // //           crossAxisAlignment: CrossAxisAlignment.stretch,
// // //           children: [
// // //             Container(
// // //               height: 280,
// // //               decoration: BoxDecoration(
// // //                 color: Colors.white,
// // //                 borderRadius: BorderRadius.circular(24),
// // //                 boxShadow: [
// // //                   BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10)),
// // //                 ],
// // //                 border: Border.all(color: Colors.white),
// // //               ),
// // //               clipBehavior: Clip.antiAlias,
// // //               child: imageFile != null
// // //                   ? Image.file(imageFile!, fit: BoxFit.contain)
// // //                   : Column(
// // //                 mainAxisAlignment: MainAxisAlignment.center,
// // //                 children: [
// // //                   Icon(Icons.image_search, size: 64, color: Colors.indigo[200]),
// // //                   const SizedBox(height: 12),
// // //                   const Text("No Image Selected", style: TextStyle(color: Colors.grey)),
// // //                 ],
// // //               ),
// // //             ),
// // //             const SizedBox(height: 24),
// // //
// // //             Text(
// // //               statusMessage,
// // //               style: TextStyle(
// // //                 fontSize: 13,
// // //                 fontWeight: FontWeight.w800,
// // //                 color: isUnmatched ? Colors.redAccent : Colors.indigo[300],
// // //                 letterSpacing: 1.2,
// // //               ),
// // //               textAlign: TextAlign.center,
// // //             ),
// // //             const SizedBox(height: 16),
// // //
// // //             if (isBusy)
// // //               const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
// // //             else if (isUnmatched)
// // //               _buildErrorCard()
// // //             else if (topPredictions.isNotEmpty)
// // //                 ...topPredictions.asMap().entries.map((entry) {
// // //                   int idx = entry.key;
// // //                   PredictionResult res = entry.value;
// // //                   return _buildResultTile(res, isHighlyRecommended: idx == 0);
// // //                 }),
// // //
// // //             const SizedBox(height: 32),
// // //
// // //             Row(
// // //               children: [
// // //                 Expanded(
// // //                   child: ElevatedButton.icon(
// // //                     onPressed: isModelLoaded && !isBusy ? () => pickAndRun(ImageSource.camera) : null,
// // //                     icon: const Icon(Icons.camera_alt),
// // //                     label: const Text("Camera"),
// // //                     style: ElevatedButton.styleFrom(
// // //                       padding: const EdgeInsets.symmetric(vertical: 16),
// // //                       backgroundColor: Colors.indigo,
// // //                       foregroundColor: Colors.white,
// // //                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
// // //                     ),
// // //                   ),
// // //                 ),
// // //                 const SizedBox(width: 16),
// // //                 Expanded(
// // //                   child: OutlinedButton.icon(
// // //                     onPressed: isModelLoaded && !isBusy ? () => pickAndRun(ImageSource.gallery) : null,
// // //                     icon: const Icon(Icons.photo_library),
// // //                     label: const Text("Gallery"),
// // //                     style: OutlinedButton.styleFrom(
// // //                       padding: const EdgeInsets.symmetric(vertical: 16),
// // //                       side: const BorderSide(color: Colors.indigo),
// // //                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
// // //                     ),
// // //                   ),
// // //                 ),
// // //               ],
// // //             ),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }
// // //
// // //   Widget _buildResultTile(PredictionResult res, {required bool isHighlyRecommended}) {
// // //     return Card(
// // //       elevation: isHighlyRecommended ? 2 : 0,
// // //       margin: const EdgeInsets.only(bottom: 12),
// // //       shape: RoundedRectangleBorder(
// // //         borderRadius: BorderRadius.circular(16),
// // //         side: BorderSide(
// // //           color: isHighlyRecommended ? Colors.indigo : Colors.indigo.withOpacity(0.1),
// // //           width: isHighlyRecommended ? 2 : 1,
// // //         ),
// // //       ),
// // //       color: Colors.white,
// // //       child: Padding(
// // //         padding: const EdgeInsets.all(16),
// // //         child: Column(
// // //           crossAxisAlignment: CrossAxisAlignment.start,
// // //           children: [
// // //             Row(
// // //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //               children: [
// // //                 Row(
// // //                   children: [
// // //                     Text(res.label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
// // //                     if (isHighlyRecommended)
// // //                       Container(
// // //                         margin: const EdgeInsets.only(left: 8),
// // //                         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
// // //                         decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(6)),
// // //                         child: Text("HIGHLY RECOMMENDED",
// // //                             style: TextStyle(color: Colors.green[700], fontSize: 10, fontWeight: FontWeight.w900)),
// // //                       ),
// // //                   ],
// // //                 ),
// // //                 Text("${(res.confidence * 100).toStringAsFixed(1)}%",
// // //                     style: TextStyle(fontWeight: FontWeight.w900, color: Colors.indigo[700])),
// // //               ],
// // //             ),
// // //             const SizedBox(height: 12),
// // //             ClipRRect(
// // //               borderRadius: BorderRadius.circular(4),
// // //               child: LinearProgressIndicator(
// // //                 value: res.confidence,
// // //                 minHeight: 6,
// // //                 backgroundColor: Colors.indigo[50],
// // //                 color: isHighlyRecommended ? Colors.indigo : Colors.indigo[200],
// // //               ),
// // //             ),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }
// // //
// // //   Widget _buildErrorCard() {
// // //     return Container(
// // //       padding: const EdgeInsets.all(24),
// // //       decoration: BoxDecoration(
// // //         color: Colors.red[50],
// // //         borderRadius: BorderRadius.circular(20),
// // //         border: Border.all(color: Colors.red.withOpacity(0.2)),
// // //       ),
// // //       child: Column(
// // //         children: [
// // //           Icon(Icons.warning_amber_rounded, color: Colors.red[400], size: 48),
// // //           const SizedBox(height: 12),
// // //           Text("Profile Not Matched",
// // //               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red[900])),
// // //           const SizedBox(height: 8),
// // //           const Text("The object does not match any models in our database with sufficient confidence.",
// // //               textAlign: TextAlign.center, style: TextStyle(color: Colors.red, fontSize: 13)),
// // //         ],
// // //       ),
// // //     );
// // //   }
// // // }
// //
// //
// // import 'dart:io';
// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:image_picker/image_picker.dart';
// // import 'package:tflite_flutter/tflite_flutter.dart';
// // import 'package:image/image.dart' as img;
// //
// // void main() {
// //   runApp(const MyApp());
// // }
// //
// // class MyApp extends StatelessWidget {
// //   const MyApp({super.key});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       debugShowCheckedModeBanner: false,
// //       title: 'Rubber Seal Classifier',
// //       theme: ThemeData(
// //         useMaterial3: true,
// //         colorScheme: ColorScheme.fromSeed(
// //           seedColor: Colors.indigo,
// //           brightness: Brightness.light,
// //         ),
// //       ),
// //       home: const HomePage(),
// //     );
// //   }
// // }
// //
// // class HomePage extends StatefulWidget {
// //   const HomePage({super.key});
// //
// //   @override
// //   State<HomePage> createState() => _HomePageState();
// // }
// //
// // class PredictionResult {
// //   final String label;
// //   final double confidence;
// //
// //   PredictionResult(this.label, this.confidence);
// // }
// //
// // class _HomePageState extends State<HomePage> {
// //   File? imageFile;
// //   List<PredictionResult> topPredictions = [];
// //   String statusMessage = "Ready to Scan";
// //   bool isBusy = false;
// //   bool isUnmatched = false;
// //
// //   late Interpreter interpreter;
// //   List<String> labels = [];
// //   bool isModelLoaded = false;
// //
// //   late List<int> inputShape;
// //   late TensorType inputType;
// //
// //   // ✅ STRICT REJECTION THRESHOLD
// //   // We set this to 85% to ensure that only very clear matches are accepted.
// //   // Industrial profiles should have high confidence if the model is correct.
// //   final double matchThreshold = 0.85;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     initApp();
// //   }
// //
// //   Future<void> initApp() async {
// //     await loadModel();
// //     await loadLabels();
// //   }
// //
// //   Future<void> loadModel() async {
// //     try {
// //       interpreter = await Interpreter.fromAsset('assets/model/rubber_model.tflite');
// //       inputShape = interpreter.getInputTensor(0).shape;
// //       inputType = interpreter.getInputTensor(0).type;
// //       setState(() {
// //         isModelLoaded = true;
// //       });
// //     } catch (e) {
// //       setState(() {
// //         statusMessage = "Model load error: $e";
// //       });
// //     }
// //   }
// //
// //   Future<void> loadLabels() async {
// //     try {
// //       final data = await rootBundle.loadString('assets/model/oldlabels.txt');
// //       labels = data.split('\n').where((e) => e.trim().isNotEmpty).toList();
// //     } catch (e) {
// //       debugPrint("Label loading error: $e");
// //     }
// //   }
// //
// //   Future<void> pickAndRun(ImageSource source) async {
// //     if (!isModelLoaded) return;
// //
// //     final picker = ImagePicker();
// //     final picked = await picker.pickImage(source: source);
// //
// //     if (picked == null) return;
// //
// //     setState(() {
// //       imageFile = File(picked.path);
// //       isBusy = true;
// //       isUnmatched = false;
// //       statusMessage = "Analyzing Profile...";
// //       topPredictions = [];
// //     });
// //
// //     await runInference(imageFile!);
// //   }
// //
// //   Future<void> runInference(File file) async {
// //     try {
// //       final bytes = await file.readAsBytes();
// //       img.Image? image = img.decodeImage(bytes);
// //
// //       if (image == null) {
// //         setState(() {
// //           statusMessage = "Invalid image format";
// //           isBusy = false;
// //         });
// //         return;
// //       }
// //
// //       int height = inputShape[1];
// //       int width = inputShape[2];
// //       img.Image resized = img.copyResize(image, width: width, height: height);
// //
// //       var input = List.generate(
// //         1,
// //             (_) => List.generate(
// //           height,
// //               (y) => List.generate(
// //             width,
// //                 (x) {
// //               final pixel = resized.getPixel(x, y);
// //               return [
// //                 pixel.r.toDouble(),
// //                 pixel.g.toDouble(),
// //                 pixel.b.toDouble(),
// //               ];
// //             },
// //           ),
// //         ),
// //       );
// //
// //       var output = List.generate(1, (_) => List.filled(labels.length, 0.0));
// //       interpreter.run(input, output);
// //
// //       List<double> resultList = List<double>.from(output[0]);
// //
// //       List<PredictionResult> results = [];
// //       for (int i = 0; i < labels.length; i++) {
// //         results.add(PredictionResult(labels[i], resultList[i]));
// //       }
// //
// //       // Sort by confidence descending
// //       results.sort((a, b) => b.confidence.compareTo(a.confidence));
// //
// //       setState(() {
// //         isBusy = false;
// //
// //         // ✅ ENHANCED LOGIC FOR UNMATCHED DATA
// //         // We check two conditions:
// //         // 1. Is the top confidence above our strict 85% threshold?
// //         // 2. Is there a clear gap between the first and second best choice?
// //         // (If the model is guessing between two classes, it's not a reliable match)
// //
// //         bool hasHighConfidence = results.isNotEmpty && results[0].confidence >= matchThreshold;
// //         bool hasClearGap = results.length > 1 ? (results[0].confidence - results[1].confidence) > 0.20 : true;
// //
// //         if (!hasHighConfidence || !hasClearGap) {
// //           isUnmatched = true;
// //           statusMessage = "No Reliable Match Found";
// //           topPredictions = [];
// //         } else {
// //           isUnmatched = false;
// //           statusMessage = "Verified Match Found";
// //           topPredictions = results.take(3).toList();
// //         }
// //       });
// //     } catch (e) {
// //       setState(() {
// //         statusMessage = "Analysis Error";
// //         isBusy = false;
// //       });
// //       debugPrint("ERROR: $e");
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: Colors.grey[50],
// //       appBar: AppBar(
// //         title: const Text("Rubber Classifier", style: TextStyle(fontWeight: FontWeight.bold)),
// //         centerTitle: true,
// //         backgroundColor: Colors.white,
// //         elevation: 0,
// //       ),
// //       body: SingleChildScrollView(
// //         padding: const EdgeInsets.all(24),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.stretch,
// //           children: [
// //             Container(
// //               height: 280,
// //               decoration: BoxDecoration(
// //                 color: Colors.white,
// //                 borderRadius: BorderRadius.circular(24),
// //                 boxShadow: [
// //                   BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10)),
// //                 ],
// //                 border: Border.all(color: Colors.white),
// //               ),
// //               clipBehavior: Clip.antiAlias,
// //               child: imageFile != null
// //                   ? Image.file(imageFile!, fit: BoxFit.contain)
// //                   : Column(
// //                 mainAxisAlignment: MainAxisAlignment.center,
// //                 children: [
// //                   Icon(Icons.image_search, size: 64, color: Colors.indigo[200]),
// //                   const SizedBox(height: 12),
// //                   const Text("No Image Selected", style: TextStyle(color: Colors.grey)),
// //                 ],
// //               ),
// //             ),
// //             const SizedBox(height: 24),
// //
// //             Text(
// //               statusMessage,
// //               style: TextStyle(
// //                 fontSize: 13,
// //                 fontWeight: FontWeight.w800,
// //                 color: isUnmatched ? Colors.orange[800] : Colors.indigo[300],
// //                 letterSpacing: 1.2,
// //               ),
// //               textAlign: TextAlign.center,
// //             ),
// //             const SizedBox(height: 16),
// //
// //             if (isBusy)
// //               const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
// //             else if (isUnmatched)
// //               _buildErrorCard()
// //             else if (topPredictions.isNotEmpty)
// //                 ...topPredictions.asMap().entries.map((entry) {
// //                   int idx = entry.key;
// //                   PredictionResult res = entry.value;
// //                   return _buildResultTile(res, isHighlyRecommended: idx == 0);
// //                 }),
// //
// //             const SizedBox(height: 32),
// //
// //             Row(
// //               children: [
// //                 Expanded(
// //                   child: ElevatedButton.icon(
// //                     onPressed: isModelLoaded && !isBusy ? () => pickAndRun(ImageSource.camera) : null,
// //                     icon: const Icon(Icons.camera_alt),
// //                     label: const Text("Camera"),
// //                     style: ElevatedButton.styleFrom(
// //                       padding: const EdgeInsets.symmetric(vertical: 16),
// //                       backgroundColor: Colors.indigo,
// //                       foregroundColor: Colors.white,
// //                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
// //                     ),
// //                   ),
// //                 ),
// //                 const SizedBox(width: 16),
// //                 Expanded(
// //                   child: OutlinedButton.icon(
// //                     onPressed: isModelLoaded && !isBusy ? () => pickAndRun(ImageSource.gallery) : null,
// //                     icon: const Icon(Icons.photo_library),
// //                     label: const Text("Gallery"),
// //                     style: OutlinedButton.styleFrom(
// //                       padding: const EdgeInsets.symmetric(vertical: 16),
// //                       side: const BorderSide(color: Colors.indigo),
// //                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildResultTile(PredictionResult res, {required bool isHighlyRecommended}) {
// //     return Card(
// //       elevation: isHighlyRecommended ? 2 : 0,
// //       margin: const EdgeInsets.only(bottom: 12),
// //       shape: RoundedRectangleBorder(
// //         borderRadius: BorderRadius.circular(16),
// //         side: BorderSide(
// //           color: isHighlyRecommended ? Colors.indigo : Colors.indigo.withOpacity(0.1),
// //           width: isHighlyRecommended ? 2 : 1,
// //         ),
// //       ),
// //       color: Colors.white,
// //       child: Padding(
// //         padding: const EdgeInsets.all(16),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             Row(
// //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //               children: [
// //                 Row(
// //                   children: [
// //                     Text(res.label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
// //                     if (isHighlyRecommended)
// //                       Container(
// //                         margin: const EdgeInsets.only(left: 8),
// //                         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
// //                         decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(6)),
// //                         child: Text("HIGHLY RECOMMENDED",
// //                             style: TextStyle(color: Colors.green[700], fontSize: 10, fontWeight: FontWeight.w900)),
// //                       ),
// //                   ],
// //                 ),
// //                 Text("${(res.confidence * 100).toStringAsFixed(1)}%",
// //                     style: TextStyle(fontWeight: FontWeight.w900, color: Colors.indigo[700])),
// //               ],
// //             ),
// //             const SizedBox(height: 12),
// //             ClipRRect(
// //               borderRadius: BorderRadius.circular(4),
// //               child: LinearProgressIndicator(
// //                 value: res.confidence,
// //                 minHeight: 6,
// //                 backgroundColor: Colors.indigo[50],
// //                 color: isHighlyRecommended ? Colors.indigo : Colors.indigo[200],
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildErrorCard() {
// //     return Container(
// //       padding: const EdgeInsets.all(24),
// //       decoration: BoxDecoration(
// //         color: Colors.orange[50],
// //         borderRadius: BorderRadius.circular(20),
// //         border: Border.all(color: Colors.orange.withOpacity(0.2)),
// //       ),
// //       child: Column(
// //         children: [
// //           Icon(Icons.search_off_rounded, color: Colors.orange[400], size: 48),
// //           const SizedBox(height: 12),
// //           Text("Data Not Found",
// //               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange[900])),
// //           const SizedBox(height: 8),
// //           const Text("The object does not match any models in our database with sufficient confidence. Please ensure the profile is clear.",
// //               textAlign: TextAlign.center, style: TextStyle(color: Colors.black54, fontSize: 13)),
// //         ],
// //       ),
// //     );
// //   }
// // }
//
// // import 'dart:io';
// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:image_picker/image_picker.dart';
// // import 'package:tflite_flutter/tflite_flutter.dart';
// // import 'package:image/image.dart' as img;
// // import 'package:shared_preferences/shared_preferences.dart';
// // import 'package:tflite_flutter/tflite_flutter.dart';
// // import 'services/model_service.dart';
// // import 'services/file_downloader.dart';
// //
// // void main() {
// //   runApp(const MyApp());
// // }
// //
// // class MyApp extends StatelessWidget {
// //   const MyApp({super.key});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       debugShowCheckedModeBanner: false,
// //       title: 'Rubber Seal Classifier Pro',
// //       theme: ThemeData(
// //         useMaterial3: true,
// //         colorScheme: ColorScheme.fromSeed(
// //           seedColor: Colors.indigo,
// //           brightness: Brightness.light,
// //         ),
// //       ),
// //       home: const HomePage(),
// //     );
// //   }
// // }
// //
// // class HomePage extends StatefulWidget {
// //   const HomePage({super.key});
// //
// //   @override
// //   State<HomePage> createState() => _HomePageState();
// // }
// //
// // class PredictionResult {
// //   final String label;
// //   final double confidence;
// //
// //   PredictionResult(this.label, this.confidence);
// // }
// //
// // class _HomePageState extends State<HomePage> {
// //   List<File> imageFiles = [];
// //   List<PredictionResult> topPredictions = [];
// //   String statusMessage = "Add images to start analysis";
// //   bool isBusy = false;
// //   bool isUnmatched = false;
// //
// //   late Interpreter interpreter;
// //   List<String> labels = [];
// //   bool isModelLoaded = false;
// //
// //   late List<int> inputShape;
// //   late TensorType inputType;
// //
// //   final double matchThreshold = 0.80;
// //   final int maxImageLimit = 5;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     initApp();
// //   }
// //
// //   Future<void> initApp() async {
// //     await loadModel();
// //     await loadLabels();
// //   }
// //
// //   Future<void> loadModel() async {
// //     try {
// //       interpreter = await Interpreter.fromAsset(
// //         'assets/model1/model.tflite',
// //       );
// //       inputShape = interpreter.getInputTensor(0).shape;
// //       inputType = interpreter.getInputTensor(0).type;
// //       setState(() {
// //         isModelLoaded = true;
// //       });
// //     } catch (e) {
// //       setState(() {
// //         statusMessage = "Model load error: $e";
// //       });
// //     }
// //   }
// //
// //   Future<void> loadLabels() async {
// //     try {
// //       final data = await rootBundle.loadString('assets/model1/labels.txt');
// //       labels = data.split('\n').where((e) => e.trim().isNotEmpty).toList();
// //     } catch (e) {
// //       debugPrint("Label loading error: $e");
// //     }
// //   }
// //
// //   void _showLimitWarning(int attempted, int allowed) {
// //     showDialog(
// //       context: context,
// //       builder: (context) => AlertDialog(
// //         title: const Row(
// //           children: [
// //             Icon(Icons.warning_amber_rounded, color: Colors.orange),
// //             SizedBox(width: 10),
// //             Text("Selection Limit"),
// //           ],
// //         ),
// //         content: Text(
// //           "You tried to select $attempted images, but only $allowed more are allowed (Max total: 5).\n\nThe selection has been automatically trimmed.",
// //         ),
// //         actions: [
// //           TextButton(
// //             onPressed: () => Navigator.pop(context),
// //             child: const Text("Understood"),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Future<void> addImage(ImageSource source) async {
// //     if (!isModelLoaded || imageFiles.length >= maxImageLimit) return;
// //
// //     final picker = ImagePicker();
// //
// //     if (source == ImageSource.gallery) {
// //       int remainingSlots = maxImageLimit - imageFiles.length;
// //
// //       // Primary Safety: Pass the 'limit' parameter to the native picker.
// //       // Most modern Android/iOS systems will use this to disable selection
// //       // of items beyond the provided count.
// //       final List<XFile> pickedFiles = await picker.pickMultiImage(
// //         limit: remainingSlots,
// //       );
// //
// //       if (pickedFiles.isEmpty) return;
// //
// //       setState(() {
// //         // Enforce the limit strictly in code if the system picker ignores the hint
// //         if (pickedFiles.length > remainingSlots) {
// //           _showLimitWarning(pickedFiles.length, remainingSlots);
// //         }
// //
// //         var filesToAdd = pickedFiles
// //             .take(remainingSlots)
// //             .map((xFile) => File(xFile.path));
// //         imageFiles.addAll(filesToAdd);
// //
// //         isUnmatched = false;
// //         topPredictions = [];
// //         statusMessage = "Ready to analyze ${imageFiles.length} profiles";
// //       });
// //     } else {
// //       final pickedFile = await picker.pickImage(source: source);
// //       if (pickedFile == null) return;
// //
// //       setState(() {
// //         imageFiles.add(File(pickedFile.path));
// //         isUnmatched = false;
// //         topPredictions = [];
// //         statusMessage = "Ready to analyze ${imageFiles.length} profiles";
// //       });
// //     }
// //   }
// //
// //   void clearImages() {
// //     setState(() {
// //       imageFiles = [];
// //       topPredictions = [];
// //       isUnmatched = false;
// //       statusMessage = "Add images to start analysis";
// //     });
// //   }
// //
// //   Future<void> runMultiInference() async {
// //     if (imageFiles.isEmpty) return;
// //
// //     setState(() {
// //       isBusy = true;
// //       statusMessage = "Aggregating geometric data...";
// //     });
// //
// //     try {
// //       List<List<double>> allScores = [];
// //
// //       for (var file in imageFiles) {
// //         final bytes = await file.readAsBytes();
// //         img.Image? image = img.decodeImage(bytes);
// //         if (image == null) continue;
// //
// //         int height = inputShape[1];
// //         int width = inputShape[2];
// //         img.Image resized = img.copyResize(image, width: width, height: height);
// //
// //         var input = List.generate(
// //           1,
// //           (_) => List.generate(
// //             height,
// //             (y) => List.generate(width, (x) {
// //               final pixel = resized.getPixel(x, y);
// //               return [
// //                 pixel.r.toDouble(),
// //                 pixel.g.toDouble(),
// //                 pixel.b.toDouble(),
// //               ];
// //             }),
// //           ),
// //         );
// //
// //         var output = List.generate(1, (_) => List.filled(labels.length, 0.0));
// //         interpreter.run(input, output);
// //         allScores.add(List<double>.from(output[0]));
// //       }
// //
// //       List<double> averagedScores = List.filled(labels.length, 0.0);
// //       for (int i = 0; i < labels.length; i++) {
// //         double sum = 0;
// //         for (int j = 0; j < allScores.length; j++) {
// //           sum += allScores[j][i];
// //         }
// //         averagedScores[i] = sum / allScores.length;
// //       }
// //
// //       List<PredictionResult> results = [];
// //       for (int i = 0; i < labels.length; i++) {
// //         results.add(PredictionResult(labels[i], averagedScores[i]));
// //       }
// //
// //       results.sort((a, b) => b.confidence.compareTo(a.confidence));
// //
// //       setState(() {
// //         isBusy = false;
// //         bool hasHighConfidence =
// //             results.isNotEmpty && results[0].confidence >= matchThreshold;
// //         bool hasClearGap = results.length > 1
// //             ? (results[0].confidence - results[1].confidence) > 0.15
// //             : true;
// //
// //         if (!hasHighConfidence || !hasClearGap) {
// //           isUnmatched = true;
// //           statusMessage = "Data Not Matched";
// //           topPredictions = [];
// //         } else {
// //           isUnmatched = false;
// //           statusMessage = "High Precision Analysis Complete";
// //           topPredictions = results.take(3).toList();
// //         }
// //       });
// //     } catch (e) {
// //       setState(() {
// //         statusMessage = "Error during analysis";
// //         isBusy = false;
// //       });
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: Colors.grey[50],
// //       appBar: AppBar(
// //         title: const Text(
// //           "Profile Scanner Pro",
// //           style: TextStyle(fontWeight: FontWeight.bold),
// //         ),
// //         centerTitle: true,
// //         actions: [
// //           if (imageFiles.isNotEmpty)
// //             IconButton(
// //               onPressed: clearImages,
// //               icon: const Icon(Icons.delete_sweep, color: Colors.red),
// //             ),
// //         ],
// //       ),
// //       body: SingleChildScrollView(
// //         padding: const EdgeInsets.all(24),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.stretch,
// //           children: [
// //             _buildImageGallery(),
// //             const SizedBox(height: 16),
// //             Container(
// //               padding: const EdgeInsets.all(12),
// //               decoration: BoxDecoration(
// //                 color: Colors.indigo[50],
// //                 borderRadius: BorderRadius.circular(12),
// //                 border: Border.all(color: Colors.indigo.withOpacity(0.1)),
// //               ),
// //               child: Row(
// //                 children: [
// //                   Icon(Icons.auto_graph, size: 20, color: Colors.indigo[700]),
// //                   const SizedBox(width: 10),
// //                   const Expanded(
// //                     child: Text(
// //                       "Precision Tip: Providing more photos (up to 5) significantly increases the accuracy of the profile match.",
// //                       style: TextStyle(
// //                         fontSize: 11,
// //                         fontWeight: FontWeight.w600,
// //                         color: Colors.indigo,
// //                       ),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //             const SizedBox(height: 24),
// //             Row(
// //               mainAxisAlignment: MainAxisAlignment.center,
// //               children: [
// //                 Text(
// //                   statusMessage.toUpperCase(),
// //                   style: TextStyle(
// //                     fontSize: 10,
// //                     fontWeight: FontWeight.w900,
// //                     color: isUnmatched
// //                         ? Colors.orange[900]
// //                         : Colors.indigo[300],
// //                     letterSpacing: 1.5,
// //                   ),
// //                 ),
// //                 const Spacer(),
// //                 Container(
// //                   padding: const EdgeInsets.symmetric(
// //                     horizontal: 8,
// //                     vertical: 2,
// //                   ),
// //                   decoration: BoxDecoration(
// //                     color: Colors.grey[200],
// //                     borderRadius: BorderRadius.circular(20),
// //                   ),
// //                   child: Text(
// //                     "Photos: ${imageFiles.length}/$maxImageLimit",
// //                     style: const TextStyle(
// //                       fontSize: 10,
// //                       fontWeight: FontWeight.bold,
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //             const SizedBox(height: 16),
// //             if (isBusy)
// //               const Center(
// //                 child: Padding(
// //                   padding: EdgeInsets.all(40),
// //                   child: CircularProgressIndicator(),
// //                 ),
// //               )
// //             else if (isUnmatched)
// //               _buildErrorCard()
// //             else if (topPredictions.isNotEmpty)
// //               ...topPredictions.asMap().entries.map((entry) {
// //                 int idx = entry.key;
// //                 PredictionResult res = entry.value;
// //                 return _buildResultTile(res, isHighlyRecommended: idx == 0);
// //               }),
// //             const SizedBox(height: 32),
// //             if (imageFiles.length < maxImageLimit && !isBusy)
// //               Row(
// //                 children: [
// //                   Expanded(
// //                     child: ElevatedButton.icon(
// //                       onPressed: () => addImage(ImageSource.camera),
// //                       icon: const Icon(Icons.add_a_photo),
// //                       label: const Text("Capture"),
// //                       style: ElevatedButton.styleFrom(
// //                         backgroundColor: Colors.indigo,
// //                         foregroundColor: Colors.white,
// //                         padding: const EdgeInsets.symmetric(vertical: 16),
// //                         shape: RoundedRectangleBorder(
// //                           borderRadius: BorderRadius.circular(12),
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                   const SizedBox(width: 12),
// //                   Expanded(
// //                     child: OutlinedButton.icon(
// //                       onPressed: () => addImage(ImageSource.gallery),
// //                       icon: const Icon(Icons.add_photo_alternate),
// //                       label: const Text("Gallery"),
// //                       style: OutlinedButton.styleFrom(
// //                         padding: const EdgeInsets.symmetric(vertical: 16),
// //                         shape: RoundedRectangleBorder(
// //                           borderRadius: BorderRadius.circular(12),
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             if (imageFiles.isNotEmpty && !isBusy)
// //               Padding(
// //                 padding: const EdgeInsets.only(top: 16.0),
// //                 child: ElevatedButton.icon(
// //                   onPressed: runMultiInference,
// //                   icon: const Icon(Icons.verified_user_outlined),
// //                   label: Text("VERIFY ${imageFiles.length} PROFILES"),
// //                   style: ElevatedButton.styleFrom(
// //                     backgroundColor: Colors.green[700],
// //                     foregroundColor: Colors.white,
// //                     padding: const EdgeInsets.symmetric(vertical: 20),
// //                     shape: RoundedRectangleBorder(
// //                       borderRadius: BorderRadius.circular(12),
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildImageGallery() {
// //     return SizedBox(
// //       height: 120,
// //       child: imageFiles.isEmpty
// //           ? Container(
// //               decoration: BoxDecoration(
// //                 border: Border.all(color: Colors.grey[300]!, width: 2),
// //                 borderRadius: BorderRadius.circular(20),
// //               ),
// //               child: const Center(
// //                 child: Text(
// //                   "No profiles added yet",
// //                   style: TextStyle(color: Colors.grey),
// //                 ),
// //               ),
// //             )
// //           : ListView.separated(
// //               scrollDirection: Axis.horizontal,
// //               itemCount: imageFiles.length,
// //               separatorBuilder: (_, __) => const SizedBox(width: 12),
// //               itemBuilder: (context, index) {
// //                 return Stack(
// //                   children: [
// //                     Container(
// //                       width: 120,
// //                       decoration: BoxDecoration(
// //                         borderRadius: BorderRadius.circular(16),
// //                         image: DecorationImage(
// //                           image: FileImage(imageFiles[index]),
// //                           fit: BoxFit.cover,
// //                         ),
// //                       ),
// //                     ),
// //                     Positioned(
// //                       top: 4,
// //                       right: 4,
// //                       child: GestureDetector(
// //                         onTap: () => setState(() => imageFiles.removeAt(index)),
// //                         child: Container(
// //                           decoration: const BoxDecoration(
// //                             color: Colors.black54,
// //                             shape: BoxShape.circle,
// //                           ),
// //                           child: const Icon(
// //                             Icons.close,
// //                             color: Colors.white,
// //                             size: 20,
// //                           ),
// //                         ),
// //                       ),
// //                     ),
// //                   ],
// //                 );
// //               },
// //             ),
// //     );
// //   }
// //
// //   Widget _buildResultTile(
// //     PredictionResult res, {
// //     required bool isHighlyRecommended,
// //   }) {
// //     return Card(
// //       elevation: isHighlyRecommended ? 2 : 0,
// //       margin: const EdgeInsets.only(bottom: 12),
// //       shape: RoundedRectangleBorder(
// //         borderRadius: BorderRadius.circular(16),
// //         side: BorderSide(
// //           color: isHighlyRecommended
// //               ? Colors.indigo
// //               : Colors.indigo.withOpacity(0.1),
// //           width: isHighlyRecommended ? 2 : 1,
// //         ),
// //       ),
// //       color: Colors.white,
// //       child: Padding(
// //         padding: const EdgeInsets.all(16),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             Row(
// //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //               children: [
// //                 Column(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     Text(
// //                       res.label,
// //                       style: const TextStyle(
// //                         fontSize: 18,
// //                         fontWeight: FontWeight.bold,
// //                       ),
// //                     ),
// //                     if (isHighlyRecommended)
// //                       const Text(
// //                         "HIGHLY RECOMMENDED",
// //                         style: TextStyle(
// //                           color: Colors.green,
// //                           fontSize: 10,
// //                           fontWeight: FontWeight.w900,
// //                           letterSpacing: 0.5,
// //                         ),
// //                       ),
// //                   ],
// //                 ),
// //                 Text(
// //                   "${(res.confidence * 100).toStringAsFixed(1)}%",
// //                   style: TextStyle(
// //                     fontWeight: FontWeight.w900,
// //                     color: Colors.indigo[700],
// //                     fontSize: 18,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //             const SizedBox(height: 12),
// //             ClipRRect(
// //               borderRadius: BorderRadius.circular(4),
// //               child: LinearProgressIndicator(
// //                 value: res.confidence,
// //                 minHeight: 8,
// //                 backgroundColor: Colors.indigo[50],
// //                 color: isHighlyRecommended ? Colors.indigo : Colors.indigo[200],
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildErrorCard() {
// //     return Container(
// //       padding: const EdgeInsets.all(24),
// //       decoration: BoxDecoration(
// //         color: Colors.orange[50],
// //         borderRadius: BorderRadius.circular(20),
// //         border: Border.all(color: Colors.orange.withOpacity(0.2)),
// //       ),
// //       child: Column(
// //         children: [
// //           Icon(Icons.search_off_rounded, color: Colors.orange[400], size: 48),
// //           const SizedBox(height: 12),
// //           Text(
// //             "Data Not Found",
// //             style: TextStyle(
// //               fontSize: 18,
// //               fontWeight: FontWeight.bold,
// //               color: Colors.orange[900],
// //             ),
// //           ),
// //           const SizedBox(height: 8),
// //           const Text(
// //             "The object does not match any profile in our database. Try taking more photos from different angles to improve the match confidence.",
// //             textAlign: TextAlign.center,
// //             style: TextStyle(color: Colors.black54, fontSize: 13),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
//
//
//
//
// // now here on i am updating code which use dynamic model
//
//
//
//
// // import 'package:flutter/material.dart';
// // import 'package:supabase_flutter/supabase_flutter.dart';
// // import 'app.dart';
// //
// // void main() async {
// //   WidgetsFlutterBinding.ensureInitialized();
// //
// //   await Supabase.initialize(
// //     url: 'https://brrdkdabcoilwebmbrlx.supabase.co',
// //     anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJycmRrZGFiY29pbHdlYm1icmx4Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3NDk1MjM1NiwiZXhwIjoyMDkwNTI4MzU2fQ.R3RTkWxSbUrD_AjnMwC5cT5rgw5jF4MV6XCIn5MxT5w',
// //   );
// //
// //   runApp(const MyApp());
// // }






import 'package:flutter/material.dart';
import 'package:mobile/model_sync_screen.dart';
import 'package:mobile/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://brrdkdabcoilwebmbrlx.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJycmRrZGFiY29pbHdlYm1icmx4Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3NDk1MjM1NiwiZXhwIjoyMDkwNTI4MzU2fQ.R3RTkWxSbUrD_AjnMwC5cT5rgw5jF4MV6XCIn5MxT5w',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // home: HomePage(),
      title: 'Gasket Guy',
      theme: AppTheme.lightTheme,
      home: const ModelSyncScreen(), // First call the model screen
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'theme.dart';
// import 'model_sync_screen.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   await Supabase.initialize(
//     url: 'https://brrdkdabcoilwebmbrlx.supabase.co',
//     anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJycmRrZGFiY29pbHdlYm1icmx4Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3NDk1MjM1NiwiZXhwIjoyMDkwNTI4MzU2fQ.R3RTkWxSbUrD_AjnMwC5cT5rgw5jF4MV6XCIn5MxT5w',
//   );
//
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Gasket Guy',
//       theme: AppTheme.lightTheme,
//       home: const ModelSyncScreen(), // Initial entry point for model updates
//     );
//   }
// }
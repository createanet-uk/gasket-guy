// // // //
// // // //
// // // //
// // // //
// // // // // import 'dart:io';
// // // // // import 'dart:math';
// // // // // import 'package:camera/camera.dart';
// // // // // import 'package:flutter/material.dart';
// // // // // import 'package:tflite_flutter/tflite_flutter.dart';
// // // // // import 'package:image/image.dart' as img;
// // // // //
// // // // // class RubberCameraDetectorPage extends StatefulWidget {
// // // // //   const RubberCameraDetectorPage({super.key});
// // // // //
// // // // //   @override
// // // // //   State<RubberCameraDetectorPage> createState() =>
// // // // //       _RubberCameraDetectorPageState();
// // // // // }
// // // // //
// // // // // class _RubberCameraDetectorPageState extends State<RubberCameraDetectorPage> {
// // // // //   CameraController? controller;
// // // // //   Interpreter? interpreter;
// // // // //
// // // // //   File? capturedImage;
// // // // //   List<Detection> detections = [];
// // // // //
// // // // //   bool isLoading = true;
// // // // //   bool isDetecting = false;
// // // // //
// // // // //   @override
// // // // //   void initState() {
// // // // //     super.initState();
// // // // //     init();
// // // // //   }
// // // // //
// // // // //   Future<void> init() async {
// // // // //     final cams = await availableCameras();
// // // // //
// // // // //     controller = CameraController(
// // // // //       cams[0],
// // // // //       ResolutionPreset.medium,
// // // // //       enableAudio: false,
// // // // //     );
// // // // //
// // // // //     await controller!.initialize();
// // // // //
// // // // //     interpreter = await Interpreter.fromAsset(
// // // // //       'assets/model/best_float32.tflite',
// // // // //     );
// // // // //
// // // // //     setState(() {
// // // // //       isLoading = false;
// // // // //     });
// // // // //   }
// // // // //
// // // // //   // =========================
// // // // //   // CAPTURE IMAGE
// // // // //   // =========================
// // // // //   Future<void> captureImage() async {
// // // // //     if (controller == null || !controller!.value.isInitialized) return;
// // // // //
// // // // //     final photo = await controller!.takePicture();
// // // // //
// // // // //     capturedImage = File(photo.path);
// // // // //     detections.clear();
// // // // //
// // // // //     setState(() {});
// // // // //   }
// // // // //
// // // // //   // =========================
// // // // //   // RUN DETECTION
// // // // //   // =========================
// // // // //   Future<void> detectObjects() async {
// // // // //     if (capturedImage == null || interpreter == null) return;
// // // // //
// // // // //
// // // // //     setState(() {
// // // // //       isDetecting = true;
// // // // //     });
// // // // //
// // // // //     await Future.delayed(const Duration(milliseconds: 50));
// // // // //
// // // // //     try{
// // // // //       final bytes = await capturedImage!.readAsBytes();
// // // // //       img.Image? image = img.decodeImage(bytes);
// // // // //
// // // // //       if (image == null) return;
// // // // //
// // // // //       final inputImage = img.copyResize(image, width: 640, height: 640);
// // // // //
// // // // //       final input = [
// // // // //         List.generate(640, (y) {
// // // // //           return List.generate(640, (x) {
// // // // //             final p = inputImage.getPixel(x, y);
// // // // //             return [p.r / 255, p.g / 255, p.b / 255];
// // // // //           });
// // // // //         }),
// // // // //       ];
// // // // //
// // // // //       final output = List.generate(
// // // // //         1,
// // // // //             (_) => List.generate(5, (_) => List.filled(8400, 0.0)),
// // // // //       );
// // // // //
// // // // //       interpreter!.run(input, output);
// // // // //
// // // // //       List<Detection> raw = [];
// // // // //
// // // // //       for (int i = 0; i < 8400; i++) {
// // // // //         double conf = output[0][4][i];
// // // // //
// // // // //         if (conf > 0.5) {
// // // // //           raw.add(
// // // // //             Detection(
// // // // //               Rect.fromCenter(
// // // // //                 center: Offset(output[0][0][i], output[0][1][i]),
// // // // //                 width: output[0][2][i] * 1.40,
// // // // //                 height: output[0][3][i]* 1.40,
// // // // //               ),
// // // // //               conf,
// // // // //             ),
// // // // //           );
// // // // //         }
// // // // //       }
// // // // //
// // // // //       detections = nms(raw, 0.5);
// // // // //
// // // // //       // --- CHECK FOR EMPTY DETECTIONS ---
// // // // //       if (detections.isEmpty && mounted) {
// // // // //         _showNoDetectionDialog();
// // // // //       }
// // // // //
// // // // //     }catch(e){
// // // // //       print('Object detection error: $e');
// // // // //     }finally{
// // // // //       setState(() {isDetecting = false;});
// // // // //     }
// // // // //   }
// // // // //
// // // // //   // =========================
// // // // // // SHOW NO DETECTION DIALOG
// // // // // // =========================
// // // // //   void _showNoDetectionDialog() {
// // // // //     showDialog(
// // // // //       context: context,
// // // // //       barrierDismissible: false,
// // // // //       builder: (BuildContext context) {
// // // // //         return AlertDialog(
// // // // //           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
// // // // //           title: const Row(
// // // // //             children: [
// // // // //               Icon(Icons.warning_amber_rounded, color: Colors.orange),
// // // // //               SizedBox(width: 10),
// // // // //               Text("No Object Found"),
// // // // //             ],
// // // // //           ),
// // // // //           content: const Text(
// // // // //             "The detector couldn't identify any objects in this image. Please try adjusting the lighting or position and take another photo.",
// // // // //           ),
// // // // //           actions: [
// // // // //             TextButton(
// // // // //               onPressed: () {
// // // // //                 Navigator.of(context).pop();
// // // // //                 setState(() {
// // // // //                   capturedImage = null;
// // // // //                   detections.clear();
// // // // //                 });
// // // // //               },
// // // // //               child: const Text("Retake Photo"),
// // // // //             ),
// // // // //             TextButton(
// // // // //               onPressed: () => Navigator.of(context).pop(),
// // // // //               child: const Text("OK"),
// // // // //             ),
// // // // //           ],
// // // // //         );
// // // // //       },
// // // // //     );
// // // // //   }
// // // // //
// // // // //   // =========================
// // // // //   // NMS
// // // // //   // =========================
// // // // //   List<Detection> nms(List<Detection> boxes, double iouThreshold) {
// // // // //     boxes.sort((a, b) => b.conf.compareTo(a.conf));
// // // // //
// // // // //     List<Detection> result = [];
// // // // //
// // // // //     for (var box in boxes) {
// // // // //       bool keep = true;
// // // // //
// // // // //       for (var selected in result) {
// // // // //         if (iou(box.rect, selected.rect) > iouThreshold) {
// // // // //           keep = false;
// // // // //           break;
// // // // //         }
// // // // //       }
// // // // //
// // // // //       if (keep) result.add(box);
// // // // //     }
// // // // //
// // // // //     return result;
// // // // //   }
// // // // //
// // // // //   double iou(Rect a, Rect b) {
// // // // //     final inter = a.intersect(b);
// // // // //     final interArea = inter.width * inter.height;
// // // // //
// // // // //     final union = a.width * a.height + b.width * b.height - interArea;
// // // // //
// // // // //     return union == 0 ? 0 : interArea / union;
// // // // //   }
// // // // //
// // // // //   // =========================
// // // // //   // SUBMIT (CROP OBJECTS)
// // // // //   // =========================
// // // // //   Future<void> submit() async {
// // // // //     if (capturedImage == null || detections.isEmpty) return;
// // // // //
// // // // //     final bytes = await capturedImage!.readAsBytes();
// // // // //     img.Image? full = img.decodeImage(bytes);
// // // // //
// // // // //     if (full == null) return;
// // // // //
// // // // //     List<Map<String, dynamic>> result = [];
// // // // //
// // // // //     for (var d in detections) {
// // // // //       final r = d.rect;
// // // // //
// // // // //       int x = (r.left * full.width).toInt();
// // // // //       int y = (r.top * full.height).toInt();
// // // // //       int w = (r.width * full.width).toInt();
// // // // //       int h = (r.height * full.height).toInt();
// // // // //
// // // // //       x = max(0, x);
// // // // //       y = max(0, y);
// // // // //
// // // // //       w = min(w, full.width - x);
// // // // //       h = min(h, full.height - y);
// // // // //
// // // // //       final crop = img.copyCrop(full, x: x, y: y, width: w, height: h);
// // // // //
// // // // //       final path = capturedImage!.path.replaceAll(
// // // // //         ".jpg",
// // // // //         "_${DateTime.now().millisecondsSinceEpoch}.jpg",
// // // // //       );
// // // // //
// // // // //       final file = File(path);
// // // // //       await file.writeAsBytes(img.encodeJpg(crop));
// // // // //
// // // // //       result.add({"path": file.path, "conf": d.conf});
// // // // //     }
// // // // //
// // // // //     if (mounted) Navigator.pop(context, result);
// // // // //   }
// // // // //
// // // // //   @override
// // // // //   void dispose() {
// // // // //     controller?.dispose();
// // // // //     interpreter?.close();
// // // // //     super.dispose();
// // // // //   }
// // // // //
// // // // //   @override
// // // // //   Widget build(BuildContext context) {
// // // // //     if (isLoading || controller == null || !controller!.value.isInitialized) {
// // // // //       return const Scaffold(body: Center(child: CircularProgressIndicator()));
// // // // //     }
// // // // //
// // // // //     return Scaffold(
// // // // //       body: LayoutBuilder(
// // // // //         builder: (context, constraints) => SizedBox(
// // // // //           width: double.infinity,
// // // // //           height: double.infinity,
// // // // //           child: Stack(
// // // // //             children: [
// // // // //               // CAMERA OR IMAGE
// // // // //               capturedImage == null
// // // // //                   ? SizedBox(
// // // // //                 height: double.infinity,
// // // // //                 width: double.infinity,
// // // // //                 child: CameraPreview(
// // // // //                   controller!,
// // // // //                 ),
// // // // //               )
// // // // //                   : Image.file(
// // // // //                 capturedImage!,
// // // // //                 fit: BoxFit.fill,
// // // // //                 width: double.infinity,
// // // // //                 height: double.infinity,
// // // // //               ),
// // // // //
// // // // //               // BOXES
// // // // //               if (capturedImage != null)
// // // // //                 Positioned.fill(
// // // // //                   child: CustomPaint(painter: BoxPainter(detections)),
// // // // //                 ),
// // // // //
// // // // //               if (capturedImage == null)
// // // // //                 Positioned(
// // // // //                   top: constraints.maxHeight * 0.2,
// // // // //                   left: 40,
// // // // //                   right: 40,
// // // // //                   bottom: constraints.maxHeight * 0.3,
// // // // //                   child: Container(
// // // // //                     decoration: BoxDecoration(
// // // // //                       border: Border.all(color: Colors.white24, width: 1),
// // // // //                       borderRadius: BorderRadius.circular(12),
// // // // //                     ),
// // // // //                     child: Stack(
// // // // //                       children: [
// // // // //                         // Corner L-Shapes
// // // // //                         _buildCorner(top: 0, left: 0, angle: 0),
// // // // //                         _buildCorner(top: 0, right: 0, angle: 90),
// // // // //                         _buildCorner(bottom: 0, left: 0, angle: 270),
// // // // //                         _buildCorner(bottom: 0, right: 0, angle: 180),
// // // // //                       ],
// // // // //                     ),
// // // // //                   ),
// // // // //                 ),
// // // // //
// // // // //               // BUTTONS
// // // // //               Positioned(
// // // // //                 bottom: 40,
// // // // //                 left: 0,
// // // // //                 right: 0,
// // // // //                 child: Column(
// // // // //                   children: [
// // // // //                     if (capturedImage == null)
// // // // //                       GestureDetector(
// // // // //                         onTap: captureImage,
// // // // //                         child: Container(
// // // // //                           // child: const Text("Capture"),
// // // // //                           height: 60,
// // // // //                           width: 60,
// // // // //                           decoration: BoxDecoration(
// // // // //                             shape: BoxShape.circle,
// // // // //                             border: BoxBorder.all(color: Colors.black, width: 2),
// // // // //                           ),
// // // // //                           child: Center(child: Icon(Icons.camera, size: 30)),
// // // // //                         ),
// // // // //                       ),
// // // // //
// // // // //                     if (capturedImage != null && detections.isEmpty)
// // // // //                       Row(
// // // // //                         mainAxisAlignment: MainAxisAlignment.center,
// // // // //                         children: [
// // // // //                           ElevatedButton.icon(
// // // // //                             style: ElevatedButton.styleFrom(
// // // // //                               backgroundColor: Colors.redAccent,
// // // // //                               foregroundColor: Colors.white,
// // // // //                               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
// // // // //                             ),
// // // // //                             onPressed: isDetecting
// // // // //                                 ? null
// // // // //                                 : () => setState(() => capturedImage = null),
// // // // //                             icon: const Icon(Icons.refresh),
// // // // //                             label: const Text("Retake"),
// // // // //                           ),
// // // // //                           const SizedBox(width: 20),
// // // // //                           ElevatedButton(
// // // // //                             onPressed: isDetecting
// // // // //                                 ? null
// // // // //                                 : detectObjects,
// // // // //                             child: isDetecting
// // // // //                                 ? const Text("Detecting...")
// // // // //                                 : const Text("Detect"),
// // // // //                           ),
// // // // //                         ],
// // // // //                       ),
// // // // //
// // // // //                     if (detections.isNotEmpty)
// // // // //                       ElevatedButton(
// // // // //                         onPressed: submit,
// // // // //                         child: const Text("Submit"),
// // // // //                       ),
// // // // //                   ],
// // // // //                 ),
// // // // //               ),
// // // // //             ],
// // // // //           ),
// // // // //         ),
// // // // //       ),
// // // // //     );
// // // // //   }
// // // // //
// // // // //   Widget _buildCorner({
// // // // //     double? top,
// // // // //     double? left,
// // // // //     double? right,
// // // // //     double? bottom,
// // // // //     required double angle,
// // // // //   }) {
// // // // //     return Positioned(
// // // // //       top: top,
// // // // //       left: left,
// // // // //       right: right,
// // // // //       bottom: bottom,
// // // // //       child: Transform.rotate(
// // // // //         angle: angle * pi / 180,
// // // // //         child: Container(
// // // // //           width: 30,
// // // // //           height: 30,
// // // // //           decoration: const BoxDecoration(
// // // // //             border: Border(
// // // // //               top: BorderSide(color: Colors.cyanAccent, width: 3),
// // // // //               left: BorderSide(color: Colors.cyanAccent, width: 3),
// // // // //             ),
// // // // //           ),
// // // // //         ),
// // // // //       ),
// // // // //     );
// // // // //   }
// // // // // }
// // // // //
// // // // // // =========================
// // // // // // MODEL
// // // // // // =========================
// // // // // class Detection {
// // // // //   final Rect rect;
// // // // //   final double conf;
// // // // //
// // // // //   Detection(this.rect, this.conf);
// // // // // }
// // // // //
// // // // // // =========================
// // // // // // PAINTER
// // // // // // =========================
// // // // //
// // // // // class BoxPainter extends CustomPainter {
// // // // //   final List<Detection> detections;
// // // // //
// // // // //   BoxPainter(this.detections);
// // // // //
// // // // //   @override
// // // // //   void paint(Canvas canvas, Size size) {
// // // // //     final boxPaint = Paint()
// // // // //       ..color = Colors.red
// // // // //       ..strokeWidth = 3
// // // // //       ..style = PaintingStyle.stroke;
// // // // //
// // // // //     final bgPaint = Paint()
// // // // //       ..color = Colors.red
// // // // //       ..style = PaintingStyle.fill;
// // // // //
// // // // //     for (var d in detections) {
// // // // //       // Calculate coordinates relative to canvas size
// // // // //       final double left = d.rect.left * size.width;
// // // // //       final double top = d.rect.top * size.height;
// // // // //       final double width = d.rect.width * size.width;
// // // // //       final double height = d.rect.height * size.height;
// // // // //
// // // // //       final r = Rect.fromLTWH(left, top, width, height);
// // // // //
// // // // //       // 1. Draw Bounding Box
// // // // //       canvas.drawRect(r, boxPaint);
// // // // //
// // // // //       // 2. Prepare Label Text (Confidence %)
// // // // //       final String text = "Rubber ${(d.conf * 100).toStringAsFixed(0)}%";
// // // // //
// // // // //       final textPainter = TextPainter(
// // // // //         text: TextSpan(
// // // // //           text: text,
// // // // //           style: const TextStyle(
// // // // //             color: Colors.white,
// // // // //             fontSize: 10,
// // // // //             fontWeight: FontWeight.bold,
// // // // //           ),
// // // // //         ),
// // // // //         textDirection: TextDirection.ltr,
// // // // //       );
// // // // //
// // // // //       textPainter.layout();
// // // // //
// // // // //       // 3. Draw Label Background (Small rectangle above/inside box)
// // // // //       final labelBgRect = Rect.fromLTWH(
// // // // //         left,
// // // // //         top - textPainter.height - 4, // Positioned slightly above the box
// // // // //         textPainter.width + 8,
// // // // //         textPainter.height + 4,
// // // // //       );
// // // // //
// // // // //       canvas.drawRect(labelBgRect, bgPaint);
// // // // //
// // // // //       // 4. Draw Text
// // // // //       textPainter.paint(
// // // // //         canvas,
// // // // //         Offset(left + 4, top - textPainter.height - 2),
// // // // //       );
// // // // //     }
// // // // //   }
// // // // //
// // // // //   @override
// // // // //   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// // // // // }
// // // //
// // // //
// // // //
// // // //
// // // // import 'dart:io';
// // // // import 'dart:math';
// // // // import 'package:camera/camera.dart';
// // // // import 'package:flutter/material.dart';
// // // // import 'package:tflite_flutter/tflite_flutter.dart';
// // // // import 'package:image/image.dart' as img;
// // // //
// // // // class RubberCameraDetectorPage extends StatefulWidget {
// // // //   const RubberCameraDetectorPage({super.key});
// // // //
// // // //   @override
// // // //   State<RubberCameraDetectorPage> createState() =>
// // // //       _RubberCameraDetectorPageState();
// // // // }
// // // //
// // // // class _RubberCameraDetectorPageState extends State<RubberCameraDetectorPage> {
// // // //   CameraController? controller;
// // // //   Interpreter? interpreter;
// // // //
// // // //   File? capturedImage;
// // // //   List<Detection> detections = [];
// // // //
// // // //   bool isLoading = true;
// // // //   bool isDetecting = false;
// // // //
// // // //   @override
// // // //   void initState() {
// // // //     super.initState();
// // // //     init();
// // // //   }
// // // //
// // // //   Future<void> init() async {
// // // //     final cams = await availableCameras();
// // // //
// // // //     controller = CameraController(
// // // //       cams[0],
// // // //       ResolutionPreset.medium,
// // // //       enableAudio: false,
// // // //     );
// // // //
// // // //     await controller!.initialize();
// // // //
// // // //     interpreter = await Interpreter.fromAsset(
// // // //       'assets/model/best_float32.tflite',
// // // //     );
// // // //
// // // //     setState(() {
// // // //       isLoading = false;
// // // //     });
// // // //   }
// // // //
// // // //   // =========================
// // // //   // CAPTURE IMAGE
// // // //   // =========================
// // // //   Future<void> captureImage() async {
// // // //     if (controller == null || !controller!.value.isInitialized) return;
// // // //
// // // //     final photo = await controller!.takePicture();
// // // //
// // // //     capturedImage = File(photo.path);
// // // //     detections.clear();
// // // //
// // // //     setState(() {});
// // // //   }
// // // //
// // // //
// // // //   // =========================
// // // //   // Use Full Image
// // // //   // =========================
// // // //
// // // //   Future<void> useFullImage() async {
// // // //     if (capturedImage == null) return;
// // // //
// // // //     if (mounted) {
// // // //       Navigator.pop(context, [
// // // //         {
// // // //           "path": capturedImage!.path,
// // // //           "conf": 1.0, // optional, since no detection
// // // //           "isFullImage": true,
// // // //         }
// // // //       ]);
// // // //     }
// // // //   }
// // // //
// // // //   // =========================
// // // //   // RUN DETECTION
// // // //   // =========================
// // // //   Future<void> detectObjects() async {
// // // //     if (capturedImage == null || interpreter == null) return;
// // // //
// // // //
// // // //     setState(() {
// // // //       isDetecting = true;
// // // //     });
// // // //
// // // //     await Future.delayed(const Duration(milliseconds: 50));
// // // //
// // // //     try{
// // // //       final bytes = await capturedImage!.readAsBytes();
// // // //       img.Image? image = img.decodeImage(bytes);
// // // //
// // // //       if (image == null) return;
// // // //
// // // //       final inputImage = img.copyResize(image, width: 640, height: 640);
// // // //
// // // //       final input = [
// // // //         List.generate(640, (y) {
// // // //           return List.generate(640, (x) {
// // // //             final p = inputImage.getPixel(x, y);
// // // //             return [p.r / 255, p.g / 255, p.b / 255];
// // // //           });
// // // //         }),
// // // //       ];
// // // //
// // // //       final output = List.generate(
// // // //         1,
// // // //             (_) => List.generate(5, (_) => List.filled(8400, 0.0)),
// // // //       );
// // // //
// // // //       interpreter!.run(input, output);
// // // //
// // // //       List<Detection> raw = [];
// // // //
// // // //       for (int i = 0; i < 8400; i++) {
// // // //         double conf = output[0][4][i];
// // // //
// // // //         if (conf > 0.5) {
// // // //           raw.add(
// // // //             Detection(
// // // //               Rect.fromCenter(
// // // //                 center: Offset(output[0][0][i], output[0][1][i]),
// // // //                 width: output[0][2][i] * 1.40,
// // // //                 height: output[0][3][i]* 1.40,
// // // //               ),
// // // //               conf,
// // // //             ),
// // // //           );
// // // //         }
// // // //       }
// // // //
// // // //       detections = nms(raw, 0.5);
// // // //
// // // //       // --- CHECK FOR EMPTY DETECTIONS ---
// // // //       if (detections.isEmpty && mounted) {
// // // //         _showNoDetectionDialog();
// // // //       }
// // // //
// // // //     }catch(e){
// // // //       print('Object detection error: $e');
// // // //     }finally{
// // // //       setState(() {isDetecting = false;});
// // // //     }
// // // //   }
// // // //
// // // //   // =========================
// // // // // SHOW NO DETECTION DIALOG
// // // // // =========================
// // // //   void _showNoDetectionDialog() {
// // // //     showDialog(
// // // //       context: context,
// // // //       barrierDismissible: false,
// // // //       builder: (BuildContext context) {
// // // //         return AlertDialog(
// // // //           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
// // // //           title: const Row(
// // // //             children: [
// // // //               Icon(Icons.warning_amber_rounded, color: Colors.orange),
// // // //               SizedBox(width: 10),
// // // //               Text("No Object Found"),
// // // //             ],
// // // //           ),
// // // //           content: const Text(
// // // //             "The detector couldn't identify any objects in this image. Please try adjusting the lighting or position and take another photo.",
// // // //           ),
// // // //           actions: [
// // // //             TextButton(
// // // //               onPressed: () {
// // // //                 Navigator.of(context).pop();
// // // //                 setState(() {
// // // //                   capturedImage = null;
// // // //                   detections.clear();
// // // //                 });
// // // //               },
// // // //               child: const Text("Retake Photo"),
// // // //             ),
// // // //             TextButton(
// // // //               onPressed: () => Navigator.of(context).pop(),
// // // //               child: const Text("OK"),
// // // //             ),
// // // //           ],
// // // //         );
// // // //       },
// // // //     );
// // // //   }
// // // //
// // // //   // =========================
// // // //   // NMS
// // // //   // =========================
// // // //   List<Detection> nms(List<Detection> boxes, double iouThreshold) {
// // // //     boxes.sort((a, b) => b.conf.compareTo(a.conf));
// // // //
// // // //     List<Detection> result = [];
// // // //
// // // //     for (var box in boxes) {
// // // //       bool keep = true;
// // // //
// // // //       for (var selected in result) {
// // // //         if (iou(box.rect, selected.rect) > iouThreshold) {
// // // //           keep = false;
// // // //           break;
// // // //         }
// // // //       }
// // // //
// // // //       if (keep) result.add(box);
// // // //     }
// // // //
// // // //     return result;
// // // //   }
// // // //
// // // //   double iou(Rect a, Rect b) {
// // // //     final inter = a.intersect(b);
// // // //     final interArea = inter.width * inter.height;
// // // //
// // // //     final union = a.width * a.height + b.width * b.height - interArea;
// // // //
// // // //     return union == 0 ? 0 : interArea / union;
// // // //   }
// // // //
// // // //   // =========================
// // // //   // SUBMIT (CROP OBJECTS)
// // // //   // =========================
// // // //   Future<void> submit() async {
// // // //     if (capturedImage == null || detections.isEmpty) return;
// // // //
// // // //     final bytes = await capturedImage!.readAsBytes();
// // // //     img.Image? full = img.decodeImage(bytes);
// // // //
// // // //     if (full == null) return;
// // // //
// // // //     List<Map<String, dynamic>> result = [];
// // // //
// // // //     for (var d in detections) {
// // // //       final r = d.rect;
// // // //
// // // //       int x = (r.left * full.width).toInt();
// // // //       int y = (r.top * full.height).toInt();
// // // //       int w = (r.width * full.width).toInt();
// // // //       int h = (r.height * full.height).toInt();
// // // //
// // // //       x = max(0, x);
// // // //       y = max(0, y);
// // // //
// // // //       w = min(w, full.width - x);
// // // //       h = min(h, full.height - y);
// // // //
// // // //       final crop = img.copyCrop(full, x: x, y: y, width: w, height: h);
// // // //
// // // //       final path = capturedImage!.path.replaceAll(
// // // //         ".jpg",
// // // //         "_${DateTime.now().millisecondsSinceEpoch}.jpg",
// // // //       );
// // // //
// // // //       final file = File(path);
// // // //       await file.writeAsBytes(img.encodeJpg(crop));
// // // //
// // // //       result.add({"path": file.path, "conf": d.conf});
// // // //     }
// // // //
// // // //     if (mounted) Navigator.pop(context, result);
// // // //   }
// // // //
// // // //   @override
// // // //   void dispose() {
// // // //     controller?.dispose();
// // // //     interpreter?.close();
// // // //     super.dispose();
// // // //   }
// // // //
// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     if (isLoading || controller == null || !controller!.value.isInitialized) {
// // // //       return const Scaffold(body: Center(child: CircularProgressIndicator()));
// // // //     }
// // // //
// // // //     return Scaffold(
// // // //       body: LayoutBuilder(
// // // //         builder: (context, constraints) => SizedBox(
// // // //           width: double.infinity,
// // // //           height: double.infinity,
// // // //           child: Stack(
// // // //             children: [
// // // //               // CAMERA OR IMAGE
// // // //               capturedImage == null
// // // //                   ? SizedBox(
// // // //                 height: double.infinity,
// // // //                 width: double.infinity,
// // // //                 child: CameraPreview(
// // // //                   controller!,
// // // //                 ),
// // // //               )
// // // //                   : Image.file(
// // // //                 capturedImage!,
// // // //                 fit: BoxFit.fill,
// // // //                 width: double.infinity,
// // // //                 height: double.infinity,
// // // //               ),
// // // //
// // // //               // BOXES
// // // //               if (capturedImage != null)
// // // //                 Positioned.fill(
// // // //                   child: CustomPaint(painter: BoxPainter(detections)),
// // // //                 ),
// // // //
// // // //               if (capturedImage == null)
// // // //                 Positioned(
// // // //                   top: constraints.maxHeight * 0.2,
// // // //                   left: 40,
// // // //                   right: 40,
// // // //                   bottom: constraints.maxHeight * 0.3,
// // // //                   child: Container(
// // // //                     decoration: BoxDecoration(
// // // //                       border: Border.all(color: Colors.white24, width: 1),
// // // //                       borderRadius: BorderRadius.circular(12),
// // // //                     ),
// // // //                     child: Stack(
// // // //                       children: [
// // // //                         // Corner L-Shapes
// // // //                         _buildCorner(top: 0, left: 0, angle: 0),
// // // //                         _buildCorner(top: 0, right: 0, angle: 90),
// // // //                         _buildCorner(bottom: 0, left: 0, angle: 270),
// // // //                         _buildCorner(bottom: 0, right: 0, angle: 180),
// // // //                       ],
// // // //                     ),
// // // //                   ),
// // // //                 ),
// // // //
// // // //               // BUTTONS
// // // //               Positioned(
// // // //                 bottom: 40,
// // // //                 left: 0,
// // // //                 right: 0,
// // // //                 child: Column(
// // // //                   children: [
// // // //                     if (capturedImage == null)
// // // //                       GestureDetector(
// // // //                         onTap: captureImage,
// // // //                         child: Container(
// // // //                           // child: const Text("Capture"),
// // // //                           height: 60,
// // // //                           width: 60,
// // // //                           decoration: BoxDecoration(
// // // //                             shape: BoxShape.circle,
// // // //                             border: BoxBorder.all(color: Colors.black, width: 2),
// // // //                           ),
// // // //                           child: Center(child: Icon(Icons.camera, size: 30)),
// // // //                         ),
// // // //                       ),
// // // //
// // // //                     if (capturedImage != null && detections.isEmpty)
// // // //                       Row(
// // // //                         mainAxisAlignment: MainAxisAlignment.spaceAround,
// // // //                         children: [
// // // //                           ElevatedButton.icon(
// // // //                             style: ElevatedButton.styleFrom(
// // // //                               backgroundColor: Colors.redAccent,
// // // //                               foregroundColor: Colors.white,
// // // //                               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
// // // //                             ),
// // // //                             onPressed: isDetecting
// // // //                                 ? null
// // // //                                 : () => setState(() => capturedImage = null),
// // // //                             icon: const Icon(Icons.refresh),
// // // //                             label: const Text("Retake"),
// // // //                           ),
// // // //                           // const SizedBox(width: 20),
// // // //                           ElevatedButton(
// // // //                             onPressed: isDetecting
// // // //                                 ? null
// // // //                                 : detectObjects,
// // // //                             child: isDetecting
// // // //                                 ? const Text("Detecting...")
// // // //                                 : const Text("Detect"),
// // // //                           ),
// // // //
// // // //                           // const SizedBox(width: 20),
// // // //
// // // //                           // 🔥 NEW BUTTON
// // // //                           ElevatedButton.icon(
// // // //                             style: ElevatedButton.styleFrom(
// // // //                               backgroundColor: Colors.green,
// // // //                               foregroundColor: Colors.white,
// // // //                             ),
// // // //                             onPressed: useFullImage,
// // // //                             icon: const Icon(Icons.check),
// // // //                             label: const Text("Use Image"),
// // // //                           ),
// // // //                         ],
// // // //                       ),
// // // //
// // // //                     if (detections.isNotEmpty)
// // // //                       ElevatedButton(
// // // //                         onPressed: submit,
// // // //                         child: const Text("Submit"),
// // // //                       ),
// // // //                   ],
// // // //                 ),
// // // //               ),
// // // //             ],
// // // //           ),
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }
// // // //
// // // //   Widget _buildCorner({
// // // //     double? top,
// // // //     double? left,
// // // //     double? right,
// // // //     double? bottom,
// // // //     required double angle,
// // // //   }) {
// // // //     return Positioned(
// // // //       top: top,
// // // //       left: left,
// // // //       right: right,
// // // //       bottom: bottom,
// // // //       child: Transform.rotate(
// // // //         angle: angle * pi / 180,
// // // //         child: Container(
// // // //           width: 30,
// // // //           height: 30,
// // // //           decoration: const BoxDecoration(
// // // //             border: Border(
// // // //               top: BorderSide(color: Colors.cyanAccent, width: 3),
// // // //               left: BorderSide(color: Colors.cyanAccent, width: 3),
// // // //             ),
// // // //           ),
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }
// // // // }
// // // //
// // // // // =========================
// // // // // MODEL
// // // // // =========================
// // // // class Detection {
// // // //   final Rect rect;
// // // //   final double conf;
// // // //
// // // //   Detection(this.rect, this.conf);
// // // // }
// // // //
// // // // // =========================
// // // // // PAINTER
// // // // // =========================
// // // //
// // // // class BoxPainter extends CustomPainter {
// // // //   final List<Detection> detections;
// // // //
// // // //   BoxPainter(this.detections);
// // // //
// // // //   @override
// // // //   void paint(Canvas canvas, Size size) {
// // // //     final boxPaint = Paint()
// // // //       ..color = Colors.red
// // // //       ..strokeWidth = 3
// // // //       ..style = PaintingStyle.stroke;
// // // //
// // // //     final bgPaint = Paint()
// // // //       ..color = Colors.red
// // // //       ..style = PaintingStyle.fill;
// // // //
// // // //     for (var d in detections) {
// // // //       // Calculate coordinates relative to canvas size
// // // //       final double left = d.rect.left * size.width;
// // // //       final double top = d.rect.top * size.height;
// // // //       final double width = d.rect.width * size.width;
// // // //       final double height = d.rect.height * size.height;
// // // //
// // // //       final r = Rect.fromLTWH(left, top, width, height);
// // // //
// // // //       // 1. Draw Bounding Box
// // // //       canvas.drawRect(r, boxPaint);
// // // //
// // // //       // 2. Prepare Label Text (Confidence %)
// // // //       final String text = "Rubber ${(d.conf * 100).toStringAsFixed(0)}%";
// // // //
// // // //       final textPainter = TextPainter(
// // // //         text: TextSpan(
// // // //           text: text,
// // // //           style: const TextStyle(
// // // //             color: Colors.white,
// // // //             fontSize: 10,
// // // //             fontWeight: FontWeight.bold,
// // // //           ),
// // // //         ),
// // // //         textDirection: TextDirection.ltr,
// // // //       );
// // // //
// // // //       textPainter.layout();
// // // //
// // // //       // 3. Draw Label Background (Small rectangle above/inside box)
// // // //       final labelBgRect = Rect.fromLTWH(
// // // //         left,
// // // //         top - textPainter.height - 4, // Positioned slightly above the box
// // // //         textPainter.width + 8,
// // // //         textPainter.height + 4,
// // // //       );
// // // //
// // // //       canvas.drawRect(labelBgRect, bgPaint);
// // // //
// // // //       // 4. Draw Text
// // // //       textPainter.paint(
// // // //         canvas,
// // // //         Offset(left + 4, top - textPainter.height - 2),
// // // //       );
// // // //     }
// // // //   }
// // // //
// // // //   @override
// // // //   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// // // // }
// // // //
// // // //
// // // //
// // // //
// // // // // class BoxPainter extends CustomPainter {
// // // // //   final List<Detection> detections;
// // // // //
// // // // //   BoxPainter(this.detections);
// // // // //
// // // // //   @override
// // // // //   void paint(Canvas canvas, Size size) {
// // // // //     final paint = Paint()
// // // // //       ..color = Colors.red
// // // // //       ..strokeWidth = 3
// // // // //       ..style = PaintingStyle.stroke;
// // // // //
// // // // //     for (var d in detections) {
// // // // //       final r = Rect.fromLTRB(
// // // // //         d.rect.left * size.width,
// // // // //         d.rect.top * size.height,
// // // // //         (d.rect.left + d.rect.width) * size.width,
// // // // //         (d.rect.top + d.rect.height) * size.height,
// // // // //       );
// // // // //
// // // // //       canvas.drawRect(r, paint);
// // // // //     }
// // // // //   }
// // // // //
// // // // //   @override
// // // // //   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// // // // // }
// // //
// // //
// // //
// // //
// // //
// // //
// // //
// // //
// // //
// // //
// // //
// // // //
// // // // import 'dart:io';
// // // // import 'dart:math';
// // // // import 'package:camera/camera.dart';
// // // // import 'package:flutter/material.dart';
// // // // import 'package:tflite_flutter/tflite_flutter.dart';
// // // // import 'package:image/image.dart' as img;
// // // //
// // // // class RubberCameraDetectorPage extends StatefulWidget {
// // // //   const RubberCameraDetectorPage({super.key});
// // // //
// // // //   @override
// // // //   State<RubberCameraDetectorPage> createState() =>
// // // //       _RubberCameraDetectorPageState();
// // // // }
// // // //
// // // // class _RubberCameraDetectorPageState extends State<RubberCameraDetectorPage> {
// // // //   CameraController? controller;
// // // //   Interpreter? interpreter;
// // // //
// // // //   File? capturedImage;
// // // //   List<Detection> detections = [];
// // // //
// // // //   FlashMode _flashMode = FlashMode.torch;
// // // //
// // // //   bool isLoading = true;
// // // //   bool isDetecting = false;
// // // //
// // // //   @override
// // // //   void initState() {
// // // //     super.initState();
// // // //     init();
// // // //   }
// // // //
// // // //   Future<void> init() async {
// // // //     final cams = await availableCameras();
// // // //
// // // //     controller = CameraController(
// // // //       cams[0],
// // // //       ResolutionPreset.medium,
// // // //       enableAudio: false,
// // // //     );
// // // //
// // // //     await controller!.initialize();
// // // //
// // // //     try {
// // // //       await controller!.setFlashMode(FlashMode.torch);
// // // //       _flashMode = FlashMode.torch;
// // // //     } catch (e) {
// // // //       debugPrint('Error enabling default flashlight: $e');
// // // //       _flashMode = FlashMode.off;
// // // //     }
// // // //
// // // //     interpreter = await Interpreter.fromAsset(
// // // //       'assets/model/best_float32.tflite',
// // // //     );
// // // //
// // // //     setState(() {
// // // //       isLoading = false;
// // // //     });
// // // //   }
// // // //
// // // //
// // // //   Future<void> _toggleFlash() async {
// // // //     if (controller == null || !controller!.value.isInitialized) return;
// // // //
// // // //     // Toggle between completely Off and Continuous Torch (Flashlight)
// // // //     final newMode = _flashMode == FlashMode.off ? FlashMode.torch : FlashMode.off;
// // // //
// // // //     try {
// // // //       await controller!.setFlashMode(newMode);
// // // //       setState(() {
// // // //         _flashMode = newMode;
// // // //       });
// // // //     } catch (e) {
// // // //       debugPrint('Error toggling camera flashlight: $e');
// // // //     }
// // // //   }
// // // //
// // // //   // =========================
// // // //   // CAPTURE IMAGE
// // // //   // =========================
// // // //   Future<void> captureImage() async {
// // // //     if (controller == null || !controller!.value.isInitialized) return;
// // // //
// // // //     final photo = await controller!.takePicture();
// // // //
// // // //     capturedImage = File(photo.path);
// // // //     detections.clear();
// // // //
// // // //     setState(() {});
// // // //   }
// // // //
// // // //   // =========================
// // // //   // RUN DETECTION
// // // //   // =========================
// // // //   Future<void> detectObjects() async {
// // // //     if (capturedImage == null || interpreter == null) return;
// // // //
// // // //
// // // //     setState(() {
// // // //       isDetecting = true;
// // // //     });
// // // //
// // // //     await Future.delayed(const Duration(milliseconds: 50));
// // // //
// // // //     try{
// // // //       final bytes = await capturedImage!.readAsBytes();
// // // //       img.Image? image = img.decodeImage(bytes);
// // // //
// // // //       if (image == null) return;
// // // //
// // // //       final inputImage = img.copyResize(image, width: 640, height: 640);
// // // //
// // // //       final input = [
// // // //         List.generate(640, (y) {
// // // //           return List.generate(640, (x) {
// // // //             final p = inputImage.getPixel(x, y);
// // // //             return [p.r / 255, p.g / 255, p.b / 255];
// // // //           });
// // // //         }),
// // // //       ];
// // // //
// // // //       final output = List.generate(
// // // //         1,
// // // //             (_) => List.generate(5, (_) => List.filled(8400, 0.0)),
// // // //       );
// // // //
// // // //       interpreter!.run(input, output);
// // // //
// // // //       List<Detection> raw = [];
// // // //
// // // //       for (int i = 0; i < 8400; i++) {
// // // //         double conf = output[0][4][i];
// // // //
// // // //         if (conf > 0.5) {
// // // //           raw.add(
// // // //             Detection(
// // // //               Rect.fromCenter(
// // // //                 center: Offset(output[0][0][i], output[0][1][i]),
// // // //                 width: output[0][2][i] * 1.40,
// // // //                 height: output[0][3][i]* 1.40,
// // // //               ),
// // // //               conf,
// // // //             ),
// // // //           );
// // // //         }
// // // //       }
// // // //
// // // //       detections = nms(raw, 0.5);
// // // //
// // // //       // --- CHECK FOR EMPTY DETECTIONS ---
// // // //       if (detections.isEmpty && mounted) {
// // // //         _showNoDetectionDialog();
// // // //       }
// // // //
// // // //     }catch(e){
// // // //       print('Object detection error: $e');
// // // //     }finally{
// // // //       setState(() {isDetecting = false;});
// // // //     }
// // // //   }
// // // //
// // // //   // =========================
// // // // // SHOW NO DETECTION DIALOG
// // // // // =========================
// // // //   void _showNoDetectionDialog() {
// // // //     showDialog(
// // // //       context: context,
// // // //       barrierDismissible: false,
// // // //       builder: (BuildContext context) {
// // // //         return AlertDialog(
// // // //           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
// // // //           title: const Row(
// // // //             children: [
// // // //               Icon(Icons.warning_amber_rounded, color: Colors.orange),
// // // //               SizedBox(width: 10),
// // // //               Text("No Object Found"),
// // // //             ],
// // // //           ),
// // // //           content: const Text(
// // // //             "The detector couldn't identify any objects in this image. Please try adjusting the lighting or position and take another photo.",
// // // //           ),
// // // //           actions: [
// // // //             TextButton(
// // // //               onPressed: () {
// // // //                 Navigator.of(context).pop();
// // // //                 setState(() {
// // // //                   capturedImage = null;
// // // //                   detections.clear();
// // // //                 });
// // // //               },
// // // //               child: const Text("Retake Photo"),
// // // //             ),
// // // //             TextButton(
// // // //               onPressed: () => Navigator.of(context).pop(),
// // // //               child: const Text("OK"),
// // // //             ),
// // // //           ],
// // // //         );
// // // //       },
// // // //     );
// // // //   }
// // // //
// // // //   // =========================
// // // //   // NMS
// // // //   // =========================
// // // //   List<Detection> nms(List<Detection> boxes, double iouThreshold) {
// // // //     boxes.sort((a, b) => b.conf.compareTo(a.conf));
// // // //
// // // //     List<Detection> result = [];
// // // //
// // // //     for (var box in boxes) {
// // // //       bool keep = true;
// // // //
// // // //       for (var selected in result) {
// // // //         if (iou(box.rect, selected.rect) > iouThreshold) {
// // // //           keep = false;
// // // //           break;
// // // //         }
// // // //       }
// // // //
// // // //       if (keep) result.add(box);
// // // //     }
// // // //
// // // //     return result;
// // // //   }
// // // //
// // // //   double iou(Rect a, Rect b) {
// // // //     final inter = a.intersect(b);
// // // //     final interArea = inter.width * inter.height;
// // // //
// // // //     final union = a.width * a.height + b.width * b.height - interArea;
// // // //
// // // //     return union == 0 ? 0 : interArea / union;
// // // //   }
// // // //
// // // //   // =========================
// // // //   // SUBMIT (CROP OBJECTS)
// // // //   // =========================
// // // //   Future<void> submit() async {
// // // //     if (capturedImage == null || detections.isEmpty) return;
// // // //
// // // //     final bytes = await capturedImage!.readAsBytes();
// // // //     img.Image? full = img.decodeImage(bytes);
// // // //
// // // //     if (full == null) return;
// // // //
// // // //     List<Map<String, dynamic>> result = [];
// // // //
// // // //     for (var d in detections) {
// // // //       final r = d.rect;
// // // //
// // // //       int x = (r.left * full.width).toInt();
// // // //       int y = (r.top * full.height).toInt();
// // // //       int w = (r.width * full.width).toInt();
// // // //       int h = (r.height * full.height).toInt();
// // // //
// // // //       x = max(0, x);
// // // //       y = max(0, y);
// // // //
// // // //       w = min(w, full.width - x);
// // // //       h = min(h, full.height - y);
// // // //
// // // //       final crop = img.copyCrop(full, x: x, y: y, width: w, height: h);
// // // //
// // // //       final path = capturedImage!.path.replaceAll(
// // // //         ".jpg",
// // // //         "_${DateTime.now().millisecondsSinceEpoch}.jpg",
// // // //       );
// // // //
// // // //       final file = File(path);
// // // //       await file.writeAsBytes(img.encodeJpg(crop));
// // // //
// // // //       result.add({"path": file.path, "conf": d.conf});
// // // //     }
// // // //
// // // //     if (mounted) Navigator.pop(context, result);
// // // //   }
// // // //
// // // //   @override
// // // //   void dispose() {
// // // //     controller?.dispose();
// // // //     interpreter?.close();
// // // //     super.dispose();
// // // //   }
// // // //
// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     if (isLoading || controller == null || !controller!.value.isInitialized) {
// // // //       return const Scaffold(body: Center(child: CircularProgressIndicator()));
// // // //     }
// // // //
// // // //     return Scaffold(
// // // //       body: LayoutBuilder(
// // // //         builder: (context, constraints) => SizedBox(
// // // //           width: double.infinity,
// // // //           height: double.infinity,
// // // //           child: Stack(
// // // //             children: [
// // // //               // CAMERA OR IMAGE
// // // //               capturedImage == null
// // // //                   ? SizedBox(
// // // //                 height: double.infinity,
// // // //                 width: double.infinity,
// // // //                 child: CameraPreview(
// // // //                   controller!,
// // // //                 ),
// // // //               )
// // // //                   : Image.file(
// // // //                 capturedImage!,
// // // //                 fit: BoxFit.fill,
// // // //                 width: double.infinity,
// // // //                 height: double.infinity,
// // // //               ),
// // // //
// // // //               // BOXES
// // // //               if (capturedImage != null)
// // // //                 Positioned.fill(
// // // //                   child: CustomPaint(painter: BoxPainter(detections)),
// // // //                 ),
// // // //
// // // //               // FLASH LIGHT TOGGLE BUTTON (Only visible when camera previewing)
// // // //               if (capturedImage == null)
// // // //                 Positioned(
// // // //                   top: 50,
// // // //                   right: 20,
// // // //                   child: SafeArea(
// // // //                     child: CircleAvatar(
// // // //                       backgroundColor: Colors.black45,
// // // //                       radius: 25,
// // // //                       child: IconButton(
// // // //                         icon: Icon(
// // // //                           _flashMode == FlashMode.torch
// // // //                               ? Icons.flash_on
// // // //                               : Icons.flash_off,
// // // //                           color: _flashMode == FlashMode.torch
// // // //                               ? Colors.yellowAccent
// // // //                               : Colors.white,
// // // //                           size: 26,
// // // //                         ),
// // // //                         onPressed: _toggleFlash,
// // // //                         tooltip: 'Toggle Flashlight',
// // // //                       ),
// // // //                     ),
// // // //                   ),
// // // //                 ),
// // // //
// // // //               if (capturedImage == null)
// // // //                 Positioned(
// // // //                   top: constraints.maxHeight * 0.2,
// // // //                   left: 40,
// // // //                   right: 40,
// // // //                   bottom: constraints.maxHeight * 0.3,
// // // //                   child: Container(
// // // //                     decoration: BoxDecoration(
// // // //                       border: Border.all(color: Colors.white24, width: 1),
// // // //                       borderRadius: BorderRadius.circular(12),
// // // //                     ),
// // // //                     child: Stack(
// // // //                       children: [
// // // //                         // Corner L-Shapes
// // // //                         _buildCorner(top: 0, left: 0, angle: 0),
// // // //                         _buildCorner(top: 0, right: 0, angle: 90),
// // // //                         _buildCorner(bottom: 0, left: 0, angle: 270),
// // // //                         _buildCorner(bottom: 0, right: 0, angle: 180),
// // // //                       ],
// // // //                     ),
// // // //                   ),
// // // //                 ),
// // // //
// // // //               // BUTTONS
// // // //               Positioned(
// // // //                 bottom: 40,
// // // //                 left: 0,
// // // //                 right: 0,
// // // //                 child: Column(
// // // //                   children: [
// // // //                     if (capturedImage == null)
// // // //                       GestureDetector(
// // // //                         onTap: captureImage,
// // // //                         child: Container(
// // // //                           // child: const Text("Capture"),
// // // //                           height: 60,
// // // //                           width: 60,
// // // //                           decoration: BoxDecoration(
// // // //                             shape: BoxShape.circle,
// // // //                             border: BoxBorder.all(color: Colors.black, width: 2),
// // // //                           ),
// // // //                           child: Center(child: Icon(Icons.camera, size: 30)),
// // // //                         ),
// // // //                       ),
// // // //
// // // //                     if (capturedImage != null && detections.isEmpty)
// // // //                       Row(
// // // //                         mainAxisAlignment: MainAxisAlignment.center,
// // // //                         children: [
// // // //                           Expanded(
// // // //                             child: ElevatedButton.icon(
// // // //                               style: ElevatedButton.styleFrom(
// // // //                                 backgroundColor: Colors.redAccent,
// // // //                                 foregroundColor: Colors.white,
// // // //                                 padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
// // // //                               ),
// // // //                               onPressed: isDetecting
// // // //                                   ? null
// // // //                                   : () => setState(() => capturedImage = null),
// // // //                               icon: const Icon(Icons.refresh),
// // // //                               label: const Text("Retake"),
// // // //                             ),
// // // //                           ),
// // // //                           const SizedBox(width: 20),
// // // //                           Expanded(
// // // //                             child: ElevatedButton(
// // // //                               onPressed: isDetecting
// // // //                                   ? null
// // // //                                   : detectObjects,
// // // //                               child: isDetecting
// // // //                                   ? const Text("Detecting...")
// // // //                                   : const Text("Detect"),
// // // //                             ),
// // // //                           ),
// // // //                         ],
// // // //                       ),
// // // //
// // // //                     if (detections.isNotEmpty)
// // // //                       ElevatedButton(
// // // //                         onPressed: submit,
// // // //                         child: const Text("Submit"),
// // // //                       ),
// // // //                   ],
// // // //                 ),
// // // //               ),
// // // //             ],
// // // //           ),
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }
// // // //
// // // //   Widget _buildCorner({
// // // //     double? top,
// // // //     double? left,
// // // //     double? right,
// // // //     double? bottom,
// // // //     required double angle,
// // // //   }) {
// // // //     return Positioned(
// // // //       top: top,
// // // //       left: left,
// // // //       right: right,
// // // //       bottom: bottom,
// // // //       child: Transform.rotate(
// // // //         angle: angle * pi / 180,
// // // //         child: Container(
// // // //           width: 30,
// // // //           height: 30,
// // // //           decoration: const BoxDecoration(
// // // //             border: Border(
// // // //               top: BorderSide(color: Colors.cyanAccent, width: 3),
// // // //               left: BorderSide(color: Colors.cyanAccent, width: 3),
// // // //             ),
// // // //           ),
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }
// // // // }
// // // //
// // // // // =========================
// // // // // MODEL
// // // // // =========================
// // // // class Detection {
// // // //   final Rect rect;
// // // //   final double conf;
// // // //
// // // //   Detection(this.rect, this.conf);
// // // // }
// // // //
// // // // // =========================
// // // // // PAINTER
// // // // // =========================
// // // //
// // // // class BoxPainter extends CustomPainter {
// // // //   final List<Detection> detections;
// // // //
// // // //   BoxPainter(this.detections);
// // // //
// // // //   @override
// // // //   void paint(Canvas canvas, Size size) {
// // // //     final boxPaint = Paint()
// // // //       ..color = Colors.red
// // // //       ..strokeWidth = 3
// // // //       ..style = PaintingStyle.stroke;
// // // //
// // // //     final bgPaint = Paint()
// // // //       ..color = Colors.red
// // // //       ..style = PaintingStyle.fill;
// // // //
// // // //     for (var d in detections) {
// // // //       // Calculate coordinates relative to canvas size
// // // //       final double left = d.rect.left * size.width;
// // // //       final double top = d.rect.top * size.height;
// // // //       final double width = d.rect.width * size.width;
// // // //       final double height = d.rect.height * size.height;
// // // //
// // // //       final r = Rect.fromLTWH(left, top, width, height);
// // // //
// // // //       // 1. Draw Bounding Box
// // // //       canvas.drawRect(r, boxPaint);
// // // //
// // // //       // 2. Prepare Label Text (Confidence %)
// // // //       final String text = "Rubber ${(d.conf * 100).toStringAsFixed(0)}%";
// // // //
// // // //       final textPainter = TextPainter(
// // // //         text: TextSpan(
// // // //           text: text,
// // // //           style: const TextStyle(
// // // //             color: Colors.white,
// // // //             fontSize: 10,
// // // //             fontWeight: FontWeight.bold,
// // // //           ),
// // // //         ),
// // // //         textDirection: TextDirection.ltr,
// // // //       );
// // // //
// // // //       textPainter.layout();
// // // //
// // // //       // 3. Draw Label Background (Small rectangle above/inside box)
// // // //       final labelBgRect = Rect.fromLTWH(
// // // //         left,
// // // //         top - textPainter.height - 4, // Positioned slightly above the box
// // // //         textPainter.width + 8,
// // // //         textPainter.height + 4,
// // // //       );
// // // //
// // // //       canvas.drawRect(labelBgRect, bgPaint);
// // // //
// // // //       // 4. Draw Text
// // // //       textPainter.paint(
// // // //         canvas,
// // // //         Offset(left + 4, top - textPainter.height - 2),
// // // //       );
// // // //     }
// // // //   }
// // // //
// // // //   @override
// // // //   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// // // // }
// // // //
// // // // // class BoxPainter extends CustomPainter {
// // // // //   final List<Detection> detections;
// // // // //
// // // // //   BoxPainter(this.detections);
// // // // //
// // // // //   @override
// // // // //   void paint(Canvas canvas, Size size) {
// // // // //     final paint = Paint()
// // // // //       ..color = Colors.red
// // // // //       ..strokeWidth = 3
// // // // //       ..style = PaintingStyle.stroke;
// // // // //
// // // // //     for (var d in detections) {
// // // // //       final r = Rect.fromLTRB(
// // // // //         d.rect.left * size.width,
// // // // //         d.rect.top * size.height,
// // // // //         (d.rect.left + d.rect.width) * size.width,
// // // // //         (d.rect.top + d.rect.height) * size.height,
// // // // //       );
// // // // //
// // // // //       canvas.drawRect(r, paint);
// // // // //     }
// // // // //   }
// // // // //
// // // // //   @override
// // // // //   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// // // // // }
// // //
// // //
// // //
// // // import 'dart:io';
// // // import 'dart:math';
// // // import 'package:camera/camera.dart';
// // // import 'package:flutter/material.dart';
// // // import 'package:tflite_flutter/tflite_flutter.dart';
// // // import 'package:image/image.dart' as img;
// // //
// // // class RubberCameraDetectorPage extends StatefulWidget {
// // //   const RubberCameraDetectorPage({super.key});
// // //
// // //   @override
// // //   State<RubberCameraDetectorPage> createState() =>
// // //       _RubberCameraDetectorPageState();
// // // }
// // //
// // // class CaptureResult {
// // //   final File parentImage;
// // //   final List<CroppedDetection> croppedDetections;
// // //   final int captureIndex;
// // //
// // //   CaptureResult({
// // //     required this.parentImage,
// // //     required this.croppedDetections,
// // //     required this.captureIndex,
// // //   });
// // // }
// // //
// // // class CroppedDetection {
// // //   final File croppedImage;
// // //   final double confidence;
// // //   final Rect originalRect;
// // //
// // //   CroppedDetection({
// // //     required this.croppedImage,
// // //     required this.confidence,
// // //     required this.originalRect,
// // //   });
// // // }
// // //
// // // class Detection {
// // //   final Rect rect;
// // //   final double conf;
// // //
// // //   Detection(this.rect, this.conf);
// // // }
// // //
// // // class _RubberCameraDetectorPageState extends State<RubberCameraDetectorPage> {
// // //   CameraController? controller;
// // //   Interpreter? interpreter;
// // //
// // //   File? currentCapturedImage;
// // //   List<Detection> currentDetections = [];
// // //
// // //   // Store all 5 capture results
// // //   List<CaptureResult> captureResults = [];
// // //
// // //   FlashMode _flashMode = FlashMode.torch;
// // //
// // //   bool isLoading = true;
// // //   bool isDetecting = false;
// // //   bool isProcessingCapture = false;
// // //
// // //   static const int maxCaptures = 5;
// // //
// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     init();
// // //   }
// // //
// // //   Future<void> init() async {
// // //     final cams = await availableCameras();
// // //
// // //     controller = CameraController(
// // //       cams[0],
// // //       ResolutionPreset.medium,
// // //       enableAudio: false,
// // //     );
// // //
// // //     await controller!.initialize();
// // //
// // //     try {
// // //       await controller!.setFlashMode(FlashMode.torch);
// // //       _flashMode = FlashMode.torch;
// // //     } catch (e) {
// // //       debugPrint('Error enabling default flashlight: $e');
// // //       _flashMode = FlashMode.off;
// // //     }
// // //
// // //     interpreter = await Interpreter.fromAsset(
// // //       'assets/model/best_float32.tflite',
// // //     );
// // //
// // //     setState(() {
// // //       isLoading = false;
// // //     });
// // //   }
// // //
// // //   Future<void> _toggleFlash() async {
// // //     if (controller == null || !controller!.value.isInitialized) return;
// // //
// // //     final newMode =
// // //     _flashMode == FlashMode.off ? FlashMode.torch : FlashMode.off;
// // //
// // //     try {
// // //       await controller!.setFlashMode(newMode);
// // //       setState(() {
// // //         _flashMode = newMode;
// // //       });
// // //     } catch (e) {
// // //       debugPrint('Error toggling camera flashlight: $e');
// // //     }
// // //   }
// // //
// // //   // =========================
// // //   // CAPTURE AND AUTO DETECT
// // //   // =========================
// // //   Future<void> captureAndDetect() async {
// // //     if (controller == null || !controller!.value.isInitialized) return;
// // //     if (isProcessingCapture) return;
// // //
// // //     setState(() {
// // //       isProcessingCapture = true;
// // //       currentCapturedImage = null;
// // //       currentDetections.clear();
// // //     });
// // //
// // //     try {
// // //       final photo = await controller!.takePicture();
// // //       currentCapturedImage = File(photo.path);
// // //
// // //       setState(() {});
// // //
// // //       // Auto detect
// // //       await _runDetection();
// // //     } catch (e) {
// // //       debugPrint('Capture error: $e');
// // //       setState(() {
// // //         isProcessingCapture = false;
// // //       });
// // //     }
// // //   }
// // //
// // //   // =========================
// // //   // RUN DETECTION AUTOMATICALLY
// // //   // =========================
// // //   Future<void> _runDetection() async {
// // //     if (currentCapturedImage == null || interpreter == null) return;
// // //
// // //     setState(() {
// // //       isDetecting = true;
// // //     });
// // //
// // //     await Future.delayed(const Duration(milliseconds: 50));
// // //
// // //     try {
// // //       final bytes = await currentCapturedImage!.readAsBytes();
// // //       img.Image? image = img.decodeImage(bytes);
// // //
// // //       if (image == null) {
// // //         setState(() {
// // //           isDetecting = false;
// // //           isProcessingCapture = false;
// // //         });
// // //         return;
// // //       }
// // //
// // //       final inputImage = img.copyResize(image, width: 640, height: 640);
// // //
// // //       final input = [
// // //         List.generate(640, (y) {
// // //           return List.generate(640, (x) {
// // //             final p = inputImage.getPixel(x, y);
// // //             return [p.r / 255, p.g / 255, p.b / 255];
// // //           });
// // //         }),
// // //       ];
// // //
// // //       final output = List.generate(
// // //         1,
// // //             (_) => List.generate(5, (_) => List.filled(8400, 0.0)),
// // //       );
// // //
// // //       interpreter!.run(input, output);
// // //
// // //       List<Detection> raw = [];
// // //
// // //       for (int i = 0; i < 8400; i++) {
// // //         double conf = output[0][4][i];
// // //
// // //         if (conf > 0.5) {
// // //           raw.add(
// // //             Detection(
// // //               Rect.fromCenter(
// // //                 center: Offset(output[0][0][i], output[0][1][i]),
// // //                 width: output[0][2][i] * 1.40,
// // //                 height: output[0][3][i] * 1.40,
// // //               ),
// // //               conf,
// // //             ),
// // //           );
// // //         }
// // //       }
// // //
// // //       currentDetections = nms(raw, 0.5);
// // //
// // //       if (currentDetections.isEmpty && mounted) {
// // //         setState(() {
// // //           isDetecting = false;
// // //           isProcessingCapture = false;
// // //         });
// // //         _showNoDetectionDialog();
// // //         return;
// // //       }
// // //
// // //       // Auto crop and save results
// // //       await _processAndSaveCapture();
// // //     } catch (e) {
// // //       print('Object detection error: $e');
// // //       setState(() {
// // //         isProcessingCapture = false;
// // //       });
// // //     } finally {
// // //       setState(() {
// // //         isDetecting = false;
// // //       });
// // //     }
// // //   }
// // //
// // //   // =========================
// // //   // PROCESS AND SAVE CAPTURE
// // //   // =========================
// // //   Future<void> _processAndSaveCapture() async {
// // //     if (currentCapturedImage == null || currentDetections.isEmpty) return;
// // //
// // //     final bytes = await currentCapturedImage!.readAsBytes();
// // //     img.Image? full = img.decodeImage(bytes);
// // //
// // //     if (full == null) return;
// // //
// // //     List<CroppedDetection> croppedList = [];
// // //
// // //     for (var d in currentDetections) {
// // //       final r = d.rect;
// // //
// // //       int x = (r.left * full.width).toInt();
// // //       int y = (r.top * full.height).toInt();
// // //       int w = (r.width * full.width).toInt();
// // //       int h = (r.height * full.height).toInt();
// // //
// // //       x = max(0, x);
// // //       y = max(0, y);
// // //       w = min(w, full.width - x);
// // //       h = min(h, full.height - y);
// // //
// // //       if (w <= 0 || h <= 0) continue;
// // //
// // //       final crop = img.copyCrop(full, x: x, y: y, width: w, height: h);
// // //
// // //       final path = currentCapturedImage!.path.replaceAll(
// // //         ".jpg",
// // //         "_crop_${DateTime.now().millisecondsSinceEpoch}.jpg",
// // //       );
// // //
// // //       final file = File(path);
// // //       await file.writeAsBytes(img.encodeJpg(crop));
// // //
// // //       croppedList.add(CroppedDetection(
// // //         croppedImage: file,
// // //         confidence: d.conf,
// // //         originalRect: d.rect,
// // //       ));
// // //     }
// // //
// // //     final captureResult = CaptureResult(
// // //       parentImage: currentCapturedImage!,
// // //       croppedDetections: croppedList,
// // //       captureIndex: captureResults.length + 1,
// // //     );
// // //
// // //     setState(() {
// // //       captureResults.add(captureResult);
// // //       currentCapturedImage = null;
// // //       currentDetections.clear();
// // //       isProcessingCapture = false;
// // //     });
// // //   }
// // //
// // //   // =========================
// // //   // SHOW NO DETECTION DIALOG
// // //   // =========================
// // //   void _showNoDetectionDialog() {
// // //     showDialog(
// // //       context: context,
// // //       barrierDismissible: false,
// // //       builder: (BuildContext context) {
// // //         return AlertDialog(
// // //           shape:
// // //           RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
// // //           title: const Row(
// // //             children: [
// // //               Icon(Icons.warning_amber_rounded, color: Colors.orange),
// // //               SizedBox(width: 10),
// // //               Text("No Object Found"),
// // //             ],
// // //           ),
// // //           content: const Text(
// // //             "The detector couldn't identify any objects in this image. "
// // //                 "Please try adjusting the lighting or position and take another photo.\n\n"
// // //                 "This retake will NOT count towards your 5 captures.",
// // //           ),
// // //           actions: [
// // //             TextButton(
// // //               onPressed: () {
// // //                 Navigator.of(context).pop();
// // //                 setState(() {
// // //                   currentCapturedImage = null;
// // //                   currentDetections.clear();
// // //                 });
// // //               },
// // //               child: const Text("Retake Photo"),
// // //             ),
// // //           ],
// // //         );
// // //       },
// // //     );
// // //   }
// // //
// // //   // =========================
// // //   // RETAKE LAST CAPTURE
// // //   // =========================
// // //   void retakeLastCapture() {
// // //     if (captureResults.isNotEmpty) {
// // //       setState(() {
// // //         captureResults.removeLast();
// // //       });
// // //     }
// // //   }
// // //
// // //   // =========================
// // //   // NMS
// // //   // =========================
// // //   List<Detection> nms(List<Detection> boxes, double iouThreshold) {
// // //     boxes.sort((a, b) => b.conf.compareTo(a.conf));
// // //
// // //     List<Detection> result = [];
// // //
// // //     for (var box in boxes) {
// // //       bool keep = true;
// // //
// // //       for (var selected in result) {
// // //         if (iou(box.rect, selected.rect) > iouThreshold) {
// // //           keep = false;
// // //           break;
// // //         }
// // //       }
// // //
// // //       if (keep) result.add(box);
// // //     }
// // //
// // //     return result;
// // //   }
// // //
// // //   double iou(Rect a, Rect b) {
// // //     final inter = a.intersect(b);
// // //     final interArea = inter.width * inter.height;
// // //
// // //     final union = a.width * a.height + b.width * b.height - interArea;
// // //
// // //     return union == 0 ? 0 : interArea / union;
// // //   }
// // //
// // //   // =========================
// // //   // SUBMIT ALL 5 CAPTURES
// // //   // =========================
// // //   Future<void> submitAll() async {
// // //     if (captureResults.isEmpty) return;
// // //
// // //     List<Map<String, dynamic>> result = [];
// // //
// // //     for (var capture in captureResults) {
// // //       // Parent image
// // //       result.add({
// // //         "path": capture.parentImage.path,
// // //         "type": "parent",
// // //         "captureIndex": capture.captureIndex,
// // //         "conf": 1.0,
// // //       });
// // //
// // //       // Child (cropped) images
// // //       for (var cropped in capture.croppedDetections) {
// // //         result.add({
// // //           "path": cropped.croppedImage.path,
// // //           "type": "child",
// // //           "captureIndex": capture.captureIndex,
// // //           "conf": cropped.confidence,
// // //         });
// // //       }
// // //     }
// // //
// // //     if (mounted) Navigator.pop(context, result);
// // //   }
// // //
// // //   @override
// // //   void dispose() {
// // //     controller?.dispose();
// // //     interpreter?.close();
// // //     super.dispose();
// // //   }
// // //
// // //   // =========================
// // //   // BUILD
// // //   // =========================
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     if (isLoading || controller == null || !controller!.value.isInitialized) {
// // //       return const Scaffold(body: Center(child: CircularProgressIndicator()));
// // //     }
// // //
// // //     return Scaffold(
// // //       backgroundColor: Colors.black,
// // //       body: LayoutBuilder(
// // //         builder: (context, constraints) => SizedBox(
// // //           width: double.infinity,
// // //           height: double.infinity,
// // //           child: Stack(
// // //             children: [
// // //               // ==================
// // //               // CAMERA PREVIEW
// // //               // ==================
// // //               if (!isProcessingCapture)
// // //                 SizedBox(
// // //                   height: double.infinity,
// // //                   width: double.infinity,
// // //                   child: CameraPreview(controller!),
// // //                 ),
// // //
// // //               // ==================
// // //               // PROCESSING OVERLAY
// // //               // ==================
// // //               if (isProcessingCapture)
// // //                 Container(
// // //                   color: Colors.black,
// // //                   child: Center(
// // //                     child: Column(
// // //                       mainAxisSize: MainAxisSize.min,
// // //                       children: [
// // //                         if (currentCapturedImage != null)
// // //                           ClipRRect(
// // //                             borderRadius: BorderRadius.circular(12),
// // //                             child: Image.file(
// // //                               currentCapturedImage!,
// // //                               width: 250,
// // //                               height: 250,
// // //                               fit: BoxFit.cover,
// // //                             ),
// // //                           ),
// // //                         const SizedBox(height: 20),
// // //                         const CircularProgressIndicator(color: Colors.cyan),
// // //                         const SizedBox(height: 12),
// // //                         Text(
// // //                           isDetecting ? "Detecting objects..." : "Processing...",
// // //                           style: const TextStyle(
// // //                               color: Colors.white, fontSize: 16),
// // //                         ),
// // //                       ],
// // //                     ),
// // //                   ),
// // //                 ),
// // //
// // //               // ==================
// // //               // TOP: CAPTURED IMAGES GALLERY
// // //               // ==================
// // //               if (captureResults.isNotEmpty)
// // //                 Positioned(
// // //                   top: 0,
// // //                   left: 0,
// // //                   right: 0,
// // //                   child: Container(
// // //                     color: Colors.black.withOpacity(0.85),
// // //                     child: SafeArea(
// // //                       bottom: false,
// // //                       child: Column(
// // //                         crossAxisAlignment: CrossAxisAlignment.start,
// // //                         children: [
// // //                           Padding(
// // //                             padding: const EdgeInsets.symmetric(
// // //                                 horizontal: 12, vertical: 6),
// // //                             child: Row(
// // //                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //                               children: [
// // //                                 Text(
// // //                                   "Captures: ${captureResults.length} / $maxCaptures",
// // //                                   style: const TextStyle(
// // //                                     color: Colors.white,
// // //                                     fontSize: 14,
// // //                                     fontWeight: FontWeight.bold,
// // //                                   ),
// // //                                 ),
// // //                                 // Progress indicator dots
// // //                                 Row(
// // //                                   children: List.generate(maxCaptures, (i) {
// // //                                     return Container(
// // //                                       margin: const EdgeInsets.symmetric(
// // //                                           horizontal: 3),
// // //                                       width: 12,
// // //                                       height: 12,
// // //                                       decoration: BoxDecoration(
// // //                                         shape: BoxShape.circle,
// // //                                         color: i < captureResults.length
// // //                                             ? Colors.cyanAccent
// // //                                             : Colors.white24,
// // //                                         border: Border.all(
// // //                                             color: Colors.white38, width: 1),
// // //                                       ),
// // //                                     );
// // //                                   }),
// // //                                 ),
// // //                               ],
// // //                             ),
// // //                           ),
// // //                           SizedBox(
// // //                             height: 150,
// // //                             child: ListView.builder(
// // //                               scrollDirection: Axis.horizontal,
// // //                               padding:
// // //                               const EdgeInsets.symmetric(horizontal: 8),
// // //                               itemCount: captureResults.length,
// // //                               itemBuilder: (context, index) {
// // //                                 return _buildCaptureCard(
// // //                                     captureResults[index], index);
// // //                               },
// // //                             ),
// // //                           ),
// // //                           const SizedBox(height: 6),
// // //                         ],
// // //                       ),
// // //                     ),
// // //                   ),
// // //                 ),
// // //
// // //               // ==================
// // //               // GUIDE FRAME (when camera previewing)
// // //               // ==================
// // //               if (!isProcessingCapture)
// // //                 Positioned(
// // //                   top: captureResults.isNotEmpty
// // //                       ? constraints.maxHeight * 0.35
// // //                       : constraints.maxHeight * 0.2,
// // //                   left: 40,
// // //                   right: 40,
// // //                   bottom: constraints.maxHeight * 0.3,
// // //                   child: Container(
// // //                     decoration: BoxDecoration(
// // //                       border: Border.all(color: Colors.white24, width: 1),
// // //                       borderRadius: BorderRadius.circular(12),
// // //                     ),
// // //                     child: Stack(
// // //                       children: [
// // //                         _buildCorner(top: 0, left: 0, angle: 0),
// // //                         _buildCorner(top: 0, right: 0, angle: 90),
// // //                         _buildCorner(bottom: 0, left: 0, angle: 270),
// // //                         _buildCorner(bottom: 0, right: 0, angle: 180),
// // //                       ],
// // //                     ),
// // //                   ),
// // //                 ),
// // //
// // //               // ==================
// // //               // FLASH TOGGLE
// // //               // ==================
// // //               if (!isProcessingCapture && captureResults.isEmpty)
// // //                 Positioned(
// // //                   top: 50,
// // //                   right: 20,
// // //                   child: SafeArea(
// // //                     child: CircleAvatar(
// // //                       backgroundColor: Colors.black45,
// // //                       radius: 25,
// // //                       child: IconButton(
// // //                         icon: Icon(
// // //                           _flashMode == FlashMode.torch
// // //                               ? Icons.flash_on
// // //                               : Icons.flash_off,
// // //                           color: _flashMode == FlashMode.torch
// // //                               ? Colors.yellowAccent
// // //                               : Colors.white,
// // //                           size: 26,
// // //                         ),
// // //                         onPressed: _toggleFlash,
// // //                         tooltip: 'Toggle Flashlight',
// // //                       ),
// // //                     ),
// // //                   ),
// // //                 ),
// // //
// // //               if (!isProcessingCapture && captureResults.isNotEmpty)
// // //                 Positioned(
// // //                   top: 230,
// // //                   right: 20,
// // //                   child: CircleAvatar(
// // //                     backgroundColor: Colors.black45,
// // //                     radius: 22,
// // //                     child: IconButton(
// // //                       icon: Icon(
// // //                         _flashMode == FlashMode.torch
// // //                             ? Icons.flash_on
// // //                             : Icons.flash_off,
// // //                         color: _flashMode == FlashMode.torch
// // //                             ? Colors.yellowAccent
// // //                             : Colors.white,
// // //                         size: 22,
// // //                       ),
// // //                       onPressed: _toggleFlash,
// // //                       tooltip: 'Toggle Flashlight',
// // //                     ),
// // //                   ),
// // //                 ),
// // //
// // //               // ==================
// // //               // BOTTOM BUTTONS
// // //               // ==================
// // //               Positioned(
// // //                 bottom: 30,
// // //                 left: 20,
// // //                 right: 20,
// // //                 child: Column(
// // //                   children: [
// // //                     // Capture button
// // //                     if (!isProcessingCapture &&
// // //                         captureResults.length < maxCaptures)
// // //                       Column(
// // //                         children: [
// // //                           Text(
// // //                             "Tap to capture (${captureResults.length + 1} of $maxCaptures)",
// // //                             style: const TextStyle(
// // //                               color: Colors.white70,
// // //                               fontSize: 13,
// // //                             ),
// // //                           ),
// // //                           const SizedBox(height: 10),
// // //                           Row(
// // //                             mainAxisAlignment: MainAxisAlignment.center,
// // //                             children: [
// // //                               // Retake last button
// // //                               if (captureResults.isNotEmpty)
// // //                                 GestureDetector(
// // //                                   onTap: retakeLastCapture,
// // //                                   child: Container(
// // //                                     height: 50,
// // //                                     width: 50,
// // //                                     decoration: BoxDecoration(
// // //                                       shape: BoxShape.circle,
// // //                                       color: Colors.redAccent.withOpacity(0.8),
// // //                                       border: Border.all(
// // //                                           color: Colors.white54, width: 2),
// // //                                     ),
// // //                                     child: const Center(
// // //                                       child: Icon(Icons.undo,
// // //                                           size: 24, color: Colors.white),
// // //                                     ),
// // //                                   ),
// // //                                 ),
// // //
// // //                               if (captureResults.isNotEmpty)
// // //                                 const SizedBox(width: 30),
// // //
// // //                               // Capture button
// // //                               GestureDetector(
// // //                                 onTap: captureAndDetect,
// // //                                 child: Container(
// // //                                   height: 70,
// // //                                   width: 70,
// // //                                   decoration: BoxDecoration(
// // //                                     shape: BoxShape.circle,
// // //                                     color: Colors.white,
// // //                                     border: Border.all(
// // //                                         color: Colors.cyanAccent, width: 4),
// // //                                   ),
// // //                                   child: const Center(
// // //                                     child: Icon(Icons.camera_alt,
// // //                                         size: 32, color: Colors.black87),
// // //                                   ),
// // //                                 ),
// // //                               ),
// // //
// // //                               // Submit early button
// // //                               if (captureResults.isNotEmpty)
// // //                                 const SizedBox(width: 30),
// // //
// // //                               if (captureResults.isNotEmpty)
// // //                                 GestureDetector(
// // //                                   onTap: submitAll,
// // //                                   child: Container(
// // //                                     height: 50,
// // //                                     width: 50,
// // //                                     decoration: BoxDecoration(
// // //                                       shape: BoxShape.circle,
// // //                                       color: Colors.green.withOpacity(0.8),
// // //                                       border: Border.all(
// // //                                           color: Colors.white54, width: 2),
// // //                                     ),
// // //                                     child: const Center(
// // //                                       child: Icon(Icons.check,
// // //                                           size: 24, color: Colors.white),
// // //                                     ),
// // //                                   ),
// // //                                 ),
// // //                             ],
// // //                           ),
// // //                         ],
// // //                       ),
// // //
// // //                     // All 5 captured - Submit
// // //                     if (!isProcessingCapture &&
// // //                         captureResults.length >= maxCaptures)
// // //                       Column(
// // //                         children: [
// // //                           const Text(
// // //                             "All 5 images captured!",
// // //                             style: TextStyle(
// // //                               color: Colors.cyanAccent,
// // //                               fontSize: 16,
// // //                               fontWeight: FontWeight.bold,
// // //                             ),
// // //                           ),
// // //                           const SizedBox(height: 12),
// // //                           Row(
// // //                             mainAxisAlignment: MainAxisAlignment.center,
// // //                             children: [
// // //                               ElevatedButton.icon(
// // //                                 style: ElevatedButton.styleFrom(
// // //                                   backgroundColor: Colors.redAccent,
// // //                                   foregroundColor: Colors.white,
// // //                                   padding: const EdgeInsets.symmetric(
// // //                                       horizontal: 20, vertical: 12),
// // //                                   shape: RoundedRectangleBorder(
// // //                                       borderRadius: BorderRadius.circular(25)),
// // //                                 ),
// // //                                 onPressed: retakeLastCapture,
// // //                                 icon: const Icon(Icons.undo),
// // //                                 label: const Text("Undo Last"),
// // //                               ),
// // //                               const SizedBox(width: 20),
// // //                               ElevatedButton.icon(
// // //                                 style: ElevatedButton.styleFrom(
// // //                                   backgroundColor: Colors.green,
// // //                                   foregroundColor: Colors.white,
// // //                                   padding: const EdgeInsets.symmetric(
// // //                                       horizontal: 30, vertical: 14),
// // //                                   shape: RoundedRectangleBorder(
// // //                                       borderRadius: BorderRadius.circular(25)),
// // //                                 ),
// // //                                 onPressed: submitAll,
// // //                                 icon: const Icon(Icons.send),
// // //                                 label: const Text("Submit All"),
// // //                               ),
// // //                             ],
// // //                           ),
// // //                         ],
// // //                       ),
// // //                   ],
// // //                 ),
// // //               ),
// // //             ],
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }
// // //
// // //   // =========================
// // //   // CAPTURE CARD WIDGET
// // //   // =========================
// // //   Widget _buildCaptureCard(CaptureResult capture, int index) {
// // //     return GestureDetector(
// // //       onTap: () => _showCaptureDetail(capture),
// // //       child: Container(
// // //         width: 130,
// // //         margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
// // //         decoration: BoxDecoration(
// // //           color: Colors.grey[900],
// // //           borderRadius: BorderRadius.circular(10),
// // //           border: Border.all(color: Colors.cyanAccent.withOpacity(0.5), width: 1),
// // //         ),
// // //         child: Column(
// // //           crossAxisAlignment: CrossAxisAlignment.start,
// // //           children: [
// // //             // Capture number header
// // //             Container(
// // //               width: double.infinity,
// // //               padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
// // //               decoration: BoxDecoration(
// // //                 color: Colors.cyanAccent.withOpacity(0.2),
// // //                 borderRadius: const BorderRadius.only(
// // //                   topLeft: Radius.circular(9),
// // //                   topRight: Radius.circular(9),
// // //                 ),
// // //               ),
// // //               child: Text(
// // //                 "Capture #${capture.captureIndex}",
// // //                 style: const TextStyle(
// // //                   color: Colors.cyanAccent,
// // //                   fontSize: 10,
// // //                   fontWeight: FontWeight.bold,
// // //                 ),
// // //               ),
// // //             ),
// // //
// // //             // Parent image
// // //             Padding(
// // //               padding: const EdgeInsets.all(4),
// // //               child: Row(
// // //                 children: [
// // //                   // Parent thumbnail
// // //                   Column(
// // //                     children: [
// // //                       ClipRRect(
// // //                         borderRadius: BorderRadius.circular(6),
// // //                         child: Image.file(
// // //                           capture.parentImage,
// // //                           width: 45,
// // //                           height: 45,
// // //                           fit: BoxFit.cover,
// // //                         ),
// // //                       ),
// // //                       const SizedBox(height: 2),
// // //                       Container(
// // //                         padding: const EdgeInsets.symmetric(
// // //                             horizontal: 4, vertical: 1),
// // //                         decoration: BoxDecoration(
// // //                           color: Colors.blue.withOpacity(0.3),
// // //                           borderRadius: BorderRadius.circular(4),
// // //                         ),
// // //                         child: const Text(
// // //                           "Parent",
// // //                           style: TextStyle(
// // //                             color: Colors.lightBlueAccent,
// // //                             fontSize: 7,
// // //                             fontWeight: FontWeight.bold,
// // //                           ),
// // //                         ),
// // //                       ),
// // //                     ],
// // //                   ),
// // //
// // //                   const SizedBox(width: 4),
// // //
// // //                   // Cropped children
// // //                   Expanded(
// // //                     child: SizedBox(
// // //                       height: 60,
// // //                       child: ListView.builder(
// // //                         scrollDirection: Axis.horizontal,
// // //                         itemCount: capture.croppedDetections.length,
// // //                         itemBuilder: (context, ci) {
// // //                           final cropped = capture.croppedDetections[ci];
// // //                           return Padding(
// // //                             padding: const EdgeInsets.only(right: 3),
// // //                             child: Column(
// // //                               children: [
// // //                                 ClipRRect(
// // //                                   borderRadius: BorderRadius.circular(4),
// // //                                   child: Image.file(
// // //                                     cropped.croppedImage,
// // //                                     width: 35,
// // //                                     height: 35,
// // //                                     fit: BoxFit.cover,
// // //                                   ),
// // //                                 ),
// // //                                 const SizedBox(height: 2),
// // //                                 Container(
// // //                                   padding: const EdgeInsets.symmetric(
// // //                                       horizontal: 3, vertical: 1),
// // //                                   decoration: BoxDecoration(
// // //                                     color: Colors.orange.withOpacity(0.3),
// // //                                     borderRadius: BorderRadius.circular(4),
// // //                                   ),
// // //                                   child: const Text(
// // //                                     "Child",
// // //                                     style: TextStyle(
// // //                                       color: Colors.orangeAccent,
// // //                                       fontSize: 7,
// // //                                       fontWeight: FontWeight.bold,
// // //                                     ),
// // //                                   ),
// // //                                 ),
// // //                                 Text(
// // //                                   "${(cropped.confidence * 100).toStringAsFixed(0)}%",
// // //                                   style: const TextStyle(
// // //                                     color: Colors.white54,
// // //                                     fontSize: 7,
// // //                                   ),
// // //                                 ),
// // //                               ],
// // //                             ),
// // //                           );
// // //                         },
// // //                       ),
// // //                     ),
// // //                   ),
// // //                 ],
// // //               ),
// // //             ),
// // //
// // //             // Detection count
// // //             Padding(
// // //               padding: const EdgeInsets.symmetric(horizontal: 6),
// // //               child: Text(
// // //                 "${capture.croppedDetections.length} object(s) detected",
// // //                 style: const TextStyle(
// // //                   color: Colors.white38,
// // //                   fontSize: 8,
// // //                 ),
// // //               ),
// // //             ),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }
// // //
// // //   // =========================
// // //   // SHOW CAPTURE DETAIL DIALOG
// // //   // =========================
// // //   void _showCaptureDetail(CaptureResult capture) {
// // //     showDialog(
// // //       context: context,
// // //       builder: (context) {
// // //         return Dialog(
// // //           backgroundColor: Colors.grey[900],
// // //           shape:
// // //           RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
// // //           child: Container(
// // //             constraints: const BoxConstraints(maxHeight: 500),
// // //             padding: const EdgeInsets.all(16),
// // //             child: Column(
// // //               mainAxisSize: MainAxisSize.min,
// // //               crossAxisAlignment: CrossAxisAlignment.start,
// // //               children: [
// // //                 // Header
// // //                 Row(
// // //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //                   children: [
// // //                     Text(
// // //                       "Capture #${capture.captureIndex}",
// // //                       style: const TextStyle(
// // //                         color: Colors.cyanAccent,
// // //                         fontSize: 18,
// // //                         fontWeight: FontWeight.bold,
// // //                       ),
// // //                     ),
// // //                     IconButton(
// // //                       icon: const Icon(Icons.close, color: Colors.white54),
// // //                       onPressed: () => Navigator.pop(context),
// // //                     ),
// // //                   ],
// // //                 ),
// // //
// // //                 const SizedBox(height: 10),
// // //
// // //                 // Parent image
// // //                 const Text(
// // //                   "📷 Parent Image",
// // //                   style: TextStyle(
// // //                     color: Colors.lightBlueAccent,
// // //                     fontWeight: FontWeight.bold,
// // //                     fontSize: 13,
// // //                   ),
// // //                 ),
// // //                 const SizedBox(height: 6),
// // //                 ClipRRect(
// // //                   borderRadius: BorderRadius.circular(10),
// // //                   child: Image.file(
// // //                     capture.parentImage,
// // //                     width: double.infinity,
// // //                     height: 150,
// // //                     fit: BoxFit.cover,
// // //                   ),
// // //                 ),
// // //
// // //                 const SizedBox(height: 12),
// // //
// // //                 // Cropped children
// // //                 Text(
// // //                   "🔍 Detected Objects (${capture.croppedDetections.length})",
// // //                   style: const TextStyle(
// // //                     color: Colors.orangeAccent,
// // //                     fontWeight: FontWeight.bold,
// // //                     fontSize: 13,
// // //                   ),
// // //                 ),
// // //                 const SizedBox(height: 6),
// // //
// // //                 SizedBox(
// // //                   height: 100,
// // //                   child: ListView.builder(
// // //                     scrollDirection: Axis.horizontal,
// // //                     itemCount: capture.croppedDetections.length,
// // //                     itemBuilder: (context, i) {
// // //                       final cropped = capture.croppedDetections[i];
// // //                       return Container(
// // //                         width: 90,
// // //                         margin: const EdgeInsets.only(right: 8),
// // //                         decoration: BoxDecoration(
// // //                           borderRadius: BorderRadius.circular(8),
// // //                           border: Border.all(
// // //                               color: Colors.orangeAccent.withOpacity(0.5)),
// // //                         ),
// // //                         child: Column(
// // //                           children: [
// // //                             ClipRRect(
// // //                               borderRadius: const BorderRadius.only(
// // //                                 topLeft: Radius.circular(7),
// // //                                 topRight: Radius.circular(7),
// // //                               ),
// // //                               child: Image.file(
// // //                                 cropped.croppedImage,
// // //                                 width: 90,
// // //                                 height: 65,
// // //                                 fit: BoxFit.cover,
// // //                               ),
// // //                             ),
// // //                             const SizedBox(height: 4),
// // //                             Text(
// // //                               "Child - ${(cropped.confidence * 100).toStringAsFixed(0)}%",
// // //                               style: const TextStyle(
// // //                                 color: Colors.white70,
// // //                                 fontSize: 9,
// // //                               ),
// // //                             ),
// // //                           ],
// // //                         ),
// // //                       );
// // //                     },
// // //                   ),
// // //                 ),
// // //               ],
// // //             ),
// // //           ),
// // //         );
// // //       },
// // //     );
// // //   }
// // //
// // //   // =========================
// // //   // CORNER GUIDE
// // //   // =========================
// // //   Widget _buildCorner({
// // //     double? top,
// // //     double? left,
// // //     double? right,
// // //     double? bottom,
// // //     required double angle,
// // //   }) {
// // //     return Positioned(
// // //       top: top,
// // //       left: left,
// // //       right: right,
// // //       bottom: bottom,
// // //       child: Transform.rotate(
// // //         angle: angle * pi / 180,
// // //         child: Container(
// // //           width: 30,
// // //           height: 30,
// // //           decoration: const BoxDecoration(
// // //             border: Border(
// // //               top: BorderSide(color: Colors.cyanAccent, width: 3),
// // //               left: BorderSide(color: Colors.cyanAccent, width: 3),
// // //             ),
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }
// // //
// // // // =========================
// // // // PAINTER (kept for any future use)
// // // // =========================
// // // class BoxPainter extends CustomPainter {
// // //   final List<Detection> detections;
// // //
// // //   BoxPainter(this.detections);
// // //
// // //   @override
// // //   void paint(Canvas canvas, Size size) {
// // //     final boxPaint = Paint()
// // //       ..color = Colors.red
// // //       ..strokeWidth = 3
// // //       ..style = PaintingStyle.stroke;
// // //
// // //     final bgPaint = Paint()
// // //       ..color = Colors.red
// // //       ..style = PaintingStyle.fill;
// // //
// // //     for (var d in detections) {
// // //       final double left = d.rect.left * size.width;
// // //       final double top = d.rect.top * size.height;
// // //       final double width = d.rect.width * size.width;
// // //       final double height = d.rect.height * size.height;
// // //
// // //       final r = Rect.fromLTWH(left, top, width, height);
// // //
// // //       canvas.drawRect(r, boxPaint);
// // //
// // //       final String text = "Rubber ${(d.conf * 100).toStringAsFixed(0)}%";
// // //
// // //       final textPainter = TextPainter(
// // //         text: TextSpan(
// // //           text: text,
// // //           style: const TextStyle(
// // //             color: Colors.white,
// // //             fontSize: 10,
// // //             fontWeight: FontWeight.bold,
// // //           ),
// // //         ),
// // //         textDirection: TextDirection.ltr,
// // //       );
// // //
// // //       textPainter.layout();
// // //
// // //       final labelBgRect = Rect.fromLTWH(
// // //         left,
// // //         top - textPainter.height - 4,
// // //         textPainter.width + 8,
// // //         textPainter.height + 4,
// // //       );
// // //
// // //       canvas.drawRect(labelBgRect, bgPaint);
// // //
// // //       textPainter.paint(
// // //         canvas,
// // //         Offset(left + 4, top - textPainter.height - 2),
// // //       );
// // //     }
// // //   }
// // //
// // //   @override
// // //   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// // // }
// //
// //
// // import 'dart:io';
// // import 'dart:math';
// // import 'package:camera/camera.dart';
// // import 'package:flutter/material.dart';
// // import 'package:tflite_flutter/tflite_flutter.dart';
// // import 'package:image/image.dart' as img;
// //
// // class RubberCameraDetectorPage extends StatefulWidget {
// //   const RubberCameraDetectorPage({super.key});
// //
// //   @override
// //   State<RubberCameraDetectorPage> createState() =>
// //       _RubberCameraDetectorPageState();
// // }
// //
// // class CaptureResult {
// //   final File parentImage;
// //   final List<CroppedDetection> croppedDetections;
// //   final int captureIndex;
// //
// //   CaptureResult({
// //     required this.parentImage,
// //     required this.croppedDetections,
// //     required this.captureIndex,
// //   });
// // }
// //
// // class CroppedDetection {
// //   final File croppedImage;
// //   final double confidence;
// //   final Rect originalRect;
// //
// //   CroppedDetection({
// //     required this.croppedImage,
// //     required this.confidence,
// //     required this.originalRect,
// //   });
// // }
// //
// // class Detection {
// //   final Rect rect;
// //   final double conf;
// //
// //   Detection(this.rect, this.conf);
// // }
// //
// // class _RubberCameraDetectorPageState extends State<RubberCameraDetectorPage>
// //     with TickerProviderStateMixin {
// //   CameraController? controller;
// //   Interpreter? interpreter;
// //
// //   File? currentCapturedImage;
// //   List<Detection> currentDetections = [];
// //
// //   // Store all capture results
// //   List<CaptureResult> captureResults = [];
// //
// //   FlashMode _flashMode = FlashMode.torch;
// //
// //   bool isLoading = true;
// //   bool isDetecting = false;
// //   bool isProcessingCapture = false;
// //
// //   // Animation controllers for smooth transitions
// //   late AnimationController _processingAnimController;
// //   late Animation<double> _processingPulseAnim;
// //   late AnimationController _cardSlideController;
// //
// //   static const int maxCaptures = 5;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //
// //     // Processing pulse animation
// //     _processingAnimController = AnimationController(
// //       vsync: this,
// //       duration: const Duration(milliseconds: 1200),
// //     )..repeat(reverse: true);
// //
// //     _processingPulseAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
// //       CurvedAnimation(
// //         parent: _processingAnimController,
// //         curve: Curves.easeInOut,
// //       ),
// //     );
// //
// //     // Card slide animation
// //     _cardSlideController = AnimationController(
// //       vsync: this,
// //       duration: const Duration(milliseconds: 300),
// //     );
// //
// //     init();
// //   }
// //
// //   Future<void> init() async {
// //     final cams = await availableCameras();
// //
// //     controller = CameraController(
// //       cams[0],
// //       ResolutionPreset.medium,
// //       enableAudio: false,
// //     );
// //
// //     await controller!.initialize();
// //
// //     try {
// //       await controller!.setFlashMode(FlashMode.torch);
// //       _flashMode = FlashMode.torch;
// //     } catch (e) {
// //       debugPrint('Error enabling default flashlight: $e');
// //       _flashMode = FlashMode.off;
// //     }
// //
// //     interpreter = await Interpreter.fromAsset(
// //       'assets/model/best_float32.tflite',
// //     );
// //
// //     setState(() {
// //       isLoading = false;
// //     });
// //   }
// //
// //   Future<void> _toggleFlash() async {
// //     if (controller == null || !controller!.value.isInitialized) return;
// //
// //     final newMode =
// //     _flashMode == FlashMode.off ? FlashMode.torch : FlashMode.off;
// //
// //     try {
// //       await controller!.setFlashMode(newMode);
// //       setState(() {
// //         _flashMode = newMode;
// //       });
// //     } catch (e) {
// //       debugPrint('Error toggling camera flashlight: $e');
// //     }
// //   }
// //
// //   // =========================
// //   // CAPTURE AND AUTO DETECT
// //   // =========================
// //   Future<void> captureAndDetect() async {
// //     if (controller == null || !controller!.value.isInitialized) return;
// //     if (isProcessingCapture) return;
// //
// //     setState(() {
// //       isProcessingCapture = true;
// //       currentCapturedImage = null;
// //       currentDetections.clear();
// //     });
// //
// //     try {
// //       final photo = await controller!.takePicture();
// //       currentCapturedImage = File(photo.path);
// //
// //       // Show captured image first, then detect
// //       setState(() {});
// //
// //       // Small delay to show the captured image
// //       await Future.delayed(const Duration(milliseconds: 400));
// //
// //       // Run detection in background
// //       await _runDetection();
// //     } catch (e) {
// //       debugPrint('Capture error: $e');
// //       setState(() {
// //         isProcessingCapture = false;
// //       });
// //     }
// //   }
// //
// //   // =========================
// //   // RUN DETECTION (Smooth, non-blocking)
// //   // =========================
// //   Future<void> _runDetection() async {
// //     if (currentCapturedImage == null || interpreter == null) return;
// //
// //     setState(() {
// //       isDetecting = true;
// //       isProcessingCapture = true;
// //     });
// //
// //     // Start processing animation
// //     _processingAnimController.repeat(reverse: true);
// //
// //     try {
// //       final bytes = await currentCapturedImage!.readAsBytes();
// //       img.Image? image = img.decodeImage(bytes);
// //
// //       if (image == null) {
// //         _stopDetection();
// //         return;
// //       }
// //
// //       final inputImage = img.copyResize(image, width: 640, height: 640);
// //
// //       final input = [
// //         List.generate(640, (y) {
// //           return List.generate(640, (x) {
// //             final p = inputImage.getPixel(x, y);
// //             return [p.r / 255, p.g / 255, p.b / 255];
// //           });
// //         }),
// //       ];
// //
// //       final output = List.generate(
// //         1,
// //             (_) => List.generate(5, (_) => List.filled(8400, 0.0)),
// //       );
// //
// //       // Run inference
// //       await Future(() => interpreter!.run(input, output));
// //
// //       List<Detection> raw = [];
// //
// //       for (int i = 0; i < 8400; i++) {
// //         double conf = output[0][4][i];
// //
// //         if (conf > 0.5) {
// //           raw.add(
// //             Detection(
// //               Rect.fromCenter(
// //                 center: Offset(output[0][0][i], output[0][1][i]),
// //                 width: output[0][2][i] * 1.40,
// //                 height: output[0][3][i] * 1.40,
// //               ),
// //               conf,
// //             ),
// //           );
// //         }
// //       }
// //
// //       currentDetections = nms(raw, 0.5);
// //
// //       // Stop processing animation
// //       _processingAnimController.stop();
// //       _processingAnimController.reset();
// //
// //       // ✅ KEY CHANGE: If no objects detected, save PARENT ONLY
// //       if (currentDetections.isEmpty && mounted) {
// //         await _saveParentOnlyCapture();
// //         return;
// //       }
// //
// //       // Auto crop and save results
// //       await _processAndSaveCapture();
// //     } catch (e) {
// //       print('Object detection error: $e');
// //       _stopDetection();
// //     }
// //   }
// //
// //   void _stopDetection() {
// //     _processingAnimController.stop();
// //     _processingAnimController.reset();
// //     setState(() {
// //       isDetecting = false;
// //       isProcessingCapture = false;
// //     });
// //   }
// //
// //   // =========================
// //   // ✅ NEW: SAVE PARENT ONLY (When no objects detected)
// //   // =========================
// //   Future<void> _saveParentOnlyCapture() async {
// //     if (currentCapturedImage == null) return;
// //
// //     final captureResult = CaptureResult(
// //       parentImage: currentCapturedImage!,
// //       croppedDetections: [], // Empty - no objects detected
// //       captureIndex: captureResults.length + 1,
// //     );
// //
// //     // Animate card appearance
// //     _cardSlideController.forward(from: 0);
// //
// //     setState(() {
// //       captureResults.add(captureResult);
// //       currentCapturedImage = null;
// //       currentDetections.clear();
// //       isDetecting = false;
// //       isProcessingCapture = false;
// //     });
// //   }
// //
// //   // =========================
// //   // PROCESS AND SAVE CAPTURE (With detected objects)
// //   // =========================
// //   Future<void> _processAndSaveCapture() async {
// //     if (currentCapturedImage == null || currentDetections.isEmpty) return;
// //
// //     final bytes = await currentCapturedImage!.readAsBytes();
// //     img.Image? full = img.decodeImage(bytes);
// //
// //     if (full == null) {
// //       _stopDetection();
// //       return;
// //     }
// //
// //     List<CroppedDetection> croppedList = [];
// //
// //     for (var d in currentDetections) {
// //       final r = d.rect;
// //
// //       int x = (r.left * full.width).toInt();
// //       int y = (r.top * full.height).toInt();
// //       int w = (r.width * full.width).toInt();
// //       int h = (r.height * full.height).toInt();
// //
// //       x = max(0, x);
// //       y = max(0, y);
// //       w = min(w, full.width - x);
// //       h = min(h, full.height - y);
// //
// //       if (w <= 0 || h <= 0) continue;
// //
// //       final crop = img.copyCrop(full, x: x, y: y, width: w, height: h);
// //
// //       final path = currentCapturedImage!.path.replaceAll(
// //         ".jpg",
// //         "_crop_${DateTime.now().millisecondsSinceEpoch}_${croppedList.length}.jpg",
// //       );
// //
// //       final file = File(path);
// //       await file.writeAsBytes(img.encodeJpg(crop));
// //
// //       croppedList.add(CroppedDetection(
// //         croppedImage: file,
// //         confidence: d.conf,
// //         originalRect: d.rect,
// //       ));
// //     }
// //
// //     final captureResult = CaptureResult(
// //       parentImage: currentCapturedImage!,
// //       croppedDetections: croppedList,
// //       captureIndex: captureResults.length + 1,
// //     );
// //
// //     // Animate card appearance
// //     _cardSlideController.forward(from: 0);
// //
// //     setState(() {
// //       captureResults.add(captureResult);
// //       currentCapturedImage = null;
// //       currentDetections.clear();
// //       isDetecting = false;
// //       isProcessingCapture = false;
// //     });
// //   }
// //
// //   // =========================
// //   // RETAKE LAST CAPTURE
// //   // =========================
// //   void retakeLastCapture() {
// //     if (captureResults.isNotEmpty) {
// //       setState(() {
// //         captureResults.removeLast();
// //       });
// //     }
// //   }
// //
// //   // =========================
// //   // NMS
// //   // =========================
// //   List<Detection> nms(List<Detection> boxes, double iouThreshold) {
// //     boxes.sort((a, b) => b.conf.compareTo(a.conf));
// //
// //     List<Detection> result = [];
// //
// //     for (var box in boxes) {
// //       bool keep = true;
// //
// //       for (var selected in result) {
// //         if (iou(box.rect, selected.rect) > iouThreshold) {
// //           keep = false;
// //           break;
// //         }
// //       }
// //
// //       if (keep) result.add(box);
// //     }
// //
// //     return result;
// //   }
// //
// //   double iou(Rect a, Rect b) {
// //     final inter = a.intersect(b);
// //     final interArea = inter.width * inter.height;
// //
// //     final union = a.width * a.height + b.width * b.height - interArea;
// //
// //     return union == 0 ? 0 : interArea / union;
// //   }
// //
// //   // =========================
// //   // SUBMIT ALL CAPTURES
// //   // =========================
// //   Future<void> submitAll() async {
// //     if (captureResults.isEmpty) return;
// //
// //     List<Map<String, dynamic>> result = [];
// //
// //     for (var capture in captureResults) {
// //       // Parent image (always included)
// //       result.add({
// //         "path": capture.parentImage.path,
// //         "type": "parent",
// //         "captureIndex": capture.captureIndex,
// //         "conf": 1.0,
// //       });
// //
// //       // Child (cropped) images (only if detected)
// //       for (var cropped in capture.croppedDetections) {
// //         result.add({
// //           "path": cropped.croppedImage.path,
// //           "type": "child",
// //           "captureIndex": capture.captureIndex,
// //           "conf": cropped.confidence,
// //         });
// //       }
// //     }
// //
// //     if (mounted) Navigator.pop(context, result);
// //   }
// //
// //   @override
// //   void dispose() {
// //     _processingAnimController.dispose();
// //     _cardSlideController.dispose();
// //     controller?.dispose();
// //     interpreter?.close();
// //     super.dispose();
// //   }
// //
// //   // =========================
// //   // BUILD
// //   // =========================
// //   @override
// //   Widget build(BuildContext context) {
// //     if (isLoading || controller == null || !controller!.value.isInitialized) {
// //       return const Scaffold(
// //         backgroundColor: Colors.black,
// //         body: Center(
// //           child: Column(
// //             mainAxisSize: MainAxisSize.min,
// //             children: [
// //               CircularProgressIndicator(color: Colors.cyanAccent),
// //               SizedBox(height: 16),
// //               Text(
// //                 "Initializing Camera...",
// //                 style: TextStyle(color: Colors.white70, fontSize: 14),
// //               ),
// //             ],
// //           ),
// //         ),
// //       );
// //     }
// //
// //     return Scaffold(
// //       backgroundColor: Colors.black,
// //       body: LayoutBuilder(
// //         builder: (context, constraints) => SizedBox(
// //           width: double.infinity,
// //           height: double.infinity,
// //           child: Stack(
// //             children: [
// //               // ==================
// //               // CAMERA PREVIEW
// //               // ==================
// //               if (!isProcessingCapture)
// //                 SizedBox(
// //                   height: double.infinity,
// //                   width: double.infinity,
// //                   child: CameraPreview(controller!),
// //                 ),
// //
// //               // ==================
// //               // ✅ SMOOTH PROCESSING OVERLAY
// //               // ==================
// //               if (isProcessingCapture)
// //                 _buildProcessingOverlay(constraints),
// //
// //               // ==================
// //               // TOP: CAPTURED IMAGES GALLERY
// //               // ==================
// //               if (captureResults.isNotEmpty)
// //                 Positioned(
// //                   top: 0,
// //                   left: 0,
// //                   right: 0,
// //                   child: Container(
// //                     color: Colors.black.withOpacity(0.85),
// //                     child: SafeArea(
// //                       bottom: false,
// //                       child: Column(
// //                         crossAxisAlignment: CrossAxisAlignment.start,
// //                         children: [
// //                           Padding(
// //                             padding: const EdgeInsets.symmetric(
// //                                 horizontal: 12, vertical: 6),
// //                             child: Row(
// //                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                               children: [
// //                                 Text(
// //                                   "Captures: ${captureResults.length} / $maxCaptures",
// //                                   style: const TextStyle(
// //                                     color: Colors.white,
// //                                     fontSize: 14,
// //                                     fontWeight: FontWeight.bold,
// //                                   ),
// //                                 ),
// //                                 // Progress indicator dots
// //                                 Row(
// //                                   children: List.generate(maxCaptures, (i) {
// //                                     return Container(
// //                                       margin: const EdgeInsets.symmetric(
// //                                           horizontal: 3),
// //                                       width: 12,
// //                                       height: 12,
// //                                       decoration: BoxDecoration(
// //                                         shape: BoxShape.circle,
// //                                         color: i < captureResults.length
// //                                             ? Colors.cyanAccent
// //                                             : Colors.white24,
// //                                         border: Border.all(
// //                                             color: Colors.white38, width: 1),
// //                                       ),
// //                                     );
// //                                   }),
// //                                 ),
// //                               ],
// //                             ),
// //                           ),
// //                           SizedBox(
// //                             height: 150,
// //                             child: ListView.builder(
// //                               scrollDirection: Axis.horizontal,
// //                               padding:
// //                               const EdgeInsets.symmetric(horizontal: 8),
// //                               itemCount: captureResults.length,
// //                               itemBuilder: (context, index) {
// //                                 return _buildCaptureCard(
// //                                     captureResults[index], index);
// //                               },
// //                             ),
// //                           ),
// //                           const SizedBox(height: 6),
// //                         ],
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //
// //               // ==================
// //               // GUIDE FRAME (when camera previewing)
// //               // ==================
// //               if (!isProcessingCapture)
// //                 Positioned(
// //                   top: captureResults.isNotEmpty
// //                       ? constraints.maxHeight * 0.35
// //                       : constraints.maxHeight * 0.2,
// //                   left: 40,
// //                   right: 40,
// //                   bottom: constraints.maxHeight * 0.3,
// //                   child: Container(
// //                     decoration: BoxDecoration(
// //                       border: Border.all(color: Colors.white24, width: 1),
// //                       borderRadius: BorderRadius.circular(12),
// //                     ),
// //                     child: Stack(
// //                       children: [
// //                         _buildCorner(top: 0, left: 0, angle: 0),
// //                         _buildCorner(top: 0, right: 0, angle: 90),
// //                         _buildCorner(bottom: 0, left: 0, angle: 270),
// //                         _buildCorner(bottom: 0, right: 0, angle: 180),
// //                       ],
// //                     ),
// //                   ),
// //                 ),
// //
// //               // ==================
// //               // FLASH TOGGLE
// //               // ==================
// //               if (!isProcessingCapture && captureResults.isEmpty)
// //                 Positioned(
// //                   top: 50,
// //                   right: 20,
// //                   child: SafeArea(
// //                     child: CircleAvatar(
// //                       backgroundColor: Colors.black45,
// //                       radius: 25,
// //                       child: IconButton(
// //                         icon: Icon(
// //                           _flashMode == FlashMode.torch
// //                               ? Icons.flash_on
// //                               : Icons.flash_off,
// //                           color: _flashMode == FlashMode.torch
// //                               ? Colors.yellowAccent
// //                               : Colors.white,
// //                           size: 26,
// //                         ),
// //                         onPressed: _toggleFlash,
// //                         tooltip: 'Toggle Flashlight',
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //
// //               if (!isProcessingCapture && captureResults.isNotEmpty)
// //                 Positioned(
// //                   top: 230,
// //                   right: 20,
// //                   child: CircleAvatar(
// //                     backgroundColor: Colors.black45,
// //                     radius: 22,
// //                     child: IconButton(
// //                       icon: Icon(
// //                         _flashMode == FlashMode.torch
// //                             ? Icons.flash_on
// //                             : Icons.flash_off,
// //                         color: _flashMode == FlashMode.torch
// //                             ? Colors.yellowAccent
// //                             : Colors.white,
// //                         size: 22,
// //                       ),
// //                       onPressed: _toggleFlash,
// //                       tooltip: 'Toggle Flashlight',
// //                     ),
// //                   ),
// //                 ),
// //
// //               // ==================
// //               // BOTTOM BUTTONS
// //               // ==================
// //               Positioned(
// //                 bottom: 30,
// //                 left: 20,
// //                 right: 20,
// //                 child: _buildBottomControls(),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   // =========================
// //   // ✅ SMOOTH PROCESSING OVERLAY
// //   // =========================
// //   Widget _buildProcessingOverlay(BoxConstraints constraints) {
// //     return AnimatedBuilder(
// //       animation: _processingPulseAnim,
// //       builder: (context, child) {
// //         return Container(
// //           color: Colors.black,
// //           child: Center(
// //             child: Column(
// //               mainAxisSize: MainAxisSize.min,
// //               children: [
// //                 // Captured image preview
// //                 if (currentCapturedImage != null)
// //                   Container(
// //                     decoration: BoxDecoration(
// //                       borderRadius: BorderRadius.circular(16),
// //                       border: Border.all(
// //                         color: Colors.cyanAccent.withOpacity(
// //                             0.4 * _processingPulseAnim.value),
// //                         width: 2,
// //                       ),
// //                       boxShadow: [
// //                         BoxShadow(
// //                           color: Colors.cyanAccent.withOpacity(
// //                               0.15 * _processingPulseAnim.value),
// //                           blurRadius: 20,
// //                           spreadRadius: 2,
// //                         ),
// //                       ],
// //                     ),
// //                     child: ClipRRect(
// //                       borderRadius: BorderRadius.circular(14),
// //                       child: Image.file(
// //                         currentCapturedImage!,
// //                         width: constraints.maxWidth * 0.55,
// //                         height: constraints.maxWidth * 0.55,
// //                         fit: BoxFit.cover,
// //                       ),
// //                     ),
// //                   ),
// //                 const SizedBox(height: 28),
// //
// //                 // ✅ Animated scanning indicator (not a static loader)
// //                 _buildScanningIndicator(),
// //
// //                 const SizedBox(height: 20),
// //                 Text(
// //                   isDetecting ? "Scanning for objects..." : "Processing image...",
// //                   style: TextStyle(
// //                     color: Colors.white.withOpacity(
// //                         0.7 + 0.3 * _processingPulseAnim.value),
// //                     fontSize: 16,
// //                     fontWeight: FontWeight.w500,
// //                     letterSpacing: 0.5,
// //                   ),
// //                 ),
// //
// //                 const SizedBox(height: 8),
// //                 Text(
// //                   "Please hold still",
// //                   style: TextStyle(
// //                     color: Colors.white.withOpacity(0.35),
// //                     fontSize: 12,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         );
// //       },
// //     );
// //   }
// //
// //   // =========================
// //   // ✅ ANIMATED SCANNING INDICATOR (Replaces boring loader)
// //   // =========================
// //   Widget _buildScanningIndicator() {
// //     return SizedBox(
// //       width: 60,
// //       height: 60,
// //       child: Stack(
// //         alignment: Alignment.center,
// //         children: [
// //           // Outer rotating ring
// //           AnimatedBuilder(
// //             animation: _processingPulseAnim,
// //             builder: (context, child) {
// //               return Transform.scale(
// //                 scale: 0.8 + 0.2 * _processingPulseAnim.value,
// //                 child: Container(
// //                   width: 60,
// //                   height: 60,
// //                   decoration: BoxDecoration(
// //                     shape: BoxShape.circle,
// //                     border: Border.all(
// //                       color: Colors.cyanAccent.withOpacity(
// //                           0.3 + 0.4 * _processingPulseAnim.value),
// //                       width: 2.5,
// //                     ),
// //                   ),
// //                   child: const CircularProgressIndicator(
// //                     strokeWidth: 2,
// //                     valueColor:
// //                     AlwaysStoppedAnimation<Color>(Colors.cyanAccent),
// //                   ),
// //                 ),
// //               );
// //             },
// //           ),
// //           // Center dot
// //           AnimatedBuilder(
// //             animation: _processingPulseAnim,
// //             builder: (context, child) {
// //               return Container(
// //                 width: 12,
// //                 height: 12,
// //                 decoration: BoxDecoration(
// //                   shape: BoxShape.circle,
// //                   color: Colors.cyanAccent.withOpacity(
// //                       0.6 + 0.4 * _processingPulseAnim.value),
// //                 ),
// //               );
// //             },
// //           ),
// //           // Scanning line effect
// //           Positioned(
// //             top: 0,
// //             left: 0,
// //             right: 0,
// //             bottom: 0,
// //             child: AnimatedBuilder(
// //               animation: _processingPulseAnim,
// //               builder: (context, child) {
// //                 return CustomPaint(
// //                   painter: _ScanLinePainter(
// //                     progress: _processingPulseAnim.value,
// //                   ),
// //                 );
// //               },
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   // =========================
// //   // BOTTOM CONTROLS
// //   // =========================
// //   Widget _buildBottomControls() {
// //     if (isProcessingCapture) {
// //       // Show cancel button during processing
// //       return Center(
// //         child: GestureDetector(
// //           onTap: () {
// //             setState(() {
// //               isProcessingCapture = false;
// //               isDetecting = false;
// //               currentCapturedImage = null;
// //               currentDetections.clear();
// //               _processingAnimController.stop();
// //               _processingAnimController.reset();
// //             });
// //           },
// //           child: Container(
// //             padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
// //             decoration: BoxDecoration(
// //               color: Colors.white.withOpacity(0.1),
// //               borderRadius: BorderRadius.circular(25),
// //               border: Border.all(color: Colors.white.withOpacity(0.3)),
// //             ),
// //             child: const Text(
// //               "Cancel",
// //               style: TextStyle(color: Colors.white70, fontSize: 14),
// //             ),
// //           ),
// //         ),
// //       );
// //     }
// //
// //     if (captureResults.length < maxCaptures) {
// //       return Column(
// //         children: [
// //           Text(
// //             "Tap to capture (${captureResults.length + 1} of $maxCaptures)",
// //             style: const TextStyle(
// //               color: Colors.white70,
// //               fontSize: 13,
// //             ),
// //           ),
// //           const SizedBox(height: 10),
// //           Row(
// //             mainAxisAlignment: MainAxisAlignment.center,
// //             children: [
// //               // Retake last button
// //               if (captureResults.isNotEmpty)
// //                 GestureDetector(
// //                   onTap: retakeLastCapture,
// //                   child: Container(
// //                     height: 50,
// //                     width: 50,
// //                     decoration: BoxDecoration(
// //                       shape: BoxShape.circle,
// //                       color: Colors.redAccent.withOpacity(0.8),
// //                       border:
// //                       Border.all(color: Colors.white54, width: 2),
// //                     ),
// //                     child: const Center(
// //                       child: Icon(Icons.undo,
// //                           size: 24, color: Colors.white),
// //                     ),
// //                   ),
// //                 ),
// //
// //               if (captureResults.isNotEmpty)
// //                 const SizedBox(width: 30),
// //
// //               // Capture button with pulse effect
// //               GestureDetector(
// //                 onTap: captureAndDetect,
// //                 child: Container(
// //                   height: 70,
// //                   width: 70,
// //                   decoration: BoxDecoration(
// //                     shape: BoxShape.circle,
// //                     color: Colors.white,
// //                     border: Border.all(
// //                         color: Colors.cyanAccent, width: 4),
// //                     boxShadow: [
// //                       BoxShadow(
// //                         color: Colors.cyanAccent.withOpacity(0.3),
// //                         blurRadius: 12,
// //                         spreadRadius: 2,
// //                       ),
// //                     ],
// //                   ),
// //                   child: const Center(
// //                     child: Icon(Icons.camera_alt,
// //                         size: 32, color: Colors.black87),
// //                   ),
// //                 ),
// //               ),
// //
// //               // Submit early button
// //               if (captureResults.isNotEmpty)
// //                 const SizedBox(width: 30),
// //
// //               if (captureResults.isNotEmpty)
// //                 GestureDetector(
// //                   onTap: submitAll,
// //                   child: Container(
// //                     height: 50,
// //                     width: 50,
// //                     decoration: BoxDecoration(
// //                       shape: BoxShape.circle,
// //                       color: Colors.green.withOpacity(0.8),
// //                       border:
// //                       Border.all(color: Colors.white54, width: 2),
// //                     ),
// //                     child: const Center(
// //                       child: Icon(Icons.check,
// //                           size: 24, color: Colors.white),
// //                     ),
// //                   ),
// //                 ),
// //             ],
// //           ),
// //         ],
// //       );
// //     }
// //
// //     // All captures done
// //     return Column(
// //       children: [
// //         const Text(
// //           "All captures complete!",
// //           style: TextStyle(
// //             color: Colors.cyanAccent,
// //             fontSize: 16,
// //             fontWeight: FontWeight.bold,
// //           ),
// //         ),
// //         const SizedBox(height: 12),
// //         Row(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             ElevatedButton.icon(
// //               style: ElevatedButton.styleFrom(
// //                 backgroundColor: Colors.redAccent,
// //                 foregroundColor: Colors.white,
// //                 padding: const EdgeInsets.symmetric(
// //                     horizontal: 20, vertical: 12),
// //                 shape: RoundedRectangleBorder(
// //                     borderRadius: BorderRadius.circular(25)),
// //               ),
// //               onPressed: retakeLastCapture,
// //               icon: const Icon(Icons.undo),
// //               label: const Text("Undo Last"),
// //             ),
// //             const SizedBox(width: 20),
// //             ElevatedButton.icon(
// //               style: ElevatedButton.styleFrom(
// //                 backgroundColor: Colors.green,
// //                 foregroundColor: Colors.white,
// //                 padding: const EdgeInsets.symmetric(
// //                     horizontal: 30, vertical: 14),
// //                 shape: RoundedRectangleBorder(
// //                     borderRadius: BorderRadius.circular(25)),
// //               ),
// //               onPressed: submitAll,
// //               icon: const Icon(Icons.send),
// //               label: const Text("Submit All"),
// //             ),
// //           ],
// //         ),
// //       ],
// //     );
// //   }
// //
// //   // =========================
// //   // CAPTURE CARD WIDGET
// //   // =========================
// //   Widget _buildCaptureCard(CaptureResult capture, int index) {
// //     final bool hasDetections = capture.croppedDetections.isNotEmpty;
// //
// //     return GestureDetector(
// //       onTap: () => _showCaptureDetail(capture),
// //       child: AnimatedContainer(
// //         duration: const Duration(milliseconds: 300),
// //         curve: Curves.easeOutCubic,
// //         width: 130,
// //         margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
// //         decoration: BoxDecoration(
// //           color: Colors.grey[900],
// //           borderRadius: BorderRadius.circular(10),
// //           border: Border.all(
// //             color: hasDetections
// //                 ? Colors.cyanAccent.withOpacity(0.5)
// //                 : Colors.orangeAccent.withOpacity(0.3),
// //             width: 1,
// //           ),
// //         ),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             // Capture number header
// //             Container(
// //               width: double.infinity,
// //               padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
// //               decoration: BoxDecoration(
// //                 color: hasDetections
// //                     ? Colors.cyanAccent.withOpacity(0.2)
// //                     : Colors.orangeAccent.withOpacity(0.15),
// //                 borderRadius: const BorderRadius.only(
// //                   topLeft: Radius.circular(9),
// //                   topRight: Radius.circular(9),
// //                 ),
// //               ),
// //               child: Row(
// //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                 children: [
// //                   Text(
// //                     "Capture #${capture.captureIndex}",
// //                     style: TextStyle(
// //                       color:
// //                       hasDetections ? Colors.cyanAccent : Colors.orangeAccent,
// //                       fontSize: 9,
// //                       fontWeight: FontWeight.bold,
// //                     ),
// //                   ),
// //                   if (!hasDetections)
// //                     const Icon(Icons.warning_amber_rounded,
// //                         size: 12, color: Colors.orangeAccent),
// //                 ],
// //               ),
// //             ),
// //
// //             // Parent image
// //             Padding(
// //               padding: const EdgeInsets.all(4),
// //               child: Row(
// //                 children: [
// //                   // Parent thumbnail
// //                   Column(
// //                     children: [
// //                       ClipRRect(
// //                         borderRadius: BorderRadius.circular(6),
// //                         child: Image.file(
// //                           capture.parentImage,
// //                           width: 45,
// //                           height: 45,
// //                           fit: BoxFit.cover,
// //                         ),
// //                       ),
// //                       const SizedBox(height: 2),
// //                       Container(
// //                         padding: const EdgeInsets.symmetric(
// //                             horizontal: 4, vertical: 1),
// //                         decoration: BoxDecoration(
// //                           color: Colors.blue.withOpacity(0.3),
// //                           borderRadius: BorderRadius.circular(4),
// //                         ),
// //                         child: const Text(
// //                           "Parent",
// //                           style: TextStyle(
// //                             color: Colors.lightBlueAccent,
// //                             fontSize: 7,
// //                             fontWeight: FontWeight.bold,
// //                           ),
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //
// //                   const SizedBox(width: 4),
// //
// //                   // Children or "No objects" message
// //                   Expanded(
// //                     child: hasDetections
// //                         ? SizedBox(
// //                       height: 60,
// //                       child: ListView.builder(
// //                         scrollDirection: Axis.horizontal,
// //                         itemCount: capture.croppedDetections.length,
// //                         itemBuilder: (context, ci) {
// //                           final cropped =
// //                           capture.croppedDetections[ci];
// //                           return Padding(
// //                             padding: const EdgeInsets.only(right: 3),
// //                             child: Column(
// //                               children: [
// //                                 ClipRRect(
// //                                   borderRadius:
// //                                   BorderRadius.circular(4),
// //                                   child: Image.file(
// //                                     cropped.croppedImage,
// //                                     width: 35,
// //                                     height: 35,
// //                                     fit: BoxFit.cover,
// //                                   ),
// //                                 ),
// //                                 const SizedBox(height: 2),
// //                                 Container(
// //                                   padding: const EdgeInsets.symmetric(
// //                                       horizontal: 3, vertical: 1),
// //                                   decoration: BoxDecoration(
// //                                     color:
// //                                     Colors.orange.withOpacity(0.3),
// //                                     borderRadius:
// //                                     BorderRadius.circular(4),
// //                                   ),
// //                                   child: const Text(
// //                                     "Child",
// //                                     style: TextStyle(
// //                                       color: Colors.orangeAccent,
// //                                       fontSize: 7,
// //                                       fontWeight: FontWeight.bold,
// //                                     ),
// //                                   ),
// //                                 ),
// //                                 Text(
// //                                   "${(cropped.confidence * 100).toStringAsFixed(0)}%",
// //                                   style: const TextStyle(
// //                                     color: Colors.white54,
// //                                     fontSize: 7,
// //                                   ),
// //                                 ),
// //                               ],
// //                             ),
// //                           );
// //                         },
// //                       ),
// //                     )
// //                         : const Padding(
// //                       padding: EdgeInsets.only(top: 12, left: 4),
// //                       child: Text(
// //                         "No objects\ndetected",
// //                         style: TextStyle(
// //                           color: Colors.white38,
// //                           fontSize: 8,
// //                           fontStyle: FontStyle.italic,
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //
// //             // Detection count
// //             Padding(
// //               padding: const EdgeInsets.symmetric(horizontal: 6),
// //               child: Text(
// //                 hasDetections
// //                     ? "${capture.croppedDetections.length} object(s) detected"
// //                     : "Only parent saved",
// //                 style: TextStyle(
// //                   color: hasDetections ? Colors.white38 : Colors.orangeAccent.withOpacity(0.6),
// //                   fontSize: 8,
// //                 ),
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   // =========================
// //   // SHOW CAPTURE DETAIL DIALOG
// //   // =========================
// //   void _showCaptureDetail(CaptureResult capture) {
// //     final bool hasDetections = capture.croppedDetections.isNotEmpty;
// //
// //     showDialog(
// //       context: context,
// //       builder: (context) {
// //         return Dialog(
// //           backgroundColor: Colors.grey[900],
// //           shape:
// //           RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
// //           child: Container(
// //             constraints: const BoxConstraints(maxHeight: 500),
// //             padding: const EdgeInsets.all(16),
// //             child: Column(
// //               mainAxisSize: MainAxisSize.min,
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 // Header
// //                 Row(
// //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                   children: [
// //                     Text(
// //                       "Capture #${capture.captureIndex}",
// //                       style: TextStyle(
// //                         color: hasDetections
// //                             ? Colors.cyanAccent
// //                             : Colors.orangeAccent,
// //                         fontSize: 18,
// //                         fontWeight: FontWeight.bold,
// //                       ),
// //                     ),
// //                     if (!hasDetections)
// //                       const Icon(Icons.warning_amber_rounded,
// //                           color: Colors.orangeAccent, size: 20),
// //                     IconButton(
// //                       icon: const Icon(Icons.close, color: Colors.white54),
// //                       onPressed: () => Navigator.pop(context),
// //                     ),
// //                   ],
// //                 ),
// //
// //                 const SizedBox(height: 10),
// //
// //                 // Parent image
// //                 Row(
// //                   children: [
// //                     const Text(
// //                       "📷 Parent Image",
// //                       style: TextStyle(
// //                         color: Colors.lightBlueAccent,
// //                         fontWeight: FontWeight.bold,
// //                         fontSize: 13,
// //                       ),
// //                     ),
// //                     const Spacer(),
// //                     if (!hasDetections)
// //                       Container(
// //                         padding: const EdgeInsets.symmetric(
// //                             horizontal: 8, vertical: 2),
// //                         decoration: BoxDecoration(
// //                           color: Colors.orange.withOpacity(0.2),
// //                           borderRadius: BorderRadius.circular(8),
// //                         ),
// //                         child: const Text(
// //                           "No objects detected",
// //                           style: TextStyle(
// //                             color: Colors.orangeAccent,
// //                             fontSize: 9,
// //                           ),
// //                         ),
// //                       ),
// //                   ],
// //                 ),
// //                 const SizedBox(height: 6),
// //                 ClipRRect(
// //                   borderRadius: BorderRadius.circular(10),
// //                   child: Image.file(
// //                     capture.parentImage,
// //                     width: double.infinity,
// //                     height: 150,
// //                     fit: BoxFit.cover,
// //                   ),
// //                 ),
// //
// //                 if (hasDetections) ...[
// //                   const SizedBox(height: 12),
// //
// //                   // Cropped children
// //                   Text(
// //                     "🔍 Detected Objects (${capture.croppedDetections.length})",
// //                     style: const TextStyle(
// //                       color: Colors.orangeAccent,
// //                       fontWeight: FontWeight.bold,
// //                       fontSize: 13,
// //                     ),
// //                   ),
// //                   const SizedBox(height: 6),
// //
// //                   SizedBox(
// //                     height: 100,
// //                     child: ListView.builder(
// //                       scrollDirection: Axis.horizontal,
// //                       itemCount: capture.croppedDetections.length,
// //                       itemBuilder: (context, i) {
// //                         final cropped = capture.croppedDetections[i];
// //                         return Container(
// //                           width: 90,
// //                           margin: const EdgeInsets.only(right: 8),
// //                           decoration: BoxDecoration(
// //                             borderRadius: BorderRadius.circular(8),
// //                             border: Border.all(
// //                                 color:
// //                                 Colors.orangeAccent.withOpacity(0.5)),
// //                           ),
// //                           child: Column(
// //                             children: [
// //                               ClipRRect(
// //                                 borderRadius: const BorderRadius.only(
// //                                   topLeft: Radius.circular(7),
// //                                   topRight: Radius.circular(7),
// //                                 ),
// //                                 child: Image.file(
// //                                   cropped.croppedImage,
// //                                   width: 90,
// //                                   height: 65,
// //                                   fit: BoxFit.cover,
// //                                 ),
// //                               ),
// //                               const SizedBox(height: 4),
// //                               Text(
// //                                 "Child - ${(cropped.confidence * 100).toStringAsFixed(0)}%",
// //                                 style: const TextStyle(
// //                                   color: Colors.white70,
// //                                   fontSize: 9,
// //                                 ),
// //                               ),
// //                             ],
// //                           ),
// //                         );
// //                       },
// //                     ),
// //                   ),
// //                 ] else ...[
// //                   const SizedBox(height: 12),
// //                   Container(
// //                     padding: const EdgeInsets.all(12),
// //                     decoration: BoxDecoration(
// //                       color: Colors.orange.withOpacity(0.1),
// //                       borderRadius: BorderRadius.circular(8),
// //                     ),
// //                     child: const Row(
// //                       children: [
// //                         Icon(Icons.info_outline,
// //                             size: 16, color: Colors.orangeAccent),
// //                         SizedBox(width: 8),
// //                         Expanded(
// //                           child: Text(
// //                             "This image was saved as parent only. You can retake it if needed.",
// //                             style: TextStyle(
// //                               color: Colors.white54,
// //                               fontSize: 11,
// //                             ),
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                 ],
// //               ],
// //             ),
// //           ),
// //         );
// //       },
// //     );
// //   }
// //
// //   // =========================
// //   // CORNER GUIDE
// //   // =========================
// //   Widget _buildCorner({
// //     double? top,
// //     double? left,
// //     double? right,
// //     double? bottom,
// //     required double angle,
// //   }) {
// //     return Positioned(
// //       top: top,
// //       left: left,
// //       right: right,
// //       bottom: bottom,
// //       child: Transform.rotate(
// //         angle: angle * pi / 180,
// //         child: Container(
// //           width: 30,
// //           height: 30,
// //           decoration: const BoxDecoration(
// //             border: Border(
// //               top: BorderSide(color: Colors.cyanAccent, width: 3),
// //               left: BorderSide(color: Colors.cyanAccent, width: 3),
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// // // =========================
// // // ✅ CUSTOM SCAN LINE PAINTER (Smooth animation)
// // // =========================
// // class _ScanLinePainter extends CustomPainter {
// //   final double progress;
// //
// //   _ScanLinePainter({required this.progress});
// //
// //   @override
// //   void paint(Canvas canvas, Size size) {
// //     final paint = Paint()
// //       ..color = Colors.cyanAccent.withOpacity(0.3)
// //       ..strokeWidth = 1.5
// //       ..style = PaintingStyle.stroke;
// //
// //     final double centerX = size.width / 2;
// //     final double centerY = size.height / 2;
// //     final double radius = size.width / 2 - 4;
// //
// //     // Draw scanning arc
// //     final rect = Rect.fromCircle(center: Offset(centerX, centerY), radius: radius);
// //
// //     canvas.drawArc(
// //       rect,
// //       -pi / 2 + progress * 2 * pi,
// //       pi / 3,
// //       false,
// //       paint,
// //     );
// //   }
// //
// //   @override
// //   bool shouldRepaint(covariant _ScanLinePainter oldDelegate) => true;
// // }
// //
// // // =========================
// // // PAINTER (kept for any future use)
// // // =========================
// // class BoxPainter extends CustomPainter {
// //   final List<Detection> detections;
// //
// //   BoxPainter(this.detections);
// //
// //   @override
// //   void paint(Canvas canvas, Size size) {
// //     final boxPaint = Paint()
// //       ..color = Colors.red
// //       ..strokeWidth = 3
// //       ..style = PaintingStyle.stroke;
// //
// //     final bgPaint = Paint()
// //       ..color = Colors.red
// //       ..style = PaintingStyle.fill;
// //
// //     for (var d in detections) {
// //       final double left = d.rect.left * size.width;
// //       final double top = d.rect.top * size.height;
// //       final double width = d.rect.width * size.width;
// //       final double height = d.rect.height * size.height;
// //
// //       final r = Rect.fromLTWH(left, top, width, height);
// //
// //       canvas.drawRect(r, boxPaint);
// //
// //       final String text = "Rubber ${(d.conf * 100).toStringAsFixed(0)}%";
// //
// //       final textPainter = TextPainter(
// //         text: TextSpan(
// //           text: text,
// //           style: const TextStyle(
// //             color: Colors.white,
// //             fontSize: 10,
// //             fontWeight: FontWeight.bold,
// //           ),
// //         ),
// //         textDirection: TextDirection.ltr,
// //       );
// //
// //       textPainter.layout();
// //
// //       final labelBgRect = Rect.fromLTWH(
// //         left,
// //         top - textPainter.height - 4,
// //         textPainter.width + 8,
// //         textPainter.height + 4,
// //       );
// //
// //       canvas.drawRect(labelBgRect, bgPaint);
// //
// //       textPainter.paint(
// //         canvas,
// //         Offset(left + 4, top - textPainter.height - 2),
// //       );
// //     }
// //   }
// //
// //   @override
// //   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// // }
//
//
// import 'dart:io';
// import 'dart:math';
// import 'dart:typed_data';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:camera/camera.dart';
// import 'package:tflite_flutter/tflite_flutter.dart';
// import 'package:image/image.dart' as img;
//
// class RubberCameraDetectorPage extends StatefulWidget {
//   const RubberCameraDetectorPage({super.key});
//
//   @override
//   State<RubberCameraDetectorPage> createState() =>
//       _RubberCameraDetectorPageState();
// }
//
// class CaptureResult {
//   final File parentImage;
//   final List<CroppedDetection> croppedDetections;
//   final int captureIndex;
//
//   CaptureResult({
//     required this.parentImage,
//     required this.croppedDetections,
//     required this.captureIndex,
//   });
// }
//
// class CroppedDetection {
//   final File croppedImage;
//   final double confidence;
//   final Rect originalRect;
//
//   CroppedDetection({
//     required this.croppedImage,
//     required this.confidence,
//     required this.originalRect,
//   });
// }
//
// class Detection {
//   final Rect rect;
//   final double conf;
//
//   Detection(this.rect, this.conf);
// }
//
// // =========================
// // ISOLATE INPUT
// // =========================
// class _YoloIsolateInput {
//   final String imagePath;
//   final String modelPath;
//   final double confThreshold;
//   final double nmsThreshold;
//   final double boxScale;
//
//   const _YoloIsolateInput({
//     required this.imagePath,
//     required this.modelPath,
//     required this.confThreshold,
//     required this.nmsThreshold,
//     required this.boxScale,
//   });
// }
//
// // =========================
// // ISOLATE DETECTION
// // This keeps the UI loader smooth instead of freezing.
// // =========================
// Future<List<Map<String, dynamic>>> _runYoloInIsolate(
//     _YoloIsolateInput data) async {
//   final interpreter = Interpreter.fromFile(File(data.modelPath));
//
//   try {
//     final bytes = await File(data.imagePath).readAsBytes();
//     final image = img.decodeImage(bytes);
//     if (image == null) return [];
//
//     final inputImage = img.copyResize(image, width: 640, height: 640);
//
//     final input = [
//       List.generate(640, (y) {
//         return List.generate(640, (x) {
//           final p = inputImage.getPixel(x, y);
//           return [p.r / 255.0, p.g / 255.0, p.b / 255.0];
//         });
//       }),
//     ];
//
//     final output = List.generate(
//       1,
//           (_) => List.generate(5, (_) => List.filled(8400, 0.0)),
//     );
//
//     interpreter.run(input, output);
//
//     List<Map<String, dynamic>> raw = [];
//
//     for (int i = 0; i < 8400; i++) {
//       final double conf = output[0][4][i];
//       if (conf > data.confThreshold) {
//         raw.add({
//           'cx': output[0][0][i],
//           'cy': output[0][1][i],
//           'w': output[0][2][i] * data.boxScale,
//           'h': output[0][3][i] * data.boxScale,
//           'conf': conf,
//         });
//       }
//     }
//
//     return _nmsIsolate(raw, data.nmsThreshold);
//   } catch (e) {
//     return [];
//   } finally {
//     interpreter.close();
//   }
// }
//
// double _iouIsolate(Map<String, dynamic> a, Map<String, dynamic> b) {
//   final double ax = (a['cx'] as double) - (a['w'] as double) / 2;
//   final double ay = (a['cy'] as double) - (a['h'] as double) / 2;
//   final double aw = a['w'] as double;
//   final double ah = a['h'] as double;
//
//   final double bx = (b['cx'] as double) - (b['w'] as double) / 2;
//   final double by = (b['cy'] as double) - (b['h'] as double) / 2;
//   final double bw = b['w'] as double;
//   final double bh = b['h'] as double;
//
//   final double x1 = max(ax, bx);
//   final double y1 = max(ay, by);
//   final double x2 = min(ax + aw, bx + bw);
//   final double y2 = min(ay + ah, by + bh);
//
//   final double interW = max(0, x2 - x1);
//   final double interH = max(0, y2 - y1);
//   final double interArea = interW * interH;
//
//   final double union = aw * ah + bw * bh - interArea;
//   if (union <= 0) return 0;
//   return interArea / union;
// }
//
// List<Map<String, dynamic>> _nmsIsolate(
//     List<Map<String, dynamic>> boxes, double threshold) {
//   boxes.sort((a, b) => (b['conf'] as double).compareTo(a['conf'] as double));
//
//   final List<Map<String, dynamic>> result = [];
//
//   for (final box in boxes) {
//     bool keep = true;
//     for (final selected in result) {
//       if (_iouIsolate(box, selected) > threshold) {
//         keep = false;
//         break;
//       }
//     }
//     if (keep) result.add(box);
//   }
//
//   return result;
// }
//
// class _RubberCameraDetectorPageState extends State<RubberCameraDetectorPage>
//     with TickerProviderStateMixin {
//   CameraController? controller;
//   Interpreter? interpreter;
//
//   File? currentCapturedImage;
//   List<Detection> currentDetections = [];
//
//   List<CaptureResult> captureResults = [];
//
//   FlashMode _flashMode = FlashMode.torch;
//
//   bool isLoading = true;
//   bool isDetecting = false;
//   bool isProcessingCapture = false;
//   bool _awaitingNoObjectDecision = false;
//
//   String? _isolateModelPath;
//
//   late final AnimationController _loaderAnim;
//   late final Animation<double> _loaderPulse;
//
//   static const int maxCaptures = 5;
//
//   @override
//   void initState() {
//     super.initState();
//     _loaderAnim = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1100),
//     )..repeat(reverse: true);
//
//     _loaderPulse = Tween<double>(begin: 0.72, end: 1.0).animate(
//       CurvedAnimation(parent: _loaderAnim, curve: Curves.easeInOut),
//     );
//
//     init();
//   }
//
//   @override
//   void dispose() {
//     _loaderAnim.dispose();
//     controller?.dispose();
//     interpreter?.close();
//     super.dispose();
//   }
//
//   Future<void> init() async {
//     final cams = await availableCameras();
//
//     controller = CameraController(
//       cams[0],
//       ResolutionPreset.medium,
//       enableAudio: false,
//     );
//
//     await controller!.initialize();
//
//     try {
//       await controller!.setFlashMode(FlashMode.torch);
//       _flashMode = FlashMode.torch;
//     } catch (e) {
//       debugPrint('Error enabling default flashlight: $e');
//       _flashMode = FlashMode.off;
//     }
//
//     interpreter = await Interpreter.fromAsset(
//       'assets/model/best_float32.tflite',
//     );
//
//     try {
//       final modelBytes =
//       await rootBundle.load('assets/model/best_float32.tflite');
//       final tempFile =
//       File('${Directory.systemTemp.path}/gg_yolo_best_float32.tflite');
//       final bytes = modelBytes.buffer.asUint8List(
//         modelBytes.offsetInBytes,
//         modelBytes.lengthInBytes,
//       );
//
//       if (!tempFile.existsSync() ||
//           tempFile.lengthSync() != bytes.lengthInBytes) {
//         await tempFile.writeAsBytes(bytes);
//       }
//
//       _isolateModelPath = tempFile.path;
//     } catch (e) {
//       debugPrint('Isolate model temp file error: $e');
//     }
//
//     if (mounted) {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }
//
//   Future<void> _toggleFlash() async {
//     if (controller == null || !controller!.value.isInitialized) return;
//
//     final newMode =
//     _flashMode == FlashMode.off ? FlashMode.torch : FlashMode.off;
//
//     try {
//       await controller!.setFlashMode(newMode);
//       setState(() {
//         _flashMode = newMode;
//       });
//     } catch (e) {
//       debugPrint('Error toggling camera flashlight: $e');
//     }
//   }
//
//   // =========================
//   // CAPTURE AND AUTO DETECT
//   // =========================
//   Future<void> captureAndDetect() async {
//     if (controller == null || !controller!.value.isInitialized) return;
//     if (isProcessingCapture) return;
//
//     setState(() {
//       isProcessingCapture = true;
//       isDetecting = false;
//       _awaitingNoObjectDecision = false;
//       currentCapturedImage = null;
//       currentDetections.clear();
//     });
//
//     try {
//       final photo = await controller!.takePicture();
//       currentCapturedImage = File(photo.path);
//
//       setState(() {});
//       await _runDetection();
//     } catch (e) {
//       debugPrint('Capture error: $e');
//       setState(() {
//         isProcessingCapture = false;
//         isDetecting = false;
//       });
//     }
//   }
//
//   // =========================
//   // RUN DETECTION AUTOMATICALLY
//   // =========================
//   Future<void> _runDetection() async {
//     if (currentCapturedImage == null || interpreter == null) {
//       setState(() {
//         isProcessingCapture = false;
//         isDetecting = false;
//       });
//       return;
//     }
//
//     setState(() {
//       isDetecting = true;
//       _awaitingNoObjectDecision = false;
//     });
//
//     await Future.delayed(const Duration(milliseconds: 60));
//
//     try {
//       List<Detection> finalDetections;
//
//       if (_isolateModelPath != null) {
//         final raw = await compute(
//           _runYoloInIsolate,
//           _YoloIsolateInput(
//             imagePath: currentCapturedImage!.path,
//             modelPath: _isolateModelPath!,
//             confThreshold: 0.5,
//             nmsThreshold: 0.5,
//             boxScale: 1.40,
//           ),
//         );
//
//         finalDetections = raw
//             .map(
//               (m) => Detection(
//             Rect.fromCenter(
//               center: Offset(m['cx'] as double, m['cy'] as double),
//               width: m['w'] as double,
//               height: m['h'] as double,
//             ),
//             m['conf'] as double,
//           ),
//         )
//             .toList();
//       } else {
//         finalDetections = await _runDetectionDirectly();
//       }
//
//       currentDetections = finalDetections;
//
//       if (!mounted) return;
//
//       if (currentDetections.isEmpty) {
//         setState(() {
//           isDetecting = false;
//           isProcessingCapture = false;
//           _awaitingNoObjectDecision = true;
//         });
//         return;
//       }
//
//       await _processAndSaveCapture();
//     } catch (e) {
//       debugPrint('Object detection error: $e');
//       if (mounted) {
//         setState(() {
//           isDetecting = false;
//           isProcessingCapture = false;
//           currentDetections = [];
//           _awaitingNoObjectDecision = true;
//         });
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           isDetecting = false;
//         });
//       }
//     }
//   }
//
//   // Fallback only if isolate model temp could not be created.
//   Future<List<Detection>> _runDetectionDirectly() async {
//     final bytes = await currentCapturedImage!.readAsBytes();
//     final image = img.decodeImage(bytes);
//     if (image == null) return [];
//
//     final inputImage = img.copyResize(image, width: 640, height: 640);
//
//     final input = [
//       List.generate(640, (y) {
//         return List.generate(640, (x) {
//           final p = inputImage.getPixel(x, y);
//           return [p.r / 255, p.g / 255, p.b / 255];
//         });
//       }),
//     ];
//
//     final output = List.generate(
//       1,
//           (_) => List.generate(5, (_) => List.filled(8400, 0.0)),
//     );
//
//     interpreter!.run(input, output);
//
//     List<Detection> raw = [];
//
//     for (int i = 0; i < 8400; i++) {
//       double conf = output[0][4][i];
//       if (conf > 0.5) {
//         raw.add(
//           Detection(
//             Rect.fromCenter(
//               center: Offset(output[0][0][i], output[0][1][i]),
//               width: output[0][2][i] * 1.40,
//               height: output[0][3][i] * 1.40,
//             ),
//             conf,
//           ),
//         );
//       }
//     }
//
//     return nms(raw, 0.5);
//   }
//
//   // =========================
//   // PROCESS AND SAVE CAPTURE
//   // =========================
//   Future<void> _processAndSaveCapture() async {
//     if (currentCapturedImage == null || currentDetections.isEmpty) return;
//
//     final bytes = await currentCapturedImage!.readAsBytes();
//     img.Image? full = img.decodeImage(bytes);
//
//     if (full == null) {
//       setState(() {
//         isProcessingCapture = false;
//         currentDetections = [];
//         _awaitingNoObjectDecision = true;
//       });
//       return;
//     }
//
//     List<CroppedDetection> croppedList = [];
//
//     for (var d in currentDetections) {
//       final r = d.rect;
//
//       int x = (r.left * full.width).toInt();
//       int y = (r.top * full.height).toInt();
//       int w = (r.width * full.width).toInt();
//       int h = (r.height * full.height).toInt();
//
//       x = max(0, x);
//       y = max(0, y);
//       w = min(w, full.width - x);
//       h = min(h, full.height - y);
//
//       if (w <= 0 || h <= 0) continue;
//
//       final crop = img.copyCrop(full, x: x, y: y, width: w, height: h);
//
//       final path = currentCapturedImage!.path.replaceAll(
//         ".jpg",
//         "_crop_${DateTime.now().millisecondsSinceEpoch}.jpg",
//       );
//
//       final file = File(path);
//       await file.writeAsBytes(img.encodeJpg(crop));
//
//       croppedList.add(CroppedDetection(
//         croppedImage: file,
//         confidence: d.conf,
//         originalRect: d.rect,
//       ));
//     }
//
//     if (croppedList.isEmpty) {
//       setState(() {
//         isProcessingCapture = false;
//         currentDetections = [];
//         _awaitingNoObjectDecision = true;
//       });
//       return;
//     }
//
//     final captureResult = CaptureResult(
//       parentImage: currentCapturedImage!,
//       croppedDetections: croppedList,
//       captureIndex: captureResults.length + 1,
//     );
//
//     setState(() {
//       captureResults.add(captureResult);
//       currentCapturedImage = null;
//       currentDetections.clear();
//       isProcessingCapture = false;
//       _awaitingNoObjectDecision = false;
//     });
//   }
//
//   // =========================
//   // NO-OBJECT REVIEW
//   // Keep parent image until user decides.
//   // =========================
//   void _retakeCurrentParent() {
//     try {
//       currentCapturedImage?.deleteSync();
//     } catch (_) {}
//
//     setState(() {
//       currentCapturedImage = null;
//       currentDetections.clear();
//       _awaitingNoObjectDecision = false;
//       isProcessingCapture = false;
//       isDetecting = false;
//     });
//   }
//
//   void _keepParentOnly() {
//     if (currentCapturedImage == null) return;
//
//     final captureResult = CaptureResult(
//       parentImage: currentCapturedImage!,
//       croppedDetections: [],
//       captureIndex: captureResults.length + 1,
//     );
//
//     setState(() {
//       captureResults.add(captureResult);
//       currentCapturedImage = null;
//       currentDetections.clear();
//       _awaitingNoObjectDecision = false;
//       isProcessingCapture = false;
//       isDetecting = false;
//     });
//   }
//
//   // =========================
//   // RETAKE LAST SUCCESSFUL CAPTURE
//   // =========================
//   void retakeLastCapture() {
//     if (captureResults.isNotEmpty) {
//       setState(() {
//         captureResults.removeLast();
//       });
//     }
//   }
//
//   // =========================
//   // NMS
//   // =========================
//   List<Detection> nms(List<Detection> boxes, double iouThreshold) {
//     boxes.sort((a, b) => b.conf.compareTo(a.conf));
//
//     List<Detection> result = [];
//
//     for (var box in boxes) {
//       bool keep = true;
//
//       for (var selected in result) {
//         if (iou(box.rect, selected.rect) > iouThreshold) {
//           keep = false;
//           break;
//         }
//       }
//
//       if (keep) result.add(box);
//     }
//
//     return result;
//   }
//
//   double iou(Rect a, Rect b) {
//     final inter = a.intersect(b);
//     final interArea = inter.width * inter.height;
//
//     final union = a.width * a.height + b.width * b.height - interArea;
//
//     return union == 0 ? 0 : interArea / union;
//   }
//
//   // =========================
//   // SUBMIT ALL CAPTURES
//   // =========================
//   Future<void> submitAll() async {
//     if (captureResults.isEmpty) return;
//
//     List<Map<String, dynamic>> result = [];
//
//     for (var capture in captureResults) {
//       result.add({
//         "path": capture.parentImage.path,
//         "type": "parent",
//         "captureIndex": capture.captureIndex,
//         "conf": 1.0,
//       });
//
//       for (var cropped in capture.croppedDetections) {
//         result.add({
//           "path": cropped.croppedImage.path,
//           "type": "child",
//           "captureIndex": capture.captureIndex,
//           "conf": cropped.confidence,
//         });
//       }
//     }
//
//     if (mounted) Navigator.pop(context, result);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (isLoading || controller == null || !controller!.value.isInitialized) {
//       return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     }
//
//     final bool showCamera = !isProcessingCapture &&
//         !isDetecting &&
//         !_awaitingNoObjectDecision;
//
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: LayoutBuilder(
//         builder: (context, constraints) => SizedBox(
//           width: double.infinity,
//           height: double.infinity,
//           child: Stack(
//             children: [
//               // ==================
//               // CAMERA PREVIEW
//               // ==================
//               if (showCamera)
//                 SizedBox(
//                   height: double.infinity,
//                   width: double.infinity,
//                   child: CameraPreview(controller!),
//                 ),
//
//               // ==================
//               // CLEAN DETECTION LOADER
//               // ==================
//               if ((isProcessingCapture || isDetecting) &&
//                   !_awaitingNoObjectDecision)
//                 _buildCleanLoaderOverlay(),
//
//               // ==================
//               // NO-OBJECT REVIEW OVERLAY
//               // Keeps parent image visible with choices.
//               // ==================
//               if (_awaitingNoObjectDecision &&
//                   currentCapturedImage != null)
//                 _buildNoObjectReviewOverlay(),
//
//               // ==================
//               // TOP CAPTURED GALLERY
//               // ==================
//               if (captureResults.isNotEmpty &&
//                   !_awaitingNoObjectDecision)
//                 _buildTopGallery(),
//
//               // ==================
//               // GUIDE FRAME
//               // ==================
//               if (showCamera)
//                 Positioned(
//                   top: captureResults.isNotEmpty
//                       ? constraints.maxHeight * 0.34
//                       : constraints.maxHeight * 0.20,
//                   left: 40,
//                   right: 40,
//                   bottom: constraints.maxHeight * 0.30,
//                   child: Container(
//                     decoration: BoxDecoration(
//                       border: Border.all(color: Colors.white24, width: 1),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Stack(
//                       children: [
//                         _buildCorner(top: 0, left: 0, angle: 0),
//                         _buildCorner(top: 0, right: 0, angle: 90),
//                         _buildCorner(bottom: 0, left: 0, angle: 270),
//                         _buildCorner(bottom: 0, right: 0, angle: 180),
//                       ],
//                     ),
//                   ),
//                 ),
//
//               // ==================
//               // FLASH
//               // ==================
//               if (showCamera && captureResults.isEmpty)
//                 Positioned(
//                   top: 50,
//                   right: 20,
//                   child: SafeArea(
//                     child: CircleAvatar(
//                       backgroundColor: Colors.black45,
//                       radius: 25,
//                       child: IconButton(
//                         icon: Icon(
//                           _flashMode == FlashMode.torch
//                               ? Icons.flash_on
//                               : Icons.flash_off,
//                           color: _flashMode == FlashMode.torch
//                               ? Colors.yellowAccent
//                               : Colors.white,
//                           size: 26,
//                         ),
//                         onPressed: _toggleFlash,
//                         tooltip: 'Toggle Flashlight',
//                       ),
//                     ),
//                   ),
//                 ),
//
//               if (showCamera && captureResults.isNotEmpty)
//                 Positioned(
//                   top: 225,
//                   right: 20,
//                   child: CircleAvatar(
//                     backgroundColor: Colors.black45,
//                     radius: 22,
//                     child: IconButton(
//                       icon: Icon(
//                         _flashMode == FlashMode.torch
//                             ? Icons.flash_on
//                             : Icons.flash_off,
//                         color: _flashMode == FlashMode.torch
//                             ? Colors.yellowAccent
//                             : Colors.white,
//                         size: 22,
//                       ),
//                       onPressed: _toggleFlash,
//                       tooltip: 'Toggle Flashlight',
//                     ),
//                   ),
//                 ),
//
//               // ==================
//               // BOTTOM BUTTONS
//               // ==================
//               if (!_awaitingNoObjectDecision)
//                 Positioned(
//                   bottom: 30,
//                   left: 20,
//                   right: 20,
//                   child: Column(
//                     children: [
//                       if (!isProcessingCapture &&
//                           !isDetecting &&
//                           captureResults.length < maxCaptures)
//                         _buildCaptureControls(),
//
//                       if (!isProcessingCapture &&
//                           !isDetecting &&
//                           captureResults.length >= maxCaptures)
//                         _buildFinalControls(),
//                     ],
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   // =========================
//   // CLEAN LOADER OVERLAY
//   // =========================
//   Widget _buildCleanLoaderOverlay() {
//     return Positioned.fill(
//       child: Container(
//         color: Colors.black.withOpacity(0.92),
//         child: SafeArea(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               if (currentCapturedImage != null)
//                 Container(
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(14),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.cyanAccent.withOpacity(0.15),
//                         blurRadius: 24,
//                         spreadRadius: 4,
//                       ),
//                     ],
//                   ),
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(14),
//                     child: Image.file(
//                       currentCapturedImage!,
//                       width: 220,
//                       height: 220,
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 ),
//               const SizedBox(height: 32),
//               AnimatedBuilder(
//                 animation: _loaderPulse,
//                 builder: (_, child) {
//                   return Transform.scale(
//                     scale: _loaderPulse.value,
//                     child: child,
//                   );
//                 },
//                 child: Container(
//                   width: 64,
//                   height: 64,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     border: Border.all(
//                       color: Colors.cyanAccent,
//                       width: 3,
//                     ),
//                   ),
//                   child: const Center(
//                     child: Icon(
//                       Icons.smart_toy_outlined,
//                       color: Colors.cyanAccent,
//                       size: 30,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 24),
//               const Text(
//                 "Detecting objects",
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   letterSpacing: 0.3,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 "Please keep the device steady...",
//                 style: TextStyle(
//                   color: Colors.white.withOpacity(0.55),
//                   fontSize: 13,
//                 ),
//               ),
//               const SizedBox(height: 28),
//               _buildLoaderDots(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildLoaderDots() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [0, 1, 2].map((i) {
//         return AnimatedBuilder(
//           animation: _loaderAnim,
//           builder: (_, __) {
//             final double delay = i * 0.28;
//             double value = (_loaderAnim.value + delay) % 1.0;
//             return Container(
//               margin: const EdgeInsets.symmetric(horizontal: 4),
//               width: 8,
//               height: 8,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: Colors.cyanAccent.withOpacity(0.25 + (value * 0.75)),
//               ),
//             );
//           },
//         );
//       }).toList(),
//     );
//   }
//
//   // =========================
//   // NO OBJECT REVIEW OVERLAY
//   // =========================
//   Widget _buildNoObjectReviewOverlay() {
//     return Positioned.fill(
//       child: Container(
//         color: Colors.black.withOpacity(0.88),
//         child: SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(14),
//                   decoration: BoxDecoration(
//                     color: Colors.orange.withOpacity(0.12),
//                     shape: BoxShape.circle,
//                   ),
//                   child: const Icon(
//                     Icons.search_off_rounded,
//                     color: Colors.orange,
//                     size: 42,
//                   ),
//                 ),
//                 const SizedBox(height: 18),
//                 const Text(
//                   "No Object Detected",
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 6),
//                 Text(
//                   "We kept your captured image.\nYou can retake or keep it as parent-only.",
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     color: Colors.white.withOpacity(0.65),
//                     fontSize: 13,
//                     height: 1.4,
//                   ),
//                 ),
//                 const SizedBox(height: 24),
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(16),
//                   child: Image.file(
//                     currentCapturedImage!,
//                     width: 260,
//                     height: 260,
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//                 const SizedBox(height: 24),
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.06),
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: Colors.white24),
//                   ),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Icon(Icons.info_outline,
//                           size: 16, color: Colors.cyanAccent),
//                       const SizedBox(width: 8),
//                       Text(
//                         "Retake will not count toward $maxCaptures",
//                         style: TextStyle(
//                           color: Colors.white.withOpacity(0.7),
//                           fontSize: 12,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 24),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: ElevatedButton.icon(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.redAccent,
//                           foregroundColor: Colors.white,
//                           padding: const EdgeInsets.symmetric(vertical: 14),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                         onPressed: _retakeCurrentParent,
//                         icon: const Icon(Icons.refresh),
//                         label: const Text("Retake"),
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: ElevatedButton.icon(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.blue,
//                           foregroundColor: Colors.white,
//                           padding: const EdgeInsets.symmetric(vertical: 14),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                         onPressed: _keepParentOnly,
//                         icon: const Icon(Icons.check),
//                         label: const Text("Keep Parent"),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   // =========================
//   // TOP GALLERY
//   // =========================
//   Widget _buildTopGallery() {
//     return Positioned(
//       top: 0,
//       left: 0,
//       right: 0,
//       child: Container(
//         color: Colors.black.withOpacity(0.85),
//         child: SafeArea(
//           bottom: false,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Padding(
//                 padding:
//                 const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       "Captures: ${captureResults.length} / $maxCaptures",
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 14,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     Row(
//                       children: List.generate(maxCaptures, (i) {
//                         return Container(
//                           margin: const EdgeInsets.symmetric(horizontal: 3),
//                           width: 12,
//                           height: 12,
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             color: i < captureResults.length
//                                 ? Colors.cyanAccent
//                                 : Colors.white24,
//                             border: Border.all(
//                                 color: Colors.white38, width: 1),
//                           ),
//                         );
//                       }),
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(
//                 height: 150,
//                 child: ListView.builder(
//                   scrollDirection: Axis.horizontal,
//                   padding: const EdgeInsets.symmetric(horizontal: 8),
//                   itemCount: captureResults.length,
//                   itemBuilder: (context, index) {
//                     return _buildCaptureCard(captureResults[index], index);
//                   },
//                 ),
//               ),
//               const SizedBox(height: 6),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   // =========================
//   // CAPTURE CONTROLS
//   // =========================
//   Widget _buildCaptureControls() {
//     return Column(
//       children: [
//         Text(
//           captureResults.length < maxCaptures
//               ? "Tap to capture (${captureResults.length + 1} of $maxCaptures)"
//               : "Ready to submit",
//           style: const TextStyle(
//             color: Colors.white70,
//             fontSize: 13,
//           ),
//         ),
//         const SizedBox(height: 10),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             if (captureResults.isNotEmpty)
//               GestureDetector(
//                 onTap: retakeLastCapture,
//                 child: Container(
//                   height: 50,
//                   width: 50,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: Colors.redAccent.withOpacity(0.8),
//                     border: Border.all(color: Colors.white54, width: 2),
//                   ),
//                   child: const Center(
//                     child: Icon(Icons.undo, size: 24, color: Colors.white),
//                   ),
//                 ),
//               ),
//             if (captureResults.isNotEmpty) const SizedBox(width: 30),
//             GestureDetector(
//               onTap: captureAndDetect,
//               child: Container(
//                 height: 70,
//                 width: 70,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: Colors.white,
//                   border: Border.all(color: Colors.cyanAccent, width: 4),
//                 ),
//                 child: const Center(
//                   child: Icon(Icons.camera_alt,
//                       size: 32, color: Colors.black87),
//                 ),
//               ),
//             ),
//             if (captureResults.isNotEmpty) const SizedBox(width: 30),
//             if (captureResults.isNotEmpty)
//               GestureDetector(
//                 onTap: submitAll,
//                 child: Container(
//                   height: 50,
//                   width: 50,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: Colors.green.withOpacity(0.8),
//                     border: Border.all(color: Colors.white54, width: 2),
//                   ),
//                   child: const Center(
//                     child: Icon(Icons.check, size: 24, color: Colors.white),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ],
//     );
//   }
//
//   Widget _buildFinalControls() {
//     return Column(
//       children: [
//         const Text(
//           "All 5 images captured!",
//           style: TextStyle(
//             color: Colors.cyanAccent,
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const SizedBox(height: 12),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ElevatedButton.icon(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.redAccent,
//                 foregroundColor: Colors.white,
//                 padding:
//                 const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(25)),
//               ),
//               onPressed: retakeLastCapture,
//               icon: const Icon(Icons.undo),
//               label: const Text("Undo Last"),
//             ),
//             const SizedBox(width: 20),
//             ElevatedButton.icon(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.green,
//                 foregroundColor: Colors.white,
//                 padding:
//                 const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(25)),
//               ),
//               onPressed: submitAll,
//               icon: const Icon(Icons.send),
//               label: const Text("Submit All"),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
//
//   // =========================
//   // CAPTURE CARD
//   // =========================
//   Widget _buildCaptureCard(CaptureResult capture, int index) {
//     return GestureDetector(
//       onTap: () => _showCaptureDetail(capture),
//       child: Container(
//         width: 130,
//         margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
//         decoration: BoxDecoration(
//           color: Colors.grey[900],
//           borderRadius: BorderRadius.circular(10),
//           border:
//           Border.all(color: Colors.cyanAccent.withOpacity(0.5), width: 1),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
//               decoration: BoxDecoration(
//                 color: Colors.cyanAccent.withOpacity(0.2),
//                 borderRadius: const BorderRadius.only(
//                   topLeft: Radius.circular(9),
//                   topRight: Radius.circular(9),
//                 ),
//               ),
//               child: Text(
//                 "Capture #${capture.captureIndex}",
//                 style: const TextStyle(
//                   color: Colors.cyanAccent,
//                   fontSize: 10,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(4),
//               child: Row(
//                 children: [
//                   Column(
//                     children: [
//                       ClipRRect(
//                         borderRadius: BorderRadius.circular(6),
//                         child: Image.file(
//                           capture.parentImage,
//                           width: 45,
//                           height: 45,
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                       const SizedBox(height: 2),
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 4, vertical: 1),
//                         decoration: BoxDecoration(
//                           color: Colors.blue.withOpacity(0.3),
//                           borderRadius: BorderRadius.circular(4),
//                         ),
//                         child: const Text(
//                           "Parent",
//                           style: TextStyle(
//                             color: Colors.lightBlueAccent,
//                             fontSize: 7,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(width: 4),
//                   Expanded(
//                     child: SizedBox(
//                       height: 60,
//                       child: ListView.builder(
//                         scrollDirection: Axis.horizontal,
//                         itemCount: capture.croppedDetections.length,
//                         itemBuilder: (context, ci) {
//                           final cropped = capture.croppedDetections[ci];
//                           return Padding(
//                             padding: const EdgeInsets.only(right: 3),
//                             child: Column(
//                               children: [
//                                 ClipRRect(
//                                   borderRadius: BorderRadius.circular(4),
//                                   child: Image.file(
//                                     cropped.croppedImage,
//                                     width: 35,
//                                     height: 35,
//                                     fit: BoxFit.cover,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 2),
//                                 Container(
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: 3, vertical: 1),
//                                   decoration: BoxDecoration(
//                                     color: Colors.orange.withOpacity(0.3),
//                                     borderRadius: BorderRadius.circular(4),
//                                   ),
//                                   child: const Text(
//                                     "Child",
//                                     style: TextStyle(
//                                       color: Colors.orangeAccent,
//                                       fontSize: 7,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                 ),
//                                 Text(
//                                   "${(cropped.confidence * 100).toStringAsFixed(0)}%",
//                                   style: const TextStyle(
//                                     color: Colors.white54,
//                                     fontSize: 7,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 6),
//               child: Text(
//                 capture.croppedDetections.isEmpty
//                     ? "Parent only"
//                     : "${capture.croppedDetections.length} object(s) detected",
//                 style: const TextStyle(
//                   color: Colors.white38,
//                   fontSize: 8,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // =========================
//   // DETAIL DIALOG
//   // =========================
//   void _showCaptureDetail(CaptureResult capture) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return Dialog(
//           backgroundColor: Colors.grey[900],
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//           child: Container(
//             constraints: const BoxConstraints(maxHeight: 500),
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       "Capture #${capture.captureIndex}",
//                       style: const TextStyle(
//                         color: Colors.cyanAccent,
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     IconButton(
//                       icon: const Icon(Icons.close, color: Colors.white54),
//                       onPressed: () => Navigator.pop(context),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 10),
//                 const Text(
//                   "📷 Parent Image",
//                   style: TextStyle(
//                     color: Colors.lightBlueAccent,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 13,
//                   ),
//                 ),
//                 const SizedBox(height: 6),
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(10),
//                   child: Image.file(
//                     capture.parentImage,
//                     width: double.infinity,
//                     height: 150,
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 Text(
//                   "🔍 Detected Objects (${capture.croppedDetections.length})",
//                   style: const TextStyle(
//                     color: Colors.orangeAccent,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 13,
//                   ),
//                 ),
//                 const SizedBox(height: 6),
//                 if (capture.croppedDetections.isEmpty)
//                   const Padding(
//                     padding: EdgeInsets.all(8.0),
//                     child: Text(
//                       "No detected objects. Parent image only.",
//                       style: TextStyle(color: Colors.white54, fontSize: 12),
//                     ),
//                   )
//                 else
//                   SizedBox(
//                     height: 100,
//                     child: ListView.builder(
//                       scrollDirection: Axis.horizontal,
//                       itemCount: capture.croppedDetections.length,
//                       itemBuilder: (context, i) {
//                         final cropped = capture.croppedDetections[i];
//                         return Container(
//                           width: 90,
//                           margin: const EdgeInsets.only(right: 8),
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(8),
//                             border: Border.all(
//                                 color: Colors.orangeAccent.withOpacity(0.5)),
//                           ),
//                           child: Column(
//                             children: [
//                               ClipRRect(
//                                 borderRadius: const BorderRadius.only(
//                                   topLeft: Radius.circular(7),
//                                   topRight: Radius.circular(7),
//                                 ),
//                                 child: Image.file(
//                                   cropped.croppedImage,
//                                   width: 90,
//                                   height: 65,
//                                   fit: BoxFit.cover,
//                                 ),
//                               ),
//                               const SizedBox(height: 4),
//                               Text(
//                                 "Child - ${(cropped.confidence * 100).toStringAsFixed(0)}%",
//                                 style: const TextStyle(
//                                   color: Colors.white70,
//                                   fontSize: 9,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   // =========================
//   // CORNER GUIDE
//   // =========================
//   Widget _buildCorner({
//     double? top,
//     double? left,
//     double? right,
//     double? bottom,
//     required double angle,
//   }) {
//     return Positioned(
//       top: top,
//       left: left,
//       right: right,
//       bottom: bottom,
//       child: Transform.rotate(
//         angle: angle * pi / 180,
//         child: Container(
//           width: 30,
//           height: 30,
//           decoration: const BoxDecoration(
//             border: Border(
//               top: BorderSide(color: Colors.cyanAccent, width: 3),
//               left: BorderSide(color: Colors.cyanAccent, width: 3),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // =========================
// // PAINTER
// // =========================
// class BoxPainter extends CustomPainter {
//   final List<Detection> detections;
//
//   BoxPainter(this.detections);
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     final boxPaint = Paint()
//       ..color = Colors.red
//       ..strokeWidth = 3
//       ..style = PaintingStyle.stroke;
//
//     final bgPaint = Paint()
//       ..color = Colors.red
//       ..style = PaintingStyle.fill;
//
//     for (var d in detections) {
//       final double left = d.rect.left * size.width;
//       final double top = d.rect.top * size.height;
//       final double width = d.rect.width * size.width;
//       final double height = d.rect.height * size.height;
//
//       final r = Rect.fromLTWH(left, top, width, height);
//
//       canvas.drawRect(r, boxPaint);
//
//       final String text = "Rubber ${(d.conf * 100).toStringAsFixed(0)}%";
//
//       final textPainter = TextPainter(
//         text: TextSpan(
//           text: text,
//           style: const TextStyle(
//             color: Colors.white,
//             fontSize: 10,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         textDirection: TextDirection.ltr,
//       );
//
//       textPainter.layout();
//
//       final labelBgRect = Rect.fromLTWH(
//         left,
//         top - textPainter.height - 4,
//         textPainter.width + 8,
//         textPainter.height + 4,
//       );
//
//       canvas.drawRect(labelBgRect, bgPaint);
//
//       textPainter.paint(
//         canvas,
//         Offset(left + 4, top - textPainter.height - 2),
//       );
//     }
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// }


import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

// ─────────────────────────────────────────────────────────────
// DATA MODELS
// ─────────────────────────────────────────────────────────────

class CaptureResult {
  final File parentImage;
  final List<CroppedDetection> croppedDetections;
  final int captureIndex;
  final bool isProcessing;

  CaptureResult({
    required this.parentImage,
    required this.croppedDetections,
    required this.captureIndex,
    this.isProcessing = false,
  });

  CaptureResult copyWith({
    File? parentImage,
    List<CroppedDetection>? croppedDetections,
    int? captureIndex,
    bool? isProcessing,
  }) {
    return CaptureResult(
      parentImage: parentImage ?? this.parentImage,
      croppedDetections: croppedDetections ?? this.croppedDetections,
      captureIndex: captureIndex ?? this.captureIndex,
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }
}

class CroppedDetection {
  final File croppedImage;
  final double confidence;
  final Rect originalRect;

  CroppedDetection({
    required this.croppedImage,
    required this.confidence,
    required this.originalRect,
  });
}

class Detection {
  final Rect rect;
  final double conf;
  Detection(this.rect, this.conf);
}

// ─────────────────────────────────────────────────────────────
// ISOLATE — YOLO
// ─────────────────────────────────────────────────────────────

class _YoloInput {
  final String imagePath;
  final String modelPath;
  const _YoloInput({required this.imagePath, required this.modelPath});
}

class _YoloOutput {
  final List<Map<String, double>> detections;
  final String imagePath;
  const _YoloOutput({required this.detections, required this.imagePath});
}

Future<_YoloOutput> _runYoloIsolate(_YoloInput data) async {
  final interpreter = Interpreter.fromFile(File(data.modelPath));
  try {
    final bytes = await File(data.imagePath).readAsBytes();
    final image = img.decodeImage(bytes);
    if (image == null) {
      return _YoloOutput(detections: [], imagePath: data.imagePath);
    }

    final inputImage = img.copyResize(image, width: 640, height: 640);

    final input = [
      List.generate(640, (y) => List.generate(640, (x) {
        final p = inputImage.getPixel(x, y);
        return [p.r / 255.0, p.g / 255.0, p.b / 255.0];
      })),
    ];

    final output = List.generate(
        1, (_) => List.generate(5, (_) => List.filled(8400, 0.0)));

    interpreter.run(input, output);

    List<Map<String, double>> raw = [];
    for (int i = 0; i < 8400; i++) {
      final double conf = output[0][4][i];
      if (conf > 0.5) {
        raw.add({
          'cx': output[0][0][i],
          'cy': output[0][1][i],
          'w': output[0][2][i] * 1.40,
          'h': output[0][3][i] * 1.40,
          'conf': conf,
        });
      }
    }

    return _YoloOutput(
        detections: _nmsIsolate(raw, 0.5), imagePath: data.imagePath);
  } catch (_) {
    return _YoloOutput(detections: [], imagePath: data.imagePath);
  } finally {
    interpreter.close();
  }
}

double _iouIsolate(Map<String, double> a, Map<String, double> b) {
  final ax = a['cx']! - a['w']! / 2;
  final ay = a['cy']! - a['h']! / 2;
  final bx = b['cx']! - b['w']! / 2;
  final by = b['cy']! - b['h']! / 2;

  final x1 = max(ax, bx);
  final y1 = max(ay, by);
  final x2 = min(ax + a['w']!, bx + b['w']!);
  final y2 = min(ay + a['h']!, by + b['h']!);

  final iW = max(0.0, x2 - x1);
  final iH = max(0.0, y2 - y1);
  final iArea = iW * iH;
  final union = a['w']! * a['h']! + b['w']! * b['h']! - iArea;
  return union <= 0 ? 0 : iArea / union;
}

List<Map<String, double>> _nmsIsolate(
    List<Map<String, double>> boxes, double threshold) {
  boxes.sort((a, b) => b['conf']!.compareTo(a['conf']!));
  final result = <Map<String, double>>[];
  for (final box in boxes) {
    bool keep = true;
    for (final sel in result) {
      if (_iouIsolate(box, sel) > threshold) {
        keep = false;
        break;
      }
    }
    if (keep) result.add(box);
  }
  return result;
}

// ─────────────────────────────────────────────────────────────
// ISOLATE — CROP
// ─────────────────────────────────────────────────────────────

class _CropInput {
  final String imagePath;
  final List<Map<String, double>> detections;
  final String baseOutputPath;
  const _CropInput(
      {required this.imagePath,
        required this.detections,
        required this.baseOutputPath});
}

class _CropOutput {
  final List<Map<String, dynamic>> crops;
  const _CropOutput({required this.crops});
}

Future<_CropOutput> _cropInIsolate(_CropInput data) async {
  final bytes = await File(data.imagePath).readAsBytes();
  final full = img.decodeImage(bytes);
  if (full == null) return const _CropOutput(crops: []);

  final crops = <Map<String, dynamic>>[];

  for (int i = 0; i < data.detections.length; i++) {
    final d = data.detections[i];
    final rect = Rect.fromCenter(
      center: Offset(d['cx']!, d['cy']!),
      width: d['w']!,
      height: d['h']!,
    );

    int x = (rect.left * full.width).toInt();
    int y = (rect.top * full.height).toInt();
    int cw = (rect.width * full.width).toInt();
    int ch = (rect.height * full.height).toInt();

    x = max(0, x);
    y = max(0, y);
    cw = min(cw, full.width - x);
    ch = min(ch, full.height - y);

    if (cw <= 0 || ch <= 0) continue;

    final crop = img.copyCrop(full, x: x, y: y, width: cw, height: ch);
    final path =
        '${data.baseOutputPath}_crop_${i}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    await File(path).writeAsBytes(img.encodeJpg(crop));

    crops.add({
      'path': path,
      'conf': d['conf']!,
      'left': rect.left,
      'top': rect.top,
      'width': rect.width,
      'height': rect.height,
    });
  }

  return _CropOutput(crops: crops);
}

// ─────────────────────────────────────────────────────────────
// PAGE
// ─────────────────────────────────────────────────────────────

class RubberCameraDetectorPage extends StatefulWidget {
  const RubberCameraDetectorPage({super.key});

  @override
  State<RubberCameraDetectorPage> createState() =>
      _RubberCameraDetectorPageState();
}

class _RubberCameraDetectorPageState extends State<RubberCameraDetectorPage> {
  CameraController? _controller;
  List<CaptureResult> _captures = [];
  FlashMode _flashMode = FlashMode.torch;
  bool _isLoading = true;
  int _processingCount = 0;
  String? _modelTempPath;

  static const int _maxCaptures = 5;

  // Fixed pixel heights — no unbounded constraints
  static const double _galleryH = 208.0;
  static const double _bottomH = 140.0;
  bool _isWaitingToSubmit = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  // ── INIT ─────────────────────────────────────────────────

  Future<void> _init() async {
    final cams = await availableCameras();
    _controller = CameraController(cams[0], ResolutionPreset.medium,
        enableAudio: false);
    await _controller!.initialize();

    try {
      await _controller!.setFlashMode(FlashMode.torch);
      _flashMode = FlashMode.torch;
    } catch (_) {
      _flashMode = FlashMode.off;
    }

    // Copy model to temp file so isolate can load it via path
    try {
      final data = await rootBundle.load('assets/model/best_float32.tflite');
      final tmp =
      File('${Directory.systemTemp.path}/gg_yolo_best_float32.tflite');
      final bytes =
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      if (!tmp.existsSync() || tmp.lengthSync() != bytes.lengthInBytes) {
        await tmp.writeAsBytes(bytes);
      }
      _modelTempPath = tmp.path;
    } catch (e) {
      debugPrint('Model temp error: $e');
    }

    if (mounted) setState(() => _isLoading = false);
  }

  void _popWithResult() {
    if (!mounted) return;
    final result = <Map<String, dynamic>>[];
    for (final cap in _captures) {
      result.add({
        'path': cap.parentImage.path,
        'type': 'parent',
        'captureIndex': cap.captureIndex,
        'conf': 1.0,
      });
      for (final c in cap.croppedDetections) {
        result.add({
          'path': c.croppedImage.path,
          'type': 'child',
          'captureIndex': cap.captureIndex,
          'conf': c.confidence,
        });
      }
    }
    Navigator.of(context).pop(result);
  }

  // ── FLASH ────────────────────────────────────────────────

  Future<void> _toggleFlash() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    final next =
    _flashMode == FlashMode.off ? FlashMode.torch : FlashMode.off;
    try {
      await _controller!.setFlashMode(next);
      setState(() => _flashMode = next);
    } catch (_) {}
  }

  // ── CAPTURE ──────────────────────────────────────────────

  Future<void> _capture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (_captures.length >= _maxCaptures) return;

    try {
      final photo = await _controller!.takePicture();
      final file = File(photo.path);
      final idx = _captures.length + 1;

      setState(() {
        _captures.add(CaptureResult(
          parentImage: file,
          croppedDetections: [],
          captureIndex: idx,
          isProcessing: true,
        ));
        _processingCount++;
      });

      _detectBg(file, idx); // fire-and-forget
    } catch (e) {
      debugPrint('Capture error: $e');
    }
  }

  // ── BACKGROUND DETECT ────────────────────────────────────

  Future<void> _detectBg(File imageFile, int captureIndex) async {
    try {
      if (_modelTempPath == null) {
        _done(captureIndex, []);
        return;
      }

      final yolo = await compute(_runYoloIsolate,
          _YoloInput(imagePath: imageFile.path, modelPath: _modelTempPath!));

      if (yolo.detections.isEmpty) {
        _done(captureIndex, []);
        return;
      }

      final base = imageFile.path.replaceAll('.jpg', '');
      final crops = await compute(_cropInIsolate,
          _CropInput(
              imagePath: imageFile.path,
              detections: yolo.detections,
              baseOutputPath: base));

      _done(
        captureIndex,
        crops.crops
            .map((c) => CroppedDetection(
          croppedImage: File(c['path'] as String),
          confidence: c['conf'] as double,
          originalRect: Rect.fromLTWH(c['left'] as double,
              c['top'] as double, c['width'] as double, c['height'] as double),
        ))
            .toList(),
      );
    } catch (e) {
      debugPrint('BG detect error: $e');
      _done(captureIndex, []);
    }
  }

  void _done(int captureIndex, List<CroppedDetection> crops) {
    if (!mounted) return;
    setState(() {
      _processingCount = max(0, _processingCount - 1);
      final i = _captures.indexWhere((c) => c.captureIndex == captureIndex);
      if (i != -1) {
        _captures[i] = _captures[i].copyWith(
          croppedDetections: crops,
          isProcessing: false,
        );
      }

      // Auto-submit if waiting and processing finished
      if (_processingCount == 0 && _isWaitingToSubmit) {
        _isWaitingToSubmit = false;
        _popWithResult();
      }
    });
  }
  // ── UNDO ─────────────────────────────────────────────────

  void _undoLast() {
    if (_captures.isEmpty) return;
    if (_captures.last.isProcessing) {
      _processingCount = max(0, _processingCount - 1);
    }
    setState(() => _captures.removeLast());
  }

  // ── SUBMIT ───────────────────────────────────────────────

  Future<void> _submit() async {
    if (_captures.isEmpty) return;
    if (_processingCount == 0) {
      _popWithResult();
      return;
    }

    final wait = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Still Processing'),
        content: Text(
          '$_processingCount image${_processingCount > 1 ? 's are' : ' is'} '
              'still being analyzed.\n\nWait or submit now?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Wait'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Submit Now'),
          ),
        ],
      ),
    );

    if (!mounted || wait == null) return;

    if (wait) {
      setState(() => _isWaitingToSubmit = true);
      // Will automatically submit when processing is complete
    } else {
      _popWithResult();
    }
  }
  // ─────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_isLoading ||
        _controller == null ||
        !_controller!.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
            child: CircularProgressIndicator(color: Colors.cyanAccent)),
      );
    }

    final bool hasGallery = _captures.isNotEmpty;
    final bool canCapture = _captures.length < _maxCaptures;

    // top of flash / badge overlay
    final double overlayTopPx = hasGallery ? _galleryH + 10 : 56;

    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(builder: (context, constraints) {
        final double sw = constraints.maxWidth;
        final double sh = constraints.maxHeight;

        return SizedBox(
          width: sw,
          height: sh,
          child: Stack(children: [
            // ── CAMERA ─────────────────────────────────────
            Positioned.fill(child: CameraPreview(_controller!)),

            // ── TOP GALLERY ────────────────────────────────
            if (hasGallery)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: _galleryH,
                child: _Gallery(
                  captures: _captures,
                  maxCaptures: _maxCaptures,
                  onTap: _showDetail,
                ),
              ),

            // ── GUIDE FRAME ────────────────────────────────
            Positioned(
              top: hasGallery ? _galleryH + 14 : sh * 0.15,
              left: 40,
              right: 40,
              bottom: _bottomH + 36,
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white24),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Stack(children: [
                    _corner(top: 0, left: 0, angle: 0),
                    _corner(top: 0, right: 0, angle: 90),
                    _corner(bottom: 0, left: 0, angle: 270),
                    _corner(bottom: 0, right: 0, angle: 180),
                  ]),
                ),
              ),
            ),

            // ── FLASH BUTTON ───────────────────────────────
            Positioned(
              top: overlayTopPx,
              right: 16,
              child: _CircleBtn(
                onTap: _toggleFlash,
                child: Icon(
                  _flashMode == FlashMode.torch
                      ? Icons.flash_on
                      : Icons.flash_off,
                  color: _flashMode == FlashMode.torch
                      ? Colors.yellowAccent
                      : Colors.white,
                  size: 22,
                ),
              ),
            ),

            // ── BOTTOM CONTROLS ────────────────────────────
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: _bottomH,
              child: _BottomBar(
                canCapture: canCapture,
                hasCaptures: hasGallery,
                onCapture: _capture,
                onUndo: _undoLast,
                onSubmit: _submit,
                captureCount: _captures.length,
                maxCaptures: _maxCaptures,
              ),
            ),
          ]),
        );
      }),
    );
  }

  // ── CORNER GUIDE ────────────────────────────────────────

  Widget _corner(
      {double? top, double? left, double? right, double? bottom, required double angle}) {
    return Positioned(
      top: top, left: left, right: right, bottom: bottom,
      child: Transform.rotate(
        angle: angle * pi / 180,
        child: Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.cyanAccent, width: 3),
              left: BorderSide(color: Colors.cyanAccent, width: 3),
            ),
          ),
        ),
      ),
    );
  }

  // ── DETAIL DIALOG ───────────────────────────────────────

  void _showDetail(CaptureResult cap) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 500),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Capture #${cap.captureIndex}',
                        style: const TextStyle(
                            color: Colors.cyanAccent,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: const Icon(Icons.close, color: Colors.white54),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text('📷 Parent Image',
                    style: TextStyle(
                        color: Colors.lightBlueAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(cap.parentImage,
                      width: double.infinity, height: 150, fit: BoxFit.cover),
                ),
                const SizedBox(height: 12),
                Text(
                    '🔍 Detected Objects (${cap.croppedDetections.length})',
                    style: const TextStyle(
                        color: Colors.orangeAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
                const SizedBox(height: 6),
                if (cap.croppedDetections.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(8),
                    child: Text('No objects detected. Parent image kept.',
                        style:
                        TextStyle(color: Colors.white54, fontSize: 12)),
                  )
                else
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: cap.croppedDetections.length,
                      itemBuilder: (_, i) {
                        final c = cap.croppedDetections[i];
                        return Container(
                          width: 90,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: Colors.orangeAccent.withOpacity(0.5)),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(7),
                                  topRight: Radius.circular(7),
                                ),
                                child: Image.file(c.croppedImage,
                                    width: 90, height: 65, fit: BoxFit.cover),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Child - ${(c.confidence * 100).toStringAsFixed(0)}%',
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 9),
                              ),
                            ],
                          ),
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
  }
}

// ─────────────────────────────────────────────────────────────
// EXTRACTED WIDGETS — all have bounded sizes, NO ElevatedButton
// ─────────────────────────────────────────────────────────────

// ── Gallery ─────────────────────────────────────────────────

class _Gallery extends StatelessWidget {
  final List<CaptureResult> captures;
  final int maxCaptures;
  final void Function(CaptureResult) onTap;

  const _Gallery(
      {required this.captures,
        required this.maxCaptures,
        required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.85),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // header
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Captures: ${captures.length} / $maxCaptures',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(maxCaptures, (i) {
                      Color c = Colors.white24;
                      if (i < captures.length) {
                        c = captures[i].isProcessing
                            ? Colors.orangeAccent
                            : Colors.cyanAccent;
                      }
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: 11,
                        height: 11,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: c,
                          border:
                          Border.all(color: Colors.white38, width: 1),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            // cards
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: captures.length,
                itemBuilder: (_, i) =>
                    _CaptureCard(capture: captures[i], onTap: onTap),
              ),
            ),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }
}

// ── Capture Card ─────────────────────────────────────────────

class _CaptureCard extends StatelessWidget {
  final CaptureResult capture;
  final void Function(CaptureResult) onTap;

  const _CaptureCard({required this.capture, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool proc = capture.isProcessing;
    final Color accent = proc ? Colors.orangeAccent : Colors.cyanAccent;

    return GestureDetector(
      onTap: proc ? null : () => onTap(capture),
      child: Container(
        width: 130,
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: accent.withOpacity(0.5)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // header strip
            Container(
              width: double.infinity,
              padding:
              const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: accent.withOpacity(0.2),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(9),
                  topRight: Radius.circular(9),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Capture #${capture.captureIndex}',
                      style: TextStyle(
                          color: accent,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                  if (proc)
                    const SizedBox(
                      width: 10,
                      height: 10,
                      child: CircularProgressIndicator(
                          strokeWidth: 1.5, color: Colors.orangeAccent),
                    ),
                ],
              ),
            ),
            // body
            Padding(
              padding: const EdgeInsets.all(4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // parent thumb
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Stack(children: [
                          Image.file(capture.parentImage,
                              width: 45, height: 45, fit: BoxFit.cover),
                          if (proc)
                            Container(
                                width: 45,
                                height: 45,
                                color: Colors.black38),
                        ]),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('Parent',
                            style: TextStyle(
                                color: Colors.lightBlueAccent,
                                fontSize: 7,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(width: 4),
                  // children
                  Expanded(
                    child: SizedBox(
                      height: 60,
                      child: proc
                          ? const Center(
                          child: Text('Detecting...',
                              style: TextStyle(
                                  color: Colors.orangeAccent,
                                  fontSize: 9)))
                          : capture.croppedDetections.isEmpty
                          ? const Center(
                          child: Text('Parent only',
                              style: TextStyle(
                                  color: Colors.white38,
                                  fontSize: 9)))
                          : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount:
                        capture.croppedDetections.length,
                        itemBuilder: (_, ci) {
                          final c =
                          capture.croppedDetections[ci];
                          return Padding(
                            padding:
                            const EdgeInsets.only(right: 3),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ClipRRect(
                                  borderRadius:
                                  BorderRadius.circular(4),
                                  child: Image.file(
                                      c.croppedImage,
                                      width: 35,
                                      height: 35,
                                      fit: BoxFit.cover),
                                ),
                                const SizedBox(height: 2),
                                Container(
                                  padding:
                                  const EdgeInsets.symmetric(
                                      horizontal: 3,
                                      vertical: 1),
                                  decoration: BoxDecoration(
                                    color: Colors.orange
                                        .withOpacity(0.3),
                                    borderRadius:
                                    BorderRadius.circular(4),
                                  ),
                                  child: const Text('Child',
                                      style: TextStyle(
                                          color:
                                          Colors.orangeAccent,
                                          fontSize: 7,
                                          fontWeight:
                                          FontWeight.bold)),
                                ),
                                Text(
                                  '${(c.confidence * 100).toStringAsFixed(0)}%',
                                  style: const TextStyle(
                                      color: Colors.white54,
                                      fontSize: 7),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // footer
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              child: Text(
                proc
                    ? 'Processing...'
                    : capture.croppedDetections.isEmpty
                    ? 'No objects found'
                    : '${capture.croppedDetections.length} object(s)',
                style: const TextStyle(color: Colors.white38, fontSize: 8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bottom Bar ───────────────────────────────────────────────
// !! NO ElevatedButton anywhere — only GestureDetector + Container !!

class _BottomBar extends StatelessWidget {
  final bool canCapture;
  final bool hasCaptures;
  final VoidCallback onCapture;
  final VoidCallback onUndo;
  final VoidCallback onSubmit;
  final int captureCount;
  final int maxCaptures;

  const _BottomBar({
    required this.canCapture,
    required this.hasCaptures,
    required this.onCapture,
    required this.onUndo,
    required this.onSubmit,
    required this.captureCount,
    required this.maxCaptures,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // fixed height — avoids unbounded Column
      height: 140,
      color: Colors.black.withOpacity(0.45),
      alignment: Alignment.center,
      child: canCapture ? _captureRow() : _finalRow(),
    );
  }

  Widget _captureRow() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Tap to capture ($captureCount of $maxCaptures)',
          style:
          const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (hasCaptures) ...[
              _Btn(
                onTap: onUndo,
                size: 50,
                color: Colors.redAccent.withOpacity(0.85),
                child: const Icon(Icons.undo, size: 22, color: Colors.white),
              ),
              const SizedBox(width: 28),
            ],
            _Btn(
              onTap: onCapture,
              size: 70,
              color: Colors.white,
              borderColor: Colors.cyanAccent,
              borderWidth: 4,
              child: const Icon(Icons.camera_alt,
                  size: 32, color: Colors.black87),
            ),
            if (hasCaptures) ...[
              const SizedBox(width: 28),
              _Btn(
                onTap: onSubmit,
                size: 50,
                color: Colors.green.withOpacity(0.85),
                child:
                const Icon(Icons.check, size: 22, color: Colors.white),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _finalRow() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'All 5 images captured!',
          style: TextStyle(
              color: Colors.cyanAccent,
              fontSize: 15,
              fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _PillBtn(
              onTap: onUndo,
              color: Colors.redAccent.withOpacity(0.85),
              icon: Icons.undo,
              label: 'Undo Last',
            ),
            const SizedBox(width: 16),
            _PillBtn(
              onTap: onSubmit,
              color: Colors.green,
              icon: Icons.send,
              label: 'Submit All',
            ),
          ],
        ),
      ],
    );
  }
}

// ── _Btn: fixed-size circle button ───────────────────────────

class _Btn extends StatelessWidget {
  final VoidCallback onTap;
  final double size;
  final Color color;
  final Color? borderColor;
  final double borderWidth;
  final Widget child;

  const _Btn({
    required this.onTap,
    required this.size,
    required this.color,
    required this.child,
    this.borderColor,
    this.borderWidth = 0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: borderColor != null
              ? Border.all(color: borderColor!, width: borderWidth)
              : null,
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}

// ── _PillBtn: intrinsic-size pill button ─────────────────────
// Uses IntrinsicWidth so Row(mainAxisSize:min) can measure it.

class _PillBtn extends StatelessWidget {
  final VoidCallback onTap;
  final Color color;
  final IconData icon;
  final String label;

  const _PillBtn(
      {required this.onTap,
        required this.color,
        required this.icon,
        required this.label});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min, // ← key: min, not max
          children: [
            Icon(icon, size: 18, color: Colors.white),
            const SizedBox(width: 6),
            Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

// ── _CircleBtn ───────────────────────────────────────────────

class _CircleBtn extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;

  const _CircleBtn({required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: const BoxDecoration(
            color: Colors.black45, shape: BoxShape.circle),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}

// ── Processing Badge ─────────────────────────────────────────

// class _ProcessingBadge extends StatelessWidget {
//   final int count;
//   const _ProcessingBadge({required this.count});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding:
//       const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//       decoration: BoxDecoration(
//         color: Colors.black54,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: Colors.cyanAccent),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           const SizedBox(
//             width: 14,
//             height: 14,
//             child: CircularProgressIndicator(
//                 strokeWidth: 2, color: Colors.cyanAccent),
//           ),
//           const SizedBox(width: 8),
//           Text('Processing $count',
//               style: const TextStyle(
//                   color: Colors.cyanAccent,
//                   fontSize: 12,
//                   fontWeight: FontWeight.bold)),
//         ],
//       ),
//     );
//   }
// }

// ─────────────────────────────────────────────────────────────
// PAINTER (kept for future use)
// ─────────────────────────────────────────────────────────────

class BoxPainter extends CustomPainter {
  final List<Detection> detections;
  BoxPainter(this.detections);

  @override
  void paint(Canvas canvas, Size size) {
    final boxP = Paint()
      ..color = Colors.red
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    final bgP = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    for (final d in detections) {
      final l = d.rect.left * size.width;
      final t = d.rect.top * size.height;
      final w = d.rect.width * size.width;
      final h = d.rect.height * size.height;
      canvas.drawRect(Rect.fromLTWH(l, t, w, h), boxP);

      final tp = TextPainter(
        text: TextSpan(
          text: 'Rubber ${(d.conf * 100).toStringAsFixed(0)}%',
          style: const TextStyle(
              color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      canvas.drawRect(
          Rect.fromLTWH(l, t - tp.height - 4, tp.width + 8, tp.height + 4),
          bgP);
      tp.paint(canvas, Offset(l + 4, t - tp.height - 2));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => true;
}
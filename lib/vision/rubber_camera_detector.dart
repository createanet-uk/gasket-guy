



// import 'dart:io';
// import 'dart:math';
// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
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
// class _RubberCameraDetectorPageState extends State<RubberCameraDetectorPage> {
//   CameraController? controller;
//   Interpreter? interpreter;
//
//   File? capturedImage;
//   List<Detection> detections = [];
//
//   bool isLoading = true;
//   bool isDetecting = false;
//
//   @override
//   void initState() {
//     super.initState();
//     init();
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
//     interpreter = await Interpreter.fromAsset(
//       'assets/model/best_float32.tflite',
//     );
//
//     setState(() {
//       isLoading = false;
//     });
//   }
//
//   // =========================
//   // CAPTURE IMAGE
//   // =========================
//   Future<void> captureImage() async {
//     if (controller == null || !controller!.value.isInitialized) return;
//
//     final photo = await controller!.takePicture();
//
//     capturedImage = File(photo.path);
//     detections.clear();
//
//     setState(() {});
//   }
//
//   // =========================
//   // RUN DETECTION
//   // =========================
//   Future<void> detectObjects() async {
//     if (capturedImage == null || interpreter == null) return;
//
//
//     setState(() {
//       isDetecting = true;
//     });
//
//     await Future.delayed(const Duration(milliseconds: 50));
//
//     try{
//       final bytes = await capturedImage!.readAsBytes();
//       img.Image? image = img.decodeImage(bytes);
//
//       if (image == null) return;
//
//       final inputImage = img.copyResize(image, width: 640, height: 640);
//
//       final input = [
//         List.generate(640, (y) {
//           return List.generate(640, (x) {
//             final p = inputImage.getPixel(x, y);
//             return [p.r / 255, p.g / 255, p.b / 255];
//           });
//         }),
//       ];
//
//       final output = List.generate(
//         1,
//             (_) => List.generate(5, (_) => List.filled(8400, 0.0)),
//       );
//
//       interpreter!.run(input, output);
//
//       List<Detection> raw = [];
//
//       for (int i = 0; i < 8400; i++) {
//         double conf = output[0][4][i];
//
//         if (conf > 0.5) {
//           raw.add(
//             Detection(
//               Rect.fromCenter(
//                 center: Offset(output[0][0][i], output[0][1][i]),
//                 width: output[0][2][i] * 1.40,
//                 height: output[0][3][i]* 1.40,
//               ),
//               conf,
//             ),
//           );
//         }
//       }
//
//       detections = nms(raw, 0.5);
//
//       // --- CHECK FOR EMPTY DETECTIONS ---
//       if (detections.isEmpty && mounted) {
//         _showNoDetectionDialog();
//       }
//
//     }catch(e){
//       print('Object detection error: $e');
//     }finally{
//       setState(() {isDetecting = false;});
//     }
//   }
//
//   // =========================
// // SHOW NO DETECTION DIALOG
// // =========================
//   void _showNoDetectionDialog() {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//           title: const Row(
//             children: [
//               Icon(Icons.warning_amber_rounded, color: Colors.orange),
//               SizedBox(width: 10),
//               Text("No Object Found"),
//             ],
//           ),
//           content: const Text(
//             "The detector couldn't identify any objects in this image. Please try adjusting the lighting or position and take another photo.",
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 setState(() {
//                   capturedImage = null;
//                   detections.clear();
//                 });
//               },
//               child: const Text("Retake Photo"),
//             ),
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: const Text("OK"),
//             ),
//           ],
//         );
//       },
//     );
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
//   // SUBMIT (CROP OBJECTS)
//   // =========================
//   Future<void> submit() async {
//     if (capturedImage == null || detections.isEmpty) return;
//
//     final bytes = await capturedImage!.readAsBytes();
//     img.Image? full = img.decodeImage(bytes);
//
//     if (full == null) return;
//
//     List<Map<String, dynamic>> result = [];
//
//     for (var d in detections) {
//       final r = d.rect;
//
//       int x = (r.left * full.width).toInt();
//       int y = (r.top * full.height).toInt();
//       int w = (r.width * full.width).toInt();
//       int h = (r.height * full.height).toInt();
//
//       x = max(0, x);
//       y = max(0, y);
//
//       w = min(w, full.width - x);
//       h = min(h, full.height - y);
//
//       final crop = img.copyCrop(full, x: x, y: y, width: w, height: h);
//
//       final path = capturedImage!.path.replaceAll(
//         ".jpg",
//         "_${DateTime.now().millisecondsSinceEpoch}.jpg",
//       );
//
//       final file = File(path);
//       await file.writeAsBytes(img.encodeJpg(crop));
//
//       result.add({"path": file.path, "conf": d.conf});
//     }
//
//     if (mounted) Navigator.pop(context, result);
//   }
//
//   @override
//   void dispose() {
//     controller?.dispose();
//     interpreter?.close();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (isLoading || controller == null || !controller!.value.isInitialized) {
//       return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     }
//
//     return Scaffold(
//       body: LayoutBuilder(
//         builder: (context, constraints) => SizedBox(
//           width: double.infinity,
//           height: double.infinity,
//           child: Stack(
//             children: [
//               // CAMERA OR IMAGE
//               capturedImage == null
//                   ? SizedBox(
//                 height: double.infinity,
//                 width: double.infinity,
//                 child: CameraPreview(
//                   controller!,
//                 ),
//               )
//                   : Image.file(
//                 capturedImage!,
//                 fit: BoxFit.fill,
//                 width: double.infinity,
//                 height: double.infinity,
//               ),
//
//               // BOXES
//               if (capturedImage != null)
//                 Positioned.fill(
//                   child: CustomPaint(painter: BoxPainter(detections)),
//                 ),
//
//               if (capturedImage == null)
//                 Positioned(
//                   top: constraints.maxHeight * 0.2,
//                   left: 40,
//                   right: 40,
//                   bottom: constraints.maxHeight * 0.3,
//                   child: Container(
//                     decoration: BoxDecoration(
//                       border: Border.all(color: Colors.white24, width: 1),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Stack(
//                       children: [
//                         // Corner L-Shapes
//                         _buildCorner(top: 0, left: 0, angle: 0),
//                         _buildCorner(top: 0, right: 0, angle: 90),
//                         _buildCorner(bottom: 0, left: 0, angle: 270),
//                         _buildCorner(bottom: 0, right: 0, angle: 180),
//                       ],
//                     ),
//                   ),
//                 ),
//
//               // BUTTONS
//               Positioned(
//                 bottom: 40,
//                 left: 0,
//                 right: 0,
//                 child: Column(
//                   children: [
//                     if (capturedImage == null)
//                       GestureDetector(
//                         onTap: captureImage,
//                         child: Container(
//                           // child: const Text("Capture"),
//                           height: 60,
//                           width: 60,
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             border: BoxBorder.all(color: Colors.black, width: 2),
//                           ),
//                           child: Center(child: Icon(Icons.camera, size: 30)),
//                         ),
//                       ),
//
//                     if (capturedImage != null && detections.isEmpty)
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           ElevatedButton.icon(
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.redAccent,
//                               foregroundColor: Colors.white,
//                               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//                             ),
//                             onPressed: isDetecting
//                                 ? null
//                                 : () => setState(() => capturedImage = null),
//                             icon: const Icon(Icons.refresh),
//                             label: const Text("Retake"),
//                           ),
//                           const SizedBox(width: 20),
//                           ElevatedButton(
//                             onPressed: isDetecting
//                                 ? null
//                                 : detectObjects,
//                             child: isDetecting
//                                 ? const Text("Detecting...")
//                                 : const Text("Detect"),
//                           ),
//                         ],
//                       ),
//
//                     if (detections.isNotEmpty)
//                       ElevatedButton(
//                         onPressed: submit,
//                         child: const Text("Submit"),
//                       ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
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
// // MODEL
// // =========================
// class Detection {
//   final Rect rect;
//   final double conf;
//
//   Detection(this.rect, this.conf);
// }
//
// // =========================
// // PAINTER
// // =========================
//
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
//       // Calculate coordinates relative to canvas size
//       final double left = d.rect.left * size.width;
//       final double top = d.rect.top * size.height;
//       final double width = d.rect.width * size.width;
//       final double height = d.rect.height * size.height;
//
//       final r = Rect.fromLTWH(left, top, width, height);
//
//       // 1. Draw Bounding Box
//       canvas.drawRect(r, boxPaint);
//
//       // 2. Prepare Label Text (Confidence %)
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
//       // 3. Draw Label Background (Small rectangle above/inside box)
//       final labelBgRect = Rect.fromLTWH(
//         left,
//         top - textPainter.height - 4, // Positioned slightly above the box
//         textPainter.width + 8,
//         textPainter.height + 4,
//       );
//
//       canvas.drawRect(labelBgRect, bgPaint);
//
//       // 4. Draw Text
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
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class RubberCameraDetectorPage extends StatefulWidget {
  const RubberCameraDetectorPage({super.key});

  @override
  State<RubberCameraDetectorPage> createState() =>
      _RubberCameraDetectorPageState();
}

class _RubberCameraDetectorPageState extends State<RubberCameraDetectorPage> {
  CameraController? controller;
  Interpreter? interpreter;

  File? capturedImage;
  List<Detection> detections = [];

  bool isLoading = true;
  bool isDetecting = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    final cams = await availableCameras();

    controller = CameraController(
      cams[0],
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await controller!.initialize();

    interpreter = await Interpreter.fromAsset(
      'assets/model/best_float32.tflite',
    );

    setState(() {
      isLoading = false;
    });
  }

  // =========================
  // CAPTURE IMAGE
  // =========================
  Future<void> captureImage() async {
    if (controller == null || !controller!.value.isInitialized) return;

    final photo = await controller!.takePicture();

    capturedImage = File(photo.path);
    detections.clear();

    setState(() {});
  }


  // =========================
  // Use Full Image
  // =========================

  Future<void> useFullImage() async {
    if (capturedImage == null) return;

    if (mounted) {
      Navigator.pop(context, [
        {
          "path": capturedImage!.path,
          "conf": 1.0, // optional, since no detection
          "isFullImage": true,
        }
      ]);
    }
  }

  // =========================
  // RUN DETECTION
  // =========================
  Future<void> detectObjects() async {
    if (capturedImage == null || interpreter == null) return;


    setState(() {
      isDetecting = true;
    });

    await Future.delayed(const Duration(milliseconds: 50));

    try{
      final bytes = await capturedImage!.readAsBytes();
      img.Image? image = img.decodeImage(bytes);

      if (image == null) return;

      final inputImage = img.copyResize(image, width: 640, height: 640);

      final input = [
        List.generate(640, (y) {
          return List.generate(640, (x) {
            final p = inputImage.getPixel(x, y);
            return [p.r / 255, p.g / 255, p.b / 255];
          });
        }),
      ];

      final output = List.generate(
        1,
            (_) => List.generate(5, (_) => List.filled(8400, 0.0)),
      );

      interpreter!.run(input, output);

      List<Detection> raw = [];

      for (int i = 0; i < 8400; i++) {
        double conf = output[0][4][i];

        if (conf > 0.5) {
          raw.add(
            Detection(
              Rect.fromCenter(
                center: Offset(output[0][0][i], output[0][1][i]),
                width: output[0][2][i] * 1.40,
                height: output[0][3][i]* 1.40,
              ),
              conf,
            ),
          );
        }
      }

      detections = nms(raw, 0.5);

      // --- CHECK FOR EMPTY DETECTIONS ---
      if (detections.isEmpty && mounted) {
        _showNoDetectionDialog();
      }

    }catch(e){
      print('Object detection error: $e');
    }finally{
      setState(() {isDetecting = false;});
    }
  }

  // =========================
// SHOW NO DETECTION DIALOG
// =========================
  void _showNoDetectionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange),
              SizedBox(width: 10),
              Text("No Object Found"),
            ],
          ),
          content: const Text(
            "The detector couldn't identify any objects in this image. Please try adjusting the lighting or position and take another photo.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  capturedImage = null;
                  detections.clear();
                });
              },
              child: const Text("Retake Photo"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  // =========================
  // NMS
  // =========================
  List<Detection> nms(List<Detection> boxes, double iouThreshold) {
    boxes.sort((a, b) => b.conf.compareTo(a.conf));

    List<Detection> result = [];

    for (var box in boxes) {
      bool keep = true;

      for (var selected in result) {
        if (iou(box.rect, selected.rect) > iouThreshold) {
          keep = false;
          break;
        }
      }

      if (keep) result.add(box);
    }

    return result;
  }

  double iou(Rect a, Rect b) {
    final inter = a.intersect(b);
    final interArea = inter.width * inter.height;

    final union = a.width * a.height + b.width * b.height - interArea;

    return union == 0 ? 0 : interArea / union;
  }

  // =========================
  // SUBMIT (CROP OBJECTS)
  // =========================
  Future<void> submit() async {
    if (capturedImage == null || detections.isEmpty) return;

    final bytes = await capturedImage!.readAsBytes();
    img.Image? full = img.decodeImage(bytes);

    if (full == null) return;

    List<Map<String, dynamic>> result = [];

    for (var d in detections) {
      final r = d.rect;

      int x = (r.left * full.width).toInt();
      int y = (r.top * full.height).toInt();
      int w = (r.width * full.width).toInt();
      int h = (r.height * full.height).toInt();

      x = max(0, x);
      y = max(0, y);

      w = min(w, full.width - x);
      h = min(h, full.height - y);

      final crop = img.copyCrop(full, x: x, y: y, width: w, height: h);

      final path = capturedImage!.path.replaceAll(
        ".jpg",
        "_${DateTime.now().millisecondsSinceEpoch}.jpg",
      );

      final file = File(path);
      await file.writeAsBytes(img.encodeJpg(crop));

      result.add({"path": file.path, "conf": d.conf});
    }

    if (mounted) Navigator.pop(context, result);
  }

  @override
  void dispose() {
    controller?.dispose();
    interpreter?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || controller == null || !controller!.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) => SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              // CAMERA OR IMAGE
              capturedImage == null
                  ? SizedBox(
                height: double.infinity,
                width: double.infinity,
                child: CameraPreview(
                  controller!,
                ),
              )
                  : Image.file(
                capturedImage!,
                fit: BoxFit.fill,
                width: double.infinity,
                height: double.infinity,
              ),

              // BOXES
              if (capturedImage != null)
                Positioned.fill(
                  child: CustomPaint(painter: BoxPainter(detections)),
                ),

              if (capturedImage == null)
                Positioned(
                  top: constraints.maxHeight * 0.2,
                  left: 40,
                  right: 40,
                  bottom: constraints.maxHeight * 0.3,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white24, width: 1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Stack(
                      children: [
                        // Corner L-Shapes
                        _buildCorner(top: 0, left: 0, angle: 0),
                        _buildCorner(top: 0, right: 0, angle: 90),
                        _buildCorner(bottom: 0, left: 0, angle: 270),
                        _buildCorner(bottom: 0, right: 0, angle: 180),
                      ],
                    ),
                  ),
                ),

              // BUTTONS
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    if (capturedImage == null)
                      GestureDetector(
                        onTap: captureImage,
                        child: Container(
                          // child: const Text("Capture"),
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: BoxBorder.all(color: Colors.black, width: 2),
                          ),
                          child: Center(child: Icon(Icons.camera, size: 30)),
                        ),
                      ),

                    if (capturedImage != null && detections.isEmpty)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            ),
                            onPressed: isDetecting
                                ? null
                                : () => setState(() => capturedImage = null),
                            icon: const Icon(Icons.refresh),
                            label: const Text("Retake"),
                          ),
                          // const SizedBox(width: 20),
                          ElevatedButton(
                            onPressed: isDetecting
                                ? null
                                : detectObjects,
                            child: isDetecting
                                ? const Text("Detecting...")
                                : const Text("Detect"),
                          ),

                          // const SizedBox(width: 20),

                          // 🔥 NEW BUTTON
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: useFullImage,
                            icon: const Icon(Icons.check),
                            label: const Text("Use Image"),
                          ),
                        ],
                      ),

                    if (detections.isNotEmpty)
                      ElevatedButton(
                        onPressed: submit,
                        child: const Text("Submit"),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCorner({
    double? top,
    double? left,
    double? right,
    double? bottom,
    required double angle,
  }) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: Transform.rotate(
        angle: angle * pi / 180,
        child: Container(
          width: 30,
          height: 30,
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
}

// =========================
// MODEL
// =========================
class Detection {
  final Rect rect;
  final double conf;

  Detection(this.rect, this.conf);
}

// =========================
// PAINTER
// =========================

class BoxPainter extends CustomPainter {
  final List<Detection> detections;

  BoxPainter(this.detections);

  @override
  void paint(Canvas canvas, Size size) {
    final boxPaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final bgPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    for (var d in detections) {
      // Calculate coordinates relative to canvas size
      final double left = d.rect.left * size.width;
      final double top = d.rect.top * size.height;
      final double width = d.rect.width * size.width;
      final double height = d.rect.height * size.height;

      final r = Rect.fromLTWH(left, top, width, height);

      // 1. Draw Bounding Box
      canvas.drawRect(r, boxPaint);

      // 2. Prepare Label Text (Confidence %)
      final String text = "Rubber ${(d.conf * 100).toStringAsFixed(0)}%";

      final textPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();

      // 3. Draw Label Background (Small rectangle above/inside box)
      final labelBgRect = Rect.fromLTWH(
        left,
        top - textPainter.height - 4, // Positioned slightly above the box
        textPainter.width + 8,
        textPainter.height + 4,
      );

      canvas.drawRect(labelBgRect, bgPaint);

      // 4. Draw Text
      textPainter.paint(
        canvas,
        Offset(left + 4, top - textPainter.height - 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}




// class BoxPainter extends CustomPainter {
//   final List<Detection> detections;
//
//   BoxPainter(this.detections);
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Colors.red
//       ..strokeWidth = 3
//       ..style = PaintingStyle.stroke;
//
//     for (var d in detections) {
//       final r = Rect.fromLTRB(
//         d.rect.left * size.width,
//         d.rect.top * size.height,
//         (d.rect.left + d.rect.width) * size.width,
//         (d.rect.top + d.rect.height) * size.height,
//       );
//
//       canvas.drawRect(r, paint);
//     }
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// }
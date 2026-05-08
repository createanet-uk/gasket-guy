// import 'dart:io';
// import 'package:http/http.dart' as http;
// import 'package:path_provider/path_provider.dart';
//
// class FileDownloader {
//   Future<String> downloadFile(String url, String fileName) async {
//     final response = await http.get(Uri.parse(url));
//
//     final dir = await getApplicationDocumentsDirectory();
//     final file = File('${dir.path}/$fileName');
//
//     await file.writeAsBytes(response.bodyBytes);
//
//     return file.path;
//   }
// }

import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class FileDownloader {
  Future<String> downloadFile(String url, String filename) async {
    final response = await http.get(Uri.parse(url));

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$filename');

    await file.writeAsBytes(response.bodyBytes);

    return file.path;
  }
}
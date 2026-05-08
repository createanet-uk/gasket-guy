// import 'dart:convert';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class ModelService {
//   final supabase = Supabase.instance.client;
//
//   Future<Map<String, dynamic>?> fetchLatestModel() async {
//     final res = await supabase
//         .from('model_versions')
//         .select()
//         .eq('is_active', true)
//         .limit(1)
//         .single();
//
//     return res;
//   }
//
//   Future<String?> getLocalVersion() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString('model_version');
//   }
//
//   Future<void> saveLocalVersion(String version) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('model_version', version);
//   }
// }

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ModelService {
  final supabase = Supabase.instance.client;

  Future<Map<String, dynamic>?> fetchLatestModel() async {
    final res = await supabase
        .from('model_versions') // ✅ FIXED TABLE NAME
        .select()
        .order('version', ascending: false)
        .limit(1)
        .maybeSingle();

    return res;
  }

  Future<String?> getLocalVersion() async {
    final pref = await SharedPreferences.getInstance();
    return pref.getString('model_version');
  }

  Future<void> saveLocalVersion(String version) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString('model_version', version);
  }
}
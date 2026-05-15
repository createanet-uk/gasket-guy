import 'package:flutter/material.dart';
import 'package:mobile/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../common/cm_dialog.dart';
import '../services/supabase_service.dart';
import '../theme.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _auth = Supabase.instance.client;

  bool _isSignUp = false;
  bool _isLoading = false;
  bool _obscurePassword = true;

  // Future<void> _handleAuth() async {
  //   if (_emailController.text.isEmpty || _passwordController.text.isEmpty) return;
  //
  //   setState(() => _isLoading = true);
  //   try {
  //     if (_isSignUp) {
  //       // SIGNUP LOGIC
  //       await _auth.auth.signUp(
  //         email: _emailController.text.trim(),
  //         password: _passwordController.text.trim(),
  //       );
  //       if (mounted) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(content: Text("Account created! Role set to 'User'. Please login.")),
  //         );
  //         setState(() => _isSignUp = false);
  //       }
  //     } else {
  //       // LOGIN LOGIC
  //       await _auth.auth.signInWithPassword(email: _emailController.text.trim(),password: _passwordController.text.trim());
  //       // final role = await _auth.getUserRole();
  //       // _redirectBasedOnRole(role);
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       print('error:::  $e');
  //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
  //     }
  //   } finally {
  //     if (mounted) setState(() => _isLoading = false);
  //   }
  // }

  // Future<void> _handleAuth() async {
  //   if (_emailController.text.isEmpty || _passwordController.text.isEmpty) return;
  //
  //   setState(() => _isLoading = true);
  //   try {
  //     if (_isSignUp) {
  //       // SIGNUP LOGIC
  //       final response = await Supabase.instance.client.auth.signUp(
  //         email: _emailController.text.trim(),
  //         password: _passwordController.text.trim(),
  //         // Pass the name in metadata so the trigger can pick it up
  //         data: {'full_name': _nameController.text.trim()},
  //       );
  //
  //       if (mounted) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(content: Text("Account created! Please check your email or login.")),
  //         );
  //         setState(() => _isSignUp = false);
  //       }
  //     } else {
  //       // LOGIN LOGIC
  //       final response = await Supabase.instance.client.auth.signInWithPassword(
  //         email: _emailController.text.trim(),
  //         password: _passwordController.text.trim(),
  //       );
  //
  //       if (response.session != null && mounted) {
  //         // Navigate to HomePage and remove the Login page from the stack
  //         Navigator.pushReplacement(
  //           context,
  //           MaterialPageRoute(builder: (context) => const HomePage()),
  //         );
  //       }
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       debugPrint('error::: $e');
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text(e.toString().replaceAll('Exception:', '').trim())),
  //       );
  //     }
  //   } finally {
  //     if (mounted) setState(() => _isLoading = false);
  //   }
  // }

  // void _showBannedDialog() {
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false, // User must acknowledge
  //     builder: (context) => AlertDialog(
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  //       title: Row(
  //         children: [
  //           Icon(Icons.report_problem_rounded, color: Colors.red[700], size: 28),
  //           const SizedBox(width: 10),
  //           const Text("Access Denied"),
  //         ],
  //       ),
  //       content: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           const Text(
  //             "Your account has been deactivated by the Administrator.",
  //             style: TextStyle(fontWeight: FontWeight.bold),
  //           ),
  //           const SizedBox(height: 12),
  //           const Text(
  //             "If you believe this is a mistake or would like to request an appeal, please contact your regional supervisor or system admin.",
  //             style: TextStyle(color: Colors.grey, fontSize: 13),
  //           ),
  //         ],
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text("UNDERSTOOD", style: TextStyle(fontWeight: FontWeight.bold)),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Future<void> _handleAuth() async {
    // Basic validation
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    // Check if Name is provided during Sign Up
    if (_isSignUp && _nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your full name")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final client = Supabase.instance.client;
      final _service = SupabaseService();

      if (_isSignUp) {
        // --- SIGNUP LOGIC ---
        await client.auth.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          data: {
            'full_name': _nameController.text.trim(),
            // Note: Role is handled by your Supabase trigger as 'user'
          },
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Account created! Please login.")),
          );
          setState(() => _isSignUp = false);
        }
      } else {
        // --- LOGIN LOGIC ---
        final response = await client.auth.signInWithPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (response.session != null && mounted) {
          final SharedPreferences prefs = await SharedPreferences.getInstance();

          await prefs.setString(
              'is_user_logged_in', response.session?.accessToken ?? '');
          // 1. Fetch the user's role from the user_profiles table
          // We use the authService instance you defined in supabase_service.dart
          final String? role = await _service.getUserRole();

          // 2. Call your existing navigation handler
          if (mounted) {
            // We use 'user' as a fallback if the profile fetch fails
            _service.handleLoginNavigation(context, role ?? 'user');
          }
        }
      }
    } catch (e) {
      if (mounted) {
        debugPrint('Auth Error: $e');

        // Check if the error is specifically a Banned User error from Supabase
        if (e is AuthApiException && e.code == 'user_banned') {
          CmDialog.showBannedDialog(context);
        } else {
          // Standard error handling for other cases (wrong password, etc.)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceAll('Exception:', '').trim()),
              backgroundColor: AppTheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _redirectBasedOnRole(String? role) {
    if (role == 'admin') {
      debugPrint("Navigating to Admin Dashboard...");
    } else if (role == 'engineer') {
      debugPrint("Navigating to Engineer Tools...");
    } else {
      debugPrint("Navigating to standard User Home...");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.blur_on_rounded, size: 80, color: AppTheme.primary),
              const SizedBox(height: 16),
              Text(
                _isSignUp ? "Join Gasket Guy" : "Welcome Back",
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.primaryText),
              ),
              Text(
                _isSignUp ? "Create your account" : "Sign in to continue",
                style: const TextStyle(color: AppTheme.secondaryText),
              ),
              const SizedBox(height: 40),

              if (_isSignUp) ...[
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: "Full Name", prefixIcon: Icon(Icons.person_outline)),
                ),
                const SizedBox(height: 16),
              ],

              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Email", prefixIcon: Icon(Icons.email_outlined)),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(labelText: "Password", prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppTheme.secondaryText,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword; // Toggle visibility state
                      });
                    },
                  ),),
              ),
              const SizedBox(height: 32),

              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _handleAuth,
                child: Text(_isSignUp ? "CREATE ACCOUNT" : "SIGN IN"),
              ),

              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  _nameController.clear();
                  _emailController.clear();
                  _passwordController.clear();
                  setState(() => _isSignUp = !_isSignUp);
                },
                child: Text(
                  _isSignUp ? "Already have an account? Sign In" : "New here? Create an Account",
                  style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
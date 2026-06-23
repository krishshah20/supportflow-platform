import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/auth_service.dart';
import '../screens/admin_screen.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await _authService.loginAdmin(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const AdminScreen()),
          (route) => false,
        );
      } catch (e) {
        if (!mounted) return;
        
        String errorMsg = e.toString();
        if (errorMsg.startsWith('Exception: ')) {
          errorMsg = errorMsg.substring(11);
        } else if (errorMsg.contains('] ')) {
          errorMsg = errorMsg.split('] ').last;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
                padding: const EdgeInsets.all(32.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24.0),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black45,
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.admin_panel_settings,
                          size: 64,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Agent Portal',
                        style: GoogleFonts.outfit(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Authorized Personnel Only',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.redAccent.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 32),
                      TextFormField(
                        controller: _emailController,
                        style: const TextStyle(),
                        decoration: InputDecoration(
                          labelText: 'Agent Email',
                          labelStyle: const TextStyle(color: Colors.black54),
                          prefixIcon: const Icon(Icons.badge_outlined, color: Color(0xFF1E293B)),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.0),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.0),
                            borderSide: const BorderSide(color: Color(0xFF1E293B), width: 2),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) => v!.isEmpty ? 'Please enter agent email' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        style: const TextStyle(),
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: const TextStyle(color: Colors.black54),
                          prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF1E293B)),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: Colors.black45,
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.0),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.0),
                            borderSide: const BorderSide(color: Color(0xFF1E293B), width: 2),
                          ),
                        ),
                        validator: (v) => v!.isEmpty ? 'Please enter password' : null,
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E293B),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            elevation: 2,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : Text(
                                  'Secure Login',
                                  style: GoogleFonts.outfit(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

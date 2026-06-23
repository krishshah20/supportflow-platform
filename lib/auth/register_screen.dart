import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/auth_service.dart';
import '../screens/home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Passwords do not match'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      
      setState(() => _isLoading = true);
      try {
        await _authService.registerClient(
          _nameController.text.trim(),
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
        
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context, 
          MaterialPageRoute(builder: (_) => const HomeScreen()), 
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
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Container(
                padding: const EdgeInsets.all(32.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24.0),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 15,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.person_add_alt_1_rounded,
                        size: 64,
                        color: Color(0xFF6366F1),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Create Account',
                        style: GoogleFonts.outfit(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Join us to submit your inquiries',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 32),
                      TextFormField(
                        controller: _nameController,
                        style: GoogleFonts.inter(),
                        decoration: InputDecoration(
                          labelText: 'Full Name',
                          labelStyle: const TextStyle(color: Colors.black54),
                          prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF6366F1)),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.0),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.0),
                            borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
                          ),
                        ),
                        validator: (v) => v!.isEmpty ? 'Please enter your full name' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        style: GoogleFonts.inter(),
                        decoration: InputDecoration(
                          labelText: 'Email Address',
                          labelStyle: const TextStyle(color: Colors.black54),
                          prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF6366F1)),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.0),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.0),
                            borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) => v!.isEmpty ? 'Please enter your email' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        style: GoogleFonts.inter(),
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: const TextStyle(color: Colors.black54),
                          prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF6366F1)),
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
                            borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Please enter a password';
                          if (v.length < 6) return 'Password must be at least 6 characters';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _confirmPasswordController,
                        style: GoogleFonts.inter(),
                        obscureText: _obscureConfirmPassword,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          labelStyle: const TextStyle(color: Colors.black54),
                          prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF6366F1)),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: Colors.black45,
                            ),
                            onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.0),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.0),
                            borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
                          ),
                        ),
                        validator: (v) => v!.isEmpty ? 'Please confirm your password' : null,
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6366F1),
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
                                  'Register',
                                  style: GoogleFonts.outfit(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Already have an account?",
                            style: GoogleFonts.inter(color: Colors.black54),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'Log In',
                              style: GoogleFonts.inter(
                                color: const Color(0xFF6366F1),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
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

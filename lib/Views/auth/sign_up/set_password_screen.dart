// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:naivedhya/utils/color_theme.dart';
import '../../../models/user_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../utils/widgets/custom_button.dart';
import '../../../utils/widgets/custom_text_field.dart';
import '../../../utils/validator.dart';
import '../../user/onboarding/onboarding_screen.dart';

class SetPasswordScreen extends StatefulWidget {
  final UserModel user;

  const SetPasswordScreen({super.key, required this.user});

  @override
  // ignore: library_private_types_in_public_api
  _SetPasswordScreenState createState() => _SetPasswordScreenState();
}

class _SetPasswordScreenState extends State<SetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _topText = 'Set Password';

  @override
  void initState() {
    super.initState();
    // Change text after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _topText = 'Almost Done';
        });
      }
    });
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _createPassword() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Passwords do not match')),
        );
        return;
      }

      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final success = await authProvider.signUp(widget.user, _passwordController.text);
        if (success) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const OnboardingScreen()),
            (route) => false,
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          // Dismiss keyboard when tapping outside text fields
          FocusScope.of(context).unfocus();
        },
        child: Column(
          children: [
            Container(
              height: screenHeight * 0.3,
              color: isDark ? AppTheme.darkPrimary : AppTheme.background,
              child: Padding(
                padding: const EdgeInsets.only(top: 40, left: 20, right: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white), 
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    Expanded(
                      child: Center(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          child: Text(
                            _topText,
                            key: ValueKey(_topText),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 48), // Balance the back button
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkBackground : Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                        return Column(
                          children: [
                            const SizedBox(height: 30),
                            
                            // Password Requirements Info
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isDark 
                                    ? AppTheme.darkPrimary.withOpacity(0.15)
                                    : AppTheme.background.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDark 
                                      ? AppTheme.darkPrimary.withOpacity(0.3)
                                      : AppTheme.background.withOpacity(0.3),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Password Requirements:',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: isDark 
                                          ? AppTheme.darkPrimary 
                                          : AppTheme.background,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  _buildRequirement('At least 8 characters', isDark),
                                  _buildRequirement('One uppercase letter', isDark),
                                  _buildRequirement('One lowercase letter', isDark),
                                  _buildRequirement('One number', isDark),
                                  _buildRequirement('One special character', isDark),
                                ],
                              ),
                            ),
                            const SizedBox(height: 30),
                            
                            CustomTextField(
                              label: 'Password',
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              validator: Validator.validatePassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                  color: isDark ? AppTheme.darkPrimary : AppTheme.primary,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(height: 20),
                            
                            CustomTextField(
                              label: 'Confirm Password',
                              controller: _confirmPasswordController,
                              obscureText: _obscureConfirmPassword,
                              validator: Validator.validatePassword,
                              suffixIcon: IconButton( 
                                icon: Icon(
                                  _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                                  color: isDark ? AppTheme.darkPrimary : AppTheme.primary,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword = !_obscureConfirmPassword;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(height: 20),
                            
                            // Security Note
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppTheme.darkSuccess.withOpacity(0.15)
                                    : AppTheme.success.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isDark
                                      ? AppTheme.darkSuccess.withOpacity(0.3)
                                      : AppTheme.success.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.security,
                                    color: isDark ? AppTheme.darkSuccess : AppTheme.success,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Your password is encrypted and stored securely',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark ? AppTheme.darkSuccess : AppTheme.success,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 30),
                            
                            authProvider.isLoading
                                ? CircularProgressIndicator(
                                    color: isDark ? AppTheme.darkPrimary : AppTheme.primary,
                                  )
                                : CustomButton(
                                    text: 'Create Password',
                                    onPressed: _createPassword,
                                  ),
                            const SizedBox(height: 20),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequirement(String requirement, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 16,
            color: isDark ? AppTheme.darkTextSecondary : Colors.grey,
          ),
          const SizedBox(width: 8),
          Text(
            requirement,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppTheme.darkTextSecondary : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
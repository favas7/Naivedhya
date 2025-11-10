// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:naivedhya/Views/bottom_navigator/bottom_navigator.dart';
import 'package:provider/provider.dart';
import 'package:naivedhya/utils/color_theme.dart';
import '../../../models/user_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../utils/widgets/custom_button.dart';
import '../../../utils/widgets/custom_text_field.dart';
import '../../../utils/validator.dart';
import 'set_password_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  SignUpScreenState createState() => SignUpScreenState();
} 

class SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();
  String _topText = 'Sign Up';

  @override
  void initState() {
    super.initState();
    // Change text after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _topText = 'Welcome';
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  void _selectDate() async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: isDark ? AppTheme.darkPrimary : AppTheme.primary,
              onPrimary: Colors.white,
              surface: isDark ? AppTheme.darkSurface : AppTheme.accent,
              onSurface: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  Future<void> _handleSignUp() async {
    if (_formKey.currentState!.validate()) {
      try {
        final user = UserModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(), 
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          dob: _dobController.text,
          address: '',
          pendingpayments: 0.0,
          orderhistory: [],
          created_at: DateTime.now(),
          updated_at: DateTime.now(),
          usertype: 'user',
        );
        
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SetPasswordScreen(user: user),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Breakpoint: 768px for web layout
        final isWebLayout = constraints.maxWidth > 768;
        
        return isWebLayout 
          ? _buildWebLayout(context)
          : _buildMobileLayout(context);
      },
    );
  }

  // ============ WEB LAYOUT ============
  Widget _buildWebLayout(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark 
                ? [
                    AppTheme.darkBackground,
                    AppTheme.darkPrimary.withOpacity(0.3),
                    AppTheme.darkBackground,
                  ]
                : [
                    AppTheme.accent,
                    AppTheme.primary.withOpacity(0.6),
                    AppTheme.primaryLight.withOpacity(0.4),
                  ],
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                width: 450,
                margin: const EdgeInsets.all(24),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.5 : 0.1),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Back button and Welcome text
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.arrow_back_ios,
                              color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                              size: 20,
                            ),
                            onPressed: () => Navigator.pop(context),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          Expanded(
                            child: Center(
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 400),
                                child: Text(
                                  _topText,
                                  key: ValueKey(_topText),
                                  style: theme.textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 32),
                        ],
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Subtitle
                      Text(
                        'Create your account',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Name Field
                      CustomTextField(
                        label: 'Name',
                        controller: _nameController,
                        validator: Validator.validateName,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Email Field
                      CustomTextField(
                        label: 'Email',
                        controller: _emailController,
                        validator: Validator.validateEmail,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Phone Field
                      CustomTextField(
                        label: 'Phone',
                        controller: _phoneController,
                        validator: Validator.validatePhone,
                        keyboardType: TextInputType.phone,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Date of Birth Field
                      CustomTextField(
                        label: 'Date of Birth',
                        controller: _dobController,
                        validator: Validator.validateDob,
                        keyboardType: TextInputType.datetime,
                        readOnly: true,
                        onTap: _selectDate,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Terms and Privacy
                      Text(
                        'By continuing, you agree to\nTerms of Use and Privacy Policy.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Sign Up Button
                      Consumer<AuthProvider>(
                        builder: (context, authProvider, child) {
                          return authProvider.isLoading
                            ? Center(
                                child: CircularProgressIndicator(
                                  color: theme.colorScheme.primary,
                                ),
                              )
                            : CustomButton(
                                text: 'Sign Up',
                                onPressed: _handleSignUp,
                              );
                        },
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Divider with "or"
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: isDark 
                                ? AppTheme.darkTextHint 
                                : AppTheme.textHint,
                              thickness: 1,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'or',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isDark 
                                  ? AppTheme.darkTextSecondary 
                                  : AppTheme.textSecondary,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: isDark 
                                ? AppTheme.darkTextHint 
                                : AppTheme.textHint,
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Google Sign In
                      Consumer<AuthProvider>(
                        builder: (context, authProvider, child) {
                          if (authProvider.isLoading) return const SizedBox.shrink();
                          
                          return GestureDetector(
                            onTap: () async {
                              try {
                                final success = await authProvider.googleSignIn();
                                if (success) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const BottomNavigator(),
                                    ),
                                  );
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(e.toString())),
                                );
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isDark ? AppTheme.darkSurfaceVariant : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDark 
                                    ? AppTheme.darkTextHint 
                                    : AppTheme.textHint.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/Google_Logo/google-logo.png',
                                    height: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Continue with Google',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
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

  // ============ MOBILE LAYOUT (ORIGINAL) ============
  Widget _buildMobileLayout(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Column(
          children: [
            Container(
              height: screenHeight * 0.3,
              color: isDark ? AppTheme.darkPrimary : AppTheme.primary,
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
                    const SizedBox(width: 48),
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
                            CustomTextField(
                              label: 'Name',
                              controller: _nameController,
                              validator: Validator.validateName,
                            ),
                            const SizedBox(height: 20),
                            CustomTextField(
                              label: 'Email',
                              controller: _emailController,
                              validator: Validator.validateEmail,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 20),
                            CustomTextField(
                              label: 'Phone',
                              controller: _phoneController,
                              validator: Validator.validatePhone,
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 20),
                            CustomTextField(
                              label: 'Date of Birth',
                              controller: _dobController,
                              validator: Validator.validateDob,
                              keyboardType: TextInputType.datetime,
                              readOnly: true,
                              onTap: _selectDate,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'By continuing, you agree to\nTerms of Use and Privacy Policy.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isDark 
                                    ? AppTheme.darkTextSecondary 
                                    : AppTheme.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 20),
                            authProvider.isLoading
                                ? CircularProgressIndicator(
                                    color: isDark 
                                        ? AppTheme.darkPrimary 
                                        : AppTheme.primary,
                                  )
                                : CustomButton(
                                    text: '    Sign Up    ',
                                    onPressed: _handleSignUp, 
                                  ),
                            const SizedBox(height: 15),
                            Text(
                              'or',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark 
                                    ? AppTheme.darkTextHint 
                                    : Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 15),
                            if (!authProvider.isLoading)
                              GestureDetector(
                                onTap: () async {
                                  try {
                                    final success = await authProvider.googleSignIn();
                                    if (success) {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(builder: (_) => const BottomNavigator()),
                                      );
                                    }
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(e.toString())),
                                    );
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isDark 
                                        ? AppTheme.darkSurface 
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isDark 
                                          ? AppTheme.darkSurface 
                                          : AppTheme.darkSurface,
                                    ),
                                  ),
                                  child: Image.asset(
                                    'assets/Google_Logo/google-logo.png', 
                                    height: 40,
                                  ),
                                ),
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
}
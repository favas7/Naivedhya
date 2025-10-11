// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:naivedhya/Views/admin/admin_dashboard/admin_dashboard.dart';
import 'package:naivedhya/Views/bottom_navigator/bottom_navigator.dart';
import 'package:naivedhya/utils/color_theme.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../utils/widgets/custom_button.dart';
import '../../../utils/widgets/custom_text_field.dart';
import '../../../utils/validator.dart';
import '../sign_up/signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String _topText = 'Log In';

  @override
  void initState() {
    super.initState();
    // Change text after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _topText = 'Hello';
        });
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      try {
        final result = await Provider.of<AuthProvider>(context, listen: false)
            .login(_emailController.text, _passwordController.text);
        
        print('Login result: $result');
        
        if (result['success']) {
          final userType = result['usertype'];
          
          if (userType == 'admin') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
            ); 
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const BottomNavigator()),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login failed. Please try again.')),
          );
        }
      } catch (e) {
        print('Caught error in _login: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  void _forgotPassword() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email address')),
      );
      return;
    }

    try {
      await Provider.of<AuthProvider>(context, listen: false)
          .sendPasswordResetEmail(_emailController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset email sent')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Column(
          children: [
            // Top Header Container
            Container(
              height: 0.3.sh,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark 
                    ? [
                        AppTheme.darkPrimary,
                        AppTheme.darkPrimaryDark,
                      ]
                    : [
                        AppTheme.background,
                        AppTheme.primary.withOpacity(0.8),
                      ],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios,
                          color: isDark ? Colors.white : Colors.white,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      Expanded(
                        child: Center(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            child: Text(
                              _topText,
                              key: ValueKey(_topText),
                              style: theme.textTheme.displaySmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 48.w),
                    ],
                  ),
                ),
              ),
            ),
            
            // Main Content Container
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25.r),
                    topRight: Radius.circular(25.r),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.shadow,
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20.r),
                  child: Form(
                    key: _formKey,
                    child: Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(height: 20.h),
                            
                            // Welcome Text
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '  Welcome',
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onBackground,
                                ),
                              ),
                            ),
                            
                            SizedBox(height: 30.h),
                            
                            // Email Field
                            CustomTextField(
                              label: 'Email',
                              controller: _emailController,
                              validator: Validator.validateEmail,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            
                            SizedBox(height: 20.h),
                            
                            // Password Field
                            CustomTextField(
                              label: 'Password',
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              validator: Validator.validatePassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword 
                                    ? Icons.visibility_off 
                                    : Icons.visibility,
                                  color: theme.colorScheme.primary,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            
                            SizedBox(height: 10.h),
                            
                            // Forgot Password
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: _forgotPassword,
                                child: Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            
                            SizedBox(height: 20.h),
                            
                            // Login Button
                            authProvider.isLoading
                              ? Center(
                                  child: CircularProgressIndicator(
                                    color: theme.colorScheme.primary,
                                  ),
                                )
                              : CustomButton(
                                  text: 'Log In',
                                  onPressed: _login,
                                ),
                            
                            SizedBox(height: 20.h),
                            
                            // Divider with "or"
                            Row(
                              children: [
                                Expanded(
                                  child: Divider(
                                    color: theme.dividerTheme.color,
                                    thickness: 1,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                                  child: Text(
                                    'or',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: theme.dividerTheme.color,
                                    thickness: 1,
                                  ),
                                ),
                              ],
                            ),
                            
                            SizedBox(height: 20.h),
                            
                            // Google Sign In
                            if (!authProvider.isLoading)
                              GestureDetector(
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
                                  padding: EdgeInsets.all(12.r),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surface,
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: Border.all(
                                      color: theme.colorScheme.outline,
                                      width: 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: theme.colorScheme.shadow,
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/Google_Logo/google-logo.png',
                                        height: 24.h,
                                      ),
                                      SizedBox(width: 12.w),
                                      Text(
                                        'Continue with Google',
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            
                            SizedBox(height: 20.h),
                            
                            // Sign Up Link
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Don't have an account? ",
                                  style: theme.textTheme.bodyMedium,
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const SignUpScreen(),
                                      ),
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    'Sign Up',
                                    style: TextStyle(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            
                            SizedBox(height: 20.h),
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
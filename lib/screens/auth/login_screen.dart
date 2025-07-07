import 'package:flutter/material.dart';
import 'package:naivedhya/bottom_navigator/bottom_navigator.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../utils/validator.dart';
import 'signup_screen.dart';

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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      try {
            final success = await Provider.of<AuthProvider>(context, listen: false)
                  .login(_emailController.text, _passwordController.text);
              print('Login success: $success, user: ');
              if (success) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const BottomNavigator()),
                );
              }
          } catch (e) {
            print('Caught error in _login: $e'); // Add this
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
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: screenHeight * 0.3,
            color: AppColors.background,
          ),
          Expanded(
            child: Container(
              color: AppColors.white,
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomTextField(
                          label: 'Email',
                          controller: _emailController,
                          validator: Validator.validateEmail,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 20),
                        CustomTextField(
                          label: 'Password',
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          validator: Validator.validatePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _forgotPassword,
                            child: const Text('Forgot Password?'),
                          ),
                        ),
                        const SizedBox(height: 20),
                        authProvider.isLoading
                            ? const CircularProgressIndicator()
                            : CustomButton(
                                text: 'Log In',
                                onPressed: _login,
                              ),
                        const SizedBox(height: 20),
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
                            child: Image.asset('assets/Google_Logo/google-logo.png', height: 40),
                          ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Don't have an account? "),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const SignUpScreen()),
                                );
                              },
                              child: const Text('Sign Up'),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
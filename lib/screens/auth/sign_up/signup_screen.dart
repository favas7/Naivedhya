// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:naivedhya/screens/bottom_navigator/bottom_navigator.dart';
import 'package:provider/provider.dart';
import 'package:naivedhya/utils/constants/colors.dart';
import '../../../models/user_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../utils/validator.dart';
import 'set_password_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
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
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
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
    final screenHeight = MediaQuery.of(context).size.height;
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
              color: AppColors.background,
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
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.only(
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
                            const Text(
                              'By continuing, you agree to\nTerms of Use and Privacy Policy.',
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            authProvider.isLoading
                                ? const CircularProgressIndicator()
                                : CustomButton(
                                    text: '    Sign Up    ',
                                    onPressed: _handleSignUp, 
                                  ),
                            const SizedBox(height: 15),
                            const Text(
                              'or',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
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
                                child: Image.asset('assets/Google_Logo/google-logo.png', height: 40),
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
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:naivedhya/bottom_navigator/bottom_navigator.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../utils/validator.dart';
import 'set_password_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();
  bool _isLoading = false;

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
      setState(() {
        _isLoading = true;
      });
      try {
        final user = UserModel(
          userId: DateTime.now().millisecondsSinceEpoch.toString(),
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          dob: _dobController.text,
          address: '',
          pendingPayments: 0.0,
          orderHistory: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          userType: 'user',
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
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
                  _isLoading
                      ? const CircularProgressIndicator()
                      : CustomButton(
                          text: 'Sign Up',
                          onPressed: _handleSignUp,
                        ),
                  const SizedBox(height: 20),
                  const Text('or sign up with'),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () async {
                      setState(() {
                        _isLoading = true;
                      });
                      try {
                        final success = await Provider.of<AuthProvider>(context, listen: false).googleSignIn();
                        if (success) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const BottomNavigator()),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Google Sign-In failed')),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Google Sign-In error: $e')),
                        );
                      } finally {
                        setState(() {
                          _isLoading = false;
                        });
                      }
                    },
                    child: Image.asset('assets/Naivedhya_Logo/naivedhya_logo.png', height: 40),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
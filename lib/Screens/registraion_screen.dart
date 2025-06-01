import 'package:emotifai/Screens/HomeScreen/home_screen.dart';
import 'package:emotifai/Widgets/input_field.dart';
import 'package:emotifai/Widgets/snack_bar.dart';
import 'package:emotifai/auth_service.dart';
import 'package:emotifai/google_login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final AuthService _auth = AuthService();

  String? _emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  String? _confirmPasswordValidator(String? value) {
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  void _handleRegistration() async {
    if (_formKey.currentState!.validate()) {
      await _auth.registerWithEmail(
        context,
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _usernameController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(top: 20.0, left: 13.0),
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 58),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Register',
                          style: GoogleFonts.lato(
                            color: Color(0xFFFFFFFF).withOpacity(0.87),
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 26),
                        InputField(
                          controller: _emailController,
                          label: 'Email',
                          hintText: 'abc@google.com',
                          validator: _emailValidator,
                        ),
                        SizedBox(height: 26),
                        InputField(
                          controller: _usernameController,
                          label: 'Username',
                          hintText: 'Enter your username',
                        ),
                        SizedBox(height: 25),
                        InputField(
                          isObscureText: true,
                          controller: _passwordController,
                          validator: _passwordValidator,
                          label: 'Password',
                          hintText: '••••••••',
                        ),
                        SizedBox(height: 25),
                        InputField(
                          isObscureText: true,
                          controller: _confirmPasswordController,
                          validator: _confirmPasswordValidator,
                          label: 'Confirm Password',
                          hintText: '••••••••',
                        ),
                        SizedBox(height: 69),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: FilledButton(
                            onPressed: () {
                              _handleRegistration();
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.white, // White background
                              padding: EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                                // Sharp corners
                              ),
                            ),
                            child: Text(
                              'Register',
                              style: GoogleFonts.lato(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            ), // Black text
                          ),
                        ),
                        SizedBox(height: 31),
                        Row(
                          children: [
                            Expanded(child: Divider(color: Colors.white24)),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                              ),
                              child: Text(
                                'or',
                                style: TextStyle(color: Colors.white54),
                              ),
                            ),
                            Expanded(child: Divider(color: Colors.white24)),
                          ],
                        ),
                        SizedBox(height: 29),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton(
                            onPressed: () async {
                              try {
                                final userCredential = await signInWithGoogle();
                                if (userCredential != null) {
                                  await Future.delayed(
                                    const Duration(milliseconds: 300),
                                  );
                                  Navigator.pushReplacement(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (_, __, ___) => HomeScreen(),
                                      transitionsBuilder:
                                          (_, animation, __, child) {
                                            return FadeTransition(
                                              opacity: animation,
                                              child: child,
                                            );
                                          },
                                    ),
                                  );
                                } else {
                                  // User cancelled sign-in
                                  showCustomSnackBar(
                                    context,
                                    message: 'Google sign-in was cancelled.',
                                    icon: Icons.info_outline,
                                    backgroundColor: Colors.orange,
                                  );
                                }
                              } catch (e) {
                                // Handle error
                                showCustomSnackBar(
                                  context,
                                  message: 'Sign-in failed. Please try again.',
                                  icon: Icons.error_outline,
                                  backgroundColor: Colors.redAccent,
                                );
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              splashFactory: InkRipple.splashFactory,
                              overlayColor: Colors.white.withOpacity(0.2),
                              side: BorderSide(color: Colors.white, width: 1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset('assets/images/google.svg'),
                                SizedBox(width: 10),
                                Text(
                                  'Sign in with Google',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.lato(
                                    color: Color(0xFFFFFFFF),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account?',
                      style: GoogleFonts.lato(
                        color: Color(0xFF979797),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.only(left: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Login',
                        style: GoogleFonts.rubik(
                          fontSize: 12,
                          color: Color(0xFFFFFFFF).withOpacity(0.87),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

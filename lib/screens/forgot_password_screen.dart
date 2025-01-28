import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import '../constants/app_colors.dart';
import 'dart:math';
import './setting_forpwd.dart';  

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;
  bool _otpSent = false;
  String? _generatedOTP;
  String? _userId;
  String? _userEmail;

  @override
  void dispose() {
    _userIdController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  String _generateOTP() {
    Random random = Random();
    return List.generate(6, (_) => random.nextInt(10)).join();
  }

  Future<void> _sendEmailOTP(String email, String otp) async {
    String username = 'code2surf@gmail.com';
    String password = 'thxc hedu gbql wlyy'; 

    try {
      print('Setting up SMTP server...'); // Debug line
      final smtpServer = SmtpServer(
        'smtp.gmail.com',
        port: 587,
        username: username,
        password: password,
        ssl: false,
        allowInsecure: true,
      );
      
      print('Creating email message...'); // Debug line
      final message = Message()
        ..from = Address(username, 'SMA Support')
        ..recipients.add(email)
        ..subject = 'Password Reset OTP'
        ..text = 'Your OTP for password reset is: $otp\n\nThis OTP will expire in 10 minutes.\n\nIf you did not request this password reset, please ignore this email.';

      try {
        print('Attempting to send email to: $email'); // Debug line
        final sendReport = await send(message, smtpServer);
        print('Message sent successfully! Send report: ${sendReport.toString()}'); // Debug line
      } catch (e) {
        print('SMTP Error Details: $e'); // Detailed error
        throw Exception('Failed to send email. Please check your internet connection and try again.');
      }
    } catch (e) {
      print('Email Configuration Error Details: $e'); // Detailed error
      throw Exception('Email service configuration error. Please try again later.');
    }
  }

  Future<void> _sendOTP() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      print('Starting OTP send process...'); // Debug line
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('User')
          .where('user_id', isEqualTo: _userIdController.text.trim())
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No account found with this User ID')),
        );
        return;
      }

      _userEmail = _userIdController.text.trim();
      print('User email from ID: $_userEmail'); // Debug line

      if (_userEmail == null || !_userEmail!.contains('@')) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid email format for this account')),
        );
        return;
      }

      _generatedOTP = _generateOTP();
      _userId = _userIdController.text.trim();
      print('Generated OTP: $_generatedOTP for user: $_userId'); // Debug line

      try {
        print('Initiating email sending...'); // Debug line
        await _sendEmailOTP(_userEmail!, _generatedOTP!);
        print('Email sent successfully'); // Debug line
        
        if (!mounted) return;
        setState(() {
          _otpSent = true;
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('OTP sent to ${_userEmail!.replaceRange(3, _userEmail!.indexOf("@"), "**")}')),
        );
      } catch (emailError) {
        print('Email sending error details: $emailError'); // Debug line
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send email: ${emailError.toString()}')),
        );
      }
    } catch (e) {
      print('General error details: $e'); // Debug line
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send OTP. Please try again.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _verifyOTPAndUpdatePassword() async {
    if (!_formKey.currentState!.validate()) return;

    if (_otpController.text != _generatedOTP) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid OTP. Please try again.')),
      );
      return;
    }

    // Navigate to ChangePasswordPage
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ChangePasswordPage(userId: _userId!),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: AppColors.textDark,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hintText,
            border: const OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'This field is required';
            }
            return null;
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Verify OTP',
          style: GoogleFonts.inter(
            color: AppColors.textDark,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Forgot Password',
                style: GoogleFonts.inter(
                  color: AppColors.textDark,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _otpSent
                    ? 'Enter the OTP sent to ${_userEmail!.replaceRange(3, _userEmail!.indexOf("@"), "**")}'
                    : 'Enter your User ID to receive an OTP',
                style: GoogleFonts.inter(
                  color: AppColors.textLight,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              _buildTextField(
                label: 'User ID',
                controller: _userIdController,
                hintText: 'Enter your User ID',
              ),
              if (_otpSent) ...[
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'OTP',
                  controller: _otpController,
                  hintText: 'Enter OTP',
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : _otpSent
                          ? _verifyOTPAndUpdatePassword
                          : _sendOTP,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : Text(
                          _otpSent ? 'Verify OTP' : 'Send OTP',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/models/user_model.dart';
import 'package:flutter_application_1/screens/dashboard_screen.dart';
import 'package:flutter_application_1/screens/forgot_password_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui'; // 

TextEditingController emailController = TextEditingController();
TextEditingController passwordController = TextEditingController();
bool hidePassword = true;

class LoginPageMobile extends StatefulWidget {
  const LoginPageMobile({super.key});

  @override
  State<LoginPageMobile> createState() => _LoginPageMobileState();
}

class _LoginPageMobileState extends State<LoginPageMobile> {
  late TextEditingController emailController;
  late TextEditingController passwordController;
  bool hidePassword = true;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenSize = mediaQuery.size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;
    final bottomInset = mediaQuery.viewInsets.bottom;
    final isKeyboardVisible = bottomInset > 0;

    return Scaffold(
      backgroundColor: Colors.amber,
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: screenHeight,
          ),
          child: IntrinsicHeight(
            child: Column(
              children: [
                Container(
                  height: isKeyboardVisible ? screenHeight * 0.15 : screenHeight * 0.4,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.yellow[100],
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40),
                      ),
                    ),
                    child: Stack(
                      children: [
                        if (!isKeyboardVisible)
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              bottomRight: Radius.circular(60),
                            ),
                            child: Image.asset(
                              'assets/images/bg1.jpg',
                              width: screenWidth,
                              height: screenHeight * 0.4,
                              fit: BoxFit.cover,
                            ),
                          ),
                        if (!isKeyboardVisible)
                          Positioned.fill(
                            child: Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                  child: Container(
                                    width: screenWidth * 0.85,
                                    height: screenHeight * 0.35,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.5),
                                        width: 1,
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.all(screenWidth * 0.02),
                                          child: Text(
                                            'Experience an all-in-one solution\nfor managing school operations\neffortlessly',
                                            style: GoogleFonts.roboto(
                                              fontSize: screenWidth * 0.035,
                                              fontWeight: FontWeight.w700,
                                              color: const Color.fromARGB(255, 229, 15, 0).withOpacity(0.7),
                                            ),
                                          ),
                                        ),
                                        CarouselSlider(
                                          items: [
                                            Image.asset(
                                              'assets/images/ss1.jpg',
                                              width: screenWidth * 0.8,
                                              height: screenHeight * 0.2,
                                              fit: BoxFit.cover,
                                            ),
                                            Image.asset(
                                              'assets/images/ss1.jpg',
                                              width: screenWidth * 0.8,
                                              height: screenHeight * 0.2,
                                              fit: BoxFit.cover,
                                            ),
                                            Image.asset(
                                              'assets/images/ss1.jpg',
                                              width: screenWidth * 0.8,
                                              height: screenHeight * 0.2,
                                              fit: BoxFit.cover,
                                            ),
                                          ],
                                          options: CarouselOptions(
                                            height: screenHeight * 0.2,
                                            autoPlay: true,
                                            enlargeCenterPage: true,
                                            onPageChanged: (index, reason) {
                                              setState(() {
                                                _currentIndex = index;
                                              });
                                            },
                                            viewportFraction: 1.0,
                                            enableInfiniteScroll: true,
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: List.generate(
                                            3,
                                            (index) => Container(
                                              margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
                                              width: screenWidth * 0.02,
                                              height: screenWidth * 0.02,
                                              decoration: BoxDecoration(
                                                color: _currentIndex == index ? Colors.orange : Colors.grey,
                                                shape: BoxShape.circle,
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
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.yellow[50],
                    ),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        screenWidth * 0.05,
                        screenWidth * 0.05,
                        screenWidth * 0.05,
                        bottomInset + screenWidth * 0.05,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Email Id:',
                            style: GoogleFonts.lato(
                              fontSize: screenWidth * 0.04,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          Container(
                            height: screenHeight * 0.07,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: emailController,
                              style: GoogleFonts.lato(fontSize: screenWidth * 0.04),
                              decoration: InputDecoration(
                                hintText: 'Enter your email',
                                hintStyle: GoogleFonts.lato(
                                  color: Colors.grey,
                                  fontSize: screenWidth * 0.04,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.05,
                                  vertical: screenWidth * 0.04,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          Text(
                            'Password',
                            style: GoogleFonts.lato(
                              fontSize: screenWidth * 0.04,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          Container(
                            height: screenHeight * 0.07,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: passwordController,
                              obscureText: hidePassword,
                              style: GoogleFonts.lato(fontSize: screenWidth * 0.04),
                              decoration: InputDecoration(
                                hintText: 'Enter your password',
                                hintStyle: GoogleFonts.lato(
                                  color: Colors.grey,
                                  fontSize: screenWidth * 0.04,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.05,
                                  vertical: screenWidth * 0.04,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    hidePassword ? Icons.visibility_off : Icons.visibility,
                                    color: Colors.grey,
                                    size: screenWidth * 0.05,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      hidePassword = !hidePassword;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ForgotPasswordScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                'Forgot Password?',
                                style: GoogleFonts.lato(
                                  color: Colors.deepOrange,
                                  fontSize: screenWidth * 0.04,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          SizedBox(
                            width: double.infinity,
                            height: screenHeight * 0.06,
                            child: ElevatedButton(
                              onPressed: () => _login(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(255, 230, 211, 3),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                'Login',
                                style: GoogleFonts.lato(
                                  color: Colors.white,
                                  fontSize: screenWidth * 0.04,
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _login(BuildContext context) async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    try {
      var userDoc = await FirebaseFirestore.instance
          .collection('User')
          .where('user_id', isEqualTo: email)
          .get();

      if (!mounted) return; // Check if the widget is still mounted

      if (userDoc.docs.isEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('User not found')));
        return;
      }

      var userData = userDoc.docs.first.data();

      if (userData['user_password'] != password) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Incorrect password')));
        return;
      }

      UserModel user = UserModel.fromMap(userData);

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Login successful')));

      if (!mounted) return; // Check again before navigating

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DashboardScreen(user: user)),
      );
    } catch (e) {
      if (!mounted) return; // Prevent error reporting if the widget is unmounted
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}

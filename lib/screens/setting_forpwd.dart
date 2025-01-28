import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key, required String userId});

  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(MediaQuery.of(context).size.height * 0.08),
        child: AppBar(
          title: Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.003),
            child: Text(
              'Change Password',
              style: GoogleFonts.roboto(
                fontSize: MediaQuery.of(context).size.width * 0.052,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Container(
            margin: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
            ),
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_outlined,
                color: Color.fromARGB(197, 82, 101, 71),
                size: MediaQuery.of(context).size.width * 0.05,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          actions: [
            Container(
              margin: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.more_horiz_sharp,
                  color: Color.fromARGB(197, 82, 101, 71),
                  size: MediaQuery.of(context).size.width * 0.05,
                ),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            left: MediaQuery.of(context).size.width * 0.04,
            right: MediaQuery.of(context).size.width * 0.04,
            top: MediaQuery.of(context).size.width * 0.04,
            bottom: MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).size.width * 0.04,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  // Current Password Field
                  Text(
                    'Current Password',
                    style: GoogleFonts.cabin(
                      fontSize: MediaQuery.of(context).size.width * 0.042,
                      fontWeight: FontWeight.w500
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.085,
                    child: TextField(
                      obscureText: _obscureCurrentPassword,
                      decoration: InputDecoration(
                        hintText: 'Current Password',
                        hintStyle: GoogleFonts.cabin(
                          color: Colors.black.withOpacity(0.2),
                          fontSize: MediaQuery.of(context).size.width * 0.04,
                        ),
                        prefixIcon: Icon(
                          Icons.lock,
                          color: Colors.black.withOpacity(0.2),
                          size: MediaQuery.of(context).size.width * 0.05,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureCurrentPassword ? Icons.visibility_off : Icons.visibility,
                            color: const Color.fromARGB(255, 161, 161, 161).withOpacity(0.2),
                            size: MediaQuery.of(context).size.width * 0.05,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureCurrentPassword = !_obscureCurrentPassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(13),
                          borderSide: BorderSide(color: Colors.grey.withOpacity(0.1)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(13),
                          borderSide: BorderSide(color: Colors.grey.withOpacity(0.1)),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.035),

                  // New Password Field
                  Text(
                    'New Password',
                    style: GoogleFonts.cabin(
                      fontSize: MediaQuery.of(context).size.width * 0.042,
                      fontWeight: FontWeight.w500
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.085,
                    child: TextField(
                      obscureText: _obscureNewPassword,
                      decoration: InputDecoration(
                        hintText: 'New Password',
                        hintStyle: GoogleFonts.cabin(
                          color: Colors.black.withOpacity(0.2),
                          fontSize: MediaQuery.of(context).size.width * 0.04,
                        ),
                        prefixIcon: Icon(
                          Icons.lock,
                          color: Colors.black.withOpacity(0.2),
                          size: MediaQuery.of(context).size.width * 0.05,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureNewPassword ? Icons.visibility_off : Icons.visibility,
                            color: const Color.fromARGB(255, 161, 161, 161).withOpacity(0.2),
                            size: MediaQuery.of(context).size.width * 0.05,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureNewPassword = !_obscureNewPassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(13),
                          borderSide: BorderSide(color: Colors.grey.withOpacity(0.1)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(13),
                          borderSide: BorderSide(color: Colors.grey.withOpacity(0.1)),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.035),

                  // Confirm Password Field
                  Text(
                    'Confirm Password',
                    style: GoogleFonts.cabin(
                      fontSize: MediaQuery.of(context).size.width * 0.042,
                      fontWeight: FontWeight.w500
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.085,
                    child: TextField(
                      obscureText: _obscureConfirmPassword,
                      decoration: InputDecoration(
                        hintText: 'Confirm Password',
                        hintStyle: GoogleFonts.cabin(
                          color: Colors.black.withOpacity(0.2),
                          fontSize: MediaQuery.of(context).size.width * 0.04,
                        ),
                        prefixIcon: Icon(
                          Icons.lock,
                          color: Colors.black.withOpacity(0.2),
                          size: MediaQuery.of(context).size.width * 0.05,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                            color: const Color.fromARGB(255, 161, 161, 161).withOpacity(0.2),
                            size: MediaQuery.of(context).size.width * 0.05,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(13),
                          borderSide: BorderSide(color: Colors.grey.withOpacity(0.1)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(13),
                          borderSide: BorderSide(color: Colors.grey.withOpacity(0.1)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.06),
              SizedBox(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.065,
                child: ElevatedButton(
                  onPressed: () {
                    // Add logic to handle password change
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 254, 197, 27),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: MediaQuery.of(context).size.height * 0.02
                    ),
                  ),
                  child: Text(
                    'Save New Password',
                    style: GoogleFonts.cabin(fontSize: MediaQuery.of(context).size.width * 0.04, color: Colors.black, fontWeight: FontWeight.w600),
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

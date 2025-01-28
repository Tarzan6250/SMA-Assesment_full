import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/user_model.dart';
import 'package:flutter_application_1/screens/dashboard_screen.dart';
import 'package:flutter_application_1/screens/setting_forpwd.dart';
import 'package:flutter_application_1/screens/settings_faq.dart';
import 'package:flutter_application_1/screens/settings_priandpol.dart';
import 'package:flutter_application_1/widgets/login_form.dart';
import 'package:google_fonts/google_fonts.dart';



class CustomIconContainer extends StatelessWidget {
  final IconData? icon;
  final String? imagePath; // Path to the image

  const CustomIconContainer({super.key, this.icon, this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.11,
      height: MediaQuery.of(context).size.width * 0.11,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 241, 232).withOpacity(1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: imagePath != null
            ? Image.asset(
                imagePath!,
                width: MediaQuery.of(context).size.width * 0.06,
                height: MediaQuery.of(context).size.width * 0.06
              )
            : Icon(
                icon,
                size: MediaQuery.of(context).size.width * 0.06,
                color: Colors.amber.withOpacity(0.8)
              ),
      ),
    );
  }
}

class SettingsPage extends StatefulWidget {
    final UserModel user;

  const SettingsPage({super.key, required this.user});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isAppNotificationOn = true;
  bool isDarkModeOn = false;
  bool cond = false;
  @override
  @override
  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height * 0.075,
        title: Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).size.height * 0.006,
            left: MediaQuery.of(context).size.width * 0.025
          ),
          child: Text(
            'Settings',
            style: GoogleFonts.cabin(
              fontSize: MediaQuery.of(context).size.width * 0.05,
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
              icon: const Icon(
                Icons.arrow_back_ios_new_outlined,
                color: Color.fromARGB(197, 82, 101, 71),
                size: 20,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DashboardScreen(user: widget.user)),
                );
              }),
        ),
        actions: [
          Container(
            margin: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.more_horiz_sharp,
                color: Color.fromARGB(197, 82, 101, 71),
              ),
              onPressed: () {},
            ),
          ),
        ],
      ),
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05, vertical: MediaQuery.of(context).size.height * 0.015),
            child: ListView(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.03,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.03),
                  child: Text(
                    'About',
                    style: GoogleFonts.cabin(
                        fontSize: MediaQuery.of(context).size.width * 0.04,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                ListTile(
                  leading: const CustomIconContainer(icon: Icons.lock_outline),
                  title: Text(
                    'Change Password',
                    style: GoogleFonts.cabin(
                      color: Colors.black,
                      fontSize: MediaQuery.of(context).size.width * 0.042
                    )
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: MediaQuery.of(context).size.width * 0.03
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ChangePasswordPage(userId: ' ',)),
                    );
                  },
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.025),
                ListTile(
                  leading: const CustomIconContainer(icon: Icons.help_outline),
                  title: Text(
                    'FAQ',
                    style: GoogleFonts.cabin(
                      color: Colors.black,
                      fontSize: MediaQuery.of(context).size.width * 0.042
                    )
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: MediaQuery.of(context).size.width * 0.03
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FAQPage()),
                    );
                  },
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.025),
                ListTile(
                  leading: const CustomIconContainer(
                      imagePath: 'assets/images/icon_tick.png'),
                  title: Text(
                    'Privacy & Policy',
                    style: GoogleFonts.cabin(
                      color: Colors.black,
                      fontSize: MediaQuery.of(context).size.width * 0.042
                    )
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: MediaQuery.of(context).size.width * 0.03
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PrivacyPolicyPage()),
                    );
                  },
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                Text(
                  'Notification',
                  style: GoogleFonts.cabin(
                    fontSize: MediaQuery.of(context).size.width * 0.04,
                    fontWeight: FontWeight.bold,
                    color: Colors.black
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                SwitchListTile(
                  secondary: const CustomIconContainer(
                      icon: Icons.notifications_outlined),
                  title: Text(
                    'App Notification',
                    style: GoogleFonts.cabin(
                      color: Colors.black,
                      fontSize: MediaQuery.of(context).size.width * 0.04,
                      fontWeight: FontWeight.w500
                    )
                  ),
                  value: isAppNotificationOn,
                  onChanged: (value) {
                    setState(() {
                      isAppNotificationOn = value;
                    });
                  },
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                SwitchListTile(
                  secondary:
                      const CustomIconContainer(icon: Icons.dark_mode_outlined),
                  title: Text(
                    'Dark Mode',
                    style: GoogleFonts.cabin(
                      color: Colors.black,
                      fontSize: MediaQuery.of(context).size.width * 0.04,
                      fontWeight: FontWeight.w500
                    )
                  ),
                  value: isDarkModeOn,
                  onChanged: (value) {
                    setState(() {
                      isDarkModeOn = value;
                    });
                  },
                ),
              ],
            ),
          ),
          Positioned(
            left: MediaQuery.of(context).size.width * 0.04,
            right: MediaQuery.of(context).size.width * 0.04,
            bottom: MediaQuery.of(context).size.height * 0.03, // Adjust this value for vertical positioning
            child: ListTile(
              leading: Container(
                width: MediaQuery.of(context).size.width * 0.11,
                height: MediaQuery.of(context).size.width * 0.11,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: const Color.fromARGB(255, 241, 93, 83)
                      .withOpacity(0.1), // Light red background
                ),
                child: Center(
                  child: Image.asset(
                    'assets/images/login.jpg',
                    width: MediaQuery.of(context).size.width * 0.06,
                    height: MediaQuery.of(context).size.width * 0.06,
                    color: const Color.fromARGB(255, 192, 28, 28), // Red icon
                  ),
                ),
              ),
              title: Text(
                'Logout',
                style: GoogleFonts.cabin(
                    color: Colors.black,
                    fontSize: MediaQuery.of(context).size.width * 0.04,
                    fontWeight: FontWeight.w500),
              ),
              onTap: () {
                showModalBottomSheet(
                  backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(2)),
                  ),
                  isScrollControlled: true,
                  builder: (BuildContext context) {
                    return Container(
                      height: MediaQuery.of(context).size.height * 0.5,
                      padding: const EdgeInsets.all(30),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/images/logoutimg.png',
                            width: MediaQuery.of(context).size.width * 0.4,
                            height: MediaQuery.of(context).size.height * 0.175,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Sign out',
                            style: GoogleFonts.cabin(
                                fontSize: MediaQuery.of(context).size.width * 0.045, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Are you sure you would like to sign out of your account?',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.cabin(
                                color: Colors.grey,
                                fontSize: MediaQuery.of(context).size.width * 0.035,
                                fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 40),
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: MediaQuery.of(context).size.height * 0.065,
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    style: TextButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(
                                          255, 255, 202, 45),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Text(
                                      'Cancel',
                                      style: GoogleFonts.cabin(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500,
                                          fontSize: MediaQuery.of(context).size.width * 0.045),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: SizedBox(
                                  height: MediaQuery.of(context).size.height * 0.065,
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (context) => LoginPageMobile(key: UniqueKey())),
);
                                    },
                                    style: TextButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      side: const BorderSide(
                                          color: Colors.amber, width: 1.5),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Text(
                                      'Logout',
                                      style: GoogleFonts.cabin(
                                          color: Colors.amber,
                                          fontSize: MediaQuery.of(context).size.width * 0.04,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

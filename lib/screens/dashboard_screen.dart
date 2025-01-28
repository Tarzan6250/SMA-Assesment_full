// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/my_courses.dart';
import 'package:flutter_application_1/screens/notification_screen.dart';
import 'package:flutter_application_1/screens/play_courses.dart';
import 'package:flutter_application_1/screens/profile_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user_model.dart';
import 'favourites_screen.dart';
import 'setting.dart';

class DashboardScreen extends StatefulWidget {
  final UserModel user;

  const DashboardScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      _buildMainDashboard(),
      FavouritesScreen(user : widget.user),
      MyCourses(user : widget.user),
      SettingsPage(user : widget.user),
    ];
  }

  Widget _buildMainDashboard() {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Dark container for welcome and courses
            Container(
              padding: const EdgeInsets.only(top: 48, bottom: 42),
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/background.png'),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.zero,
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      children: [
                        // Header with profile
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProfileScreen(user: widget.user),
                                  ),
                                );
                              },
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundImage: widget.user.photoUrl != null
                                        ? NetworkImage(widget.user.photoUrl!)
                                        : const AssetImage('assets/images/user.png') as ImageProvider,
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Welcome Back!',
                                        style: GoogleFonts.inter(
                                          color: Colors.grey,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            widget.user.userName,
                                            style: GoogleFonts.inter(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Stack(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.notifications_outlined,
                                    size: 30,
                                  ),
                                  color: Colors.white,
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              NotificationScreen()),
                                    );
                                  },
                                ),
                                Positioned(
                                  right: 8,
                                  top: 8,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(0),
                                    ),
                                    child: Text(
                                      '9+',
                                      style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Courses for you section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Courses for you',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.arrow_forward),
                              color: Colors.white,
                              iconSize: 24,
                              onPressed: () {
                                setState(() {
          _selectedIndex = 2; // Set the index for the "Courses" page
        }
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // White container for continue learning and my courses
            Container(
              color: const Color.fromARGB(255, 245, 245, 245),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Continue Learning section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Continue Learning',
                        style: GoogleFonts.inter(
                          color: Colors.black87,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.more_horiz_rounded,
                          color: Colors.black87,
                          size: 24,
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  Container(
                    height: 170,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color.fromARGB(255, 255, 227, 151),
                          Color.fromARGB(255, 245, 245, 245),
                        ],
                        begin: Alignment.centerRight,
                        end: Alignment.centerLeft,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Playcourses(user: widget.user),
                            ),
                          );
                        },
                    child: Column(
                      children: [
                        Container(
                          height: 65,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(27),
                              topRight: Radius.circular(27),
                            ),
                            image: DecorationImage(
                              image:
                                  AssetImage('assets/images/course_image.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.more_horiz),
                                  color: Colors.white,
                                  iconSize: 24,
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Playcourses(user : widget.user)),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Bottom portion with content
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Science : Microbiology',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const CircleAvatar(
                                      radius: 10,
                                      backgroundImage: NetworkImage(
                                          'assets/images/user.png'),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Azamat Baimatov',
                                      style: GoogleFonts.inter(
                                        color: const Color.fromARGB(
                                            221, 124, 124, 124),
                                        fontSize: 9,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 32),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.star_rounded,
                                          color:
                                              Color.fromARGB(221, 255, 196, 0),
                                          size: 18,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '4.9',
                                          style: GoogleFonts.inter(
                                            color: const Color.fromARGB(
                                                221, 109, 109, 109),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          ' (1,435 Reviews)',
                                          style: GoogleFonts.inter(
                                            color: const Color.fromARGB(
                                                221, 132, 132, 132),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      constraints: const BoxConstraints(
                                        maxWidth: 27,
                                        maxHeight: 27,
                                      ),
                                      child: Image.asset(
                                        'assets/icons/play_icon.png',
                                        width: 21,
                                        height: 21,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Sessions 7/15',
                                      style: GoogleFonts.inter(
                                        fontSize: 10,
                                        color: Colors.black54,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const Spacer(),
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: 15,
                                          height: 15,
                                          child: CircularProgressIndicator(
                                            value: 0.82,
                                            backgroundColor: Colors.grey[200],
                                            valueColor:
                                                const AlwaysStoppedAnimation<
                                                    Color>(
                                              Color.fromARGB(255, 246, 187, 26),
                                            ),
                                            strokeWidth: 2.5,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '82%',
                                          style: GoogleFonts.inter(
                                            color: const Color.fromARGB(
                                                255, 255, 194, 25),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),),
                  const SizedBox(height: 32),

                  // My Courses section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'My Courses',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
          _selectedIndex = 2; // Set the index for the "Courses" page
        });
                        },
                        child: Row(
                          children: [
                            Text(
                              'See all',
                              style: GoogleFonts.inter(
                                color: Colors.grey[600],
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.grey[600],
                              size: 14,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildCourseCard(
                          'GRAPHICS DESIGN',
                          'How to make modern poster for...',
                          const Color(0xFFE8F5E9),
                          Icons.brush_outlined,
                        ),
                        const SizedBox(width: 16),
                        _buildCourseCard(
                          'UI/UX DESIGN',
                          'How to make design system in easy...',
                          const Color(0xFFE3F2FD),
                          Icons.design_services_outlined,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.blue : Colors.grey,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.blue : Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(
    String title,
    String description,
    Color backgroundColor,
    IconData iconData,
  ) {
    return Container(
      width: 220,
      constraints: const BoxConstraints(
        minHeight: 140,
        maxHeight: 160,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        image: title == "CONTINUE LEARNING"
            ? null
            : DecorationImage(
                image: AssetImage(
                  title == 'GRAPHICS DESIGN'
                      ? 'assets/images/hex_pattern.png'
                      : 'assets/images/hex_pattern.png',
                ),
                fit: BoxFit.cover,
                opacity: 0.04,
                colorFilter: ColorFilter.mode(
                  backgroundColor.withOpacity(0.1),
                  BlendMode.overlay,
                ),
              ),
        gradient: title == "CONTINUE LEARNING"
            ? const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0xFFFFD700), // Bright yellow
                  Color(0xFFFF6B00), // Deep orange
                  Color(0xFF8B3000), // Dark brown
                ],
                stops: [0.0, 0.5, 1.0],
              )
            : null,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            offset: const Offset(0, 4),
            blurRadius: 12,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            if (title == "SCIENCE: MICROBIOLOGY")
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 255, 255, 255),
                    image: DecorationImage(
                      image: AssetImage('assets/images/course_image.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Icon(
                        Icons.more_horiz_rounded,
                        color: Colors.white.withOpacity(0.9),
                        size: 24,
                      ),
                    ),
                  ),
                ),
              )
            else
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 255, 255),
                    image: DecorationImage(
                      image: AssetImage(
                        title == 'GRAPHICS DESIGN'
                            ? 'assets/images/hex_pattern.png'
                            : 'assets/images/hex_pattern.png',
                      ),
                      fit: BoxFit.cover,
                      opacity: 1,
                      colorFilter: ColorFilter.mode(
                        backgroundColor.withOpacity(0.1),
                        BlendMode.overlay,
                      ),
                    ),
                  ),
                ),
              ),
            Container(
              constraints: const BoxConstraints(
                minHeight: 140,
                maxHeight: 160,
              ),
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      title == 'GRAPHICS DESIGN' || title == 'UI/UX DESIGN'
                          ? Image.asset(
                              title == 'GRAPHICS DESIGN'
                                  ? 'assets/icons/graphics_icon.png'
                                  : 'assets/icons/uiux_icon.png',
                              width: 48,
                              height: 48,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                print('Error loading image: $error');
                                return Icon(
                                  Icons.error_outline,
                                  color: title == 'GRAPHICS DESIGN'
                                      ? const Color.fromARGB(255, 164, 182, 1)
                                      : const Color.fromARGB(255, 0, 165, 146),
                                  size: 48,
                                );
                              },
                            )
                          : Icon(
                              iconData,
                              color: title == 'GRAPHICS DESIGN'
                                  ? const Color.fromARGB(255, 164, 182, 1)
                                  : const Color.fromARGB(255, 0, 165, 146),
                              size: 48,
                            ),
                      const SizedBox(height: 16),
                      Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: IconButton(
                icon: const Icon(
                  Icons.more_horiz_rounded,
                  color: Colors.black54,
                  size: 24,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  // Handle menu button press
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        elevation: 0,
        backgroundColor: Colors.white,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            selectedIcon: Icon(Icons.favorite_rounded),
            label: 'Favorites',
          ),
          NavigationDestination(
            icon: Icon(Icons.school_outlined),
            selectedIcon: Icon(Icons.school_rounded),
            label: 'Courses',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/user_model.dart';
import 'my_courses.dart';
import 'package:google_fonts/google_fonts.dart';
/* import 'package:ui_own/mobile.dart';
import 'package:ui_own/my_courses.dart'; */

class Playcourses extends StatefulWidget {
    final UserModel user;

  const Playcourses({super.key, required this.user});

  @override
  State<Playcourses> createState() => _PlaycoursesState();
}

class _PlaycoursesState extends State<Playcourses> {
  int playingIndex = -1;
  int playing = -1; // Tracks which container is currently playing
  int Playing = -1;
  int Index = -1;
  int curr = -1;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFA),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Image and Icons
            Stack(
              children: [
                Image.asset(
                  "assets/images/micro.jpg",
                  height: 280,
                  width: double.infinity,
                  fit: BoxFit.fill,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(30, 50, 0, 10),
                      child: GestureDetector(
                        child: const Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.white,
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          
                        },
                      ),
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 50, 10, 10),
                          child: PopupMenuButton<String>(
                            child: const Icon(Icons.more_horiz,
                                size: 30, color: Colors.white),
                            itemBuilder: (BuildContext context) {
                              return [
                                const PopupMenuItem(
                                  value: 'Option 1',
                                  child: Text('Option 1'),
                                ),
                                const PopupMenuItem(
                                  value: 'Option 2',
                                  child: Text('Option 2'),
                                ),
                                const PopupMenuItem(
                                  value: 'Option 3',
                                  child: Text('Option 3'),
                                ),
                              ];
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 50, 10, 10),
                          child: InkWell(
                            child: const Icon(Icons.close,
                                size: 30, color: Colors.white),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MyCourses(user: widget.user)),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            // Take Assessment Link
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/quiz');
                      },
                      child: Text(
                        'Take Assessment',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/test-edit');
                      },
                      icon: Icon(
                        Icons.edit,
                        color: Theme.of(context).primaryColor,
                      ),
                      tooltip: 'Edit Test Questions',
                    ),
                  ],
                ),
              ),
            ),
            // Title and Subtitle
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 10, 10, 0),
              child: Text(
                'Science: Microbiology',
                style: GoogleFonts.comfortaa(
                  fontSize: 24,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 5, 10, 20),
              child: Text(
                'Azamat Baimatov',
                style: GoogleFonts.comfortaa(
                  fontSize: 16,
                  color: const Color.fromARGB(234, 119, 113, 113),
                ),
              ),
            ),

            // Section 1: Introductions
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
              child: Text(
                'Section 1 - Introductions',
                style: GoogleFonts.comfortaa(
                  fontSize: 13,
                  color: const Color.fromARGB(255, 140, 133, 133),
                ),
              ),
            ),

            // ListView for Section 1
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: 2,
              itemBuilder: (context, index) {
                return SizedBox(
                  height: 100,
                  width: double.infinity,
                  child: Card(
                    elevation: 6,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    color: Colors.white,
                    shadowColor: const Color.fromARGB(83, 158, 158, 158),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: curr == index
                                  ? const Color.fromARGB(67, 237, 156, 63)
                                  : const Color.fromARGB(44, 167, 199, 224),
                            ),
                            child: Center(
                              child: Text(
                                index + 1 >= 10
                                    ? "${index + 1}"
                                    : "0${index + 1}",
                                style: const TextStyle(
                                  color: Colors.amber,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(5, 29, 0, 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Introduction of course',
                                style: GoogleFonts.comfortaa(
                                  fontSize: 14,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: Text(
                                  'video - 10:04',
                                  style: GoogleFonts.comfortaa(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: InkWell(
                            child: curr == index
                                ? Image.asset("assets/images/play.png")
                                : Image.asset("assets/images/images.png"),
                            onTap: () {
                              setState(() {
                                if (Playing == -1) {
                                  curr = index;
                                  Playing = 1;
                                } else if (Playing == 1 && curr == index) {
                                  Playing = -1;
                                  curr = -1;
                                } else if (Playing == 1 && curr != index) {
                                  curr = index;
                                }

                                /*if (playingIndex == index/ ||playing==index ) {
                                          playingIndex = -1; // Set all to pause
                                        }
                                         else if(playing==-1)
                                        {
                                         
                                          playingIndex = index; // Set the current index to play
                                        }*/
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // Section 2: Basic Biology
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
              child: Text(
                'Section 2 - Basic Biology',
                style: GoogleFonts.comfortaa(
                  fontSize: 13,
                  color: const Color.fromARGB(255, 140, 133, 133),
                ),
              ),
            ),

            // ListView for Section 2
            ListView.builder(
              physics: /* const */ const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: 12,
              itemBuilder: (context, index) {
                return SizedBox(
                  height: 100,
                  width: double.infinity,
                  child: Card(
                    shadowColor: const Color.fromARGB(83, 158, 158, 158),
                    elevation: 6,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    color: Colors.white,
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: curr == index + 2
                                  ? const Color.fromARGB(67, 237, 156, 63)
                                  : const Color.fromARGB(44, 167, 199, 224),
                            ),
                            child: Center(
                              child: Text(
                                index + 3 >= 10
                                    ? "${index + 3}"
                                    : "0${index + 3}",
                                style: const TextStyle(
                                  color: Colors.amber,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(5, 30, 0, 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Basics of Biology',
                                style: GoogleFonts.comfortaa(
                                  fontSize: 14,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: Text(
                                  'video - 15:08',
                                  style: GoogleFonts.comfortaa(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: InkWell(
                            child: curr == index + 2
                                ? Image.asset("assets/images/play.png")
                                : Image.asset("assets/images/images.png"),
                            onTap: () {
                              setState(() {
                                if (Playing == -1) {
                                  curr = index + 2;
                                  Playing = 1;
                                } else if (Playing == 1 && curr == index + 2) {
                                  Playing = -1;
                                  curr = -1;
                                } else if (Playing == 1 && curr != index + 2) {
                                  curr = index + 2;
                                }

                                /* if (playing == index  ||playingIndex==index )
                                 {
                                      playing = -1; // Set all to pause
                                 }
                                    
                                    
                                     else if(playingIndex==-1) {
                                      playing = index; // Set the current index to play
                                    } */
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

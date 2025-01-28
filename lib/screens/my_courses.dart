import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/user_model.dart';
import 'package:flutter_application_1/screens/dashboard_screen.dart';
import 'play_courses.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

String? dropdownText;

TextEditingController _search = TextEditingController();
List<String> coursesStatus = ['All', 'Ongoing', 'Completed', 'Downloaded'];
String? selectedChoice = coursesStatus[0];
/* final List<String> courses = [
      'Science: Microbiology',
      'Science: Kinematics'
    ];
    List<String> authors = ['Azamat Baimatov', 'Walter Lewin'];
    List<String> durations = ['2 hrs 53mins', '2 hrs 15mins'];
List<String> thumbnail=['assets/images/micro.jpg','assets/images/kinematics.jpg']; */

class MyCourses extends StatefulWidget {
  final UserModel user;

  const MyCourses({super.key, required this.user});

  @override
  State<MyCourses> createState() => _MyCoursesState();
}

class _MyCoursesState extends State<MyCourses> {
  int selected = 0;
  int? courseSelected;
   List<String> filteredCourses = [];

 
  List<Map<String, dynamic>> coursesList = [
    {
      'course': 'Science: Microbiology',
      'author': 'Azamat Baimatov',
      'duration': '2 hrs 53mins',
      'thumbnail': 'assets/images/micro.jpg',
      'progress': 0.75,
    },
    {
      'course': 'Science: Kinematics',
      'author': 'Walter Lewin',
      'duration': '2 hrs 15mins',
      'thumbnail': 'assets/images/kinematics.jpg',
      'progress': 0.55,
    },
    {
      'course': 'Mathematics: Geometry',
      'author': 'Gauss',
      'duration': '2 hrs 15mins',
      'thumbnail': 'assets/images/geometry.jpg',
      'progress': 0.35,
    },
    {
      'course': 'Social: History',
      'author': 'John',
      'duration': '2 hrs 15mins',
      'thumbnail': 'assets/images/history.jpg',
      'progress': 0.89,
    },
    {
      'course': 'English: Grammar',
      'author': 'Dave',
      'duration': '2 hrs 15mins',
      'thumbnail': 'assets/images/grammar.jpg',
      'progress': 1.0,
    },

  ];
  List<Map<String,dynamic>> filter_based_on_choice=[];
  List<Map<String, dynamic>> filteredCoursesList = [];
 // String? selected_choice = "All";
 

   @override
 @override
  void initState() {
    super.initState();
    filteredCoursesList = List.from(coursesList); 
    filter_based_on_choice=List.from(coursesList);
  }

 

  void _filter_choice(String? filter,String query){
    setState(() {
      if(filter=='All'){
        filter_based_on_choice=List.from(coursesList);
      }
      else if(filter=='Ongoing'){
        filter_based_on_choice=coursesList.where((course)=>
                  (course['progress'] as double) < 1.0).toList();
      }
      else if(filter=='Completed'){
        filter_based_on_choice=coursesList.where((course)=>
                  (course['progress'] as double) >= 1.0).toList();
      }
       filteredCoursesList = filter_based_on_choice
          .where((course) =>
              course['course'].toLowerCase().contains(query.toLowerCase()))
          .toList();

});
  } 

/*  void _filterCourses(String query) {
    setState(() {
      filteredCoursesList = filter_based_on_choice
          .where((course) =>
              course['course'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  } */
  @override
  Widget build(BuildContext context) {
    
    
    
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFA),

      // AppBar
      appBar: AppBar(
        leading: Container(
          margin: const EdgeInsets.all(8),
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
              selectedChoice=coursesStatus[0];
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        DashboardScreen(user: widget.user)),
              );
            },
          ),
        ),
        automaticallyImplyLeading: true,
        elevation: 0,
        toolbarHeight: 60,
        backgroundColor: const Color(0xFFF9FAFA),
        title: const Text(
          'My Courses',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 8, 10, 8),
            child: DropdownButton<String>(
              underline: Container(height: 0),
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: Colors.black,
              ),
              hint: Text(
                dropdownText ?? '10th Std',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              items: <String>['10th Std', '12th Std', 'Graduate']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? value) {
                setState(() {
                  dropdownText = value;
                });
              },
            ),
          ),
        ],
      ),

      // Body
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(20),
              child: TextField(
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      width: 0,
                      color: Color.fromARGB(120, 144, 141, 141),
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      width: 0,
                      color: Color.fromARGB(115, 144, 141, 141),
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  prefixIcon: Image.asset('assets/images/searchicon.png'),
                  hintText: 'Search...',
                  hintStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color.fromARGB(255, 144, 142, 142),
                  ),
                ),
                controller: _search,
                keyboardType: TextInputType.text,
                onChanged: (query){
                  _filter_choice(selectedChoice,query);
                },
              ),
            ),


              SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Wrap(
                spacing: 10,
                children: coursesStatus.map((option) {
                  return ChoiceChip(
                   showCheckmark: false,
                    label: Text(option),
                    selected: selectedChoice == option,
                    selectedColor: Colors.amber,
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    labelStyle: TextStyle(
                      color: selectedChoice == option ? Colors.black : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                    onSelected: (bool selected) {
                      setState(() {
                        selectedChoice = selected ? option : selectedChoice;
                        
                        _filter_choice(selectedChoice, _search.text);
                      });
                    },
                  );
                  
                }).toList(),
              ),
            ),




            // ListView of Courses
            Expanded(
              child: ListView.builder(
                itemCount: filteredCoursesList.length,
                itemBuilder: (context, index) {
                  var courseData = filteredCoursesList[index];
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(4, 10, 4, 10),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          courseSelected = index;
                        });
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                Playcourses(user: widget.user)),
                        );
                      },
                      child: Card(
                        elevation: courseSelected == index ? 4 : 16,
                        shadowColor:
                            const Color.fromARGB(87, 211, 207, 207),
                        color: const Color.fromARGB(255, 255, 253, 253),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            // Thumbnail
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.asset(
                                  courseData['thumbnail'],
                                  fit: BoxFit.fill,
                                  height: 100,
                                  width: 100,
                                ),
                              ),
                            ),
                            // Course Details
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 4.0),
                                      child: Text(
                                        courseData['course'],
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 4.0),
                                      child: Text(
                                        courseData['author'],
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 4.0),
                                      child: Text(
                                        courseData['duration'],
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    const Text(
                                      '38 / 50',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.amber,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Progress Indicator
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 10, top: 20, right: 14),
                              child: CircularPercentIndicator(
                                radius: 30,
                                lineWidth: 6.0,
                                animation: true,
                                percent: courseData['progress'] as double,
                                center: Text(
                                  "${((courseData['progress'] as double) * 100).toStringAsFixed(0)}%",
                                  style: const TextStyle(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                circularStrokeCap: CircularStrokeCap.round,
                                progressColor: Colors.amber,
                                backgroundColor: Colors.grey[300]!,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
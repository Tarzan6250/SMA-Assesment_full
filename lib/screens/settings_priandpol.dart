import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';



class PrivacyPolicyApp extends StatelessWidget {
  const PrivacyPolicyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PrivacyPolicyPage(),
    );
  }
}

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        //toolbarHeight: 60, // Adjust toolbar height for spacing
        title: Padding(
          padding: const EdgeInsets.only(top: 2), // Move text lower
          child: Text(
            'Privacy & Policy',
            style: GoogleFonts.roboto(
              fontSize: 21,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: Colors.transparent, // Transparent AppBar
        elevation: 0,
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
            onPressed: () => Navigator.pop(context),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
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
      body: SingleChildScrollView(
      
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
          child: Container(
            
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 244, 244, 244),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(16, 30, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Types of data collected',
                  style: GoogleFonts.cabin(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: const Color.fromARGB(255, 35, 35, 35),
                  ),
                ),
                const SizedBox(height: 20),
                 Text(
                  'A Privacy Policy is a legal document, which informs your website\'s visitors about the data collected on them and how your company will use it.\n\n'
                  'This article will cover the components of a good Privacy Policy and will help you better understand how to create one that builds trust and confidence in your customers and protects you against various liability issues. You\'ll also find examples of how other businesses have used Privacy Policies to comply with the law and inform customers about their privacy practices.\n\n'
                  'We\'ve also put together a Sample Privacy Policy Template that you can use to help write your own.',
                  style: GoogleFonts.cabin(fontSize: 14, height: 2, color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 90),
                 Text(
                  'How my data used and disclosed',
                  style: GoogleFonts.cabin(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: const Color.fromARGB(255, 35, 35, 35),
                  ),
                ),
                const SizedBox(height: 12),
                 Text(
                  'A Privacy Policy is a legal document, which informs your website\'s visitors about the data collected on them and how your company will use it.\n\n'
                  'This article will cover the components of a good Privacy Policy and will help you better understand how to create one that builds trust and confidence in your customers and protects you against various liability issues. You\'ll also find examples of how other businesses have used Privacy Policies to comply with the law and inform customers about their privacy practices.',
                  style: GoogleFonts.cabin(fontSize: 14, height: 2, color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

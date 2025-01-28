import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FAQPage extends StatefulWidget {
  const FAQPage({super.key});

  @override
  _FAQPageState createState() => _FAQPageState();
}

class _FAQPageState extends State<FAQPage> {
  String selectedCategory = 'Courses';
  Set<String> expandedItems = {}; // Tracks expanded questions

  final Map<String, List<Map<String, String>>> faqData = {
    'Courses': [
      {'What is a course?': ''},
      {
        'What are the benefits?': 
             'You can search for courses according to your expertise, we always update 24 hours for the latest courses. use the search feature or go to the category or search there you can find the latest courses and you can use filters according to your needs'
      },
      {'How to buy courses?': ''},
      {'Will I get a course certificate?': ''},
    ],
    'Payments': [
      {'How can I pay for a course?': ''},
      {'What payment methods are available?': ''},
      {'Is my payment secure?': ''},
    ],
    'Promo': [
      {'How do I apply a promo code?': ''},
      {'Where can I find promo codes?': ''},
    ],
    'Certificate': [
      {'How can I get my certificate?': ''},
      {'Is the certificate valid internationally?': ''},
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            'FAQ',
            style: GoogleFonts.roboto(
              fontSize: 18,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Top Questions',
                  style: GoogleFonts.cabin(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                IconButton(
                icon: Image.asset(
                  'assets/images/searc.png',
                  width: 24,
                  height: 24,
                  color: Colors.grey[700], // Optional: Adjust color if needed
                ),
                onPressed: () {
                  // Add search functionality here
                },
              ),

              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 40,
              width: MediaQuery.of(context).size.width,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: faqData.keys.map((category) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: _buildCategoryChip(category),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: ListView(
                children: faqData[selectedCategory]!
                    .map((faq) => _buildFAQContainer(
                          faq.keys.first,
                          faq.values.first,
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label) {
    bool isSelected = label == selectedCategory;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = label;
        });
      },
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color.fromARGB(255, 253, 204, 26) : const Color.fromARGB(255, 255, 255, 255),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color.fromARGB(255, 255, 255, 255) : Colors.grey[200]!,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.cabin(
              color: isSelected ? Colors.black : Colors.grey[700],
              fontWeight: FontWeight.bold,
              fontSize: 
              label.length > 10 ? 15 :
              
              14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFAQContainer(String question, String answer) {
  bool isExpanded = expandedItems.contains(question);

  return GestureDetector(
    onTap: () {
      setState(() {
        if (isExpanded) {
          expandedItems.remove(question);
        } else {
          expandedItems.add(question);
        }
      });
    },
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 30),  // Increased space between containers
      decoration: BoxDecoration(
        color: isExpanded ? const Color.fromARGB(224, 250, 250, 250) : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  question,
                  style: GoogleFonts.cabin(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Icon(
                isExpanded ? Icons.remove : Icons.add,  // Toggle icon
                color: Colors.black,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 16),  // Added gap between question and answer
          if (isExpanded && answer.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                answer,
                style: GoogleFonts.cabin(fontSize: 16, color: const Color.fromARGB(255, 145, 145, 145), height: 1.8),
              ),
            ),
        ],
      ),
    ),
  );
}



}

void main() => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FAQPage(),
    ));

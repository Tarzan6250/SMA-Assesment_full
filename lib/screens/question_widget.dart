import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'test_edit.dart';

class QuestionWidget extends StatelessWidget {
  final Map<String, dynamic> question;
  final Function handleNextSlide;
  final Function handlePreviousSlide;
  final bool isLastQuestion;
  final bool isFirstQuestion;
  final Function handleSubmit;
  final int? selectedAnswer;
  final Function(int) onAnswerSelected;

  QuestionWidget({
    required this.question,
    required this.handleNextSlide,
    required this.handlePreviousSlide,
    required this.isLastQuestion,
    required this.isFirstQuestion,
    required this.handleSubmit,
    required this.selectedAnswer,
    required this.onAnswerSelected,
  });

  @override
  Widget build(BuildContext context) {
    String questionType = question['ques_type'] ?? 'text';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                question['ques'] ?? '',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TestEdit()),
                );
              },
            ),
          ],
        ),
        SizedBox(height: 20),
        if (questionType == 'text')
          TextField(
            decoration: InputDecoration(
              hintText: 'Enter your answer',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => onAnswerSelected(0),
          )
        else if (question['options'] != null)
          ...List.generate(
            (question['options'] as List).length,
            (index) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: InkWell(
                onTap: () => onAnswerSelected(index),
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: selectedAnswer == index
                          ? Theme.of(context).primaryColor
                          : Colors.grey[300]!,
                      width: 2,
                    ),
                    color: selectedAnswer == index
                        ? Theme.of(context).primaryColor.withOpacity(0.1)
                        : Colors.white,
                  ),
                  child: Row(
                    children: [
                      if (questionType == 'multiple_choice')
                        Container(
                          width: 24,
                          height: 24,
                          margin: EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selectedAnswer == index
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey[400]!,
                              width: 2,
                            ),
                            color: selectedAnswer == index
                                ? Theme.of(context).primaryColor
                                : Colors.white,
                          ),
                          child: selectedAnswer == index
                              ? Icon(
                                  Icons.check,
                                  size: 16,
                                  color: Colors.white,
                                )
                              : null,
                        )
                      else if (questionType == 'true_false')
                        Container(
                          width: 24,
                          height: 24,
                          margin: EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selectedAnswer == index
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey[400]!,
                              width: 2,
                            ),
                            color: selectedAnswer == index
                                ? Theme.of(context).primaryColor
                                : Colors.white,
                          ),
                          child: selectedAnswer == index
                              ? Icon(
                                  Icons.check,
                                  size: 16,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      Expanded(
                        child: Text(
                          question['options'][index].toString(),
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: selectedAnswer == index
                                ? Theme.of(context).primaryColor
                                : Colors.black87,
                            fontWeight: selectedAnswer == index
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (!isFirstQuestion)
              ElevatedButton(
                onPressed: () => handlePreviousSlide(),
                child: Text('Previous'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            if (!isLastQuestion)
              ElevatedButton(
                onPressed: () => handleNextSlide(),
                child: Text('Next'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            if (isLastQuestion)
              ElevatedButton(
                onPressed: () => handleSubmit(),
                child: Text('Submit'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  backgroundColor: Theme.of(context).primaryColor,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

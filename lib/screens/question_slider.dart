import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/question_service.dart';
import 'dart:convert';

class QuizSlider extends StatefulWidget {
  @override
  _QuizSliderState createState() => _QuizSliderState();
}

class _QuizSliderState extends State<QuizSlider> {
  int currentSlide = 0;
  int score = 0;
  bool showScore = false;
  int timeLeft = 300; // 5 minutes in seconds
  late Timer timer;
  List<Map<String, dynamic>> questions = [];
  Map<int, List<String>> answers = {};
  int? timeTaken;
  bool isLoading = true;
  final QuestionService _questionService = QuestionService();
  final PageController _pageController = PageController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    loadQuestions();
  }

  Future<void> loadQuestions() async {
    try {
      final loadedQuestions = await _loadQuestions();
      setState(() {
        questions = loadedQuestions;
        answers = {};
        isLoading = false;
      });
      startTimer();
    } catch (e) {
      print('Error loading questions: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<List<Map<String, dynamic>>> _loadQuestions() async {
    List<Map<String, dynamic>> allQuestions = [];
    
    try {
      // Get questions from Question_bank collection
      QuerySnapshot snapshot = await _firestore.collection('Question_bank').get();
      
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('questions')) {
          // Safely handle the questions list
          final questionsList = data['questions'];
          if (questionsList != null) {
            if (questionsList is List) {
              for (var question in questionsList) {
                if (question is Map) {
                  allQuestions.add(Map<String, dynamic>.from(question));
                }
              }
            }
          }
        }
      }

      // Shuffle questions for randomization
      allQuestions.shuffle();
      return allQuestions;
    } catch (e) {
      print('Error loading questions: $e');
      return [];
    }
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (timeLeft > 0) {
            timeLeft--;
          } else {
            handleSubmit();
            timer.cancel();
          }
        });
      }
    });
  }

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void handleAnswer(int questionIndex, String answer) {
    setState(() {
      if (questions[questionIndex]['ques_type'] == 'Multi_Sel') {
        // Initialize the list if it doesn't exist
        answers[questionIndex] = answers[questionIndex] ?? [];
        
        // Toggle the answer
        if (answers[questionIndex]!.contains(answer)) {
          answers[questionIndex]!.remove(answer);
        } else {
          answers[questionIndex]!.add(answer);
        }
      } else {
        // For single select questions
        answers[questionIndex] = [answer];
      }
    });
  }

  void handleRAGAnswer(int questionIndex, String subcategoryName, String color) {
    if (!answers.containsKey(questionIndex)) {
      answers[questionIndex] = [];
    }
    
    // Find or create the answer for this subcategory
    Map<String, String> answer = {
      'subcategory': subcategoryName,
      'color': color,
    };
    
    // Update the answer
    List<Map<String, String>> currentAnswers = answers[questionIndex]!
        .map((a) => Map<String, String>.from(json.decode(a)))
        .toList();
        
    bool found = false;
    for (int i = 0; i < currentAnswers.length; i++) {
      if (currentAnswers[i]['subcategory'] == subcategoryName) {
        currentAnswers[i]['color'] = color;
        found = true;
        break;
      }
    }
    
    if (!found) {
      currentAnswers.add(answer);
    }
    
    // Convert back to string format
    answers[questionIndex] = currentAnswers.map((a) => json.encode(a)).toList();
    
    setState(() {});
  }

  String? getRAGAnswer(int questionIndex, String subcategoryName) {
    if (!answers.containsKey(questionIndex)) return null;
    
    for (String answerStr in answers[questionIndex]!) {
      Map<String, dynamic> answer = json.decode(answerStr);
      if (answer['subcategory'] == subcategoryName) {
        return answer['color'];
      }
    }
    return null;
  }

  bool isAnswerSelected(int questionIndex, String option) {
    if (!answers.containsKey(questionIndex)) return false;
    return answers[questionIndex]!.contains(option);
  }

  void navigateToQuestion(int index) {
    _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void handleSubmit() {
    setState(() {
      showScore = true;
      timeTaken = 300 - timeLeft;
      timer.cancel();
      
      // Calculate score
      score = 0;
      for (int i = 0; i < questions.length; i++) {
        if (answers.containsKey(i)) {
          if (questions[i]['ques_type'] == 'Multi_Sel') {
            var correctAnswers = questions[i]['answer'] != null && questions[i]['answer'] is List
                ? List<String>.from(questions[i]['answer'] as List)
                : <String>[];
            var userAnswers = answers[i] ?? [];
            if (correctAnswers.length == userAnswers.length && 
                correctAnswers.every((element) => userAnswers.contains(element))) {
              score++;
            }
          } else if (questions[i]['ques_type'] == 'true_false') {
            if (answers[i]!.first.toString().toLowerCase() == 
                questions[i]['answer'].toString().toLowerCase()) {
              score++;
            }
          } else if (questions[i]['ques_type'] == 'voice') {
            // For voice questions, we don't compare answers
            score++;
          } else if (questions[i]['ques_type'] == 'rag') {
            // For RAG questions, we don't compare answers
            score++;
          } else {
            if (answers[i]!.first.toString() == 
                questions[i]['answer'].toString()) {
              score++;
            }
          }
        }
      }
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => AssessmentCompletedView(
          score: score,
          totalQuestions: questions.length,
          timeTaken: timeTaken!,
          questions: questions,
          answers: answers,
        ),
      ),
    );
  }

  bool isAnswerCorrect(int index) {
    if (!answers.containsKey(index)) return false;
    
    if (questions[index]['ques_type'] == 'Multi_Sel') {
      var correctAnswers = questions[index]['answer'] != null && questions[index]['answer'] is List
          ? List<String>.from(questions[index]['answer'] as List)
          : <String>[];
      var userAnswers = answers[index] ?? [];
      return correctAnswers.length == userAnswers.length && 
             correctAnswers.every((element) => userAnswers.contains(element));
    } else if (questions[index]['ques_type'] == 'true_false') {
      return answers[index]!.first.toString().toLowerCase() == 
             questions[index]['answer'].toString().toLowerCase();
    } else if (questions[index]['ques_type'] == 'voice') {
      // For voice questions, any answer is considered correct
      return true;
    } else if (questions[index]['ques_type'] == 'rag') {
      // For RAG questions, any answer is considered correct
      return true;
    } else {
      return answers[index]!.first.toString() == 
             questions[index]['answer'].toString();
    }
  }

  String getAnswerDisplay(dynamic answer) {
    if (answer == null) return "Not answered";
    if (answer is List) {
      return answer.map((e) => e.toString()).join(", ");
    }
    return answer.toString();
  }

  bool isOptionCorrect(dynamic question, dynamic option) {
    String optionStr = option.toString();
    if (question['ques_type'] == 'Multi_Sel') {
      List<String> answers = List<String>.from(question['answer'] as List);
      return answers.contains(optionStr);
    } else if (question['ques_type'] == 'true_false') {
      return question['answer'].toString().toLowerCase() == optionStr.toLowerCase();
    } else if (question['ques_type'] == 'rag') {
      // For RAG questions, we don't compare answers
      return true;
    } else {
      return question['answer'].toString() == optionStr;
    }
  }

  Widget _buildQuestionCard(Map<String, dynamic> question, int optionIndex) {
    if (question['ques_type'] == 'rag') {
      // Handle RAG type questions
      List<Map<String, dynamic>> subcategories = 
        (question['subcategories'] as List?)?.map((e) => Map<String, dynamic>.from(e)).toList() ?? [];
      
      if (subcategories.isEmpty) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Text('No subcategories available'),
        );
      }

      return Container(
        margin: EdgeInsets.only(bottom: 16),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...subcategories.map((subcategory) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subcategory['name'] as String? ?? '',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildRAGButton(
                        color: Colors.red,
                        label: 'Red',
                        isSelected: getRAGAnswer(currentSlide, subcategory['name']) == 'red',
                        onTap: () => handleRAGAnswer(currentSlide, subcategory['name'], 'red'),
                      ),
                      _buildRAGButton(
                        color: Colors.amber,
                        label: 'Amber',
                        isSelected: getRAGAnswer(currentSlide, subcategory['name']) == 'amber',
                        onTap: () => handleRAGAnswer(currentSlide, subcategory['name'], 'amber'),
                      ),
                      _buildRAGButton(
                        color: Colors.green,
                        label: 'Green',
                        isSelected: getRAGAnswer(currentSlide, subcategory['name']) == 'green',
                        onTap: () => handleRAGAnswer(currentSlide, subcategory['name'], 'green'),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                ],
              );
            }).toList(),
          ],
        ),
      );
    }
    
    // Handle other question types
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isOptionCorrect(question, question['options'][optionIndex])
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isOptionCorrect(question, question['options'][optionIndex])
              ? Colors.green
              : Colors.red,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${optionIndex + 1}. ${question['options'][optionIndex]}',
            style: TextStyle(
              color: isOptionCorrect(question, question['options'][optionIndex])
                  ? Colors.green
                  : Colors.black87,
              fontWeight: isOptionCorrect(question, question['options'][optionIndex])
                  ? FontWeight.w600
                  : FontWeight.normal,
            ),
          ),
          if (isOptionCorrect(question, question['options'][optionIndex]))
            Padding(
              padding: EdgeInsets.only(left: 8),
              child: Icon(Icons.check_circle, color: Colors.green, size: 16),
            ),
        ],
      ),
    );
  }

  Widget _buildRAGButton({
    required Color color,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.grey[400]!,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
              ),
            ),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showDetailedResults() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Detailed Results',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                ...List.generate(
                  questions.length,
                  (index) => Container(
                    margin: EdgeInsets.only(bottom: 16),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isAnswerCorrect(index)
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isAnswerCorrect(index)
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Question ${index + 1}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(
                              isAnswerCorrect(index)
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              color: isAnswerCorrect(index)
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(questions[index]['ques']),
                        SizedBox(height: 8),
                        Text(
                          'Your Answer: ${getAnswerDisplay(answers[index])}',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        Text(
                          'Correct Answer: ${getAnswerDisplay(questions[index]['answer'])}',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Close'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String formatTimeTaken(int seconds) {
    if (seconds < 60) return '$seconds sec';
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes min ${remainingSeconds} sec';
  }

  void _showQuestionNavigationDialog() {
    final size = MediaQuery.of(context).size;
    final maxHeight = size.height * 0.8; // Maximum 80% of screen height
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: maxHeight,
            maxWidth: size.width * 0.9, // Maximum 90% of screen width
          ),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Navigate to Question',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Flexible(
                  child: GridView.builder(
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 1,
                    ),
                    itemCount: questions.length,
                    itemBuilder: (context, index) {
                      bool isAnswered = answers.containsKey(index);
                      bool isCurrentQuestion = currentSlide == index;
                      
                      return InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          navigateToQuestion(index);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isCurrentQuestion
                                ? Theme.of(context).primaryColor
                                : isAnswered
                                    ? Theme.of(context).primaryColor.withOpacity(0.1)
                                    : Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isCurrentQuestion
                                  ? Theme.of(context).primaryColor
                                  : isAnswered
                                      ? Theme.of(context).primaryColor
                                      : Colors.grey[400]!,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: isCurrentQuestion
                                    ? Colors.white
                                    : isAnswered
                                        ? Theme.of(context).primaryColor
                                        : Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegendItem(
                        color: Theme.of(context).primaryColor,
                        text: 'Current',
                      ),
                      SizedBox(width: 16),
                      _buildLegendItem(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderColor: Theme.of(context).primaryColor,
                        text: 'Answered',
                      ),
                      SizedBox(width: 16),
                      _buildLegendItem(
                        color: Colors.grey[200]!,
                        borderColor: Colors.grey[400]!,
                        text: 'Unanswered',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    Color? borderColor,
    required String text,
  }) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: borderColor ?? color,
            ),
          ),
        ),
        SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (questions.isEmpty) {
      return Scaffold(
        body: Center(
          child: Text(
            'No questions available',
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz Assessment'),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: _showQuestionNavigationDialog,
          ),
          Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                formatTime(timeLeft),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: BouncingScrollPhysics(),
              onPageChanged: (index) {
                setState(() {
                  currentSlide = index;
                });
              },
              itemCount: questions.length,
              itemBuilder: (context, index) {
                final question = questions[index];
                return SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LinearProgressIndicator(
                        value: (index + 1) / questions.length,
                        backgroundColor: Colors.grey[200],
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Question ${index + 1}/${questions.length}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            question['ques_type'] == 'voice'
                                ? 'Voice Question'
                                : question['ques_type'] == 'multiple_choice'
                                ? 'Multiple Choice'
                                : question['ques_type'] == 'Multi_Sel'
                                    ? 'Multi Select'
                                    : question['ques_type'] == 'rag'
                                        ? 'RAG'
                                        : 'True/False',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24),
                      Text(
                        question['ques'],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 24),
                      if (question['ques_type'] == 'rag')
                        ...List.generate(
                          (question['subcategories'] as List?)?.length ?? 0,
                          (subIndex) {
                            final subcategory = (question['subcategories'] as List)[subIndex];
                            final selectedColor = getRAGAnswer(index, subcategory['name']);
                            
                            return Padding(
                              padding: EdgeInsets.only(bottom: 16),
                              child: Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      subcategory['name'],
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        _buildRAGButton(
                                          color: Colors.red,
                                          label: 'Red',
                                          isSelected: selectedColor == 'red',
                                          onTap: () => handleRAGAnswer(index, subcategory['name'], 'red'),
                                        ),
                                        _buildRAGButton(
                                          color: Colors.amber,
                                          label: 'Amber',
                                          isSelected: selectedColor == 'amber',
                                          onTap: () => handleRAGAnswer(index, subcategory['name'], 'amber'),
                                        ),
                                        _buildRAGButton(
                                          color: Colors.green,
                                          label: 'Green',
                                          isSelected: selectedColor == 'green',
                                          onTap: () => handleRAGAnswer(index, subcategory['name'], 'green'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        )
                      else
                        ...(question['options'] as List).map((option) {
                          final isSelected = isAnswerSelected(index, option.toString());
                          final isMultiSelect = question['ques_type'] == 'Multi_Sel';
                          
                          return Padding(
                            padding: EdgeInsets.only(bottom: 12),
                            child: InkWell(
                              onTap: () => handleAnswer(index, option.toString()),
                              child: Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSelected
                                        ? Theme.of(context).primaryColor
                                        : Colors.grey[300]!,
                                    width: 2,
                                  ),
                                  color: isSelected
                                      ? Theme.of(context).primaryColor.withOpacity(0.1)
                                      : Colors.white,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        shape: isMultiSelect ? BoxShape.rectangle : BoxShape.circle,
                                        borderRadius: isMultiSelect ? BorderRadius.circular(4) : null,
                                        border: Border.all(
                                          color: isSelected
                                              ? Theme.of(context).primaryColor
                                              : Colors.grey[400]!,
                                        ),
                                        color: isSelected
                                            ? Theme.of(context).primaryColor
                                            : Colors.white,
                                      ),
                                      child: isSelected
                                          ? Icon(
                                              isMultiSelect ? Icons.check_box : Icons.check,
                                              size: 16,
                                              color: Colors.white,
                                            )
                                          : isMultiSelect
                                              ? Icon(
                                                  Icons.check_box_outline_blank,
                                                  size: 16,
                                                  color: Colors.grey[400],
                                                )
                                              : null,
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        option.toString(),
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: isSelected
                                              ? Theme.of(context).primaryColor
                                              : Colors.black87,
                                          fontWeight: isSelected
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      SizedBox(height: 24),
                    ],
                  ),
                );
              },
            ),
          ),
          // Bottom navigation buttons in a fixed position
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (currentSlide > 0)
                  ElevatedButton(
                    onPressed: () => navigateToQuestion(currentSlide - 1),
                    child: Text('Previous'),
                  )
                else
                  SizedBox(width: 80), // Placeholder for spacing
                if (currentSlide < questions.length - 1)
                  ElevatedButton(
                    onPressed: () => navigateToQuestion(currentSlide + 1),
                    child: Text('Next'),
                  )
                else
                  ElevatedButton(
                    onPressed: handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Submit'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

extension on List<String>? {
  toLowerCase() {}
}

class AssessmentCompletedView extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final int timeTaken;
  final List<dynamic> questions;
  final Map<int, List<String>> answers;

  const AssessmentCompletedView({
    Key? key,
    required this.score,
    required this.totalQuestions,
    required this.timeTaken,
    required this.questions,
    required this.answers,
  }) : super(key: key);

  bool isAnswerCorrect(int index) {
    if (!answers.containsKey(index)) return false;
    
    if (questions[index]['ques_type'] == 'Multi_Sel') {
      var correctAnswers = questions[index]['answer'] != null && questions[index]['answer'] is List
          ? List<String>.from(questions[index]['answer'] as List)
          : <String>[];
      var userAnswers = answers[index] ?? [];
      return correctAnswers.length == userAnswers.length && 
             correctAnswers.every((element) => userAnswers.contains(element));
    } else if (questions[index]['ques_type'] == 'true_false') {
      return answers[index]!.first.toString().toLowerCase() == 
             questions[index]['answer'].toString().toLowerCase();
    } else if (questions[index]['ques_type'] == 'voice') {
      // For voice questions, any answer is considered correct
      return true;
    } else if (questions[index]['ques_type'] == 'rag') {
      // For RAG questions, any answer is considered correct
      return true;
    } else {
      return answers[index]!.first.toString() == 
             questions[index]['answer'].toString();
    }
  }

  String formatTimeTaken(int seconds) {
    if (seconds < 60) return '$seconds sec';
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes min ${remainingSeconds} sec';
  }

  String getAnswerDisplay(dynamic answer) {
    if (answer == null) return "Not answered";
    if (answer is List) {
      return answer.map((e) => e.toString()).join(", ");
    }
    return answer.toString();
  }

  bool isOptionCorrect(dynamic question, dynamic option) {
    String optionStr = option.toString();
    if (question['ques_type'] == 'Multi_Sel') {
      List<String> answers = List<String>.from(question['answer'] as List);
      return answers.contains(optionStr);
    } else if (question['ques_type'] == 'true_false') {
      return question['answer'].toString().toLowerCase() == optionStr.toLowerCase();
    } else if (question['ques_type'] == 'rag') {
      // For RAG questions, we don't compare answers
      return true;
    } else {
      return question['answer'].toString() == optionStr;
    }
  }

  Widget _buildQuestionCard(Map<String, dynamic> question, int optionIndex) {
    if (question['ques_type'] == 'rag') {
      // Handle RAG type questions
      List<Map<String, dynamic>> subcategories = 
        (question['subcategories'] as List?)?.map((e) => Map<String, dynamic>.from(e)).toList() ?? [];
      
      if (subcategories.isEmpty) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Text('No subcategories available'),
        );
      }

      return Container(
        margin: EdgeInsets.only(bottom: 16),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...subcategories.map((subcategory) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subcategory['name'] as String? ?? '',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.red,
                      ),
                      SizedBox(width: 8),
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.amber,
                      ),
                      SizedBox(width: 8),
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.green,
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                ],
              );
            }).toList(),
          ],
        ),
      );
    }
    
    // Handle other question types
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isOptionCorrect(question, question['options'][optionIndex])
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isOptionCorrect(question, question['options'][optionIndex])
              ? Colors.green
              : Colors.red,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${optionIndex + 1}. ${question['options'][optionIndex]}',
            style: TextStyle(
              color: isOptionCorrect(question, question['options'][optionIndex])
                  ? Colors.green
                  : Colors.black87,
              fontWeight: isOptionCorrect(question, question['options'][optionIndex])
                  ? FontWeight.w600
                  : FontWeight.normal,
            ),
          ),
          if (isOptionCorrect(question, question['options'][optionIndex]))
            Padding(
              padding: EdgeInsets.only(left: 8),
              child: Icon(Icons.check_circle, color: Colors.green, size: 16),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Assessment Completed'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Final Score',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$score/$totalQuestions',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${((score / totalQuestions) * 100).toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Time Taken',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              formatTimeTaken(timeTaken),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
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
            SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.list_alt),
                    label: Text('View Detailed Results'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => Dialog(
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(16),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Detailed Results',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  ...List.generate(
                                    questions.length,
                                    (index) => Container(
                                      margin: EdgeInsets.only(bottom: 16),
                                      padding: EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: isAnswerCorrect(index)
                                            ? Colors.green.withOpacity(0.1)
                                            : Colors.red.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: isAnswerCorrect(index)
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                'Question ${index + 1}',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              Icon(
                                                isAnswerCorrect(index)
                                                    ? Icons.check_circle
                                                    : Icons.cancel,
                                                color: isAnswerCorrect(index)
                                                    ? Colors.green
                                                    : Colors.red,
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 8),
                                          Text(questions[index]['ques']),
                                          SizedBox(height: 8),
                                          Text(
                                            'Your Answer: ${getAnswerDisplay(answers[index])}',
                                            style: TextStyle(color: Colors.grey[700]),
                                          ),
                                          Text(
                                            'Correct Answer: ${getAnswerDisplay(questions[index]['answer'])}',
                                            style: TextStyle(color: Colors.grey[700]),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text('Close'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: Icon(Icons.arrow_back),
                    label: Text('Return to Course Page'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      // Pop once to return to the page where assessment was started
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

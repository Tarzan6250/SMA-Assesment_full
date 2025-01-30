import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TestEdit extends StatefulWidget {
  @override
  _TestEditState createState() => _TestEditState();
}

class _TestEditState extends State<TestEdit> with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? _selectedQuestion;
  int? _selectedIndex;
  bool _isAddingNew = false;
  String _selectedTab = 'multiple_choice';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(_handleTabSelection);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      // Prevent tab switching while editing/adding questions
      if (_isAddingNew || _selectedQuestion != null) {
        // Revert back to previous tab
        _tabController.animateTo(_tabController.previousIndex);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please complete or cancel your current edit first'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }
      setState(() {
        _selectedTab = _tabController.index == 0 
            ? 'multiple_choice' 
            : _tabController.index == 1 
                ? 'Multi_Sel'  
                : _tabController.index == 2 
                    ? 'true_false' 
                    : _tabController.index == 3 
                        ? 'rag' 
                        : 'voice';
        _selectedQuestion = null;
        _selectedIndex = null;
        _isAddingNew = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Test Questions'),
        bottom: TabBar(
          controller: _tabController,
          onTap: (index) {
            // Prevent tab switching while editing/adding questions
            if (_isAddingNew || _selectedQuestion != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Please complete or cancel your current edit first'),
                  duration: Duration(seconds: 2),
                ),
              );
              return;
            }
            setState(() {
              _selectedTab = index == 0 
                  ? 'multiple_choice' 
                  : index == 1 
                      ? 'Multi_Sel'  
                      : index == 2 
                          ? 'true_false' 
                          : index == 3 
                              ? 'rag' 
                              : 'voice';
              _selectedQuestion = null;
              _selectedIndex = null;
              _isAddingNew = false;
            });
          },
          tabs: [
            Tab(text: 'Multiple Choice'),
            Tab(text: 'Multi Select'),  
            Tab(text: 'True/False'),
            Tab(text: 'RAG Assessment'),
            Tab(text: 'Voice Input'),
          ],
        ),
      ),
      floatingActionButton: !_isAddingNew ? FloatingActionButton(
        onPressed: () {
          setState(() {
            _isAddingNew = true;
            _selectedQuestion = null;
            _selectedIndex = null;
          });
        },
        child: Icon(Icons.add),
      ) : null,
      body: TabBarView(
        controller: _tabController,
        physics: _isAddingNew || _selectedQuestion != null 
            ? NeverScrollableScrollPhysics()  // Prevent swiping when editing
            : null,  // Allow swiping when not editing
        children: [
          _buildQuestionList('zdD79hpJJxCq9mOtp33I'),
          _buildQuestionList('UQvys4UKzeM4MnBbnr0j'),
          _buildQuestionList('ve27tEYc0wAE7bFLtubm'),
          _buildQuestionList('6eyyZYQ4ChVXmf0GCCRjv'),
          _buildQuestionList('G8b65NreEfHWeWhFiQop'),
        ],
      ),
    );
  }

  Widget _buildQuestionList(String docId) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore
          .collection('Question_bank')
          .doc(docId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Center(child: Text('No questions found'));
        }

        Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
        List<dynamic> questions = List.from(data['questions'] ?? []);
        String docId = snapshot.data!.id;

        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Questions (${questions.length})',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 16),
              if (_isAddingNew) _buildNewQuestionForm(),
              if (!_isAddingNew) ...List.generate(
                questions.length,
                (index) => _buildQuestionCard(
                  questions[index],
                  docId,
                  index,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNewQuestionForm() {
    String selectedQuestionType = 'multiple_choice';
    TextEditingController questionController = TextEditingController();
    ValueNotifier<List<String>> optionsNotifier = ValueNotifier<List<String>>(['', '']);
    ValueNotifier<List<String>> selectedAnswersNotifier = ValueNotifier<List<String>>(['']);
    ValueNotifier<List<Map<String, dynamic>>> subcategoriesNotifier = ValueNotifier<List<Map<String, dynamic>>>([
      {
        'name': '',
        'options': [
          {'color': 'red', 'text': 'Red'},
          {'color': 'amber', 'text': 'Amber'},
          {'color': 'green', 'text': 'Green'}
        ]
      }
    ]);
    ValueNotifier<List<Map<String, String>>> ragOptionsNotifier = ValueNotifier<List<Map<String, String>>>([
      {'color': 'red', 'text': 'Red'},
      {'color': 'amber', 'text': 'Amber'},
      {'color': 'green', 'text': 'Green'},
    ]);

    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Add New ${_selectedTab == 'multiple_choice' ? 'Multiple Choice' : _selectedTab == 'Multi_Sel' ? 'Multi Select' : _selectedTab == 'true_false' ? 'True/False' : _selectedTab == 'rag' ? 'RAG Assessment' : 'Voice Input'} Question',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedQuestionType,
                decoration: InputDecoration(
                  labelText: 'Question Type',
                  border: OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(value: 'multiple_choice', child: Text('Multiple Choice')),
                  DropdownMenuItem(value: 'Multi_Sel', child: Text('Multi Select')),
                  DropdownMenuItem(value: 'true_false', child: Text('True/False')),
                  DropdownMenuItem(value: 'rag', child: Text('RAG Assessment')),
                  DropdownMenuItem(value: 'voice', child: Text('Voice Input')),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedQuestionType = value!;
                    if (value == 'true_false') {
                      optionsNotifier.value = ['true', 'false'];
                      selectedAnswersNotifier.value = ['true'];
                    } else if (value == 'rag') {
                      subcategoriesNotifier.value = [
                        {
                          'name': '',
                          'options': [
                            {'color': 'red', 'text': 'Red'},
                            {'color': 'amber', 'text': 'Amber'},
                            {'color': 'green', 'text': 'Green'}
                          ]
                        }
                      ];
                    } else if (value == 'voice') {
                      optionsNotifier.value = [];
                      selectedAnswersNotifier.value = [];
                    } else {
                      optionsNotifier.value = ['', ''];
                      selectedAnswersNotifier.value = value == 'Multi_Sel' ? [] : [''];
                    }
                  });
                },
              ),
              SizedBox(height: 16),
              TextField(
                controller: questionController,
                decoration: InputDecoration(
                  labelText: 'Question',
                  border: OutlineInputBorder(),
                ),
                maxLines: null,
              ),
              SizedBox(height: 16),
              if (selectedQuestionType == 'rag') ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Subcategories:', style: TextStyle(fontWeight: FontWeight.w500)),
                    TextButton.icon(
                      icon: Icon(Icons.add),
                      label: Text('Add Subcategory'),
                      onPressed: () {
                        setState(() {
                          subcategoriesNotifier.value = [
                            ...subcategoriesNotifier.value,
                            {
                              'name': '',
                              'options': [
                                {'color': 'red', 'text': 'Red'},
                                {'color': 'amber', 'text': 'Amber'},
                                {'color': 'green', 'text': 'Green'}
                              ]
                            }
                          ];
                        });
                      },
                    ),
                  ],
                ),
                ValueListenableBuilder<List<Map<String, dynamic>>>(
                  valueListenable: subcategoriesNotifier,
                  builder: (context, subcategories, _) {
                    return Column(
                      children: [
                        ...List.generate(
                          subcategories.length,
                          (i) => Padding(
                            padding: EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    initialValue: subcategories[i]['name'] as String,
                                    decoration: InputDecoration(
                                      labelText: 'Subcategory ${i + 1}',
                                      border: OutlineInputBorder(),
                                    ),
                                    onChanged: (value) {
                                      var newSubcategories = List<Map<String, dynamic>>.from(subcategories);
                                      newSubcategories[i] = {
                                        ...newSubcategories[i],
                                        'name': value,
                                        'options': [
                                          {'color': 'red', 'text': 'Red'},
                                          {'color': 'amber', 'text': 'Amber'},
                                          {'color': 'green', 'text': 'Green'}
                                        ]
                                      };
                                      subcategoriesNotifier.value = newSubcategories;
                                    },
                                  ),
                                ),
                                SizedBox(width: 16),
                                // RAG Options
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey[300]!),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
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
                                ),
                                if (subcategories.length > 1)
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      setState(() {
                                        var newSubcategories = List<Map<String, dynamic>>.from(subcategories);
                                        newSubcategories.removeAt(i);
                                        subcategoriesNotifier.value = newSubcategories;
                                      });
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ] else if (selectedQuestionType != 'voice' && selectedQuestionType != 'true_false') ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Options:', style: TextStyle(fontWeight: FontWeight.w500)),
                    TextButton.icon(
                      icon: Icon(Icons.add),
                      label: Text('Add Option'),
                      onPressed: () {
                        setState(() {
                          optionsNotifier.value = [...optionsNotifier.value, ''];
                        });
                      },
                    ),
                  ],
                ),
                ValueListenableBuilder<List<String>>(
                  valueListenable: optionsNotifier,
                  builder: (context, options, _) {
                    return Column(
                      children: [
                        ...List.generate(
                          options.length,
                          (i) => Card(
                            margin: EdgeInsets.only(bottom: 8),
                            child: Padding(
                              padding: EdgeInsets.all(8),
                              child: Row(
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${i + 1}',
                                        style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: TextFormField(
                                      initialValue: options[i],
                                      decoration: InputDecoration(
                                        hintText: 'Enter option ${i + 1}',
                                        border: OutlineInputBorder(),
                                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      ),
                                      onChanged: (value) {
                                        var newOptions = List<String>.from(options);
                                        newOptions[i] = value;
                                        optionsNotifier.value = newOptions;
                                        
                                        // Update selected answers if the edited option was an answer
                                        if (selectedQuestionType == 'Multi_Sel') {
                                          var currentAnswers = List<String>.from(selectedAnswersNotifier.value);
                                          int answerIndex = currentAnswers.indexOf(options[i]);
                                          if (answerIndex != -1) {
                                            currentAnswers[answerIndex] = value;
                                            selectedAnswersNotifier.value = currentAnswers;
                                          }
                                        } else if (selectedAnswersNotifier.value.first == options[i]) {
                                          selectedAnswersNotifier.value = [value];
                                        }
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  if (selectedQuestionType == 'Multi_Sel')
                                    ValueListenableBuilder<List<String>>(
                                      valueListenable: selectedAnswersNotifier,
                                      builder: (context, selectedAnswers, _) {
                                        return Checkbox(
                                          value: selectedAnswers.contains(options[i]),
                                          activeColor: Theme.of(context).primaryColor,
                                          onChanged: (bool? value) {
                                            if (value == true) {
                                              selectedAnswersNotifier.value = [...selectedAnswers, options[i]];
                                            } else {
                                              selectedAnswersNotifier.value = selectedAnswers.where((answer) => answer != options[i]).toList();
                                            }
                                          },
                                        );
                                      },
                                    )
                                  else
                                    ValueListenableBuilder<List<String>>(
                                      valueListenable: selectedAnswersNotifier,
                                      builder: (context, selectedAnswers, _) {
                                        return Radio<String>(
                                          value: options[i],
                                          groupValue: selectedAnswers.first,
                                          activeColor: Theme.of(context).primaryColor,
                                          onChanged: (value) {
                                            if (value != null) {
                                              selectedAnswersNotifier.value = [value];
                                            }
                                          },
                                        );
                                      },
                                    ),
                                  if (options.length > 2)
                                    IconButton(
                                      icon: Icon(Icons.delete, color: Colors.red),
                                      tooltip: 'Remove option',
                                      onPressed: () {
                                        var newOptions = List<String>.from(options);
                                        
                                        // Remove the option from selected answers if it was selected
                                        if (selectedQuestionType == 'Multi_Sel') {
                                          var currentAnswers = List<String>.from(selectedAnswersNotifier.value);
                                          currentAnswers.remove(options[i]);
                                          selectedAnswersNotifier.value = currentAnswers;
                                        } else if (selectedAnswersNotifier.value.first == options[i]) {
                                          selectedAnswersNotifier.value = [''];
                                        }
                                        
                                        newOptions.removeAt(i);
                                        optionsNotifier.value = newOptions;
                                      },
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: () {
                            optionsNotifier.value = [...options, ''];
                          },
                          icon: Icon(Icons.add),
                          label: Text('Add Option'),
                        ),
                      ],
                    );
                  },
                ),
              ] else if (selectedQuestionType == 'true_false') ...[
                Text('Select Answer:', style: TextStyle(fontWeight: FontWeight.w500)),
                ValueListenableBuilder<List<String>>(
                  valueListenable: selectedAnswersNotifier,
                  builder: (context, selectedAnswers, _) {
                    return Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: Text('True'),
                            value: 'true',
                            groupValue: selectedAnswers.first,
                            onChanged: (value) {
                              selectedAnswersNotifier.value = [value!];
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: Text('False'),
                            value: 'false',
                            groupValue: selectedAnswers.first,
                            onChanged: (value) {
                              selectedAnswersNotifier.value = [value!];
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      // Show confirmation dialog before canceling
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Cancel Editing'),
                          content: Text('Are you sure you want to cancel? All changes will be lost.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(); // Close dialog
                              },
                              child: Text('No'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(); // Close dialog
                                setState(() {
                                  _isAddingNew = false;
                                });
                              },
                              child: Text('Yes'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Text('Cancel'),
                  ),
                  SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (questionController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Question cannot be empty')),
                        );
                        return;
                      }

                      Map<String, dynamic> newQuestion;
                      if (selectedQuestionType == 'rag') {
                        List<Map<String, dynamic>> validSubcategories = subcategoriesNotifier.value
                            .where((subcat) => subcat['name'] != '').toList();

                        if (validSubcategories.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Please add at least one subcategory')),
                          );
                          return;
                        }

                        newQuestion = {
                          'ques': questionController.text.trim(),
                          'ques_type': 'rag',
                          'subcategories': validSubcategories,
                          'ques_no': 1,
                        };
                      } else if (selectedQuestionType == 'voice') {
                        newQuestion = {
                          'ques': questionController.text.trim(),
                          'ques_type': 'voice',
                          'ques_no': 1,
                        };
                      } else {
                        if (selectedQuestionType != 'true_false') {
                          List<String> validOptions = optionsNotifier.value
                              .where((text) => text.isNotEmpty)
                              .toList();

                          if (validOptions.length < 2) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Please add at least two options')),
                            );
                            return;
                          }

                          if (selectedAnswersNotifier.value.isEmpty || 
                              (selectedQuestionType != 'Multi_Sel' && selectedAnswersNotifier.value.first.isEmpty)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Please select an answer')),
                            );
                            return;
                          }

                          newQuestion = {
                            'ques': questionController.text.trim(),
                            'ques_type': selectedQuestionType,
                            'options': validOptions,
                            'answer': selectedQuestionType == 'Multi_Sel'
                                ? selectedAnswersNotifier.value
                                : selectedAnswersNotifier.value.first,
                            'ques_no': 1,
                          };
                        } else {
                          newQuestion = {
                            'ques': questionController.text.trim(),
                            'ques_type': selectedQuestionType,
                            'options': ['true', 'false'],
                            'answer': selectedAnswersNotifier.value.first,
                            'ques_no': 1,
                          };
                        }
                      }

                      // Set the question number
                      newQuestion['ques_no'] = 1;
                      
                      // For RAG questions, ensure subcategories have the correct structure
                      if (newQuestion['ques_type'] == 'rag') {
                        List<Map<String, dynamic>> subcategories = (newQuestion['subcategories'] as List).map((subcat) {
                          if (subcat is Map<String, dynamic>) {
                            return subcat;
                          } else {
                            return {
                              'name': subcat,
                              'options': [
                                {'color': 'red', 'text': 'Red'},
                                {'color': 'amber', 'text': 'Amber'},
                                {'color': 'green', 'text': 'Green'}
                              ]
                            };
                          }
                        }).toList();
                        newQuestion['subcategories'] = subcategories;
                      }
                      
                      final docId = selectedQuestionType == 'multiple_choice'
                          ? 'zdD79hpJJxCq9mOtp33I'
                          : selectedQuestionType == 'Multi_Sel'
                              ? 'UQvys4UKzeM4MnBbnr0j'
                              : selectedQuestionType == 'true_false'
                                  ? 've27tEYc0wAE7bFLtubm'
                                  : selectedQuestionType == 'rag'
                                      ? '6eyyZYQ4ChVXmf0GCCRjv'
                                      : 'G8b65NreEfHWeWhFiQop';

                      _addNewQuestion(newQuestion, docId);
                    },
                    child: Text('Add Question'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _addNewQuestion(Map<String, dynamic> newQuestion, String docId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('Question_bank')
          .doc(docId)
          .get();
      
      if (!doc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Document not found')),
        );
        return;
      }

      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      List<dynamic> questions = List.from(data['questions'] ?? []);
      
      newQuestion['ques_no'] = questions.length + 1;
      questions.add(newQuestion);

      await _firestore
          .collection('Question_bank')
          .doc(docId)
          .update({
        'questions': questions,
      });

      setState(() {
        _isAddingNew = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Question added successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding question: $e')),
      );
    }
  }

  Widget _buildQuestionEditor(Map<String, dynamic> question, String docId, int index) {
    TextEditingController questionController = TextEditingController(text: question['ques']);
    ValueNotifier<List<String>> optionsNotifier = ValueNotifier<List<String>>(
      question['options'] != null ? List<String>.from(question['options']) : []
    );
    ValueNotifier<List<String>> selectedAnswersNotifier = ValueNotifier<List<String>>(
      question['answer'] is List ? List<String>.from(question['answer']) : [question['answer']?.toString() ?? '']
    );
    ValueNotifier<List<Map<String, dynamic>>> subcategoriesNotifier = ValueNotifier<List<Map<String, dynamic>>>(
      question['ques_type'] == 'rag'
          ? List<Map<String, dynamic>>.from(question['subcategories'] as List)
          : [
              {
                'name': '',
                'options': [
                  {'color': 'red', 'text': 'Red'},
                  {'color': 'amber', 'text': 'Amber'},
                  {'color': 'green', 'text': 'Green'}
                ]
              }
            ]
    );

    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: questionController,
            decoration: InputDecoration(
              labelText: 'Question',
              border: OutlineInputBorder(),
            ),
            maxLines: null,
          ),
          SizedBox(height: 16),
          // Only show options for non-voice type questions
          if (question['options'] != null)
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Options:', style: TextStyle(fontWeight: FontWeight.w500)),
                  SizedBox(height: 8),
                  ValueListenableBuilder<List<String>>(
                    valueListenable: optionsNotifier,
                    builder: (context, options, _) {
                      return Column(
                        children: [
                          ...List.generate(
                            options.length,
                            (i) => Card(
                              margin: EdgeInsets.only(bottom: 8),
                              child: Padding(
                                padding: EdgeInsets.all(8),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${i + 1}',
                                          style: TextStyle(
                                            color: Theme.of(context).primaryColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: TextFormField(
                                        initialValue: options[i],
                                        decoration: InputDecoration(
                                          hintText: 'Enter option ${i + 1}',
                                          border: OutlineInputBorder(),
                                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        ),
                                        onChanged: (value) {
                                          var newOptions = List<String>.from(options);
                                          newOptions[i] = value;
                                          optionsNotifier.value = newOptions;
                                          
                                          // Update selected answers if the edited option was an answer
                                          if (question['ques_type'] == 'Multi_Sel') {
                                            var currentAnswers = List<String>.from(selectedAnswersNotifier.value);
                                            int answerIndex = currentAnswers.indexOf(options[i]);
                                            if (answerIndex != -1) {
                                              currentAnswers[answerIndex] = value;
                                              selectedAnswersNotifier.value = currentAnswers;
                                            }
                                          } else if (selectedAnswersNotifier.value.first == options[i]) {
                                            selectedAnswersNotifier.value = [value];
                                          }
                                        },
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    if (question['ques_type'] == 'Multi_Sel')
                                      ValueListenableBuilder<List<String>>(
                                        valueListenable: selectedAnswersNotifier,
                                        builder: (context, selectedAnswers, _) {
                                          return Checkbox(
                                            value: selectedAnswers.contains(options[i]),
                                            activeColor: Theme.of(context).primaryColor,
                                            onChanged: (bool? value) {
                                              if (value == true) {
                                                selectedAnswersNotifier.value = [...selectedAnswers, options[i]];
                                              } else {
                                                selectedAnswersNotifier.value = selectedAnswers.where((answer) => answer != options[i]).toList();
                                              }
                                            },
                                          );
                                        },
                                      )
                                    else
                                      ValueListenableBuilder<List<String>>(
                                        valueListenable: selectedAnswersNotifier,
                                        builder: (context, selectedAnswers, _) {
                                          return Radio<String>(
                                            value: options[i],
                                            groupValue: selectedAnswers.first,
                                            activeColor: Theme.of(context).primaryColor,
                                            onChanged: (value) {
                                              if (value != null) {
                                                selectedAnswersNotifier.value = [value];
                                              }
                                            },
                                          );
                                        },
                                      ),
                                    if (options.length > 2)
                                      IconButton(
                                        icon: Icon(Icons.delete, color: Colors.red),
                                        tooltip: 'Remove option',
                                        onPressed: () {
                                          var newOptions = List<String>.from(options);
                                          
                                          // Remove the option from selected answers if it was selected
                                          if (question['ques_type'] == 'Multi_Sel') {
                                            var currentAnswers = List<String>.from(selectedAnswersNotifier.value);
                                            currentAnswers.remove(options[i]);
                                            selectedAnswersNotifier.value = currentAnswers;
                                          } else if (selectedAnswersNotifier.value.first == options[i]) {
                                            selectedAnswersNotifier.value = [''];
                                          }
                                          
                                          newOptions.removeAt(i);
                                          optionsNotifier.value = newOptions;
                                        },
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          OutlinedButton.icon(
                            onPressed: () {
                              optionsNotifier.value = [...options, ''];
                            },
                            icon: Icon(Icons.add),
                            label: Text('Add Option'),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          if (question['ques_type'] == 'rag') ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Subcategories:', style: TextStyle(fontWeight: FontWeight.w500)),
                TextButton.icon(
                  icon: Icon(Icons.add),
                  label: Text('Add Subcategory'),
                  onPressed: () {
                    var newSubcategories = List<Map<String, dynamic>>.from(subcategoriesNotifier.value);
                    newSubcategories.add({
                      'name': '',
                      'options': [
                        {'color': 'red', 'text': 'Red'},
                        {'color': 'amber', 'text': 'Amber'},
                        {'color': 'green', 'text': 'Green'}
                      ]
                    });
                    subcategoriesNotifier.value = newSubcategories;
                  },
                ),
              ],
            ),
            ValueListenableBuilder<List<Map<String, dynamic>>>(
              valueListenable: subcategoriesNotifier,
              builder: (context, subcategories, _) {
                return Column(
                  children: [
                    ...List.generate(
                      subcategories.length,
                      (i) => Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                initialValue: subcategories[i]['name'] as String,
                                decoration: InputDecoration(
                                  labelText: 'Subcategory ${i + 1}',
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: (value) {
                                  var newSubcategories = List<Map<String, dynamic>>.from(subcategories);
                                  newSubcategories[i] = {
                                    ...newSubcategories[i],
                                    'name': value,
                                  };
                                  subcategoriesNotifier.value = newSubcategories;
                                },
                              ),
                            ),
                            SizedBox(width: 16),
                            // RAG Options
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
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
                            ),
                            if (subcategories.length > 1)
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  var newSubcategories = List<Map<String, dynamic>>.from(subcategories);
                                  newSubcategories.removeAt(i);
                                  subcategoriesNotifier.value = newSubcategories;
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Cancel Editing'),
                      content: Text('Are you sure you want to cancel? All changes will be lost.'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Close dialog
                          },
                          child: Text('No'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Close dialog
                            setState(() {
                              _selectedQuestion = null;
                              _selectedIndex = null;
                            });
                          },
                          child: Text('Yes'),
                        ),
                      ],
                    ),
                  );
                },
                child: Text('Cancel'),
              ),
              SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  if (questionController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Question cannot be empty')),
                    );
                    return;
                  }

                  Map<String, dynamic> updatedQuestion = {
                    'ques': questionController.text.trim(),
                    'ques_type': question['ques_type'],
                    'ques_no': question['ques_no'],
                  };

                  if (question['ques_type'] == 'voice') {
                    updatedQuestion['options'] = [];
                    updatedQuestion['answer'] = '';
                  } else if (question['ques_type'] == 'rag') {
                    List<Map<String, dynamic>> validSubcategories = subcategoriesNotifier.value
                        .where((subcat) => subcat['name'].toString().trim().isNotEmpty)
                        .toList();

                    if (validSubcategories.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please add at least one subcategory')),
                      );
                      return;
                    }

                    updatedQuestion['subcategories'] = validSubcategories;
                  } else if (question['ques_type'] == 'true_false') {
                    updatedQuestion['options'] = ['True', 'False'];
                    updatedQuestion['answer'] = selectedAnswersNotifier.value.first;
                  } else {
                    // For multiple choice and multi-select
                    List<String> validOptions = optionsNotifier.value
                        .where((option) => option.trim().isNotEmpty)
                        .toList();

                    if (validOptions.length < 2) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please add at least two options')),
                      );
                      return;
                    }

                    // Validate that all selected answers exist in the options
                    List<String> validAnswers = selectedAnswersNotifier.value
                        .where((answer) => validOptions.contains(answer))
                        .toList();

                    if (validAnswers.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please select at least one answer')),
                      );
                      return;
                    }

                    updatedQuestion['options'] = validOptions;
                    updatedQuestion['answer'] = question['ques_type'] == 'Multi_Sel' 
                        ? validAnswers 
                        : validAnswers.first;
                  }

                  _updateQuestion(docId, index, updatedQuestion);
                },
                child: Text('Save'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _updateQuestion(String docId, int index, Map<String, dynamic> updatedQuestion) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('Question_bank').doc(docId).get();
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      List<dynamic> questions = List.from(data['questions'] ?? []);
      
      // Ensure proper structure for voice questions
      if (updatedQuestion['ques_type'] == 'voice') {
        updatedQuestion['options'] = [];
        updatedQuestion['answer'] = '';
      }
      
      questions[index] = updatedQuestion;

      await _firestore.collection('Question_bank').doc(docId).update({
        'questions': questions,
      });

      setState(() {
        _selectedQuestion = null;
        _selectedIndex = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Question updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating question: $e')),
      );
    }
  }

  Widget _buildQuestionCard(Map<String, dynamic> question, String docId, int index) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            title: Text(question['ques'] ?? ''),
            subtitle: Text('Type: ${question['ques_type']?.toString().toUpperCase() ?? ''}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    setState(() {
                      _selectedQuestion = Map<String, dynamic>.from(question);
                      _selectedIndex = index;
                    });
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteQuestion(docId, index),
                ),
              ],
            ),
          ),
          if (question['options'] != null)
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Options:', style: TextStyle(fontWeight: FontWeight.w500)),
                  SizedBox(height: 8),
                  ...List.generate(
                    (question['options'] as List).length,
                    (optionIndex) => Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Text(
                            '${optionIndex + 1}. ${question['options'][optionIndex]}',
                            style: TextStyle(
                              color: question['answer'] is List
                                  ? (question['answer'] as List).contains(question['options'][optionIndex])
                                      ? Colors.green
                                      : Colors.black87
                                  : question['answer'] == question['options'][optionIndex]
                                      ? Colors.green
                                      : Colors.black87,
                              fontWeight: question['answer'] is List
                                  ? (question['answer'] as List).contains(question['options'][optionIndex])
                                      ? FontWeight.w600
                                      : FontWeight.normal
                                  : question['answer'] == question['options'][optionIndex]
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                            ),
                          ),
                          if (question['answer'] is List
                              ? (question['answer'] as List).contains(question['options'][optionIndex])
                              : question['answer'] == question['options'][optionIndex])
                            Padding(
                              padding: EdgeInsets.only(left: 8),
                              child: Icon(Icons.check_circle, color: Colors.green, size: 16),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (_selectedIndex == index && _selectedQuestion != null)
            _buildQuestionEditor(_selectedQuestion!, docId, index),
        ],
      ),
    );
  }

  Future<void> _deleteQuestion(String docId, int index) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('Question_bank').doc(docId).get();
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      List<dynamic> questions = List.from(data['questions'] ?? []);
      questions.removeAt(index);
      await _firestore.collection('Question_bank').doc(docId).update({
        'questions': questions,
      });
      setState(() {
        _selectedQuestion = null;
        _selectedIndex = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Question deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting question: $e')),
      );
    }
  }

  void _showAddQuestionDialog() {
    String selectedQuestionType = 'multiple_choice';
    TextEditingController questionController = TextEditingController();
    ValueNotifier<List<String>> optionsNotifier = ValueNotifier<List<String>>(['', '']);
    ValueNotifier<List<String>> selectedAnswersNotifier = ValueNotifier<List<String>>(['']);
    ValueNotifier<List<Map<String, dynamic>>> subcategoriesNotifier = ValueNotifier<List<Map<String, dynamic>>>([
      {
        'name': '',
        'options': [
          {'color': 'red', 'text': 'Red'},
          {'color': 'amber', 'text': 'Amber'},
          {'color': 'green', 'text': 'Green'}
        ]
      }
    ]);
    ValueNotifier<List<Map<String, String>>> ragOptionsNotifier = ValueNotifier<List<Map<String, String>>>([
      {'color': 'red', 'text': 'Red'},
      {'color': 'amber', 'text': 'Amber'},
      {'color': 'green', 'text': 'Green'},
    ]);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Add New Question'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedQuestionType,
                    decoration: InputDecoration(
                      labelText: 'Question Type',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem(value: 'multiple_choice', child: Text('Multiple Choice')),
                      DropdownMenuItem(value: 'Multi_Sel', child: Text('Multi Select')),
                      DropdownMenuItem(value: 'true_false', child: Text('True/False')),
                      DropdownMenuItem(value: 'rag', child: Text('RAG Assessment')),
                      DropdownMenuItem(value: 'voice', child: Text('Voice Input')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedQuestionType = value!;
                        if (value == 'true_false') {
                          optionsNotifier.value = ['true', 'false'];
                          selectedAnswersNotifier.value = ['true'];
                        } else if (value == 'rag') {
                          subcategoriesNotifier.value = [
                            {
                              'name': '',
                              'options': [
                                {'color': 'red', 'text': 'Red'},
                                {'color': 'amber', 'text': 'Amber'},
                                {'color': 'green', 'text': 'Green'}
                              ]
                            }
                          ];
                        } else if (value == 'voice') {
                          optionsNotifier.value = [];
                          selectedAnswersNotifier.value = [];
                        } else {
                          optionsNotifier.value = ['', ''];
                          selectedAnswersNotifier.value = value == 'Multi_Sel' ? [] : [''];
                        }
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: questionController,
                    decoration: InputDecoration(
                      labelText: 'Question',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: null,
                  ),
                  SizedBox(height: 16),
                  if (selectedQuestionType == 'rag') ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Subcategories:', style: TextStyle(fontWeight: FontWeight.w500)),
                        TextButton.icon(
                          icon: Icon(Icons.add),
                          label: Text('Add Subcategory'),
                          onPressed: () {
                            setState(() {
                              subcategoriesNotifier.value = [
                                ...subcategoriesNotifier.value,
                                {
                                  'name': '',
                                  'options': [
                                    {'color': 'red', 'text': 'Red'},
                                    {'color': 'amber', 'text': 'Amber'},
                                    {'color': 'green', 'text': 'Green'}
                                  ]
                                }
                              ];
                            });
                          },
                        ),
                      ],
                    ),
                    ValueListenableBuilder<List<Map<String, dynamic>>>(
                      valueListenable: subcategoriesNotifier,
                      builder: (context, subcategories, _) {
                        return Column(
                          children: [
                            ...List.generate(
                              subcategories.length,
                              (i) => Padding(
                                padding: EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        initialValue: subcategories[i]['name'] as String,
                                        decoration: InputDecoration(
                                          labelText: 'Subcategory ${i + 1}',
                                          border: OutlineInputBorder(),
                                        ),
                                        onChanged: (value) {
                                          var newSubcategories = List<Map<String, dynamic>>.from(subcategories);
                                          newSubcategories[i] = {
                                            ...newSubcategories[i],
                                            'name': value,
                                            'options': [
                                              {'color': 'red', 'text': 'Red'},
                                              {'color': 'amber', 'text': 'Amber'},
                                              {'color': 'green', 'text': 'Green'}
                                            ]
                                          };
                                          subcategoriesNotifier.value = newSubcategories;
                                        },
                                      ),
                                    ),
                                    SizedBox(width: 16),
                                    // RAG Options
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 8),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey[300]!),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
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
                                    ),
                                    if (subcategories.length > 1)
                                      IconButton(
                                        icon: Icon(Icons.delete, color: Colors.red),
                                        onPressed: () {
                                          setState(() {
                                            var newSubcategories = List<Map<String, dynamic>>.from(subcategories);
                                            newSubcategories.removeAt(i);
                                            subcategoriesNotifier.value = newSubcategories;
                                          });
                                        },
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ] else if (selectedQuestionType != 'voice' && selectedQuestionType != 'true_false') ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Options:', style: TextStyle(fontWeight: FontWeight.w500)),
                        TextButton.icon(
                          icon: Icon(Icons.add),
                          label: Text('Add Option'),
                          onPressed: () {
                            setState(() {
                              optionsNotifier.value = [...optionsNotifier.value, ''];
                            });
                          },
                        ),
                      ],
                    ),
                    ValueListenableBuilder<List<String>>(
                      valueListenable: optionsNotifier,
                      builder: (context, options, _) {
                        return Column(
                          children: [
                            ...List.generate(
                              options.length,
                              (i) => Card(
                                margin: EdgeInsets.only(bottom: 8),
                                child: Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${i + 1}',
                                            style: TextStyle(
                                              color: Theme.of(context).primaryColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: TextFormField(
                                          initialValue: options[i],
                                          decoration: InputDecoration(
                                            hintText: 'Enter option ${i + 1}',
                                            border: OutlineInputBorder(),
                                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          ),
                                          onChanged: (value) {
                                            var newOptions = List<String>.from(options);
                                            newOptions[i] = value;
                                            optionsNotifier.value = newOptions;
                                            
                                            // Update selected answers if the edited option was an answer
                                            if (selectedQuestionType == 'Multi_Sel') {
                                              var currentAnswers = List<String>.from(selectedAnswersNotifier.value);
                                              int answerIndex = currentAnswers.indexOf(options[i]);
                                              if (answerIndex != -1) {
                                                currentAnswers[answerIndex] = value;
                                                selectedAnswersNotifier.value = currentAnswers;
                                              }
                                            } else if (selectedAnswersNotifier.value.first == options[i]) {
                                              selectedAnswersNotifier.value = [value];
                                            }
                                          },
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      if (selectedQuestionType == 'Multi_Sel')
                                        ValueListenableBuilder<List<String>>(
                                          valueListenable: selectedAnswersNotifier,
                                          builder: (context, selectedAnswers, _) {
                                            return Checkbox(
                                              value: selectedAnswers.contains(options[i]),
                                              activeColor: Theme.of(context).primaryColor,
                                              onChanged: (bool? value) {
                                                if (value == true) {
                                                  selectedAnswersNotifier.value = [...selectedAnswers, options[i]];
                                                } else {
                                                  selectedAnswersNotifier.value = selectedAnswers.where((answer) => answer != options[i]).toList();
                                                }
                                              },
                                            );
                                          },
                                        )
                                      else
                                        ValueListenableBuilder<List<String>>(
                                          valueListenable: selectedAnswersNotifier,
                                          builder: (context, selectedAnswers, _) {
                                            return Radio<String>(
                                              value: options[i],
                                              groupValue: selectedAnswers.first,
                                              activeColor: Theme.of(context).primaryColor,
                                              onChanged: (value) {
                                                if (value != null) {
                                                  selectedAnswersNotifier.value = [value];
                                                }
                                              },
                                            );
                                          },
                                        ),
                                      if (options.length > 2)
                                        IconButton(
                                          icon: Icon(Icons.delete, color: Colors.red),
                                          tooltip: 'Remove option',
                                          onPressed: () {
                                            var newOptions = List<String>.from(options);
                                            
                                            // Remove the option from selected answers if it was selected
                                            if (selectedQuestionType == 'Multi_Sel') {
                                              var currentAnswers = List<String>.from(selectedAnswersNotifier.value);
                                              currentAnswers.remove(options[i]);
                                              selectedAnswersNotifier.value = currentAnswers;
                                            } else if (selectedAnswersNotifier.value.first == options[i]) {
                                              selectedAnswersNotifier.value = [''];
                                            }
                                            
                                            newOptions.removeAt(i);
                                            optionsNotifier.value = newOptions;
                                          },
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 8),
                            OutlinedButton.icon(
                              onPressed: () {
                                optionsNotifier.value = [...options, ''];
                              },
                              icon: Icon(Icons.add),
                              label: Text('Add Option'),
                            ),
                          ],
                        );
                      },
                    ),
                  ] else if (selectedQuestionType == 'true_false') ...[
                    Text('Select Answer:', style: TextStyle(fontWeight: FontWeight.w500)),
                    ValueListenableBuilder<List<String>>(
                      valueListenable: selectedAnswersNotifier,
                      builder: (context, selectedAnswers, _) {
                        return Row(
                          children: [
                            Expanded(
                              child: RadioListTile<String>(
                                title: Text('True'),
                                value: 'true',
                                groupValue: selectedAnswers.first,
                                onChanged: (value) {
                                  selectedAnswersNotifier.value = [value!];
                                },
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<String>(
                                title: Text('False'),
                                value: 'false',
                                groupValue: selectedAnswers.first,
                                onChanged: (value) {
                                  selectedAnswersNotifier.value = [value!];
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (questionController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please enter a question')),
                    );
                    return;
                  }

                  // Create question data based on type
                  Map<String, dynamic> newQuestion = {
                    'ques': questionController.text,
                    'ques_type': selectedQuestionType,
                  };

                  if (selectedQuestionType == 'voice') {
                    newQuestion['options'] = [];
                    newQuestion['answer'] = '';
                  } else if (selectedQuestionType == 'rag') {
                    List<Map<String, dynamic>> validSubcategories = subcategoriesNotifier.value
                        .where((subcat) => subcat['name'] != '').toList();

                    if (validSubcategories.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please add at least one subcategory')),
                      );
                      return;
                    }

                    newQuestion['subcategories'] = validSubcategories;
                  } else if (selectedQuestionType != 'true_false') {
                    List<String> validOptions = optionsNotifier.value
                        .where((text) => text.isNotEmpty)
                        .toList();

                    if (validOptions.length < 2) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please add at least two options')),
                      );
                      return;
                    }

                    if (selectedAnswersNotifier.value.isEmpty || 
                        (selectedQuestionType != 'Multi_Sel' && selectedAnswersNotifier.value.first.isEmpty)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please select an answer')),
                      );
                      return;
                    }

                    newQuestion['options'] = validOptions;
                    newQuestion['answer'] = selectedQuestionType == 'Multi_Sel'
                        ? selectedAnswersNotifier.value
                        : selectedAnswersNotifier.value.first;
                  } else {
                    if (selectedAnswersNotifier.value.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please select true or false')),
                      );
                      return;
                    }

                    newQuestion['options'] = ['true', 'false'];
                    newQuestion['answer'] = selectedAnswersNotifier.value.first;
                  }

                  final docId = selectedQuestionType == 'multiple_choice'
                      ? 'zdD79hpJJxCq9mOtp33I'
                      : selectedQuestionType == 'Multi_Sel'
                          ? 'UQvys4UKzeM4MnBbnr0j'
                          : selectedQuestionType == 'true_false'
                              ? 've27tEYc0wAE7bFLtubm'
                              : selectedQuestionType == 'rag'
                                  ? '6eyyZYQ4ChVXmf0GCCRjv'
                                  : 'G8b65NreEfHWeWhFiQop';

                  _addQuestion(newQuestion, docId);
                  Navigator.pop(context);
                },
                child: Text('Add Question'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _addQuestion(Map<String, dynamic> newQuestion, String docId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('Question_bank')
          .doc(docId)
          .get();
      
      if (!doc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Document not found')),
        );
        return;
      }

      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      List<dynamic> questions = List.from(data['questions'] ?? []);
      
      newQuestion['ques_no'] = questions.length + 1;
      questions.add(newQuestion);

      await _firestore
          .collection('Question_bank')
          .doc(docId)
          .update({
        'questions': questions,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Question added successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding question: $e')),
      );
    }
  }
}

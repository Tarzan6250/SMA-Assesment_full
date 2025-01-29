import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TestEdit extends StatefulWidget {
  @override
  _TestEditState createState() => _TestEditState();
}

class _TestEditState extends State<TestEdit> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? _selectedQuestion;
  int? _selectedIndex;
  bool _isAddingNew = false;
  String _selectedTab = 'multiple_choice';

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Edit Test Questions'),
          bottom: TabBar(
            onTap: (index) {
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
          children: [
            _buildQuestionList('zdD79hpJJxCq9mOtp33I'),
            _buildQuestionList('UQvys4UKzeM4MnBbnr0j'),
            _buildQuestionList('ve27tEYc0wAE7bFLtubm'),
            _buildQuestionList('6eyyZYQ4ChVXmf0GCCRjv'),
            _buildQuestionList('G8b65NreEfHWeWhFiQop'),
          ],
        ),
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
                      selectedAnswersNotifier.value = [''];
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
                          (i) => Padding(
                            padding: EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    initialValue: options[i],
                                    decoration: InputDecoration(
                                      labelText: 'Option ${i + 1}',
                                      border: OutlineInputBorder(),
                                    ),
                                    onChanged: (value) {
                                      var newOptions = List<String>.from(options);
                                      newOptions[i] = value;
                                      optionsNotifier.value = newOptions;
                                    },
                                  ),
                                ),
                                if (selectedQuestionType == 'Multi_Sel')
                                  ValueListenableBuilder<List<String>>(
                                    valueListenable: selectedAnswersNotifier,
                                    builder: (context, selectedAnswers, _) {
                                      return Checkbox(
                                        value: selectedAnswers.contains(options[i]),
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
                                else if (selectedQuestionType == 'multiple_choice')
                                  ValueListenableBuilder<List<String>>(
                                    valueListenable: selectedAnswersNotifier,
                                    builder: (context, selectedAnswers, _) {
                                      return Radio<String>(
                                        value: options[i],
                                        groupValue: selectedAnswers.first,
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
                                    onPressed: () {
                                      setState(() {
                                        var newOptions = List<String>.from(options);
                                        newOptions.removeAt(i);
                                        optionsNotifier.value = newOptions;
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
                      setState(() {
                        _isAddingNew = false;
                      });
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
      question['options']?.cast<String>() ?? []
    );
    ValueNotifier<List<String>> selectedAnswersNotifier = ValueNotifier<List<String>>(
      question['ques_type'] == 'Multi_Sel' 
          ? List<String>.from(question['answer'] as List)
          : [question['answer'].toString()]
    );
    ValueNotifier<List<Map<String, dynamic>>> subcategoriesNotifier = ValueNotifier<List<Map<String, dynamic>>>(
      question['ques_type'] == 'rag'
          ? List<Map<String, dynamic>>.from(question['subcategories'] as List)
          : []
    );

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
                'Edit ${question['ques_type'] == 'multiple_choice' ? 'Multiple Choice' : question['ques_type'] == 'Multi_Sel' ? 'Multi Select' : question['ques_type'] == 'true_false' ? 'True/False' : question['ques_type'] == 'rag' ? 'RAG Assessment' : 'Voice Input'} Question',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
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
              if (question['ques_type'] == 'rag') ...[
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
              ] else if (question['ques_type'] != 'true_false') ...[
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
                          (i) => Padding(
                            padding: EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    initialValue: options[i],
                                    decoration: InputDecoration(
                                      labelText: 'Option ${i + 1}',
                                      border: OutlineInputBorder(),
                                    ),
                                    onChanged: (value) {
                                      var newOptions = List<String>.from(options);
                                      newOptions[i] = value;
                                      
                                      // Update selected answers if option text changes
                                      if (question['ques_type'] == 'Multi_Sel') {
                                        var newAnswers = selectedAnswersNotifier.value.map((answer) {
                                          return answer == options[i] ? value : answer;
                                        }).toList();
                                        selectedAnswersNotifier.value = newAnswers;
                                      } else if (selectedAnswersNotifier.value.first == options[i]) {
                                        selectedAnswersNotifier.value = [value];
                                      }
                                    },
                                  ),
                                ),
                                if (question['ques_type'] == 'Multi_Sel')
                                  ValueListenableBuilder<List<String>>(
                                    valueListenable: selectedAnswersNotifier,
                                    builder: (context, selectedAnswers, _) {
                                      return Checkbox(
                                        value: selectedAnswers.contains(options[i]),
                                        onChanged: (bool? value) {
                                          var newSelectedAnswers = List<String>.from(selectedAnswers);
                                          if (value == true) {
                                            newSelectedAnswers.add(options[i]);
                                          } else {
                                            newSelectedAnswers.remove(options[i]);
                                          }
                                          selectedAnswersNotifier.value = newSelectedAnswers;
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
                                    onPressed: () {
                                      setState(() {
                                        var newOptions = List<String>.from(options);
                                        newOptions.removeAt(i);
                                        optionsNotifier.value = newOptions;
                                        
                                        // Remove from selected answers if deleted
                                        if (question['ques_type'] == 'Multi_Sel') {
                                          selectedAnswersNotifier.value = selectedAnswersNotifier.value
                                              .where((answer) => answer != options[i])
                                              .toList();
                                        } else if (selectedAnswersNotifier.value.first == options[i]) {
                                          selectedAnswersNotifier.value = [''];
                                        }
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
              ] else ...[
                Text('Select Answer:', style: TextStyle(fontWeight: FontWeight.w500)),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: Text('True'),
                        value: 'true',
                        groupValue: selectedAnswersNotifier.value.first,
                        onChanged: (value) {
                          setState(() {
                            selectedAnswersNotifier.value = [value!];
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: Text('False'),
                        value: 'false',
                        groupValue: selectedAnswersNotifier.value.first,
                        onChanged: (value) {
                          setState(() {
                            selectedAnswersNotifier.value = [value!];
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedQuestion = null;
                        _selectedIndex = null;
                      });
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

                      if (question['ques_type'] != 'true_false') {
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
                            (question['ques_type'] != 'Multi_Sel' && selectedAnswersNotifier.value.first.isEmpty)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Please select an answer')),
                          );
                          return;
                        }

                        Map<String, dynamic> updatedQuestion = {
                          'ques': questionController.text.trim(),
                          'ques_type': question['ques_type'],
                          'options': validOptions,
                          'answer': question['ques_type'] == 'Multi_Sel' 
                              ? selectedAnswersNotifier.value 
                              : selectedAnswersNotifier.value.first,
                          'ques_no': question['ques_no'],
                        };

                        _updateQuestion(docId, index, updatedQuestion);
                      } else {
                        if (selectedAnswersNotifier.value.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Please select true or false')),
                          );
                          return;
                        }

                        Map<String, dynamic> updatedQuestion = {
                          'ques': questionController.text.trim(),
                          'ques_type': question['ques_type'],
                          'options': ['true', 'false'],
                          'answer': selectedAnswersNotifier.value.first,
                          'ques_no': question['ques_no'],
                        };

                        _updateQuestion(docId, index, updatedQuestion);
                      }
                    },
                    child: Text('Save Changes'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _updateQuestion(String docId, int index, Map<String, dynamic> updatedQuestion) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('Question_bank')
          .doc(docId)
          .get();
      
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      List<dynamic> questions = List.from(data['questions'] ?? []);
      
      // Update the question at the specified index
      questions[index] = updatedQuestion;

      await _firestore
          .collection('Question_bank')
          .doc(docId)
          .update({
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
                          selectedAnswersNotifier.value = [''];
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
                              (i) => Padding(
                                padding: EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        initialValue: options[i],
                                        decoration: InputDecoration(
                                          labelText: 'Option ${i + 1}',
                                          border: OutlineInputBorder(),
                                        ),
                                        onChanged: (value) {
                                          var newOptions = List<String>.from(options);
                                          newOptions[i] = value;
                                          optionsNotifier.value = newOptions;
                                        },
                                      ),
                                    ),
                                    if (selectedQuestionType == 'Multi_Sel')
                                      ValueListenableBuilder<List<String>>(
                                        valueListenable: selectedAnswersNotifier,
                                        builder: (context, selectedAnswers, _) {
                                          return Checkbox(
                                            value: selectedAnswers.contains(options[i]),
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
                                    else if (selectedQuestionType == 'multiple_choice')
                                      ValueListenableBuilder<List<String>>(
                                        valueListenable: selectedAnswersNotifier,
                                        builder: (context, selectedAnswers, _) {
                                          return Radio<String>(
                                            value: options[i],
                                            groupValue: selectedAnswers.first,
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
                                        onPressed: () {
                                          setState(() {
                                            var newOptions = List<String>.from(options);
                                            newOptions.removeAt(i);
                                            optionsNotifier.value = newOptions;
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
              ElevatedButton(
                onPressed: () async {
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

                  await _addQuestion(newQuestion, docId);
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

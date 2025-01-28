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
      length: 3,
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
                        : 'true_false';
                _selectedQuestion = null;
                _selectedIndex = null;
                _isAddingNew = false;
              });
            },
            tabs: [
              Tab(text: 'Multiple Choice'),
              Tab(text: 'Multi Select'),  
              Tab(text: 'True/False'),
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
    TextEditingController questionController = TextEditingController();
    ValueNotifier<List<String>> optionsNotifier = ValueNotifier<List<String>>(['', '', '', '']);
    ValueNotifier<List<String>> selectedAnswersNotifier = ValueNotifier<List<String>>([]);  
    ValueNotifier<String> selectedAnswerNotifier = ValueNotifier<String>('');  

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
                'Add New ${_selectedTab == 'multiple_choice' ? 'Multiple Choice' : _selectedTab == 'Multi_Sel' ? 'Multi Select' : 'True/False'} Question',
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
              if (_selectedTab == 'multiple_choice' || _selectedTab == 'Multi_Sel') ...[
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
                SizedBox(height: 8),
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
                                if (_selectedTab == 'Multi_Sel')
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
                                  ValueListenableBuilder<String>(
                                    valueListenable: selectedAnswerNotifier,
                                    builder: (context, selectedAnswer, _) {
                                      return Radio<String>(
                                        value: options[i],
                                        groupValue: selectedAnswer,
                                        onChanged: (value) {
                                          selectedAnswerNotifier.value = value!;
                                        },
                                      );
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
                        groupValue: selectedAnswerNotifier.value,
                        onChanged: (value) {
                          setState(() {
                            selectedAnswerNotifier.value = value!;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: Text('False'),
                        value: 'false',
                        groupValue: selectedAnswerNotifier.value,
                        onChanged: (value) {
                          setState(() {
                            selectedAnswerNotifier.value = value!;
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

                      if (_selectedTab == 'multiple_choice') {
                        List<String> validOptions = optionsNotifier.value
                            .where((text) => text.isNotEmpty)
                            .toList();

                        if (validOptions.length < 2) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Please add at least two options')),
                          );
                          return;
                        }

                        if (selectedAnswerNotifier.value.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Please select an answer')),
                          );
                          return;
                        }

                        Map<String, dynamic> newQuestion = {
                          'ques': questionController.text.trim(),
                          'ques_type': _selectedTab,
                          'options': validOptions,
                          'answer': selectedAnswerNotifier.value,
                        };

                        _addNewQuestion(newQuestion);
                      } else if (_selectedTab == 'Multi_Sel') {
                        List<String> validOptions = optionsNotifier.value
                            .where((text) => text.isNotEmpty)
                            .toList();

                        if (validOptions.length < 2) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Please add at least two options')),
                          );
                          return;
                        }

                        if (selectedAnswersNotifier.value.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Please select at least one answer')),
                          );
                          return;
                        }

                        Map<String, dynamic> newQuestion = {
                          'ques': questionController.text.trim(),
                          'ques_type': _selectedTab,
                          'options': validOptions,
                          'answer': selectedAnswersNotifier.value,
                        };

                        _addNewQuestion(newQuestion);
                      } else {
                        if (selectedAnswerNotifier.value.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Please select true or false')),
                          );
                          return;
                        }

                        Map<String, dynamic> newQuestion = {
                          'ques': questionController.text.trim(),
                          'ques_type': _selectedTab,
                          'options': ['true', 'false'],
                          'answer': selectedAnswerNotifier.value,
                        };

                        _addNewQuestion(newQuestion);
                      }
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

  Future<void> _addNewQuestion(Map<String, dynamic> newQuestion) async {
    try {
      final docId = newQuestion['ques_type'] == 'multiple_choice' 
          ? 'zdD79hpJJxCq9mOtp33I' 
          : newQuestion['ques_type'] == 'Multi_Sel' 
              ? 'UQvys4UKzeM4MnBbnr0j' 
              : 've27tEYc0wAE7bFLtubm';

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
                'Edit ${question['ques_type'] == 'multiple_choice' ? 'Multiple Choice' : question['ques_type'] == 'Multi_Sel' ? 'Multi Select' : 'True/False'} Question',
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
              if (question['ques_type'] != 'true_false') ...[
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
                SizedBox(height: 8),
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
}

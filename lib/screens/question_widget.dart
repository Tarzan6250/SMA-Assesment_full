import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'test_edit.dart';

class QuestionWidget extends StatefulWidget {
  final Map<String, dynamic> question;
  final Function handleNextSlide;
  final Function handlePreviousSlide;
  final bool isLastQuestion;
  final bool isFirstQuestion;
  final Function handleSubmit;
  final dynamic selectedAnswer;
  final Function(dynamic) onAnswerSelected;

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
  _QuestionWidgetState createState() => _QuestionWidgetState();
}

class _QuestionWidgetState extends State<QuestionWidget> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _voiceText = '';
  TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.question['ques_type'] == 'voice') {
      _initSpeech();
    }
    if (widget.selectedAnswer != null && widget.question['ques_type'] == 'text') {
      _textController.text = widget.selectedAnswer.toString();
    }
  }

  Future<void> _initSpeech() async {
    var status = await Permission.microphone.request();
    if (status.isGranted) {
      bool available = await _speech.initialize();
      if (mounted) {
        setState(() {
          if (available && widget.selectedAnswer != null) {
            _voiceText = widget.selectedAnswer.toString();
          }
        });
      }
    }
  }

  void _startListening() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (result) {
            setState(() {
              _voiceText = result.recognizedWords;
              widget.onAnswerSelected(_voiceText);
            });
          },
        );
      }
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  Widget _buildRAGQuestion() {
    List<Map<String, dynamic>> subcategories = 
        List<Map<String, dynamic>>.from(widget.question['subcategories'] ?? []);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...subcategories.map((subcat) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subcat['name'] ?? '',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    _buildRAGButton('R', Colors.red, subcat['name']),
                    SizedBox(width: 12),
                    _buildRAGButton('A', Colors.amber, subcat['name']),
                    SizedBox(width: 12),
                    _buildRAGButton('G', Colors.green, subcat['name']),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildRAGButton(String label, Color color, String subcategory) {
    Map<String, String> currentAnswers = 
        Map<String, String>.from(widget.selectedAnswer ?? {});
    bool isSelected = currentAnswers[subcategory] == label;

    return InkWell(
      onTap: () {
        Map<String, String> newAnswers = Map.from(currentAnswers);
        newAnswers[subcategory] = label;
        widget.onAnswerSelected(newAnswers);
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String questionType = widget.question['ques_type'] ?? 'text';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                widget.question['ques'] ?? '',
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
            controller: _textController,
            decoration: InputDecoration(
              hintText: 'Enter your answer',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => widget.onAnswerSelected(value),
          )
        else if (questionType == 'voice')
          Column(
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  children: [
                    Text(
                      _voiceText.isEmpty ? 'Tap the microphone to start speaking' : _voiceText,
                      style: GoogleFonts.poppins(fontSize: 16),
                    ),
                    SizedBox(height: 16),
                    IconButton(
                      icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
                      onPressed: _isListening ? _stopListening : _startListening,
                      color: _isListening ? Theme.of(context).primaryColor : Colors.grey,
                      iconSize: 36,
                    ),
                  ],
                ),
              ),
            ],
          )
        else if (questionType == 'rag')
          _buildRAGQuestion()
        else if (widget.question['options'] != null)
          ...List.generate(
            (widget.question['options'] as List).length,
            (index) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: InkWell(
                onTap: () => widget.onAnswerSelected(index),
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: widget.selectedAnswer == index
                          ? Theme.of(context).primaryColor
                          : Colors.grey[300]!,
                      width: 2,
                    ),
                    color: widget.selectedAnswer == index
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
                              color: widget.selectedAnswer == index
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey[400]!,
                              width: 2,
                            ),
                            color: widget.selectedAnswer == index
                                ? Theme.of(context).primaryColor
                                : Colors.white,
                          ),
                          child: widget.selectedAnswer == index
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
                              color: widget.selectedAnswer == index
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey[400]!,
                              width: 2,
                            ),
                            color: widget.selectedAnswer == index
                                ? Theme.of(context).primaryColor
                                : Colors.white,
                          ),
                          child: widget.selectedAnswer == index
                              ? Icon(
                                  Icons.check,
                                  size: 16,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      Expanded(
                        child: Text(
                          widget.question['options'][index].toString(),
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: widget.selectedAnswer == index
                                ? Theme.of(context).primaryColor
                                : Colors.black87,
                            fontWeight: widget.selectedAnswer == index
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
            if (!widget.isFirstQuestion)
              ElevatedButton(
                onPressed: () => widget.handlePreviousSlide(),
                child: Text('Previous'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            if (!widget.isLastQuestion)
              ElevatedButton(
                onPressed: () => widget.handleNextSlide(),
                child: Text('Next'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            if (widget.isLastQuestion)
              ElevatedButton(
                onPressed: () => widget.handleSubmit(),
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

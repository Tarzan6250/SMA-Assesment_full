import 'package:cloud_firestore/cloud_firestore.dart';

class QuestionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<QuerySnapshot> getTrueFalseQuestions() async {
    return await _firestore.collection('true_false_questions').get();
  }

  Future<QuerySnapshot> getMultipleChoiceQuestions() async {
    return await _firestore.collection('multiple_choice_questions').get();
  }

  Future<List<Map<String, dynamic>>> getAllQuestions() async {
    List<Map<String, dynamic>> allQuestions = [];
    
    try {
      // Get true/false questions
      final trueFalseSnapshot = await getTrueFalseQuestions();
      for (var doc in trueFalseSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        allQuestions.add(data);
      }

      // Get multiple choice questions
      final multipleChoiceSnapshot = await getMultipleChoiceQuestions();
      for (var doc in multipleChoiceSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        allQuestions.add(data);
      }

      // Shuffle questions for randomization
      allQuestions.shuffle();
      return allQuestions;
    } catch (e) {
      print('Error getting questions: $e');
      return [];
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:learning_app/score_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';

class TestPage extends StatefulWidget {
  final String topic;

  const TestPage({super.key, required this.topic});

  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  final FlutterTts flutterTts = FlutterTts();
  final TextEditingController _answerController = TextEditingController(); // Controller for the text field
  int currentQuestionIndex = 0;
  int score = 0;

  String ageGroup = "";
  String currentWord = "";
  String difficulty = "";

  // final List<Map<String, dynamic>> questions = [
  //   {
  //     "question": "Spell the word 'Apple'",
  //     "answer": "apple",
  //   },
  //   {
  //     "question": "Spell the word 'Banana'",
  //     "answer": "banana",
  //   },
  //   {
  //     "question": "Spell the word 'Elephant'",
  //     "answer": "elephant",
  //   },
  // ];

  @override
  void initState() {
    super.initState();
    initializeTts();
    fetchRandomSpellingWord();; // Speak the first question when the page loads
  }

  Future<void> initializeTts() async {
    await flutterTts.setLanguage("en-US"); // Set language
    await flutterTts.setSpeechRate(0.5); // Set speech rate (0.0 to 1.0)
    await flutterTts.setVolume(1.0); // Set volume (0.0 to 1.0)
    await flutterTts.setPitch(1.0); // Set pitch (0.5 to 2.0)
  }

  Future<void> speak(String text) async {
    await flutterTts.speak(text); // Speak the text
  }

  Future<void> fetchRandomSpellingWord() async {
    final response = await http.get(Uri.parse('http://127.0.0.1:5000/api/random-spelling-word'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        ageGroup = data ['Age Group'];
        currentWord = data['Word'];
        difficulty = data['Difficulty Level'];
      });
      speak("Spell the word $currentWord"); // Speak the word
    } else {
      throw Exception('Failed to load word');
    }
  }

  void checkAnswer() {
    String userAnswer = _answerController.text.trim(); // Get the user's answer
    if (userAnswer.toLowerCase() == currentWord.toLowerCase()) {
      setState(() {
        score++;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Wrong answer! Try again."),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }

    if (currentQuestionIndex < 9) { //  10 questions per test
      setState(() {
        currentQuestionIndex++;
      });
      _answerController.clear(); // Clear the text field
      fetchRandomSpellingWord(); // Fetch and speak the next word
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ScorePage(score: score, total: 10), // as 10 questions per test
        ),
      );
    }
  }

  @override
  void dispose() {
    flutterTts.stop(); // Stop TTS when the widget is disposed
    _answerController.dispose(); // Dispose the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.topic)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Align vertically in the center
          children: [
            SizedBox(
              width: 300, // Set a fixed width for the text field
              child: TextField(
                controller: _answerController, // Connect the controller to the text field
                decoration: const InputDecoration(
                  hintText: "Type your answer here",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 24), // Add spacing between the text field and buttons
            ElevatedButton(
              onPressed: checkAnswer, // Submit the answer
              child: const Text("Submit",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.purple),
                ),

            ),
            const SizedBox(height: 10), // Add spacing between the buttons
            ElevatedButton(
              onPressed: () => speak("Spell the word $currentWord"), // Allow the student to replay the question
              child: const Text("Listen Again",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.purple),
                ),
            ),
          ],
        ),
      ),
    );
  }
}
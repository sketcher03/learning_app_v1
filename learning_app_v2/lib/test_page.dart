import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:learning_app/score_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';

class TestPage extends StatefulWidget {
  final String topic;
  final String ageGroup;

  //const TestPage({super.key, required this.topic, required String ageGroup});
  const TestPage({super.key, required this.ageGroup, required this.topic});

  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  final FlutterTts flutterTts = FlutterTts();
  final TextEditingController _answerController = TextEditingController(); // Controller for the text field


  String currentDifficulty = "easy";
  int currentTestNumber = 1; // Test number within the difficulty (1 to 3)
  int currentQuestionIndex = 0;
  List<int> testScores = []; // Stores scores for the current difficulty level
  int score = 0;
  bool isLoading = false; 

  String ageGroup = "";
  String currentWord = "";
  String difficulty = "";

  // @override
  // void initState() {
  //   super.initState();
  //   initializeTts();
  //   fetchRandomSpellingWord();; // Speak the first question when the page loads
  // }

    @override
    void initState() {
      super.initState();
      ageGroup = widget.ageGroup; // Set ageGroup from widget
      currentDifficulty = "easy";
      initializeTts();
      fetchRandomSpellingWord();
    }

  Future<void> initializeTts() async {
    await flutterTts.setLanguage("en-US"); // Set language
    await flutterTts.setSpeechRate(0.001); // Set speech rate (0.0 to 1.0)
    await flutterTts.setVolume(1.0); // Set volume (0.0 to 1.0)
    await flutterTts.setPitch(0.5); // Set pitch (0.5 to 2.0)
  }

  Future<void> speak(String text) async {
    await flutterTts.speak(text); // Speak the text
  }

  // Future<void> fetchRandomSpellingWord() async {
  //   final response = await http.get(Uri.parse('http://10.0.2.2:5000/api/random-spelling-word'));
  //   if (response.statusCode == 200) {
  //     final data = json.decode(response.body);
  //     print("$data");
  //     setState(() {
  //       ageGroup = data['Age Group'];
  //       currentWord = data['Word'];
  //       difficulty = data['Difficulty Level'];
  //     });
  //     speak("Spell the word $currentWord"); // Speak the word
  //   } else {
  //     throw Exception('Failed to load word');
  //   }
  // }

  Future<void> fetchRandomSpellingWord() async {
  setState(() {
    isLoading = true;
  });
  try {
    final response = await http.get(
            Uri.parse('http://10.0.2.2:5000/api/random-spelling-word?age_group=$ageGroup&difficulty=$currentDifficulty'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print("$data");


      print("ageGroup= $ageGroup");


      setState(() {
        ageGroup = data['Age Group'];
        currentWord = data['Word'];
        difficulty = data['Difficulty Level'];
        isLoading = false;
      });
      print("ageGroup= $ageGroup");


      speak("Spell the word $currentWord");

      
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to fetch word. Please try again."),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  } catch (e) {
    setState(() {
      isLoading = false;
    });
    print("Error fetching word: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("An error occurred. Please check your connection."),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
  }
}

  void checkAnswer() {
    String userAnswer = _answerController.text.trim(); // Get the user's answer
    if (userAnswer.toLowerCase() == currentWord.toLowerCase()) {
      setState(() {
        score++;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
        content: Text("Correct answer!"),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
      );
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
    } 
  //else {
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) => ScorePage(score: score, total: 10), // as 10 questions per test
  //       ),
  //     );
  //   }
  // }

  // difficulty starts

  else {
    // Test completed
    setState(() {
      testScores.add(score); // Save the score for the current test
      currentQuestionIndex = 0; // Reset question index for the next test
      score = 0; // Reset score for the next test
    });

    // Check if 3 tests are completed
    if (testScores.length == 3) {
      double averageScore = testScores.reduce((a, b) => a + b) / 30; // Calculate average score (out of 10)
      if (averageScore >= 0.8) {
        // Promote to the next level
        if (currentDifficulty == "easy") {
          setState(() {
            currentDifficulty = "moderate";
            currentTestNumber = 1;
            testScores = [];
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Congratulations! You have been promoted to the moderate level."),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        } else if (currentDifficulty == "moderate") {
          setState(() {
            currentDifficulty = "hard";
            currentTestNumber = 1;
            testScores = [];
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Congratulations! You have been promoted to the hard level."),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        } else if (currentDifficulty == "hard") {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Congratulations! You have completed all levels."),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        // Retry the same level
        setState(() {
          currentTestNumber = 1;
          testScores = [];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("You need to score at least 80% to proceed to the next level. Retrying..."),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } else {
      // Move to the next test
      setState(() {
        currentTestNumber++;
      });
    }

    // Fetch the first word for the next test
    fetchRandomSpellingWord();
  }
}

// difficulty ends

  @override
  void dispose() {
    flutterTts.stop(); // Stop TTS when the widget is disposed
    _answerController.dispose(); // Dispose the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.topic)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Align vertically in the center
          children: [
            Text(
              "Level: ${currentDifficulty.toUpperCase()} | Test: $currentTestNumber",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
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
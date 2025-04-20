import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'score_page.dart';

class TestPage extends StatefulWidget {
  final String topic;
  final String ageGroup;
  final String difficulty;

  //const TestPage({super.key, required this.topic, required String ageGroup});
  const TestPage(
      {super.key,
      required this.ageGroup,
      required this.topic,
      required this.difficulty});

  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  final FlutterTts flutterTts = FlutterTts();
  final TextEditingController _answerController =
      TextEditingController(); // Controller for the text field

  String currentDifficulty =
      "easy"; // Test number within the difficulty (1 to 3)
  int currentQuestionIndex = 0;
  List<String> userAnswers = [];
  List<String> correctWords = [];
  // List<int> testScores = []; // Stores scores for the current difficulty level
  int score = 0;
  bool isLoading = false;

  String ageGroup = "";
  String currentWord = "";
  String difficulty = "";
  String topic = "";

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
    topic = widget.topic;
    currentDifficulty = widget.difficulty;
    initializeTts();
    fetchRandomSpellingWords();
  }

  Future<void> initializeTts() async {
    await flutterTts.setLanguage("en-US"); // Set language
    await flutterTts.setVolume(1.0); // Set volume (0.0 to 1.0)
    await flutterTts.setPitch(1.0); // Set pitch (0.5 to 2.0)
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

  Future<void> fetchRandomSpellingWords() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.get(
        Uri.parse(
            'http://10.0.2.2:5000/api/random-spelling-word?age_group=$ageGroup&difficulty=$currentDifficulty'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        print("ageGroup= $ageGroup");

        setState(() {
          ageGroup = data['Age Group'];

          correctWords = List<String>.from(data['words']);
          currentWord = correctWords[currentQuestionIndex];

          difficulty = data['Difficulty Level'];
          isLoading = false;
        });

        speak("Spell the word. $currentWord");
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

    userAnswers.add(userAnswer); // Store the user's answer

    if (userAnswer.toLowerCase() ==
        correctWords[currentQuestionIndex].toLowerCase()) {
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

    if (currentQuestionIndex < 9) {
      //  10 questions per test
      setState(() {
        currentQuestionIndex++;
      });
      _answerController.clear(); // Clear the text field
      setState(() {
        currentWord = correctWords[currentQuestionIndex];
      });
      speak("Spell the word, $currentWord");
    } else {
      submitTest(); // Submit the test after all answers are collected
    }
  }

  Future<void> submitTest() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:5000/api/submit_answers'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'age_group': ageGroup,
          'difficulty': currentDifficulty,
          'user_answers': userAnswers,
          'correct_words': correctWords,
          'score': score,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          isLoading = false;
        });

        print(data['errors']);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ScorePage(
                score: data['score'],
                total: 10,
                errors: List<Map<String, String>>.from(
                  data['errors'].map((error) {
                    return {
                      'correct_word': error['Correct Word'].toString(),
                      'answer_cleaned': error['Answer'].toString(),
                      'cook_error_desc': error['Cook Error Description'].toString(),
                      'cook_error_message': error['Cook Error Message'].toString(),
                      'edit_distance_desc': error['Edit Distance Description'].toString(),
                      'edit_distance_message': error['Edit Distance Message'].toString(),
                      'length_diff_desc': error['Length Diff Description'].toString(),
                      'length_diff_message': error['Length Diff Message'].toString(),
                      'jaccard_message': error['Jaccard Message'].toString(),
                      'jaccard_desc': error['Jaccard Description'].toString(),
                      'common_desc': error['Common PreSuf Description'].toString(),
                      'phonetic_desc': error['Phonetic Description'].toString(),
                      'phonetic_message': error['Phonetic Message'].toString(),
                      'double_letter_desc': error['Double Letter Description'].toString(),
                      'double_letter_message': error['Double Letter Message'].toString(),
                      'word_info_desc': error['Word Information'].toString(),
                    };
                  }),
                ),
                currentAgeGroup: ageGroup,
                currentDifficulty: currentDifficulty,
                topic: topic),
          ),
        );
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to submit answers. Please try again."),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error submitting answers: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("An error occurred. Please check your connection."),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  /*
  void showErrorList(List<dynamic> errors) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Errors in your answers"),
          content: Column(
            children: errors.map((error) {
              return Text(
                "Word: ${error['word']} | Error: ${error['description']}",
                style: TextStyle(color: Colors.red),
              );
            }).toList(),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
  */

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
          mainAxisAlignment:
              MainAxisAlignment.center, // Align vertically in the center
          children: [
            Text(
              "Test: ${currentDifficulty.toUpperCase()} | Question: ${currentQuestionIndex + 1}",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              width: 300, // Set a fixed width for the text field
              child: TextField(
                controller:
                    _answerController, // Connect the controller to the text field
                decoration: const InputDecoration(
                  hintText: "Type your answer here",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(
                height: 24), // Add spacing between the text field and buttons
            ElevatedButton(
              onPressed: checkAnswer, // Submit the answer
              child: const Text(
                "Submit",
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 39, 176, 50)),
              ),
            ),
            const SizedBox(height: 10), // Add spacing between the buttons
            ElevatedButton(
              onPressed: () => speak(
                  "Spell the word. $currentWord"), // Allow the student to replay the question
              child: const Text(
                "Listen Again",
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

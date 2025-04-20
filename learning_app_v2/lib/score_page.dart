// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'test_page.dart';

class ScorePage extends StatelessWidget {
  final int score;
  final int total;
  final List<Map<String, String>> errors;
  final String currentAgeGroup;
  final String currentDifficulty;
  final String topic;

  ScorePage({
    super.key,
    required this.score,
    required this.total,
    required this.errors,
    required this.currentAgeGroup,
    required this.currentDifficulty,
    required this.topic,
  });

  double get percentage => (score / total) * 100;

  String newDifficulty = '';
  String newAgeGroup = '';

  // Function to decide the next difficulty and age group
  void setNextDifficulty() {
    if (percentage >= 80) {
      return _setNextDifficulty();
    } else if (percentage < 30) {
      return _setPreviousDifficulty();
    } else {
      newDifficulty = currentDifficulty; // Stay in the same difficulty
    }
  }

  void _setNextDifficulty() {
    if (currentDifficulty == 'easy') {
      newDifficulty = 'moderate';
    } else if (currentDifficulty == 'moderate') {
      newDifficulty = 'hard';
    } else {
      newDifficulty = 'hard'; // Already at the hardest difficulty
    }
  }

  void _setPreviousDifficulty() {
    if (currentDifficulty == 'hard') {
      newDifficulty = 'moderate';
    } else if (currentDifficulty == 'moderate') {
      newDifficulty = 'easy';
    } else {
      newDifficulty = 'easy'; // Already at the easiest difficulty
    }
  }

  void setNextAgeGroup() {
    // Check the current age group and difficulty
    if (currentAgeGroup == '5-6 years' &&
        currentDifficulty == 'easy' &&
        percentage < 30) {
      newAgeGroup =
          '5-6 years'; // Stay in the lowest age group if failing at easy difficulty in 5-6
      newDifficulty == 'easy';
    } else if (currentAgeGroup == '11-12 years' &&
        currentDifficulty == 'hard' &&
        percentage >= 80) {
      newAgeGroup =
          '11-12 years'; // Stay in the highest age group after completing hard difficulty in 11-12
      newDifficulty == 'hard';
    } else if (percentage >= 80 && currentDifficulty == 'hard') {
      newDifficulty = 'easy';
      return _setNextAgeGroup(); // Move to the next age group if passing at hard difficulty
    } else if (percentage < 30 && currentDifficulty == 'easy') {
      newDifficulty = 'hard';
      return _setPreviousAgeGroup(); // Move to the previous age group if failing at easy difficulty
    } else {
      newAgeGroup = currentAgeGroup;
      return setNextDifficulty();
    }
  }

  void _setNextAgeGroup() {
    print("Current Age Group $currentAgeGroup");

    if (currentAgeGroup == '5-6 years') {
      newAgeGroup = '7-8 years';
    } else if (currentAgeGroup == '7-8 years') {
      newAgeGroup = '9-10 years';
    } else if (currentAgeGroup == '9-10 years') {
      newAgeGroup = '11-12 years';
    } else {
      newAgeGroup = currentAgeGroup; // Already at the highest age group
    }
  }

  void _setPreviousAgeGroup() {
    if (currentAgeGroup == '11-12 years') {
      newAgeGroup = '9-10 years';
    } else if (currentAgeGroup == '9-10 years') {
      newAgeGroup = '7-8 years';
    } else if (currentAgeGroup == '7-8 years') {
      newAgeGroup = '5-6 years';
    } else {
      newAgeGroup = currentAgeGroup; // Already at the highest age group
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Score"),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Display the score and percentage
            _buildScoreSummary(),

            const SizedBox(height: 10),

            // Display errors if there are any
            if (errors.isNotEmpty) ...[
              const Text(
                "Comprehensive Report:",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _buildErrorList(),
            ],

            const SizedBox(height: 20),

            // Button to take another test
            _buildTakeAnotherTestButton(context),

            /*
            ElevatedButton(
              onPressed: () {
                setNextAgeGroup();
                // Take the user back to the test page with updated difficulty and age group
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TestPage(
                      topic: topic,
                      ageGroup: newAgeGroup,
                      difficulty: newDifficulty,
                    ),
                  ),
                );
              },
              child: const Text(
                "Take Another Test",
                style: TextStyle(fontSize: 20),
              ),
            ),
            */
            const SizedBox(height: 10),

            // Button to navigate back to the home screen
            _buildBackToHomeButton(context),
          ],
        ),
      ),
    );
  }

  // Score Summary Widget
  Widget _buildScoreSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "Your Score: $score / $total",
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 1),
        Text(
          "Percentage: ${percentage.toStringAsFixed(2)}%",
          style: const TextStyle(fontSize: 20, color: Colors.green),
        ),
        const Divider(
          height: 50,
          color: Colors.grey,
        ),
      ],
    );
  }

  // Button to take another test
  Widget _buildTakeAnotherTestButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        setNextAgeGroup();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TestPage(
              topic: topic,
              ageGroup: newAgeGroup,
              difficulty: newDifficulty,
            ),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
        textStyle: const TextStyle(fontSize: 18),
      ),
      child: const Text(
        "Take Another Test",
        style: TextStyle(fontSize: 20),
      ),
    );
  }

  // Button to go back to home
  Widget _buildBackToHomeButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.popUntil(context, (route) => route.isFirst);
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
        textStyle: const TextStyle(fontSize: 18),
      ),
      child: const Text(
        "Back to Home",
        style: TextStyle(fontSize: 20),
      ),
    );
  }

  // Display the error report in a list of collapsible cards (ExpansionTile)
  Widget _buildErrorList() {
    return Column(
      children: errors.map((error) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 5),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: ExpansionTile(
              title: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Correct Word: ${error['correct_word']}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 53, 53, 53),
                    ),
                  ),
                  Text(
                    "Your Answer: ${error['answer_cleaned']}",
                    style: TextStyle(
                      fontSize: 16,
                      color: error['correct_word'] == error['answer_cleaned']
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                ],
              ),
              subtitle: error['correct_word'] == error['answer_cleaned']
                  ? const Icon(
                      Icons.check_circle_outlined,
                      color: Color.fromARGB(255, 81, 173, 84),
                    )
                  : const Icon(
                      Icons.clear_outlined,
                      color: Colors.red,
                    ),
              trailing: const Icon(Icons.arrow_drop_down), // See more icon
              children: [
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: _buildErrorDetails(error),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // Display detailed error information for each error
  Widget _buildErrorDetails(Map<String, String> error) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (error['cook_error_desc'] != null &&
            error['cook_error_message'] != null)
          _buildErrorDescription("Cook Error", error['cook_error_message'],
              error['cook_error_desc']),
        if (error['edit_distance_desc'] != null &&
            error['edit_distance_message'] != null)
          _buildErrorDescription("Edit Distance (Levenshtein)",
              error['edit_distance_message'], error['edit_distance_desc']),
        if (error['length_diff_desc'] != null &&
            error['length_diff_message'] != null)
          _buildErrorDescription("Length Difference",
              error['length_diff_message'], error['length_diff_desc']),
        if (error['jaccard_desc'] != null && error['jaccard_message'] != null)
          _buildErrorDescription("Jaccard Similarity", error['jaccard_message'],
              error['jaccard_desc']),
        if (error['phonetic_desc'] != null && error['phonetic_message'] != null)
          _buildErrorDescription("Phonetic Match", error['phonetic_message'],
              error['phonetic_description']),
        if (error['common_desc'] != null)
          _buildErrorDescription(
              "Common Prefix/Suffix Match", error['common_desc'], ""),
        if (error['double_letter_desc'] != null &&
            error['double_letter_message'] != null)
          _buildErrorDescription("Double Letter Error",
              error['double_letter_message'], error['double_letter_desc']),
        if (error['word_info_desc'] != null)
          _buildErrorDescription(
              "Word Information", error['word_info_desc'], ""),
      ],
    );
  }

  // Widget to display individual error description in one column
  Widget _buildErrorDescription(
      String title, String? message, String? description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title with bold text
          Text(
            "$title:",
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87),
          ),
          const SizedBox(height: 4), // Spacer between title and message

          // Message text
          Text(
            message.toString(),
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
          const SizedBox(height: 4), // Spacer between message and description

          // Description text
          Text(
            description.toString(),
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

}

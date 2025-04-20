import 'package:flutter/material.dart';
import 'package:learning_app/model.dart';
//import 'package:learning_app/test_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'age_Group_page.dart'; // Import the AgeGroup Page

class TopicPage extends StatelessWidget {
  final Subject subject;

  const TopicPage({super.key, required this.subject});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Choose a Topic",
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white
        ),
        child: ListView.builder(
          itemCount: subject.topics.length,
          itemBuilder: (context, index) {
            final topic = subject.topics[index];
            return Card(
              margin: const EdgeInsets.all(20),
              elevation: 2,
              child: ListTile(
                leading: const Icon(Icons.book, color: Colors.deepOrange),
                title: Text(
                  topic,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward, color: Colors.orange),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AgeGroupPage(topic: topic),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
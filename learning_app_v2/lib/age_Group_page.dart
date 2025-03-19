import 'package:flutter/material.dart';
//import 'package:learning_app/topic_page.dart';
import 'test_page.dart'; // Import the TestPage

class AgeGroupPage extends StatelessWidget {
  final dynamic topic;

  const AgeGroupPage({super.key, required this.topic});
  // get age
  get ageGroup => null;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Select Age Group")),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ElevatedButton(
//               onPressed: () {
//                 // Navigate to TestPage with age group "5-6"
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => TestPage(ageGroup: "5-6", topic: topic),
//                   ),
//                 );
//               },
//               child: const Text("5-6 Years"),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 // Navigate to TestPage with age group "7-8"
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => TestPage(ageGroup: ageGroup, topic: topic),
//                   ),
//                 );
//               },
//               child: const Text("7-8 Years"),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 // Navigate to TestPage with age group "9-10"
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => TestPage(ageGroup: "9-10", topic: topic),
//                   ),
//                 );
//               },
//               child: const Text("9-10 Years"),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 // Navigate to TestPage with age group "11-12"
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => TestPage(ageGroup: "11-12", topic: topic),
//                   ),
//                 );
//               },
//               child: const Text("11-12 Years"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

  @override
  Widget build(BuildContext context) {
    List<String> ageGroups = ["5-6 years", "7-8 years", "9-10 years", "11-12 years"]; // Example age groups

    return Scaffold(
      appBar: AppBar(title: Text("Select Age Group")),
      body: ListView.builder(
        itemCount: ageGroups.length,
        itemBuilder: (context, index) {
          String ageGroup = ageGroups[index];
          return Card(
            margin: const EdgeInsets.all(15),
            child: ListTile(
              title: Text(
                ageGroup,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              trailing: const Icon(Icons.arrow_forward, color: Colors.orange),
              onTap: () {
                print("Selected Age Group: $ageGroup"); // Debugging Log
                // Navigate to TestPage and pass topic & ageGroup
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TestPage(topic: topic, ageGroup: ageGroup),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
 //}

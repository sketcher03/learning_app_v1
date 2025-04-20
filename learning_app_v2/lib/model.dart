class Subject {
  final String name;
  final List<String> topics;

  Subject({required this.name, required this.topics});
}

// Sample Data
List<Subject> subjects = [
  Subject(name: "English", topics: ["Spelling", "Grammar"]),
  Subject(name: "Math", topics: ["Addition", "Subtraction", "Multiplication"]),
];
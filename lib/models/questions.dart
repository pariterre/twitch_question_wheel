import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';

class Category {
  String name;
  final List<String> questions;

  Category._({required this.name, List<String>? questions})
      : questions = questions ?? [];

  Map<String, dynamic> serialize() => {'name': name, 'questions': questions};

  static Category _fromSerialized(map) {
    final name = map['name'];

    final questions = <String>[];
    questions.addAll(
        (map['questions'] as List?)?.map<String>((e) => e).toList() ?? []);
    return Category._(name: name, questions: questions);
  }

  void addQuestion(String question) {
    questions.add(question);
  }

  String pickNextQuestion() {
    final questionIndex = Fortune.randomInt(0, questions.length);
    return questions[questionIndex];
  }

  int get length => questions.length;
}

class Questions {
  final List<Category> categories;

  Questions._({required this.categories});

  Map<String, dynamic> serialize() => {
        'categories':
            categories.map((category) => category.serialize()).toList()
      };

  int get length => categories.length;

  static Questions fromSerialized(map) {
    final categories = <Category>[];
    categories.addAll((map['categories'] as List?)
            ?.map((category) => Category._fromSerialized(category)) ??
        []);
    return Questions._(categories: categories);
  }

  void addQuestion(String category, String question) {
    final categoryIndex = categories.indexWhere((c) => c.name == category);
    if (categoryIndex == -1) categories.add(Category._(name: category));

    categories[categoryIndex].addQuestion(question);
  }

  int pickNextCategoryIndex() {
    final categoryIndex = Fortune.randomInt(0, categories.length);
    return categoryIndex;
  }
}

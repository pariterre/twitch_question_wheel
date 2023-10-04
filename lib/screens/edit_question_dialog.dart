import 'package:flutter/material.dart';
import 'package:pomodoro_wheel/models/questions.dart';
import 'package:pomodoro_wheel/providers/app_preferences.dart';

class EditQuestionDialog extends StatelessWidget {
  const EditQuestionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final preferences = AppPreferences.of(context);

    return AlertDialog(
      title: const Text('Éditer les questions'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            ...preferences.questions.categories.map((category) => Column(
                  children: [
                    const SizedBox(height: 24),
                    _buildCategory(context, category),
                    const SizedBox(height: 24),
                    const Divider(),
                  ],
                )),
            _buildAddCategory(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCategory(BuildContext context, Category category) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Text(
              category.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 36.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () async {
                        final controller =
                            TextEditingController(text: category.name);
                        final preferences =
                            AppPreferences.of(context, listen: false);

                        await showDialog<String>(
                            context: context,
                            builder: (context) => AlertDialog(
                                  content: TextField(controller: controller),
                                ));
                        if (controller.text.isEmpty) return;

                        preferences.editCategory(
                            category.name, controller.text);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => AppPreferences.of(context, listen: false)
                          .deleteCategory(category.name),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
        const SizedBox(height: 12),
        ...category.questions
            .map((question) => _buildQuestion(context, category, question)),
        _buildAddQuestion(context, category),
      ],
    );
  }

  Widget _buildAddCategory(BuildContext context) {
    final textEditingController = TextEditingController();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 400,
          child: TextField(
            controller: textEditingController,
            decoration: const InputDecoration(hintText: 'Nouvelle catégorie'),
          ),
        ),
        IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => AppPreferences.of(context, listen: false)
                .addCategory(textEditingController.text)),
      ],
    );
  }

  Widget _buildQuestion(
      BuildContext context, Category category, String question) {
    return Row(
      children: [
        Expanded(child: Text(question)),
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () async {
            final controller = TextEditingController(text: question);
            final preferences = AppPreferences.of(context, listen: false);

            await showDialog<String>(
                context: context,
                builder: (context) => AlertDialog(
                      content: TextField(controller: controller),
                    ));
            if (controller.text.isEmpty) return;

            preferences.editQuestion(category.name, question, controller.text);
          },
        ),
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => AppPreferences.of(context, listen: false)
              .deleteQuestion(category.name, question),
        ),
      ],
    );
  }

  Widget _buildAddQuestion(BuildContext context, Category category) {
    final textEditingController = TextEditingController();
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 500,
            child: TextField(
              controller: textEditingController,
              decoration: const InputDecoration(hintText: 'Nouvelle question'),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => AppPreferences.of(context, listen: false)
                .addQuestion(category.name, textEditingController.text),
          ),
        ],
      ),
    );
  }
}

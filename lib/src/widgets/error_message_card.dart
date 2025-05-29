import 'package:flutter/material.dart';

/// A widget that displays an error message in a card format with an error icon.
class ErrorMessageCard extends StatelessWidget {
  /// The error message to be displayed in the card.
  final String message;

  /// Creates an [ErrorMessageCard] with the specified error message.
  const ErrorMessageCard({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      color: const Color.fromARGB(255, 254, 208, 205),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(
                Icons.error,
                color: Color.fromARGB(255, 164, 47, 39),
              ),
              title: Text(
                message,
                style: textTheme.titleSmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

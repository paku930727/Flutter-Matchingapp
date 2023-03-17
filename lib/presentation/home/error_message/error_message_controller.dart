import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final errorMessageProvider =
    ChangeNotifierProvider.autoDispose((ref) => ErrorMessageController());

class ErrorMessageController extends ChangeNotifier {
  ErrorMessageController();

  var errorMessages = [];

  @override
  void dispose() {
    clearMessages();
    super.dispose();
  }

  void addMessage(String message) {
    errorMessages.add(message);
    notifyListeners();
  }

  void addMessages(List<String> messages) {
    for (var message in messages) {
      errorMessages.add(message);
    }
    notifyListeners();
  }

  void clearMessages() {
    errorMessages = [];
    notifyListeners();
  }
}

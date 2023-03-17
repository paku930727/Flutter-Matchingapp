import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sukimachi/constants.dart';
import 'package:sukimachi/presentation/home/error_message/error_message_controller.dart';

class ErrorMessageWidget extends ConsumerWidget {
  const ErrorMessageWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ErrorMessageController state = ref.watch(errorMessageProvider);
    if (state.errorMessages.isEmpty) {
      return const SizedBox();
    }
    return Column(
      children: state.errorMessages
          .map((message) => Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0),
                child: Container(
                    padding: const EdgeInsets.all(16.0),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: kGreyColor),
                      borderRadius: BorderRadius.circular(10),
                      color: kErrorColor,
                    ),
                    child: Text(
                      message,
                      style: const TextStyle(color: Colors.red),
                    )),
              ))
          .toList(),
    );
  }
}

import 'package:form_field_validator/form_field_validator.dart';

/// TwitterのURLであることを確認するValidator
class TwitterUrlValidator extends TextFieldValidator {
  TwitterUrlValidator({required String errorText}) : super(errorText);

  @override
  bool isValid(String? value) => RegExp(
          r"^https?://twitter\.com/[a-zA-Z0-9.a-zA-Z0-9./:!#$%&'*+-=?^_`{|}~]+$")
      .hasMatch(value!);
}

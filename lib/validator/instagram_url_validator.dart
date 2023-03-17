import 'package:form_field_validator/form_field_validator.dart';

/// InstagramのURLであることを確認するValidator
class InstagramUrlValidator extends TextFieldValidator {
  InstagramUrlValidator({required String errorText}) : super(errorText);

  @override
  bool isValid(String? value) => RegExp(
          r"^https?://www\.instagram\.com/[a-zA-Z0-9.a-zA-Z0-9./:!#$%&'*+-=?^_`{|}~]+$")
      .hasMatch(value!);
}

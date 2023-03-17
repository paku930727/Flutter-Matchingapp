import 'package:form_field_validator/form_field_validator.dart';

/// InstagramのURLであることを確認するValidator
class DateFormatValidator extends TextFieldValidator {
  DateFormatValidator({required String errorText}) : super(errorText);

  @override
  bool isValid(String? value) =>
      RegExp(r"^[0-9]{4}/[0-9]{2}/[0-9]{2}$").hasMatch(value!);
}

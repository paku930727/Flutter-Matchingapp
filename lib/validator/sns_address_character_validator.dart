import 'package:form_field_validator/form_field_validator.dart';

/// SNS Address入力において入力できる文字(半角英数字+記号)を制限するValidator
class SnsAddressCharacterValidator extends TextFieldValidator {
  SnsAddressCharacterValidator({required String errorText}) : super(errorText);

  @override
  bool isValid(String? value) =>
      RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9./:!#$%&'*+-=?^_`{|}~]+$").hasMatch(value!);
}

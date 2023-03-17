import 'package:form_field_validator/form_field_validator.dart';

class PriceValidator extends TextFieldValidator {
  PriceValidator({required String errorText}) : super(errorText);

  @override
  bool isValid(String? value) {
    if (value == null) return false;
    final intValue = () {
      try {
        return int.parse(value);
      } catch (e) {
        return 0;
      }
    }();
    if (intValue < 1000) return false;
    if (intValue % 100 != 0) return false;
    return true;
  }
}

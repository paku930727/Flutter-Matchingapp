import 'package:form_field_validator/form_field_validator.dart';
import 'package:intl/intl.dart';

/// InstagramのURLであることを確認するValidator
class CompareApplicationDeliveryDate extends TextFieldValidator {
  CompareApplicationDeliveryDate({
    required String errorText,
    required this.applicationDate,
  }) : super(errorText);

  /// 応募期限
  final String applicationDate;

  @override
  bool isValid(String? value) {
    DateFormat formattedDate = DateFormat('yyyy/MM/dd');
    final applicationDate = formattedDate.parse(this.applicationDate);
    final deliveryDate = formattedDate.parse(value!);
    return deliveryDate.isAfter(applicationDate);
  }
}

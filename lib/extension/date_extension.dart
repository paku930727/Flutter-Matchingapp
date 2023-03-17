import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

extension DateExtension on DateTime {
  String toFormatString() {
    String formattedDate = DateFormat('yyyy年M月d日 HH:mm').format(this);
    return formattedDate;
  }
}

extension DateExtensionTimestamp on Timestamp {
  String toFormatYMDHmString() {
    String formattedDate = DateFormat('yyyy年M月d日 HH:mm').format(toDate());
    return formattedDate;
  }

  String toFormatYMDString() {
    String formattedDate = DateFormat('yyyy年M月d日').format(toDate());
    return formattedDate;
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

extension TimestampExt on Timestamp {
  DateTime asDateTime() => toDate();
  
  bool isBeforeDate(DateTime other) => toDate().isBefore(other);
  bool isAfterDate(DateTime other) => toDate().isAfter(other);
  
  int get day$ => toDate().day;
  int get month$ => toDate().month;
  int get year$ => toDate().year;
  
  // New extensions for compatibility
  bool isBeforeDateTime(DateTime other) => toDate().isBefore(other);
  int get day => toDate().day;
  int get month => toDate().month;
  int get year => toDate().year;
}

extension DateTimeExt on DateTime {
  Timestamp asTimestamp() => Timestamp.fromDate(this);
}
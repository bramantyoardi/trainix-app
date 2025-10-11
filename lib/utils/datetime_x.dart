import 'package:cloud_firestore/cloud_firestore.dart';

// Konversi longgar & aman dipakai di mana saja
DateTime? asDateTime(dynamic v) {
  if (v == null) return null;
  if (v is DateTime) return v;
  if (v is Timestamp) return v.toDate();
  return null;
}

Timestamp? asTimestamp(dynamic v) {
  if (v == null) return null;
  if (v is Timestamp) return v;
  if (v is DateTime) return Timestamp.fromDate(v);
  return null;
}

// (Opsional) helper via extension
extension TimestampX on Timestamp? {
  DateTime? get toDateTime => this?.toDate();
}

extension DateTimeX on DateTime? {
  Timestamp? get toTimestamp => this == null ? null : Timestamp.fromDate(this!);
}
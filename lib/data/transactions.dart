import 'package:flutter/material.dart';

// --- TIPE DATA ---
class Transaction {
  final String id;
  final String type; // 'income' | 'expense'
  final String category;
  final double amount;
  final String title;
  final String detail;
  final String date; // Format: YYYY-MM-DD
  final String time; // Format: HH:mm
  final String? accountId; // Optional account linkage

  Transaction({
    required this.id,
    required this.type,
    required this.category,
    required this.amount,
    required this.title,
    required this.detail,
    required this.date,
    required this.time,
    this.accountId,
  });

  factory Transaction.fromSupabase(Map<String, dynamic> row) {
    final rawTime = row['transaction_time']?.toString() ?? '00:00';
    return Transaction(
      id: row['id']?.toString() ?? '',
      type: row['type']?.toString() ?? 'expense',
      category: row['category_name']?.toString() ?? 'Lainnya',
      amount: parseAmount(row['amount']),
      title: row['title']?.toString() ?? '',
      detail: row['detail']?.toString() ?? '',
      date: row['transaction_date']?.toString() ?? '',
      time: rawTime.length >= 5 ? rawTime.substring(0, 5) : rawTime,
      accountId: row['account_id']?.toString(),
    );
  }
}

double parseAmount(Object? value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

class MonthlyPoint {
  final String month;
  final double income;
  final double expense;

  const MonthlyPoint(this.month, this.income, this.expense);
}

// --- WARNA & IKON KATEGORI ---
final Map<String, Color> categoryColors = {
  "Gaji Masuk": const Color(0xFF00C48C),
  "Belanja": const Color(0xFFFF6B6B),
  "Tagihan": const Color(0xFFFFB347),
  "Tabungan": const Color(0xFF6C63FF),
  "Makanan": const Color(0xFFFF8C94),
  "Transportasi": const Color(0xFF4ECDC4),
  "Hiburan": const Color(0xFFA78BFA),
  "Lainnya": const Color(0xFF94A3B8),
};

final Map<String, String> categoryIcons = {
  "Gaji Masuk": "💼",
  "Belanja": "🛍️",
  "Tagihan": "📄",
  "Tabungan": "🏦",
  "Makanan": "🍽️",
  "Transportasi": "🚗",
  "Hiburan": "🎬",
  "Lainnya": "📦",
};

// --- HELPER FORMATTER ---
String formatRupiah(double amount) {
  return 'Rp ${amount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
}

String formatDate(String dateStr) {
  final parts = dateStr.split('-');
  if (parts.length != 3) return dateStr;

  // Array nama bulan
  const months = [
    "",
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "Mei",
    "Jun",
    "Jul",
    "Agt",
    "Sep",
    "Okt",
    "Nov",
    "Des",
  ];

  // Menghapus angka 0 di depan tanggal (misal: 02 jadi 2)
  int day = int.parse(parts[2]);
  int monthIndex = int.parse(parts[1]);
  String year = parts[0];

  return '$day ${months[monthIndex]} $year';
}

String shortMonthName(int monthIndex) {
  const months = [
    "",
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "Mei",
    "Jun",
    "Jul",
    "Agt",
    "Sep",
    "Okt",
    "Nov",
    "Des",
  ];
  if (monthIndex < 1 || monthIndex >= months.length) return '';
  return months[monthIndex];
}

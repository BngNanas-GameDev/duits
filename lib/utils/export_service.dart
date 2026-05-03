import 'dart:io';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../data/transactions.dart';

class ExportService {
  static Future<void> exportTransactionsToPdf(List<Transaction> transactions) async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));

    final filteredTransactions = transactions.where((tx) {
      final txDate = DateTime.tryParse(tx.date);
      if (txDate == null) return false;
      return txDate.isAfter(thirtyDaysAgo);
    }).toList();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text('Laporan Transaksi (30 Hari Terakhir)',
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          ),
          pw.SizedBox(height: 20),
          pw.TableHelper.fromTextArray(
            headers: ['Tanggal', 'Judul', 'Kategori', 'Tipe', 'Jumlah'],
            data: filteredTransactions.map((tx) {
              return [
                tx.date,
                tx.title,
                tx.category,
                tx.type == 'income' ? 'Pemasukan' : 'Pengeluaran',
                NumberFormat.currency(locale: 'id_ID', symbol: 'Rp')
                    .format(tx.amount),
              ];
            }).toList(),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Laporan_Transaksi_30_Hari.pdf',
    );
  }
}

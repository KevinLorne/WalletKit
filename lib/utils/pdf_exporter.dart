import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:walletkit/models/card_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

Future<void> exportCardAsPdf(CardModel card) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      build:
          (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                card.title,
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 12),
              ...card.fields.map(
                (field) => pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 4),
                  child: pw.Text(
                    "${field.label}: ${field.value}",
                    style: const pw.TextStyle(fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
    ),
  );

  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/${card.title.replaceAll(' ', '_')}.pdf');
  await file.writeAsBytes(await pdf.save());

  await Share.shareXFiles([
    XFile(file.path),
  ], text: 'Here’s my WalletKit card!');
}

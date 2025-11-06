import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdfx/pdfx.dart' as pdfx; // For in-app PDF preview
// Removed pdf_google_fonts import as it does not exist
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

class PDFGenerator {
  static Future<void> exportRoadmapToPDF({
    required BuildContext context,
    required Map<String, dynamic> roadmapData,
    required TextEditingController ideaController,
    required Function(Object) onError,
  }) async {
    try {
      // 1. Generate the PDF
      final pdf = pw.Document();
      pdf.addPage(
        pw.MultiPage(
          pageTheme: pw.PageTheme(
            pageFormat: PdfPageFormat.a4,
            margin: pw.EdgeInsets.all(32),
            theme: pw.ThemeData.withFont(
              base: pw.Font.helvetica(),
              bold: pw.Font.helveticaBold(),
            ),
          ),
          build: (pw.Context context) => [
            pw.Header(
              level: 0,
              child: pw.Text(
                'Investment Roadmap',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Header(level: 1, text: 'Investment Idea'),
            pw.Text(ideaController.text),
            pw.SizedBox(height: 10),
            pw.Text(
              'Validity: ${roadmapData['idea_validity']}',
              style: pw.TextStyle(
                color: roadmapData['idea_validity'] == 'valid'
                    ? PdfColors.green
                    : PdfColors.red,
              ),
            ),
            if ((roadmapData['refinement_suggestions'] as List).isNotEmpty) ...[
              pw.Header(level: 1, text: 'Refinement Suggestions'),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: (roadmapData['refinement_suggestions'] as List)
                    .map<pw.Widget>((suggestion) => pw.Bullet(text: suggestion))
                    .toList(),
              ),
            ],
            pw.Header(level: 1, text: 'Investment Timeline'),
            pw.Table.fromTextArray(
              headers: ['Phase', 'Start', 'End'],
              data: (roadmapData['investment_timeline'] as List)
                  .map(
                    (phase) => [phase['phase'], phase['start'], phase['end']],
                  )
                  .toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.center,
                2: pw.Alignment.center,
              },
            ),
            pw.Header(level: 1, text: 'Financial Projection'),
            pw.Table(
              children: [
                pw.TableRow(
                  children: [
                    pw.Text(
                      'Total Cost:',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      '\$${roadmapData['financial_projection']['total_cost']}',
                    ),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Text(
                      'Expected Revenue:',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      '\$${roadmapData['financial_projection']['expected_revenue']}',
                    ),
                  ],
                ),
              ],
            ),
            pw.Header(level: 2, text: 'Yearly Growth Projections'),
            pw.Table.fromTextArray(
              headers: ['Year', 'Growth'],
              data:
                  (roadmapData['financial_projection']['yearly_growth'] as List)
                      .asMap()
                      .entries
                      .map(
                        (entry) => ['Year ${entry.key + 1}', '${entry.value}%'],
                      )
                      .toList(),
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerRight,
              },
            ),
            pw.Header(level: 1, text: 'Risk Assessment'),
            pw.Text(
              'Risk Score: ${roadmapData['risk_assessment']['score']}',
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: roadmapData['risk_assessment']['score'] == 'low'
                    ? PdfColors.green
                    : roadmapData['risk_assessment']['score'] == 'medium'
                    ? PdfColors.orange
                    : PdfColors.red,
              ),
            ),
            pw.Header(level: 2, text: 'Identified Risks'),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: (roadmapData['risk_assessment']['risks'] as List)
                  .map<pw.Widget>((risk) => pw.Bullet(text: risk))
                  .toList(),
            ),
            pw.Header(level: 2, text: 'Mitigation Strategies'),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: (roadmapData['risk_assessment']['mitigation'] as List)
                  .map<pw.Widget>((strategy) => pw.Bullet(text: strategy))
                  .toList(),
            ),
            if (roadmapData.containsKey('markdown_content')) ...[
              pw.Header(level: 1, text: 'Detailed Analysis'),
              pw.Text(roadmapData['markdown_content']),
            ],
          ],
        ),
      );

      // 2. Save PDF bytes
      final Uint8List pdfBytes = await pdf.save();

      // 3. Show in-app preview (pdfx)
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Preview PDF'),
          content: SizedBox(
            width: double.maxFinite,
            height: 500,
            child: pdfx.PdfView(
              controller: pdfx.PdfController(
                document: pdfx.PdfDocument.openData(pdfBytes),
              ),
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text('Save PDF'),
              onPressed: () async {
                Navigator.pop(context); // Close preview
                await _savePDF(context, pdfBytes, onError); // Proceed to save
              },
            ),
          ],
        ),
      );
    } catch (e) {
      onError(e);
    }
  }

  /// Helper function to save PDF locally
  static Future<void> _savePDF(
    BuildContext context,
    Uint8List pdfBytes,
    Function(Object) onError,
  ) async {
    try {
      // Get directory for saving
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/investment_roadmap.pdf';
      final file = File(filePath);

      // Write PDF bytes to file
      await file.writeAsBytes(pdfBytes);

      // Show success dialog
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('PDF Saved'),
          content: Text('File saved at: $filePath'),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    } catch (e) {
      onError(e);
    }
  }

  // (Keep your existing downloadMarkdownFile method)
  static Future<void> downloadMarkdownFile({
    required Map<String, dynamic> roadmapData,
    required Function(Object) onError,
  }) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/investment_roadmap.md');

      await file.writeAsString(roadmapData['markdown_content']);
    } catch (e) {
      onError(e);
    }
  }
}

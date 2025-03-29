import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

import 'error_logger.dart';

class PDFGenerator {
  static Future<void> exportRoadmapToPDF({
    required Map<String, dynamic> roadmapData,
    required TextEditingController ideaController,
    required Function(Object) onError,
  }) async {
    try {
      final pdf = pw.Document();
      pdf.addPage(
        pw.MultiPage(
          pageTheme: pw.PageTheme(
            pageFormat: PdfPageFormat.a4,
            margin: pw.EdgeInsets.all(32),
            theme: pw.ThemeData.withFont(
              base: await PdfGoogleFonts.openSansRegular(),
              bold: await PdfGoogleFonts.openSansBold(),
            ),
          ),
          build: (pw.Context context) => [
            pw.Header(
              level: 0,
              child: pw.Text('Investment Roadmap',
                  style: pw.TextStyle(
                      fontSize: 24, fontWeight: pw.FontWeight.bold)),
            ),
            pw.SizedBox(height: 20),
            pw.Header(level: 1, text: 'Investment Idea'),
            pw.Text(ideaController.text),
            pw.SizedBox(height: 10),
            pw.Text('Validity: ${roadmapData['idea_validity']}',
                style: pw.TextStyle(
                    color: roadmapData['idea_validity'] == 'valid'
                        ? PdfColors.green
                        : PdfColors.red)),
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
                  .map((phase) => [
                        phase['phase'],
                        phase['start'],
                        phase['end'],
                      ])
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
                    pw.Text('Total Cost:',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text(
                        '\$${roadmapData['financial_projection']['total_cost']}'),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Text('Expected Revenue:',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text(
                        '\$${roadmapData['financial_projection']['expected_revenue']}'),
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
                      .map((entry) => [
                            'Year ${entry.key + 1}',
                            '${entry.value}%',
                          ])
                      .toList(),
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerRight,
              },
            ),
            pw.Header(level: 1, text: 'Risk Assessment'),
            pw.Text('Risk Score: ${roadmapData['risk_assessment']['score']}',
                style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    color: roadmapData['risk_assessment']['score'] == 'low'
                        ? PdfColors.green
                        : roadmapData['risk_assessment']['score'] == 'medium'
                            ? PdfColors.orange
                            : PdfColors.red)),
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
              pw.Text(roadmapData['markdown_content'])
            ],
          ],
        ),
      );

      await Printing.sharePdf(
          bytes: await pdf.save(), filename: 'investment_roadmap.pdf');
    } catch (e) {
      onError(e);
    }
  }

  static Future<void> downloadMarkdownFile({
    required Map<String, dynamic> roadmapData,
    required Function(Object) onError,
  }) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/investment_roadmap.md');

      if (await file.exists()) {
        await Printing.sharePdf(
          bytes: utf8.encode(roadmapData['markdown_content']),
          filename: 'investment_roadmap.md',
        );
      } else {
        onError('Markdown file not found');
      }
    } catch (e) {
      onError(e);
    }
  }
}

import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'models/c_by_ai_models.dart';

/// Builds a simple PDF of the full meal plan for CRM / ops.
class CByAiPdfService {
  CByAiPdfService._();

  static Future<Uint8List> buildMealPlanPdf({
    required Map<int, List<MealModel>> mealData,
    required Map<int, DailyTotalModel> dailyTotals,
    MealSummaryModel? summary,
    required int selectedDay,
  }) async {
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) {
          final blocks = <pw.Widget>[
            pw.Header(
              level: 0,
              child: pw.Text(
                'C BY AI — Meal plan',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              'Highlighted delivery focus: Day $selectedDay',
              style: const pw.TextStyle(fontSize: 11),
            ),
            if (summary != null) ...[
              pw.SizedBox(height: 12),
              pw.Text(
                'Summary: ${summary.totalDays} days · ${summary.totalMeals} meals · '
                '${summary.totalCalories.toStringAsFixed(0)} kcal total',
                style: const pw.TextStyle(fontSize: 10),
              ),
            ],
            pw.SizedBox(height: 16),
          ];

          final days = mealData.keys.toList()..sort();
          if (days.isEmpty) {
            blocks.add(
              pw.Paragraph(text: 'No meals loaded for this plan.'),
            );
          } else {
            for (final d in days) {
              final meals = mealData[d] ?? [];
              blocks.add(
                pw.Header(
                  level: 1,
                  child: pw.Text('Day $d'),
                ),
              );
              for (final m in meals) {
                blocks.add(
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 4),
                    child: pw.Text(
                      '${m.type} · ${m.time} — ${m.name}  '
                      '(${m.totalCal.toStringAsFixed(0)} kcal, '
                      'P${m.totalProtein.toStringAsFixed(1)} '
                      'C${m.totalCarbs.toStringAsFixed(1)} '
                      'F${m.totalFat.toStringAsFixed(1)})',
                      style: const pw.TextStyle(fontSize: 9),
                    ),
                  ),
                );
              }
              final t = dailyTotals[d];
              if (t != null) {
                blocks.add(
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 12, top: 4),
                    child: pw.Text(
                      'Day total: ${t.calories.toStringAsFixed(0)} kcal · '
                      'P${t.protein.toStringAsFixed(1)} '
                      'C${t.carbs.toStringAsFixed(1)} '
                      'F${t.fat.toStringAsFixed(1)}',
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontStyle: pw.FontStyle.italic,
                      ),
                    ),
                  ),
                );
              }
            }
          }

          return blocks;
        },
      ),
    );

    return doc.save();
  }
}

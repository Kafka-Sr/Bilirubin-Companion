import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'package:bilirubin/core/l10n/app_localizations.dart';
import 'package:bilirubin/models/baby.dart';
import 'package:bilirubin/models/measurement.dart';
import 'package:bilirubin/providers/audit_providers.dart';
import 'package:bilirubin/utils/bhutani_classifier.dart' as classifier;
import 'package:bilirubin/utils/safe_file_export.dart';

enum _ExportFormat { json, csv, pdf }

Future<void> showExportBottomSheet(
  BuildContext context,
  WidgetRef ref, {
  required Baby baby,
  required List<Measurement> measurements,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _ExportSheet(
      baby: baby,
      measurements: measurements,
      ref: ref,
    ),
  );
}

class _ExportSheet extends StatefulWidget {
  const _ExportSheet({
    required this.baby,
    required this.measurements,
    required this.ref,
  });

  final Baby baby;
  final List<Measurement> measurements;
  final WidgetRef ref;

  @override
  State<_ExportSheet> createState() => _ExportSheetState();
}

class _ExportSheetState extends State<_ExportSheet> {
  late final TextEditingController _filenameCtrl;
  late final TextEditingController _locationCtrl;
  _ExportFormat _format = _ExportFormat.json;
  bool _exporting = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final timestamp =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    _filenameCtrl = TextEditingController(
      text: sanitiseFilename('bilirubin_${widget.baby.babyName}_$timestamp'),
    );
    _locationCtrl = TextEditingController();
    _initDefaultLocation();
  }

  Future<void> _initDefaultLocation() async {
    final dir = await getApplicationDocumentsDirectory();
    if (mounted) _locationCtrl.text = dir.path;
  }

  @override
  void dispose() {
    _filenameCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  String get _extension {
    switch (_format) {
      case _ExportFormat.json:
        return '.json';
      case _ExportFormat.csv:
        return '.csv';
      case _ExportFormat.pdf:
        return '.pdf';
    }
  }

  Future<void> _pickDirectory() async {
    final dir = await FilePicker.platform.getDirectoryPath();
    if (dir != null && mounted) {
      setState(() => _locationCtrl.text = dir);
    }
  }

  Future<void> _export(BuildContext context) async {
    if (_format == _ExportFormat.pdf) {
      setState(() => _exporting = true);
      try {
        final l10n = AppLocalizations.of(context);
        final doc = _buildPdf(l10n);
        final bytes = await doc.save();
        final filename =
            'bilirubin_${sanitiseFilename(widget.baby.babyName)}.pdf';
        await Printing.sharePdf(bytes: bytes, filename: filename);
        widget.ref.read(auditRepositoryProvider).logExport(
          widget.baby.babyId,
          babyName: widget.baby.babyName,
          fileType: 'PDF',
        );
      } finally {
        if (mounted) setState(() => _exporting = false);
      }
      return;
    }

    final l10n = AppLocalizations.of(context);
    final rawName = _filenameCtrl.text.trim();
    if (rawName.isEmpty) return;

    final filename = sanitiseFilename(rawName) + _extension;
    final saveDir = _locationCtrl.text.trim();

    setState(() => _exporting = true);
    try {
      final fullPath = p.join(saveDir, filename);
      final file = File(fullPath);

      String content;
      if (_format == _ExportFormat.json) {
        content = _buildJson();
      } else {
        content = _buildCsv();
      }

      await file.writeAsString(content);

      widget.ref.read(auditRepositoryProvider).logExport(
        widget.baby.babyId,
        babyName: widget.baby.babyName,
        fileType: _format == _ExportFormat.json ? 'JSON' : 'CSV',
      );

      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.exportedTo(filename))),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context).exportFailed} $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  String _buildJson() {
    final now = DateTime.now();
    final payload = {
      'exportedAt': now.toIso8601String(),
      'baby': {
        'baby_name': widget.baby.babyName,
        'baby_dob': widget.baby.babyDob.toIso8601String(),
        'baby_weight': widget.baby.babyWeight,
      },
      'measurements': widget.measurements
          .map((m) => {
                'measurement_id': m.measurementId,
                'captured_at': m.capturedAt.toIso8601String(),
                'age_hours': m.ageHours,
                'bilirubin_mgdl': m.bilirubinMgdl,
                'device_id': m.deviceId,
                'model_version': m.modelVersion,
              })
          .toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  String _buildCsv() {
    final buf = StringBuffer();
    buf.writeln('measurement_id,captured_at,age_hours,bilirubin_mgdl,device_id,model_version');
    for (final m in widget.measurements) {
      buf.writeln(
        '${_csvEscape(m.measurementId)},'
        '${m.capturedAt.toIso8601String()},'
        '${m.ageHours},'
        '${m.bilirubinMgdl},'
        '${_csvEscape(m.deviceId ?? '')},'
        '${_csvEscape(m.modelVersion ?? '')}',
      );
    }
    return buf.toString();
  }

  String _csvEscape(String v) =>
      v.contains(',') || v.contains('"') || v.contains('\n')
          ? '"${v.replaceAll('"', '""')}"'
          : v;

  pw.Document _buildPdf(AppLocalizations l10n) {
    final doc = pw.Document();
    final now = DateTime.now();
    final baby = widget.baby;
    final measurements = widget.measurements;

    final ageDays = now.difference(baby.babyDob).inHours / 24;

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(l10n.pdfTitle,
                style: pw.TextStyle(
                    fontSize: 20, fontWeight: pw.FontWeight.bold)),
            pw.Text(
                '${l10n.pdfExportedAt} ${now.day}/${now.month}/${now.year} '
                '${now.hour.toString().padLeft(2, '0')}:'
                '${now.minute.toString().padLeft(2, '0')}',
                style: const pw.TextStyle(
                    fontSize: 10, color: PdfColors.grey600)),
            pw.Divider(),
          ],
        ),
        footer: (_) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(l10n.pdfGeneratedBy,
              style: const pw.TextStyle(
                  fontSize: 9, color: PdfColors.grey500)),
        ),
        build: (_) => [
          pw.Text(l10n.pdfPatientInfo,
              style: pw.TextStyle(
                  fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Table(
            columnWidths: {
              0: const pw.FlexColumnWidth(1),
              1: const pw.FlexColumnWidth(2),
            },
            children: [
              _pdfInfoRow(l10n.metadataName, baby.babyName),
              _pdfInfoRow(l10n.metadataDob,
                  '${baby.babyDob.day}/${baby.babyDob.month}/${baby.babyDob.year}'),
              _pdfInfoRow(l10n.pdfBirthWeight,
                  '${baby.babyWeight.toStringAsFixed(2)} kg'),
              _pdfInfoRow(l10n.pdfAgeAtExport,
                  '${ageDays.toStringAsFixed(1)} days'),
            ],
          ),
          pw.SizedBox(height: 20),

          pw.Text(l10n.pdfMeasurementsTitle,
              style: pw.TextStyle(
                  fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headerDecoration:
                const pw.BoxDecoration(color: PdfColors.grey200),
            cellHeight: 24,
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.center,
              2: pw.Alignment.center,
              3: pw.Alignment.center,
              4: pw.Alignment.centerLeft,
            },
            headers: [
              l10n.pdfColDateTime,
              l10n.axisLabelAgeHours,
              l10n.pdfColBilirubin,
              l10n.pdfColZone,
              l10n.pdfColDevice,
            ],
            data: measurements.map((m) {
              final d = m.capturedAt.toLocal();
              final dateStr = '${d.day}/${d.month}/${d.year} '
                  '${d.hour.toString().padLeft(2, '0')}:'
                  '${d.minute.toString().padLeft(2, '0')}';
              final zone = classifier.classify(m.ageHours, m.bilirubinMgdl);
              return [
                dateStr,
                m.ageHours.toStringAsFixed(1),
                m.bilirubinMgdl.toStringAsFixed(1),
                zone?.localizedLabel(l10n) ?? '—',
                m.deviceId ?? '—',
              ];
            }).toList(),
          ),
        ],
      ),
    );

    return doc;
  }

  pw.TableRow _pdfInfoRow(String label, String value) {
    return pw.TableRow(children: [
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 3),
        child: pw.Text(label,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold,
                fontSize: 10)),
      ),
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 3),
        child: pw.Text(value, style: const pw.TextStyle(fontSize: 10)),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.exportSheetTitle,
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // File name
          Text(l10n.exportFileName,
              style: theme.textTheme.bodyLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          TextField(
            controller: _filenameCtrl,
            decoration: InputDecoration(
              suffixText: _extension,
              suffixStyle: TextStyle(color: colorScheme.outline),
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(99),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(99),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(99),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Save location
          Text(l10n.exportSaveLocation,
              style: theme.textTheme.bodyLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: TextField(
                    controller: _locationCtrl,
                    decoration: InputDecoration(
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(99),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(99),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(99),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.tonal(
                  onPressed: _pickDirectory,
                  child: Text(l10n.exportBrowse),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Format selector
          SegmentedButton<_ExportFormat>(
            showSelectedIcon: false,
            selected: {_format},
            onSelectionChanged: (s) => setState(() => _format = s.first),
            segments: const [
              ButtonSegment(
                value: _ExportFormat.json,
                label: Text('JSON'),
                icon: Icon(Icons.data_object, size: 16),
              ),
              ButtonSegment(
                value: _ExportFormat.csv,
                label: Text('CSV'),
                icon: Icon(Icons.table_rows_outlined, size: 16),
              ),
              ButtonSegment(
                value: _ExportFormat.pdf,
                label: Text('PDF'),
                icon: Icon(Icons.picture_as_pdf_outlined, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Export button
          FilledButton(
            onPressed: _exporting ? null : () => _export(context),
            child: _exporting
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.exportAction, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          SizedBox(height: MediaQuery.viewInsetsOf(context).bottom + 24),
        ],
      ),
    );
  }
}

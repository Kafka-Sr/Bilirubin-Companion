import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:bilirubin/core/l10n/app_localizations.dart';
import 'package:bilirubin/models/baby.dart';
import 'package:bilirubin/models/measurement.dart';
import 'package:bilirubin/providers/database_provider.dart';
import 'package:bilirubin/repositories/audit_repository.dart';
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
      text: sanitiseFilename('bilirubin_${widget.baby.name}_$timestamp'),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF export is not yet available.')),
      );
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

      final db = widget.ref.read(appDatabaseProvider);
      await AuditRepository(db).logExport(widget.baby.id);

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
        'name': widget.baby.name,
        'dateOfBirth': widget.baby.dateOfBirth.toIso8601String(),
        'weightKg': widget.baby.weightKg,
      },
      'measurements': widget.measurements
          .map((m) => {
                'measurementId': m.measurementId,
                'capturedAt': m.capturedAt.toIso8601String(),
                'ageHours': m.ageHours,
                'bilirubinMgDl': m.bilirubinMgDl,
                'deviceId': m.deviceId,
                'modelVersion': m.modelVersion,
              })
          .toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  String _buildCsv() {
    final buf = StringBuffer();
    buf.writeln('measurementId,capturedAt,ageHours,bilirubinMgDl,deviceId,modelVersion');
    for (final m in widget.measurements) {
      buf.writeln(
        '${_csvEscape(m.measurementId)},'
        '${m.capturedAt.toIso8601String()},'
        '${m.ageHours},'
        '${m.bilirubinMgDl},'
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header ──────────────────────────────────────────────────────────
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

          // ── File name ────────────────────────────────────────────────────────
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

          // ── Save location ────────────────────────────────────────────────────
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

          // ── Format selector ──────────────────────────────────────────────────
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

          // ── Export button ────────────────────────────────────────────────────
          FilledButton(
            onPressed: _exporting ? null : () => _export(context),
            child: _exporting
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.exportAction),
          ),
        ],
      ),
    );
  }
}

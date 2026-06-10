import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bilirubin/core/l10n/app_localizations.dart';
import 'package:bilirubin/providers/admin_providers.dart';

class AuditEventsScreen extends ConsumerStatefulWidget {
  const AuditEventsScreen({super.key});

  @override
  ConsumerState<AuditEventsScreen> createState() => _AuditEventsScreenState();
}

class _AuditEventsScreenState extends ConsumerState<AuditEventsScreen> {
  int _page = 0;
  String? _filter;
  bool _hasNextPage = false;

  static const _eventTypes = [
    'baby_create',
    'baby_edit',
    'baby_delete',
    'measurement_create',
    'measurement_delete',
    'export',
    'account_create',
    'account_edit',
    'account_deactivate',
    'account_reactivate',
    'parent_link',
    'parent_unlink',
    'device_add',
    'transfer_create',
    'transfer_accept',
    'transfer_reject',
    'transfer_cancel',
  ];

  @override
  Widget build(BuildContext context) {
    // Provider fetches 51 rows; we use the extra row to detect a next page.
    final eventsAsync = ref.watch(auditEventsProvider(_page));
    final cs = Theme.of(context).colorScheme;

    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.auditEventsLogTitle)),
      body: Column(
        children: [
          // Filter chips
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                FilterChip(
                  label: Text(l10n.auditAllFilter),
                  selected: _filter == null,
                  onSelected: (_) => setState(() => _filter = null),
                ),
                const SizedBox(width: 6),
                ..._eventTypes.map((t) => Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: FilterChip(
                        label: Text(_labelFor(l10n, t)),
                        selected: _filter == t,
                        onSelected: (_) =>
                            setState(() => _filter = _filter == t ? null : t),
                      ),
                    )),
              ],
            ),
          ),
          const Divider(height: 1),

          // Event list
          Expanded(
            child: eventsAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                  child: Text(AppLocalizations.of(context).adminErrorGeneric)),
              data: (rawEvents) {
                // Detect next page: provider fetches 51, >50 means there is more
                final hasNext = rawEvents.length > 50;
                final events =
                    rawEvents.length > 50 ? rawEvents.sublist(0, 50) : rawEvents;

                // Update flag without triggering a rebuild mid-build
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_hasNextPage != hasNext) {
                    setState(() => _hasNextPage = hasNext);
                  }
                });

                final filtered = _filter == null
                    ? events
                    : events
                        .where((e) => e['event_type'] == _filter)
                        .toList();

                if (filtered.isEmpty) {
                  return Center(child: Text(l10n.auditNoEvents));
                }

                return ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final e = filtered[i];
                    final eventType = e['event_type'] as String? ?? '';
                    final createdAt = e['created_at'] as String?;
                    final babyId = e['baby_id'] as String?;
                    final details = e['details_json'] as String?;

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            _colorFor(eventType, cs).withValues(alpha: 0.15),
                        child: Icon(
                          _iconFor(eventType),
                          size: 18,
                          color: _colorFor(eventType, cs),
                        ),
                      ),
                      title: Text(_labelFor(l10n, eventType)),
                      subtitle: Text([
                        if (babyId != null) 'Baby: $babyId',
                        if (details != null) details,
                      ].join(' · ')),
                      trailing: Text(
                        _formatDate(createdAt),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Pagination
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _page > 0
                      ? () => setState(() => _page--)
                      : null,
                ),
                Text('Page ${_page + 1}'),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _hasNextPage
                      ? () => setState(() => _page++)
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _labelFor(AppLocalizations l10n, String type) => switch (type) {
        'baby_create' => l10n.auditEventBabyCreate,
        'baby_edit' => l10n.auditEventBabyEdit,
        'baby_delete' => l10n.auditEventBabyDelete,
        'measurement_create' => l10n.auditEventMeasurementCreate,
        'measurement_delete' => l10n.auditEventMeasurementDelete,
        'export' => l10n.auditEventExport,
        'account_create' => l10n.auditEventAccountCreate,
        'account_edit' => l10n.auditEventAccountEdit,
        'account_deactivate' => l10n.auditEventAccountDeactivate,
        'account_reactivate' => l10n.auditEventAccountReactivate,
        'parent_link' => l10n.auditEventParentLink,
        'parent_unlink' => l10n.auditEventParentUnlink,
        'device_add' => l10n.auditEventDeviceAdd,
        'transfer_create' => l10n.auditEventTransferCreate,
        'transfer_accept' => l10n.auditEventTransferAccept,
        'transfer_reject' => l10n.auditEventTransferReject,
        'transfer_cancel' => l10n.auditEventTransferCancel,
        _ => type,
      };

  IconData _iconFor(String type) => switch (type) {
        'baby_create' => Icons.child_care_outlined,
        'baby_edit' => Icons.edit_outlined,
        'baby_delete' => Icons.delete_outline,
        'measurement_create' => Icons.colorize_outlined,
        'measurement_delete' => Icons.remove_circle_outline,
        'export' => Icons.file_upload_outlined,
        'account_create' => Icons.person_add_outlined,
        'account_edit' => Icons.manage_accounts_outlined,
        'account_deactivate' => Icons.block_outlined,
        'account_reactivate' => Icons.check_circle_outline,
        'parent_link' => Icons.family_restroom,
        'parent_unlink' => Icons.link_off,
        'device_add' => Icons.devices_outlined,
        'transfer_create' => Icons.swap_horiz,
        'transfer_accept' => Icons.check_circle_outline,
        'transfer_reject' => Icons.cancel_outlined,
        'transfer_cancel' => Icons.cancel_outlined,
        _ => Icons.info_outline,
      };

  Color _colorFor(String type, ColorScheme cs) => switch (type) {
        'baby_delete' ||
        'measurement_delete' ||
        'account_deactivate' ||
        'parent_unlink' ||
        'transfer_reject' ||
        'transfer_cancel' =>
          cs.error,
        'export' ||
        'account_create' ||
        'account_reactivate' ||
        'transfer_accept' =>
          cs.primary,
        _ => cs.secondary,
      };

  String _formatDate(String? iso) {
    if (iso == null) return '';
    final d = DateTime.tryParse(iso)?.toLocal();
    if (d == null) return '';
    return '${d.day}/${d.month}/${d.year} '
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }
}

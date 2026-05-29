import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bilirubin/core/l10n/app_localizations.dart';
import 'package:bilirubin/providers/admin_providers.dart';
import 'package:bilirubin/providers/audit_providers.dart';
import 'package:bilirubin/providers/auth_providers.dart';
import 'package:bilirubin/providers/baby_providers.dart';
import 'package:bilirubin/providers/supabase_providers.dart';
import 'package:bilirubin/utils/extensions.dart';

class TransferScreen extends ConsumerStatefulWidget {
  const TransferScreen({super.key});

  @override
  ConsumerState<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends ConsumerState<TransferScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final transfersAsync = ref.watch(transfersProvider);

    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.babyTransfersTitle),
        bottom: TabBar(
          controller: _tabCtrl,
          tabs: [Tab(text: l10n.outgoingTab), Tab(text: l10n.incomingTab)],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.swap_horiz),
        label: Text(l10n.initiateTransferFab),
        onPressed: () => _showInitiateDialog(context),
      ),
      body: transfersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            Center(child: Text(AppLocalizations.of(context).adminErrorGeneric)),
        data: (transfers) {
          final myId = profile?.hospitalId ?? '';
          final outgoing = transfers
              .where((t) => t['from_hospital_id'] == myId)
              .toList();
          final incoming = transfers
              .where((t) =>
                  t['to_hospital_id'] == myId &&
                  t['from_hospital_id'] != myId)
              .toList();

          return TabBarView(
            controller: _tabCtrl,
            children: [
              _TransferList(
                  transfers: outgoing,
                  isIncoming: false,
                  onRefresh: () => ref.invalidate(transfersProvider)),
              _TransferList(
                  transfers: incoming,
                  isIncoming: true,
                  onRefresh: () => ref.invalidate(transfersProvider)),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showInitiateDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (_) => _InitiateTransferDialog(onDone: () {
        ref.invalidate(transfersProvider);
      }),
    );
  }
}

class _TransferList extends ConsumerWidget {
  const _TransferList({
    required this.transfers,
    required this.isIncoming,
    required this.onRefresh,
  });

  final List<Map<String, dynamic>> transfers;
  final bool isIncoming;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (transfers.isEmpty) {
      final l10n = AppLocalizations.of(context);
      return Center(
        child: Text(
          isIncoming ? l10n.noIncomingTransfers : l10n.noOutgoingTransfers,
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: transfers.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, i) {
        final t = transfers[i];
        final status = t['status'] as String? ?? 'pending';
        final babyName =
            (t['babies'] as Map<String, dynamic>?)?['baby_name'] as String? ??
                t['baby_id'] as String? ??
                'Unknown';
        final l10n = AppLocalizations.of(context);

        Widget? trailing;
        if (isIncoming && status == 'pending') {
          trailing = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () => _updateStatus(
                  context, ref,
                  t['transfer_id'] as String,
                  'accepted',
                  babyId: t['baby_id'] as String?,
                  babyName: babyName,
                  fromHospitalId: t['from_hospital_id'] as String?,
                ),
                child: Text(l10n.acceptLabel),
              ),
              TextButton(
                onPressed: () => _updateStatus(
                  context, ref,
                  t['transfer_id'] as String,
                  'rejected',
                  babyId: t['baby_id'] as String?,
                  babyName: babyName,
                  fromHospitalId: t['from_hospital_id'] as String?,
                ),
                child: Text(l10n.rejectLabel,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.error)),
              ),
            ],
          );
        } else if (!isIncoming && status == 'pending') {
          trailing = TextButton(
            onPressed: () => _updateStatus(
              context, ref,
              t['transfer_id'] as String,
              'cancelled',
              babyId: t['baby_id'] as String?,
              babyName: babyName,
              toHospitalId: t['to_hospital_id'] as String?,
            ),
            child: Text(l10n.cancelTransfer,
                style:
                    TextStyle(color: Theme.of(context).colorScheme.error)),
          );
        }

        return ListTile(
          leading: _StatusIcon(status: status),
          title: Text(babyName),
          subtitle: Text(status.toUpperCase()),
          trailing: trailing,
        );
      },
    );
  }

  Future<void> _updateStatus(
    BuildContext context,
    WidgetRef ref,
    String transferId,
    String newStatus, {
    String? babyId,
    String? babyName,
    String? fromHospitalId,
    String? toHospitalId,
  }) async {
    final client = ref.read(supabaseClientProvider);
    final session = ref.read(supabaseSessionProvider).valueOrNull;
    final user = ref.read(supabaseUserProvider);
    if (client == null || user == null) return;

    try {
      if (newStatus == 'accepted') {
        if (session == null) throw Exception('Not authenticated');
        await client.functions.invoke(
          'accept-transfer',
          body: {'transferId': transferId},
          headers: {'Authorization': 'Bearer ${session.accessToken}'},
        );
        if (babyId != null && fromHospitalId != null) {
          ref.read(auditRepositoryProvider).logTransferAccept(
            babyId,
            babyName: babyName ?? babyId,
            fromHospitalId: fromHospitalId,
          );
        }
      } else {
        await client.from('transfer_requests').update({
          'status': newStatus,
          'resolved_by': user.id,
          'resolved_at': DateTime.now().toIso8601String(),
        }).eq('transfer_id', transferId);

        final audit = ref.read(auditRepositoryProvider);
        if (newStatus == 'rejected' &&
            babyId != null &&
            fromHospitalId != null) {
          audit.logTransferReject(
            babyId,
            babyName: babyName ?? babyId,
            fromHospitalId: fromHospitalId,
          );
        } else if (newStatus == 'cancelled' &&
            babyId != null &&
            toHospitalId != null) {
          audit.logTransferCancel(
            babyId,
            babyName: babyName ?? babyId,
            toHospitalId: toHospitalId,
          );
        }
      }
      onRefresh();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(AppLocalizations.of(context).adminErrorGeneric)),
        );
      }
    }
  }
}

class _StatusIcon extends StatelessWidget {
  const _StatusIcon({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final (icon, color) = switch (status) {
      'accepted' => (Icons.check_circle_outline, Colors.green),
      'rejected' => (Icons.cancel_outlined, cs.error),
      'cancelled' => (Icons.block_outlined, cs.outline),
      _ => (Icons.hourglass_empty_outlined, Colors.amber),
    };
    return Icon(icon, color: color);
  }
}

class _InitiateTransferDialog extends ConsumerStatefulWidget {
  const _InitiateTransferDialog({required this.onDone});
  final VoidCallback onDone;

  @override
  ConsumerState<_InitiateTransferDialog> createState() =>
      _InitiateTransferDialogState();
}

class _InitiateTransferDialogState
    extends ConsumerState<_InitiateTransferDialog> {
  final _hospitalCodeCtrl = TextEditingController();
  String? _selectedBabyId;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _hospitalCodeCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final babyId = _selectedBabyId;
    final code = _hospitalCodeCtrl.text.trim();
    if (babyId == null || code.isEmpty) return;

    final l10n = AppLocalizations.of(context);

    // Warn the admin that data access will be permanently lost
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final dl10n = AppLocalizations.of(ctx);
        return AlertDialog(
          title: Text(dl10n.transferWarningTitle),
          content: Text(dl10n.transferWarningBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(dl10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(dl10n.transferWarningConfirm),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final client = ref.read(supabaseClientProvider);
      final profile = ref.read(userProfileProvider).valueOrNull;
      final user = ref.read(supabaseUserProvider);
      if (client == null || profile == null || user == null) {
        throw Exception('Not authenticated');
      }

      final hospital = await client
          .from('hospitals')
          .select('hospital_id')
          .eq('hospital_code', code)
          .maybeSingle();
      if (hospital == null) throw Exception('Hospital code not found');

      await client.from('transfer_requests').insert({
        'baby_id': babyId,
        'from_hospital_id': profile.hospitalId,
        'to_hospital_id': hospital['hospital_id'] as String,
        'initiated_by': user.id,
      });

      final babies = ref.read(babiesListProvider).valueOrNull ?? [];
      final transferBabyName = babies
              .firstWhereOrNull((b) => b.babyId == babyId)
              ?.babyName ??
          babyId;
      ref.read(auditRepositoryProvider).logTransferCreate(
        babyId,
        babyName: transferBabyName,
        toHospitalCode: code,
      );
      widget.onDone();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() => _error = l10n.adminErrorGeneric);
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final babies = ref.watch(babiesListProvider).valueOrNull ?? [];

    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.initiateTransferDialogTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            initialValue: _selectedBabyId,
            decoration: InputDecoration(labelText: l10n.babyLabel),
            items: babies
                .map((b) => DropdownMenuItem(
                      value: b.babyId,
                      child: Text(b.babyName),
                    ))
                .toList(),
            onChanged: (v) => setState(() => _selectedBabyId = v),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _hospitalCodeCtrl,
            decoration: InputDecoration(
                labelText: l10n.targetHospitalCodeLabel,
                hintText: l10n.hospitalCodeHint),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.error, fontSize: 12)),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _loading ? null : _submit,
          child: _loading
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : Text(l10n.sendLabel),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bilirubin/core/l10n/app_localizations.dart';
import 'package:bilirubin/providers/admin_providers.dart';
import 'package:bilirubin/providers/baby_providers.dart';
import 'package:bilirubin/providers/user_profile_provider.dart';
import 'package:bilirubin/utils/error_utils.dart';

class TransferScreen extends ConsumerWidget {
  const TransferScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final transfersAsync = ref.watch(transfersProvider);
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.patientTransfers)),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.swap_horiz_rounded),
        label: Text(l10n.initiateTransfer),
        onPressed: () => _showInitiateDialog(context, ref),
      ),
      body: transfersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (transfers) {
          if (transfers.isEmpty) {
            return Center(child: Text(l10n.noTransferRequests));
          }
          final myHospitalId = profileAsync.valueOrNull?.hospitalId;
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
            itemCount: transfers.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) => _TransferTile(
              transfer: transfers[i],
              myHospitalId: myHospitalId ?? '',
              onChanged: () => ref.invalidate(transfersProvider),
            ),
          );
        },
      ),
    );
  }

  Future<void> _showInitiateDialog(BuildContext context, WidgetRef ref) async {
    await showDialog<void>(
      context: context,
      builder: (_) => _InitiateTransferDialog(
        onInitiated: () => ref.invalidate(transfersProvider),
      ),
    );
  }
}

// ── Transfer tile ─────────────────────────────────────────────────────────────

class _TransferTile extends ConsumerStatefulWidget {
  const _TransferTile({
    required this.transfer,
    required this.myHospitalId,
    required this.onChanged,
  });

  final TransferRequest transfer;
  final String myHospitalId;
  final VoidCallback onChanged;

  @override
  ConsumerState<_TransferTile> createState() => _TransferTileState();
}

class _TransferTileState extends ConsumerState<_TransferTile> {
  bool _loading = false;

  bool get _isIncoming =>
      widget.transfer.toHospitalId == widget.myHospitalId &&
      widget.transfer.isPending;

  bool get _isOutgoing =>
      widget.transfer.fromHospitalId == widget.myHospitalId &&
      widget.transfer.isPending;

  Future<void> _accept() async {
    setState(() => _loading = true);
    try {
      final res = await Supabase.instance.client.functions.invoke(
        'accept-transfer',
        body: {'transferId': widget.transfer.id},
      );
      if (res.data?['error'] != null) {
        _showError(res.data['error'] as String);
        return;
      }
      widget.onChanged();
    } catch (e) {
      _showError(friendlyError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _reject() async {
    setState(() => _loading = true);
    try {
      await Supabase.instance.client
          .from('transfer_requests')
          .update({
            'status': 'rejected',
            'resolved_by': Supabase.instance.client.auth.currentUser!.id,
            'resolved_at': DateTime.now().toIso8601String(),
          })
          .eq('id', widget.transfer.id);
      widget.onChanged();
    } catch (e) {
      _showError(friendlyError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _cancel() async {
    setState(() => _loading = true);
    try {
      await Supabase.instance.client
          .from('transfer_requests')
          .update({'status': 'cancelled'})
          .eq('id', widget.transfer.id);
      widget.onChanged();
    } catch (e) {
      _showError(friendlyError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final t = widget.transfer;

    Color statusColor;
    switch (t.status) {
      case 'accepted':
        statusColor = Colors.green;
      case 'rejected':
      case 'cancelled':
        statusColor = theme.colorScheme.error;
      default:
        statusColor = theme.colorScheme.primary;
    }

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(t.babyName, style: theme.textTheme.titleMedium),
                ),
                Chip(
                  label: Text(t.status.toUpperCase(),
                      style: const TextStyle(fontSize: 11)),
                  backgroundColor: statusColor.withValues(alpha: 0.15),
                  labelStyle: TextStyle(color: statusColor),
                  side: BorderSide.none,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${t.fromHospitalName}  →  ${t.toHospitalName}',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.outline),
            ),
            if (_isIncoming) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _loading ? null : _reject,
                      child: Text(l10n.rejectAction),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _loading ? null : _accept,
                      child: _loading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : Text(l10n.acceptAction),
                    ),
                  ),
                ],
              ),
            ] else if (_isOutgoing) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _loading ? null : _cancel,
                  child: Text(l10n.cancelRequest),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Initiate transfer dialog ───────────────────────────────────────────────────

class _InitiateTransferDialog extends ConsumerStatefulWidget {
  const _InitiateTransferDialog({required this.onInitiated});
  final VoidCallback onInitiated;

  @override
  ConsumerState<_InitiateTransferDialog> createState() =>
      _InitiateTransferDialogState();
}

class _InitiateTransferDialogState
    extends ConsumerState<_InitiateTransferDialog> {
  final _codeCtrl = TextEditingController();
  int? _selectedBabyId;
  String? _selectedBabyName;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedBabyId == null || _selectedBabyName == null || _codeCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Select a baby and enter the destination hospital code.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final profile = await ref.read(userProfileProvider.future);

      final hospitalRow = await Supabase.instance.client
          .from('hospitals')
          .select('id')
          .eq('code', _codeCtrl.text.trim().toUpperCase())
          .maybeSingle();

      if (hospitalRow == null) {
        setState(() => _error = 'No hospital found with that code.');
        return;
      }

      final toHospitalId = hospitalRow['id'] as String;
      if (toHospitalId == profile?.hospitalId) {
        setState(() => _error = 'Cannot transfer to your own hospital.');
        return;
      }

      await Supabase.instance.client.from('transfer_requests').insert({
        'baby_name': _selectedBabyName,
        'from_hospital_id': profile?.hospitalId,
        'to_hospital_id': toHospitalId,
        'initiated_by': Supabase.instance.client.auth.currentUser!.id,
      });

      widget.onInitiated();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _error = friendlyError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final babiesAsync = ref.watch(babiesListProvider);

    return AlertDialog(
      title: Text(l10n.initiateTransfer),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.selectBabyToLink),
            const SizedBox(height: 8),
            babiesAsync.when(
              loading: () => const CircularProgressIndicator(),
              error: (e, _) => Text('Error: $e'),
              data: (babies) => DropdownButton<int>(
                isExpanded: true,
                hint: Text(l10n.selectBaby),
                value: _selectedBabyId,
                items: babies
                    .where((b) => !b.isArchived)
                    .map((b) => DropdownMenuItem(
                          value: b.id,
                          child: Text(b.name),
                        ))
                    .toList(),
                onChanged: (v) {
                  final baby = babies.firstWhere((b) => b.id == v);
                  setState(() {
                    _selectedBabyId = v;
                    _selectedBabyName = baby.name;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _codeCtrl,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                labelText: l10n.destinationHospitalCode,
                hintText: 'e.g. HOSP2',
                errorText: _error,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _loading ? null : _submit,
          child: _loading
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : Text(l10n.sendRequest),
        ),
      ],
    );
  }
}

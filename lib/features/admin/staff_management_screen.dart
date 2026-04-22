import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bilirubin/core/l10n/app_localizations.dart';
import 'package:bilirubin/providers/admin_providers.dart';
import 'package:bilirubin/providers/user_profile_provider.dart';

class StaffManagementScreen extends ConsumerWidget {
  const StaffManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final staffAsync = ref.watch(staffListProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.staffManagement)),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.person_add_outlined),
        label: Text(l10n.addStaff),
        onPressed: () => _showAddStaffDialog(context, ref),
      ),
      body: staffAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (staff) {
          if (staff.isEmpty) {
            return Center(child: Text(l10n.noStaffYet));
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
            itemCount: staff.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) => _StaffTile(member: staff[i], ref: ref),
          );
        },
      ),
    );
  }

  Future<void> _showAddStaffDialog(BuildContext context, WidgetRef ref) async {
    await showDialog<void>(
      context: context,
      builder: (_) => _AddStaffDialog(onCreated: () => ref.invalidate(staffListProvider)),
    );
  }
}

class _StaffTile extends StatelessWidget {
  const _StaffTile({required this.member, required this.ref});

  final StaffMember member;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    final isSelf = member.userId == currentUserId;

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: member.role == UserRole.admin
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.secondaryContainer,
          child: Icon(
            member.role == UserRole.admin
                ? Icons.admin_panel_settings_outlined
                : Icons.person_outline,
            color: member.role == UserRole.admin
                ? theme.colorScheme.primary
                : theme.colorScheme.secondary,
          ),
        ),
        title: Text(member.email),
        subtitle: Text(
          member.role == UserRole.admin ? l10n.roleAdmin : l10n.roleNurse,
          style: theme.textTheme.bodySmall,
        ),
        trailing: isSelf
            ? Chip(label: Text(l10n.you))
            : IconButton(
                icon: const Icon(Icons.delete_outline),
                color: theme.colorScheme.error,
                tooltip: l10n.removeFromHospital,
                onPressed: () => _confirmRemove(context),
              ),
      ),
    );
  }

  Future<void> _confirmRemove(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.removeStaffTitle),
        content: Text(l10n.removeStaffContent(member.email)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.removeFromHospital),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await Supabase.instance.client
        .from('user_profiles')
        .delete()
        .eq('user_id', member.userId);

    ref.invalidate(staffListProvider);
  }
}

// ── Add Staff Dialog ──────────────────────────────────────────────────────────

class _AddStaffDialog extends StatefulWidget {
  const _AddStaffDialog({required this.onCreated});
  final VoidCallback onCreated;

  @override
  State<_AddStaffDialog> createState() => _AddStaffDialogState();
}

class _AddStaffDialogState extends State<_AddStaffDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  UserRole _role = UserRole.nurse;
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await Supabase.instance.client.functions.invoke(
        'create-staff',
        body: {
          'email': _emailCtrl.text.trim(),
          'password': _passwordCtrl.text,
          'role': _role.name,
        },
      );
      if (res.data?['error'] != null) {
        setState(() => _error = res.data['error'] as String);
        return;
      }
      widget.onCreated();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.addStaffTitle),
      content: SizedBox(
        width: 360,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(labelText: l10n.emailLabel),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? l10n.validationRequired : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordCtrl,
                obscureText: _obscure,
                decoration: InputDecoration(
                  labelText: l10n.temporaryPassword,
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return l10n.validationRequired;
                  if (v.length < 8) return l10n.validationPasswordLength;
                  return null;
                },
              ),
              const SizedBox(height: 16),
              SegmentedButton<UserRole>(
                showSelectedIcon: false,
                selected: {_role},
                onSelectionChanged: (s) => setState(() => _role = s.first),
                segments: [
                  ButtonSegment(value: UserRole.nurse, label: Text(l10n.roleNurse)),
                  ButtonSegment(value: UserRole.admin, label: Text(l10n.roleAdmin)),
                  const ButtonSegment(value: UserRole.parent, label: Text('Parent')),
                ],
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.error, fontSize: 12)),
              ],
            ],
          ),
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
              : Text(l10n.addStaff),
        ),
      ],
    );
  }
}

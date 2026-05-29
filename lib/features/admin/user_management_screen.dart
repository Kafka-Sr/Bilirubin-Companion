import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bilirubin/core/l10n/app_localizations.dart';
import 'package:bilirubin/providers/admin_providers.dart';
import 'package:bilirubin/providers/audit_providers.dart';
import 'package:bilirubin/providers/auth_providers.dart';
import 'package:bilirubin/providers/supabase_providers.dart';
class UserManagementScreen extends ConsumerStatefulWidget {
  const UserManagementScreen({super.key});

  @override
  ConsumerState<UserManagementScreen> createState() =>
      _UserManagementScreenState();
}

class _UserManagementScreenState extends ConsumerState<UserManagementScreen> {
  String _roleFilter = 'all';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final usersAsync = ref.watch(allUsersProvider);
    final currentUserId =
        ref.watch(userProfileProvider).valueOrNull?.userId ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.userManagementTitle),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.person_add_outlined),
        label: Text(l10n.addAccountFab),
        onPressed: () => _showAddAccountDialog(context, ref),
      ),
      body: usersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.loadingUsersError(e.toString()))),
        data: (users) {
          final filtered = users.where((u) {
            final matchesRole =
                _roleFilter == 'all' || u['role'] == _roleFilter;
            final q = _searchQuery.toLowerCase();
            final matchesSearch = q.isEmpty ||
                (u['full_name'] as String? ?? '')
                    .toLowerCase()
                    .contains(q) ||
                (u['role'] as String? ?? '').toLowerCase().contains(q);
            return matchesRole && matchesSearch;
          }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: l10n.adminSearchUsersHint,
                    prefixIcon: const Icon(Icons.search),
                    border: const OutlineInputBorder(),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 12),
                  ),
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
              ),
              _RoleFilterBar(
                selected: _roleFilter,
                onChanged: (v) => setState(() => _roleFilter = v),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? Center(child: Text(l10n.noAccountsFound))
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, i) => _UserTile(
                          user: filtered[i],
                          isSelf: filtered[i]['user_id'] == currentUserId,
                          onToggleActive: () =>
                              _toggleActive(context, ref, filtered[i]),
                          onEdit: () =>
                              _showEditAccountDialog(context, ref, filtered[i]),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _toggleActive(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> user,
  ) async {
    final isActive = user['is_active'] as bool? ?? true;
    final name = user['full_name'] as String;
    final role = user['role'] as String;
    final l10n = AppLocalizations.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final dl10n = AppLocalizations.of(ctx);
        return AlertDialog(
          title: Text(isActive
              ? dl10n.deactivateAccountTitle
              : dl10n.reactivateAccountTitle),
          content: Text(
            isActive
                ? dl10n.deactivateConfirmContent(name, role)
                : dl10n.reactivateConfirmContent(name, role),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(dl10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(isActive
                  ? dl10n.deactivateAccountTitle
                  : dl10n.reactivateAccountTitle),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) return;

    try {
      final client = ref.read(supabaseClientProvider);
      final session = ref.read(supabaseSessionProvider).valueOrNull;
      if (client == null || session == null) throw Exception('Not authenticated');

      final targetUserId = user['user_id'] as String;
      await client.functions.invoke(
        'toggle-user-active',
        body: {'userId': targetUserId, 'active': !isActive},
        headers: {'Authorization': 'Bearer ${session.accessToken}'},
      );

      final audit = ref.read(auditRepositoryProvider);
      if (isActive) {
        audit.logAccountDeactivate(targetUserId, name: name, role: role);
      } else {
        audit.logAccountReactivate(targetUserId, name: name, role: role);
      }
      ref.invalidate(allUsersProvider);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.adminErrorGeneric)),
        );
      }
    }
  }

  Future<void> _showAddAccountDialog(
      BuildContext context, WidgetRef ref) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => _AddAccountDialog(ref: ref),
    );
  }

  Future<void> _showEditAccountDialog(
      BuildContext context, WidgetRef ref, Map<String, dynamic> user) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => _EditAccountDialog(ref: ref, user: user),
    );
  }

}

// ── Role filter bar ───────────────────────────────────────────────────────────

class _RoleFilterBar extends StatelessWidget {
  const _RoleFilterBar({required this.selected, required this.onChanged});

  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final roles = [
      ('all', l10n.roleAll),
      ('admin', l10n.roleAdmin),
      ('staff', l10n.roleStaff),
      ('parent', l10n.roleParent),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        spacing: 8,
        children: roles
            .map((r) => FilterChip(
                  label: Text(r.$2),
                  selected: selected == r.$1,
                  onSelected: (_) => onChanged(r.$1),
                ))
            .toList(),
      ),
    );
  }
}

// ── User tile ─────────────────────────────────────────────────────────────────

class _UserTile extends StatelessWidget {
  const _UserTile({
    required this.user,
    required this.isSelf,
    required this.onToggleActive,
    required this.onEdit,
  });

  final Map<String, dynamic> user;
  final bool isSelf;
  final VoidCallback onToggleActive;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final isActive = user['is_active'] as bool? ?? true;
    final role = user['role'] as String;
    final name = user['full_name'] as String;
    final dimColor =
        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38);
    final l10n = AppLocalizations.of(context);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isActive
            ? _roleColor(context, role).withValues(alpha: 0.15)
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Icon(
          Icons.person,
          color: isActive ? _roleColor(context, role) : dimColor,
        ),
      ),
      title: Text(
        name,
        style: isActive ? null : TextStyle(color: dimColor),
      ),
      subtitle: Row(
        spacing: 6,
        children: [
          _RoleBadge(role: role, isActive: isActive),
          if (!isActive)
            Text(
              l10n.deactivatedLabel,
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: dimColor),
            ),
          if (isSelf)
            Text(
              l10n.selfLabel,
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: dimColor),
            ),
        ],
      ),
      trailing: isSelf
          ? null
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: l10n.adminEditUser,
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: Icon(
                    isActive
                        ? Icons.block_outlined
                        : Icons.check_circle_outline,
                    color: isActive
                        ? Theme.of(context).colorScheme.error
                        : Theme.of(context).colorScheme.primary,
                  ),
                  tooltip:
                      isActive ? l10n.adminDeactivate : l10n.adminReactivate,
                  onPressed: onToggleActive,
                ),
              ],
            ),
    );
  }

  Color _roleColor(BuildContext context, String role) {
    final cs = Theme.of(context).colorScheme;
    return switch (role) {
      'admin' => cs.error,
      'staff' => cs.primary,
      _ => cs.tertiary,
    };
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.role, required this.isActive});

  final String role;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = isActive
        ? switch (role) {
            'admin' => cs.error,
            'staff' => cs.primary,
            _ => cs.tertiary,
          }
        : cs.onSurface.withValues(alpha: 0.38);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        role.toUpperCase(),
        style: Theme.of(context)
            .textTheme
            .labelSmall
            ?.copyWith(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}

// ── Add account dialog ────────────────────────────────────────────────────────

class _AddAccountDialog extends ConsumerStatefulWidget {
  const _AddAccountDialog({required this.ref});

  final WidgetRef ref;

  @override
  ConsumerState<_AddAccountDialog> createState() => _AddAccountDialogState();
}

class _AddAccountDialogState extends ConsumerState<_AddAccountDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  String _role = 'staff';
  bool _loading = false;
  bool _obscurePassword = true;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
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
      final client = ref.read(supabaseClientProvider);
      final session = ref.read(supabaseSessionProvider).valueOrNull;
      if (client == null || session == null) throw Exception('Not authenticated');

      final result = await client.functions.invoke(
        'create-staff',
        body: {
          'email': _emailCtrl.text.trim(),
          'password': _passwordCtrl.text,
          'fullName': _nameCtrl.text.trim(),
          'role': _role,
        },
        headers: {'Authorization': 'Bearer ${session.accessToken}'},
      );
      final newUserId =
          (result.data as Map<String, dynamic>?)?['userId'] as String?;
      if (newUserId != null) {
        ref.read(auditRepositoryProvider).logAccountCreate(
          newUserId,
          email: _emailCtrl.text.trim(),
          name: _nameCtrl.text.trim(),
          role: _role,
        );
      }

      ref.invalidate(allUsersProvider);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.addAccountDialogTitle),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: InputDecoration(labelText: l10n.fullNameLabel),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? l10n.validationRequired : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(labelText: l10n.loginEmailLabel),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? l10n.validationRequired : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordCtrl,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: l10n.loginPasswordLabel,
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                validator: (v) =>
                    (v == null || v.length < 8) ? l10n.passwordMinLength : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _role,
                decoration: InputDecoration(labelText: l10n.roleLabel),
                items: [
                  DropdownMenuItem(value: 'staff', child: Text(l10n.roleStaff)),
                  DropdownMenuItem(value: 'admin', child: Text(l10n.roleAdmin)),
                  DropdownMenuItem(
                      value: 'parent', child: Text(l10n.roleParent)),
                ],
                onChanged: (v) => setState(() => _role = v ?? 'staff'),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
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
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.createLabel),
        ),
      ],
    );
  }
}

// ── Edit account dialog ───────────────────────────────────────────────────────

class _EditAccountDialog extends ConsumerStatefulWidget {
  const _EditAccountDialog({required this.ref, required this.user});

  final WidgetRef ref;
  final Map<String, dynamic> user;

  @override
  ConsumerState<_EditAccountDialog> createState() => _EditAccountDialogState();
}

class _EditAccountDialogState extends ConsumerState<_EditAccountDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late String _role;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _nameCtrl =
        TextEditingController(text: widget.user['full_name'] as String? ?? '');
    _role = widget.user['role'] as String? ?? 'staff';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final client = ref.read(supabaseClientProvider);
      if (client == null) throw Exception('Not authenticated');

      final targetUserId = widget.user['user_id'] as String;
      await client.from('user_profiles').update({
        'full_name': _nameCtrl.text.trim(),
        'role': _role,
      }).eq('user_id', targetUserId);

      ref.read(auditRepositoryProvider).logAccountEdit(
        targetUserId,
        name: _nameCtrl.text.trim(),
        role: _role,
      );
      ref.invalidate(allUsersProvider);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.adminEditUserTitle),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: InputDecoration(labelText: l10n.fullNameLabel),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? l10n.validationRequired : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _role,
                decoration: InputDecoration(labelText: l10n.roleLabel),
                items: [
                  DropdownMenuItem(value: 'staff', child: Text(l10n.roleStaff)),
                  DropdownMenuItem(value: 'admin', child: Text(l10n.roleAdmin)),
                  DropdownMenuItem(
                      value: 'parent', child: Text(l10n.roleParent)),
                ],
                onChanged: (v) => setState(() => _role = v ?? 'staff'),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
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
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.adminSaveChanges),
        ),
      ],
    );
  }
}

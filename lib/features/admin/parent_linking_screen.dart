import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bilirubin/core/l10n/app_localizations.dart';
import 'package:bilirubin/providers/admin_providers.dart';
import 'package:bilirubin/providers/audit_providers.dart';
import 'package:bilirubin/providers/auth_providers.dart';
import 'package:bilirubin/providers/baby_providers.dart';
import 'package:bilirubin/providers/supabase_providers.dart';

class ParentLinkingScreen extends ConsumerStatefulWidget {
  const ParentLinkingScreen({super.key});

  @override
  ConsumerState<ParentLinkingScreen> createState() =>
      _ParentLinkingScreenState();
}

class _ParentLinkingScreenState extends ConsumerState<ParentLinkingScreen> {
  final _emailCtrl = TextEditingController();
  bool _searching = false;
  String? _foundUserId;
  String? _foundName;
  String? _searchError;
  String? _selectedBabyId;
  bool _linking = false;
  String? _linkError;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _searchParent() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) return;
    setState(() {
      _searching = true;
      _searchError = null;
      _foundUserId = null;
      _foundName = null;
    });
    try {
      final client = ref.read(supabaseClientProvider);
      final session = ref.read(supabaseSessionProvider).valueOrNull;
      if (client == null || session == null) throw Exception('Not authenticated');

      final result = await client.functions.invoke(
        'lookup-parent',
        body: {'email': email},
        headers: {'Authorization': 'Bearer ${session.accessToken}'},
      );
      final data = result.data as Map<String, dynamic>?;
      if (data == null) throw Exception('Parent not found');
      setState(() {
        _foundUserId = data['userId'] as String?;
        _foundName = data['fullName'] as String?;
      });
    } catch (e) {
      setState(() => _searchError = 'Parent not found: $e');
    } finally {
      setState(() => _searching = false);
    }
  }

  Future<void> _linkParent() async {
    final parentId = _foundUserId;
    final babyId = _selectedBabyId;
    if (parentId == null || babyId == null) return;
    setState(() {
      _linking = true;
      _linkError = null;
    });
    try {
      final client = ref.read(supabaseClientProvider);
      final profile = ref.read(userProfileProvider).valueOrNull;
      final user = ref.read(supabaseUserProvider);
      if (client == null || profile == null || user == null) {
        throw Exception('Not authenticated');
      }

      // Ensure the baby exists in Supabase before inserting the FK row.
      // Babies may not have synced yet if the outbox hasn't drained.
      final baby = ref.read(babiesListProvider).valueOrNull
          ?.firstWhere((b) => b.babyId == babyId);
      if (baby != null) {
        await client.from('babies').upsert({
          'baby_id': baby.babyId,
          'hospital_id': baby.hospitalId,
          'baby_name': baby.babyName,
          'baby_dob': baby.babyDob.toIso8601String(),
          'baby_weight': baby.babyWeight,
          'is_archived': baby.isArchived,
          'created_at': baby.createdAt.toIso8601String(),
          'updated_at': baby.updatedAt.toIso8601String(),
        }, onConflict: 'baby_id');
      }

      await client.from('parent_access').upsert({
        'parent_id': parentId,
        'baby_id': babyId,
        'hospital_id': profile.hospitalId,
        'granted_by': user.id,
      });

      ref.read(auditRepositoryProvider).logParentLink(parentId, babyId);
      ref.invalidate(parentLinksProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).parentLinkedSuccess)),
        );
        setState(() {
          _foundUserId = null;
          _foundName = null;
          _selectedBabyId = null;
          _emailCtrl.clear();
        });
      }
    } catch (e) {
      setState(() => _linkError = 'Failed to link: $e');
    } finally {
      setState(() => _linking = false);
    }
  }

  Future<void> _unlinkParent(String parentId, String babyId) async {
    final client = ref.read(supabaseClientProvider);
    if (client == null) return;
    try {
      await client
          .from('parent_access')
          .delete()
          .eq('parent_id', parentId)
          .eq('baby_id', babyId);
      ref.read(auditRepositoryProvider).logParentUnlink(parentId, babyId);
      ref.invalidate(parentLinksProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to unlink: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final babiesAsync = ref.watch(babiesListProvider);
    final babies = babiesAsync.valueOrNull ?? [];
    final linksAsync = ref.watch(parentLinksProvider);
    final cs = Theme.of(context).colorScheme;

    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.parentAccessTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Existing links ──────────────────────────────────────────────────
          Text(l10n.currentLinksTitle,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          linksAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) =>
                Text('Error: $e', style: TextStyle(color: cs.error)),
            data: (links) {
              if (links.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    l10n.noParentLinksYet,
                    style: TextStyle(color: cs.onSurfaceVariant),
                  ),
                );
              }
              return Column(
                children: links.map((link) {
                  final parentId = link['parent_id'] as String;
                  final babyId = link['baby_id'] as String;
                  final parentName =
                      (link['user_profiles'] as Map<String, dynamic>?)?['full_name']
                              as String? ??
                          'Unknown parent';
                  final babyName =
                      (link['babies'] as Map<String, dynamic>?)?['baby_name']
                              as String? ??
                          'Unknown baby';
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(child: Icon(Icons.family_restroom)),
                    title: Text(parentName),
                    subtitle: Text('→ $babyName'),
                    trailing: IconButton(
                      icon: Icon(Icons.link_off, color: cs.error),
                      tooltip: l10n.unlinkParentTitle,
                      onPressed: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (ctx) {
                            final dl10n = AppLocalizations.of(ctx);
                            return AlertDialog(
                              title: Text(dl10n.unlinkParentTitle),
                              content: Text(dl10n.unlinkConfirmContent(parentName, babyName)),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(ctx).pop(false),
                                  child: Text(dl10n.cancel),
                                ),
                                FilledButton(
                                  onPressed: () =>
                                      Navigator.of(ctx).pop(true),
                                  child: Text(dl10n.unlinkParentTitle),
                                ),
                              ],
                            );
                          },
                        );
                        if (confirmed == true) {
                          await _unlinkParent(parentId, babyId);
                        }
                      },
                    ),
                  );
                }).toList(),
              );
            },
          ),

          const Divider(height: 40),

          // ── Link a parent ───────────────────────────────────────────────────
          Text(l10n.linkParentSectionTitle,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),

          // Step 1: search
          Text(l10n.findParentStep,
              style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: l10n.parentEmailLabel,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _searching ? null : _searchParent,
                child: _searching
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(l10n.searchLabel),
              ),
            ],
          ),
          if (_searchError != null) ...[
            const SizedBox(height: 6),
            Text(_searchError!,
                style: TextStyle(color: cs.error, fontSize: 12)),
          ],
          if (_foundUserId != null) ...[
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(_foundName ?? 'Unknown'),
              subtitle: Text(_emailCtrl.text),
              trailing: const Icon(Icons.check_circle, color: Colors.green),
            ),
          ],

          const SizedBox(height: 20),

          // Step 2: select baby
          Text(l10n.selectBabyStep,
              style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _selectedBabyId,
            decoration: InputDecoration(
              labelText: l10n.babyLabel,
              border: const OutlineInputBorder(),
            ),
            items: babies
                .map((b) => DropdownMenuItem(
                      value: b.babyId,
                      child: Text(b.babyName),
                    ))
                .toList(),
            onChanged: (v) => setState(() => _selectedBabyId = v),
          ),

          const SizedBox(height: 20),

          // Step 3: link
          FilledButton.icon(
            icon: const Icon(Icons.link),
            label: Text(l10n.linkParentButton),
            onPressed: (_foundUserId == null ||
                    _selectedBabyId == null ||
                    _linking)
                ? null
                : _linkParent,
          ),
          if (_linkError != null) ...[
            const SizedBox(height: 6),
            Text(_linkError!,
                style: TextStyle(color: cs.error, fontSize: 12)),
          ],
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bilirubin/core/l10n/app_localizations.dart';
import 'package:bilirubin/providers/admin_providers.dart';
import 'package:bilirubin/providers/audit_providers.dart';
import 'package:bilirubin/providers/auth_providers.dart';
import 'package:bilirubin/providers/baby_providers.dart';
import 'package:bilirubin/providers/supabase_providers.dart';
import 'package:bilirubin/utils/extensions.dart';

class ParentLinkingScreen extends ConsumerStatefulWidget {
  const ParentLinkingScreen({super.key});

  @override
  ConsumerState<ParentLinkingScreen> createState() =>
      _ParentLinkingScreenState();
}

class _ParentLinkingScreenState extends ConsumerState<ParentLinkingScreen> {
  String _linksQuery = '';

  Future<void> _unlinkParent(
    String parentId,
    String babyId, {
    required String parentName,
    required String babyName,
  }) async {
    final client = ref.read(supabaseClientProvider);
    if (client == null) return;
    try {
      await client
          .from('parent_access')
          .delete()
          .eq('parent_id', parentId)
          .eq('baby_id', babyId);
      ref.read(auditRepositoryProvider).logParentUnlink(
        parentId,
        babyId,
        parentName: parentName,
        babyName: babyName,
      );
      ref.invalidate(parentLinksProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(AppLocalizations.of(context).adminUnlinkFailed)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final linksAsync = ref.watch(parentLinksProvider);
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.parentAccessTitle)),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.link),
        label: Text(l10n.linkParentFab),
        onPressed: () => showDialog<void>(
          context: context,
          builder: (_) => _LinkParentDialog(
            onLinked: () => ref.invalidate(parentLinksProvider),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Container(
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(99),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: TextField(
                decoration: InputDecoration(
                  hintText: l10n.searchLinksHint,
                  border: InputBorder.none,
                  icon: Icon(Icons.search, size: 20,
                      color: cs.onSurfaceVariant),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
                onChanged: (v) =>
                    setState(() => _linksQuery = v.toLowerCase()),
              ),
            ),
          ),
          Expanded(
            child: linksAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                  child: Text(
                l10n.adminErrorGeneric,
                style: TextStyle(color: cs.error),
              )),
              data: (links) {
                final filtered = _linksQuery.isEmpty
                    ? links
                    : links.where((link) {
                        final parentName = ((link['user_profiles']
                                    as Map<String, dynamic>?)?['full_name']
                                as String? ??
                            '').toLowerCase();
                        final babyName = ((link['babies']
                                    as Map<String, dynamic>?)?['baby_name']
                                as String? ??
                            '').toLowerCase();
                        return parentName.contains(_linksQuery) ||
                            babyName.contains(_linksQuery);
                      }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      l10n.noParentLinksYet,
                      style: TextStyle(color: cs.onSurfaceVariant),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final link = filtered[i];
                    final parentId = link['parent_id'] as String;
                    final babyId = link['baby_id'] as String;
                    final parentName =
                        (link['user_profiles']
                                    as Map<String, dynamic>?)?['full_name']
                                as String? ??
                            'Unknown parent';
                    final babyName =
                        (link['babies']
                                    as Map<String, dynamic>?)?['baby_name']
                                as String? ??
                            'Unknown baby';
                    return ListTile(
                      leading: const CircleAvatar(
                          child: Icon(Icons.family_restroom)),
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
                                content: Text(dl10n.unlinkConfirmContent(
                                    parentName, babyName)),
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
                            await _unlinkParent(
                              parentId,
                              babyId,
                              parentName: parentName,
                              babyName: babyName,
                            );
                          }
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LinkParentDialog extends ConsumerStatefulWidget {
  const _LinkParentDialog({required this.onLinked});

  final VoidCallback onLinked;

  @override
  ConsumerState<_LinkParentDialog> createState() => _LinkParentDialogState();
}

class _LinkParentDialogState extends ConsumerState<_LinkParentDialog> {
  String? _selectedParentId;
  String? _selectedParentName;
  String? _selectedBabyId;
  bool _linking = false;
  String? _linkError;

  Future<void> _linkParent() async {
    final parentId = _selectedParentId;
    final babyId = _selectedBabyId;
    if (parentId == null || babyId == null) return;

    final existingLinks = ref.read(parentLinksProvider).valueOrNull ?? [];
    final alreadyLinked = existingLinks.any((link) =>
        link['parent_id'] == parentId && link['baby_id'] == babyId);
    if (alreadyLinked) {
      setState(() =>
          _linkError = AppLocalizations.of(context).adminLinkAlreadyExists);
      return;
    }

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

      final linkedBaby = ref.read(babiesListProvider).valueOrNull
          ?.firstWhereOrNull((b) => b.babyId == babyId);
      ref.read(auditRepositoryProvider).logParentLink(
        parentId,
        babyId,
        parentEmail: _selectedParentName ?? parentId,
        babyName: linkedBaby?.babyName ?? babyId,
      );

      widget.onLinked();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  AppLocalizations.of(context).parentLinkedSuccess)),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() =>
            _linkError = AppLocalizations.of(context).adminLinkFailed);
      }
    } finally {
      if (mounted) setState(() => _linking = false);
    }
  }

  void _openParentSheet(List<Map<String, dynamic>> parents) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _SearchSheet<Map<String, dynamic>>(
        items: parents,
        searchHint: AppLocalizations.of(context).searchParentHint,
        emptyText: AppLocalizations.of(context).noParentAccountsFound,
        itemLabel: (p) => p['full_name'] as String? ?? '?',
        onSelected: (p) {
          setState(() {
            _selectedParentId = p['user_id'] as String?;
            _selectedParentName = p['full_name'] as String?;
          });
        },
      ),
    );
  }

  void _openBabySheet(List babies) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _SearchSheet(
        items: babies,
        searchHint: AppLocalizations.of(context).searchBabiesHint,
        emptyText: AppLocalizations.of(context).noBabiesTitle,
        itemLabel: (b) => b.babyName as String,
        onSelected: (b) {
          setState(() {
            _selectedBabyId = b.babyId as String;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final babiesAsync = ref.watch(babiesListProvider);
    final babies = babiesAsync.valueOrNull ?? [];
    final parentsAsync = ref.watch(hospitalParentAccountsProvider);
    final parents = parentsAsync.valueOrNull ?? [];
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    final selectedBabyName =
        babies.firstWhereOrNull((b) => b.babyId == _selectedBabyId)?.babyName;

    return AlertDialog(
      title: Text(l10n.linkParentSectionTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PillDropdown(
            icon: Icons.person_outline,
            label: _selectedParentName ?? l10n.selectParentAccount,
            isPlaceholder: _selectedParentName == null,
            onTap: () => _openParentSheet(parents),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.arrow_downward, size: 16, color: cs.outline),
              const SizedBox(width: 6),
              Text(l10n.linkTo,
                  style: tt.bodySmall?.copyWith(color: cs.outline)),
            ],
          ),
          const SizedBox(height: 10),
          _PillDropdown(
            icon: Icons.child_friendly,
            label: selectedBabyName ?? l10n.selectBaby,
            isPlaceholder: selectedBabyName == null,
            onTap: () => _openBabySheet(babies),
          ),
          if (_linkError != null) ...[
            const SizedBox(height: 8),
            Text(_linkError!,
                style: TextStyle(color: cs.error, fontSize: 12)),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton.icon(
          icon: const Icon(Icons.link, size: 18),
          label: Text(l10n.linkParentButton),
          onPressed: (_selectedParentId == null ||
                  _selectedBabyId == null ||
                  _linking)
              ? null
              : _linkParent,
        ),
      ],
    );
  }
}

class _PillDropdown extends StatelessWidget {
  const _PillDropdown({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isPlaceholder = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isPlaceholder;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(99),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(99),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: cs.onSurfaceVariant),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isPlaceholder
                          ? cs.onSurfaceVariant
                          : cs.onSurface,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.keyboard_arrow_down,
                size: 20, color: cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

class _SearchSheet<T> extends StatefulWidget {
  const _SearchSheet({
    required this.items,
    required this.searchHint,
    required this.emptyText,
    required this.itemLabel,
    required this.onSelected,
  });

  final List<T> items;
  final String searchHint;
  final String emptyText;
  final String Function(T) itemLabel;
  final void Function(T) onSelected;

  @override
  State<_SearchSheet<T>> createState() => _SearchSheetState<T>();
}

class _SearchSheetState<T> extends State<_SearchSheet<T>> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final filtered = _query.isEmpty
        ? widget.items
        : widget.items
            .where((item) => widget
                .itemLabel(item)
                .toLowerCase()
                .contains(_query.toLowerCase()))
            .toList();

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (_, scrollCtrl) => Column(
        children: [
          const SizedBox(height: 8),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: cs.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(99),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: TextField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: widget.searchHint,
                  border: InputBorder.none,
                  icon: Icon(Icons.search, size: 20,
                      color: cs.onSurfaceVariant),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: filtered.isEmpty
                ? Center(child: Text(widget.emptyText))
                : ListView.builder(
                    controller: scrollCtrl,
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final item = filtered[i];
                      return ListTile(
                        title: Text(widget.itemLabel(item)),
                        onTap: () {
                          widget.onSelected(item);
                          Navigator.of(context).pop();
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

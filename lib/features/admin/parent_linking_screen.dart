import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bilirubin/core/l10n/app_localizations.dart';
import 'package:bilirubin/providers/baby_providers.dart';

class ParentLinkingScreen extends ConsumerStatefulWidget {
  const ParentLinkingScreen({super.key});

  @override
  ConsumerState<ParentLinkingScreen> createState() => _ParentLinkingScreenState();
}

class _ParentLinkingScreenState extends ConsumerState<ParentLinkingScreen> {
  final _emailCtrl = TextEditingController();

  bool _searching = false;
  String? _searchError;
  _FoundParent? _foundParent;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) return;
    setState(() {
      _searching = true;
      _searchError = null;
      _foundParent = null;
    });
    try {
      final res = await Supabase.instance.client.functions.invoke(
        'lookup-parent',
        body: {'email': email},
      );
      if (res.data?['error'] != null) {
        setState(() => _searchError = res.data['error'] as String);
        return;
      }
      setState(() => _foundParent = _FoundParent(
            userId: res.data['userId'] as String,
            email: res.data['email'] as String,
          ));
    } catch (e) {
      setState(() => _searchError = e.toString());
    } finally {
      setState(() => _searching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.parentAccess)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            l10n.parentSearchDescription,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: l10n.parentEmailLabel,
                    prefixIcon: const Icon(Icons.email_outlined),
                  ),
                  onSubmitted: (_) => _search(),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton(
                onPressed: _searching ? null : _search,
                child: _searching
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(l10n.searchAction),
              ),
            ],
          ),
          if (_searchError != null) ...[
            const SizedBox(height: 12),
            Text(
              _searchError!,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.error, fontSize: 13),
            ),
          ],
          if (_foundParent != null) ...[
            const SizedBox(height: 24),
            _LinkCard(parent: _foundParent!),
          ],
        ],
      ),
    );
  }
}

// ── Found parent card + baby selector ────────────────────────────────────────

class _FoundParent {
  const _FoundParent({required this.userId, required this.email});
  final String userId;
  final String email;
}

class _LinkCard extends ConsumerStatefulWidget {
  const _LinkCard({required this.parent});
  final _FoundParent parent;

  @override
  ConsumerState<_LinkCard> createState() => _LinkCardState();
}

class _LinkCardState extends ConsumerState<_LinkCard> {
  int? _selectedBabyId;
  bool _linking = false;
  String? _error;
  bool _linked = false;

  Future<void> _link() async {
    if (_selectedBabyId == null) return;
    setState(() {
      _linking = true;
      _error = null;
    });
    try {
      await Supabase.instance.client.from('parent_baby_access').insert({
        'parent_user_id': widget.parent.userId,
        'baby_id': _selectedBabyId,
        'granted_by': Supabase.instance.client.auth.currentUser!.id,
      });
      setState(() => _linked = true);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _linking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final babiesAsync = ref.watch(babiesListProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.green),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.parentFound(widget.parent.email),
                    style: theme.textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            if (_linked) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.link, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(l10n.linkedSuccess),
                ],
              ),
            ] else ...[
              const SizedBox(height: 16),
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
                  onChanged: (v) => setState(() => _selectedBabyId = v),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!,
                    style: TextStyle(color: theme.colorScheme.error, fontSize: 12)),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: (_linking || _selectedBabyId == null) ? null : _link,
                  child: _linking
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(l10n.linkParentToBaby),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

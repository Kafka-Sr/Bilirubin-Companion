import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bilirubin/core/l10n/app_localizations.dart';

/// Admin panel hub — tiles link to sub-screens.
class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.adminPanelTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _AdminTile(
            icon: Icons.manage_accounts_outlined,
            title: l10n.adminUserManagementTitle,
            subtitle: l10n.adminUserManagementSubtitle,
            onTap: () => context.push('/admin/accounts'),
          ),
          _AdminTile(
            icon: Icons.family_restroom_outlined,
            title: l10n.adminParentAccessTitle,
            subtitle: l10n.adminParentAccessSubtitle,
            onTap: () => context.push('/admin/parents'),
          ),
          _AdminTile(
            icon: Icons.swap_horiz_outlined,
            title: l10n.adminTransfersTitle,
            subtitle: l10n.adminTransfersSubtitle,
            onTap: () => context.push('/admin/transfers'),
          ),
          _AdminTile(
            icon: Icons.history_outlined,
            title: l10n.adminAuditTitle,
            subtitle: l10n.adminAuditSubtitle,
            onTap: () => context.push('/admin/audit'),
          ),
        ],
      ),
    );
  }
}

class _AdminTile extends StatelessWidget {
  const _AdminTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: cs.primaryContainer,
          child: Icon(icon, color: cs.onPrimaryContainer),
        ),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

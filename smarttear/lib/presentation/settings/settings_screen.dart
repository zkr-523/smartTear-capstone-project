import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/providers/est_bg_settings_notifier.dart';
import '../../application/providers/settings_notifier.dart';
import '../../application/providers/simulation_connector_provider.dart';
import '../auth/auth_ui.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conn = ref.watch(simulationConnectorProvider);
    final estBg = ref.watch(estBgSettingsNotifierProvider);
    final settings = ref.watch(settingsNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _SectionTitle(title: 'Device'),
          _DeviceConnectionCard(conn: conn),
          const Divider(height: 24),
          _SectionTitle(title: 'Analysis'),
          estBg.when(
            loading: () => const ListTile(
              title: Text('Estimated BG'),
              trailing: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            error: (e, _) => ListTile(
              title: const Text('Estimated BG'),
              subtitle: Text('$e'),
            ),
            data: (enabled) => SwitchListTile(
              title: const Text('Estimated BG'),
              subtitle: const Text(
                'ML model trained on real paired measurements dataset',
              ),
              value: enabled,
              onChanged: (v) => ref
                  .read(estBgSettingsNotifierProvider.notifier)
                  .setEnabled(v),
            ),
          ),
          const Divider(height: 24),
          _SectionTitle(title: 'Data'),
          ListTile(
            leading: const Icon(Icons.table_chart_outlined),
            title: const Text('Export CSV'),
            onTap: () async {
              final err = await ref
                  .read(settingsNotifierProvider.notifier)
                  .exportReadingsCsv();
              if (!context.mounted) return;
              if (err != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(err)),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.save_alt_outlined),
            title: const Text('Backup'),
            subtitle: const Text('Save all readings as a JSON file'),
            onTap: () async {
              final err = await ref
                  .read(settingsNotifierProvider.notifier)
                  .backupReadingsJson();
              if (!context.mounted) return;
              if (err != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(err)),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.restore_outlined),
            title: const Text('Restore'),
            subtitle: const Text('Merge readings from a backup'),
            onTap: () => _showRestoreDialog(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Data privacy'),
            onTap: () => _showPrivacyDialog(context),
          ),
          const Divider(height: 24),
          _SectionTitle(title: 'Account'),
          settings.when(
            loading: () => const ListTile(title: Text('Loading…')),
            error: (e, _) => ListTile(title: Text('Error: $e')),
            data: (vm) => ListTile(
              leading: const Icon(Icons.person_outline),
              title: Text(vm.email ?? 'Signed in'),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign out'),
            onTap: () async {
              await ref.read(settingsNotifierProvider.notifier).signOut();
              if (!context.mounted) return;
              context.go('/auth/login');
            },
          ),
          ListTile(
            leading: Icon(Icons.delete_forever_outlined, color: Colors.red.shade700),
            title: Text('Delete account', style: TextStyle(color: Colors.red.shade700)),
            onTap: () => _confirmDeleteAccount(context, ref),
          ),
        ],
      ),
    );
  }
}

/// Avoids [ListTile] trailing width assertion on wide web layouts.
class _DeviceConnectionCard extends ConsumerWidget {
  const _DeviceConnectionCard({required this.conn});

  final SimulationConnectorState conn;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = conn.isConnected
        ? 'Connected'
        : conn.isConnecting
            ? 'Connecting…'
            : 'Disconnected';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            conn.isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
            color: SmartTearAuthUi.primary,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  conn.deviceId,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  status,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (conn.isConnected)
            OutlinedButton(
              onPressed: () =>
                  ref.read(simulationConnectorProvider.notifier).disconnect(),
              style: _compactButtonStyle(isFilled: false),
              child: const Text('Disconnect'),
            )
          else
            FilledButton(
              onPressed: conn.isConnecting
                  ? null
                  : () =>
                      ref.read(simulationConnectorProvider.notifier).connect(),
              style: _compactButtonStyle(isFilled: true),
              child: const Text('Connect'),
            ),
        ],
      ),
    );
  }
}

/// Theme sets [minimumSize] to infinite width; override for inline row buttons.
ButtonStyle _compactButtonStyle({required bool isFilled}) {
  const size = Size(0, 40);
  const padding = EdgeInsets.symmetric(horizontal: 16, vertical: 8);
  return isFilled
      ? FilledButton.styleFrom(minimumSize: size, padding: padding)
      : OutlinedButton.styleFrom(minimumSize: size, padding: padding);
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              letterSpacing: 0.8,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}

Future<void> _showRestoreDialog(BuildContext context, WidgetRef ref) async {
  final controller = TextEditingController();
  try {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restore from backup'),
        content: TextField(
          controller: controller,
          maxLines: 8,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Paste backup JSON',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Merge'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final err = await ref
        .read(settingsNotifierProvider.notifier)
        .restoreReadingsFromJson(controller.text.trim());
    if (!context.mounted) return;
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Backup merged')),
      );
    }
  } finally {
    controller.dispose();
  }
}

void _showPrivacyDialog(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Data privacy'),
      content: const SingleChildScrollView(
        child: Text(
          'Readings are stored on this device for your SmartTear workflow. '
          'Export or backup if you need a copy. Signing out does not erase local data. '
          'Delete individual readings from History, or clear app data in system settings.',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

Future<void> _confirmDeleteAccount(BuildContext context, WidgetRef ref) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Delete account?'),
      content: const Text(
        'This removes your Firebase account. Local readings may remain until cleared.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
  if (ok != true || !context.mounted) return;
  final err = await ref.read(settingsNotifierProvider.notifier).deleteAccount();
  if (!context.mounted) return;
  if (err != null) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
  } else {
    context.go('/auth/login');
  }
}

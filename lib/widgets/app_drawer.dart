import 'package:flutter/material.dart';

import '../core/app_info.dart';
import '../core/launch.dart';
import '../core/theme.dart';
import 'app_logo.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  /// Close the drawer first, then run [action] on the root context
  /// (the drawer's own context is gone after it closes).
  void _run(BuildContext context, void Function(BuildContext) action) {
    final root = Navigator.of(context, rootNavigator: true).context;
    Navigator.of(context).pop();
    action(root);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Drawer(
      backgroundColor: const Color(0xFFF5F9FF),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
              24,
              MediaQuery.of(context).padding.top + 28,
              24,
              26,
            ),
            decoration: const BoxDecoration(gradient: AppTheme.header),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(18),
                  child: const AppLogo(size: 36),
                ),
                const SizedBox(height: 18),
                const Text(
                  AppInfo.appName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Unofficial  •  Made by ${AppInfo.developer}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _Tile(
            icon: Icons.info_outline_rounded,
            title: 'Important notice',
            subtitle: 'This is not an official SNGPL app',
            onTap: () => _run(context, _showNotice),
          ),
          _Tile(
            icon: Icons.help_outline_rounded,
            title: 'How to use',
            subtitle: 'Quick guide to this app',
            onTap: () => _run(context, _showHowTo),
          ),
          _Tile(
            icon: Icons.person_outline_rounded,
            title: 'About the developer',
            subtitle: '${AppInfo.developer}  •  ${AppInfo.developerRole}',
            onTap: () => _run(context, _showDeveloper),
          ),
          _Tile(
            icon: Icons.code_rounded,
            title: 'Rate on GitHub',
            subtitle: AppInfo.githubLabel,
            onTap: () => _run(context, (c) => openUrl(c, AppInfo.githubUrl)),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Text(
              'v${AppInfo.version} — built independently using SNGPL’s public billing portal',
              textAlign: TextAlign.center,
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
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
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppTheme.tint,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: cs.primary),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 16,
          color: AppTheme.ink,
        ),
      ),
      subtitle: Text(subtitle),
    );
  }
}

// ---------------- dialogs / sheets ----------------

void _showNotice(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      icon: Icon(Icons.info_outline_rounded, color: AppTheme.blue, size: 32),
      title: const Text('Important notice'),
      content: const SingleChildScrollView(
        child: Text(
          'This is an unofficial app made independently. It is not published by, '
          'affiliated with or endorsed by SNGPL or any government body.\n\n'
          'It loads the public bill page on sngpl.com.pk for you and shows the '
          'result in a cleaner layout. You always type the captcha yourself.\n\n'
          'Consumer numbers you save stay on your phone. Bill details come from '
          'SNGPL; if SNGPL changes its website, the app may stop working until '
          'it is updated.\n\n'
          'SNGPL does not mark the newest bill as paid on its website. A payment '
          'only appears in the history after the next bill is issued, so the '
          'newest bill is shown as Pending.\n\n'
          'Confirm payments with SNGPL before relying on them.',
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Got it'),
        ),
      ],
    ),
  );
}

void _showHowTo(BuildContext context) {
  const steps = [
    'Tap “Add Number” and save your SNGPL consumer number. Add a label like Home or Shop.',
    'Tap a saved connection to open it.',
    'Type the characters shown in the captcha image, then tap “Get bill”.',
    'See what to pay, the due date, the charges, and your last 12 months marked paid or unpaid.',
    'Tap “Check again” any time for a fresh bill.',
  ];
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How to use',
              style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppTheme.ink,
                  ),
            ),
            const SizedBox(height: 16),
            for (var i = 0; i < steps.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 13,
                      backgroundColor: AppTheme.blue,
                      child: Text(
                        '${i + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(steps[i])),
                  ],
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

void _showDeveloper(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    backgroundColor: Colors.white,
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                gradient: AppTheme.header,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(18),
              child: const AppLogo(size: 36),
            ),
            const SizedBox(height: 14),
            Text(
              AppInfo.developer,
              style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppTheme.ink,
                  ),
            ),
            const SizedBox(height: 2),
            Text(AppInfo.developerRole),
            const SizedBox(height: 14),
            const Text(
              'Built as an independent project. If it helps you, a star on GitHub means a lot.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => openUrl(context, AppInfo.githubUrl),
                icon: const Icon(Icons.code_rounded),
                label: const Text(AppInfo.githubLabel),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

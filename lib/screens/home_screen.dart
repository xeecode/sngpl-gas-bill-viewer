import 'package:flutter/material.dart';

import '../core/app_info.dart';
import '../core/theme.dart';
import '../models/saved_consumer.dart';
import '../services/storage_service.dart';
import '../widgets/add_consumer_dialog.dart';
import '../widgets/app_drawer.dart';
import '../widgets/app_logo.dart';
import '../widgets/consumer_tile.dart';
import 'bill_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _storage = StorageService();
  List<SavedConsumer> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = await _storage.load();
    if (!mounted) return;
    setState(() {
      _items = items;
      _loading = false;
    });
  }

  Future<void> _add() async {
    final result = await showDialog<SavedConsumer>(
      context: context,
      builder: (_) => AddConsumerDialog(
        existing: _items.map((e) => e.number).toSet(),
      ),
    );
    if (result == null) return;
    final next = [..._items, result];
    await _storage.save(next);
    if (!mounted) return;
    setState(() => _items = next);
  }

  Future<void> _remove(SavedConsumer c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove connection?'),
        content: Text('${c.title} will be removed from this phone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final next = _items.where((e) => e.number != c.number).toList();
    await _storage.save(next);
    if (!mounted) return;
    setState(() => _items = next);
  }

  Future<void> _open(SavedConsumer c) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => BillScreen(consumer: c)),
    );
    if (mounted) _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _add,
        icon: const Icon(Icons.add_rounded, size: 26),
        label: const Text('Add Number'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _Header(
              count: _items.length,
              onMenu: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _items.isEmpty
                      ? const _EmptyState()
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
                          itemCount: _items.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 14),
                          itemBuilder: (_, i) => ConsumerTile(
                            consumer: _items[i],
                            onTap: () => _open(_items[i]),
                            onRemove: () => _remove(_items[i]),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.count, required this.onMenu});

  final int count;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    final subtitle = count == 0
        ? 'Save your first connection'
        : count == 1
            ? '1 saved connection'
            : '$count saved connections';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      decoration: BoxDecoration(
        gradient: AppTheme.header,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppTheme.blue.withOpacity(0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Stack(
          children: [
            // large faint flame as a watermark
            Positioned(
              right: -14,
              bottom: -26,
              child: AppLogo(size: 130, color: Colors.white.withOpacity(0.13)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 22, 20, 22),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Menu',
                    onPressed: onMenu,
                    icon: const Icon(
                      Icons.menu_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const AppLogo(size: 34),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          AppInfo.appName,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                color: AppTheme.tint,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(24),
              child: AppLogo(size: 48, color: cs.primary),
            ),
            const SizedBox(height: 20),
            Text(
              'No connections yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppTheme.ink,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap “Add Number” to save your consumer number. After that you only type the captcha to see your bill.',
              textAlign: TextAlign.center,
              style: TextStyle(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

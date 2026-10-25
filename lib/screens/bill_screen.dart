import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../models/bill_data.dart';
import '../models/saved_consumer.dart';
import '../services/sngpl_exception.dart';
import '../services/sngpl_service.dart';
import '../services/storage_service.dart';
import '../core/launch.dart';
import '../widgets/bill_detail_card.dart';
import '../widgets/captcha_card.dart';
import '../widgets/section_card.dart';

class BillScreen extends StatefulWidget {
  const BillScreen({super.key, required this.consumer});

  final SavedConsumer consumer;

  @override
  State<BillScreen> createState() => _BillScreenState();
}

class _BillScreenState extends State<BillScreen> {
  final _service = SngplService();
  final _storage = StorageService();
  final _captchaCtrl = TextEditingController();

  Uint8List? _captcha;
  bool _loadingCaptcha = true;
  bool _submitting = false;
  String? _error;
  BillData? _bill;

  @override
  void initState() {
    super.initState();
    _loadCaptcha();
  }

  @override
  void dispose() {
    _captchaCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCaptcha({bool refresh = false, bool keepError = false}) async {
    setState(() {
      _loadingCaptcha = true;
      if (!keepError) _error = null;
    });
    try {
      final img = refresh
          ? await _service.refreshCaptcha()
          : await _service.loadCaptcha();
      if (!mounted) return;
      setState(() {
        _captcha = img;
        _captchaCtrl.clear();
      });
    } on SngplException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Could not load the captcha. Tap refresh to try again.');
    } finally {
      if (mounted) setState(() => _loadingCaptcha = false);
    }
  }

  Future<void> _submit() async {
    final code = _captchaCtrl.text.trim();
    if (code.isEmpty) {
      setState(() => _error = 'Type the characters shown in the image.');
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final bill = await _service.fetchBill(widget.consumer.number, code);
      await _storage.updateLastBill(widget.consumer.number, bill);
      if (!mounted) return;
      setState(() => _bill = bill);
    } on SngplException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
      await _loadCaptcha(refresh: true, keepError: true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Something went wrong. Try again with a new captcha.');
      await _loadCaptcha(refresh: true, keepError: true);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _checkAgain() {
    setState(() {
      _bill = null;
      _error = null;
    });
    _loadCaptcha();
  }

  @override
  Widget build(BuildContext context) {
    final bill = _bill;
    return Scaffold(
      appBar: AppBar(
        actions: [
          if (bill != null)
            IconButton(
              tooltip: 'Check again',
              onPressed: _checkAgain,
              icon: const Icon(Icons.refresh_rounded),
            ),
        ],
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.consumer.title),
            if (widget.consumer.title != widget.consumer.number)
              Text(
                widget.consumer.number,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: bill == null ? _captchaView() : _billView(bill),
      ),
    );
  }

  List<Widget> _captchaView() => [
        CaptchaCard(
          image: _captcha,
          loading: _loadingCaptcha,
          submitting: _submitting,
          controller: _captchaCtrl,
          error: _error,
          onRefresh: () => _loadCaptcha(refresh: true),
          onSubmit: _submit,
        ),
      ];

  List<Widget> _billView(BillData bill) {
    const gap = SizedBox(height: 14);
    final photo = bill.meterImageUrl;
    final btnShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(18));
    return [
      BillDetailCard(bill: bill),
      if (photo != null) ...[
        gap,
        SectionCard(
          title: 'Meter photo',
          icon: Icons.photo_camera_outlined,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.network(
              photo,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('No meter photo for this month.'),
              ),
            ),
          ),
        ),
      ],
      gap,
      FilledButton.icon(
        onPressed: _checkAgain,
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          shape: btnShape,
        ),
        icon: const Icon(Icons.refresh_rounded),
        label: const Text('Check again'),
      ),
      const SizedBox(height: 10),
      OutlinedButton.icon(
        onPressed: () => openUrl(context, '${SngplService.base}${SngplService.loginPath}'),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          shape: btnShape,
        ),
        icon: const Icon(Icons.open_in_new_rounded),
        label: const Text('Open on SNGPL website'),
      ),
    ];
  }
}

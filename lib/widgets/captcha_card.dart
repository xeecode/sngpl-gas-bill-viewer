import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'section_card.dart';

class CaptchaCard extends StatelessWidget {
  const CaptchaCard({
    super.key,
    required this.image,
    required this.loading,
    required this.submitting,
    required this.controller,
    required this.onRefresh,
    required this.onSubmit,
    this.error,
  });

  final Uint8List? image;
  final bool loading;
  final bool submitting;
  final TextEditingController controller;
  final VoidCallback onRefresh;
  final VoidCallback onSubmit;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final busy = loading || submitting;

    return SectionCard(
      title: 'Verify to view the bill',
      icon: Icons.verified_user_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 68,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: cs.outlineVariant),
                  ),
                  alignment: Alignment.center,
                  child: loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : image == null
                          ? Text(
                              'Captcha not loaded',
                              style: TextStyle(color: Colors.grey.shade700),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.memory(
                                image!,
                                fit: BoxFit.contain,
                                gaplessPlayback: true,
                              ),
                            ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton.filledTonal(
                tooltip: 'New captcha',
                onPressed: busy ? null : onRefresh,
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            controller: controller,
            enabled: !submitting,
            autocorrect: false,
            enableSuggestions: false,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => onSubmit(),
            decoration: const InputDecoration(
              labelText: 'Characters in the image',
            ),
          ),
          if (error != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.errorContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                error!,
                style: TextStyle(color: cs.onErrorContainer),
              ),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: (busy || image == null) ? null : onSubmit,
              icon: submitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.receipt_long_rounded),
              label: Text(submitting ? 'Getting bill' : 'Get bill'),
            ),
          ),
        ],
      ),
    );
  }
}

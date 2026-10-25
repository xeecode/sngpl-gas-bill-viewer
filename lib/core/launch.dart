import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens [url] in the phone's browser. Shows a snackbar if it fails.
Future<void> openUrl(BuildContext context, String url) async {
  final messenger = ScaffoldMessenger.maybeOf(context);
  try {
    final ok = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
    if (!ok) {
      messenger?.showSnackBar(
        const SnackBar(content: Text('Could not open the link.')),
      );
    }
  } catch (_) {
    messenger?.showSnackBar(
      const SnackBar(content: Text('Could not open the link.')),
    );
  }
}

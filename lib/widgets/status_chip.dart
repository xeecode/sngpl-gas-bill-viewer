import 'package:flutter/material.dart';

import '../models/bill_data.dart';

class StatusStyle {
  const StatusStyle(this.label, this.icon, this.fg, this.bg);
  final String label;
  final IconData icon;
  final Color fg;
  final Color bg;
}

StatusStyle styleFor(PayStatus s) {
  switch (s) {
    case PayStatus.paid:
      return const StatusStyle(
        'Paid',
        Icons.check_circle_rounded,
        Color(0xFF1B7F3B),
        Color(0xFFE4F4E9),
      );
    case PayStatus.partial:
      return const StatusStyle(
        'Partly paid',
        Icons.timelapse_rounded,
        Color(0xFF8A5A00),
        Color(0xFFFFF1D6),
      );
    case PayStatus.unpaid:
      return const StatusStyle(
        'Unpaid',
        Icons.error_rounded,
        Color(0xFFC62828),
        Color(0xFFFDE6E6),
      );
  }
}

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});

  final PayStatus status;

  @override
  Widget build(BuildContext context) {
    final s = styleFor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: s.bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(s.icon, size: 14, color: s.fg),
          const SizedBox(width: 4),
          Text(
            s.label,
            style: TextStyle(
              color: s.fg,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

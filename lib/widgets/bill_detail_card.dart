import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../models/bill_data.dart';
import 'app_logo.dart';
import 'status_chip.dart';

const _red = Color(0xFFC62828);
const _redBg = Color(0xFFFDEEEE);
const _redLine = Color(0xFFF3C7C7);
const _green = Color(0xFF1B7F3B);
const _blueBg = Color(0xFFEAF3FF);
const _blueLine = Color(0xFFBBD6F5);
const _greyBox = Color(0xFFF4F7FB);

/// One big card: header, payment status, amounts, meter, details,
/// charges and the 12-month history table.
class BillDetailCard extends StatelessWidget {
  const BillDetailCard({super.key, required this.bill});

  final BillData bill;

  @override
  Widget build(BuildContext context) {
    final surcharge = bill.surcharge;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppTheme.blue.withOpacity(0.10),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Column(
          children: [
            _Header(bill: bill),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (bill.previousBill != null) ...[
                    _PreviousMonthRow(row: bill.previousBill!),
                    const SizedBox(height: 16),
                  ],
                  _AmountBox(
                    title: 'PAYABLE WITHIN DUE DATE',
                    subtitle: 'Due by ${bill.dueDate}',
                    amount: 'Rs. ${bill.payableInDue}',
                    color: AppTheme.blue,
                    bg: _blueBg,
                    line: _blueLine,
                    icon: Icons.event_available_rounded,
                    extra: bill.dueStatus,
                    extraColor: bill.isOverdue ? _red : AppTheme.blue,
                  ),
                  const SizedBox(height: 12),
                  _AmountBox(
                    title: 'PAYABLE AFTER DUE DATE',
                    subtitle: surcharge > 0
                        ? 'Includes Rs. ${formatMoney(surcharge)} surcharge'
                        : 'After ${bill.dueDate}',
                    amount: 'Rs. ${bill.payableAfterDue}',
                    color: _red,
                    bg: _redBg,
                    line: _redLine,
                    icon: Icons.warning_amber_rounded,
                  ),
                  const SizedBox(height: 18),
                  _ReadingBox(bill: bill),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _Tile(
                          icon: Icons.sell_outlined,
                          value: bill.tariff,
                          label: 'Tariff',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _Tile(
                          icon: Icons.speed_rounded,
                          value: bill.meterNo,
                          label: 'Meter No',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Divider(height: 1),
                  const SizedBox(height: 6),
                  _Details(bill: bill),
                  const SizedBox(height: 14),
                  _ChargesBox(bill: bill),
                  const SizedBox(height: 14),
                  _HistoryBox(bill: bill),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- header

class _Header extends StatelessWidget {
  const _Header({required this.bill});

  final BillData bill;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 18, 22),
      decoration: const BoxDecoration(gradient: AppTheme.header),
      child: Row(
        children: [
          const AppLogo(size: 38),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bill.name.isEmpty ? 'Gas bill' : bill.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.22),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'SNGPL',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'No: ${bill.account}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.88),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.22),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              shortMonth(bill.month, space: true).toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- status

class _PreviousMonthRow extends StatelessWidget {
  const _PreviousMonthRow({required this.row});

  final HistoryRow row;

  @override
  Widget build(BuildContext context) {
    final st = styleFor(row.status);
    final String text;
    switch (row.status) {
      case PayStatus.paid:
        text = '${row.month} was paid  •  Rs. ${formatMoney(row.paidValue)}';
      case PayStatus.partial:
        text =
            '${row.month} partly paid  •  Rs. ${formatMoney(row.paidValue)} of ${formatMoney(row.dueValue)}';
      case PayStatus.unpaid:
        text = '${row.month} is not paid';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: st.bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(st.icon, color: st.fg, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppTheme.ink,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- amounts

class _AmountBox extends StatelessWidget {
  const _AmountBox({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.color,
    required this.bg,
    required this.line,
    required this.icon,
    this.extra,
    this.extraColor,
  });

  final String? extra;
  final Color? extraColor;
  final String title;
  final String subtitle;
  final String amount;
  final Color color;
  final Color bg;
  final Color line;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: line),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14),
                ),
                if (extra != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    extra!,
                    style: TextStyle(
                      color: extraColor ?? color,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            amount,
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- meter

class _ReadingBox extends StatelessWidget {
  const _ReadingBox({required this.bill});

  final BillData bill;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _blueBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _blueLine),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ReadingValue(
              label: 'PREVIOUS',
              value: bill.previousReading,
              date: bill.previousReadingDate,
              alignEnd: false,
            ),
          ),
          const SizedBox(width: 6),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.arrow_forward_rounded, color: AppTheme.blue),
              if (bill.gasHm3.isNotEmpty) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.blue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${bill.gasHm3} HM3',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _ReadingValue(
              label: 'PRESENT',
              value: bill.currentReading,
              date: bill.currentReadingDate,
              alignEnd: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadingValue extends StatelessWidget {
  const _ReadingValue({
    required this.label,
    required this.value,
    required this.date,
    required this.alignEnd,
  });

  final String label;
  final String value;
  final String date;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: cs.onSurfaceVariant,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: alignEnd ? Alignment.centerRight : Alignment.centerLeft,
          child: Text(
            value.isEmpty ? '-' : value,
            style: const TextStyle(
              color: AppTheme.ink,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        if (date.isNotEmpty)
          Text(date, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11)),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.icon, required this.value, required this.label});

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.tint,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: cs.primary, size: 26),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value.isEmpty ? '-' : value,
              style: const TextStyle(
                color: AppTheme.ink,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- details

class _Details extends StatelessWidget {
  const _Details({required this.bill});

  final BillData bill;

  @override
  Widget build(BuildContext context) {
    final issueReading = [bill.issueDate, bill.currentReadingDate]
        .where((e) => e.isNotEmpty)
        .join(' / ');
    final rows = <MapEntry<String, String>>[
      MapEntry('Consumer ID', bill.account),
      MapEntry('Name', bill.name),
      MapEntry('Address', bill.address),
      MapEntry('Issue / Reading Date', issueReading),
      MapEntry('Energy', bill.mmbtu.isEmpty ? '' : '${bill.mmbtu} MMBTU'),
    ].where((e) => e.value.isNotEmpty).toList();

    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        for (final e in rows)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 9),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 112,
                  child: Text(
                    e.key,
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14),
                  ),
                ),
                Expanded(
                  child: Text(
                    e.value,
                    style: const TextStyle(
                      color: AppTheme.ink,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------- grey boxes

class _GreyBox extends StatelessWidget {
  const _GreyBox({
    required this.title,
    required this.icon,
    required this.child,
    this.trailing,
  });

  final String title;
  final IconData icon;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _greyBox,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.blue, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.ink,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _ChargesBox extends StatelessWidget {
  const _ChargesBox({required this.bill});

  final BillData bill;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final entries =
        bill.charges.entries.where((e) => e.value.isNotEmpty).toList();
    return _GreyBox(
      title: 'CHARGES BREAKUP',
      icon: Icons.receipt_long_rounded,
      child: Column(
        children: [
          for (final e in entries) ...[
            if (e.key == 'Total Amount Due') const Divider(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      e.key,
                      style: TextStyle(
                        color: e.key == 'Total Amount Due'
                            ? AppTheme.ink
                            : cs.onSurfaceVariant,
                        fontWeight: e.key == 'Total Amount Due'
                            ? FontWeight.w800
                            : FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Text(
                    e.value,
                    style: TextStyle(
                      color: AppTheme.ink,
                      fontWeight: e.key == 'Total Amount Due'
                          ? FontWeight.w900
                          : FontWeight.w600,
                      fontSize: e.key == 'Total Amount Due' ? 16 : 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- history

class _HistoryBox extends StatelessWidget {
  const _HistoryBox({required this.bill});

  final BillData bill;

  @override
  Widget build(BuildContext context) {
    final rows = bill.history;
    if (rows.isEmpty) return const SizedBox.shrink();
    final cs = Theme.of(context).colorScheme;
    final paidCount = rows.where((r) => r.status == PayStatus.paid).length;

    return _GreyBox(
      title: 'BILL HISTORY',
      icon: Icons.history_rounded,
      trailing: Text(
        '$paidCount/${rows.length} paid',
        style: const TextStyle(
          color: _green,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
      child: Column(
        children: [
          const _HistHeader(),
          const Divider(height: 16),
          _HistRow(
            month: shortMonth(bill.month),
            units: bill.gasHm3.isEmpty ? '-' : bill.gasHm3,
            bill: formatMoney(parseAmount(bill.currentBillAmount)),
            paid: 'Pending',
            status: PayStatus.unpaid,
            isNew: true,
            pending: true,
          ),
          for (final r in rows)
            _HistRow(
              month: shortMonth(r.month),
              units: r.hm3,
              bill: formatMoney(r.billValue),
              paid: r.paidValue > 0 ? formatMoney(r.paidValue) : 'Unpaid',
              status: r.status,
            ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Green = paid  •  Red = not paid. The newest bill stays Pending until SNGPL lists its payment on the next bill.',
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistHeader extends StatelessWidget {
  const _HistHeader();

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
      fontSize: 12,
      fontWeight: FontWeight.w800,
      letterSpacing: 0.5,
    );
    return Row(
      children: [
        Expanded(flex: 5, child: Text('MONTH', style: style)),
        Expanded(
          flex: 2,
          child: Text('UNITS', textAlign: TextAlign.center, style: style),
        ),
        Expanded(
          flex: 3,
          child: Text('BILL', textAlign: TextAlign.right, style: style),
        ),
        Expanded(
          flex: 3,
          child: Text('PAID', textAlign: TextAlign.right, style: style),
        ),
      ],
    );
  }
}

class _HistRow extends StatelessWidget {
  const _HistRow({
    required this.month,
    required this.units,
    required this.bill,
    required this.paid,
    required this.status,
    this.isNew = false,
    this.pending = false,
  });

  final bool pending;

  final String month;
  final String units;
  final String bill;
  final String paid;
  final PayStatus status;
  final bool isNew;

  @override
  Widget build(BuildContext context) {
    final Color paidColor;
    switch (status) {
      case PayStatus.paid:
        paidColor = _green;
      case PayStatus.partial:
        paidColor = styleFor(PayStatus.partial).fg;
      case PayStatus.unpaid:
        paidColor = _red;
    }
    final shownColor = pending
        ? Theme.of(context).colorScheme.onSurfaceVariant
        : paidColor;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  month,
                  style: const TextStyle(
                    color: AppTheme.ink,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                if (isNew) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.blue,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'NEW',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              units,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.ink, fontSize: 14),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              bill,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppTheme.ink,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              paid,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: shownColor,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

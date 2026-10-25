enum PayStatus { paid, partial, unpaid }

class HistoryRow {
  const HistoryRow({
    required this.month,
    required this.hm3,
    required this.bill,
    required this.due,
    required this.paid,
  });

  final String month;
  final String hm3;
  final String bill;
  final String due;
  final String paid;

  double get billValue => parseAmount(bill);
  double get hm3Value => parseAmount(hm3);
  double get dueValue => parseAmount(due);
  double get paidValue => parseAmount(paid);

  /// SNGPL lists a payment amount for months that were paid.
  PayStatus get status {
    final p = paidValue;
    final d = dueValue;
    if (p <= 0) return d <= 0 ? PayStatus.paid : PayStatus.unpaid;
    if (p + 0.5 < d) return PayStatus.partial;
    return PayStatus.paid;
  }
}

/// "1,013.07" -> 1013.07, "-92.03/0" -> -92.03
double parseAmount(String s) {
  final head = s.split('/').first;
  return double.tryParse(head.replaceAll(RegExp(r'[^0-9.\-]'), '')) ?? 0;
}

class BillData {
  const BillData({
    required this.account,
    required this.name,
    required this.address,
    required this.month,
    required this.issueDate,
    required this.dueDate,
    required this.payableInDue,
    required this.payableAfterDue,
    required this.meterNo,
    required this.tariff,
    required this.currentReading,
    required this.previousReading,
    required this.currentReadingDate,
    required this.previousReadingDate,
    required this.gasHm3,
    required this.mmbtu,
    required this.charges,
    required this.history,
  });

  final String account;
  final String name;
  final String address;
  final String month;
  final String issueDate;
  final String dueDate;
  final String payableInDue;
  final String payableAfterDue;
  final String meterNo;
  final String tariff;
  final String currentReading;
  final String previousReading;
  final String currentReadingDate;
  final String previousReadingDate;
  final String gasHm3;
  final String mmbtu;

  /// Ordered: label -> value, exactly as printed on the bill.
  final Map<String, String> charges;

  /// Newest first (as SNGPL prints it).
  final List<HistoryRow> history;

  /// Last month's row (history is newest first). The current bill is never in
  /// this list, so it has no payment yet.
  HistoryRow? get previousBill => history.isEmpty ? null : history.first;

  String get currentBillAmount => charges['Current Bill'] ?? '';

  /// Extra charged if paid after the due date.
  double get surcharge => parseAmount(payableAfterDue) - parseAmount(payableInDue);

  DateTime? get dueDateTime {
    final p = dueDate.split('-');
    if (p.length != 3) return null;
    final d = int.tryParse(p[0]);
    final m = int.tryParse(p[1]);
    final y = int.tryParse(p[2]);
    if (d == null || m == null || y == null) return null;
    return DateTime(y, m, d);
  }

  int? get daysToDue {
    final d = dueDateTime;
    if (d == null) return null;
    final now = DateTime.now();
    return d.difference(DateTime(now.year, now.month, now.day)).inDays;
  }

  bool get isOverdue => (daysToDue ?? 0) < 0;

  String? get dueStatus {
    final diff = daysToDue;
    if (diff == null) return null;
    final n = diff.abs();
    final unit = n == 1 ? 'day' : 'days';
    if (diff < 0) return 'Overdue by $n $unit';
    if (diff == 0) return 'Due today';
    return '$diff $unit left';
  }

  static const _months = {
    'Jan': '01', 'Feb': '02', 'Mar': '03', 'Apr': '04',
    'May': '05', 'Jun': '06', 'Jul': '07', 'Aug': '08',
    'Sep': '09', 'Oct': '10', 'Nov': '11', 'Dec': '12',
  };

  /// "Sep 2026" -> "202609"
  String? get billMonCode {
    final p = month.split(' ');
    if (p.length != 2) return null;
    final m = _months[p[0]];
    if (m == null) return null;
    return '${p[1]}$m';
  }

  String? get meterImageUrl {
    final code = billMonCode;
    if (code == null || account.isEmpty) return null;
    return 'https://www.sngpl.com.pk/imageservlet?consumer=$account&billmon=$code';
  }
}

/// 1030.4 -> "1,030"
String formatMoney(num v) {
  final n = v.round();
  final digits = n.abs().toString();
  final buf = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buf.write(',');
    buf.write(digits[i]);
  }
  return '${n < 0 ? '-' : ''}$buf';
}

/// "Aug 2026" -> "Aug26" (or "Aug 26" with [space])
String shortMonth(String month, {bool space = false}) {
  final p = month.trim().split(' ');
  if (p.length != 2 || p[1].length < 2) return month;
  final yy = p[1].substring(p[1].length - 2);
  return '${p[0]}${space ? ' ' : ''}$yy';
}

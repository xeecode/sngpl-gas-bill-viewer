import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;

import '../models/bill_data.dart';
import 'sngpl_exception.dart';

/// Turns the HTML returned by POST /viewbill into [BillData].
/// If SNGPL changes their bill layout, this is the only file to update.
class BillParser {
  BillParser._();

  static final _dateRe = RegExp(r'^\d{2}-\d{2}-\d{4}$');
  static final _meterRe = RegExp(r'^[A-Z]{1,3}\d{5,}$');

  static const _chargeLabels = [
    'Gas Charges',
    'Prov.Bill Adjustment',
    'Meter Rent',
    'Fixed Charges',
    'GST',
    'Rebate / Adjustment',
    'Security Deposit',
    'Current Bill',
    'Arrears / Aging',
    'Late Payment Surcharge (Rs.)',
    'Total Amount Due',
  ];

  static String _clean(String s) =>
      s.replaceAll('\u00a0', ' ').replaceAll(RegExp(r'\s+'), ' ').trim();

  static List<String> _cells(Element tr) => tr.children
      .where((e) => e.localName == 'td')
      .map((e) => _clean(e.text))
      .toList();

  static List<String>? _find(List<List<String>> rows, String label) {
    for (final r in rows) {
      if (r.length >= 2 && r.first == label) return r;
    }
    return null;
  }

  static List<String>? _containing(List<List<String>> rows, String text) {
    for (final r in rows) {
      if (r.contains(text)) return r;
    }
    return null;
  }

  static String _at(List<String>? row, int i) =>
      (row != null && i < row.length) ? row[i] : '';

  static BillData parse(String body) {
    final doc = html_parser.parse(body);
    final trs = doc.querySelectorAll('tr');
    final rows = trs.map(_cells).where((r) => r.isNotEmpty).toList();

    if (_find(rows, 'Total Amount Due') == null) {
      throw const SngplException(
        'Bill not found. The captcha may be wrong, or the consumer number is invalid. Try a new captcha.',
      );
    }

    // Row with three cells where the last one is a date: [within due, after due, due date]
    var due = const ['', '', ''];
    for (final r in rows) {
      if (r.length == 3 && _dateRe.hasMatch(r[2])) {
        due = r;
        break;
      }
    }

    final readingRow = _find(rows, 'Reading:');
    final datesRow = _find(rows, 'Dates:');
    final gasRow = _containing(rows, 'Gas Consumed HM3');
    final mmbtuRow = _containing(rows, '*MMBTU');

    var meterNo = '';
    outer:
    for (final r in rows) {
      for (final cell in r) {
        if (_meterRe.hasMatch(cell)) {
          meterNo = cell;
          break outer;
        }
      }
    }

    final charges = <String, String>{};
    for (final label in _chargeLabels) {
      final r = _find(rows, label);
      charges[label] = r == null ? '' : r.last;
    }

    final history = <HistoryRow>[];
    for (final tr in trs) {
      final tds = tr.children.where((e) => e.localName == 'td').toList();
      if (tds.length == 5 && tds.every((t) => t.classes.contains('history'))) {
        final c = tds.map((t) => _clean(t.text)).toList();
        history.add(HistoryRow(
          month: c[0],
          hm3: c[1],
          bill: c[2],
          due: c[3],
          paid: c[4],
        ));
      }
    }

    // Address: first line is on the 'Address:' row, the rest follow in rows
    // whose first two cells are empty.
    final addrIdx = rows.indexWhere((r) => r.isNotEmpty && r.first == 'Address:');
    final addrLines = <String>[];
    if (addrIdx >= 0) {
      addrLines.add(rows[addrIdx].last);
      for (var i = addrIdx + 1; i < rows.length; i++) {
        final r = rows[i];
        if (r.length == 3 && r[0].isEmpty && r[1].isEmpty && r[2].isNotEmpty) {
          addrLines.add(r[2]);
        } else {
          break;
        }
      }
    }

    String match(String pattern) =>
        RegExp(pattern).firstMatch(body)?.group(1) ?? '';

    return BillData(
      account: _at(_find(rows, 'Account ID'), 1),
      name: _at(_find(rows, 'Name'), 1),
      address: addrLines.where((l) => l.isNotEmpty).join(', '),
      month: _at(_find(rows, 'Billing Month'), 1),
      issueDate: match(r'Issue Date:\s*(\d{2}-\d{2}-\d{4})'),
      dueDate: due[2],
      payableInDue: due[0],
      payableAfterDue: due[1],
      meterNo: meterNo,
      tariff: match(r'Tariff:\s*([A-Za-z0-9\-]+)'),
      currentReading: _at(readingRow, 1),
      previousReading: _at(readingRow, 2),
      currentReadingDate: _at(datesRow, 1),
      previousReadingDate: _at(datesRow, 2),
      gasHm3: gasRow == null ? '' : gasRow.last,
      mmbtu: mmbtuRow == null ? '' : mmbtuRow.last,
      charges: charges,
      history: history,
    );
  }
}

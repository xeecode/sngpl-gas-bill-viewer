import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/bill_data.dart';
import '../models/saved_consumer.dart';

class StorageService {
  static const _key = 'saved_consumers_v1';

  Future<List<SavedConsumer>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => SavedConsumer.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> save(List<SavedConsumer> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(items.map((e) => e.toJson()).toList()),
    );
  }

  /// Remembers the latest amount/due date so the home list can show it.
  Future<void> updateLastBill(String number, BillData bill) async {
    final items = await load();
    final i = items.indexWhere((c) => c.number == number);
    if (i < 0) return;
    items[i] = items[i].copyWith(
      lastMonth: bill.month,
      lastAmount: bill.payableInDue,
      lastDueDate: bill.dueDate,
      lastChecked: DateTime.now(),
    );
    await save(items);
  }
}

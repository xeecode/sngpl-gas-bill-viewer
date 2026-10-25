class SavedConsumer {
  const SavedConsumer({
    required this.number,
    this.label,
    this.lastMonth,
    this.lastAmount,
    this.lastDueDate,
    this.lastChecked,
  });

  final String number;
  final String? label;
  final String? lastMonth;
  final String? lastAmount;
  final String? lastDueDate;
  final DateTime? lastChecked;

  String get title => (label != null && label!.isNotEmpty) ? label! : number;

  SavedConsumer copyWith({
    String? lastMonth,
    String? lastAmount,
    String? lastDueDate,
    DateTime? lastChecked,
  }) {
    return SavedConsumer(
      number: number,
      label: label,
      lastMonth: lastMonth ?? this.lastMonth,
      lastAmount: lastAmount ?? this.lastAmount,
      lastDueDate: lastDueDate ?? this.lastDueDate,
      lastChecked: lastChecked ?? this.lastChecked,
    );
  }

  Map<String, dynamic> toJson() => {
        'number': number,
        'label': label,
        'lastMonth': lastMonth,
        'lastAmount': lastAmount,
        'lastDueDate': lastDueDate,
        'lastChecked': lastChecked?.toIso8601String(),
      };

  factory SavedConsumer.fromJson(Map<String, dynamic> j) {
    return SavedConsumer(
      number: (j['number'] ?? '') as String,
      label: j['label'] as String?,
      lastMonth: j['lastMonth'] as String?,
      lastAmount: j['lastAmount'] as String?,
      lastDueDate: j['lastDueDate'] as String?,
      lastChecked: j['lastChecked'] == null
          ? null
          : DateTime.tryParse(j['lastChecked'] as String),
    );
  }
}

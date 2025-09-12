enum StatisticType {
  count('COUNT'),
  average('AVERAGE');

  const StatisticType(this.value);
  final String value;

  static StatisticType fromString(String value) =>
      StatisticType.values.firstWhere(
        (type) => type.value == value.toUpperCase(),
        orElse: () => throw ArgumentError('Invalid  type: $value'),
      );
}

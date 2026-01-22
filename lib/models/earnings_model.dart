class EarningsModel {
  final double todayEarnings;
  final double weekEarnings;
  final double monthEarnings;
  final int totalDeliveries;
  final double avgRating;

  EarningsModel({
    required this.todayEarnings,
    required this.weekEarnings,
    required this.monthEarnings,
    required this.totalDeliveries,
    required this.avgRating,
  });

  factory EarningsModel.fromJson(Map<String, dynamic> json) {
    return EarningsModel(
      todayEarnings: double.tryParse(json['today_earnings'].toString()) ?? 0.0,
      weekEarnings: double.tryParse(json['week_earnings'].toString()) ?? 0.0,
      monthEarnings: double.tryParse(json['month_earnings'].toString()) ?? 0.0,
      totalDeliveries: json['total_deliveries'] ?? 0,
      avgRating: double.tryParse(json['avg_rating'].toString()) ?? 0.0,
    );
  }
}

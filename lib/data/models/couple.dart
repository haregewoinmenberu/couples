class Couple {
  final String id;
  final String userAId;
  final String userBId;
  final DateTime anniversaryDate;
  final DateTime connectedAt;

  const Couple({
    required this.id,
    required this.userAId,
    required this.userBId,
    required this.anniversaryDate,
    required this.connectedAt,
  });

  int get daysTogether =>
      DateTime.now().difference(anniversaryDate).inDays.clamp(0, 999999);

  String? partnerIdFor(String userId) {
    if (userId == userAId) return userBId;
    if (userId == userBId) return userAId;
    return null;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userAId': userAId,
        'userBId': userBId,
        'anniversaryDate': anniversaryDate.toIso8601String(),
        'connectedAt': connectedAt.toIso8601String(),
      };

  factory Couple.fromJson(Map<String, dynamic> json) => Couple(
        id: json['id'] as String,
        userAId: json['userAId'] as String,
        userBId: json['userBId'] as String,
        anniversaryDate: DateTime.parse(json['anniversaryDate'] as String),
        connectedAt: DateTime.parse(json['connectedAt'] as String),
      );
}

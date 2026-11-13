enum InvitationMethod { qr, phone }

enum InvitationStatus { pending, accepted, expired, cancelled }

class Invitation {
  final String id;
  final String code;
  final String inviterId;
  final InvitationMethod method;
  final String? inviteePhone;
  final DateTime createdAt;
  final DateTime expiresAt;
  InvitationStatus status;
  String? redeemedByUserId;

  Invitation({
    required this.id,
    required this.code,
    required this.inviterId,
    required this.method,
    this.inviteePhone,
    required this.createdAt,
    required this.expiresAt,
    this.status = InvitationStatus.pending,
    this.redeemedByUserId,
  });

  bool get isExpired =>
      status == InvitationStatus.pending && DateTime.now().isAfter(expiresAt);

  bool get isUsable => status == InvitationStatus.pending && !isExpired;

  Duration get remaining => expiresAt.difference(DateTime.now());

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'inviterId': inviterId,
        'method': method.name,
        'inviteePhone': inviteePhone,
        'createdAt': createdAt.toIso8601String(),
        'expiresAt': expiresAt.toIso8601String(),
        'status': status.name,
        'redeemedByUserId': redeemedByUserId,
      };

  factory Invitation.fromJson(Map<String, dynamic> json) => Invitation(
        id: json['id'] as String,
        code: json['code'] as String,
        inviterId: json['inviterId'] as String,
        method: InvitationMethod.values.byName(json['method'] as String),
        inviteePhone: json['inviteePhone'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        expiresAt: DateTime.parse(json['expiresAt'] as String),
        status: InvitationStatus.values.byName(json['status'] as String),
        redeemedByUserId: json['redeemedByUserId'] as String?,
      );
}

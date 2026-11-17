/// Data passed through the connection flow after an invitation is redeemed.
///
/// No phone number or OTP is required: both partners use the same device, so
/// the redeemed inviter id is all we need to create the shared couple.
class ConnectionPayload {
  final String? inviterId;

  const ConnectionPayload({this.inviterId});
}

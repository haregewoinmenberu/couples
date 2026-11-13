import '../models/user.dart';
import '../models/couple.dart';

const String alexId = 'user_alex';
const String sophiaId = 'user_sophia';
const String demoCoupleId = 'couple_alex_sophia';

final AppUser mockAlex = AppUser(
  id: alexId,
  fullName: 'Alex',
  username: 'alex',
  email: 'alex@example.com',
  phoneNumber: '+1 555 0101',
  countryCode: 'US',
  avatarSeed: 'alex',
  phoneVerified: true,
  partnerId: sophiaId,
  coupleId: demoCoupleId,
);

final AppUser mockSophia = AppUser(
  id: sophiaId,
  fullName: 'Sophia',
  username: 'sophia_love',
  email: 'sophia@example.com',
  phoneNumber: '+1 555 0102',
  countryCode: 'US',
  avatarSeed: 'sophia',
  phoneVerified: true,
  partnerId: alexId,
  coupleId: demoCoupleId,
);

final Couple mockCouple = Couple(
  id: demoCoupleId,
  userAId: alexId,
  userBId: sophiaId,
  anniversaryDate: DateTime.now().subtract(const Duration(days: 128)),
  connectedAt: DateTime.now().subtract(const Duration(days: 128)),
);

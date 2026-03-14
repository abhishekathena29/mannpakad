import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mannpakad/core/models/app_models.dart';

class UserProfileRepository {
  UserProfileRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _firestore.collection('users').doc(uid);

  Future<UserSessionData?> fetchSession(String uid) async {
    final snapshot = await _userDoc(uid).get();
    if (!snapshot.exists) {
      return null;
    }

    final data = snapshot.data();
    if (data == null || data['profile'] == null) {
      return null;
    }

    return UserSessionData(
      profile: _profileFromMap(uid, Map<String, dynamic>.from(data['profile'])),
      avatar: data['avatar'] == null
          ? null
          : _avatarFromMap(uid, Map<String, dynamic>.from(data['avatar'])),
    );
  }

  Future<UserProfile> saveProfile(String uid, UserProfile profile) async {
    await _userDoc(uid).set({
      'profile': _profileToMap(profile),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    return profile;
  }

  Future<Avatar> saveAvatar(String uid, Avatar avatar) async {
    await _userDoc(uid).set({
      'avatar': _avatarToMap(avatar),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    return avatar;
  }

  Future<void> deleteSession(String uid) async {
    await _userDoc(uid).delete();
  }

  Map<String, dynamic> _profileToMap(UserProfile profile) {
    return {
      'id': profile.id,
      'name': profile.name,
      'ageMode': profile.ageMode.name,
      'ocdThemes': profile.ocdThemes.map((item) => item.name).toList(),
      'adhdTraits': profile.adhdTraits.map((item) => item.name).toList(),
      'sensitivities': profile.sensitivities,
      'coachingTone': profile.coachingTone.name,
      'parentPin': profile.parentPin,
      'createdAt': Timestamp.fromDate(profile.createdAt),
    };
  }

  Map<String, dynamic> _avatarToMap(Avatar avatar) {
    return {
      'id': avatar.id,
      'name': avatar.name,
      'style': avatar.style.name,
      'personality': avatar.personality.name,
      'accessories': avatar.accessories,
      'background': avatar.background,
      'level': avatar.level,
      'experience': avatar.experience,
    };
  }

  UserProfile _profileFromMap(String uid, Map<String, dynamic> map) {
    return UserProfile(
      id: (map['id'] as String?) ?? uid,
      name: (map['name'] as String?) ?? 'Friend',
      ageMode: AgeMode.values.byName(
        (map['ageMode'] as String?) ?? AgeMode.older.name,
      ),
      ocdThemes: _enumList(map['ocdThemes'], OCDTheme.values),
      adhdTraits: _enumList(map['adhdTraits'], ADHDTrait.values),
      sensitivities: (map['sensitivities'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
      coachingTone: CoachingTone.values.byName(
        (map['coachingTone'] as String?) ?? CoachingTone.gentle.name,
      ),
      parentPin: map['parentPin'] as String?,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Avatar _avatarFromMap(String uid, Map<String, dynamic> map) {
    return Avatar(
      id: (map['id'] as String?) ?? uid,
      name: (map['name'] as String?) ?? 'Buddy',
      style: AvatarStyle.values.byName(
        (map['style'] as String?) ?? AvatarStyle.fox.name,
      ),
      personality: AvatarPersonality.values.byName(
        (map['personality'] as String?) ?? AvatarPersonality.friend.name,
      ),
      accessories: (map['accessories'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
      background: (map['background'] as String?) ?? 'meadow',
      level: (map['level'] as num?)?.toInt() ?? 1,
      experience: (map['experience'] as num?)?.toInt() ?? 0,
    );
  }

  List<T> _enumList<T extends Enum>(dynamic source, List<T> values) {
    final names = (source as List<dynamic>? ?? const [])
        .map((item) => item.toString())
        .toSet();
    return values.where((value) => names.contains(value.name)).toList();
  }
}

class UserSessionData {
  const UserSessionData({required this.profile, required this.avatar});

  final UserProfile profile;
  final Avatar? avatar;
}

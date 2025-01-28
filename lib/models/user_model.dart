class UserModel {
  final String userId;
  final String userName;
  final String parentName;
  final String userAddress;
  final int userAge;
  final String userBg;
  final String userGender;
  final String userMobile;
  final String userPassword;
  final String userStd;
  final String userType;
  String? profilePicture;

  UserModel({
    required this.userId,
    required this.userName,
    required this.parentName,
    required this.userAddress,
    required this.userAge,
    required this.userBg,
    required this.userGender,
    required this.userMobile,
    required this.userPassword,
    required this.userStd,
    required this.userType,
    this.profilePicture,
  });

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'user_name': userName,
      'parent_name': parentName,
      'user_address': userAddress,
      'user_age': userAge,
      'user_bg': userBg,
      'user_gender': userGender,
      'user_mobile': userMobile,
      'user_password': userPassword,
      'user_std': userStd,
      'user_type': userType,
      'profile_picture': profilePicture,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      userId: data['user_id'] ?? '',
      userName: data['user_name'] ?? '',
      parentName: data['parent_name'] ?? '',
      userAddress: data['user_address'] ?? '',
      userAge: data['user_age'] ?? 0,
      userBg: data['user_bg'] ?? '',
      userGender: data['user_gender'] ?? '',
      userMobile: data['user_mobile'] ?? '',
      userPassword: data['user_password'] ?? '',
      userStd: data['user_std'] ?? '',
      userType: data['user_type'] ?? '',
      profilePicture: data['profile_picture'],
    );
  }

  UserModel copyWith({
    String? userId,
    String? userName,
    String? parentName,
    String? userAddress,
    int? userAge,
    String? userBg,
    String? userGender,
    String? userMobile,
    String? userPassword,
    String? userStd,
    String? userType,
    String? profilePicture, required String photoUrl,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      parentName: parentName ?? this.parentName,
      userAddress: userAddress ?? this.userAddress,
      userAge: userAge ?? this.userAge,
      userBg: userBg ?? this.userBg,
      userGender: userGender ?? this.userGender,
      userMobile: userMobile ?? this.userMobile,
      userPassword: userPassword ?? this.userPassword,
      userStd: userStd ?? this.userStd,
      userType: userType ?? this.userType,
      profilePicture: profilePicture ?? this.profilePicture,
    );
  }

  // Getter for profile picture URL to maintain compatibility
  String? get photoUrl => profilePicture;

  get lastProfileUpdate => null;

  // Setter for profile picture URL to maintain compatibility
  set photoUrl(String? url) {
    profilePicture = url;
  }
}

class UserData {
  final String email;
  final String name;

  UserData({
    required this.email,
    required this.name,
  });
}

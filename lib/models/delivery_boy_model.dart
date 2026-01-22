class DeliveryBoyModel {
  final String userId;
  final String name;
  final String phone;
  final bool isActive;
  final String verificationStatus;
  final String? vehicleType;
  final String? vehicleNumber;
  final String? licenseNumber;
  final String? profilePhoto;
  final bool isRegistered;
  final String? email;
  final double rating;

  DeliveryBoyModel({
    required this.userId,
    required this.name,
    required this.phone,
    this.isActive = false,
    this.verificationStatus = 'pending',
    this.vehicleType,
    this.vehicleNumber,
    this.licenseNumber,
    this.profilePhoto,
    this.isRegistered = false,
    this.email,
    this.rating = 0.0,
  });

  DeliveryBoyModel copyWith({
    String? userId,
    String? name,
    String? phone,
    bool? isActive,
    String? verificationStatus,
    String? vehicleType,
    String? vehicleNumber,
    String? licenseNumber,
    String? profilePhoto,
    bool? isRegistered,
    String? email,
    double? rating,
  }) {
    return DeliveryBoyModel(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      isActive: isActive ?? this.isActive,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      vehicleType: vehicleType ?? this.vehicleType,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      isRegistered: isRegistered ?? this.isRegistered,
      email: email ?? this.email,
      rating: rating ?? this.rating,
    );
  }

  factory DeliveryBoyModel.fromJson(Map<String, dynamic> json) {
    return DeliveryBoyModel(
      userId: json['id'].toString(),
      name: json['full_name'] ?? 'Delivery Partner',
      phone: json['phone_number'] ?? '',
      isActive: json['is_online'] ?? false,
      verificationStatus: json['verification_status'] ?? 'pending',
      vehicleType: json['vehicle_type'],
      vehicleNumber: json['vehicle_number'],
      licenseNumber: json['license_number'],
      profilePhoto: json['profile_photo'],
      isRegistered: json['is_registered'] ?? false,
      email: json['email'],
      rating: double.tryParse(json['rating'].toString()) ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': userId,
      'full_name': name,
      'phone_number': phone,
      'is_online': isActive,
      'verification_status': verificationStatus,
      'vehicle_type': vehicleType,
      'vehicle_number': vehicleNumber,
      'license_number': licenseNumber,
      'profile_photo': profilePhoto,
      'is_registered': isRegistered,
      'email': email,
      'rating': rating,
    };
  }
}

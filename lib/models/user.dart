class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? classTeacherId;
  final String? className;
  final String? rollNo;
  final double? lat;
  final double? lng;
  final String? driverId;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.classTeacherId,
    this.className,
    this.rollNo,
    this.lat,
    this.lng,
    this.driverId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['userId'] ?? json['_id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      classTeacherId: json['classTeacherId'],
      className: json['class'],
      rollNo: json['rollNo'],
      lat: json['lat'] != null ? double.parse(json['lat'].toString()) : null,
      lng: json['lng'] != null ? double.parse(json['lng'].toString()) : null,
      driverId: json['busDriverId'] ?? json['driverId'],
    );
  }
}

class BookingBooker {
  const BookingBooker({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
  });

  final int id;
  final String firstName;
  final String lastName;
  final String phoneNumber;

  factory BookingBooker.fromJson(Map<String, dynamic> json) => BookingBooker(
        id: json['id'] as int,
        firstName: json['first_name'] as String,
        lastName: json['last_name'] as String,
        phoneNumber: json['phone_number'] as String,
      );
}

class BookingWithUser {
  const BookingWithUser({
    required this.id,
    required this.userId,
    required this.carId,
    required this.startTime,
    required this.endTime,
    required this.user,
  });

  final int id;
  final int userId;
  final int carId;
  final DateTime startTime;
  final DateTime endTime;
  final BookingBooker user;

  factory BookingWithUser.fromJson(Map<String, dynamic> json) =>
      BookingWithUser(
        id: json['id'] as int,
        userId: json['user_id'] as int,
        carId: json['car_id'] as int,
        startTime: DateTime.parse(json['start_time'] as String),
        endTime: DateTime.parse(json['end_time'] as String),
        user: BookingBooker.fromJson(
          Map<String, dynamic>.from(json['user'] as Map),
        ),
      );
}

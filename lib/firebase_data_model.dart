// models/user_information.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class UserInformation {
  String? id;
  String userName;
  int userAge;
  int scissor;
  int pencil;
  int pincher;
  int button;
  String sessionDate;
  int timer;
  DateTime createdAt;

  UserInformation({
    this.id,
    required this.userName,
    required this.userAge,
    required this.scissor,
    required this.pencil,
    required this.pincher,
    required this.button,
    required this.sessionDate,
    required this.timer,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userName': userName,
      'userAge': userAge,
      'scissor': scissor,
      'pencil': pencil,
      'pincher': pincher,
      'button': button,
      'sessionDate': sessionDate,
      'timer': timer,
      'createdAt': createdAt,
    };
  }

  factory UserInformation.fromMap(String id, Map<String, dynamic> map) {
    return UserInformation(
      id: id,
      userName: map['userName'] ?? '',
      userAge: map['userAge'] ?? 0,
      scissor: map['scissor'] ?? 0,
      pencil: map['pencil'] ?? 0,
      pincher: map['pincher'] ?? 0,
      button: map['button'] ?? 0,
      sessionDate: map['sessionDate'] ?? '',
      timer: map['timer'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}

// models/device_settings.dart
class DeviceSettings {
  String colorScissor;
  String colorPencil;
  String colorPincher;
  String colorButton;
  String musicScissor;
  String musicPencil;
  String musicPincher;
  String musicButton;

  DeviceSettings({
    required this.colorScissor,
    required this.colorPencil,
    required this.colorPincher,
    required this.colorButton,
    required this.musicScissor,
    required this.musicPencil,
    required this.musicPincher,
    required this.musicButton,
  });
}
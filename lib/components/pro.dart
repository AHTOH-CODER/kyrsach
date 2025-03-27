import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:kyrsach/models/profile.dart';

class ProfileController {
  Future<List<Profile>> loadProfiles() async {
    try {
      final String response = await rootBundle.loadString('assets/profile.json');
      final List<dynamic> data = json.decode(response);
      return data.map((profileJson) => Profile.fromJson(profileJson)).toList();
    } catch (e) {
      throw Exception('Ошибка загрузки профилей: $e');
    }
  }

  Profile? authenticate(List<Profile> profiles, String login, String password) {
    try {
      return profiles.firstWhere(
        (p) => p.login == login && p.password == password,
        orElse: () => Profile.empty(),
      );
    } catch (e) {
      throw Exception('Ошибка аутентификации: $e');
    }
  }
}
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Profile {
  String login;
  String password;
  String level;
  String store;
  String department;
  String fullName;
  String gender;
  int age;
  String address;
  int workExperience;
  String qualification;

  Profile({
    required this.login,
    required this.password,
    required this.level,
    required this.store,
    required this.department,
    required this.fullName,
    required this.gender,
    required this.age,
    required this.address,
    required this.workExperience,
    required this.qualification,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      login: json['login'],
      password: json['password'],
      level: json['level'],
      store: json['store'],
      department: json['department'],
      fullName: json['fullName'],
      gender: json['gender'],
      age: json['age'],
      address: json['address'],
      workExperience: json['workExperience'],
      qualification: json['qualification'],
    );
  }

  get storeName => null;
}

class ProfileScreen extends StatefulWidget {
  final Function(Profile?) onProfileChanged;

  ProfileScreen({required this.onProfileChanged});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  Profile? _currentProfile;

  Future<List<Profile>> _loadProfiles() async {
    final String response = await rootBundle.loadString('assets/profile.json');
    final List<dynamic> data = json.decode(response);
    return data.map((profileJson) => Profile.fromJson(profileJson)).toList();
  }

  void _authenticate() async {
    final profiles = await _loadProfiles();
    final login = _loginController.text;
    final password = _passwordController.text;

    final profile = profiles.firstWhere(
      (p) => p.login == login && p.password == password,
      orElse: () => Profile(
        login: '',
        password: '',
        level: '',
        store: '',
        department: '',
        fullName: '',
        gender: '',
        age: 0,
        address: '',
        workExperience: 0,
        qualification: '',
      ),
    );

    if (profile.login.isNotEmpty) {
      setState(() {
        _currentProfile = profile;
      });
      widget.onProfileChanged(profile);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Неверный логин или пароль')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Авторизация'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _currentProfile == null
            ? Column(
                children: [
                  TextField(
                    controller: _loginController,
                    decoration: InputDecoration(labelText: 'Логин'),
                  ),
                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(labelText: 'Пароль'),
                    obscureText: true,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _authenticate,
                    child: Text('Войти'),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Профиль:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Text('ФИО: ${_currentProfile!.fullName}'),
                  Text('Логин: ${_currentProfile!.login}'),
                  Text('Роль: ${_currentProfile!.level}'),
                  Text('Магазин: ${_currentProfile!.store}'),
                  Text('Отдел: ${_currentProfile!.department}'),
                  Text('Пол: ${_currentProfile!.gender}'),
                  Text('Возраст: ${_currentProfile!.age}'),
                  Text('Адрес: ${_currentProfile!.address}'),
                  Text('Опыт работы: ${_currentProfile!.workExperience} лет'),
                  Text('Квалификация: ${_currentProfile!.qualification}'),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _currentProfile = null; // Сброс профиля
                      });
                      widget.onProfileChanged(null); // Уведомление о сбросе профиля
                      Navigator.pop(context); // Закрытие диалога
                    },
                    child: Text('Выйти'),
                  ),
                ],
              ),
      ),
    );
  }
}
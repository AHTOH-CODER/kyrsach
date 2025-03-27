import 'package:flutter/material.dart';
import 'package:kyrsach/models/profile.dart';
import 'package:kyrsach/components/pro.dart';

class ProfileScreen extends StatefulWidget {
  final Function(Profile?) onProfileChanged;

  const ProfileScreen({required this.onProfileChanged, Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  final ProfileController _controller = ProfileController();
  Profile? _currentProfile;

  Future<void> _authenticate() async {
    try {
      final profiles = await _controller.loadProfiles();
      final profile = _controller.authenticate(
        profiles,
        _loginController.text,
        _passwordController.text,
      );

      if (profile!.login.isNotEmpty) {
        setState(() => _currentProfile = profile);
        widget.onProfileChanged(profile);
      } else {
        _showError('Неверный логин или пароль');
      }
    } catch (e) {
      _showError(e.toString());
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _logout() {
    setState(() => _currentProfile = null);
    widget.onProfileChanged(null);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Авторизация')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _currentProfile == null ? _buildLoginForm() : _buildProfileInfo(),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      children: [
        TextField(
          controller: _loginController,
          decoration: const InputDecoration(labelText: 'Логин'),
        ),
        TextField(
          controller: _passwordController,
          decoration: const InputDecoration(labelText: 'Пароль'),
          obscureText: true,
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _authenticate,
          child: const Text('Войти'),
        ),
      ],
    );
  }

  Widget _buildProfileInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Профиль:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
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
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _logout,
          child: const Text('Выйти'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
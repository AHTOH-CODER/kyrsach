import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kyrsach/models.dart';
import 'package:kyrsach/pages/central_warehouse.dart';
import 'dart:convert';
import 'package:kyrsach/pages/profile.dart';
import 'package:kyrsach/pages/application.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Store Network System',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: StoreListScreen(),
    );
  }
}

class StoreListScreen extends StatefulWidget {
  @override
  _StoreListScreenState createState() => _StoreListScreenState();
}

class _StoreListScreenState extends State<StoreListScreen> {
  List<Store> stores = [];
  Profile? _currentProfile; // Хранение текущего профиля

  @override
  void initState() {
    super.initState();
    _loadStores();
  }

  Future<void> _loadStores() async {
    final String response = await rootBundle.loadString('assets/stores.json');
    final List<dynamic> data = json.decode(response);
    setState(() {
      stores = data.map((storeJson) => Store.fromJson(storeJson)).toList();
    });
  }

  void _showProfile() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Профиль'),
          content: ProfileScreen(
            onProfileChanged: (profile) {
              setState(() {
                _currentProfile = profile; // Обновление текущего профиля
              });
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Закрытие диалога
              },
              child: Text('Закрыть'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToApplicationPage() {
    if (_currentProfile == null) {
      _showErrorDialog('Пожалуйста, войдите в систему для доступа к заявкам.');
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ApplicationPage(level: _currentProfile!.level, store: _currentProfile!.store,)),
      );
    }
  }

  void _navigateToCentralWarehouse() {
    if (_currentProfile == null) {
      _showErrorDialog('Пожалуйста, войдите в систему для доступа к центральному складу.');
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CentralWarehouseScreen(level: _currentProfile!.level)),
      );
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Ошибка'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Закрытие диалога
              },
              child: Text('Закрыть'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Список магазинов'),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: _showProfile, // Открытие страницы профиля
          ),
        ],
      ),
      body: _currentProfile == null
          ? Center(child: Text('Пожалуйста, войдите в систему для просмотра магазинов.'))
          : ListView.builder(
              itemCount: stores.length,
              itemBuilder: (context, index) {
                final store = stores[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3.0),
                  child: Container(
                    color: const Color.fromARGB(255, 228, 232, 240),
                    child: ListTile(
                      title: Text(store.name),
                      subtitle: Text(store.address),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductListScreen(store: store),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),       
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _navigateToApplicationPage, // Переход на страницу заявок
            child: Icon(Icons.list_alt), // Иконка для заявок
            tooltip: 'Заявки',
          ),
          SizedBox(width: 16), // Отступ между кнопками
          FloatingActionButton(
            onPressed: _navigateToCentralWarehouse, // Переход на центральный склад
            child: Icon(Icons.storage),
            tooltip: 'Центральный склад',
          ),
        ],
      ),
    );
  }
}

class ProductListScreen extends StatelessWidget {
  final Store store;

  ProductListScreen({required this.store});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(store.name),
      ),
      body: ListView.builder(
        itemCount: store.products.length,
        itemBuilder: (context, index) {
          final product = store.products[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 3.0),
            child: Container(
              color: const Color.fromARGB(255, 228, 232, 240),
              child: ListTile(
                title: Text(product.name),
                subtitle: Text('${product.quantity} ${product.unit}'),
              ),
            ),
          );
        },
      ),
    );
  }
}
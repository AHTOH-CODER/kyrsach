import 'package:flutter/material.dart';
import 'package:kyrsach/pages/central_warehouse.dart';
import 'package:kyrsach/pages/profile.dart';
import 'package:kyrsach/pages/application.dart';
import 'package:kyrsach/pages/sell.dart';
import 'package:kyrsach/pages/store_inventory.dart';
import 'package:kyrsach/components/sto.dart';

class StoreListScreen extends StatefulWidget {
  @override
  _StoreListScreenState createState() => _StoreListScreenState();
}

class _StoreListScreenState extends State<StoreListScreen> {
  final StoreListController _controller = StoreListController();

  @override
  void initState() {
    super.initState();
    _controller.loadStores().then((_) {
      setState(() {});
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
                _controller.updateProfile(profile!);
              });
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Закрыть'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToApplicationPage() {
    if (_controller.currentProfile == null) {
      _showErrorDialog('Пожалуйста, войдите в систему для доступа к заявкам.');
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ApplicationPage(
            level: _controller.currentProfile!.level,
            store: _controller.currentProfile!.store,
          ),
        ),
      );
    }
  }

  void _navigateToCentralWarehouse() {
    if (_controller.currentProfile == null) {
      _showErrorDialog('Пожалуйста, войдите в систему для доступа к центральному складу.');
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CentralWarehouseScreen(
            level: _controller.currentProfile!.level,
          ),
        ),
      );
    }
  }

  void _navigatesellPage() {
    if (_controller.currentProfile == null) {
      _showErrorDialog('Пожалуйста, войдите в систему для доступа к продажам.');
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SellPage(profile: _controller.currentProfile),
        ),
      );
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ошибка'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Закрыть'),
          ),
        ],
      ),
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
            onPressed: _showProfile,
          ),
        ],
      ),
      body: _controller.currentProfile == null
          ? Center(child: Text('Пожалуйста, войдите в систему для просмотра магазинов.'))
          : ListView.builder(
              itemCount: _controller.stores.length,
              itemBuilder: (context, index) {
                final store = _controller.stores[index];
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
            onPressed: _navigateToApplicationPage,
            child: Icon(Icons.list_alt),
            tooltip: 'Заявки',
          ),
          SizedBox(width: 16),
          FloatingActionButton(
            onPressed: _navigateToCentralWarehouse,
            child: Icon(Icons.storage),
            tooltip: 'Центральный склад',
          ),
          SizedBox(width: 16),
          FloatingActionButton(
            onPressed: _navigatesellPage,
            child: Icon(Icons.money),
            tooltip: 'Продажа',
          ),
        ],
      ),
    );
  }
}
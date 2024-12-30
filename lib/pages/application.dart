import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kyrsach/models.dart';
import 'package:kyrsach/pages/profile.dart';


class ApplicationPage extends StatefulWidget {
  final String level;
  final String store;

  ApplicationPage({required this.level, required this.store});

  @override
  _ApplicationPageState createState() => _ApplicationPageState();
}

class _ApplicationPageState extends State<ApplicationPage> {
  List<Application> applications = [];
  Profile? _currentProfile;

  @override
  void initState() {
    super.initState();
    _loadApplications();
  }

  Future<void> _loadApplications() async {
    final String response = await rootBundle.loadString('assets/application.json');
    final List<dynamic> data = json.decode(response);
    setState(() {
      applications = data.map((appJson) => Application.fromJson(appJson)).toList();
    });
  }

  void _createApplication() {
    // Function to create a new application
    showDialog(
      context: context,
      builder: (context) {
        String storeName = widget.store;
        String date = DateTime.now().toIso8601String().split("T").first; // Current date
        List<Product> orderedProducts = [];

        return AlertDialog(
          title: Text('Создать заявку'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Input fields for products
              // You can implement a form with TextFields for each product
              // For simplicity, let's assume we have a single product
              TextField(
                decoration: InputDecoration(labelText: 'Название товара'),
                onSubmitted: (value) {
                  // Add product to the orderedProducts list
                  orderedProducts.add(Product(name: value, unit: 'шт', quantity: 1)); // Default unit and quantity
                },
              ),
              // Add more fields as necessary
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Create application logic here
                if (orderedProducts.isNotEmpty) {
                  Application newApplication = Application(
                    storeName: storeName,
                    orderDate: date,
                    items: orderedProducts,
                  );
                  setState(() {
                    applications.add(newApplication);
                  });
                  Navigator.pop(context);
                }
              },
              child: Text('Создать'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Отмена'),
            ),
          ],
        );
      },
    );
  }

  void _acceptApplication(Application application) {
    // Logic to accept application
    // Here you will check if the warehouse has enough stock
    // If so, move the items from central warehouse to the store
    // If not, show an error message
  }

  void _rejectApplication(Application application) {
    // Logic to reject application
    setState(() {
      applications.remove(application);
    });
    // Here you should also update the JSON file to remove the rejected application
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Заявки'),
        actions: widget.level == 'seller'
            ? [
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _createApplication,
                  tooltip: 'Создать заявку',
                ),
              ]
            : null,
      ),
      body: ListView.builder(
        itemCount: applications.length,
        itemBuilder: (context, index) {
          final application = applications[index];
          return Card(
            child: ListTile(
              title: Text(application.storeName),
              subtitle: Text('Дата: ${application.orderDate}'),
              onTap: () {
                // Show details of the application
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('Детали заявки'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: application.items.map((item) {
                          return Text('${item.name} - ${item.quantity} ${item.unit}');
                        }).toList(),
                      ),
                      actions: [
                        if (widget.level == 'admin') ...[
                          TextButton(
                            onPressed: () => _acceptApplication(application),
                            child: Text('Принять'),
                          ),
                          TextButton(
                            onPressed: () => _rejectApplication(application),
                            child: Text('Отклонить'),
                          ),
                        ],
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('Закрыть'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class Application {
  String storeName;
  String orderDate;
  List<Product> items;

  Application({required this.storeName, required this.orderDate, required this.items});

  factory Application.fromJson(Map<String, dynamic> json) {
    var itemList = json['items'] as List;
    List<Product> itemListParsed = itemList.map((i) => Product.fromJson(i)).toList();

    return Application(
      storeName: json['storeName'],
      orderDate: json['orderDate'],
      items: itemListParsed,
    );
  }
}

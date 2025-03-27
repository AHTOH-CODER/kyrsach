import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:kyrsach/models/profile.dart';
import 'package:kyrsach/models/store.dart';

class StoreListController {
  List<Store> stores = [];
  Profile? currentProfile;

  Future<void> loadStores() async {
    final String response = await rootBundle.loadString('assets/stores.json');
    final List<dynamic> data = json.decode(response);
    stores = data.map((storeJson) => Store.fromJson(storeJson)).toList();
  }

  void updateProfile(Profile profile) {
    currentProfile = profile;
  }
}
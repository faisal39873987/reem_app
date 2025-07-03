import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/marketplace_service.dart';

class MarketplaceProvider extends ChangeNotifier {
  List<Product> _products = [];
  bool _loading = false;
  String? _error;

  List<Product> get products => _products;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> loadMarketplace() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _products = await fetchProducts();
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> addProduct(Product product) async {
    _products.insert(0, product);
    notifyListeners();
    // TODO: Persist to backend
  }
}

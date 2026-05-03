import 'package:flutter/material.dart';

class SidebarController extends ChangeNotifier {
  bool _isOpen = true;
  bool get isOpen => _isOpen;

  void toggle() {
    _isOpen = !_isOpen;
    notifyListeners();
  }

  void setOpen(bool value) {
    _isOpen = value;
    notifyListeners();
  }
}

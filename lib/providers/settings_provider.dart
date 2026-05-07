import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static const String _txConfirmKey = 'duits_tx_confirmation_popup';

  bool _txConfirmationEnabled = true;
  bool _isLoading = true;

  SettingsProvider() {
    _loadFromPrefs();
  }

  bool get txConfirmationEnabled => _txConfirmationEnabled;
  bool get isLoading => _isLoading;

  Future<void> setTxConfirmationEnabled(bool value) async {
    if (_txConfirmationEnabled == value) return;
    _txConfirmationEnabled = value;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_txConfirmKey, value);
    } catch (e) {
      debugPrint('SettingsProvider: Failed to save tx confirmation: $e');
    }
    notifyListeners();
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _txConfirmationEnabled = prefs.getBool(_txConfirmKey) ?? true;
    } catch (e) {
      debugPrint('SettingsProvider: Failed to load prefs: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

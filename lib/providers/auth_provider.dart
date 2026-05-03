import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider extends ChangeNotifier {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  static const String _biometricUserKey = 'duits_biometric_user_id';

  final LocalAuthentication _localAuth = LocalAuthentication();
  final bool _enableLocalAuth;

  bool _isAuthenticated = false;
  bool _isInitialized = false;
  bool _isLoading = false;
  bool _hasPin = false;
  bool _needsPinSetup = false;
  bool _canUseBiometrics = false;
  bool _biometricEnabled = false;
  String? _errorMessage;
  User? _user;

  AuthProvider({bool enableLocalAuth = true})
    : _enableLocalAuth = enableLocalAuth {
    _initAuth();
  }

  bool get isAuthenticated => _isAuthenticated;
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  bool get hasPin => _hasPin;
  bool get needsPinSetup => _needsPinSetup;
  bool get canUseBiometrics => _canUseBiometrics;
  bool get biometricEnabled => _biometricEnabled;
  String? get errorMessage => _errorMessage;
  User? get user => _user;
  String? get userId => _user?.id;
  String? get email => _user?.email;
  bool get hasSupabaseSession => _user != null;

  SupabaseClient get _supabase => Supabase.instance.client;

  Future<void> _initAuth() async {
    _setLoading(true);
    try {
      if (_enableLocalAuth) {
        _canUseBiometrics = await _deviceHasUsableBiometric();
      }

      _user = _supabase.auth.currentUser;
      await _refreshLocalAuthState();
      if (_user != null) {
        await _ensureDefaultAccount(_user!.id);
      }

      _supabase.auth.onAuthStateChange.listen((data) async {
        final previousUserId = _user?.id;
        final wasUnlocked = _isAuthenticated;
        _user = data.session?.user;
        await _refreshLocalAuthState();
        if (_user == null) {
          _isAuthenticated = false;
        } else if (wasUnlocked && previousUserId == _user!.id && _hasPin) {
          _isAuthenticated = true;
        } else {
          _isAuthenticated = false;
        }
        notifyListeners();
      });
    } catch (e) {
      _errorMessage = 'Gagal memuat autentikasi: $e';
      debugPrint(_errorMessage);
    } finally {
      _isInitialized = true;
      _setLoading(false);
    }
  }

  Future<void> _refreshLocalAuthState() async {
    if (_user == null) {
      _hasPin = false;
      _needsPinSetup = false;
      _biometricEnabled = false;
      _isAuthenticated = false;
      return;
    }

    _hasPin = await _readPin(_user!.id) != null;
    _needsPinSetup = !_hasPin;
    final biometricUserId = await _secureStorage.read(key: _biometricUserKey);
    _biometricEnabled = _canUseBiometrics && biometricUserId == _user!.id;
  }

  Future<AuthResult> signUp({
    required String name,
    required String email,
    required String password,
    required String pin,
  }) async {
    if (name.trim().isEmpty) {
      return _fail('Nama wajib diisi.');
    }
    if (!_isValidEmail(email)) {
      return _fail('Email tidak valid.');
    }
    if (password.length < 6) {
      return _fail('Password minimal 6 karakter.');
    }
    if (!_isValidPin(pin)) {
      return _fail('PIN harus 4 digit angka.');
    }

    _setLoading(true);
    try {
      final response = await _supabase.auth.signUp(
        email: email.trim(),
        password: password,
        data: {'name': name.trim()},
      );

      final signedUpUser = response.user;
      if (signedUpUser == null) {
        return _fail('Signup gagal. Coba lagi.');
      }

      await _savePin(signedUpUser.id, pin);

      if (response.session == null) {
        _user = null;
        _hasPin = false;
        _needsPinSetup = false;
        return AuthResult(
          success: true,
          message:
              'Akun dibuat. Jika Supabase meminta konfirmasi email, verifikasi dulu lalu login.',
        );
      }

      _user = response.session!.user;
      await _ensureDefaultAccount(_user!.id);
      _hasPin = true;
      _needsPinSetup = false;
      if (_canUseBiometrics) {
        await enableBiometricForCurrentUser();
      }
      _isAuthenticated = true;
      notifyListeners();
      return const AuthResult(success: true);
    } on AuthException catch (e) {
      return _fail(e.message);
    } catch (e) {
      return _fail('Signup gagal: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<AuthResult> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (!_isValidEmail(email)) {
      return _fail('Email tidak valid.');
    }
    if (password.isEmpty) {
      return _fail('Password wajib diisi.');
    }

    _setLoading(true);
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      _user = response.user;
      await _refreshLocalAuthState();
      if (_user != null) {
        await _ensureDefaultAccount(_user!.id);
      }
      _isAuthenticated = false;

      notifyListeners();
      return AuthResult(
        success: true,
        requiresPinSetup: _needsPinSetup,
        message: _needsPinSetup
            ? 'Buat PIN untuk device ini.'
            : 'Akun berhasil login. Buka dengan PIN atau biometrik.',
      );
    } on AuthException catch (e) {
      return _fail(e.message);
    } catch (e) {
      return _fail('Login gagal: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<AuthResult> createPinForCurrentUser(String pin) async {
    if (_user == null) {
      return _fail('Login ke akun terlebih dahulu.');
    }
    if (!_isValidPin(pin)) {
      return _fail('PIN harus 4 digit angka.');
    }

    _setLoading(true);
    try {
      await _savePin(_user!.id, pin);
      _hasPin = true;
      _needsPinSetup = false;

      if (_canUseBiometrics) {
        await enableBiometricForCurrentUser();
      }

      _isAuthenticated = true;
      notifyListeners();
      return const AuthResult(success: true);
    } catch (e) {
      return _fail('Gagal menyimpan PIN: $e');
    } finally {
      _setLoading(false);
    }
  }

  bool login(String pin) {
    verifyPin(pin);
    return _isAuthenticated;
  }

  Future<AuthResult> verifyPin(String pin) async {
    if (_user == null) {
      return _fail('Login akun dulu sebelum memakai PIN.');
    }
    if (!_isInitialized) {
      return _fail('Autentikasi belum siap.');
    }

    final storedPin = await _readPin(_user!.id);
    if (storedPin == null) {
      _needsPinSetup = true;
      notifyListeners();
      return AuthResult(
        success: false,
        requiresPinSetup: true,
        message: 'PIN belum dibuat.',
      );
    }

    if (pin == storedPin) {
      _isAuthenticated = true;
      _errorMessage = null;
      notifyListeners();
      return const AuthResult(success: true);
    }

    return _fail('PIN salah. Coba lagi.');
  }

  Future<bool> loginWithBiometric() async {
    final result = await authenticateWithBiometric();
    return result.success;
  }

  Future<AuthResult> authenticateWithBiometric() async {
    if (_user == null) {
      return _fail('Login akun dulu sebelum memakai biometrik.');
    }
    if (!_canUseBiometrics) {
      return _fail('Biometrik tidak tersedia di perangkat ini.');
    }

    final boundUserId = await _secureStorage.read(key: _biometricUserKey);
    if (boundUserId != _user!.id) {
      return _fail('Biometrik belum dipasangkan untuk akun ini.');
    }

    final ok = await _authenticateWithDevice(
      'Gunakan biometrik untuk membuka Duits',
    );

    if (!ok) {
      return _fail(_errorMessage ?? 'Autentikasi biometrik dibatalkan.');
    }

    _isAuthenticated = true;
    _errorMessage = null;
    notifyListeners();
    return const AuthResult(success: true);
  }

  Future<AuthResult> enableBiometricForCurrentUser() async {
    if (_user == null) {
      return _fail('Login akun dulu sebelum memasangkan biometrik.');
    }
    if (!_canUseBiometrics) {
      return _fail('Biometrik tidak tersedia di perangkat ini.');
    }

    final ok = await _authenticateWithDevice(
      'Pasangkan biometrik perangkat ini dengan akun Duits',
    );

    if (!ok) {
      _biometricEnabled = false;
      notifyListeners();
      return _fail(_errorMessage ?? 'Pemasangan biometrik dibatalkan.');
    }

    await _secureStorage.write(key: _biometricUserKey, value: _user!.id);
    _biometricEnabled = true;
    _isAuthenticated = true;
    _errorMessage = null;
    notifyListeners();
    return const AuthResult(success: true);
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      debugPrint('Logout error: $e');
    } finally {
      _user = null;
      _isAuthenticated = false;
      _hasPin = false;
      _needsPinSetup = false;
      _setLoading(false);
    }
  }

  Future<void> changePin(String newPin) async {
    if (_user == null || !_isValidPin(newPin)) return;
    await _savePin(_user!.id, newPin);
    _hasPin = true;
    _needsPinSetup = false;
    notifyListeners();
  }

  Future<AuthResult> updateProfile({String? name, String? photoUrl}) async {
    if (_user == null) return _fail('User not logged in');

    _setLoading(true);
    try {
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (photoUrl != null) updates['avatar_url'] = photoUrl;

      await _supabase.auth.updateUser(
        UserAttributes(data: updates),
      );

      _user = _supabase.auth.currentUser;
      notifyListeners();
      return const AuthResult(success: true);
    } on AuthException catch (e) {
      return _fail(e.message);
    } catch (e) {
      return _fail('Gagal memperbarui profil: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<AuthResult> changePassword(String newPassword) async {
    if (_user == null) return _fail('User not logged in');
    if (newPassword.length < 6) return _fail('Password minimal 6 karakter.');

    _setLoading(true);
    try {
      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      return const AuthResult(success: true);
    } on AuthException catch (e) {
      return _fail(e.message);
    } catch (e) {
      return _fail('Gagal mengubah password: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> resetAuth() async {
    final currentUserId = _user?.id;
    if (currentUserId != null) {
      await _secureStorage.delete(key: _pinKey(currentUserId));
    }
    await _secureStorage.delete(key: _biometricUserKey);
    await logout();
  }

  Future<String?> _readPin(String userId) =>
      _secureStorage.read(key: _pinKey(userId));

  Future<void> _savePin(String userId, String pin) {
    return _secureStorage.write(key: _pinKey(userId), value: pin);
  }

  Future<void> _ensureDefaultAccount(String userId) async {
    try {
      final existing = await _supabase
          .from('accounts')
          .select('id')
          .eq('user_id', userId)
          .limit(1);

      if (existing.isNotEmpty) return;

      await _supabase.from('accounts').insert({
        'user_id': userId,
        'name': 'Dompet Utama',
        'type': 'cash',
        'opening_balance': 0,
        'currency': 'IDR',
      });
    } catch (e) {
      debugPrint('Default account setup failed: $e');
    }
  }

  Future<bool> _deviceHasUsableBiometric() async {
    try {
      final supported = await _localAuth.isDeviceSupported();
      final canCheck = await _localAuth.canCheckBiometrics;
      final available = await _localAuth.getAvailableBiometrics();
      return supported && canCheck && available.isNotEmpty;
    } catch (e) {
      debugPrint('Biometric capability check failed: $e');
      return false;
    }
  }

  Future<bool> _authenticateWithDevice(String reason) async {
    try {
      return await _localAuth.authenticate(
        localizedReason: reason,
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
    } on LocalAuthException catch (e) {
      _errorMessage = _localAuthMessage(e);
      debugPrint('Local auth error: ${e.code} ${e.description}');
      return false;
    } catch (e) {
      _errorMessage = 'Autentikasi biometrik gagal: $e';
      debugPrint(_errorMessage);
      return false;
    }
  }

  String _localAuthMessage(LocalAuthException e) {
    return switch (e.code) {
      LocalAuthExceptionCode.noBiometricHardware =>
        'Perangkat ini tidak punya sensor biometrik.',
      LocalAuthExceptionCode.noBiometricsEnrolled =>
        'Belum ada sidik jari/biometrik yang terdaftar di Android.',
      LocalAuthExceptionCode.biometricLockout ||
      LocalAuthExceptionCode.temporaryLockout =>
        'Biometrik terkunci sementara. Coba lagi nanti atau gunakan PIN.',
      LocalAuthExceptionCode.userCanceled ||
      LocalAuthExceptionCode.systemCanceled =>
        'Autentikasi biometrik dibatalkan.',
      _ => e.description ?? 'Autentikasi biometrik gagal.',
    };
  }

  String _pinKey(String userId) => 'duits_pin_$userId';

  bool _isValidEmail(String value) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim());
  }

  bool _isValidPin(String value) {
    return RegExp(r'^\d{4}$').hasMatch(value);
  }

  AuthResult _fail(String message) {
    _errorMessage = message;
    notifyListeners();
    return AuthResult(success: false, message: message);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}

class AuthResult {
  final bool success;
  final String? message;
  final bool requiresPinSetup;

  const AuthResult({
    required this.success,
    this.message,
    this.requiresPinSetup = false,
  });
}

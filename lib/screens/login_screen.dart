import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

enum _LoginMode { account, choice, pin, biometric, setupPin }

enum _AccountMode { signIn, signUp }

enum _BiometricState { idle, scanning, success, fail }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  static const int _maxPin = 4;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  _LoginMode _mode = _LoginMode.account;
  _AccountMode _accountMode = _AccountMode.signIn;
  _BiometricState _biometricState = _BiometricState.idle;
  String _pin = '';
  String _error = '';
  String _info = '';

  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;
  late final AnimationController _spinController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnimation =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 0, end: -10), weight: 1),
          TweenSequenceItem(tween: Tween(begin: -10, end: 10), weight: 1),
          TweenSequenceItem(tween: Tween(begin: 10, end: -8), weight: 1),
          TweenSequenceItem(tween: Tween(begin: -8, end: 8), weight: 1),
          TweenSequenceItem(tween: Tween(begin: 8, end: 0), weight: 1),
        ]).animate(
          CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut),
        );
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _shakeController.dispose();
    _spinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    _syncModeWithAuth(auth);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF3B30D4), Color(0xFF6C3AED), Color(0xFF7C63FF)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 28,
                ),
                child: Column(
                  children: [
                    const _LogoBlock(),
                    const SizedBox(height: 28),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 240),
                      child: switch (_mode) {
                        _LoginMode.account => _buildAccountMode(auth),
                        _LoginMode.choice => _buildChoiceMode(auth),
                        _LoginMode.pin => _buildPinMode(),
                        _LoginMode.biometric => _buildBiometricMode(),
                        _LoginMode.setupPin => _buildSetupPinMode(auth),
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _syncModeWithAuth(AuthProvider auth) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (auth.isAuthenticated) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
        return;
      }
      if (auth.hasSupabaseSession &&
          auth.needsPinSetup &&
          _mode != _LoginMode.setupPin) {
        setState(() => _mode = _LoginMode.setupPin);
      } else if (auth.hasSupabaseSession &&
          auth.hasPin &&
          (_mode == _LoginMode.account || _mode == _LoginMode.setupPin)) {
        setState(() => _mode = _LoginMode.choice);
      } else if (!auth.hasSupabaseSession &&
          _mode != _LoginMode.account &&
          _mode != _LoginMode.biometric) {
        setState(() => _mode = _LoginMode.account);
      }
    });
  }

  Widget _buildAccountMode(AuthProvider auth) {
    final isSignUp = _accountMode == _AccountMode.signUp;
    return _GlassPanel(
      key: const ValueKey('account'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: _SegmentButton(
                  label: 'Login',
                  selected: !isSignUp,
                  onTap: () => setState(() {
                    _accountMode = _AccountMode.signIn;
                    _clearMessages();
                  }),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SegmentButton(
                  label: 'Signup',
                  selected: isSignUp,
                  onTap: () => setState(() {
                    _accountMode = _AccountMode.signUp;
                    _clearMessages();
                  }),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (isSignUp) ...[
            _AuthTextField(
              controller: _nameController,
              label: 'Nama',
              icon: Icons.person_outline_rounded,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
          ],
          _AuthTextField(
            controller: _emailController,
            label: 'Email',
            icon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          _AuthTextField(
            controller: _passwordController,
            label: 'Password',
            icon: Icons.lock_outline_rounded,
            obscureText: true,
            textInputAction: TextInputAction.done,
          ),
          if (isSignUp) ...[
            const SizedBox(height: 16),
            const Text(
              'Buat PIN 4 digit',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFFC7D2FE), fontSize: 13),
            ),
            const SizedBox(height: 12),
            _PinDots(pin: _pin, maxPin: _maxPin),
            const SizedBox(height: 10),
            _MiniNumpad(
              onDigit: _handleSetupPinDigit,
              onDelete: _handleSetupPinDelete,
            ),
          ],
          const SizedBox(height: 14),
          _Message(error: _error, info: _info),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: auth.isLoading ? null : () => _submitAccount(auth),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF4F46E5),
              disabledBackgroundColor: Colors.white54,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: auth.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    isSignUp ? 'Buat Akun' : 'Login Akun',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceMode(AuthProvider auth) {
    return Column(
      key: const ValueKey('choice'),
      children: [
        Text(
          auth.email ?? 'Akun siap',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Pilih cara membuka aplikasi',
          style: TextStyle(color: Color(0xFFC7D2FE), fontSize: 13),
        ),
        const SizedBox(height: 16),
        _ChoiceButton(
          icon: Icons.fingerprint_rounded,
          title: auth.biometricEnabled ? 'Sidik Jari' : 'Aktifkan Biometrik',
          subtitle: auth.biometricEnabled
              ? 'Masuk dengan biometrik HP'
              : auth.canUseBiometrics
              ? 'Pasangkan biometrik perangkat ini'
              : 'Gunakan PIN di perangkat ini',
          showStatus: auth.biometricEnabled,
          onTap: () => _openBiometricFlow(auth),
        ),
        const SizedBox(height: 12),
        _ChoiceButton(
          icon: Icons.pin_rounded,
          title: 'Masuk dengan PIN',
          subtitle: 'Gunakan PIN akun ini',
          onTap: () => setState(() {
            _mode = _LoginMode.pin;
            _clearPin();
          }),
        ),
        const SizedBox(height: 14),
        TextButton(
          onPressed: () => auth.logout(),
          child: const Text(
            'Ganti akun',
            style: TextStyle(color: Color(0xFFC7D2FE)),
          ),
        ),
      ],
    );
  }

  Widget _buildPinMode() {
    return Column(
      key: const ValueKey('pin'),
      children: [
        const Text(
          'Masukkan PIN 4 digit',
          style: TextStyle(color: Color(0xFFC7D2FE), fontSize: 14),
        ),
        const SizedBox(height: 24),
        AnimatedBuilder(
          animation: _shakeAnimation,
          builder: (context, child) => Transform.translate(
            offset: Offset(_shakeAnimation.value, 0),
            child: child,
          ),
          child: _PinDots(pin: _pin, maxPin: _maxPin),
        ),
        const SizedBox(height: 12),
        _Message(error: _error, info: _info),
        const SizedBox(height: 16),
        _Numpad(onDigit: _handleDigit, onDelete: _handleDelete),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => setState(() {
            _mode = _LoginMode.choice;
            _clearPin();
          }),
          child: const Text(
            'Kembali',
            style: TextStyle(color: Color(0xFFA5B4FC)),
          ),
        ),
      ],
    );
  }

  Widget _buildSetupPinMode(AuthProvider auth) {
    return Column(
      key: const ValueKey('setupPin'),
      children: [
        const Text(
          'Buat PIN untuk device ini',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'PIN dipakai setelah akun Supabase berhasil login.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFFC7D2FE), fontSize: 13),
        ),
        const SizedBox(height: 22),
        _PinDots(pin: _pin, maxPin: _maxPin),
        const SizedBox(height: 12),
        _Message(error: _error, info: _info),
        const SizedBox(height: 16),
        _Numpad(
          onDigit: (digit) => _handleSetupPinDigit(digit, autoSubmit: true),
          onDelete: _handleSetupPinDelete,
        ),
        const SizedBox(height: 16),
        if (auth.isLoading)
          const CircularProgressIndicator(color: Colors.white)
        else
          TextButton(
            onPressed: () => auth.logout(),
            child: const Text(
              'Batal dan logout',
              style: TextStyle(color: Color(0xFFA5B4FC)),
            ),
          ),
      ],
    );
  }

  Widget _buildBiometricMode() {
    return Column(
      key: const ValueKey('biometric'),
      children: [
        Text(
          switch (_biometricState) {
            _BiometricState.idle => 'Siap memindai sidik jari',
            _BiometricState.scanning => 'Memindai sidik jari...',
            _BiometricState.success => 'Berhasil! Selamat datang',
            _BiometricState.fail =>
              _error.isEmpty ? 'Sidik jari tidak dikenal' : _error,
          },
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFFC7D2FE), fontSize: 14),
        ),
        const SizedBox(height: 28),
        Stack(
          alignment: Alignment.center,
          children: [
            if (_biometricState == _BiometricState.scanning)
              RotationTransition(
                turns: _spinController,
                child: Container(
                  width: 144,
                  height: 144,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SweepGradient(
                      colors: [
                        Colors.transparent,
                        Colors.white54,
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 260),
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                color: _biometricColor().withValues(alpha: 0.22),
                shape: BoxShape.circle,
                border: Border.all(color: _biometricColor(), width: 2),
              ),
              child: Icon(
                Icons.fingerprint_rounded,
                color: _biometricColor(),
                size: 64,
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        OutlinedButton(
          onPressed: _handleBiometric,
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: BorderSide(color: Colors.white.withValues(alpha: 0.32)),
            backgroundColor: Colors.white.withValues(alpha: 0.14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          ),
          child: const Text('Coba Biometrik'),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () {
            _spinController.stop();
            setState(() {
              _mode = _LoginMode.choice;
              _biometricState = _BiometricState.idle;
              _error = '';
            });
          },
          child: const Text(
            'Gunakan PIN sebagai gantinya',
            style: TextStyle(color: Color(0xFFA5B4FC)),
          ),
        ),
      ],
    );
  }

  Future<void> _submitAccount(AuthProvider auth) async {
    _clearMessages();
    final AuthResult result;
    if (_accountMode == _AccountMode.signUp) {
      if (_pin.length != _maxPin) {
        setState(() => _error = 'Buat PIN 4 digit dulu.');
        return;
      }
      result = await auth.signUp(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        pin: _pin,
      );
    } else {
      result = await auth.signInWithEmail(
        email: _emailController.text,
        password: _passwordController.text,
      );
    }

    if (!mounted) return;
    if (!result.success) {
      setState(() => _error = result.message ?? 'Autentikasi gagal.');
      return;
    }
    if (result.requiresPinSetup) {
      setState(() {
        _mode = _LoginMode.setupPin;
        _clearPin();
      });
      return;
    }
    if (result.message != null && !auth.isAuthenticated) {
      setState(() {
        _clearPin();
        _info = result.message!;
        if (auth.hasSupabaseSession && auth.needsPinSetup) {
          _mode = _LoginMode.setupPin;
        } else if (auth.hasSupabaseSession && auth.hasPin) {
          _mode = _LoginMode.choice;
        } else {
          _accountMode = _AccountMode.signIn;
        }
      });
    }
  }

  Future<void> _openBiometricFlow(AuthProvider auth) async {
    _clearMessages();
    if (!auth.canUseBiometrics) {
      setState(() {
        _mode = _LoginMode.pin;
        _clearPin();
        _error = 'Biometrik tidak tersedia. Gunakan PIN dulu.';
      });
      return;
    }

    if (!auth.biometricEnabled) {
      final result = await auth.enableBiometricForCurrentUser();
      if (!mounted) return;
      if (!result.success) {
        setState(() {
          _mode = _LoginMode.choice;
          _error = result.message ?? 'Gagal memasangkan biometrik.';
        });
        return;
      }
      setState(() {
        _mode = _LoginMode.biometric;
        _biometricState = _BiometricState.success;
        _error = '';
      });
      return;
    }

    if (!mounted) return;
    setState(() {
      _mode = _LoginMode.biometric;
      _biometricState = _BiometricState.idle;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _handleBiometric();
    });
  }

  void _handleDigit(String digit) {
    if (_pin.length >= _maxPin) return;
    final nextPin = _pin + digit;
    setState(() {
      _pin = nextPin;
      _error = '';
    });
    if (nextPin.length == _maxPin) {
      Timer(const Duration(milliseconds: 120), () => _verifyPin(nextPin));
    }
  }

  Future<void> _verifyPin(String pin) async {
    final result = await context.read<AuthProvider>().verifyPin(pin);
    if (result.success) return;
    _shakeController.forward(from: 0);
    setState(() => _error = result.message ?? 'PIN salah. Coba lagi.');
    Timer(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _pin = '');
    });
  }

  void _handleDelete() {
    if (_pin.isEmpty) return;
    setState(() {
      _pin = _pin.substring(0, _pin.length - 1);
      _error = '';
    });
  }

  void _handleSetupPinDigit(String digit, {bool autoSubmit = false}) {
    if (_pin.length >= _maxPin) return;
    setState(() {
      _pin += digit;
      _error = '';
    });
    if (autoSubmit && _pin.length == _maxPin) {
      Timer(const Duration(milliseconds: 120), _submitSetupPin);
    }
  }

  void _handleSetupPinDelete() {
    if (_pin.isEmpty) return;
    setState(() {
      _pin = _pin.substring(0, _pin.length - 1);
      _error = '';
    });
  }

  Future<void> _submitSetupPin() async {
    final result = await context.read<AuthProvider>().createPinForCurrentUser(
      _pin,
    );
    if (!mounted || result.success) return;
    setState(() => _error = result.message ?? 'Gagal membuat PIN.');
  }

  Future<void> _handleBiometric() async {
    if (_biometricState == _BiometricState.scanning) return;
    setState(() {
      _biometricState = _BiometricState.scanning;
      _error = '';
    });
    _spinController.repeat();

    final result = await context
        .read<AuthProvider>()
        .authenticateWithBiometric();
    _spinController.stop();
    if (!mounted) return;

    setState(() {
      _biometricState = result.success
          ? _BiometricState.success
          : _BiometricState.fail;
      _error = result.message ?? '';
    });
  }

  Color _biometricColor() {
    return switch (_biometricState) {
      _BiometricState.success => const Color(0xFF00C48C),
      _BiometricState.fail => const Color(0xFFFF6B6B),
      _ => Colors.white,
    };
  }

  void _clearPin() {
    _pin = '';
    _error = '';
    _info = '';
  }

  void _clearMessages() {
    _error = '';
    _info = '';
  }
}

class _LogoBlock extends StatelessWidget {
  const _LogoBlock();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: const Icon(
            Icons.account_balance_wallet_rounded,
            color: Colors.white,
            size: 40,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Duits',
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Kelola keuangan dengan cerdas',
          style: TextStyle(color: Color(0xFFC7D2FE), fontSize: 14),
        ),
      ],
    );
  }
}

class _GlassPanel extends StatelessWidget {
  final Widget child;

  const _GlassPanel({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
      ),
      child: child,
    );
  }
}

class _SegmentButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SegmentButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.white.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected ? const Color(0xFF4F46E5) : Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;

  const _AuthTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFFC7D2FE)),
        prefixIcon: Icon(icon, color: const Color(0xFFC7D2FE)),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.18)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.18)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Colors.white),
        ),
      ),
    );
  }
}

class _ChoiceButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool showStatus;
  final VoidCallback onTap;

  const _ChoiceButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.showStatus = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.25),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFFC7D2FE),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (showStatus)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF34D399),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PinDots extends StatelessWidget {
  final String pin;
  final int maxPin;

  const _PinDots({required this.pin, required this.maxPin});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        maxPin,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 16,
          height: 16,
          margin: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: index < pin.length ? Colors.white : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color: index < pin.length ? Colors.white : Colors.white38,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}

class _Numpad extends StatelessWidget {
  final ValueChanged<String> onDigit;
  final VoidCallback onDelete;

  const _Numpad({required this.onDigit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        children: [
          for (final key in [
            '1',
            '2',
            '3',
            '4',
            '5',
            '6',
            '7',
            '8',
            '9',
            '',
            '0',
            'del',
          ])
            if (key.isEmpty)
              const SizedBox.shrink()
            else
              _NumpadButton(
                value: key,
                onTap: key == 'del' ? onDelete : () => onDigit(key),
              ),
        ],
      ),
    );
  }
}

class _MiniNumpad extends StatelessWidget {
  final ValueChanged<String> onDigit;
  final VoidCallback onDelete;

  const _MiniNumpad({required this.onDigit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final key in ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'])
          SizedBox(
            width: 42,
            height: 42,
            child: _SmallPinButton(label: key, onTap: () => onDigit(key)),
          ),
        SizedBox(
          width: 42,
          height: 42,
          child: _SmallPinButton(
            icon: Icons.backspace_outlined,
            onTap: onDelete,
          ),
        ),
      ],
    );
  }
}

class _SmallPinButton extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final VoidCallback onTap;

  const _SmallPinButton({this.label, this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: icon != null
              ? Icon(icon, color: Colors.white70, size: 18)
              : Text(
                  label!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
        ),
      ),
    );
  }
}

class _NumpadButton extends StatelessWidget {
  final String value;
  final VoidCallback onTap;

  const _NumpadButton({required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDelete = value == 'del';
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: isDelete ? 0.10 : 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        ),
        child: Center(
          child: isDelete
              ? const Icon(
                  Icons.backspace_outlined,
                  color: Colors.white70,
                  size: 21,
                )
              : Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  final String error;
  final String info;

  const _Message({required this.error, required this.info});

  @override
  Widget build(BuildContext context) {
    final text = error.isNotEmpty ? error : info;
    if (text.isEmpty) return const SizedBox(height: 20);
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: error.isNotEmpty
            ? const Color(0xFFFCA5A5)
            : const Color(0xFFBBF7D0),
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

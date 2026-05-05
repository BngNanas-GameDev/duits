import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class ChangePinScreen extends StatefulWidget {
  const ChangePinScreen({super.key});

  @override
  State<ChangePinScreen> createState() => _ChangePinScreenState();
}

class _ChangePinScreenState extends State<ChangePinScreen>
    with SingleTickerProviderStateMixin {
  static const int _maxPin = 4;

  // Step management
  // step 1: verify old PIN
  // step 2: enter new PIN
  // step 3: confirm new PIN
  int _step = 1;

  String _currentInput = '';
  String _error = '';
  String _newPinTemp = ''; // stores new PIN between step 2 and 3

  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -10), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10, end: 10), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 10, end: -8), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -8, end: 8), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 8, end: 0), weight: 1),
    ]).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  String get _title {
    switch (_step) {
      case 1:
        return 'Verifikasi PIN Lama';
      case 2:
        return 'Masukkan PIN Baru';
      case 3:
        return 'Konfirmasi PIN Baru';
      default:
        return '';
    }
  }

  String get _subtitle {
    switch (_step) {
      case 1:
        return 'Masukkan PIN lama Anda untuk verifikasi';
      case 2:
        return 'Buat PIN baru 4 digit';
      case 3:
        return 'Ulangi PIN baru Anda';
      default:
        return '';
    }
  }

  Future<void> _handleDigit(String digit) async {
    if (_currentInput.length >= _maxPin) return;
    final nextPin = _currentInput + digit;

    setState(() {
      _currentInput = nextPin;
      _error = '';
    });

    if (nextPin.length == _maxPin) {
      // Auto-verify after complete
      Timer(const Duration(milliseconds: 200), () {
        if (!mounted) return;
        switch (_step) {
          case 1:
            _verifyOldPin(nextPin);
            break;
          case 2:
            _proceedToConfirm(nextPin);
            break;
          case 3:
            _confirmAndSave(nextPin);
            break;
        }
      });
    }
  }

  Future<void> _verifyOldPin(String pin) async {
    final auth = context.read<AuthProvider>();
    final result = await auth.verifyPin(pin);

    if (!mounted) return;

    if (result.success) {
      // Old PIN verified, move to step 2
      setState(() {
        _step = 2;
        _currentInput = '';
        _error = '';
      });
    } else {
      _shakeController.forward(from: 0);
      setState(() {
        _error = result.message ?? 'PIN lama salah.';
      });
      Timer(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() => _currentInput = '');
        }
      });
    }
  }

  void _proceedToConfirm(String newPin) {
    setState(() {
      _newPinTemp = newPin;
      _step = 3;
      _currentInput = '';
      _error = '';
    });
  }

  Future<void> _confirmAndSave(String confirmPin) async {
    if (confirmPin != _newPinTemp) {
      _shakeController.forward(from: 0);
      setState(() {
        _error = 'PIN tidak cocok. Coba lagi.';
      });
      Timer(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() => _currentInput = '');
        }
      });
      return;
    }

    // PINs match, save new PIN
    final auth = context.read<AuthProvider>();
    await auth.changePin(confirmPin);

    if (mounted) {
      // Show success and navigate back
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN berhasil diubah.')),
      );
    }
  }

  Future<void> _handleBiometricVerify() async {
    final auth = context.read<AuthProvider>();
    final result = await auth.authenticateWithBiometric();

    if (!mounted) return;

    if (result.success) {
      // Biometric verified, skip to PIN entry
      setState(() {
        _step = 2;
        _currentInput = '';
        _error = '';
      });
    } else {
      setState(() {
        _error = result.message ?? 'Autentikasi biometrik gagal.';
      });
      _shakeController.forward(from: 0);
    }
  }

  void _handleDelete() {
    if (_currentInput.isEmpty) return;
    setState(() {
      _currentInput = _currentInput.substring(0, _currentInput.length - 1);
      _error = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubah PIN'),
        centerTitle: true,
        elevation: 0,
        leading: _step > 1
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () {
                  setState(() {
                    if (_step == 3) {
                      _step = 2;
                    } else {
                      _step = 1;
                    }
                    _currentInput = '';
                    _error = '';
                  });
                },
              )
            : null,
      ),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Column(
                    key: ValueKey(_step),
                    children: [
                      // Step indicator dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (index) {
                          final stepNum = index + 1;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            width: stepNum <= _step ? 24 : 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: stepNum <= _step
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 32),
                      // Title
                      Text(
                        _title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Subtitle
                      Text(
                        _subtitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFFC7D2FE),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 28),
                      // PIN Dots
                      animatedPinDots,
                      const SizedBox(height: 12),
                      // Error message
                      if (_error.isNotEmpty)
                        Text(
                          _error,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFFFCA5A5),
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      const SizedBox(height: 20),
                      // Numpad
                      SizedBox(
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
                                  onTap: key == 'del'
                                      ? _handleDelete
                                      : () => _handleDigit(key),
                                ),
                          ],
                        ),
                      ),
                      // Biometric button (step 1 only)
                      if (_step == 1) ...[
                        const SizedBox(height: 20),
                        Consumer<AuthProvider>(
                          builder: (context, auth, _) {
                            if (!auth.canUseBiometrics) {
                              return const SizedBox.shrink();
                            }
                            return TextButton.icon(
                              onPressed: _handleBiometricVerify,
                              icon: const Icon(Icons.fingerprint_rounded),
                              label: const Text('Gunakan Sidik Jari'),
                              style: TextButton.styleFrom(
                                foregroundColor:
                                    const Color(0xFFA5B4FC),
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget get animatedPinDots {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) => Transform.translate(
        offset: Offset(_shakeAnimation.value, 0),
        child: child,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          _maxPin,
          (index) => AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 18,
            height: 18,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: index < _currentInput.length
                  ? Colors.white
                  : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: index < _currentInput.length
                    ? Colors.white
                    : Colors.white38,
                width: 2,
              ),
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
          color: Colors.white.withValues(
              alpha: isDelete ? 0.10 : 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: Colors.white.withValues(alpha: 0.10)),
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

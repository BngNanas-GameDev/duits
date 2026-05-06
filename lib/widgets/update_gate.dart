import 'package:flutter/material.dart';
import '../services/update_checker.dart';
import '../widgets/update_dialog.dart';

class UpdateGate extends StatefulWidget {
  final Widget child;

  const UpdateGate({super.key, required this.child});

  @override
  State<UpdateGate> createState() => _UpdateGateState();
}

class _UpdateGateState extends State<UpdateGate> {
  bool _isChecking = true;
  bool _hasShownUpdate = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkUpdate());
  }

  Future<void> _checkUpdate() async {
    if (_hasShownUpdate) return;

    await Future.delayed(const Duration(milliseconds: 500));

    final updateInfo = await UpdateChecker.checkForUpdate();

    if (!mounted) return;

    if (updateInfo.hasUpdate) {
      _hasShownUpdate = true;
      if (updateInfo.isForceUpdate) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => PopScope(
            canPop: false,
            child: UpdateDialog(
              updateInfo: updateInfo,
            ),
          ),
        );

        if (!mounted) return;
        setState(() {
          _isChecking = false;
        });

        if (updateInfo.isForceUpdate) {
          await Future.delayed(const Duration(milliseconds: 500));
          if (!mounted) return;
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (dialogContext) => PopScope(
              canPop: false,
              child: UpdateDialog(
                updateInfo: updateInfo,
              ),
            ),
          );
        }
      } else {
        bool shouldSkip = false;
        await showDialog(
          context: context,
          barrierDismissible: true,
          builder: (dialogContext) => UpdateDialog(
            updateInfo: updateInfo,
            onSkip: () {
              shouldSkip = true;
              Navigator.of(dialogContext).pop();
            },
          ),
        );

        if (shouldSkip && mounted) {
          setState(() {
            _isChecking = false;
          });
          return;
        }
      }
    }

    if (!mounted) return;
    setState(() {
      _isChecking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Memeriksa pembaruan...'),
            ],
          ),
        ),
      );
    }

    return widget.child;
  }
}

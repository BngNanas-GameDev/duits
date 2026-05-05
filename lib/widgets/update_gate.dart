import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkUpdate());
  }

  Future<void> _checkUpdate() async {
    await Future.delayed(const Duration(milliseconds: 500));

    final prefs = await SharedPreferences.getInstance();
    final lastSkipDate = prefs.getString('update_skip_date');
    final today = DateTime.now().toIso8601String().substring(0, 10);

    if (lastSkipDate == today) {
      if (!mounted) return;
      setState(() {
        _isChecking = false;
      });
      return;
    }

    final updateInfo = await UpdateChecker.checkForUpdate();

    if (!mounted) return;

    if (updateInfo.hasUpdate) {
      if (updateInfo.isForceUpdate) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => UpdateDialog(
            updateInfo: updateInfo,
            onDismiss: () {
              Navigator.of(dialogContext).pop();
            },
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
            builder: (dialogContext) => UpdateDialog(
              updateInfo: updateInfo,
              onDismiss: () {},
            ),
          );
        }
      } else {
        await showDialog(
          context: context,
          barrierDismissible: true,
          builder: (dialogContext) => UpdateDialog(
            updateInfo: updateInfo,
            onDismiss: () async {
              final p = await SharedPreferences.getInstance();
              await p.setString('update_skip_date', today);
            },
          ),
        );
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

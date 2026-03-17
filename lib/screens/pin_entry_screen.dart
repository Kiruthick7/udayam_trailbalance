import 'package:flutter/material.dart';
import 'package:trial_balance_app/screens/home_screen.dart';
import '../services/storage_service.dart';
import '../widgets/shake_widget.dart';

class PinEntryScreen extends StatefulWidget {
  final Future<void> Function() onPinVerified;
  final VoidCallback onFailed;
  const PinEntryScreen(
      {super.key, required this.onPinVerified, required this.onFailed});

  @override
  State<PinEntryScreen> createState() => _PinEntryScreenState();
}

class _PinEntryScreenState extends State<PinEntryScreen> {
  AnimationController? _pinShakeController;
  final _pinController = TextEditingController();
  String? _error;
  int _attempts = 0;
  final int _maxAttempts = 5;
  bool _isVerifying = false;

  Future<void> _verifyPin() async {
    if (_isVerifying) return;
    setState(() => _isVerifying = true);
    final pin = _pinController.text.trim();
    final isValid = await StorageService.verifyPin(pin);
    if (!mounted) return;
    if (isValid) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } else {
      setState(() {
        _attempts++;
        _error = 'Incorrect PIN';
        _isVerifying = false;
      });
      _pinShakeController?.forward(from: 0);
      if (_attempts >= _maxAttempts) {
        widget.onFailed();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Enter PIN',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              final navigator = Navigator.of(context);

              await StorageService.clearPin();

              if (!mounted) return;

              navigator.popUntil((route) => route.isFirst);
            },
          ),
        ],
      ),
      body: Center(
        child: Card(
          color: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 8,
          margin: const EdgeInsets.symmetric(horizontal: 24),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Enter your PIN',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'For your security, please enter your 4-digit PIN.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withAlpha((0.8 * 255).toInt()),
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ShakeWidget(
                  shakeConstant: ShakeDefaultConstant1(),
                  onController: (controller) =>
                      _pinShakeController = controller,
                  child: TextField(
                    controller: _pinController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    maxLength: 4,
                    enabled: !_isVerifying,
                    style: Theme.of(context).textTheme.titleLarge,
                    decoration: InputDecoration(
                      labelText: 'Enter 4-digit PIN',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.lock_outline),
                    ),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _error!,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).colorScheme.error,
                              fontWeight: FontWeight.bold,
                            ) ??
                        TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 32),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isVerifying ? null : _verifyPin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      textStyle: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(color: Colors.white),
                    ),
                    child: _isVerifying
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'Verify',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

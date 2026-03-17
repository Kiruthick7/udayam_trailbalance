import 'package:flutter/material.dart';
import 'package:trial_balance_app/screens/home_screen.dart';
import '../services/storage_service.dart';
import '../widgets/shake_widget.dart';

class PinSetupScreen extends StatefulWidget {
  final VoidCallback onPinSet;
  const PinSetupScreen({super.key, required this.onPinSet});

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  AnimationController? _pinShakeController;
  AnimationController? _confirmPinShakeController;
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  String? _error;

  Future<void> _savePin() async {
    final pin = _pinController.text.trim();
    final confirmPin = _confirmPinController.text.trim();
    if (pin.length != 4 || confirmPin.length != 4) {
      setState(() => _error = 'PIN must be 4 digits');
      _pinShakeController?.forward(from: 0);
      _confirmPinShakeController?.forward(from: 0);
      return;
    }
    if (pin != confirmPin) {
      setState(() => _error = 'PINs do not match');
      _pinShakeController?.forward(from: 0);
      _confirmPinShakeController?.forward(from: 0);
      return;
    }
    await StorageService.savePin(pin);
    if (!mounted) return;
    // Navigate directly to HomeScreen and clear the stack
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Set 4-digit PIN',
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
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Center(
          child: Card(
            color: Theme.of(context).cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            elevation: 12,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Icon(Icons.lock,
                        size: 40, color: Theme.of(context).primaryColor),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Secure your account',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Set a 4-digit PIN to protect your data.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.8),
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  ShakeWidget(
                    shakeConstant: ShakeDefaultConstant1(),
                    onController: (controller) =>
                        _pinShakeController = controller,
                    child: TextField(
                      controller: _pinController,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      maxLength: 4,
                      style: Theme.of(context).textTheme.titleLarge,
                      decoration: InputDecoration(
                        labelText: 'Enter PIN',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14)),
                        prefixIcon: Icon(Icons.lock_outline,
                            color: Theme.of(context).primaryColor),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  ShakeWidget(
                    shakeConstant: ShakeDefaultConstant1(),
                    onController: (controller) =>
                        _confirmPinShakeController = controller,
                    child: TextField(
                      controller: _confirmPinController,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      maxLength: 4,
                      style: Theme.of(context).textTheme.titleLarge,
                      decoration: InputDecoration(
                        labelText: 'Confirm PIN',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14)),
                        prefixIcon: Icon(Icons.lock,
                            color: Theme.of(context).primaryColor),
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
                  const SizedBox(height: 28),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _savePin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        elevation: 4,
                        textStyle: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(color: Colors.white),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.check_circle_outline,
                            color: Colors.white,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Save PIN',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

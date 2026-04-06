import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bilirubin/core/l10n/app_localizations.dart';
import 'package:bilirubin/providers/settings_providers.dart';
import 'package:bilirubin/security/app_lock_service.dart';

/// Full-screen PIN entry screen shown when app lock is enabled.
class PinLockScreen extends ConsumerStatefulWidget {
  const PinLockScreen({super.key});

  @override
  ConsumerState<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends ConsumerState<PinLockScreen> {
  final _lockService = AppLockService();
  String _pin = '';
  String? _error;
  bool _checking = false;

  static const _maxLen = 6;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _tryBiometric());
  }

  Future<void> _tryBiometric() async {
    final can = await _lockService.canUseBiometric();
    if (!can || !mounted) return;
    final ok = await _lockService.authenticateBiometric();
    if (ok && mounted) _unlock();
  }

  void _onDigit(String d) {
    if (_pin.length >= _maxLen) return;
    setState(() {
      _pin += d;
      _error = null;
    });
    if (_pin.length == _maxLen) _submit();
  }

  void _onBack() {
    if (_pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  Future<void> _submit() async {
    if (_checking) return;
    setState(() => _checking = true);
    final ok = await _lockService.verifyPin(_pin);
    if (!mounted) return;
    if (ok) {
      _unlock();
    } else {
      setState(() {
        _pin = '';
        _error = AppLocalizations.of(context).pinLockIncorrect;
        _checking = false;
      });
    }
  }

  void _unlock() {
    ref.read(appLockEnabledProvider.notifier).state = false;
    context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/icon.png',
                  width: 72,
                  height: 72,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.lock_outline, size: 72),
                ),
                const SizedBox(height: 16),
                Text(l10n.pinLockTitle, style: theme.textTheme.headlineSmall),
                const SizedBox(height: 32),

                // PIN dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_maxLen, (i) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i < _pin.length
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outlineVariant,
                      ),
                    );
                  }),
                ),

                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ],

                const SizedBox(height: 32),

                // Numpad
                _Numpad(
                  onDigit: _onDigit,
                  onBack: _onBack,
                  onBiometric: _tryBiometric,
                  canBiometric: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Numpad extends StatelessWidget {
  const _Numpad({
    required this.onDigit,
    required this.onBack,
    required this.onBiometric,
    required this.canBiometric,
  });

  final ValueChanged<String> onDigit;
  final VoidCallback onBack;
  final VoidCallback onBiometric;
  final bool canBiometric;

  static const _rows = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final row in _rows)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row
                .map((d) => _DigitButton(digit: d, onPressed: () => onDigit(d)))
                .toList(),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _IconButton(
              icon: Icons.fingerprint,
              onPressed: onBiometric,
            ),
            _DigitButton(digit: '0', onPressed: () => onDigit('0')),
            _IconButton(
              icon: Icons.backspace_outlined,
              onPressed: onBack,
            ),
          ],
        ),
      ],
    );
  }
}

class _DigitButton extends StatelessWidget {
  const _DigitButton({required this.digit, required this.onPressed});

  final String digit;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 64,
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          digit,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 64,
      child: IconButton(
        icon: Icon(icon),
        onPressed: onPressed,
      ),
    );
  }
}

// ── PIN-setup bottom sheet ────────────────────────────────────────────────────

/// Shows a bottom sheet for the user to set a new PIN.
Future<bool> showSetPinSheet(BuildContext context) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => const _SetPinSheet(),
  );
  return result ?? false;
}

class _SetPinSheet extends StatefulWidget {
  const _SetPinSheet();

  @override
  State<_SetPinSheet> createState() => _SetPinSheetState();
}

class _SetPinSheetState extends State<_SetPinSheet> {
  final _lockService = AppLockService();
  String _pin = '';
  String _confirm = '';
  bool _confirming = false;
  String? _error;

  void _onDigit(String d) {
    if (!_confirming) {
      if (_pin.length >= 6) return;
      setState(() => _pin += d);
      if (_pin.length == 6) setState(() => _confirming = true);
    } else {
      if (_confirm.length >= 6) return;
      setState(() => _confirm += d);
      if (_confirm.length == 6) _save();
    }
  }

  void _onBack() {
    if (_confirming) {
      setState(() => _confirm = _confirm.isNotEmpty
          ? _confirm.substring(0, _confirm.length - 1)
          : _confirm);
    } else {
      setState(() =>
          _pin = _pin.isNotEmpty ? _pin.substring(0, _pin.length - 1) : _pin);
    }
  }

  Future<void> _save() async {
    if (_pin != _confirm) {
      setState(() {
        _error = AppLocalizations.of(context).pinLockMismatch;
        _confirm = '';
        _confirming = false;
      });
      return;
    }
    await _lockService.enablePin(_pin);
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final current = _confirming ? _confirm : _pin;

    return Padding(
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _confirming ? l10n.pinLockConfirm : l10n.pinLockEnterNew,
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(6, (i) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 6),
                width: 14, height: 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i < current.length
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outlineVariant,
                ),
              );
            }),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
          ],
          const SizedBox(height: 24),
          _Numpad(
            onDigit: _onDigit,
            onBack: _onBack,
            onBiometric: () {},
            canBiometric: false,
          ),
        ],
      ),
    );
  }
}

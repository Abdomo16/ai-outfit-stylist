import 'dart:async';

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/app_localizations.dart';

/// Names what the stylist is doing while an outfit is being built.
class StylingProgress extends StatefulWidget {
  final Color? textColor;

  const StylingProgress({super.key, this.textColor});

  @override
  State<StylingProgress> createState() => _StylingProgressState();
}

class _StylingProgressState extends State<StylingProgress> {
  static const _stepDuration = Duration(milliseconds: 1300);
  late final Timer _timer;
  int _step = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(_stepDuration, (_) {
      if (mounted) setState(() => _step++);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final steps = [l10n.stepWeather, l10n.stepPieces, l10n.stepColors];
    final text = steps[_step % steps.length];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: Text(
            text,
            key: ValueKey(text),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: widget.textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

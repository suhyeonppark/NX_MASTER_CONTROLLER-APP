import 'package:flutter/material.dart';

/// Modal progress dialog shown while a macro runs. A determinate bar fills over
/// [duration] (the macro's estimated total wait). When the bar reaches the end
/// but the macro is still finishing, it holds at 100% with a "마무리 중" label.
///
/// The dialog never closes itself — the caller pops it once the macro actually
/// completes (see `runActionWithFeedback`). It cannot be dismissed by tapping
/// outside or the back button so a half-run macro can't be abandoned mid-way.
class MacroProgressDialog extends StatefulWidget {
  const MacroProgressDialog({
    super.key,
    required this.label,
    required this.duration,
  });

  final String label;
  final Duration duration;

  @override
  State<MacroProgressDialog> createState() => _MacroProgressDialogState();
}

class _MacroProgressDialogState extends State<MacroProgressDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration <= Duration.zero
          ? const Duration(milliseconds: 700)
          : widget.duration,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalSeconds = widget.duration.inMilliseconds / 1000;
    return PopScope(
      canPop: false,
      child: AlertDialog(
        content: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final value = _controller.value;
            final done = value >= 1.0;
            final remaining =
                (totalSeconds * (1 - value)).clamp(0, totalSeconds);
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Icon(Icons.playlist_play, size: 26),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${widget.label} 실행 중...',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: value,
                    minHeight: 12,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  done
                      ? '마무리 중...'
                      : '${(value * 100).round()}%  ·  ${remaining.toStringAsFixed(1)}초 남음',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15, color: Color(0xFF7D848D)),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

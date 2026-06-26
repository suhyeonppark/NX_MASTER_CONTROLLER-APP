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

  // Quiet industrial palette, matching ControlButton.
  static const Color _accent = Color(0xFF356F62);
  static const Color _track = Color(0xFFE3E7EA);
  static const Color _ink = Color(0xFF20242B);
  static const Color _muted = Color(0xFF7D848D);

  @override
  Widget build(BuildContext context) {
    final totalSeconds = widget.duration.inMilliseconds / 1000;
    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final value = _controller.value;
              final done = value >= 1.0;
              final remaining = (totalSeconds * (1 - value)).ceil();
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 132,
                    height: 132,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox.expand(
                          child: CircularProgressIndicator(
                            value: done ? null : value,
                            strokeWidth: 9,
                            strokeCap: StrokeCap.round,
                            backgroundColor: _track,
                            valueColor:
                                const AlwaysStoppedAnimation<Color>(_accent),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${(value * 100).round()}',
                              style: const TextStyle(
                                fontSize: 38,
                                fontWeight: FontWeight.w800,
                                color: _ink,
                                height: 1.0,
                              ),
                            ),
                            const Text(
                              '%',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: _muted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    widget.label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: _ink,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    done ? '마무리 중...' : '$remaining초 남음',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 15, color: _muted),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

/// Continuously scrolls text like a news ticker when the content is wider
/// than the container. A second copy follows after a gap for a seamless loop,
/// with a 1.2 s pause at the start of each cycle. Renders as plain Text when
/// content fits — no second copy is rendered until overflow is confirmed.
class MarqueeText extends StatefulWidget {
  const MarqueeText({super.key, required this.text, this.style});

  final String text;
  final TextStyle? style;

  @override
  State<MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<MarqueeText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  final _scrollCtrl = ScrollController();
  final _textKey = GlobalKey();
  double _contentWidth = 0;
  double _containerWidth = 0;

  static const double _gap = 48;
  static const double _pixelsPerSecond = 35;

  bool get _overflows => _contentWidth > 0 && _contentWidth > _containerWidth;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 5));
    _ctrl.addListener(_onTick);
    WidgetsBinding.instance.addPostFrameCallback(_measure);
  }

  void _measure(_) {
    if (!mounted) return;
    final box = _textKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    final newContent = box.size.width;
    if (newContent == _contentWidth) return;

    final wasOverflowing = _overflows;
    _contentWidth = newContent;
    final isOverflowing = _overflows;

    // Rebuild to add or remove the second copy.
    if (wasOverflowing != isOverflowing) setState(() {});

    _ctrl.stop();
    if (isOverflowing) {
      _ctrl.reset();
      if (_scrollCtrl.hasClients) _scrollCtrl.jumpTo(0);
      final durationMs =
          ((_contentWidth + _gap) / _pixelsPerSecond * 1000).round();
      _ctrl.duration = Duration(milliseconds: durationMs);
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted && _overflows) _startCycle();
      });
    }
  }

  void _startCycle() {
    if (!mounted || !_overflows) return;
    _ctrl.forward(from: 0).then((_) {
      if (!mounted || !_overflows) return;
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted && _overflows) _startCycle();
      });
    });
  }

  void _onTick() {
    if (!_scrollCtrl.hasClients) return;
    final pos = _ctrl.value * (_contentWidth + _gap);
    _scrollCtrl.jumpTo(pos.clamp(0, _scrollCtrl.position.maxScrollExtent));
  }

  @override
  void didUpdateWidget(MarqueeText old) {
    super.didUpdateWidget(old);
    if (old.text != widget.text) {
      _ctrl.stop();
      _ctrl.reset();
      if (_scrollCtrl.hasClients) _scrollCtrl.jumpTo(0);
      _contentWidth = 0;
      WidgetsBinding.instance.addPostFrameCallback(_measure);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        _containerWidth = constraints.maxWidth;
        return SingleChildScrollView(
          controller: _scrollCtrl,
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          child: Row(
            children: [
              Text(widget.text, key: _textKey, style: widget.style, maxLines: 1),
              if (_overflows) ...[
                const SizedBox(width: _gap),
                Text(widget.text, style: widget.style, maxLines: 1),
              ],
            ],
          ),
        );
      },
    );
  }
}

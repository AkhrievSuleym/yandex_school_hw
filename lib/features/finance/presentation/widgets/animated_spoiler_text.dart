import 'package:flutter/material.dart';

class AnimatedSpoilerText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final bool isBlurred; // Флаг, который определяет, скрыт текст или нет
  final Duration animationDuration;
  final Color blurColor; // Цвет, которым "закрашивается" текст

  const AnimatedSpoilerText({
    super.key,
    required this.text,
    this.style,
    required this.isBlurred,
    this.animationDuration = const Duration(milliseconds: 300),
    this.blurColor = Colors.grey, // Дефолтный серый цвет для скрытия
  });

  @override
  State<AnimatedSpoilerText> createState() => _AnimatedSpoilerTextState();
}

class _AnimatedSpoilerTextState extends State<AnimatedSpoilerText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation; // Анимация для "эффекта спойлера"

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    // Анимация от 0 (полностью закрашен) до 1 (полностью виден)
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    if (!widget.isBlurred) {
      _controller.forward(); // Если не скрыт, сразу показать
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedSpoilerText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isBlurred != oldWidget.isBlurred) {
      if (widget.isBlurred) {
        _controller.reverse(); // Скрыть
      } else {
        _controller.forward(); // Показать
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final overlayColor = Color.lerp(
          widget.blurColor,
          widget.blurColor.withOpacity(
            0.0,
          ), // От полностью непрозрачного до прозрачного
          _animation
              .value, // Когда _animation.value = 0, overlayColor = blurColor. Когда 1, overlayColor = transparent.
        )!;

        return ShaderMask(
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              colors: [overlayColor, overlayColor],
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop, // Накладываем цвет поверх текста
          child: Text(widget.text, style: widget.style),
        );
      },
    );
  }
}

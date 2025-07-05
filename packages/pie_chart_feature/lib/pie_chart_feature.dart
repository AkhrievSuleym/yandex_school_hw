import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:intl/intl.dart';

/// Класс для конфигурации одной секции круговой диаграммы.
class PieChartSectionDataConfig {
  final double value;
  final String title;
  final Color color;
  final String? tooltipLabel; // Подпись для тултипа
  final IconData? icon;

  PieChartSectionDataConfig({
    required this.value,
    required this.title,
    required this.color,
    this.tooltipLabel,
    this.icon,
  });
}

/// Виджет, который отображает анимированную круговую диаграмму.
class AnimatedPieChart extends StatefulWidget {
  final List<PieChartSectionDataConfig> data;
  final double radius;
  final String centerValueText;
  final TextStyle? centerTextStyle;
  final Duration animationDuration;

  const AnimatedPieChart({
    super.key,
    required this.data,
    this.radius = 150,
    this.centerValueText = '',
    this.centerTextStyle,
    this.animationDuration = const Duration(milliseconds: 700),
  });

  @override
  State<AnimatedPieChart> createState() => _AnimatedPieChartState();
}

class _AnimatedPieChartState extends State<AnimatedPieChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _fadeAnimation;

  int _touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutBack, // Немного более выраженная кривая
      ),
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(
          0.0,
          0.5,
          curve: Curves.easeOut,
        ), // Fade out в первой половине
      ),
    );

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.reset(); // Сброс для следующего запуска
        setState(() {
          // Принудительная перерисовка, чтобы убедиться, что новый график отрисовался
          _touchedIndex = -1;
        });
      }
    });
  }

  @override
  void didUpdateWidget(covariant AnimatedPieChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      _animationController.forward(
        from: 0.0,
      ); // Запускаем анимацию при изменении данных
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return Center(
        child: Text(
          'Нет данных для отображения графика',
          style:
              widget.centerTextStyle ?? Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
      );
    }

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final double currentRotation = _rotationAnimation.value;
        final double currentFade = _fadeAnimation.value;

        // Определяем, какую часть анимации мы сейчас проигрываем.
        // Если мы в первой половине (fade out), отображаем старый контент с уменьшающейся прозрачностью.
        // Если мы во второй половине (fade in), отображаем новый контент с увеличивающейся прозрачностью.
        final bool isFadingOut = _animationController.value <= 0.5;
        final double effectiveFade =
            isFadingOut ? currentFade : (1.0 - currentFade);

        return Opacity(
          opacity: effectiveFade.clamp(
            0.0,
            1.0,
          ), // Гарантируем значения от 0 до 1
          child: Transform.rotate(
            angle: currentRotation,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (
                        FlTouchEvent event,
                        PieTouchResponse? pieTouchResponse,
                      ) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              pieTouchResponse == null ||
                              pieTouchResponse.touchedSection == null) {
                            _touchedIndex = -1; // Сбрасываем, если нет касания
                            return;
                          }
                          _touchedIndex = pieTouchResponse
                              .touchedSection!.touchedSectionIndex;
                        });
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 0,
                    centerSpaceRadius:
                        widget.radius - 5, // Пространство в центре
                    sections: List.generate(widget.data.length, (i) {
                      final isTouched = i == _touchedIndex;
                      final double radius = isTouched
                          ? widget.radius + 10
                          : widget.radius; // Увеличиваем радиус при касании
                      final config = widget.data[i];

                      final String titleText = isTouched
                          ? '${(config.value / widget.data.map((e) => e.value).fold(0.0, (prev, curr) => prev + curr) * 100).toStringAsFixed(0)}%'
                          : ''; // Пустая строка для скрытия текста

                      return PieChartSectionData(
                        color: config.color,
                        value: config.value,
                        title: titleText,
                        radius: radius,
                        titleStyle: TextStyle(
                          fontSize: isTouched ? 25 : 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // Цвет текста внутри секций
                          shadows: [Shadow(color: Colors.black, blurRadius: 2)],
                        ),
                        // Добавим тултип, если есть данные
                        badgeWidget: isTouched && config.tooltipLabel != null
                            ? _PieChartTooltip(
                                label: config.tooltipLabel!,
                                value: config.value,
                                totalValue: widget.data
                                    .map((e) => e.value)
                                    .fold(0.0, (prev, curr) => prev + curr),
                              )
                            : null,
                        badgePositionPercentageOffset: 1.05, // Позиция тултипа
                      );
                    }).toList(),
                  ),
                  swapAnimationDuration:
                      Duration.zero, // Анимация через AnimatedBuilder
                  swapAnimationCurve: Curves.linear,
                ),
                Text(
                  widget.centerValueText,
                  style: widget.centerTextStyle ??
                      Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Пример кастомного тултипа
class _PieChartTooltip extends StatelessWidget {
  final String label;
  final double value;
  final double totalValue;

  const _PieChartTooltip({
    required this.label,
    required this.value,
    required this.totalValue,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (value / totalValue * 100).toStringAsFixed(2);
    final formattedValue = NumberFormat.currency(
      locale: 'ru_RU',
      symbol: '₽',
      decimalDigits: 2,
    ).format(value);

    return Material(
      color: Colors.black.withOpacity(0.7),
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$percentage%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 20),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              formattedValue,
              style: const TextStyle(color: Colors.white, fontSize: 20),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

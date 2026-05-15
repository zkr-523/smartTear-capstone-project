import 'package:flutter/material.dart';

import 'design_system.dart';

enum AnalyteStatus { low, normal, high }

class AnalyteCard extends StatelessWidget {
  const AnalyteCard({
    super.key,
    required this.name,
    required this.value,
    required this.unit,
    required this.normalMin,
    required this.normalMax,
  });

  final String name;
  final double value;
  final String unit;
  final double normalMin;
  final double normalMax;

  AnalyteStatus get status {
    if (value < normalMin) return AnalyteStatus.low;
    if (value > normalMax) return AnalyteStatus.high;
    return AnalyteStatus.normal;
  }

  Color get _statusColor => switch (status) {
        AnalyteStatus.normal => SmartTearColors.rangeNormal,
        AnalyteStatus.high => SmartTearColors.rangeHigh,
        AnalyteStatus.low => SmartTearColors.rangeLow,
      };

  Color get _chipBg => switch (status) {
        AnalyteStatus.normal => SmartTearColors.statusValidBg,
        AnalyteStatus.high => SmartTearColors.statusInvalidBg,
        AnalyteStatus.low => SmartTearColors.statusWarningBg,
      };

  String get _chipText => switch (status) {
        AnalyteStatus.normal => '● Normal',
        AnalyteStatus.high => '▲ High',
        AnalyteStatus.low => '▼ Low',
      };

  String _fmt(double v) {
    final use1 = normalMax <= 10 || unit.toLowerCase().contains('mmol');
    return v.toStringAsFixed(use1 ? 1 : 0);
  }

  String get _explanation {
    final n = name.toLowerCase();
    if (n.contains('glucose')) {
      return switch (status) {
        AnalyteStatus.normal => 'Tear glucose within expected range.',
        AnalyteStatus.high =>
          'Elevated tear glucose. May correlate with higher blood glucose. Consult your doctor.',
        AnalyteStatus.low =>
          'Low tear glucose. Ensure proper sample collection and retake if needed.',
      };
    }
    if (n.contains('sodium')) {
      return switch (status) {
        AnalyteStatus.high =>
          'Elevated sodium may indicate dehydration or dry eye. Stay hydrated.',
        AnalyteStatus.low => 'Low sodium in tears. Retake recommended.',
        AnalyteStatus.normal => 'Sodium within expected range.',
      };
    }
    if (n.contains('potassium')) {
      return switch (status) {
        AnalyteStatus.high =>
          'Elevated potassium. Monitor and consult doctor if persistent.',
        AnalyteStatus.low =>
          'Low potassium. Ensure adequate sample volume.',
        AnalyteStatus.normal => 'Potassium within expected range.',
      };
    }
    if (n.contains('chloride')) {
      return switch (status) {
        AnalyteStatus.high => 'Elevated chloride, mirrors sodium changes.',
        AnalyteStatus.low => 'Low chloride. Retake if reading is invalid.',
        AnalyteStatus.normal => 'Chloride within expected range.',
      };
    }
    if (n.contains('chol')) {
      return switch (status) {
        AnalyteStatus.high =>
          'Elevated tear cholesterol may relate to meibomian gland function. Consult doctor.',
        AnalyteStatus.low => 'Low cholesterol in tears. Within safe range.',
        AnalyteStatus.normal => 'Cholesterol within expected range.',
      };
    }
    return 'Within expected range.';
  }

  @override
  Widget build(BuildContext context) {
    final valueText = value.isFinite ? _fmt(value) : value.toString();

    final min = normalMin;
    final max = normalMax;
    final range = (max - min).abs() < 1e-9 ? 1.0 : (max - min);
    final tRaw = (value - min) / range;
    final t = tRaw.clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(SmartTearSpacing.md),
      decoration: BoxDecoration(
        color: SmartTearColors.surface,
        borderRadius: BorderRadius.circular(SmartTearRadius.card),
        border: Border.all(color: SmartTearColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(name, style: SmartTearText.title.copyWith(fontSize: 16)),
              ),
              Text(
                valueText,
                style: SmartTearText.mono.copyWith(fontSize: 18),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(unit, style: SmartTearText.label.copyWith(fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _chipBg,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                _chipText,
                style: SmartTearText.label.copyWith(
                  fontWeight: FontWeight.w700,
                  color: _statusColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: SmartTearSpacing.sm + 4),
          LayoutBuilder(
            builder: (context, c) {
              final w = c.maxWidth;
              final dotX = (t * w).clamp(0.0, w);
              final fillW = dotX;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Stack(
                    children: [
                      Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: SmartTearColors.rangeBg,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      Container(
                        height: 6,
                        width: fillW,
                        decoration: BoxDecoration(
                          color: _statusColor,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      Positioned(
                        left: dotX - 5,
                        top: -2,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: SmartTearColors.surface,
                            shape: BoxShape.circle,
                            border: Border.all(color: _statusColor, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: SmartTearSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Low < ${_fmt(normalMin)}',
                          style: SmartTearText.micro,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Normal ${_fmt(normalMin)}–${_fmt(normalMax)}',
                          textAlign: TextAlign.center,
                          style: SmartTearText.micro,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'High > ${_fmt(normalMax)}',
                          textAlign: TextAlign.right,
                          style: SmartTearText.micro,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: SmartTearSpacing.sm + 4),
          Text(
            _explanation,
            style: SmartTearText.micro.copyWith(fontSize: 12.5, height: 1.35),
          ),
        ],
      ),
    );
  }
}

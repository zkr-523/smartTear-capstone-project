import 'package:flutter/material.dart';

/// Teal card for ML estimated blood glucose (mmol/L + mg/dL).
class EstimatedBgCard extends StatelessWidget {
  const EstimatedBgCard({
    super.key,
    required this.bgMmol,
    this.compact = false,
  });

  final double bgMmol;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final mgDl = bgMmol * 18.0;

    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0x4400D4C8)),
          borderRadius: BorderRadius.circular(10),
          color: const Color(0x1A00D4C8),
        ),
        child: Row(
          children: [
            const Icon(Icons.show_chart, color: Color(0xFF00D4C8), size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'EST. BLOOD GLUCOSE',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF00D4C8),
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${bgMmol.toStringAsFixed(1)} mmol/L · ${mgDl.toStringAsFixed(0)} mg/dL',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF00D4C8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0x4400D4C8), width: 1),
        borderRadius: BorderRadius.circular(12),
        color: const Color(0x1A00D4C8),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.show_chart, color: Color(0xFF00D4C8), size: 16),
              SizedBox(width: 8),
              Text(
                'ESTIMATED BLOOD GLUCOSE',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF00D4C8),
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                bgMmol.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF00D4C8),
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'mmol/L',
                style: TextStyle(fontSize: 13, color: Color(0xFF7FA8C0)),
              ),
              const Spacer(),
              Text(
                '${mgDl.toStringAsFixed(0)} mg/dL',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF00D4C8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'ML estimate from tear glucose · Park et al. 2024',
            style: TextStyle(fontSize: 10, color: Color(0xFF4A7090)),
          ),
          const SizedBox(height: 2),
          const Text(
            'Estimation only — not a clinical blood glucose measurement.',
            style: TextStyle(
              fontSize: 10,
              color: Color(0xFF4A7090),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

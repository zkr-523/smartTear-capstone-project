import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/design_system.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late final Animation<double> _scale;
  Timer? _navTimer;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );

    _navTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      context.go('/auth/login');
    });
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SmartTearColors.bgDeep,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _scale,
              builder: (context, _) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0x2200D4C8),
                          width: 1,
                        ),
                      ),
                    ),
                    Transform.scale(
                      scale: _scale.value,
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0x4400D4C8),
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF112236),
                        border: Border.all(
                          color: const Color(0xFF00D4C8),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00D4C8).withOpacity(0.35),
                            blurRadius: 20,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.water_drop_rounded,
                        size: 32,
                        color: Color(0xFF00D4C8),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Smart',
                  style: SmartTearText.headline.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: SmartTearColors.textPrimary,
                  ),
                ),
                Text(
                  'Tear',
                  style: SmartTearText.headline.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: SmartTearColors.teal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Tear Biomarker Analysis',
              style: SmartTearText.tag,
            ),
          ],
        ),
      ),
    );
  }
}

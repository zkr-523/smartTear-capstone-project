import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

import '../widgets/design_system.dart';

/// Must match [kOnboardingCompleteKey] in `app_router.dart`.
const _onboardingCompleteStorageKey = 'onboarding_complete';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  late final AnimationController _float;
  late final Animation<double> _drift;
  int _page = 0;

  static const _storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _float = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _drift = Tween<double>(begin: -4, end: 4).animate(
      CurvedAnimation(parent: _float, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _float.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finishOnboarding() async {
    try {
      await _storage.write(key: _onboardingCompleteStorageKey, value: 'true');
    } catch (_) {}
    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: SmartTearColors.bgDeep,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _page = i),
                children: [
                  _OnboardingPage1(floatAnim: _drift),
                  const _OnboardingPage2(),
                  const _OnboardingPage3(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 0),
              child: Row(
                children: [
                  _PageDots(activeIndex: _page, count: 3),
                  const Spacer(),
                  if (_page < 2)
                    TextButton(
                      onPressed: _finishOnboarding,
                      child: Text(
                        'Skip',
                        style: SmartTearText.body.copyWith(
                          color: SmartTearColors.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  else
                    SizedBox(
                      width: 140,
                      child: TealButton(
                        label: 'Get Started',
                        expandWidth: false,
                        onPressed: _finishOnboarding,
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 32 + bottomInset),
          ],
        ),
      ),
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({required this.activeIndex, required this.count});

  final int activeIndex;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (i) {
        final active = i == activeIndex;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Container(
            width: active ? 8 : 6,
            height: active ? 8 : 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active
                  ? SmartTearColors.teal
                  : Colors.white.withOpacity(0.2),
            ),
          ),
        );
      }),
    );
  }
}

/// Concentric rings + center icon (splash proportions; [large] for 64px icons).
class _BrandRings extends StatelessWidget {
  const _BrandRings({
    required this.icon,
    required this.iconSize,
    this.pulseScale = 1.0,
    this.large = false,
  });

  final IconData icon;
  final double iconSize;
  final double pulseScale;
  final bool large;

  double get _outer => large ? 168 : 120;
  double get _mid => large ? 126 : 90;
  double get _inner => large ? 88 : 64;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: _outer,
          height: _outer,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0x2200D4C8), width: 1),
          ),
        ),
        Transform.scale(
          scale: pulseScale,
          child: Container(
            width: _mid,
            height: _mid,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0x4400D4C8), width: 1),
            ),
          ),
        ),
        Container(
          width: _inner,
          height: _inner,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF112236),
            border: Border.all(color: const Color(0xFF00D4C8), width: 1),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00D4C8).withOpacity(0.35),
                blurRadius: 20,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Icon(icon, size: iconSize, color: SmartTearColors.teal),
        ),
      ],
    );
  }
}

class _OnboardingPage1 extends StatefulWidget {
  const _OnboardingPage1({required this.floatAnim});

  final Animation<double> floatAnim;

  @override
  State<_OnboardingPage1> createState() => _OnboardingPage1State();
}

class _OnboardingPage1State extends State<_OnboardingPage1>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late final Animation<double> _scale;

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
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final h = constraints.maxHeight;
        final topH = h * 0.6;
        final bottomH = h * 0.4;

        return Column(
          children: [
            SizedBox(
              height: topH,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _scale,
                      builder: (context, _) {
                        return _BrandRings(
                          icon: Icons.water_drop_rounded,
                          iconSize: 64,
                          large: true,
                          pulseScale: _scale.value,
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    AnimatedBuilder(
                      animation: widget.floatAnim,
                      builder: (context, _) {
                        return Transform.translate(
                          offset: Offset(0, widget.floatAnim.value),
                          child: Text(
                            'Basal Tear Collection',
                            style: SmartTearText.label.copyWith(
                              color: SmartTearColors.teal,
                              letterSpacing: 0.8,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: bottomH,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Non-Invasive',
                      style: SmartTearText.headline,
                    ),
                    Text(
                      'Health Monitoring',
                      style: SmartTearText.headline.copyWith(
                        color: SmartTearColors.teal,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'A gentle touch of the sensor tip collects '
                      'tear fluid instantly — no needles, no pain.',
                      style: SmartTearText.body.copyWith(
                        color: SmartTearColors.textSecond,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _OnboardingPage2 extends StatefulWidget {
  const _OnboardingPage2();

  @override
  State<_OnboardingPage2> createState() => _OnboardingPage2State();
}

class _OnboardingPage2State extends State<_OnboardingPage2>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late final Animation<double> _scale;

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
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const Spacer(),
          AnimatedBuilder(
            animation: _scale,
            builder: (context, _) {
              return _BrandRings(
                icon: Icons.analytics_rounded,
                iconSize: 64,
                large: true,
                pulseScale: _scale.value,
              );
            },
          ),
          const SizedBox(height: 32),
          Text('AI-Powered', style: SmartTearText.headline),
          Text(
            'Analysis',
            style: SmartTearText.headline.copyWith(
              color: SmartTearColors.teal,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Three neural networks analyze your tear '
            'chemistry in seconds, entirely on your device.',
            textAlign: TextAlign.center,
            style: SmartTearText.body.copyWith(
              color: SmartTearColors.textSecond,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class _OnboardingPage3 extends StatefulWidget {
  const _OnboardingPage3();

  @override
  State<_OnboardingPage3> createState() => _OnboardingPage3State();
}

class _OnboardingPage3State extends State<_OnboardingPage3>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late final Animation<double> _scale;

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
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const Spacer(),
          AnimatedBuilder(
            animation: _scale,
            builder: (context, _) {
              return _BrandRings(
                icon: Icons.insights_rounded,
                iconSize: 64,
                large: true,
                pulseScale: _scale.value,
              );
            },
          ),
          const SizedBox(height: 32),
          Text('Your Health', style: SmartTearText.headline),
          Text(
            'Decoded',
            style: SmartTearText.headline.copyWith(
              color: SmartTearColors.teal,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Track glucose, electrolytes, and cholesterol '
            'trends over time with clear visual insights.',
            textAlign: TextAlign.center,
            style: SmartTearText.body.copyWith(
              color: SmartTearColors.textSecond,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

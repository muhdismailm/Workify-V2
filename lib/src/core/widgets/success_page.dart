import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A full-screen animated success confirmation page.
///
/// [title]        — headline text, supports newlines.
/// [primaryLabel] — label for the filled action button.
/// [primaryIcon]  — icon for the action button.
/// [primaryColor] — fill colour for the action button.
/// [onPrimary]    — optional callback when action button is tapped.
/// [onHome]       — callback when "Back to Home" is tapped.
class SuccessPage extends StatefulWidget {
  final String title;
  final String primaryLabel;
  final IconData primaryIcon;
  final Color primaryColor;
  final VoidCallback? onPrimary;
  final VoidCallback onHome;

  const SuccessPage({
    super.key,
    required this.title,
    required this.primaryLabel,
    required this.primaryIcon,
    required this.primaryColor,
    this.onPrimary,
    required this.onHome,
  });

  @override
  State<SuccessPage> createState() => _SuccessPageState();
}

class _SuccessPageState extends State<SuccessPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 750));
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // ── Animated checkmark + burst ─────────────────────────────
              ScaleTransition(
                scale: _scale,
                child: _CheckBurst(color: widget.primaryColor),
              ),

              const SizedBox(height: 44),

              // ── Title ──────────────────────────────────────────────────
              FadeTransition(
                opacity: _fade,
                child: Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E),
                    height: 1.4,
                  ),
                ),
              ),

              const Spacer(flex: 2),

              // ── Primary action button ──────────────────────────────────
              FadeTransition(
                opacity: _fade,
                child: _FilledBtn(
                  label: widget.primaryLabel,
                  icon: widget.primaryIcon,
                  color: widget.primaryColor,
                  onTap: widget.onPrimary ?? () {},
                ),
              ),

              const SizedBox(height: 16),

              // ── Back to Home ───────────────────────────────────────────
              FadeTransition(
                opacity: _fade,
                child: _OutlineBtn(onTap: widget.onHome),
              ),

              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Checkmark + burst dots ─────────────────────────────────────────────────────

class _CheckBurst extends StatelessWidget {
  final Color color;
  const _CheckBurst({required this.color});

  @override
  Widget build(BuildContext context) {
    const total  = 8;
    const radius = 82.0;
    const big    = 10.0;
    const small  = 7.0;

    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Burst dots
          for (int i = 0; i < total; i++) ...[
            _dot(
              angle: (2 * math.pi / total) * i,
              dist: radius,
              size: i.isEven ? big : small,
            ),
          ],
          // Checkmark circle
          Container(
            width: 96,
            height: 96,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF4CAF50),
              boxShadow: [
                BoxShadow(
                  color: Color(0x554CAF50),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(Icons.check_rounded,
                color: Colors.white, size: 56),
          ),
        ],
      ),
    );
  }

  Widget _dot({required double angle, required double dist, required double size}) {
    const cx = 100.0;
    const cy = 100.0;
    final x = cx + dist * math.cos(angle) - size / 2;
    final y = cy + dist * math.sin(angle) - size / 2;
    return Positioned(
      left: x,
      top: y,
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: Color(0xFF4CAF50),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

// ── Filled gradient button ─────────────────────────────────────────────────────

class _FilledBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _FilledBtn({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 58,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withValues(alpha: 0.78)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.35),
              blurRadius: 18,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: Colors.white24),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3)),
          ],
        ),
      ),
    );
  }
}

// ── Outline button ─────────────────────────────────────────────────────────────

class _OutlineBtn extends StatelessWidget {
  final VoidCallback onTap;
  const _OutlineBtn({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 58,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: const Color(0xFFDDDDDD), width: 1.5),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Back to Home',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A2E))),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward, size: 18, color: Color(0xFF1A1A2E)),
          ],
        ),
      ),
    );
  }
}

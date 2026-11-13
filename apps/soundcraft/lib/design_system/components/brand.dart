import 'package:flutter/material.dart';

import 'package:soundcraft/design_system/tokens.dart';

/// Brand mark (P00 decision): the owner-approved concept image was NOT
/// available at implementation time, so this is a clearly-labelled DRAFT
/// original cricket-with-guitar mark drawn programmatically (no frog, no
/// borrowed assets). The final artwork swap is owner action queue item #1.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 32, this.showWave = true});
  final double size;
  final bool showWave;

  @override
  Widget build(BuildContext context) {
    final c = context.scColors;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CricketMarkPainter(
          primary: c.brandPrimary,
          deep: c.brandDeep,
          warm: c.brandWarm,
          wave: showWave,
        ),
      ),
    );
  }
}

class _CricketMarkPainter extends CustomPainter {
  _CricketMarkPainter({
    required this.primary,
    required this.deep,
    required this.warm,
    required this.wave,
  });

  final Color primary;
  final Color deep;
  final Color warm;
  final bool wave;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    // Background disc
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      s / 2,
      Paint()..color = deep,
    );

    final body = Paint()..color = primary;
    final cx = size.width * 0.42;
    final cy = size.height * 0.56;

    // Body (elongated cricket silhouette, antennae, not a frog).
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(cx, cy),
        width: s * 0.16,
        height: s * 0.42,
      ),
      Radius.circular(s * 0.08),
    );
    canvas.drawRRect(bodyRect, body);

    // Head
    canvas.drawCircle(Offset(cx, cy - s * 0.21), s * 0.09, body);

    // Antennae (two long curves — the cricket identity marker).
    final antenna = Paint()
      ..color = primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.025
      ..strokeCap = StrokeCap.round;
    final head = Offset(cx, cy - s * 0.27);
    canvas.drawPath(
      Path()
        ..moveTo(head.dx - s * 0.02, head.dy)
        ..quadraticBezierTo(
          cx - s * 0.14,
          cy - s * 0.5,
          cx - s * 0.24,
          cy - s * 0.52,
        ),
      antenna,
    );
    canvas.drawPath(
      Path()
        ..moveTo(head.dx + s * 0.02, head.dy)
        ..quadraticBezierTo(
          cx + s * 0.10,
          cy - s * 0.52,
          cx + s * 0.20,
          cy - s * 0.56,
        ),
      antenna,
    );

    // Hind leg (long bent leg — species detail per §2.1).
    canvas.drawPath(
      Path()
        ..moveTo(cx + s * 0.02, cy + s * 0.05)
        ..lineTo(cx + s * 0.14, cy - s * 0.02)
        ..lineTo(cx + s * 0.12, cy + s * 0.14),
      antenna..strokeWidth = s * 0.03,
    );

    // Guitar body (warm wood accent).
    final guitarPaint = Paint()..color = warm;
    canvas.drawCircle(
      Offset(cx + s * 0.2, cy + s * 0.16),
      s * 0.085,
      guitarPaint,
    );
    canvas.drawCircle(
      Offset(cx + s * 0.2, cy + s * 0.16),
      s * 0.035,
      Paint()..color = deep,
    );
    // Guitar neck (string line).
    canvas.drawLine(
      Offset(cx + s * 0.24, cy + s * 0.10),
      Offset(cx - s * 0.10, cy - s * 0.20),
      antenna..strokeWidth = s * 0.02,
    );

    // Soundwave (green notes/waves rising from the guitar).
    if (wave) {
      final wavePaint = Paint()
        ..color = primary.withValues(alpha: 0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.03
        ..strokeCap = StrokeCap.round;
      for (var i = 0; i < 3; i++) {
        final x = size.width * (0.70 + i * 0.08);
        final h = s * (0.10 + i * 0.05);
        canvas.drawLine(
          Offset(x, size.height * 0.5 - h / 2),
          Offset(x, size.height * 0.5 + h / 2),
          wavePaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CricketMarkPainter old) =>
      old.primary != primary || old.deep != deep || old.warm != warm;
}

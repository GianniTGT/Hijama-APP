import 'package:flutter/material.dart';
import '../services/localization_service.dart';

/// Normalized positions (0.0–1.0) for each cupping point on the body diagram.
/// x: left=0, right=1 (on the back-view silhouette)
/// y: top=0, bottom=1
const Map<String, Offset> _pointPositions = {
  'kahil':         Offset(0.50, 0.18), // Al-Kahil — nape/upper back
  'akhday_left':   Offset(0.40, 0.15), // Left jugular vein
  'akhday_right':  Offset(0.60, 0.15), // Right jugular vein
  'qamahduwa':     Offset(0.50, 0.13), // Back of head
  'hamah':         Offset(0.50, 0.10), // Top of head
  'back_upper':    Offset(0.50, 0.24), // Upper back
  'back_mid':      Offset(0.50, 0.32), // Mid back
  'back_lower':    Offset(0.50, 0.40), // Lower back
};

class BodyPointsPainter extends CustomPainter {
  const BodyPointsPainter({
    required this.points,
    this.selectedId,
  });

  final List<CuppingPoint> points;
  final String? selectedId;

  static const double _dotRadius = 10.0;
  static const double _selectedRadius = 14.0;

  @override
  void paint(Canvas canvas, Size size) {
    _drawSilhouette(canvas, size);

    for (final point in points) {
      final pos = _pointPositions[point.id];
      if (pos == null) continue;

      final x = pos.dx * size.width;
      final y = pos.dy * size.height;
      final center = Offset(x, y);
      final isSelected = point.id == selectedId;
      final radius = isSelected ? _selectedRadius : _dotRadius;

      // Glow ring for selected
      if (isSelected) {
        canvas.drawCircle(
          center,
          radius + 5,
          Paint()
            ..color = const Color(0xFF2D7A4A).withOpacity(0.3)
            ..style = PaintingStyle.fill,
        );
      }

      // Dot
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = point.isSunnah
              ? const Color(0xFF1A4A2E)
              : const Color(0xFFC4922A)
          ..style = PaintingStyle.fill,
      );

      // White border
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );

      // Label
      if (isSelected) {
        _drawLabel(canvas, size, center, point.name, radius);
      }
    }
  }

  void _drawSilhouette(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE8F0EC)
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    // Simple human back-view silhouette using paths
    final path = Path();

    // Head (circle approximation)
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.07),
        width: w * 0.14,
        height: h * 0.10,
      ),
      paint,
    );

    // Neck
    canvas.drawRect(
      Rect.fromLTWH(w * 0.46, h * 0.11, w * 0.08, h * 0.04),
      paint,
    );

    // Torso
    path.reset();
    path.moveTo(w * 0.30, h * 0.15); // left shoulder
    path.lineTo(w * 0.70, h * 0.15); // right shoulder
    path.lineTo(w * 0.65, h * 0.55); // right hip
    path.lineTo(w * 0.35, h * 0.55); // left hip
    path.close();
    canvas.drawPath(path, paint);

    // Left arm
    final leftArm = Path()
      ..moveTo(w * 0.30, h * 0.15)
      ..lineTo(w * 0.18, h * 0.18)
      ..lineTo(w * 0.16, h * 0.42)
      ..lineTo(w * 0.22, h * 0.43)
      ..lineTo(w * 0.25, h * 0.20)
      ..lineTo(w * 0.35, h * 0.17)
      ..close();
    canvas.drawPath(leftArm, paint);

    // Right arm
    final rightArm = Path()
      ..moveTo(w * 0.70, h * 0.15)
      ..lineTo(w * 0.82, h * 0.18)
      ..lineTo(w * 0.84, h * 0.42)
      ..lineTo(w * 0.78, h * 0.43)
      ..lineTo(w * 0.75, h * 0.20)
      ..lineTo(w * 0.65, h * 0.17)
      ..close();
    canvas.drawPath(rightArm, paint);

    // Left leg
    final leftLeg = Path()
      ..moveTo(w * 0.35, h * 0.55)
      ..lineTo(w * 0.50, h * 0.55)
      ..lineTo(w * 0.50, h * 0.90)
      ..lineTo(w * 0.38, h * 0.90)
      ..close();
    canvas.drawPath(leftLeg, paint);

    // Right leg
    final rightLeg = Path()
      ..moveTo(w * 0.50, h * 0.55)
      ..lineTo(w * 0.65, h * 0.55)
      ..lineTo(w * 0.62, h * 0.90)
      ..lineTo(w * 0.50, h * 0.90)
      ..close();
    canvas.drawPath(rightLeg, paint);

    // Outline
    final outline = Paint()
      ..color = const Color(0xFF2D7A4A).withOpacity(0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.07),
        width: w * 0.14,
        height: h * 0.10,
      ),
      outline,
    );
  }

  void _drawLabel(Canvas canvas, Size size, Offset center, String text, double radius) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Color(0xFF1A4A2E),
          fontSize: 11,
          fontWeight: FontWeight.w600,
          backgroundColor: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width * 0.4);

    final labelOffset = Offset(
      (center.dx + radius + 4).clamp(0, size.width - tp.width),
      center.dy - tp.height / 2,
    );
    tp.paint(canvas, labelOffset);
  }

  @override
  bool shouldRepaint(BodyPointsPainter old) =>
      old.selectedId != selectedId || old.points != points;

  /// Returns the point id at the tapped position, or null.
  static String? hitTest(Offset tap, Size size, List<CuppingPoint> points) {
    for (final point in points) {
      final pos = _pointPositions[point.id];
      if (pos == null) continue;
      final center = Offset(pos.dx * size.width, pos.dy * size.height);
      if ((tap - center).distance <= 20) return point.id;
    }
    return null;
  }
}

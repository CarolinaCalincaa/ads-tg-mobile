import 'package:flutter/material.dart';

/// Símbolo / Ícone oficial do aplicativo Eixo (Raio estilizado em squircle).
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.size = 64.0,
    this.showShadow = true,
  });

  /// Dimensão quadrada (largura e altura) do símbolo.
  final double size;

  /// Se deve exibir a sombra difusa suave abaixo do squircle.
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    final double radius = size * 0.30;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[
            Color(0xFF6366F1), // Indigo 500
            Color(0xFF4F46E5), // Indigo 600
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.25),
          width: size >= 48 ? 1.5 : 1.0,
        ),
        boxShadow: showShadow
            ? <BoxShadow>[
                BoxShadow(
                  color: const Color(0xFF4F46E5).withValues(alpha: 0.35),
                  blurRadius: size * 0.3,
                  offset: Offset(0, size * 0.1),
                ),
              ]
            : null,
      ),
      child: Center(
        child: CustomPaint(
          size: Size(size * 0.65, size * 0.65),
          painter: _LightningBoltPainter(
            color: Colors.white,
            strokeWidth: (size * 0.05).clamp(2.0, 4.0),
          ),
        ),
      ),
    );
  }
}

/// Painter vetorial que desenha o contorno do raio do Eixo com precisão pixel-perfect.
class _LightningBoltPainter extends CustomPainter {
  const _LightningBoltPainter({
    required this.color,
    required this.strokeWidth,
  });

  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final double w = size.width;
    final double h = size.height;

    // Traçado do contorno do raio estilizado
    final Path path = Path()
      ..moveTo(w * 0.54, h * 0.12) // Topo
      ..lineTo(w * 0.28, h * 0.52) // Diagonal descendo para a esquerda
      ..lineTo(w * 0.46, h * 0.52) // Passo horizontal para o centro
      ..lineTo(w * 0.38, h * 0.88) // Diagonal descendo até a ponta inferior
      ..lineTo(w * 0.72, h * 0.44) // Diagonal subindo para a direita
      ..lineTo(w * 0.54, h * 0.44) // Passo horizontal de volta ao centro
      ..close(); // Fecha de volta ao topo

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _LightningBoltPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
  }
}

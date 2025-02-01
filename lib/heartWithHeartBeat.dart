import 'dart:ui';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..forward();

    // Opacity animation (starts fading out in last 1 second)
    _fadeAnimation = Tween<double>(begin: 1, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(1, 1.0,
            curve: Curves.easeOut), // Fade out at last 20% of animation
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      double heartProgress = (_controller.value - 0.5) * 2;
                      heartProgress =
                          heartProgress.clamp(0.0, 1.0); // Delay start
                      return CustomPaint(
                        size: const Size(150, 150),
                        painter: HeartPainter(heartProgress),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return CustomPaint(
                        size: const Size(200, 100),
                        painter: HeartbeatPainter(_controller.value),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class HeartPainter extends CustomPainter {
  final double progress;
  HeartPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10.0;

    final Path heartPath = Path();
    double width = size.width;
    double height = size.height;
    double centerX = width / 2;
    double centerY = height / 2;

    heartPath.moveTo(centerX, centerY + 50);
    heartPath.cubicTo(
      centerX - 40,
      centerY + 20,
      centerX - 70,
      centerY - 30,
      centerX,
      centerY,
    );
    heartPath.cubicTo(
      centerX + 70,
      centerY - 30,
      centerX + 40,
      centerY + 20,
      centerX,
      centerY + 50,
    );
    heartPath.close();

    final PathMetric pathMetric = heartPath.computeMetrics().first;
    final Path extractedPath =
        pathMetric.extractPath(0.0, pathMetric.length * progress);
    canvas.drawPath(extractedPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class HeartbeatPainter extends CustomPainter {
  final double animationValue;
  HeartbeatPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 10.0
      ..style = PaintingStyle.stroke;

    Path path = Path();
    double width = size.width;
    double height = size.height / 2;

    List<double> peaks = [
      0.0,
      0.1,
      0.2,
      0.3,
      0.4,
      0.5,
      0.6,
      0.7,
      0.8,
      0.9,
      1.0
    ];
    double progress = animationValue * peaks.length;
    int currentSegment = progress.floor();
    double segmentProgress = progress - currentSegment;

    for (int i = 0; i <= currentSegment; i++) {
      double x = width * peaks[i];
      if (i == 0) {
        path.moveTo(x, height);
      } else if (i % 3 == 0) {
        path.lineTo(x, height);
      } else if (i % 2 == 0) {
        path.lineTo(x, height - (i % 6 == 0 ? 20 : (i % 4 == 0 ? 50 : 80)));
      } else {
        path.lineTo(x, height);
      }
    }

    if (currentSegment < peaks.length - 1) {
      double x1 = width * peaks[currentSegment];
      double x2 = width * peaks[currentSegment + 1];
      double y1 = height;
      double y2 = height;

      if (currentSegment % 3 == 0) {
        y2 = height;
      } else if (currentSegment % 2 == 0) {
        y2 = height -
            (currentSegment % 6 == 0
                ? 20
                : (currentSegment % 4 == 0 ? 50 : 80));
      } else {
        y2 = height;
      }

      double x = x1 + (x2 - x1) * segmentProgress;
      double y = y1 + (y2 - y1) * segmentProgress;
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

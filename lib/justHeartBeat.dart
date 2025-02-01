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

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration:
          const Duration(seconds: 5), // Slower duration for smooth scrolling
    )..repeat(); // Repeats indefinitely for continuous animation
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.black, // Background color to contrast with the heartbeat
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                size: const Size(300, 200),
                painter: HeartbeatPainter(_controller.value),
              );
            },
          ),
        ),
      ),
    );
  }
}

class HeartbeatPainter extends CustomPainter {
  final double animationValue;

  HeartbeatPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    Path path = Path();
    double width = size.width;
    double height = size.height / 2;

    // Define the heartbeat pattern
    List<double> peaks = [
      0.0, // baseline
      0.1, // small peak
      0.2, // return to baseline
      0.3, // small peak
      0.4, // back to baseline
      0.5, // mid peak
      0.6, // return to baseline
      0.7, // large peak
      0.8, // deep drop
      0.9, // return to baseline
      1.0, // end small peak
    ];

    // Draw the heartbeat pattern
    for (int i = 0; i < peaks.length; i++) {
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

    // Calculate the horizontal offset for smooth scrolling
    double offsetX = -width * animationValue;

    // Draw the heartbeat path with the offset
    canvas.save();
    canvas.translate(offsetX, 0);
    canvas.drawPath(path, paint);
    canvas.restore();

    // Draw the next segment of the heartbeat to create a seamless loop
    canvas.save();
    canvas.translate(offsetX + width, 0);
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

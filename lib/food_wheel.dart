import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

class SpokeWheel extends StatefulWidget {
  const SpokeWheel({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SpokeWheelState createState() => _SpokeWheelState();
}

class _SpokeWheelState extends State<SpokeWheel> with SingleTickerProviderStateMixin {
  int glowingCircleIndex = -1;
  late Timer _timer;
  late int selectedCircleIndex;
  bool isSpinning = false;
  String? selectedButton = '100';
  bool canSelect = true;

  int? _selectedCircle;
  Map<int, int> iconCounts = {};
  int countdown = 15;
  String statusText = 'Please select food';

  double balance = 10000.00;
  double profit = 0.00;
  int roundCount = 0;

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 8; i++) {
      iconCounts[i] = 0;
    }
    startSpinning();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void startSpinning() {
    if (isSpinning) return;

    isSpinning = true;
    canSelect = true;
    setState(() {
      countdown = 30;
      statusText = 'Please select food';
    });

    _startCountdown();
  }

  void _startCountdown() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (countdown > 0) {
          countdown--;
        } else if (countdown == 0 && statusText == 'Please select food') {
          timer.cancel();
          canSelect = false;
          _startAnnouncingCountdown();
        }
      });
    });
  }

  void _startAnnouncingCountdown() {
    setState(() {
      countdown = 10;
      statusText = 'Announcing In:';
    });

    _startWheelSpinning();

    Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (countdown > 0) {
          countdown--;
        } else if (countdown == 0 && statusText == 'Announcing In:') {
          timer.cancel();
          _stopWheelSpinning();
        }
      });
    });
  }

  void _startWheelSpinning() {
    int numberOfSpokes = 8;
    int interval = 90;

    _timer = Timer.periodic(Duration(milliseconds: interval), (timer) {
      setState(() {
        glowingCircleIndex = (glowingCircleIndex + 1) % numberOfSpokes;
      });
    });
  }

  void _stopWheelSpinning() {
    _timer.cancel();
    setState(() {
      selectedCircleIndex = Random().nextInt(8);
      glowingCircleIndex = selectedCircleIndex;
      iconCounts[selectedCircleIndex] = (iconCounts[selectedCircleIndex] ?? 0) + 1;
      isSpinning = false;

      double betAmount = _convertBetAmountToDouble(selectedButton ?? '0');
      if (_selectedCircle != null) {
        if (_selectedCircle == selectedCircleIndex) {
          balance += betAmount;
          profit += betAmount;
        } else {
          balance -= betAmount;
        }
      }

      _selectedCircle = null;
      roundCount++;
    });

    Future.delayed(const Duration(seconds: 5), () {
      startSpinning();
    });
  }

  void _onCircleTap(int index) {
    if (!canSelect) return;

    double betAmount = _convertBetAmountToDouble(selectedButton ?? '0');
    if (balance >= betAmount) {
      setState(() {
        if (_selectedCircle == index) {
          _selectedCircle = null;
        } else {
          _selectedCircle = index;
        }
      });
    } else {
      _showInsufficientFundsDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) {
        RenderBox renderBox = context.findRenderObject() as RenderBox;
        Offset localPosition = renderBox.globalToLocal(details.globalPosition);
        _handleTap(localPosition);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Guess the Food'),
          backgroundColor: Colors.white,
          leading: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Image.asset(
              'images/ferris.png',
              fit: BoxFit.contain,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                icon: Image.asset(
                  'images/info.png',
                  fit: BoxFit.contain,
                ),
                onPressed: _showInfoDialog,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    height: 450,
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CustomPaint(
                            size: const Size(400, 400),
                            painter: WheelPainter(glowingCircleIndex, iconCounts, _selectedCircle),
                          ),
                          Positioned(
                            top: 185,
                            child: Text(
                              statusText,
                              style: const TextStyle(fontSize: 15, color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Positioned(
                            top: 205,
                            child: Text(
                              '${countdown}s',
                              style: const TextStyle(fontSize: 20, color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.yellow[700],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildSelectionButton('100'),
                          const SizedBox(width: 10),
                          _buildSelectionButton('1000'),
                          const SizedBox(width: 10),
                          _buildSelectionButton('10K'),
                          const SizedBox(width: 10),
                          _buildSelectionButton('100K'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0E345D),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildBalanceContainer('Coins balance', balance.toStringAsFixed(2), 'coin.png'),
                          _buildBalanceContainer('Today\'s profit', profit.toStringAsFixed(2), 'coin.png'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleTap(Offset position) {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    Offset localPosition = renderBox.globalToLocal(position);
    Size size = renderBox.size;
    Offset center = Offset(size.width / 2, size.height / 2);
    double spokeLength = 160;
    double angleBetweenSpokes = (2 * pi) / 8;
    double selectionRadius = 50;

    for (int i = 0; i < 8; i++) {
      double angle = i * angleBetweenSpokes;
      double outerCircleX = center.dx + spokeLength * cos(angle);
      double outerCircleY = center.dy + spokeLength * sin(angle);
      Offset outerCircleCenter = Offset(outerCircleX, outerCircleY);

      double dx = localPosition.dx - outerCircleCenter.dx;
      double dy = localPosition.dy - outerCircleCenter.dy;

      if (sqrt(dx * dx + dy * dy) <= selectionRadius) {
        _onCircleTap(i);
        break;
      }
    }
  }

  double _convertBetAmountToDouble(String betText) {
    switch (betText) {
      case '100':
        return 100.0;
      case '1000':
        return 1000.0;
      case '10K':
        return 10000.0;
      case '100K':
        return 100000.0;
      default:
        return 0.0;
    }
  }

  Widget _buildBalanceContainer(String title, String amount, String iconAsset) {
    return Container(
      width: 140,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'images/$iconAsset',
                width: 20,
                height: 20,
              ),
              const SizedBox(width: 5),
              Text(
                amount,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionButton(String text) {
    bool isSelected = selectedButton == text;
    double betAmount = _convertBetAmountToDouble(text);

    return GestureDetector(
      onTap: () {
        if (balance >= betAmount) {
          setState(() {
            if (!isSelected) {
              selectedButton = text;
            }
          });
        } else {
          _showInsufficientFundsDialog();
        }
      },
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.orange,
            width: 3,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'images/coin.png',
              width: 30,
              height: 30,
            ),
            const SizedBox(height: 8),
            Text(
              text,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showInsufficientFundsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: const Color(0xFF323F4B),
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.yellow[700]),
              const SizedBox(width: 10),
              const Text(
                'Insufficient Funds',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: const Text(
            'You do not have enough coins to make this bet.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'OK',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: const Color(0xFF0E345D),
          title: const Row(
            children: [
              Icon(Icons.info, color: Colors.orange, size: 28),
              SizedBox(width: 10),
              Text(
                'Game Info',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 22,
                ),
              ),
            ],
          ),
          content: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF1B3B5A),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rounds Played: $roundCount',
                  style: const TextStyle(
                    color: Colors.yellow,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Divider(color: Colors.white),
                const SizedBox(height: 10),
                const Text(
                  'Game Rules:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  '1. Select your bet amount.\n'
                  '2. Choose a food item by tapping on it.\n'
                  '3. Wait for the wheel to spin and reveal the selected food.\n'
                  '4. If your selection matches the revealed food, you win!',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.close, color: Colors.white),
              label: const Text(
                'Close',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class WheelPainter extends CustomPainter {
  final int glowingCircleIndex;
  final List<Image> images = [
    Image.asset("images/carrot.png"),
    Image.asset("images/grape.png"),
    Image.asset("images/pizza.png"),
    Image.asset("images/burger.png"),
    Image.asset("images/chicken.png"),
    Image.asset("images/noodles.png"),
    Image.asset("images/strawberry.png"),
    Image.asset("images/shake.png"),
  ];
  final Map<int, int> iconCounts;
  final int? selectedCircle;

  WheelPainter(this.glowingCircleIndex, this.iconCounts, this.selectedCircle);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = const Color.fromARGB(255, 14, 52, 93)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    Paint bluePaint = Paint()
      ..color = const Color(0xff6b97ff)
      ..style = PaintingStyle.fill;

    Paint glowPaint = Paint()
      ..color = const Color.fromARGB(255, 14, 52, 93)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 10);

    Paint unselectedPaint = Paint()
      ..color = const Color(0xff6b97ff)
      ..style = PaintingStyle.fill;

    Paint selectedPaint = Paint()
      ..color = const Color(0xffa7c957)
      ..style = PaintingStyle.fill;

    Offset center = Offset(size.width / 2, size.height / 2);
    double hubRadius = 70;
    double outerCircleRadius = 40;

    int numberOfSpokes = 8;
    double spokeLength = 160;
    double angleBetweenSpokes = (2 * pi) / numberOfSpokes;

    Offset bottomLeft = Offset(center.dx - hubRadius, center.dy + hubRadius + spokeLength);
    Offset bottomRight = Offset(center.dx + hubRadius, center.dy + hubRadius + spokeLength);

    canvas.drawLine(center, bottomLeft, paint);
    canvas.drawLine(center, bottomRight, paint);

    canvas.drawCircle(center, hubRadius, bluePaint);
    canvas.drawCircle(center, hubRadius, paint);

    for (int i = 0; i < numberOfSpokes; i++) {
      double angle = i * angleBetweenSpokes;
      double outerCircleX = center.dx + spokeLength * cos(angle);
      double outerCircleY = center.dy + spokeLength * sin(angle);
      Offset outerCircleCenter = Offset(outerCircleX, outerCircleY);

      double spokeStartX = center.dx + hubRadius * cos(angle);
      double spokeStartY = center.dy + hubRadius * sin(angle);
      Offset spokeStart = Offset(spokeStartX, spokeStartY);

      double spokeEndX = outerCircleCenter.dx - outerCircleRadius * cos(angle);
      double spokeEndY = outerCircleCenter.dy - outerCircleRadius * sin(angle);
      Offset spokeEnd = Offset(spokeEndX, spokeEndY);

      canvas.drawLine(spokeStart, spokeEnd, paint);

      double startAngle = 0;
      double sweepAngle = pi;

      Paint currentPaint = unselectedPaint;

      if (i == glowingCircleIndex) {
        canvas.drawCircle(outerCircleCenter, outerCircleRadius + 5, glowPaint);
      }

      if (i == selectedCircle) {
        currentPaint = selectedPaint;
      }

      canvas.drawArc(
        Rect.fromCircle(center: outerCircleCenter, radius: outerCircleRadius),
        startAngle,
        sweepAngle,
        true,
        currentPaint,
      );

      double imageSize = 30.0;
      images[i].image.resolve(const ImageConfiguration()).addListener(
        ImageStreamListener((ImageInfo info, bool _) {
          canvas.drawImageRect(
            info.image,
            Rect.fromLTWH(0, 0, info.image.width.toDouble(), info.image.height.toDouble()),
            Rect.fromCenter(
              center: Offset(
                outerCircleCenter.dx,
                outerCircleCenter.dy - outerCircleRadius / 2,
              ),
              width: imageSize,
              height: imageSize,
            ),
            Paint(),
          );
        }),
      );

      String countText = "Win ${iconCounts[i] ?? 0} times";
      TextSpan span = TextSpan(
        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
        text: countText,
      );
      TextPainter tp = TextPainter(
        text: span,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(
        canvas,
        Offset(
          outerCircleCenter.dx - tp.width / 2,
          outerCircleCenter.dy + outerCircleRadius / 2 - tp.height / 2,
        ),
      );

      canvas.drawCircle(outerCircleCenter, outerCircleRadius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

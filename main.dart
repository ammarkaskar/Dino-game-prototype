import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const DinoGame());
}

class DinoGame extends StatelessWidget {
  const DinoGame({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GamePage(),
    );
  }
}

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  static double dinoY = 1;
  double time = 0;
  double initialHeight = dinoY;
  bool midJump = false;

  double obstacleX = 1;
  double obstacleWidth = 0.05;
  double obstacleHeight = 0.2;

  double coinX = 2;
  double coinY = 0.6;
  bool coinVisible = false;

  bool gameHasStarted = false;
  int score = 0;
  late Timer gameTimer;

  double gravity = -4.9;
  double jumpVelocity = 2.8;
  double obstacleSpeed = 0.02;

  void setDifficulty() {
    if (score < 50) {
      gravity = -4.9;
      jumpVelocity = 3.5;
      obstacleSpeed = 0.018;
    } else if (score < 100) {
      gravity = -5.5;
      jumpVelocity = 3.0;
      obstacleSpeed = 0.025;
    } else {
      gravity = -6.0;
      jumpVelocity = 2.6;
      obstacleSpeed = 0.035;
    }
  }

  void jump() {
    if (midJump == false) {
      midJump = true;
      time = 0;
      initialHeight = dinoY;
    }
  }

  void startGame() {
    gameHasStarted = true;
    score = 0;
    obstacleX = 1;
    coinX = 2;
    gameTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      setDifficulty();

      time += 0.03;
      double height = gravity * time * time + jumpVelocity * time;

      if (height < 0) {
        midJump = false;
        dinoY = 1;
      } else {
        dinoY = initialHeight - height;
        if (dinoY > 1) dinoY = 1;
      }

      setState(() {
        obstacleX -= obstacleSpeed;
        if (obstacleX < -1.2) {
          obstacleX = 1;
          score++;
        }

        coinX -= obstacleSpeed;
        if (coinX < -1.2) {
          spawnCoin();
        }

        if (coinVisible &&
            coinX < 0.1 &&
            coinX > -0.1 &&
            (dinoY < coinY + 0.1)) {
          score += 5;
          coinVisible = false;
          coinX = 2;
        }
      });

      if (collisionDetected()) {
        timer.cancel();
        _showGameOverDialog();
      }
    });
  }

  void spawnCoin() {
    if (Random().nextBool()) {
      coinX = 1.2;
      coinY = 0.5 + Random().nextDouble() * 0.3;
      coinVisible = true;
    } else {
      coinVisible = false;
      coinX = 2;
    }
  }

  bool collisionDetected() {
    if (obstacleX < 0.1 &&
        obstacleX + obstacleWidth > -0.1 &&
        dinoY >= 1 - obstacleHeight) {
      return true;
    }
    return false;
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Game Over"),
        content: Text("Your Score: $score"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                gameHasStarted = false;
                dinoY = 1;
                obstacleX = 1;
                coinX = 2;
              });
            },
            child: const Text("Restart"),
          )
        ],
      ),
    );
  }

  Color getBackgroundColor() {
    if (score < 50) {
      return Colors.blue.shade200;
    } else if (score < 100) {
      return Colors.orange.shade300;
    } else {
      return Colors.black87;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: gameHasStarted ? jump : startGame,
      child: Scaffold(
        backgroundColor: getBackgroundColor(),
        body: Center(
          child: Stack(
            children: [
              AnimatedContainer(
                alignment: Alignment(0, dinoY),
                duration: const Duration(milliseconds: 0),
                child: const Dino(),
              ),
              AnimatedContainer(
                alignment: Alignment(obstacleX, 1),
                duration: const Duration(milliseconds: 0),
                child: Obstacle(
                  width: obstacleWidth,
                  height: obstacleHeight,
                ),
              ),
              if (coinVisible)
                AnimatedContainer(
                  alignment: Alignment(coinX, coinY),
                  duration: const Duration(milliseconds: 0),
                  child: const Coin(),
                ),
              Container(
                alignment: const Alignment(0, -0.7),
                child: Text(
                  gameHasStarted ? "" : "TAP TO START",
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                alignment: const Alignment(0, -0.9),
                child: Text(
                  "Score: $score",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Dino extends StatelessWidget {
  const Dino({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

class Obstacle extends StatelessWidget {
  final double width;
  final double height;

  const Obstacle({super.key, required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 50,
      color: Colors.brown,
    );
  }
}

class Coin extends StatelessWidget {
  const Coin({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 25,
      height: 25,
      decoration: BoxDecoration(
        color: Colors.yellow,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.orange, width: 2),
      ),
    );
  }
}

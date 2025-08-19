import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const SnakeGameApp());
}

class SnakeGameApp extends StatelessWidget {
  const SnakeGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snake Game',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: const SnakeGameScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SnakeGameScreen extends StatefulWidget {
  const SnakeGameScreen({super.key});

  @override
  State<SnakeGameScreen> createState() => _SnakeGameScreenState();
}

class _SnakeGameScreenState extends State<SnakeGameScreen> {
  // Game variables
  final int gridSize = 20;
  List<Point<int>> snake = [];
  Point<int> food = const Point(0, 0);
  Direction direction = Direction.right;
  Direction nextDirection = Direction.right;
  bool isPlaying = false;
  bool isGameOver = false;
  int score = 0;
  int highScore = 0;
  late Timer gameTimer;
  double gameBoardSize = 300; // Default size, will be adjusted responsively

  @override
  void initState() {
    super.initState();
    resetGame();
  }

  void resetGame() {
    setState(() {
      snake = [
        const Point(10, 10),
        const Point(9, 10),
        const Point(8, 10),
      ];
      direction = Direction.right;
      nextDirection = Direction.right;
      isGameOver = false;
      score = 0;
      generateFood();
    });
  }

  void generateFood() {
    final random = Random();
    Point<int> newFood;
    do {
      newFood = Point(
        random.nextInt(gridSize),
        random.nextInt(gridSize),
      );
    } while (snake.contains(newFood));
    
    setState(() {
      food = newFood;
    });
  }

  void startGame() {
    if (isGameOver) {
      resetGame();
    }
    
    setState(() {
      isPlaying = true;
    });
    
    gameTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (!isPlaying) {
        return;
      }
      
      setState(() {
        // Update direction
        direction = nextDirection;
        
        // Calculate new head position
        Point<int> newHead = snake.first;
        switch (direction) {
          case Direction.up:
            newHead = Point(newHead.x, newHead.y - 1);
            break;
          case Direction.down:
            newHead = Point(newHead.x, newHead.y + 1);
            break;
          case Direction.left:
            newHead = Point(newHead.x - 1, newHead.y);
            break;
          case Direction.right:
            newHead = Point(newHead.x + 1, newHead.y);
            break;
        }
        
        // Check for collisions with walls
        if (newHead.x < 0 || 
            newHead.x >= gridSize || 
            newHead.y < 0 || 
            newHead.y >= gridSize) {
          gameOver();
          return;
        }
        
        // Check for collisions with self
        if (snake.contains(newHead)) {
          gameOver();
          return;
        }
        
        // Move snake
        snake.insert(0, newHead);
        
        // Check if food is eaten
        if (newHead == food) {
          score += 10;
          if (score > highScore) {
            highScore = score;
          }
          generateFood();
        } else {
          snake.removeLast();
        }
      });
    });
  }

  void pauseGame() {
    setState(() {
      isPlaying = false;
    });
  }

  void gameOver() {
    setState(() {
      isPlaying = false;
      isGameOver = true;
    });
    gameTimer.cancel();
  }

  void handleSwipe(Direction swipeDirection) {
    if ((swipeDirection == Direction.up && direction != Direction.down) ||
        (swipeDirection == Direction.down && direction != Direction.up) ||
        (swipeDirection == Direction.left && direction != Direction.right) ||
        (swipeDirection == Direction.right && direction != Direction.left)) {
      setState(() {
        nextDirection = swipeDirection;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate responsive game board size
    final screenSize = MediaQuery.of(context).size;
    gameBoardSize = min(screenSize.width, screenSize.height) * 0.7;
    
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Adjust layout for different screen orientations
            final isPortrait = constraints.maxHeight > constraints.maxWidth;
            
            return isPortrait ? _buildPortraitLayout() : _buildLandscapeLayout();
          },
        ),
      ),
    );
  }

  Widget _buildPortraitLayout() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Title
            const Text(
              'SNAKE GAME',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            
            // Score display
            _buildScoreDisplay(),
            const SizedBox(height: 24),
            
            // Game board
            _buildGameBoard(),
            const SizedBox(height: 24),
            
            // Game controls
            _buildControlButtons(),
            const SizedBox(height: 16),
            
            // Game over message
            if (isGameOver) _buildGameOverMessage(),
            const SizedBox(height: 16),
            
            // Swipe instructions
            const Text(
              'Swipe on the game area to control the snake',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 16),
            
            // Touch controls
            _buildTouchControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildLandscapeLayout() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left column - Game board
          Expanded(
            child: Column(
              children: [
                const Text(
                  'SNAKE GAME',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 16),
                _buildGameBoard(),
                const SizedBox(height: 16),
                const Text(
                  'Swipe on the game area to control the snake',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 24),
          
          // Right column - Controls and info
          Expanded(
            child: Column(
              children: [
                _buildScoreDisplay(),
                const SizedBox(height: 24),
                _buildControlButtons(),
                const SizedBox(height: 24),
                if (isGameOver) _buildGameOverMessage(),
                const SizedBox(height: 24),
                _buildTouchControls(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreDisplay() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Column(
          children: [
            const Text(
              'SCORE',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white70,
              ),
            ),
            Text(
              '$score',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        Column(
          children: [
            const Text(
              'HIGH SCORE',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white70,
              ),
            ),
            Text(
              '$highScore',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGameBoard() {
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        if (details.delta.dy < -5) {
          handleSwipe(Direction.up);
        } else if (details.delta.dy > 5) {
          handleSwipe(Direction.down);
        }
      },
      onHorizontalDragUpdate: (details) {
        if (details.delta.dx < -5) {
          handleSwipe(Direction.left);
        } else if (details.delta.dx > 5) {
          handleSwipe(Direction.right);
        }
      },
      child: Container(
        width: gameBoardSize,
        height: gameBoardSize,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.green, width: 3),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: gridSize,
          ),
          itemCount: gridSize * gridSize,
          itemBuilder: (context, index) {
            int x = index % gridSize;
            int y = index ~/ gridSize;
            Point<int> point = Point(x, y);
            
            bool isSnake = snake.contains(point);
            bool isHead = snake.isNotEmpty && snake.first == point;
            bool isFood = food == point;
            
            return Container(
              margin: const EdgeInsets.all(0.5),
              decoration: BoxDecoration(
                color: isHead
                    ? Colors.green[700]
                    : isSnake
                        ? Colors.green[500]
                        : isFood
                            ? Colors.red
                            : Colors.grey[850],
                borderRadius: isHead ? BorderRadius.circular(5) : BorderRadius.circular(2),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildControlButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (!isPlaying && !isGameOver)
          ElevatedButton.icon(
            onPressed: startGame,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        if (isPlaying)
          ElevatedButton.icon(
            onPressed: pauseGame,
            icon: const Icon(Icons.pause),
            label: const Text('Pause'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        if (isGameOver)
          ElevatedButton.icon(
            onPressed: resetGame,
            icon: const Icon(Icons.refresh),
            label: const Text('Play Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildGameOverMessage() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Text(
        'GAME OVER!',
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildTouchControls() {
    return Column(
      children: [
        const Text(
          'Or use touch buttons:',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 16),
        // Up button
        IconButton(
          icon: const Icon(Icons.keyboard_arrow_up, size: 40),
          color: Colors.white,
          onPressed: () => handleSwipe(Direction.up),
        ),
        // Left/Right buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.keyboard_arrow_left, size: 40),
              color: Colors.white,
              onPressed: () => handleSwipe(Direction.left),
            ),
            const SizedBox(width: 60),
            IconButton(
              icon: const Icon(Icons.keyboard_arrow_right, size: 40),
              color: Colors.white,
              onPressed: () => handleSwipe(Direction.right),
            ),
          ],
        ),
        // Down button
        IconButton(
          icon: const Icon(Icons.keyboard_arrow_down, size: 40),
          color: Colors.white,
          onPressed: () => handleSwipe(Direction.down),
        ),
      ],
    );
  }

  @override
  void dispose() {
    gameTimer.cancel();
    super.dispose();
  }
}

enum Direction { up, down, left, right }
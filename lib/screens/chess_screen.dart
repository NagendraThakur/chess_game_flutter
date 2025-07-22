import 'package:chess_game_flutter/components/border_tile.dart';
import 'package:chess_game_flutter/components/captured_piece.dart';
import 'package:chess_game_flutter/model/game_piece.dart';
import 'package:chess_game_flutter/helper/helper.dart';
import 'package:flutter/material.dart';
import 'package:chess_game_flutter/model/game_piece.dart';

class ChessScreen extends StatefulWidget {
  const ChessScreen({Key? key}) : super(key: key);

  @override
  State<ChessScreen> createState() => _ChessScreenState();
}

class _ChessScreenState extends State<ChessScreen> {
  // The 8x8 grid representing our chess board. Each spot can hold a GamePiece or be empty (null).
  late List<List<GamePiece?>> boardGrid;

  // The chess piece the player has currently picked up. Null if nothing is picked.
  GamePiece? currentlyPickedPiece;
  // The row index of the picked piece. -1 means no piece is picked.
  int pickedPieceRow = -1;
  // The column index of the picked piece. -1 means no piece is picked.
  int pickedPieceCol = -1;

  // A list of all squares where the currently picked piece can legally move.
  List<List<int>> legalMovesForPickedPiece = [];

  // Lists to keep track of pieces captured by each team.
  List<GamePiece> whiteCaptured = [];
  List<GamePiece> blackCaptured = [];

  // True if it's the light team's turn, false if it's the dark team's turn.
  bool isWhiteTurn = true;

  // Store the current positions of both kings for check detection.
  List<int> whiteKingLocation = [7, 4]; // Initial position for the light king
  List<int> blackKingLocation = [0, 4]; // Initial position for the dark king

  // True if the current player's king is in check.
  bool isKingThreatened = false;

  @override
  void initState() {
    super.initState();
    _setupNewGame(); // Set up the board when the game starts
  }

  // Sets up the chess board with all pieces in their starting positions.
  void _setupNewGame() {
    // Create an empty 8x8 board first.
    List<List<GamePiece?>> initialBoard =
        List.generate(8, (index) => List.generate(8, (index) => null));

    // Place pawns (pawns) for both teams
    for (int i = 0; i < 8; i++) {
      initialBoard[1][i] = GamePiece(
        pieceKind: GamePieceType.pawn,
        isLightTeam: false,
        graphicAssetPath: 'images/pawn.png',
      );
      initialBoard[6][i] = GamePiece(
        pieceKind: GamePieceType.pawn,
        isLightTeam: true,
        graphicAssetPath: 'images/pawn.png',
      );
    }

    // Place castles (rooks)
    initialBoard[0][0] = GamePiece(
        pieceKind: GamePieceType.castle,
        isLightTeam: false,
        graphicAssetPath: "images/rook.png");
    initialBoard[0][7] = GamePiece(
        pieceKind: GamePieceType.castle,
        isLightTeam: false,
        graphicAssetPath: "images/rook.png");
    initialBoard[7][0] = GamePiece(
        pieceKind: GamePieceType.castle,
        isLightTeam: true,
        graphicAssetPath: "images/rook.png");
    initialBoard[7][7] = GamePiece(
        pieceKind: GamePieceType.castle,
        isLightTeam: true,
        graphicAssetPath: "images/rook.png");

    // Place knights (knights)
    initialBoard[0][1] = GamePiece(
        pieceKind: GamePieceType.knight,
        isLightTeam: false,
        graphicAssetPath: "images/knight.png");
    initialBoard[0][6] = GamePiece(
        pieceKind: GamePieceType.knight,
        isLightTeam: false,
        graphicAssetPath: "images/knight.png");
    initialBoard[7][1] = GamePiece(
        pieceKind: GamePieceType.knight,
        isLightTeam: true,
        graphicAssetPath: "images/knight.png");
    initialBoard[7][6] = GamePiece(
        pieceKind: GamePieceType.knight,
        isLightTeam: true,
        graphicAssetPath: "images/knight.png");

    // Place bishops (bishops)
    initialBoard[0][2] = GamePiece(
        pieceKind: GamePieceType.bishop,
        isLightTeam: false,
        graphicAssetPath: "images/bishop.png");
    initialBoard[0][5] = GamePiece(
        pieceKind: GamePieceType.bishop,
        isLightTeam: false,
        graphicAssetPath: "images/bishop.png");
    initialBoard[7][2] = GamePiece(
        pieceKind: GamePieceType.bishop,
        isLightTeam: true,
        graphicAssetPath: "images/bishop.png");
    initialBoard[7][5] = GamePiece(
        pieceKind: GamePieceType.bishop,
        isLightTeam: true,
        graphicAssetPath: "images/bishop.png");

    // Place queens (queens)
    initialBoard[0][3] = GamePiece(
      pieceKind: GamePieceType.queen,
      isLightTeam: false,
      graphicAssetPath: 'images/queen.png',
    );
    initialBoard[7][3] = GamePiece(
      pieceKind: GamePieceType.queen,
      isLightTeam: true,
      graphicAssetPath: 'images/queen.png',
    );

    // Place kings (kings)
    initialBoard[0][4] = GamePiece(
      pieceKind: GamePieceType.king,
      isLightTeam: false,
      graphicAssetPath: 'images/king.png',
    );
    initialBoard[7][4] = GamePiece(
      pieceKind: GamePieceType.king,
      isLightTeam: true,
      graphicAssetPath: 'images/king.png',
    );

    boardGrid = initialBoard; // Assign the freshly set up board
  }

  // --- GAME LOGIC ---

  // Called when the user taps on a square.
  void handlePieceSelection(int row, int col) {
    setState(() {
      // Scenario 1: No piece is currently picked, and the tapped square has one of our pieces.
      if (currentlyPickedPiece == null && boardGrid[row][col] != null) {
        if (boardGrid[row][col]!.isLightTeam == isWhiteTurn) {
          currentlyPickedPiece = boardGrid[row][col];
          pickedPieceRow = row;
          pickedPieceCol = col;
        }
      }
      // Scenario 2: A piece is already picked, and the user taps another of their own pieces.
      else if (boardGrid[row][col] != null &&
          boardGrid[row][col]!.isLightTeam ==
              currentlyPickedPiece!.isLightTeam) {
        currentlyPickedPiece = boardGrid[row][col];
        pickedPieceRow = row;
        pickedPieceCol = col;
      }
      // Scenario 3: A piece is picked, and the user taps a valid empty square or an opponent's piece.
      else if (currentlyPickedPiece != null &&
          legalMovesForPickedPiece
              .any((move) => move[0] == row && move[1] == col)) {
        moveCurrentPiece(row, col); // Perform the move
      }

      // After any action, recalculate legal moves for the selected piece (if any).
      legalMovesForPickedPiece = calculateFilteredLegalMoves(
          pickedPieceRow, pickedPieceCol, currentlyPickedPiece, true);
    });
  }

  // Calculates all possible moves for a given piece, ignoring whether they put the king in check.
  List<List<int>> calculateRawPossibleMoves(
      int row, int col, GamePiece? piece) {
    List<List<int>> possibleDestinations = [];

    if (piece == null) {
      return []; // No piece, no moves.
    }

    // Direction modifier for pawns: -1 for light team (moving up), 1 for dark team (moving down).
    int moveDirection = piece.isLightTeam ? -1 : 1;

    switch (piece.pieceKind) {
      case GamePieceType.pawn: // Pawn moves
        // One step forward
        if (isValidCoordinate(row + moveDirection, col) &&
            boardGrid[row + moveDirection][col] == null) {
          possibleDestinations.add([row + moveDirection, col]);
        }

        // Two steps forward on first move
        if ((row == 1 && !piece.isLightTeam) ||
            (row == 6 && piece.isLightTeam)) {
          if (isValidCoordinate(row + 2 * moveDirection, col) &&
              boardGrid[row + 2 * moveDirection][col] == null &&
              boardGrid[row + moveDirection][col] == null) {
            possibleDestinations.add([row + 2 * moveDirection, col]);
          }
        }

        // Diagonal captures
        if (isValidCoordinate(row + moveDirection, col - 1) &&
            boardGrid[row + moveDirection][col - 1] != null &&
            boardGrid[row + moveDirection][col - 1]!.isLightTeam !=
                piece.isLightTeam) {
          possibleDestinations.add([row + moveDirection, col - 1]);
        }
        if (isValidCoordinate(row + moveDirection, col + 1) &&
            boardGrid[row + moveDirection][col + 1] != null &&
            boardGrid[row + moveDirection][col + 1]!.isLightTeam !=
                piece.isLightTeam) {
          possibleDestinations.add([row + moveDirection, col + 1]);
        }
        break;

      case GamePieceType.castle: // Rook moves (horizontal and vertical)
        var directions = [
          [-1, 0], // Up
          [1, 0], // Down
          [0, -1], // Left
          [0, 1], // Right
        ];
        for (var dir in directions) {
          var step = 1;
          while (true) {
            var newRow = row + step * dir[0];
            var newCol = col + step * dir[1];
            if (!isValidCoordinate(newRow, newCol)) {
              break; // Out of board
            }
            if (boardGrid[newRow][newCol] != null) {
              if (boardGrid[newRow][newCol]!.isLightTeam != piece.isLightTeam) {
                possibleDestinations
                    .add([newRow, newCol]); // Can capture opponent
              }
              break; // Blocked by a piece (own or captured opponent)
            }
            possibleDestinations.add([newRow, newCol]); // Empty, valid square
            step++;
          }
        }
        break;

      case GamePieceType.knight: // Knight moves (L-shape)
        var knightJumps = [
          [-2, -1], [-2, 1], // Up 2, left/right 1
          [-1, -2], [-1, 2], // Up 1, left/right 2
          [1, -2], [1, 2], // Down 1, left/right 2
          [2, -1], [2, 1], // Down 2, left/right 1
        ];
        for (var jump in knightJumps) {
          var newRow = row + jump[0];
          var newCol = col + jump[1];
          if (!isValidCoordinate(newRow, newCol)) {
            continue; // Skip if out of board
          }
          // Add if empty or contains an opponent's piece
          if (boardGrid[newRow][newCol] == null ||
              boardGrid[newRow][newCol]!.isLightTeam != piece.isLightTeam) {
            possibleDestinations.add([newRow, newCol]);
          }
        }
        break;

      case GamePieceType.bishop: // Bishop moves (diagonal)
        var diagonalDirections = [
          [-1, -1], // Up-left
          [-1, 1], // Up-right
          [1, -1], // Down-left
          [1, 1], // Down-right
        ];
        for (var dir in diagonalDirections) {
          var step = 1;
          while (true) {
            var newRow = row + step * dir[0];
            var newCol = col + step * dir[1];
            if (!isValidCoordinate(newRow, newCol)) {
              break; // Out of board
            }
            if (boardGrid[newRow][newCol] != null) {
              if (boardGrid[newRow][newCol]!.isLightTeam != piece.isLightTeam) {
                possibleDestinations.add([newRow, newCol]); // Capture
              }
              break; // Blocked
            }
            possibleDestinations.add([newRow, newCol]); // Empty square
            step++;
          }
        }
        break;

      case GamePieceType.queen: // Queen moves (all directions)
        // Combines rook and bishop moves
        var allDirections = [
          [-1, 0], [1, 0], [0, -1], [0, 1], // Straight
          [-1, -1], [-1, 1], [1, -1], [1, 1] // Diagonal
        ];

        for (var dir in allDirections) {
          var step = 1;
          while (true) {
            var newRow = row + step * dir[0];
            var newCol = col + step * dir[1];
            if (!isValidCoordinate(newRow, newCol)) {
              break; // Out of board
            }
            if (boardGrid[newRow][newCol] != null) {
              if (boardGrid[newRow][newCol]!.isLightTeam != piece.isLightTeam) {
                possibleDestinations.add([newRow, newCol]); // Capture
              }
              break; // Blocked
            }
            possibleDestinations.add([newRow, newCol]); // Empty square
            step++;
          }
        }
        break;

      case GamePieceType.king: // King moves (one step in any direction)
        var kingOneStepMoves = [
          [-1, -1], [-1, 0], [-1, 1], // Top row
          [0, -1], [0, 1], // Middle row
          [1, -1], [1, 0], [1, 1] // Bottom row
        ];

        for (var move in kingOneStepMoves) {
          var newRow = row + move[0];
          var newCol = col + move[1];

          if (!isValidCoordinate(newRow, newCol)) {
            continue; // Skip if out of board
          }

          if (boardGrid[newRow][newCol] != null) {
            if (boardGrid[newRow][newCol]!.isLightTeam != piece.isLightTeam) {
              possibleDestinations.add([newRow, newCol]); // Can capture
            }
            continue; // Square is blocked by a piece of the same color
          }
          possibleDestinations.add([newRow, newCol]); // Empty, valid square
        }
        break;

      default:
    }
    return possibleDestinations;
  }

  // Filters raw possible moves to ensure they don't leave the king in check.
  List<List<int>> calculateFilteredLegalMoves(
      int row, int col, GamePiece? piece, bool performCheckSimulation) {
    List<List<int>> filteredMoves = [];
    List<List<int>> rawPossibleMoves =
        calculateRawPossibleMoves(row, col, piece);

    if (performCheckSimulation) {
      for (var potentialMove in rawPossibleMoves) {
        int targetRow = potentialMove[0];
        int targetCol = potentialMove[1];
        // Only add the move if simulating it keeps our king safe
        if (doesSimulatedMoveKeepKingSafe(
            piece!, row, col, targetRow, targetCol)) {
          filteredMoves.add(potentialMove);
        }
      }
    } else {
      // If no check simulation needed (e.g., for calculating opponent's attacks)
      filteredMoves = rawPossibleMoves;
    }
    return filteredMoves;
  }

  // Performs the actual movement of a piece on the board.
  void moveCurrentPiece(int newRow, int newCol) {
    // If the destination has an enemy piece, capture it.
    if (boardGrid[newRow][newCol] != null) {
      var capturedGamePiece = boardGrid[newRow][newCol];
      if (capturedGamePiece!.isLightTeam) {
        whiteCaptured.add(capturedGamePiece);
      } else {
        blackCaptured.add(capturedGamePiece);
      }
    }

    // Update the king's position if the king is the one moving.
    if (currentlyPickedPiece?.pieceKind == GamePieceType.king) {
      if (currentlyPickedPiece!.isLightTeam) {
        whiteKingLocation = [newRow, newCol];
      } else {
        blackKingLocation = [newRow, newCol];
      }
    }

    // Move the piece: put it in the new spot, clear the old spot.
    boardGrid[newRow][newCol] = currentlyPickedPiece;
    boardGrid[pickedPieceRow][pickedPieceCol] = null;

    // After the move, check if the *opponent's* king is now in check.
    if (isKingCurrentlyAttacked(!isWhiteTurn)) {
      isKingThreatened = true;
    } else {
      isKingThreatened = false;
    }

    // Reset selection and legal moves for the next turn.
    setState(() {
      currentlyPickedPiece = null;
      pickedPieceRow = -1;
      pickedPieceCol = -1;
      legalMovesForPickedPiece = [];
    });

    // Check for checkmate for the opponent.
    if (isCheckmate(!isWhiteTurn)) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("CHECKMATE! Game Over"),
          actions: [
            TextButton(
              onPressed: resetGame,
              child: const Text("Restart Game"),
            )
          ],
        ),
      );
    }

    // Switch turns to the other team.
    isWhiteTurn = !isWhiteTurn;
  }

  // Checks if a king (of a specified color) is currently being attacked.
  bool isKingCurrentlyAttacked(bool checkLightKing) {
    List<int> kingPos = checkLightKing ? whiteKingLocation : blackKingLocation;

    // Loop through every square on the board.
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        // Skip empty squares or pieces of the same color as the king we are checking.
        if (boardGrid[r][c] == null ||
            boardGrid[r][c]!.isLightTeam == checkLightKing) {
          continue;
        }

        // Get all possible moves for this opponent piece (don't simulate checks here).
        List<List<int>> opponentPieceMoves =
            calculateFilteredLegalMoves(r, c, boardGrid[r][c], false);

        // Check if any of these moves target the king's position.
        for (List<int> move in opponentPieceMoves) {
          if (move[0] == kingPos[0] && move[1] == kingPos[1]) {
            return true; // Yes, the king is under attack!
          }
        }
      }
    }
    return false; // No, the king is safe.
  }

  // Simulates a move to check if it would leave the player's own king in check.
  bool doesSimulatedMoveKeepKingSafe(
      GamePiece pieceToMove, int startR, int startC, int endR, int endC) {
    // Temporarily save what was at the destination square
    GamePiece? originalTargetPiece = boardGrid[endR][endC];

    // Temporarily save the king's position if the king is the one moving
    List<int>? originalKingPosition;
    if (pieceToMove.pieceKind == GamePieceType.king) {
      originalKingPosition =
          pieceToMove.isLightTeam ? whiteKingLocation : blackKingLocation;
      if (pieceToMove.isLightTeam) {
        whiteKingLocation = [endR, endC];
      } else {
        blackKingLocation = [endR, endC];
      }
    }

    // Perform the hypothetical move on the board
    boardGrid[endR][endC] = pieceToMove;
    boardGrid[startR][startC] = null;

    // Check if the king (of the moving piece's color) is in check after this hypothetical move
    bool isKingSafe = !isKingCurrentlyAttacked(pieceToMove.isLightTeam);

    // Revert the board to its original state (undo the hypothetical move)
    boardGrid[startR][startC] = pieceToMove;
    boardGrid[endR][endC] = originalTargetPiece;

    // Restore the king's position if it was temporarily changed
    if (pieceToMove.pieceKind == GamePieceType.king) {
      if (pieceToMove.isLightTeam) {
        whiteKingLocation = originalKingPosition!;
      } else {
        blackKingLocation = originalKingPosition!;
      }
    }
    return isKingSafe; // Return true if the move is safe for the king
  }

  // Checks if the specified king is in checkmate.
  bool isCheckmate(bool checkLightKing) {
    // If the king is not in check, it cannot be checkmate.
    if (!isKingCurrentlyAttacked(checkLightKing)) {
      return false;
    }

    // Check every piece of the threatened team to see if it can make a legal move.
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        // Skip empty squares or opponent's pieces.
        if (boardGrid[r][c] == null ||
            boardGrid[r][c]!.isLightTeam != checkLightKing) {
          continue;
        }
        // Calculate the real legal moves for this piece (moves that save the king).
        List<List<int>> possibleEscapeMoves =
            calculateFilteredLegalMoves(r, c, boardGrid[r][c]!, true);
        if (possibleEscapeMoves.isNotEmpty) {
          return false; // Found a move that gets the king out of check, so not checkmate.
        }
      }
    }
    return true; // No legal moves found to escape check, it's checkmate.
  }

  // Resets the game to its initial state.
  void resetGame() {
    Navigator.pop(context); // Close the checkmate dialog
    _setupNewGame(); // Re-initialize the board
    isKingThreatened = false; // Clear check status
    whiteCaptured.clear(); // Clear captured pieces
    blackCaptured.clear();
    whiteKingLocation = [7, 4]; // Reset king positions
    blackKingLocation = [0, 4];
    isWhiteTurn = true; // White starts
    setState(() {}); // Rebuild the UI
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[800], // Dark background for the overall app
      body: Column(
        children: [
          // Display for captured light pieces (top of the screen)
          Expanded(
            child: GridView.builder(
              physics:
                  const NeverScrollableScrollPhysics(), // Don't allow scrolling
              itemCount: whiteCaptured.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8), // 8 columns for captured pieces
              itemBuilder: (context, index) => CapturedPieceDisplay(
                pieceAssetPath: whiteCaptured[index].graphicAssetPath,
                isLightColored: true, // They are light pieces
              ),
            ),
          ),

          // Display "CHECK" status
          Text(
            isKingThreatened ? "CHECK!" : "",
            style: const TextStyle(color: Colors.red, fontSize: 24),
          ),

          // The main chessboard (takes up most of the screen)
          Expanded(
            flex:
                3, // Takes 3 times more space than the captured piece displays
            child: GridView.builder(
              physics:
                  const NeverScrollableScrollPhysics(), // Don't allow scrolling
              itemCount: 8 * 8, // 64 squares on a chess board
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8), // 8 columns for the board
              itemBuilder: (context, index) {
                // Calculate row and column from the single index
                int row = index ~/ 8;
                int col = index % 8;

                // Determine if this square is currently selected
                bool isThisSquareSelected =
                    pickedPieceCol == col && pickedPieceRow == row;

                // Determine if this square is a valid move for the picked piece
                bool isThisSquareLegalMove = false;
                for (var position in legalMovesForPickedPiece) {
                  if (position[0] == row && position[1] == col) {
                    isThisSquareLegalMove = true;
                    break;
                  }
                }

                // Return a BoardTile widget for this square
                return BoardTile(
                  isLegalMove: isThisSquareLegalMove,
                  onTileTap: () => handlePieceSelection(
                      row, col), // What happens when tapped
                  currentlySelected: isThisSquareSelected,
                  isLightTile: identifySquareColor(
                      index), // Determine if it's a light or dark square
                  currentPiece: boardGrid[row]
                      [col], // The piece on this square (or null)
                );
              },
            ),
          ),

          // Display for captured dark pieces (bottom of the screen)
          Expanded(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: blackCaptured.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8),
              itemBuilder: (context, index) => CapturedPieceDisplay(
                pieceAssetPath: blackCaptured[index].graphicAssetPath,
                isLightColored: false, // They are dark pieces
              ),
            ),
          ),
        ],
      ),
    );
  }
}

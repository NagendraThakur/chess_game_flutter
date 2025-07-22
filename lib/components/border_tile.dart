import 'package:chess_game_flutter/model/game_piece.dart';
import 'package:chess_game_flutter/constants/colors.dart';
import 'package:flutter/material.dart';

class BoardTile extends StatelessWidget {
  // Function to call when this tile is tapped
  final void Function()? onTileTap;
  // True if this tile is a valid place to move the selected piece
  final bool isLegalMove;
  // True if this is a light-colored square, false if dark
  final bool isLightTile;
  // The chess piece currently on this tile, can be null if empty
  final GamePiece? currentPiece;
  // True if this tile is currently selected by the user
  final bool currentlySelected;

  const BoardTile({
    super.key,
    required this.onTileTap,
    required this.isLegalMove,
    required this.isLightTile,
    required this.currentPiece,
    required this.currentlySelected,
  });

  @override
  Widget build(BuildContext context) {
    Color? tileFillColor;

    // Determine the background color of the tile
    if (currentlySelected) {
      tileFillColor = Colors.blue; // Blue if the tile is selected
    } else if (isLegalMove) {
      tileFillColor = Colors.pink[300]; // Pinkish if it's a valid move target
    }
    // Otherwise, use the standard board colors
    else {
      tileFillColor = isLightTile ? backgroundColor : forgroundColor;
    }

    return GestureDetector(
      onTap: onTileTap, // Trigger the tap function when pressed
      child: Container(
        color: tileFillColor, // Set the background color of the tile
        child: currentPiece != null
            ? Image.asset(
                currentPiece!.graphicAssetPath, // Display the piece's image
                // Optionally tint dark pieces for better contrast
                color: currentPiece!.isLightTeam ? null : Colors.black,
              )
            : null, // If no piece, show nothing
      ),
    );
  }
}

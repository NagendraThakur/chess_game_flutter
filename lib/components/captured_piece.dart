import 'package:flutter/material.dart';

class CapturedPieceDisplay extends StatelessWidget {
  // Path to the image file for the captured piece
  final String pieceAssetPath;
  // True if the captured piece was light-colored (e.g., white), false if dark
  final bool isLightColored;

  const CapturedPieceDisplay({
    Key? key,
    required this.pieceAssetPath,
    required this.isLightColored,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      pieceAssetPath,
      // Apply a faded color based on the piece's original color
      color: isLightColored ? Colors.white54 : Colors.black54,
    );
  }
}

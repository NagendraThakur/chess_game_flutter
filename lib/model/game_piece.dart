enum GamePieceType {
  // Represents different types of chess pieces
  pawn, // Formerly sipahi
  castle, // Formerly hati
  knight, // Formerly ghoda
  bishop, //
  king, // Formerly raja
  queen, // Formerly rani
}

class GamePiece {
  // The specific type of this game piece (e.g., pawn, king)
  final GamePieceType pieceKind;
  // True if the piece belongs to the light team, false if to the dark team
  final bool isLightTeam;
  // The file path to the image representing this piece
  final String graphicAssetPath;

  GamePiece({
    required this.pieceKind,
    required this.isLightTeam,
    required this.graphicAssetPath,
  });
}

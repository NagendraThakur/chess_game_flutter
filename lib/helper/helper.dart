bool identifySquareColor(int boardIndex) {
  // Calculate the row (rank) from the overall board index
  int currentRank = boardIndex ~/ 8;
  // Calculate the column (file) from the overall board index
  int currentFile = boardIndex % 8;
  // Determine if the square is "light" (like white) based on the sum of its rank and file
  bool isLightSquare = (currentRank + currentFile) % 2 == 0;
  return isLightSquare;
}

bool isValidCoordinate(int rowCoord, int colCoord) {
  // Check if the given row and column are within the standard 8x8 chess board boundaries
  return rowCoord >= 0 && rowCoord < 8 && colCoord >= 0 && colCoord < 8;
}

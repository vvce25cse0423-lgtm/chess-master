// lib/widgets/chess_board.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/chess_piece.dart';
import '../models/chess_move.dart';
import '../theme/app_theme.dart';
import 'chess_piece_svg.dart';
import 'promotion_dialog.dart';

class ChessBoard extends StatelessWidget {
  const ChessBoard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, provider, _) {
        return AspectRatio(
          aspectRatio: 1,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.gold.withOpacity(0.6), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Stack(
              children: [
                _buildBoardGrid(context, provider),
                if (provider.isAIThinking) _buildThinkingOverlay(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBoardGrid(BuildContext context, GameProvider provider) {
    return Column(
      children: List.generate(8, (rowIdx) {
        return Expanded(
          child: Row(
            children: List.generate(8, (colIdx) {
              final col = provider.boardFlipped ? 7 - colIdx : colIdx;
              final displayRow = provider.boardFlipped ? 7 - rowIdx : rowIdx;
              return Expanded(
                child: _buildSquare(context, provider, displayRow, col, rowIdx, colIdx),
              );
            }),
          ),
        );
      }),
    );
  }

  Widget _buildSquare(BuildContext context, GameProvider provider,
      int row, int col, int rowIdx, int colIdx) {
    final isLight = (row + col) % 2 == 0;
    final isSelected = provider.isSelected(row, col);
    final isLegal = provider.isLegalMove(row, col);
    final isLastMove = provider.isLastMoveSquare(row, col);
    final isCheck = provider.isCheckSquare(row, col);
    final piece = provider.getPiece(row, col);

    Color squareColor;
    if (isCheck) {
      squareColor = AppTheme.checkSquare;
    } else if (isSelected) {
      squareColor = AppTheme.selectedSquare;
    } else if (isLastMove) {
      squareColor = isLight ? AppTheme.lastMoveLight : AppTheme.lastMoveDark;
    } else {
      squareColor = isLight ? AppTheme.lightSquare : AppTheme.darkSquare;
    }

    return GestureDetector(
      onTap: () => _handleTap(context, provider, row, col, piece),
      child: Container(
        color: squareColor,
        child: Stack(
          children: [
            // Legal move indicator
            if (isLegal) _buildLegalMoveIndicator(piece),
            // Piece
            if (piece != null) _buildPiece(piece, isSelected),
            // Coordinates
            if (provider.showCoordinates) _buildCoordinates(row, col, isLight),
          ],
        ),
      ),
    );
  }

  void _handleTap(BuildContext context, GameProvider provider, int row, int col, ChessPiece? piece) {
    // Check if this is a pawn promotion move
    final selected = provider.selectedPosition;
    if (selected != null && provider.isLegalMove(row, col)) {
      final movingPiece = provider.getPiece(selected.row, selected.col);
      if (movingPiece?.type == PieceType.pawn && (row == 0 || row == 7)) {
        _showPromotionDialog(context, provider, selected, ChessPosition(row, col));
        return;
      }
    }
    provider.onSquareTap(row, col);
  }

  void _showPromotionDialog(BuildContext context, GameProvider provider,
      ChessPosition from, ChessPosition to) {
    final color = provider.getPiece(from.row, from.col)?.color ?? PieceColor.white;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PromotionDialog(
        color: color,
        onSelect: (type) {
          Navigator.pop(context);
          provider.onSquareTap(to.row, to.col, promotionPiece: type);
        },
      ),
    );
  }

  Widget _buildLegalMoveIndicator(ChessPiece? piece) {
    if (piece == null) {
      return Center(
        child: Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withOpacity(0.2),
          ),
        ),
      );
    } else {
      return Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black.withOpacity(0.3),
            width: 3,
          ),
        ),
      );
    }
  }

  Widget _buildPiece(ChessPiece piece, bool isSelected) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxWidth * 0.88;
        return Center(
          child: ChessPieceSvg(
            piece: piece,
            size: size,
            isSelected: isSelected,
          ),
        );
      },
    );
  }

  Widget _buildCoordinates(int row, int col, bool isLight) {
    return Stack(
      children: [
        if (col == 0)
          Padding(
            padding: const EdgeInsets.only(left: 2, top: 1),
            child: Text(
              '${8 - row}',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isLight ? AppTheme.darkSquare : AppTheme.lightSquare,
              ),
            ),
          ),
        if (row == 7)
          Positioned(
            bottom: 1,
            right: 2,
            child: Text(
              String.fromCharCode('a'.codeUnitAt(0) + col),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isLight ? AppTheme.darkSquare : AppTheme.lightSquare,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildThinkingOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black12,
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: AppTheme.gold,
                strokeWidth: 3,
              ),
              SizedBox(height: 8),
              Text(
                'AI thinking...',
                style: TextStyle(
                  color: AppTheme.gold,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

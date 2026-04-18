// lib/providers/game_provider.dart
import 'package:flutter/material.dart';
import 'dart:async';
import '../models/chess_game.dart';
import '../models/chess_piece.dart';
import '../models/chess_move.dart';
import '../models/chess_ai.dart';

class GameProvider extends ChangeNotifier {
  ChessGame _game = ChessGame();
  ChessPosition? _selectedPosition;
  List<ChessPosition> _legalMoves = [];
  bool _soundEnabled = true;
  bool _showCoordinates = true;
  bool _boardFlipped = false;
  bool _isAIThinking = false;
  GameMode _gameMode = GameMode.pvp;
  AIDifficulty _difficulty = AIDifficulty.medium;
  ChessAI? _ai;
  
  // Timers
  Map<PieceColor, int> _timeLeft = {
    PieceColor.white: 600,
    PieceColor.black: 600,
  };
  bool _timerEnabled = false;
  Timer? _timer;

  // Stats
  int _whiteWins = 0;
  int _blackWins = 0;
  int _draws = 0;

  ChessGame get game => _game;
  ChessPosition? get selectedPosition => _selectedPosition;
  List<ChessPosition> get legalMoves => _legalMoves;
  bool get soundEnabled => _soundEnabled;
  bool get showCoordinates => _showCoordinates;
  bool get boardFlipped => _boardFlipped;
  bool get isAIThinking => _isAIThinking;
  GameMode get gameMode => _gameMode;
  AIDifficulty get difficulty => _difficulty;
  Map<PieceColor, int> get timeLeft => _timeLeft;
  bool get timerEnabled => _timerEnabled;
  int get whiteWins => _whiteWins;
  int get blackWins => _blackWins;
  int get draws => _draws;

  ChessPiece? getPiece(int row, int col) => _game.board[row][col];

  bool isSelected(int row, int col) =>
      _selectedPosition?.row == row && _selectedPosition?.col == col;

  bool isLegalMove(int row, int col) =>
      _legalMoves.contains(ChessPosition(row, col));

  bool isLastMoveSquare(int row, int col) {
    if (_game.moveHistory.isEmpty) return false;
    final last = _game.moveHistory.last;
    return (last.from.row == row && last.from.col == col) ||
           (last.to.row == row && last.to.col == col);
  }

  bool isCheckSquare(int row, int col) {
    if (_game.status != GameStatus.check && _game.status != GameStatus.checkmate) return false;
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final p = _game.board[r][c];
        if (p != null && p.type == PieceType.king && p.color == _game.currentTurn) {
          return r == row && c == col;
        }
      }
    }
    return false;
  }

  void onSquareTap(int row, int col, {PieceType? promotionPiece}) {
    if (_game.isGameOver || _isAIThinking) return;
    if (_gameMode == GameMode.vsAI && _game.currentTurn == PieceColor.black) return;

    final pos = ChessPosition(row, col);
    final piece = _game.board[row][col];

    if (_selectedPosition != null && _legalMoves.contains(pos)) {
      _makeMove(_selectedPosition!, pos, promotionPiece: promotionPiece);
    } else if (piece != null && piece.color == _game.currentTurn) {
      _selectedPosition = pos;
      _legalMoves = _game.getLegalMoves(pos);
      notifyListeners();
    } else {
      _selectedPosition = null;
      _legalMoves = [];
      notifyListeners();
    }
  }

  void _makeMove(ChessPosition from, ChessPosition to, {PieceType? promotionPiece}) {
    // Check if pawn promotion needed
    final piece = _game.board[from.row][from.col];
    if (piece?.type == PieceType.pawn && (to.row == 0 || to.row == 7) && promotionPiece == null) {
      // Will be handled by UI - don't make move yet
      notifyListeners();
      return;
    }

    final success = _game.makeMove(from, to, promotionPiece: promotionPiece);
    if (success) {
      _selectedPosition = null;
      _legalMoves = [];
      _updateTimer();
      notifyListeners();

      if (_game.isGameOver) {
        _stopTimer();
        _updateStats();
      } else if (_gameMode == GameMode.vsAI) {
        _triggerAIMove();
      }
    }
  }

  void _triggerAIMove() async {
    _isAIThinking = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    final ai = _ai ?? ChessAI(_difficulty);
    final bestMove = ai.getBestMove(_game);
    
    if (bestMove != null && !_game.isGameOver) {
      _game.makeMove(bestMove['from']!, bestMove['to']!);
      _updateTimer();
    }

    _isAIThinking = false;
    notifyListeners();

    if (_game.isGameOver) {
      _stopTimer();
      _updateStats();
    }
  }

  void startNewGame({GameMode? mode, AIDifficulty? difficulty, int? timeSeconds}) {
    _gameMode = mode ?? _gameMode;
    _difficulty = difficulty ?? _difficulty;
    _ai = _gameMode == GameMode.vsAI ? ChessAI(_difficulty) : null;
    
    _game = ChessGame();
    _selectedPosition = null;
    _legalMoves = [];
    _isAIThinking = false;
    
    _timerEnabled = timeSeconds != null;
    if (_timerEnabled) {
      _timeLeft = {
        PieceColor.white: timeSeconds!,
        PieceColor.black: timeSeconds,
      };
    }
    
    _stopTimer();
    if (_timerEnabled) _startTimer();
    
    notifyListeners();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_game.isGameOver) {
        _stopTimer();
        return;
      }
      final current = _game.currentTurn;
      _timeLeft[current] = (_timeLeft[current] ?? 0) - 1;
      if ((_timeLeft[current] ?? 0) <= 0) {
        _game.resign(current);
        _stopTimer();
        _updateStats();
      }
      notifyListeners();
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _updateTimer() {
    // Timer keeps running - nothing to switch since it tracks currentTurn
  }

  void _updateStats() {
    final winner = _game.winner;
    if (winner == PieceColor.white) {
      _whiteWins++;
    } else if (winner == PieceColor.black) {
      _blackWins++;
    } else {
      _draws++;
    }
  }

  void resign() {
    if (!_game.isGameOver) {
      _game.resign(_game.currentTurn);
      _stopTimer();
      _updateStats();
      notifyListeners();
    }
  }

  void flipBoard() {
    _boardFlipped = !_boardFlipped;
    notifyListeners();
  }

  void toggleSound() {
    _soundEnabled = !_soundEnabled;
    notifyListeners();
  }

  void toggleCoordinates() {
    _showCoordinates = !_showCoordinates;
    notifyListeners();
  }

  String formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
}

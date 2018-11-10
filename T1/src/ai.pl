moves_piece([], _Board, _Level, _BestVal, BestMove, BestMove) :- write('BEST MOVE 1:'), write(BestMove), nl.

moves_piece([Move | Rest], Board, Level, BestVal, BestMove, BestMovePiece):-
    move_ai(Move, Board, NewBoard),
    minimax(NewBoard, Level, false, MoveVal),     
    ( 
        (
            MoveVal > BestVal,
            moves_piece( Rest, Board, Level, MoveVal, Move, BestMovePiece)
        );
        moves_piece( Rest, Board, Level, BestVal, BestMove, BestMovePiece)
    ).

find_best_move_aux(_Board, _Level, [], _BestVal, BestMove, BestMove):- 
    nextPlayer(Player), 
    retract(nextPlayer(Player)), 
    assert(nextPlayer(2)),
    write('BEST MOVE 3:'),write(BestMove),nl.

find_best_move_aux(Board, Level, [MovesPiece|RestPieces], BestVal, BestMove, VeryFinalMove):-
    moves_piece(MovesPiece, Board,Level, BestVal, BestMove, FinalMove),
    write('BEST MOVE 2:'),write(FinalMove),nl,
    find_best_move_aux(Board, Level, RestPieces, BestVal, FinalMove,VeryFinalMove).

find_best_move(Board, Level, ValidMoves, FinalMove):-
    BestVal is -1000,
    find_best_move_aux(Board, Level, ValidMoves, BestVal, _BestMove, FinalMove).

max_best_move(_Best, _Board, _Level, _IsMax, []).

max_best_move(Best, Board, Level, IsMax, [MovesPiece | RestPieces]):-
    max_best_move_piece(Best, Board, Level, IsMax, MovesPiece),
    max_best_move(Best, Board, Level, IsMax, RestPieces).

min_best_move(_Best, _Board, _Level, _IsMax, []).

min_best_move(Best, Board, Level, IsMax, [MovesPiece | RestPieces]):-
    min_best_move_piece(Best, Board, Level, IsMax, MovesPiece),
    min_best_move(Best, Board, Level, IsMax, RestPieces).

max_best_move_piece(_Best, _, _Level, _IsMax, []).

max_best_move_piece(Best, Board, Level, IsMax, [Move | Rest]):-
    move_ai(Move, Board, NewBoard),
    minimax(NewBoard,Level,not(IsMax),TempBest),
    NewBest is max(Best, TempBest),
    max_best_move_piece(NewBest, NewBoard, Level, IsMax, Rest).

min_best_move_piece(_Best, _Board, _Level, _IsMax, []).

min_best_move_piece(Best, Board, Level, IsMax, [Move | Rest]):-
    move_ai(Move, Board, NewBoard),    
    minimax(NewBoard,Level,not(IsMax),TempBest),
    NewBest is min(Best, TempBest),
    min_best_move_piece(NewBest, Board, Level, IsMax, Rest).

minimax(Board, 1, _IsMax, BestVal):- value(Board, BestVal).

minimax(Board, Level, IsMax, BestVal):-
    value(Board, BestVal),
    (BestVal \= 1, true);
    (   nextPlayer(Player),
        NewLevel is Level - 1,
        (
            (IsMax,
                (
                Best is -1000,
                BestVal is Best,
                valid_moves(Board, 2, ValidMoves),
                retract(nextPlayer(Player)),
                assert(nextPlayer(2)),
                max_best_move(Best, Board, NewLevel, IsMax, ValidMoves)
                )
            )
            ;
            (
                Best is 1000,
                BestVal is Best,
                valid_moves(Board, 1, ValidMoves),
                retract(nextPlayer(Player)),
                assert(nextPlayer(1)),
                min_best_move(Best, Board, NewLevel, IsMax, ValidMoves)
            )
        )  
    ).

/**
 * Return value for the current state of the game. Used by minimax.
 */ 
value(Board, Value):-
    game_over(Board, Winner),
    winner(Winner, Value).

move_ai([InitLine, InitCol, DestLine, DestCol], Board, NewBoard):-
        nextPlayer(Player),
        (   Player=1
        ->  set(black, Piece)
        ;   set(white, Piece)
        ),
        set_piece(InitLine, InitCol, Board, TempBoard, empty),
        set_piece(DestLine, DestCol, TempBoard, NewBoard, Piece).


/**
 * Return the value for the winner of the game.
 */ 
winner(black, 10).
winner(white, -10).
winner(none, 1).
winner(draw, 0).

choose_move(Board, Level, Move):-
    nextPlayer(Player),
    valid_moves(Board, Player, ValidMoves),
    find_best_move(Board,Level,ValidMoves,Move).

% Generic alpha beta algorithm from Bratko's Prolog programming for artificial intelligence
alphabeta(Pos, Alpha, Beta, GoodPos, Val, Depth) :-
    moves(Pos, PosList),!,
    boundedbest(PosList, Alpha, Beta, GoodPos, Val, Depth);
    staticval(Pos, Val).

moves(Pos, PosList).

staticval(Pos, Val).

min_to_move(Pos).

max_to_move(Pos).

boundedbest([Pos | PosList], Alpha, Beta, GoodPos, GoodVal, Depth) :-
    NextDepth is Depth - 1, 
    alphabeta(Pos, Alpha, Beta, _, Val, NextDepth),
    goodenough(PosList, Alpha, Beta, Pos, Val, GoodPos, GoodVal, Depth).

goodenough([],_,_, Pos, Val, Pos, Val, _) :- !.

goodenough(_, Alpha, Beta, Pos, Val, Pos, Val, _) :-
    min_to_move(Pos), Val > Beta,!; % Maximizer attained upper bound
    max_to_move(Pos), Val < Alpha,!.

goodenough(PosList, Alpha, Beta, Pos, Val, GoodPos, GoodVal, Depth) :-
    newbounds(Alpha, Beta, Pos, Val, NewAlpha, NewBeta), % Refine bounds
    boundedbest(PosList, NewAlpha, NewBeta, Pos1, Val1, Depth),
    betterof(Pos, Val, Pos1, Val1, GoodPos, GoodVal).

newbounds(Alpha, Beta, Pos, Val, Val, Beta) :-
    min_to_move(Pos), Val > Alpha,!.

newbounds(Alpha, Beta, Pos, Val, Alpha, Val) :-
    max_to_move(Pos), Val < Beta,!.

newbounds(Alpha, Beta, _, _, Alpha, Beta).

betterof(Pos, Val, _Pos1, Val1, Pos, Val) :- % Pos better than Posl
    min_to_move(Pos), Val > Val1, !;
    max_to_move(Pos), Val < Val1,!.

betterof( _, _, Pos1, Val1, Pos1, Val1).
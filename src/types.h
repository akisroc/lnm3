#ifndef LIBLNM3_TYPES_H
#define LIBLNM3_TYPES_H

#define NUMBER_OF_PHASES_IN_BATTLE 8

typedef unsigned short int PieceId;
typedef unsigned short int PieceAttribute;

/**
 * String representation of a troup. Example:
 *
 * 0000995/0000020/0000600/00000400/0000030/0000000/0000060/0000020
 *
 * This example features a troup of 995 P1s, 20 P2s, 600 P3s, 400 P4s,
 * 30 P5s, no P6s, 60 P7s and 20 P8s.
 * Leading zeros allow for a fix string length while keeping large enough
 * possibilites to never become a constraint (players will never get to
 * troups of 9 millons pieces).
 */
typedef char TroupNotation[65];

/**
 * String representation of the state of a battle. Example:
 *
 * 0000995/0000020/0000600/00000400/0000030/0000000/0000060/0000020 0000995/0000020/0000600/00000400/0000030/0000000/0000060/0000020 1 0
 *
 * First group is the attacker troup, in the same format as TroupNotation[65].
 * Second group is the defender troup.
 * Digit after third space tells if the battle is finished: 1 for yes, 0 for no.
 * Last digit after fourth space tells if the attacker won: 1 for yes, 0 for no.
 */
typedef char BattleStateNotation[134];

/**
 * String representation of the log of a battle. Example for a three phases battle:
 *
 * 0000995/0000020/0000600/00000400/0000030/0000000/0000060/0000020 0000995/0000020/0000600/00000400/0000030/0000000/0000060/0000020 0 0\n
 * 0000500/0000010/0000400/00000300/0000030/0000000/0000060/0000020 0000995/0000020/0000600/00000400/0000030/0000000/0000060/0000020 0 0\n
 * 0000400/0000005/0000600/00000400/0000030/0000000/0000060/0000020 0000995/0000020/0000400/00000000/0000020/0000000/0000060/0000020 1 0
 *
 * That’s battle states separated by \n. No trailing \n for last line.
 *
 * Last two digits must be 0 for all lines before the last one, as the battle
 * was not finished and the winner was not determined yet.
 */
typedef char BattleLogNotation[(133 + 1) * NUMBER_OF_PHASES_IN_BATTLE];

typedef enum {
    PIECE_TYPE_P1, PIECE_TYPE_P2, PIECE_TYPE_P3, PIECE_TYPE_P4,
    PIECE_TYPE_P5, PIECE_TYPE_P6, PIECE_TYPE_P7, PIECE_TYPE_P8
} PieceType;

typedef enum {
    PIECE_ATTACK_P1 = 4, PIECE_ATTACK_P2 = 3, PIECE_ATTACK_P3 = 5, PIECE_ATTACK_P4 = 5,
    PIECE_ATTACK_P5 = 18, PIECE_ATTACK_P6 = 10, PIECE_ATTACK_P7 = 24, PIECE_ATTACK_P8 = 19
} PieceAttack;

typedef enum {
    PIECE_DEFENSE_P1 = 7, PIECE_DEFENSE_P2 = 5, PIECE_DEFENSE_P3 = 9, PIECE_DEFENSE_P4 = 7,
    PIECE_DEFENSE_P5 = 8, PIECE_DEFENSE_P6 = 7, PIECE_DEFENSE_P7 = 16, PIECE_DEFENSE_P8 = 13
} PieceDefense;

typedef enum {
    PIECE_SPEED_P1 = 85, PIECE_SPEED_P2 = 86, PIECE_SPEED_P3 = 95, PIECE_SPEED_P4 = 84,
    PIECE_SPEED_P5 = 80, PIECE_SPEED_P6 = 98, PIECE_SPEED_P7 = 88, PIECE_SPEED_P8 = 90
} PieceSpeed;

typedef struct Piece {
    PieceId id;
    PieceType type;
    PieceAttack attack;
    PieceDefense defense;
    PieceSpeed speed;
} Piece;

#endif // LIBLNM3_TYPES_H

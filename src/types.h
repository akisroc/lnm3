#ifndef LIBLNM3_TYPES_H
#define LIBLNM3_TYPES_H

#define NUMBER_OF_PHASES_IN_BATTLE 8

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
typedef char BattleLogNotation[134 * NUMBER_OF_PHASES_IN_BATTLE];

typedef struct Piece {
    const unsigned short int attack;
    const unsigned short int defense;
    const unsigned short int speed;
    const bool distance;
} Piece;

#define P1 (Piece) { .attack = 4, .defense = 7, .speed = 85, .distance = false }
#define P2 (Piece) { .attack = 3, .defense = 5, .speed = 86, .distance = true }
#define P3 (Piece) { .attack = 5, .defense = 9, .speed = 95, .distance = false }
#define P4 (Piece) { .attack = 5, .defense = 7, .speed = 84, .distance = true }
#define P5 (Piece) { .attack = 18, .defense = 8, .speed = 80, .distance = false }
#define P6 (Piece) { .attack = 10, .defense = 7, .speed = 98, .distance = true }
#define P7 (Piece) { .attack = 24, .defense = 16, .speed = 88, .distance = false }
#define P8 (Piece) { .attack = 19, .defense = 13, .speed = 90, .distance = true }

#endif // LIBLNM3_TYPES_H

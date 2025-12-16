#ifndef LIBLNM3_TYPES_H
#define LIBLNM3_TYPES_H

#define NUMBER_OF_PHASES_IN_BATTLE 8

// Example: 0000995
#define UNIT_PADDING_SIZE 7
#define UNIT_PADDING_CHAR '0'
#define UNIT_PADDING "0000000"

/**
 * String representation of a unit of pieces. Example:
 *
 * 0000995
 *
 * This represents a unit of 995 pieces.
*
 * Leading zeros allow for a fix string length while keeping large enough
 * possibilites to never become a constraint (players will never get to
 * troups of 9 millons pieces).
 */
typedef char UnitNotation[UNIT_PADDING_SIZE + 1];

/**
 * String representation of a troup. Example:
 *
 * 0000995/0000020/0000600/0000400/0000030/0000000/0000060/0000020
 *
 * This example features a troup of 995 P1s, 20 P2s, 600 P3s, 400 P4s,
 * 30 P5s, no P6s, 60 P7s and 20 P8s.
 */
typedef char TroupNotation[65];

/**
 * String representation of the state of a battle. Example:
 *
 * 0000995/0000020/0000600/0000400/0000030/0000000/0000060/0000020 0000995/0000020/0000600/0000400/0000030/0000000/0000060/0000020
 *
 * First group is the attacker troup, in the same format as TroupNotation[65].
 * Second group is the defender troup.
 */
typedef char BattleStateNotation[134];

/**
 * String representation of the log of a battle. Example for a three phases battle:
 *
 * @todo Complete doc example with generated log as soon as the battle solving works
 * 0000995/0000020/0000600/0000400/0000030/0000000/0000060/0000020 0000995/0000020/0000600/0000400/0000030/0000000/0000060/0000020\n
 * P3/p1/0000060/0000080 p6/P6/0000060/0000040 […]\n
 * P3/p1/0000060/0000080 p6/P6/0000060/0000040 […]\n
 * P3/p1/0000060/0000080 p6/P6/0000060/0000040 […]\n
 * 0000400/0000005/0000600/0000400/0000030/0000000/0000060/0000020 0000995/0000020/0000400/00000000/0000020/0000000/0000060/0000020\n
 * 1
 *
 * – First line is the initial battle state.
 * – Next lines are the battle phases.
 *     Each phase is cut in successives salvos separated by spaces.
 *     Each salvo is cut as follows:
 *       – Which piece archetype strikes (uppercase pieces (ex: P1) for attacker, lowercase (ex: p1) for defender)
 *       – / Which piece archetype is striken
 *       – / How many pieces are killed
 *       – / How many pieces are wounded
 * – Last line is the result as a digit. 1 if attacker won. 0 if defender won. No trailing line break.
 *
 * Last two digits must be 0 for all lines before the last one, as the battle
 * was not finished and the winner was not determined yet.
 */
typedef char BattleLogNotation[134 * NUMBER_OF_PHASES_IN_BATTLE];

typedef int Troup[8];

typedef struct PieceArchetype {
    const float attack;
    const float defense;
    const float speed;
    const float kill_rate;
    const bool distance;
} PieceArchetype;

#define NB_OF_PIECES_ARCHETYPES 8
#define P1 (PieceArchetype) { .attack = 4.0, .defense = 7.0, .speed = 85.0, .kill_rate = 4.0 / 7.0, .distance = false }
#define P2 (PieceArchetype) { .attack = 3.0, .defense = 5.0, .speed = 86.0, .kill_rate = 3.0 / 5.0, .distance = true }
#define P3 (PieceArchetype) { .attack = 5.0, .defense = 9.0, .speed = 95.0, .kill_rate = 5.0 / 9.0, .distance = false }
#define P4 (PieceArchetype) { .attack = 5.0, .defense = 7.0, .speed = 84.0, .kill_rate = 5.0 / 7.0, .distance = true }
#define P5 (PieceArchetype) { .attack = 18.0, .defense = 8.0, .speed = 80.0, .kill_rate = 18.0 / 8.0, .distance = false }
#define P6 (PieceArchetype) { .attack = 10.0, .defense = 7.0, .speed = 98.0, .kill_rate = 10.0 / 7.0, .distance = true }
#define P7 (PieceArchetype) { .attack = 24.0, .defense = 16.0, .speed = 88.0, .kill_rate = 24.0 / 16.0, .distance = false }
#define P8 (PieceArchetype) { .attack = 19.0, .defense = 13.0, .speed = 90.0, .kill_rate = 19.0 / 13.0, .distance = true }
#define PIECES_ARCHETYPES (PieceArchetype[NB_OF_PIECES_ARCHETYPES]) { P1, P2, P3, P4, P5, P6, P7, P8 }

#endif // LIBLNM3_TYPES_H

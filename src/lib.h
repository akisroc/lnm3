#ifndef LIBLNM3_LIB_H
#define LIBLNM3_LIB_H

#include "types.h"
#include "stddef.h"

/**
 * Solve a battle from an initial state, and hydrates the battle log.
 *
 * @param initial_state
 * @param battle_log /!\ This will be mutated
 * @return 1 if attacker won, 0 if defender won
 */
bool solve_battle(const BattleStateNotation initial_state, BattleLogNotation battle_log);

/**
 * Parse troup notation and hydrates given Troup array.
 *
 * @param troup_notation
 * @param troup /!\ This will be mutated
 */
void parse_troup(const TroupNotation troup_notation, Troup troup);

void parse_battle_sate(const BattleStateNotation battle_state_notation, Troup attacker_troup, Troup defender_troup);

/**
 * Serialize troup array and hydrates given TroupNotation string.
 *
 * @param troup
 * @param troup_notation /!\ This will be mutated
 */
void serialize_troup(const Troup troup, size_t troup_size, TroupNotation troup_notation);

#endif // LIBLNM3_LIB_H

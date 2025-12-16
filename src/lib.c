#include "lib.h"

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>

// void solve_battle(const BattleStateNotation initial_state, BattleLogNotation *battle_log) {
//     srand(time(NULL));
//     // Deciding who goes first

// }

/**
 * Parse troup notation and hydrates given Troup array.
 *
 * @param troup_notation
 * @param troup
 */
void parse_troup(const TroupNotation troup_notation, Troup troup) {
    TroupNotation str_buffer;
    strcpy(str_buffer, troup_notation);

    char *token = strtok(str_buffer, "/");
    for (unsigned short int i = 0; token != NULL; ++i) {
        int n = atoi(token);
        troup[i] = n;
        token = strtok(NULL, "/");
    }
}

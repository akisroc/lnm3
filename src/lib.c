#include "lib.h"

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>

#define BINARY_RAND(void) rand() % 2 == 0

__attribute__((constructor))
static void lib_constructor(void) {
    srand(time(nullptr));
}

bool solve_battle(const BattleStateNotation initial_state, BattleLogNotation battle_log) {
    strcat(battle_log, initial_state);
    Troup attacker_troup = {0};
    Troup defender_troup = {0};
    parse_battle_sate(initial_state, attacker_troup, defender_troup);

    bool attacker_has_initiative = BINARY_RAND();
    printf("%d\n", attacker_has_initiative);

    return true;
}

void parse_troup(const TroupNotation troup_notation, Troup troup) {
    TroupNotation str_buffer = {0};
    strcpy(str_buffer, troup_notation);

    char *token = strtok(str_buffer, "/");
    for (size_t i = 0; token != NULL; ++i) {
        troup[i] = atof(token);
        token = strtok(nullptr, "/");
    }
}

void parse_battle_sate(const BattleStateNotation battle_state_notation, Troup attacker_troup, Troup defender_troup) {
    BattleStateNotation battle_state_notation_buffer = {0};
    strcpy(battle_state_notation_buffer, battle_state_notation);

    char *token = strtok(battle_state_notation_buffer, " ");
    parse_troup(token, attacker_troup);
    token = strtok(nullptr, " ");
    parse_troup(token, defender_troup);
}

void serialize_troup(const Troup troup, const size_t troup_size, TroupNotation troup_notation) {
    UnitNotation buffer = {0};
    for (size_t i = 0; i < troup_size; ++i) {
        snprintf(buffer, sizeof(buffer), "%0*d", UNIT_PADDING_SIZE, troup[i]);
        strcat(troup_notation, buffer);
        if (i < troup_size - 1) {
            strcat(troup_notation, "/");
        }
    }
}

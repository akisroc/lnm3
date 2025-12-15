#include "lib.h"

#include <stdio.h>
#include <stdlib.h>
#include <time.h>

Piece init_piece(const PieceType type) {
    switch (type) {
        case PIECE_TYPE_P1:
            return (Piece) { .id = PIECE_TYPE_P1, .type = PIECE_TYPE_P1, .attack = PIECE_ATTACK_P1, .defense = PIECE_DEFENSE_P1, .speed = PIECE_SPEED_P1 };
        case PIECE_TYPE_P2:
            return (Piece) { .id = PIECE_TYPE_P2, .type = PIECE_TYPE_P2, .attack = PIECE_ATTACK_P2, .defense = PIECE_DEFENSE_P2, .speed = PIECE_SPEED_P2 };
        case PIECE_TYPE_P3:
            return (Piece) { .id = PIECE_TYPE_P3, .type = PIECE_TYPE_P3, .attack = PIECE_ATTACK_P3, .defense = PIECE_DEFENSE_P3, .speed = PIECE_SPEED_P3 };
        case PIECE_TYPE_P4:
            return (Piece) { .id = PIECE_TYPE_P4, .type = PIECE_TYPE_P4, .attack = PIECE_ATTACK_P4, .defense = PIECE_DEFENSE_P4, .speed = PIECE_SPEED_P4 };
        case PIECE_TYPE_P5:
            return (Piece) { .id = PIECE_TYPE_P5, .type = PIECE_TYPE_P5, .attack = PIECE_ATTACK_P5, .defense = PIECE_DEFENSE_P5, .speed = PIECE_SPEED_P5 };
        case PIECE_TYPE_P6:
            return (Piece) { .id = PIECE_TYPE_P6, .type = PIECE_TYPE_P6, .attack = PIECE_ATTACK_P6, .defense = PIECE_DEFENSE_P6, .speed = PIECE_SPEED_P6 };
        case PIECE_TYPE_P7:
            return (Piece) { .id = PIECE_TYPE_P7, .type = PIECE_TYPE_P7, .attack = PIECE_ATTACK_P7, .defense = PIECE_DEFENSE_P7, .speed = PIECE_SPEED_P7 };
        case PIECE_TYPE_P8:
            return (Piece) { .id = PIECE_TYPE_P8, .type = PIECE_TYPE_P8, .attack = PIECE_ATTACK_P8, .defense = PIECE_DEFENSE_P8, .speed = PIECE_SPEED_P8 };
        default:
            fprintf(stderr, "Invalid piece type: %d\n", type);
            exit(EXIT_FAILURE);
    }
}

void solve_battle(const BattleStateNotation initial_state, BattleLogNotation *battle_log) {
    srand(time(NULL));
    // Deciding who goes first

}

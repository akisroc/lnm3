#include "../src/lib.h"
#include <assert.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#define FMT_GREEN "\033[32m"
#define FMT_RED "\033[31m"
#define FMT_RESET "\033[0m"
#define FMT_BOLD "\033[1m"

#define DISPLAY_SUCCESS(expr) \
            printf( \
                FMT_BOLD FMT_GREEN "OK " FMT_RESET "-> " FMT_BOLD FMT_GREEN "%s() " FMT_RESET "-> " FMT_BOLD FMT_GREEN "%s\n" FMT_RESET, \
                __func__, expr \
            )
#define DISPLAY_FAILURE(expr) \
            fprintf(stderr, \
                FMT_BOLD FMT_RED "----------------\n---- ABORTING TESTS\n----------------\n" FMT_RESET \
                FMT_BOLD FMT_RED "FAIL " FMT_RESET "-> " \
                FMT_BOLD FMT_RED "%s()\n"  FMT_RESET \
                "\tCould not assert: " FMT_BOLD FMT_RED "%s\n" FMT_RESET \
                FMT_BOLD FMT_RED "----------------\n" FMT_RESET, \
                __func__, expr \
            )
#define ASSERT(cond) if (!(cond)) { DISPLAY_FAILURE(#cond); abort(); } else { DISPLAY_SUCCESS(#cond); }

void test_parse_troup(void) {
    TroupNotation troup_notation = "0000995/0000020/0000600/0000400/0000030/0000000/0000060/0000020";
    Troup troup;
    parse_troup(troup_notation, troup);
    ASSERT(sizeof(troup) / sizeof(troup[0]) == 8);
    ASSERT(troup[0] == 995.0);
    ASSERT(troup[1] == 20.0);
    ASSERT(troup[2] == 600.0);
    ASSERT(troup[3] == 400.0);
    ASSERT(troup[4] == 30.0);
    ASSERT(troup[5] == 0.0);
    ASSERT(troup[6] == 60.0);
    ASSERT(troup[7] == 20.0);
}

void test_serialize_troup(void) {
    TroupNotation troup_notation = "0000995/0000020/0000600/00000400/0000030/0000000/0000060/0000020";
    Troup troup;
    parse_troup(troup_notation, troup);
    size_t troup_size = sizeof(troup) / sizeof(troup[0]);
    ASSERT(troup_size == 8);
    ASSERT(troup[0] == 995.0);

    TroupNotation notation_buffer = {0};
    serialize_troup(troup, troup_size, notation_buffer);
    ASSERT(strcmp(notation_buffer, "0000995/0000020/0000600/0000400/0000030/0000000/0000060/0000020") == 0);
}

void test_solve_battle(void) {
    BattleStateNotation initial_battle_state = "0000995/0000020/0000600/0000400/0000030/0000000/0000060/0000020 0000995/0000020/0000600/0000400/0000030/0000000/0000060/0000020";
    BattleLogNotation battle_log = {0};

    bool battle_result = solve_battle(initial_battle_state, battle_log);

    ASSERT(battle_result == 1 || battle_result == 0);
}

int main(void) {
    test_parse_troup();
    test_serialize_troup();
    test_solve_battle();

    return 0;
}

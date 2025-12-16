#include "../src/lib.h"
#include <assert.h>
#include <stdio.h>
#include <string.h>

#define FMT_GREEN "\033[32m"
#define FMT_RED "\033[31m"
#define FMT_RESET "\033[0m"
#define FMT_BOLD "\033[1m"

#define DISPLAY_SUCCESS() printf(FMT_BOLD FMT_GREEN "OK ----> " FMT_RESET FMT_BOLD "%s()\n" FMT_RESET, __func__)

int test_parse_troup(void) {
    TroupNotation troup_notation = "0000995/0000020/0000600/00000400/0000030/0000000/0000060/0000020";
    Troup troup;
    parse_troup(troup_notation, troup);
    assert(troup[0] == 995);
    assert(troup[1] == 20);
    assert(troup[2] == 600);
    assert(troup[3] == 400);
    assert(troup[4] == 30);
    assert(troup[5] == 0);
    assert(troup[6] == 60);
    assert(troup[7] == 20);

    DISPLAY_SUCCESS();

    return 0;
}

int main(void) {
    test_parse_troup();

    return 0;
}

#include "../src/lib.h"
#include <assert.h>
#include <stdio.h>
#include <string.h>

#define FMT_GREEN "\033[32m"
#define FMT_RED "\033[31m"
#define FMT_RESET "\033[0m"
#define FMT_BOLD "\033[1m"

#define DISPLAY_SUCCESS() printf(FMT_BOLD FMT_GREEN "OK ----> " FMT_RESET FMT_BOLD "%s()\n" FMT_RESET, __func__)

int test_init_piece(void) {
    TroupNotation message = "0000995/0000020/0000600/00000400/0000030/0000000/0000060/0000020";
    printf("%s\n", message);


    DISPLAY_SUCCESS();

    return 0;
}

int main(void) {
    test_init_piece();
    printf("%d\n", P1.defense);

    return 0;
}

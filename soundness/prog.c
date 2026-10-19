#include <stdio.h>
#include <stdlib.h>

__attribute__((noinline)) int f(int x)
{
    int a = x & 0x7fffffff; // analysis: zero or positive
    return a + 0x7fffffff;  // analysis: zero-or-pos + pos = pos (ignores overflow)
}

int main(int argc, char** argv)
{
    int x = argc > 1 ? atoi(argv[1]) : 1;
    printf("%d\n", f(x));
    return 0;
}
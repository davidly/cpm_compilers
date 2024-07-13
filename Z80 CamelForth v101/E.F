200 CONSTANT DIGITS
VARIABLE ARRAY DIGITS ALLOT
VARIABLE X

: E
    0 X !
    ARRAY DIGITS 1 FILL
    0 ARRAY C!
    2 1 ARRAY + C!

    DIGITS
    BEGIN DUP 9 > WHILE
        1 -
        DUP
        BEGIN DUP 0 <> WHILE
            X @ OVER /MOD
            ROT
            ROT
            OVER ARRAY + C!
            SWAP
            OVER 1 - ARRAY + C@
            10 * +
            X !
            1 -
        REPEAT
        DROP
        X @ .
    REPEAT
    CR
    ." done"
    ;

E
BYE


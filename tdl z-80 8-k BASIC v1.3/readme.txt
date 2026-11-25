sbasic can't load() text files; it only loads the binary form of parsed files
previously created with save().

instead, redirect stdin.

sbasic has no means (that I've found) to return to the OS aside from ^x

The .TXT files end after "run". When the program finishes, sbasic waits for more
input; ntvcm ends the app when redirected input is exhausted, so no ^x is needed.
(Earlier versions of these files ended with filler text and ^x, which only worked if
the ^x arrived after the program finished -- that depended on wall-clock time.)


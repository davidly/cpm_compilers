pragma optimize(time);
-- MatMul.pkg with the unused "With Util" removed so it builds in the Watcom-generated ntvcmdos.exe.

procedure MM is
    -- Jerry Pournelle's Floating Point Benchmark
    -- October 1982 Byte, pages 254 - 270
    -- Translated from Pascal into Janus/Ada, 3/13/83

    M : Constant integer := 20;
    N : Constant integer := 20;

    Subtype Real Is Float; -- Also can use Long_Float for comparision

    A : array( 0..20, 0..20 ) of Real;
    B : array( 0..20, 0..20 ) of Real;
    C : array( 0..20, 0..20 ) of Real;

    Summ : Real;

    Procedure Fill_A Is
    Begin
        For i In 0..20 Loop
            For j In 0..20 Loop
                A(i,j) := Real( i + j + 2 );
            End Loop;
        End Loop;
    End Fill_A;

    Procedure Fill_B Is
    Begin
        For i In 0..20 Loop
            For j In 0..20 Loop
                B(i,j) := Real( ( i + j + 2 ) / ( j + 1 ) );
            End Loop;
        End Loop;
    End Fill_B;

    Procedure Fill_C Is
    Begin
        For i In 0..20 Loop
            For j In 0..20 Loop
                C(i,j) := 0.0;
            End Loop;
        End Loop;
    End Fill_C;

    Procedure Matrix_Multiply Is
    Begin
        For i In 0..20 Loop
            For j In 0..20 Loop
                For k In 0..20 Loop
                    C(i,j) := C(i,j) + A(i,k) * B(k,j);
                End Loop;
            End Loop;
        End Loop;
    End Matrix_Multiply;

    Procedure Summit Is
    Begin
        For i In 0..20 Loop
            For j In 0..20 Loop
                Summ := Summ + C(i,j);
            End Loop;
        End Loop;
    End Summit;

Begin
    Summ := 0.0;
    Fill_A;
    Put(" A filled. "); New_line;
    Fill_B;
    Put(" B filled. "); New_line;
    Fill_C;
    Put(" C filled. "); New_line;
    Matrix_Multiply;
    Put(" Multiplied."); New_line;
    Summit;
    Put("Summ is : "); Put(Summ); New_Line;
End MM;

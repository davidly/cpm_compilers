program TESTP( OUTPUT, WRNFIL);
(*    'TESTP.PAS': Pascal installation test program.
      Sorcim Pascal/M:  seh  79-08-7*)

const
   WRNFILNAM='TPWARN.txt';
   VERSION='Testp: Version 10.24';

var
   CH: char;
   LINE: string;
   WRNFIL: text;

procedure Filetext;
begin
   Write  ( WRNFIL, 'Copyright (c) 1979 by Sorcim.');
   Writeln( WRNFIL, ' All rights reserved.');
   Write  ( WRNFIL, 'No part of the "PASCAL/M Software System"');
   Writeln( WRNFIL, ' covered by this License Agreement');
   Write  ( WRNFIL, 'may be reproduced, transmitted, transcribed,');
   Writeln( WRNFIL, ' stored in a retrieval system,');
   Write  ( WRNFIL, 'or translated into any language');
   Writeln( WRNFIL, ' or computer language, in any form,');
   Write  ( WRNFIL, 'or by any means, electronic, mechanical,');
   Writeln( WRNFIL, ' magnetic, optical, chemical,');
   Write  ( WRNFIL, 'manual, or otherwise, without the prior');
   Writeln( WRNFIL, ' written permission of');
   Writeln( WRNFIL, 'SORCIM, 2273 Calle De Luna, Santa Clara  CA  95050.');
   Writeln( WRNFIL);
   Writeln( WRNFIL, 'The files on this disk are as follows:');
   Writeln( WRNFIL, 'PASCAL.pco = Pascal compiler.');
   Writeln( WRNFIL, '  PRUN.com = Pascal P-code interpreter.');
   Writeln( WRNFIL, 'PASLIB.pco = Pascal library.');
   Writeln( WRNFIL, ' TESTP.pas = Pascal test program source code.');
                                         (*This file*)
end (*end Filetext*) ;

begin
   Page( OUTPUT);
      (*Write alphabetics*)
   for CH:='A' to 'Z' do
      Write( CH);
   Writeln;
   for CH:='a' to 'z' do
      Write( CH);
   Writeln; Writeln;
      (*Create TPWARN.txt*)
   {$I-} Reset( WRNFIL, WRNFILNAM); {$I+}
   Close  ( WRNFIL, PURGE);
   Rewrite( WRNFIL, WRNFILNAM);
   Filetext;
   Close  ( WRNFIL, LOCK);
      (*Copy TPWARN.txt to the console*)
   Reset  ( WRNFIL, WRNFILNAM);
   while not Eof( WRNFIL) do begin
      Readln ( WRNFIL, LINE);
      Writeln( LINE);
   end;
   Writeln;
end.

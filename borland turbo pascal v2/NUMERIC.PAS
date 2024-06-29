{ *****                                                }
{ ***** convert character string to positive integer   }
{ ***** tom de lellis                                  }
{ ***** 2/24/85                                        }
{ *****                                                }
{ ***** strng = string to convert                      }
{ *****                                                }
{ ***** numeric = value of string, returns             }
{ *****           0 if invalid numeric string          }
{ *****                                                }

type
  num_type=string[6];

function numeric(strng:num_type):integer;
var
  temp:num_type;
  valid:boolean;
  i,
  code:integer;
begin
if strng<>''
then
  begin
  temp:='';
  i:=1;
  valid:=true;
  while (i<=length(strng)) and (i<=6) and valid do
    if strng[i] in ['0'..'9']
    then
      begin
      temp:=temp+strng[i];
      i:=i+1;
      end
    else
      valid:=false;
  if temp<>''
  then
    begin
    val(temp,i,code);
    if code<>0
    then
      numeric:=0
    else
      numeric:=i;
    end
  else
    numeric:=0;
  end
else
  numeric:=0;
end;

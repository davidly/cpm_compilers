{ *****                               }
{ ***** yarbbs bulletin board section }
{ ***** tom de lellis                 }
{ ***** 2/24/85                       }
{ *****                               }

{$c-,r+,v-}

program bbs;

const
{$i bbsconst.inc}

type
{$i bbstypes.inc}

var
  nlist:string[255];
  cf:file;
  section:char;
  temp_name:name_type;
  temp_subject,
  temp2_subject:header_type;
  found,
  done,
  sysop,
  valid:boolean;
  e:file of message_text_type;
  message_text:message_text_type;
  f:file of header_type;
  header:header_type;
  g_temp,
  g:file of counter_type;
  counter_temp,
  counter:counter_type;
  h:file of common_info_type;
  common_info:common_info_type;
  j,
  k,
  i:integer;
  cmnd,
  answer,
  answer1,
  answer2,
  numst:string[4];
  pass:string[7];
  delim:string[1];

{$i cron.inc}
{$i ioparam.inc}
{$i exists.inc}
{$i abort.inc}
{$i numeric.inc}
{$i wipeibuf.inc}
{$i dispfile.inc}

procedure open_up(var section:char;urgent_info:boolean);
begin
assign(g,'COUNTERS.BD'+section);
reset(g);
read(g,counter);
if counter.board_status=inactive_board
then
  begin
  section:='0';
  assign(g,'COUNTERS.BD'+section);
  reset(g);
  read(g,counter);
  end;
if counter.board_sysop=common_info.name
then
  begin
  counter.board_use_by_sysop:=counter.board_use_by_sysop+1;
  sysop:=true;
  end
else
  begin
  counter.board_use_by_all:=counter.board_use_by_all+1;
  sysop:=false;
  end;
set_dcd_check(false);
reset(g);
write(g,counter);
flush(g);
set_dcd_check(true);
assign(e,'TEXT.BD'+section);
reset(e);
assign(f,'SUBJECTS.BD'+section);
reset(f);
if counter.board_name<>''
then
  writeln('Segment name: "',counter.board_name,'"');
writeln('   Total messaged entered: ',counter.total_entered);
writeln('   Total active messages:  ',counter.total_active);
writeln;
if urgent_info
then
  display_file('IMPORTNT.BD'+section,'',1);
end;

{$i input.inc}
{$i skip.inc}
{$i disccnt.inc}
{$i editor.inc}
{$i fifo.inc}
{$i delmsg.inc}
{$i summon.inc}
{$i displog.inc}
{$i chpass.inc}
{$i readmsg.inc}
{$i setmode.inc}
{$i switchb.inc}
{$i savemsg.inc}

begin
set_warmboot(false);
set_defdrv(system_drive,system_user);
set_file_number(1);
set_dcd_check(true);
writeln;
assign(h,'COMMON.DTA');
reset(h);
read(h,common_info);
close(h);
section:=common_info.default_board;
writeln('Bulletin Board  Type: <?> and hit the <RETURN> key for help');
open_up(section,true);
display_file('BBSMENU.BD'+section,'BBS.MNU',3);
repeat
  repeat
    write('Command: (SEG',section,') ');
    input(cmnd,4,4,0,true,true,true,true,common_info.single_key,true);
  until cmnd<>'';
  if (cmnd='OFF') or (cmnd='BYE')
  then
    cmnd:='T';
  if length(cmnd)=1
  then
    case cmnd[1] of
    'P':
      change_passwd;
    'K',
    'D':
      if (common_info.can_enter_messages) or
         (common_info.status=super_user) or
         sysop
      then
        begin
        if counter.total_active<>0
        then
          begin
          valid:=false;
          write('Delete message number: ');
          input(numst,5,4,0,true,false,true,true,false,true);
          i:=numeric(numst);
          if (i<=counter.last_active) and (i>0)
          then
            begin
            seek(f,i-1);
            read(f,header);
            if header.attribute=not_in_use
            then
              writeln('  Message already deleted')
            else
              begin
              if ((header.password='-------') and
                 (header.receiver='')) or
                 (header.receiver=common_info.name) or
                 (header.sender=common_info.name) or
                 (common_info.status=super_user) or
                 sysop
              then
                valid:=true
              else
                if header.receiver=''
                then
                  begin
                  write('Password: ');
                  set_sio_echo(false);
                  write('(',header.password,') ');
                  set_sio_echo(true);
                  input(pass,8,7,0,true,true,true,true,false,true);
                  if pass=header.password
                  then
                    valid:=true;
                  end;
              if valid
              then
                delete_msg(i)
              else
                writeln('  Protection violation');
              end;
            end
          else
            if numst<>''
            then
              writeln('  Invalid message number');
          end
        else
          writeln('  No messages to delete');
        writeln;
        end
      else
        begin
        writeln('  Protection violation');
        writeln;
        end;
    'H',
    'S',
    'R':
      read_messages;
    'N':
      begin
      writeln('Please wait...');
      assign(cf,'PLIST.COM');
      execute(cf);
      end;
    'U':
       display_log;
    'O':
      chat;
    'B':
      display_file('BULLETIN.BD'+section,'NONEWS.INF',2);
    'I':
      display_file('SYSINF.INF','',2);
    'G',
    'Q',
    'T':
      disconnect(true,false,true);
    '?':
      display_file('BBSMENU.BD'+section,'BBS.MNU',3);
    'X':
      if (common_info.can_use_os) or
         (common_info.status=super_user) or
         sysop
      then
        begin
        writeln;
        display_file('OSINFO.INF','',2);
        set_warmboot(true);
        halt;
        end
      else
        begin
        writeln('  Protection violation');
        writeln;
        end;
    'W':
      switch_boards;
    'M':
      set_modes;
    'C',
    'E':
      if (common_info.can_enter_messages) or
         (common_info.status=super_user) or
         (cmnd='C') or
         sysop
      then
        begin
        flush_fifo;
        done:=false;
        if cmnd='C'
        then
          begin
          writeln('Comment to the operator of:');
          writeln;
          display_file('SUBSYS.MNU','',3);
          write('Choose: (',section,') ');
          input(answer,4,1,0,true,true,true,true,common_info.single_key,true);
          if (length(answer)=1) and (answer[1] in ['0'..common_info.max_seg])
          then
            begin
            assign(g_temp,'COUNTERS.BD'+answer);
            reset(g_temp);
            read(g_temp,counter_temp);
            close(g_temp);
            if counter_temp.board_status<>inactive_board
            then
              begin
              if section<>'0'
              then
                begin
                section:='0';
                writeln;
                writeln('Switching to segment ',section,', please wait...');
                open_up(section,false);
                end;
              writeln('Enter a message to the operator:');
              nlist:=counter_temp.board_sysop;
              repeat
                writeln;
                write('Subject:... ');
                input(header.subject,41,40,0,true,false,true,true,false,true);
                writeln;
                write('Is the above correct, or abort? (Y/N/A) ');
                input(answer,3,1,0,true,true,true,true,common_info.single_key,true);
                if answer=''
                then
                  answer:='A';
              until (answer='Y') or (answer='A');
              if answer='A'
              then
                done:=true;
              end
            else
              begin
              done:=true;
              writeln('  That sysop does not exist');
              end;
            end
          else
            begin
            done:=true;
            writeln('  That sysop does not exist');
            end;
          end
        else
          begin
          repeat
            write('Address a message to all or a specific user? (A/U) ');
            input(answer,4,1,0,true,true,true,true,common_info.single_key,true);
            writeln;
            if answer='U'
            then
              begin
              repeat
                write('Full name: ');
                input(nlist,255,254,0,true,true,true,true,false,true);
              until length(nlist)>=4;
              end
            else
              nlist:='';
            write('Subject:.. ');
            input(header.subject,41,40,0,true,false,true,true,false,true);
            writeln;
            write('Is the above correct, or abort? (Y/N/A) ');
            input(answer,3,1,0,true,true,true,true,common_info.single_key,true);
            if answer=''
            then
              answer:='A';
          until (answer='Y') or (answer='A');
          if answer='A'
          then
            done:=true;
          end;
        if not done
        then
          begin
          header.sender:=common_info.name;
          header.attribute:=public;
          header.signed_message:=true;
          if common_info.status>=privilaged
          then
            begin
            write('Is this a global message? (Y/N) ');
            input(answer,3,1,0,true,true,true,true,common_info.single_key,true);
            if answer='Y'
            then
              header.attribute:=global;
            end;
          if (nlist<>'') and
             (header.attribute<>global)
          then
            if not common_info.can_enter_messages
            then
              header.attribute:=private
            else
              begin
              write('Is this message private? (Y/N) ');
              input(answer,3,1,0,true,true,true,true,common_info.single_key,true);
              if answer='Y'
              then
                header.attribute:=private
              end;
          if ((counter.board_aok) and (common_info.can_enter_messages)) or
             (common_info.status=super_user)
          then
            begin
            write('Send this anonymously? (Y/N) ');
            input(answer,3,1,0,true,true,true,true,common_info.single_key,true);
            if answer='Y'
            then
              header.signed_message:=false;
            end;
          done:=true;
          enter_message(message_text,done,max_width,max_lines);
          if done
          then
            begin
            if nlist=''
            then
              begin
              repeat
                write('Deletion password: (7 characters max) ');
                input(header.password,8,7,0,true,true,true,true,false,true);
                if header.password=''
                then
                  begin
                  header.password:='-------';
                  writeln;
                  writeln('WARNING: With no deletion password, anybody that logs in has');
                  writeln('         the ability to delete your message.');
                  writeln;
                  write('Do you want a deletion password now? (Y/N) ');
                  input(answer,3,1,0,true,true,true,true,common_info.single_key,true);
                  if answer='Y'
                  then
                    writeln;
                  end;
              until (answer='N') or (header.password<>'-------');
              end
            else
              begin
              header.password:='';
              randomize;
              for i:=1 to random(4)+4 do
                header.password:=header.password+chr(random(63)+33);
              end;
            fifo_parse(nlist);
            valid:=false;
            while not empty_fifo do
              begin
              get_from_fifo(header.receiver);
              get_from_fifo(delim);
              if (length(header.receiver)>=4) or ((nlist='') and empty_fifo)
              then
                begin
                write('  Saving message');
                if header.receiver<>''
                then
                  write(' to ',header.receiver);
                writeln(', please wait...');
                header.date:=cron_time_stamp;
                save_message;
                valid:=true;
                end;
              end;
            if not valid
            then
              writeln('  Message ignored');
            end;
          end;
        writeln;
        end
      else
        begin
        writeln('  Protection violation');
        writeln;
        end;
    else
      begin
      writeln('  I don''t know what "',cmnd,'" means');
      writeln('  Type: <?> and hit the <RETURN> key for help');
      writeln;
      wipe_ibuff;
      end;
    end
  else
    begin
    writeln('  I don''t know what "',cmnd,'" means');
    writeln('  Type: <?> and hit the <RETURN> key for help');
    writeln;
    wipe_ibuff;
    end;
until false;
end.

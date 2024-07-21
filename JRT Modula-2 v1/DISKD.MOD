definition module disk;

export qualified
	status_conditions, file_variable, open, close,
	diskread, diskwrite, display_file, parse_filename,
	status_message;

type
char16 = array [1..16] of char;
char30000 = array [0..29999] of char;
status_conditions = (file_ok, name_error, not_found,
	no_disk_space, no_directory_space, parameter_error);
file_variable = record
	open_flag : integer;
	file_pos,
	ascii_eof_pos,
	absolute_eof_pos,
	buffer_pos : real;
	buffer : pointer to char30000;
	buffer_size,
	record_size : integer;
	buffer_equals_disk,
	ascii_eof,
	absolute_eof : boolean;
	status : status_conditions;

	fcb_disk : char;
	fcb_name : array [1..8] of char;
	fcb_type : array [1..3] of char;
	fcb_extent,
	fcb_s1,
	fcb_s2,
	fcb_record_count : char;
	fcb_blocks : char16;
	fcb_current_record : char;
	fcb_random_record : integer;
	fcb_x : char
	end;

procedure open (var fv : file_variable; name_type : char16;
	bufsize : integer; delete, create : boolean);
procedure close (var fv : file_variable);

(* if pos = -1.0 then use the current filepos (sequential I/O) *)
procedure diskread (var fv : file_variable; pos : real; count : integer;
	var buf : char30000);
procedure diskwrite ( var fv : file_variable; pos : real;
	count : integer; var buf : char30000 );

procedure display_file (fv : file_variable);
procedure parse_filename ( x : char16; var fv : file_variable );
procedure status_message ( var fv : file_variable ): char16;

end disk.

(* Chuong trinh doc/ghi Sector * Thai Hung Van -  Dai hoc Tong hop *)
   Uses Crt,Dos,HVan;
   Const
      Hexchar : array[0..$F] of char = '0123456789ABCDEF';
   Type Mang = Array[0..511] of byte;
   Label t;
   Var
     Buff : Mang;
     Drive,sector,track,head,wy : integer;
     i,j,k,l : word;
     Ch : Char;
     flag,exist,Ok : boolean;
     Regs :registers;


{----------------------------------------------------}
Function Readdisk(sector,track,disk,head:word) : byte;
 begin
   With Regs do
     begin
       ax := $0201;
       cl := sector;
       ch := track;
       dl := disk;
       dh := head;
       es := seg(buff);
       bx := ofs(buff);
     end;
   INTR($13,Regs);
   ReadDisk := regs.ah;
 end;
{------------------------------------------------------}
Function Writedisk(sector,track,drive,head:byte) : byte;
 begin
   With Regs do
     begin
       ax := $0301;
       cl := sector;
       ch := track;
       dl := drive;
       dh := head;
       es := seg(buff);
       bx := ofs(buff);
     end;
   INTR($13,Regs);
   WriteDisk := Regs.ah;
  end;
{----------------------------------------------------------}
Procedure Write_HexByte(b:byte);
  Begin
    Write(HexChar[B shr 4]);
    Write(HexChar[B and $F])
  End;
{-----------------------------------------------------------}
Procedure DiskInfo;
 Var c : char;
   Sector_size,Sector_per_Cluster,Cluster_per_Disk,Fat_Sector,
   Entry_per_Dir,Dir_Sector,Data_Cluster,Sector_per_Fat,Heads,
   Sector_per_Track,Fat_per_Disk,Data_Sector,Sector_per_Data ,t : word;
 Begin
   t := buff[12];
   Sector_Size := t*256 + Buff[11];
   Sector_per_Cluster := Buff[13];
   t := buff[20];
   Cluster_per_Disk := (t*256 + Buff[19]) div Sector_per_Cluster;
   t := buff[25];
   Sector_per_Track := t*256 + buff[24];
   t := buff[23];
   Sector_per_Fat := t*256 + Buff[22];
   Fat_Sector := Buff[14];
   Fat_per_Disk := Buff[16];
   t := buff[18];
   Entry_per_Dir := t*256 + Buff[17];
   t := Buff[27];
   Heads := t * 256 + Buff[26];
   Dir_Sector := Fat_Sector + Fat_per_Disk*Sector_per_Fat;
   Data_Sector := Dir_Sector + (Entry_per_Dir div 16);
   Sector_per_Data := Cluster_per_disk - Data_Sector;
   Data_Cluster := Data_Sector div Sector_per_Cluster;
   box(53,7,80,22,4);
   writexy(65,7,'INFO');
   window(54,8,80,21);
   write('                ');
   if Drive < 2 then writexyattr(7,1,'Floopy disk '+chr(65+Drive),$9)
   else writexyattr(8,1,'Hard disk C',$9);
   writeln(#13,#10,' Bytes per Sector : ',  Sector_Size);
   writeln(' Sectors per Cluster : ',Sector_per_Cluster);
   writeln(' Clusters per Disk : ',  Cluster_per_Disk );
   writeln(' Sectors per Track : ',  Sector_per_Track);
   writeln(' Fat Sector :  ',  Fat_Sector);
   writeln(' Sectors per Fat : ',  Sector_per_Fat);
   writeln(' Fat per Disk : ',  Fat_per_Disk);
   writeln(' Dir Sector : ',  Dir_Sector);
   writeln(' Numbers of Head : ',Heads);
   writeln(' Entry per Dir : ',  Entry_per_Dir);
   writeln(' Data Sector : ',  Data_Sector);
   writeln(' Sector per Data : ',Sector_per_Data);
   write(' Data Cluster : ',Data_cluster);
   c := readkey;
   window(1,1,80,24);
 End;
{---------------------------------------------------------}
Procedure ReadInput;
 Begin
   window(1,1,80,24);
   writexy(10,2,'Sector :    ');gotoxy(whereX-3,whereY);
   read_int(sector,1,17);
   writexy(27,2,'Track :    ');gotoxy(whereX-3,whereY);
   Read_int(track,0,700);
   writexy(44,2,'Drive :    ');gotoxy(whereX-3,whereY);
   readln(ch);
   case ch of
    'a'..'z' : Drive := ord(ch) - ord('a');
    'A'..'Z' : Drive := ord(ch) - ord('A');
    '0'..'9' : Drive := ord(ch) - ord('0');
   end;
   if Drive >= 2 then
     drive := drive + 126;
   writexy(59,2,'Head :    ');gotoxy(whereX-3,whereY);
   read_int(Head,0,33);
 End;
{---------------------------------------------------------}
Procedure ReadFile;
 Var filename : string [12];
   g : file of byte;
   i : word;
 Begin
   writexy(3,10,'File name : ');
   readln(filename);
   IF FILENAME = '' THEN EXIT;
   {$I-}
   assign(g,filename);
   reset(g);
   {$I+}
   if ioresult <> 0 then
     begin
       Ok := false;
       writexy(3,10,'      Open Error      ')
     end
   else
     begin
       for i := 0 to 511 do
	 read(g,buff[i]);
       close(g);
       exist := true;
     end
 End;
{---------------------------------------------------------}
Procedure WriteFile;
 Var filename : string [12];
   g : file of byte;
   i : word;
 Begin
   writexy(3,10,'File name : ');
   readln(filename);
   {$I-}
   assign(g,filename);
   rewrite(g);
   {$I+}
   if ioresult <> 0 then
     begin
       writexy(3,10,'     Open Error     ');
       Ok := false;
       sound(500);
       delay(300);
       nosound;
     end
   else
     begin
       for i := 0 to 511 do
	 write(g,buff[i]);
       close(g);
     end
 End;
{---------------------------------------------------------}
Procedure WriteSector;
 Var
   i : byte;
 Begin
   clrscr;
   writexyattr(7,1,'Write Sector :',$9);
   ReadInput;
(*   BUFF[14] := 45; {SECTOR DAU CUA FAT}*)
   i := 0;
   Repeat
     inc(i);
     Ok := (WriteDisk(Sector,Track,Drive,Head) = 0);
   Until Ok or (i = 5);{Neu xay ra loi thi ghi lai(toi da 5 lan)}
   if not Ok then
     begin
       writexy(25,1,'    Write disk error    ');
       sound(500);
       delay(300);
       nosound;
     end;
 End;
{---------------------------------------------------------}
Procedure ReadSector;
 Var
   i : byte;
 Begin
   writexyattr(7,1,'Read Sector :',$9);
   ReadInput;
   i := 0;
   Repeat
     inc(i);
     Ok := (ReadDisk(Sector,Track,Drive,Head) = 0);
   Until Ok or (i = 5);{Neu xay ra loi thi doc lai(toi da 5 lan)}
   if not Ok then
     writexy(25,1,'   Read disk error      ')
   else exist := true;
 End;
{---------------------------------------------------------}
Procedure ShowSector;
 Var
   i,j,k : word;
 Begin
   writeXYattr(30,4,'Content of sector',$70);
   writeln;write('  ');
   highvideo;
   for i := 0 to $F do
   write('  ',HexChar[i]);
   writeln(#13,#10);
   for i := 0 to $F do
   writeln(HexChar[i]);
   lowvideo;
   window(5,7,54,23);
   k := 0;
   for i := 1 to 16 do
     begin
       k := 16*(i-1);
       for j := k to (16*i-1) do
	 begin
	   Write_HexByte(buff[j]);
	   write(' ');
	 end;
       writeln;
     end;
         {Trinh bay cac ky tu Ascii tuong ung}
   window(54,7,69,23);
   for j := 0 to 255 do
   if (Buff[j] >= 32) {and (Buff[j] < 127)} then
     write(chr(Buff[j]))
   else
     write('.');
   window(3,1,80,24);
   writexy(25,24,'Press any key to continue');
   Ch := readkey;
   Scrollcol(5,7,69,22);
   delline;
   window(5,7,54,23);
   k := 0;
   for i := 1 to 16 do
     begin
       k := 16*(i-1);
       for j := k to (16*i-1) do
	 begin
	   write_HexByte(buff[j+256]);
	   write(' ');
	 end;
       writeln;
     end;
         {Trinh bay cac ky tu Ascii tuong ung}
   window(54,7,69,23);
   for j := 0 to 255 do
    if (Buff[j+256] > 32){ and (Buff[j+256] < 127) }then
      write(chr(Buff[j+256]))
    else
      write('.');
   if readkey='!' then;
   window(1,1,80,24);
 End;
{---------------------------------------------------------}
Procedure FindString ;
  Var
    save : boolean;
    kk : longint;
    ii : byte;
    tt : array[1..10] of string[20];
    h : text;
    filename : string[127];
    s : array[1..4] of string[128];
    i,j : word;
    Heads,Sector_per_Track,t : word;
  begin
     save := false;
     for i := 1 to 4 do
       begin
	 s[i] := '';
	 for j := 1 to 128 do s[i] := s[i] + ' ';
       end;
     filename := '';
     clrscr;
     writeln('  Capslock on  : Save sector into file');
     writeln('  Capslock off : Don''t save');
     ii := 0;
     repeat
       inc(ii);
       write(' String[',ii,'] : ');
       readln(tt[ii]);
     until tt[ii] = '';
     SetCapslock(1);
     dec(ii);
     if ii = 0 then exit;
     write(' Sector begin : ');
     readln(kk);
     write(' Drive : ');
     repeat
       ch := upcase(readkey);
       case ch of
	'A'..'Z' : Drive := ord(ch) - ord('A');
	'0'..'9' : Drive := ord(ch) - ord('0');
       end;
     until Ch in ['A'..'Z','0'..'9'];
     CLRSCR;
     writexy(44,2,'Drive : ');write(chr(ord('A')+Drive));
     if Drive >= 2 then
       drive := drive + 126;
     writexy(10,2,'Sector : ');
     writexy(27,2,'Track : ');
     writexy(59,2,'Head : ');
     writexy(30,3,'DOS Sector : ');

     i := 0;
     Repeat
       inc(i);
       if Drive < 2 then ok := (Readdisk(1,0,Drive,0) = 0)
       else ok := (Readdisk(1,0,Drive,1) = 0);
     Until ok or (i = 5);{Neu xay ra loi thi doc lai(toi da 5 lan)}
     if not Ok then
       begin
	 writeln('             Read disk error           ');
	 sound(500);delay(150);nosound;exit
       end
     else
       begin
         t := buff[25];
	 Sector_per_Track := t*256 + buff[24];
	 Heads := Buff[26];
       end;
     repeat
	 flag := false;
	 gotoxy(43,3);write(kk);
	 sector := 1 + kk mod Sector_per_Track;
	 gotoxy(19,2);
	 write(sector,'   ');
	 track := kk div (Sector_per_Track*Heads);
	 gotoxy(35,2);
	 write(track,'   ');
	 Head := (kk div Sector_per_Track) mod Heads;
	 gotoxy(66,2);
	 write(head);
	 for i := 1 to 4 do
	   begin
	     s[i] := '';
	     for l := 1 to 128 do s[i] := s[i] + ' ';
	   end;
     i := 0;
     Repeat
       inc(i);
       ok := (Readdisk(Sector,Track,Drive,Head) = 0);
     Until ok or (i = 5);{Neu xay ra loi thi doc lai(toi da 5 lan)}
     if not Ok then
       begin
	 writeln('        Read disk error             ');
	 sound(500);delay(250);nosound;
       end
     else
       begin
	 for i :=   0 to 127 do
           if (buff[i] > 31) or (Buff[i] in [9,10,13]) then
             s[1][i+1] := chr(buff[i]);
         s[1] := copy(s[4],101,28) + s[1];
	 for i := 128 to 255 do
           if (buff[i] > 31) or (Buff[i] in [9,10,13]) then
             s[2][i-127] := chr(buff[i]);
         s[2] := copy(s[1],101,28) + s[2];
	 for i := 255 to 383 do
           if (buff[i] > 31) or (Buff[i] in [9,10,13]) then
             s[3][i-255] := chr(buff[i]);
         s[3] := copy(s[2],101,28) + s[3];
	 for i := 383 to 511 do
           if (buff[i] > 31) or (Buff[i] in [9,10,13]) then
             s[4][i-383] := chr(buff[i]);
         s[4] := copy(s[3],101,28) + s[4];
	 i := 0;
	 while (I < 4) and not flag do
	   begin
	     inc(i);
	     j := 0;
	     repeat
	       inc(j);
	     until (pos(tt[j],s[i]) <> 0) or (j > ii);
	     flag := j <= ii;
	   end;
	if FLAG then
	 begin
	  writexy(53,4,'Found : ');writexyattr(61,4,tt[j],$8F);
          if i = 1 then writexy(53,5,'in first bytes');
          ShowSector;
          savescreen(9,5,69,23);
          box(9,5,69,23,4);
          window(10,6,68,22);
          clrscr;
          window(11,6,67,22);
          for i := 1 to 4 do write(s[i]);
	  if CAPSLOCK then
	   begin
	     writexyattr(23,17,'Save ?(Y/N)',$87);
	     Ch := readkey;
	     if not (Ch in ['n','N']) then
	       if filename <> '' then
		begin
		 for i := 1 to 4 do
		   write(h,s[i]);
		 writeln(h)
		end
	       else
		begin
		  writexy(22,17,'File name : ');
		  readln(filename);
                  if filename <> '' then
                   begin
		  assign(h,filename);
		  rewrite(h);
		  for i := 1 to 4 do
		    write(h,s[i]);
		  writeln(h);
		  save := true;
                   end
		end;
	      end;
           restorescreen(9,5,69,23);
           window(1,1,80,24);
	   writeXYattr(32,24,'Continue ? (Y/N)',$70);
	   Ch := readkey;
	   writexy(53,4,'                         ');
           writexy(53,5,'                      ');
	 end { if flag }
       End; {If Ok}
      inc(kk);
   Until (upcase(ch) in ['N',#27]) or (keypressed and (readkey = #27));
   if save then close(h);
End;
(*********************************************************)
 BEGIN
   wy := whereY;
   savescreen(1,1,80,wy);
   clrscr;
   writexy(18,25,'** Thai Hung Van - University of HCM City **');
   window(1,1,80,24);
   exist := false;
   Repeat
     clrscr;
     writexyattrK(3,1,'1.Read  Sector on Disk',$7,1,$F);
     writexyattrK(3,2,'2.Write Sector into Disk',$7,1,$F);
     writexyattrK(3,3,'3.Read  Sector from file',$7,1,$F);
     writexyattrK(3,4,'4.Write Sector into file',$7,1,$F);
     writexyattrK(3,5,'5.Find  String on Disk',$7,1,$F);
     writexyattrK(3,6,'6.Exit',$7,1,$F);
     writexy(3,9,'Enter for choice : ');
     repeat
       Ch := readkey;
       if (Ch in ['2','4']) and not exist then
	 writexy(3,10,'Must choice <2> or <4> before');
       gotoxy(22,9)
     until (Ch in [#27,'1'..'6']) and not((Ch in ['2','4']) and not exist);
     write(ch);
     gotoxy(3,10);clreol;
     Case Ch of
       '2' : WriteSector;
       '4' : WriteFile;
       '3' :
	  begin
	    ReadFile;
	    if Ok then
	      begin
		clrscr;
		ShowSector;
	      end
            else
	      begin
		sound(500);delay(250);
		nosound;
	      end;
	  end;
       '1' :
	  begin
	    clrscr;
	    ReadSector;
	    if Ok then
	      begin
		ShowSector;
		if (sector = 1) and (track = 0) and
		  ( ((drive<2)and(head=0)) or ((drive>=128)and(head=1))) then
		  Diskinfo;
	      end
	    else
	      begin
		sound(500);delay(250);
		nosound;
	      end;
	  end;
       '5' : FindString;
     end;
   Until (upcase(ch) in ['6','N',#27]);
   window(1,1,80,25);
   CLRSCR;
   restorescreen(1,1,80,wy);
   gotoxy(1,wy);
 END.


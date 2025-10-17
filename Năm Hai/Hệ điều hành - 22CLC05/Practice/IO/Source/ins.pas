Program Install;
{$M $8000,0,0} (*Dinh Lai kich thuoc Stack*)
Uses Dos;
Const Tb : string[28] = 'Rf_g Fsle T_l + BFRF RNFAK ';
Var
  g : file;
  f : Searchrec;
  Param1,Param2,Command,Opt,Tam,FileSpec : PathStr;
  dem,i : byte ;           {bien dem trong cac vong lap }
  ch : char;
{---------------------------------------------------------------------------}
 Function Capslock : boolean;
   Begin
     Capslock := (Mem[0:$417] and $40 = $40);
   End;
{---------------------------------------------------------------------------}
 Procedure Change_Code;
   Const TempName = 'TEMP.@@@';
   Var
    Infile : file of Char;
    Outfile :text;
    temp,ch,t : char;
    i,j : byte;
    s : string;
    Enter : boolean;
   Begin
     If ParamCount = 2 then
       begin
         Param1 := ParamStr(1);
         Param2 := ParamStr(2);
         if Param2[length(param2)] = '\' then
           begin
             i := length(Param1);
             while (i > 1) and not (Param1[i-1] in [':','\',' ']) do
               dec(i);
             Param2 := Param2 + Copy(Param1,i,length(Param1)-i+1)
           end;
       end
     Else
       begin
         Param1 := ParamStr(1);
         i := length(Param1);
         while (i >1) and not (Param1[i-1] in [':','\',' ']) do
           dec(i);
         Param2 := Copy(Param1,1,i-1) + TempName;
       end;
       Assign(InFile,Param1);
       {$I-}
       reset(infile);
       {$I+}
       if IoResult<>0 then
	 begin
	   writeln('File not found');
	   halt
	 end;
       Assign(OutFile,Param2);
       rewrite(outfile);
       While not eof(InFile) do
         begin
           s := '';
           enter := false;
	   i := 0;
	   while not enter and not eof(InFile) and (i < 253) do
	     begin
	       inc(i);
	       read(InFile,Ch);
	       s := s + Ch;
	    if not eof(Infile) then
	      begin
	       read(InFile,Ch);
               if Ch = #13 then
                 Enter := True
               else
                 begin
		   inc(I);
		   if ch = #92 then
                     Ch := #13;
		   Ch := Chr((ord(Ch) XOR $FF) XOR i);
                   if Ch = #13 then
                     Ch:= #92;
                   s := s + Ch;
		 end;
		end;
             end;
	   for j := 1 to i do
	     write(OutFile,s[j]);
           if Enter then
             begin
               t := #13;
               write(OutFile,t);
             end
         end;
       Close(InFile);
       Close(OutFile);
       If pos(TempName,Param2) <> 0 then
         begin
           Erase(InFile);
           Rename(OutFile,Param1);
         end;
    End;

BEGIN
  writeln;
  If ParamCount = 0 then
    begin
      writeln('Chuong trinh bao ve cac tap tin .COM va .EXE ');
      writeln('THAI HUNG VAN - DHTH TPHCM');
      writeln('Cac tham so can go vao : ');
      writeln('/P : Cai Password vao tap tin .COM hay .EXE can bao ve');
      writeln('/D : Dung 1 dia mem 1.2M lam chia khoa');
      writeln('/T : Dung 1 sector tren dia lam chia khoa');
      writeln(' Vi du : INS SK*.COM /P');
      halt;
    end;
  if ParamCount > 2 then
    begin
      writeln('Khong duoc qua 2 tham so');
      halt
    end;
  If not Capslock then
    Change_Code
  else
    begin
      if ParamCount = 1 then
	begin
          Tam := ParamStr(1);
	  Param1 := Copy(Tam,1,length(Tam)-2);
	  Param2 := Copy(Tam,length(Tam)-1,2);
        end
      else
        begin
          Param1 := ParamStr(1);
          Param2 := ParamStr(2);
        end;
      Param2[2] := UpCase(Param2[2]);
      if (Param2<>'/P') and (Param2<>'/S') and (Param2<>'/T') then
	begin
	  writeln('Tham so khong hop le');
	  halt
	end;
      Tam := '';
      for i := length(Param1) - 3 to length(Param1) do
      tam := tam + upcase(Param1[i]);
      if (tam<>'.EXE') and (tam<>'.COM') then
	begin
	  writeln('Chuong trinh chi bao ve cac tap tin .COM va .EXE');
	  halt
	end;
      if param2[1] <> '/' then
        begin
          writeln(' Tham so khong hop le');
          halt
        end;
      Case Param2[2] of
      'P' :
      if tam='.EXE' then
	begin
	  {$I-}
   	  assign(g,'Pass_Exe.COM');reset(g);{$I+}
          if IoResult<>0 then
	    begin
	      writeln('Khong tim thay tap tin Pass_Exe.COM');
              halt
 	    end;
	  close(g);
	  Command := 'Pass_Exe.COM';
        end
      else
	begin
	  {$I-}
          assign(g,'Pass_Com.COM');reset(g);{$I+}
	  if IoResult<>0 then
	    begin
	      writeln('Khong tim thay tap tin Pass_Com.COM');
	      halt
	    end;
          close(g);
	  Command := 'Pass_Com.COM';
	end;
      'D' :
      if tam='.EXE' then
	begin
	  {$I-}
	  assign(g,'PROT_EXE.COM');reset(g);{$I+}
	  if IoResult<>0 then
	    begin
	      writeln('Khong tim thay tap tin PROT_EXE.COM');
	      halt
	    end;
          close(g);
	  Command := 'PROT_EXE.COM';
	end
      else
	begin
	  {$I-}
	  assign(g,'PROT_COM.COM');reset(g);{$I+}
          close(g);
	  if IoResult<>0 then
	    begin
	      writeln('Khong tim thay tap tin PROT_COM.COM');
	      halt
	    end;
          close(g);
	  Command := 'PROT_COM.COM';
        end;
      'T' :
        if tam='.EXE' then
	  begin
	    {$I-}
	    assign(g,'EXE_PROT.COM');reset(g);{$I+}
	    if IoResult<>0 then
	      begin
	        writeln('Khong tim thay tap tin EXE_PROT.COM');
	        halt
	      end;
            close(g);
	    Command := 'EXE_PROT.COM';
	  end
        else
	  begin
	    {$I+}
	    assign(g,'COM_PROT.COM');reset(g);{$I-}
	    if IoResult<>0 then
	      begin
	      writeln('Khong tim thay tap tin COM_PROT.COM');
	      halt
	    end;
          close(g);
	  Command := 'COM_PROT.COM';
	end;
      end;{case}
      dem := 0;
      FindFirst(Param1,AnyFile,f);
      i := Length(Param1);
      while NOT (Param1[i] in [' ',':','\']) and (i > 0) do
        dec(i);
      if i > 0 then Param1 := copy(Param1,1,i)
      else Param1 := '';
      While DosError = 0 do
	begin
	  if (f.attr<>0) and (f.attr<>32) then
	    writeln('Hay doi thuoc tinh tap tin ',f.name,' truoc khi Install')
	  else
	    begin
	      writeln('Install file ',f.name);
	      Opt := Param1 + f.name;
	      SwapVectors;
	      Exec(Command,Opt);
	      SwapVectors;
	      if DosError <> 0 then
	        writeln('Khong Install duoc Tap tin ',f.name)
	      else
		inc(Dem);
	    end;
	  FindNext(f);
        end;{While}
      writeln('Da Install ',dem,' tap tin');
    end;
  write('Chuong trinh bao ve tap tin * ');
  for i := 1 to 28 do
    if tb[i] <> ' ' then
      write(chr(ord(tb[i])+2))
    else
      write(' ');
  writeln;
END.
{* Written by Thai Hung Van *}

 Program Cay_chan_doan;
 Uses Crt;
 Const
  Subtrees = 2;
 Type
   Element = ^Node;
   Node = record
	    pos : word;
	    question : boolean;
	    pointer : array[1..subtrees] of Element;
	  end;
   Reco = record
	    pos : word;
	    question : boolean;
	    pointer : array[1..subtrees] of boolean;
	  end;
   MyFile = File of Reco;
   str50 = string[50];
 Var
   Ch : char;
   i  : word;
   f  : MyFile;
   df : file of str50;
   Root,p,q  : Element;
   st,animal : str50;
{---------------------------------------------------------------------------}
 Procedure Tree_to_File(T : Element;var f : MyFile);
   var
     p : Element;
     x : Reco;
     i : byte;
   begin
     p := T;
     if p <> nil then
       begin
	 x.pos := p^.pos;
	 x.question := p^.question;
	 for i := 1 to Subtrees do
	   x.pointer[i] := (p^.pointer[i] <> nil);
	 write(f,x);
	 for i := 1 to subtrees do
	   Tree_to_File(p^.pointer[i],f);
       end;
   end;
{---------------------------------------------------------------------------}
 Procedure File_to_Tree(var f : MyFile;var T : Element);
   var
     x : Reco;
     i : byte;
   begin
     if not eof(f) then
       begin
	 read(f,x);
	 new(T);
	 T^.pos := x.pos;
	 T^.question := x.question;
	 for i := 1 to Subtrees do
	   if x.pointer[i] then File_to_Tree(f,T^.pointer[i])
	   else T^.pointer[i] := nil
	 end
   end;
{---------------------------------------------------------------------------}
 Procedure Ques(p : Element);
   begin
     seek(df,p^.pos);
     read(df,st);
     write('N¢ c¢ ',st,' ?(Y/N) ')
   end;
{---------------------------------------------------------------------------}
 Function Answer : char;
   Var Ch : char;
   Begin
     repeat
       Ch := upcase(readkey);
     until Ch in [#27,'Y','N'];
     if Ch = #27 then Halt;
     if ch = 'Y' then write(' Yes')
     else write(' No');
     Answer := Ch;
   end;
{--------------------------------------------------------------------------}
 BEGIN
   writeln;
   writeln('You think of animal and I will guess it');
   writeln('Answer each question with Yes or No');
   {$i-}
   Assign(f,'HV_Tree');
   reset(f);
   {$I+}
   if IOresult <> 0 then
     begin
       writeln;
       write('File not found - HV_Tree');
       halt
     end;
    {$i-}
   Assign(df,'HV.Dat');
   reset(df);
   {$I+}
   if IOresult <> 0 then
     begin
       writeln;
       write('File not found - HV.Dat');
       halt
     end;
   File_to_Tree(f,p);
   Root := p;
   close(f);
   while p^.question do
     begin
       writeln;
       Ques(p);
       if Answer = 'Y' then
	 p := p^.pointer[1]
       else p := p^.pointer[2];
     end;
   writeln;
   seek(df,p^.pos);
   read(df,st);
   write('N¢ l… con ',st,' ! Ok(Y/N)');
   if Answer = 'N' then
     begin
       writeln;
       write('I don''t know the animal that you are thinking of ,');
       write('what is it called ? ');
       readln(animal);
       for i := length(animal) to 50 do
         animal := animal + ' ';
       new(q);
       q^.pos := p^.pos;
       q^.question := false;
       for i := 1 to subtrees do
	 q^.pointer[i] := nil;
       write('Cho biet dac diem dac trung cua con vat : ');
       st := '';
       readln(st);
       for i := length(st) to 50 do
         st := st + ' ';
       p^.pos := filesize(df);
       p^.question := true;
       p^.pointer[2] := q;
       new(q);
       q^.question := false;
       q^.pos := filesize(df) + 1;
       for i := 1 to subtrees do
	 q^.pointer[i] := nil;
       p^.pointer[1] := q;
       write('Cap nhat tri thuc ? (Y/N)');
       if Answer = 'N' then halt;
       assign(f,'HV_Tree');
       rewrite(f);
       Tree_to_File(Root,f);
       close(f);
       seek(df,filesize(df));
       write(df,st);
       write(df,animal);
     end;
  writeln;
  writeln('Written by Thai Hung Van - University of Ho Chi Minh city-12/1993');
  close(df);
END.


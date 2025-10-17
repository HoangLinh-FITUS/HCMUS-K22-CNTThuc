{* Written by Thai Hung Van *}

Program Cay_chan_doan;
 Uses Crt;
 Const Subtrees = 2;
 Type  Element = ^Node;
   Node = record
	    pos : word;
	    question : boolean;
	    pointer : array[1..subtrees] of Element;
	  end;
   MyFile = File of word;
 Var i: word;
   f  : MyFile;
   df,g : text;
   Root,p,q  : Element;
   st,animal,temp : string[60];
{---------------------------------------------------------}
 Procedure Tree_to_File(T : Element;var f : MyFile);
   var p : Element;
     x,i : word;
   begin
     p := T;
     if p <> nil then
       begin
	 x := p^.pos;
	 if p^.question then x := x or $8000;
	 if p^.pointer[1] <> nil then x := x or $4000;
	 write(f,x);
	 for i := 1 to subtrees do
	   Tree_to_File(p^.pointer[i],f);
       end;
   end;
{--------------------------------------------------------}
 Procedure File_to_Tree(var f : MyFile;var T : Element);
   var x,i : word;
   begin
     if not eof(f) then
       begin
	 read(f,x);
	 new(T);
	 T^.pos := x and $3FFF;
	 T^.question := (x and $8000 = $8000);
	 for i := 1 to Subtrees do
	   if (x and $4000 = $4000) then
             File_to_Tree(f,T^.pointer[i])
	   else T^.pointer[i] := nil
       end
   end;
{------------------------------------------------------------}
 Procedure Ques(p : Element);
   begin
     reset(df);for i := 1 to p^.pos do readln(df,st);
     readln(df,st);
     close(df);
     write(#13,#10,'N¢ c¢ ',st,' ?(C/K) ')
   end;
{-------------------------------------------------------------}
 Function Answer : char;
   Var Ch : char;
   Begin
     repeat Ch := upcase(readkey);
     until  Ch in [#27,'C','K'];
     if Ch = #27 then Halt;
     if ch = 'C' then write(' C¢')
     else write(' Khìng');
     Answer := Ch;
   end;
{--------------------------------------------------------------------------}
 BEGIN
   writeln('Ban nghi~ và` 1 con vÉt , Tìi se~ do†n ra n¢ !');
   Assign(f,'KnowTree.Van');
   {$i-} reset(f); {$I+}
   if IOresult <> 0 then
     begin
       writeln(#13,#10,'Khìng c¢ file - KnowTree.Van');
       halt
     end;
   Assign(df,'Data.Van');
   {$i-} reset(df); {$I+}
   if IOresult <> 0 then
     begin
       writeln(#13,#10,'Khìng c¢ file - Data.Van');
       halt
     end;
   close(df);
   File_to_Tree(f,p);
   Root := p;
   while p^.question do
     begin
       Ques(p);
       if Answer = 'C' then p := p^.pointer[1]
       else p := p^.pointer[2];
     end;
   reset(df);for i := 1 to p^.pos do readln(df,st);
   readln(df,st);
   close(df);
   write(#13,#10,'N¢ lÖ con ',st,' ! C¢ d£ng khìng(C/K)');
   if Answer = 'K' then
     begin
       write(#13,#10,'Tìi do†n khìng ra! N¢ lÖ con gç ? ');
       readln(animal);
       new(q);
       q^.pos := p^.pos;
       q^.question := false;
       for i := 1 to subtrees do
	 q^.pointer[i] := nil;
       write('Cho biet dac diem dac trung cua con vat : ');
       readln(st);
       p^.pos := filesize(f);
       p^.question := true;
       p^.pointer[2] := q;
       new(q);
       q^.question := false;
       q^.pos := filesize(f) + 1;
       for i := 1 to subtrees do
	 q^.pointer[i] := nil;
       p^.pointer[1] := q;
       write('Cap nhat tri thuc ? (C/K)');
       if Answer = 'K' then halt;
       rename(df,'Data.Bak');
       reset(df);
       assign(g,'Data.Van');
       rewrite(g);
       for i := 1 to filesize(f) do
         begin
           readln(df,temp);
           writeln(g,temp);
         end;
       writeln(g,st);
       writeln(g,animal);
       close(df);close(g);
       erase(df);
       assign(f,'KnowTree.Van');
       rewrite(f);
       Tree_to_File(Root,f);
       close(f);
     end;
  writeln(#13,#10,'Written by Thai Hung Van - University of Ho Chi Minh city-12/1993');
END.


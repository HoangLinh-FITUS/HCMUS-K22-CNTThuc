{* Written by Thai Hung Van *}

{$F+}
{$B-}
{$R-}
{$I-}
{$L SetVfont.obj}
 Uses Dos,HVan,Vsystem,My_Mouse,Crt;
 Const
   Max = 100;
   TongSo_Tb = 22;
   tb { tham bien } : array[1..TongSo_Tb] of string[2] =
   ('ra','rb','rc','ha','hb','hc','ma','mb','mc','la',
    'lb','lc','p','a','b','c','r','A','B','C','R','S');
   MaxSubFunc = 5; { max so chuc nang cua menu con }
   Tao = 8;
   Them = 5;
 Type
   String2 = string[2];
   ByteArr5= array[1..5] of byte;
   Domain  = 1..TongSo_Tb;
   ByteArr = array[Domain] of byte;
   DSet = set of Domain;
   Nut = record
	   ct {cong thuc} : string[25];
	   b {bien} : bytearr5;
	 end;
 Var
   a : array[1..Max] of Nut;
   DaBiet,CanTim : DSet;
   So_ct : 0..Max;
   old,i,j,wy :byte;
   i_menu,i_top,oldattr : byte;
   Mouse,open : boolean;
   LightChar : array[0..MaxSubFunc-1] of byte;
   s1,s2 : string[50];
   s : string[78];
   Ch,ans : char;
   c : word;
   f : text;
{$I Menu.pas}
{****************************************************}
 Procedure SetVfont; external;
{****************************************************}
 Procedure PhanTich(s : string; var p : Nut; var error : byte);
 Const
   Vitu : array[1..8] of string[6] =
  ('ARCSIN','ARCCOS','ARCTG','ARCC','SIN','COS','EXP','ABS');
 Var
   t : string;
   i,j : byte;
   c : bytearr5;
 Begin
   while s[1] = #32 do
     delete(s,1,1);
   while pos('  ',s) <> 0 do
     delete(s,pos('  ',s),1);
   t := '';
   for i := 1 to length(s) do
     t := t + upcase(s[i]);
   if pos('CAC BIEN',t) <> 0 then
     begin
       p.ct := copy(s,1,pos('CAC BIEN',t)-1);
       s := copy(s,pos('CAC BIEN',t),length(s)-pos('CAC BIEN',t));
     end
   else { Phan tich }
     begin
       p.ct := s;
       for i := 1 to 8 do
	 while pos(Vitu[i],t) <> 0 do
	   begin
	     delete(s,pos(vitu[i],t),length(Vitu[i]));
	     delete(t,pos(vitu[i],t),length(Vitu[i]));
	   end;
     end;
   j := 0;
   for i := 1 to TongSo_tb do
     if pos(tb[i],s) <> 0 then
       begin
         delete(s,pos(tb[i],s),length(tb[i]));
	 inc(j);
	 if j <= 5 then p.b[j] := i;
       end;
   case j of
     0..2 : error := 2;
     3..5 :
       begin
         p.b[j+1] := 0;
         error := 0;
       end;
     else error := 1;
   end;
 end;
{------------------------------------------------------}
Procedure LoadData;
 Var
   f : text;
   s : string;
   error : byte;
   mess,mess1,mess2 : string[30];
 Begin
   So_ct := 0;
   assign(f,'TG.Dat');
   {$i-} reset(f); {$I+}
   if IOResult <> 0 then exit;
   repeat
     {$I-}readln(f,s);{$I+}
     if IOResult <> 0 then exit;
     while (length(s) >= 1) and (s[1] = ' ') do delete(s,1,1);
   until s <> '';
   inc(So_ct);
   mess := 'Cong thuc ';
   mess1 := 'Khong hieu cong thuc ';
   mess2 := '.Bo qua(B) hay Ngung chuong trinh(N) ? ';
   if monoscreen then
     begin
       mess := 'C“ng thuc ';
       mess1 := 'Kh“ng hiˆu c“ng thuc ';
       mess2 := '.Bo qua(B) hay Ngung chuong trnh(N) ? '
     end;
   writexy(1,wy,mess);write(So_ct,' : ',s,' => ');
   PhanTich(s,a[So_ct],error);
   if error <> 0 then
     begin
       writexy(1,wy,mess1 + s + mess2);
       repeat
         ch := upcase(readkey);
       until ch in [#27,'B','N'];
       if ch = 'B' then
         begin
           dec(So_ct);
           gotoxy(1,wy);
           delline;
         end
       else Goodbye;
     end
   else
    while not eof(f) do
     begin
       repeat
         readln(f,s);
         if IOResult <> 0 then exit;
         while (length(s) >= 1) and (s[1] = ' ') do delete(s,1,1);
       until s <> '';
       inc(So_ct);
       gotoxy(1,wy);delline;
       writexy(1,wy,mess);write(So_ct,' : ',s,' => ');
       PhanTich(s,a[So_ct],error);
       if error <> 0 then
	 begin
           writexy(1,wy,mess1 + s + mess2);
           repeat
	     ch := upcase(readkey);
	   until (ch in [#27,'B','N']);
           if ch = 'B' then
             begin
               dec(So_ct);
               gotoxy(1,wy);
               delline;
	     end
	   else Goodbye;
	 end
       else
	 begin
	   write(a[so_ct].ct);
	   delay(70);
	 end;
     end;
   gotoxy(1,wy);delline;
   close(f);
 End;
{-----------------------------------------}
Function Order(b : string2) : byte;
 Var i : byte;
 Begin
   i := 0;
   repeat
     inc(i);
   until (i > TongSo_tb) or (tb[i] = b) ;
   Order := i;
 End;
{-----------------------------------------}
 Procedure Loi_Giai;
   var s : array[1..4] of string[30];
{.......................................}
Procedure Doc_tb(var Tap_tb : DSet);
 Var
   b : string[2];
   s : string[80];
   x,y,i,j : byte;
   flag : boolean;
 Begin
   x := WhereX;y := WhereY;
   tap_tb := [];
   repeat
     flag := false;
     readln(s);
     if s = '' then exit;
     while pos('  ',s) <> 0 do delete(s,pos('  ',s),1);
     while pos(' ,',s) <> 0 do delete(s,pos(' ,',s),1);
     while pos(' ;',s) <> 0 do delete(s,pos(' ;',s),1);
     while pos(',,',s) <> 0 do delete(s,pos(',,',s),1);
     while pos(';;',s) <> 0 do delete(s,pos(';;',s),1);
     i := 1;
     repeat
       if s[i] = ',' then inc(i);
       while s[i] = ' ' do inc(i);
       b := s[i];
       case s[i] of
       'h' :
	 if s[i+1] in ['a'..'c'] then
	   begin
	     inc(i);
	     b := b + s[i];
	   end
	 else
	   flag := true;
       'r' :
         if s[i+1] in ['a'..'c'] then
	   begin
	     inc(i);
	     b := b + s[i];
	   end
	 else if not(s[i+1] in [',',' ']) and (i < length(s)) then
		flag := true;
       'A'..'C','R','S','a'..'c','p' :
       else  flag := true;
       end;{case}
       if flag then
	 begin
           tap_tb := [];
	   i := WhereX;
	   sound(900);delay(100);nosound;
           if monoscreen then
             writexy(i,whereY,'Nhƒp biˆn sai , hay nhƒp lai')
           else
	     writexy(i,whereY,'Nhƒp biˆn sai , hay nhƒp lai');
	   delay(1200);
	   writexy(i,whereY,'                            ');
	   gotoxy(x,y);
	   for i := 1 to length(s) do write(' ');
	   gotoxy(x,y);
	 end
       else
	 Tap_tb := Tap_tb + [order(b)];
       inc(i);
     until (i > length(s)) or flag;
   until not flag;
 End;
{-----------------------------------------------}
 Procedure Giai(Dabiet,Cantim : DSet);
  Type
    Element = record
		pt {phan tu},
		ct { cong thuc} : byte
	      end;
  Var
    top1,top2,i,j : byte;
    stack : array[0..Max] of Element;
    kh {kich hoat} : array[1..Max] of boolean;
    Contim,Phaico : DSet;
    s1,s2,s3,s4 : string[30];
    flag : boolean;
    old : word;
{.................................................}
Function KichHoat(b : bytearr5; DaBiet : DSet; var j : byte) : boolean;
 Var i : byte;
 Begin
   i := 0;
   repeat
     inc(i);
   until ((i > 5) or (b[i] = 0)) or not(b[i] in DaBiet);
   if (i > 5) or (b[i] = 0) then
     begin
       kh[i] := true;
       KichHoat := False;
       exit
     end;
   j := b[i];
   repeat
     inc(i);
   until ((i > 5)or(b[i] = 0)) or not(b[i] in DaBiet);
   KichHoat := (i > 5) or (b[i] = 0)
 End;
{.................................................}
  Begin
    top1 := 0;
    Contim := CanTim;
    for i := 1 to So_ct do kh[i] := false;
    repeat
      flag := false;
      for i := 1 to So_ct do
	if not kh[i] and KichHoat(a[i].b,DaBiet,j) then
	  begin
	    kh[i] := true;
	    DaBiet := DaBiet + [j];
	    ConTim := ConTim - [j];
	    inc(top1);
	    stack[top1].ct := i;stack[top1].pt := j;
	    flag := true;
	  end;
      until (ConTim <= DaBiet) or not flag;
      s1 := '  Kh“ng du c” s” dˆ giai ';
      s2 := ' Suy du”c ';
      s3 := ' tu c“ng thc ';
      s4 := ' Kh“ng du c” s” dˆ suy ra c c yˆ£ t“ c•n lai';
      if monoscreen then
        begin
          s1 := '  Kh“ng du c” s” dˆ giai ';
          s2 := ' Suy du”c ';
          s3 := ' tu c“ng thc ';
          s4 := ' Kh“ng du c” s” dˆ suy ra c c yˆ£ t“'' c•n lai'
        end;
      if ConTim = CanTim then
	writeln(s1)
      else
	begin
	  top2 := Max + 1;
	  PhaiCo := CanTim;
	  repeat
	    while not(stack[top1].pt in PhaiCo) and (top1 > 0) do
	      dec(top1);
	    if top1 > 0 then
	      begin
		j := 1;
		repeat
		  PhaiCo := PhaiCo + [a[stack[top1].ct].b[j]];
		  inc(j);
		until (j > 5) or (a[stack[top1].ct].b[j] = 0);
		dec(top2);
		stack[top2].ct := stack[top1].ct;
		stack[top2].pt := stack[top1].pt;
		dec(top1);
	      end;
	  until top1 = 0;
	  window(1,1,80,25);
	  old := textattr;
	  SaveScreen(14,10-((max - top2) div 2),67,16+((max-top2)div 2));
	  textattr := $2F;
	  zoombox(14,10-((max - top2) div 2),65,15+((max-top2)div 2),2);
	  window(15,11-((max - top2) div 2),64,14+((max-top2)div 2));
	  clrscr;
	  for i := top2 to Max do
            write(#13,#10,s2,tb[stack[i].pt],s3,a[stack[i].ct].ct);
	  if ConTim <> [] then
	    write(#13,#10,s4);
	  ch := readkey;
	  textattr := old;
          window(1,1,80,25);
	  RestoreScreen(14,10-((max - top2) div 2),67,16+((max-top2)div 2));
	  window(14,13,65,16);
	  clrscr;
	end;
 End;
{-----------------------------------------------------------}
 Begin
   Introduce;
   window(14,13,65,16);
   if monoscreen then
     begin
       s[1] := '  C c yˆ£ t“'' da~ biˆt : ';
       s[2] := '  C c yˆ£ t“'' cƒn tm : ';
       s[3] := ' dˆ— da~ biˆt !';
       s[4] := '  C¢ tiˆp tuc kh“ng ?(C/K) '
     end
   else
     begin
       s[1] := '  C c yˆ£ t“'' da~ biˆt : ';
       s[2] := '  C c yˆ£ t“'' cƒn tm : ';
       s[3] := ' dˆ— da~ biˆt !';
       s[4] := '  C¢ tiˆp tuc kh“ng ?(C/K) '
     end;
   repeat
     write(s[1]);
     Doc_tb(DaBiet);
     if DaBiet = [] then exit;
     write(s[2]);
     Doc_tb(CanTim);
     CanTim := CanTim - DaBiet;
     if CanTim = [] then
       writeln(s[2]+s[3])
     else
       Giai(DaBiet,CanTim);
     write(s[4]);
     repeat
       ch := upcase(readkey);
     until (ch in [#27,'C','K']) or Capslock;
     clrscr;
   until (ch in [#27,'K']) or Capslock;
 End;
{-------------------------------------------------------}
Procedure Xemtb;
  Const s : array[1..10] of string[44] = (
   'A,B,C : 3 g¢c cua tam gi c                  ',
   'a,b,c : 3 canh tuong ung                    ',
   'S : Diˆn t¡ch tam gi c                      ',
   'p : nua chu vi tam gi c                     ',
   'R : b n k¡nh duong tr•n ngoai tiˆp tam gi c ',
   'r : b n k¡nh duong tr•n noi tiˆp tam gi c   ',
   'ra,rb,rc : 3 b n k¡nh duong tr•n b…ng tiˆp  ',
   'ha,hb,hc : 3 duong cao ung voi 3 canh a,b,c ',
   'la,lb,lc : 3 duong phƒn gi c cua 3 g¢c A,B,C',
   'ma,mb,mc : 3 duong trung tuyˆn ung voi a,b,c');
  xtop = 17;
  ytop = 7;
 Begin
   if not monoscreen then
     begin
       s[1] := 'A,B,C : 3 goc cua tam giac';
       s[2] := 'a,b,c : 3 canh tuong ung';
       s[3] := 'S : Dien tich tam giac';
       s[4] := 'p : nua chu vi tam giac';
       s[5] := 'R : ban kinh duong tron ngoai tiep tam giac';
       s[6] := 'r : ban kinh duong tron noi tiep tam giac';
       s[7] := 'ra,rb,rc : 3 ban kinh duong tron bang tiep';
       s[8] := 'ha,hb,hc : 3 duong cao ung voi 3 canh a,b,c';
       s[9] := 'la,lb,lc : 3 duong phan giac cua 3 goc A,B,C';
       s[10]:= 'ma,mb,mc : 3 duong trung tuyen ung voi a,b,c';
     end;
   zoombox(xtop,ytop,xtop+47,ytop+11,4);
   for i := 1 to 10 do
     writexy(xtop+2,ytop+i,s[i]);
 End;
{-------------------------------------------------------}
Procedure XemCt;
  Const num = 38;
        F1 = #59;
        PGUP = #73;
        PGDW = #81;
  Var start,i : integer;
      Ch : char;
      old : byte;
 {....................................................}
  Function Min(x,y:integer) : integer;
    begin
      min := x;
      if x > y then min :=y
    end;
 {....................................................}
  Begin
    setwin(2,23,78,23,' ',textattr);
    if So_ct > 40 then
      if monoscreen then
        writexy(6,21,'Su dung c c ph¡m mui tˆn lˆn xu“ng v… PGUP/PGDW ' +
                   'dˆ xem phƒn kˆ tiˆp')
      else writexy(6,21,'Su dung cac phim mui ten len xuong va PGUP/PGDW ' +
                   'de xem phan ke tiep');
    window(2,3,78,21);
    start := 1;
    old := textattr;
    textattr := $F;
    repeat
      clrscr;
      for i := start to start+min(So_ct-start,num-1) do
        begin
          gotoxy(((i-start) mod 2)*40+5,(i-start) shr 1 + 1);
          textcolor(Lightgray);
          write(i:2,'> ');
          textcolor(White);
          write(a[i].ct);
        end;
      repeat
        ch := readkey;
      until ch in [F1,#27,#13,UP,DOWN,PGUP,PGDW];
      case ch of
        F1 : begin
               Message;
               window(2,3,78,21);
             end;
        UP : if start > 2 then dec(start,2);
        DOWN : if (start <= So_ct-1) and (start+num <= So_ct) then
                 inc(start,2);
        PGUP : if start-num >= 1 then dec(start,num)
               else start := 1;
        PGDW : if start+num <= So_ct then inc(start,num);
      end;
    until ch in [#13,#27];
    textattr := old;
    window(2,3,79,23);
    writexy(1,21,
'                                                                            ');
 End;
{----------------------------------------------------------------}
 Procedure Tao_Them_Trithuc(opt:byte);
   Var ans : char;
       i,error : byte;
       s : string[35];
       tblq : string[2];
       temp : nut;
       old : byte;
       f : text;
   Begin
     textattr := $07;
     window(20,9,60,16);
     zoombox(20,9,60,16,2);
     if monoscreen then
       writexyattr(24,9,'Nhap c“ng thuc, Enter de ket thuc',$9)
     else writexyattr(24,9,'Nhap c“ng thuc, Enter de ket thuc',$9);
     window(21,10,59,15);
     clrscr;
     if opt = 8 then
       begin
         So_ct := 0;
         temp := a[1];
       end
     else if opt = 5 then old := So_ct;
     if monoscreen then write(' C“ng thuc ',So_ct+1,' : ')
     else  write(' C“ng thuc ',So_ct+1,' : ');
     readln(s);
     while (length(s)>=1) and (s[1] = ' ') do delete(s,1,1);
     while s <> '' do
       begin
         inc(so_ct);
         PhanTich(s,a[so_ct],error);
         if error = 2 then
           begin
             if monoscreen then writeln(' Kh“ng hieu c“ng thuc n…y')
             else writeln(' Kh“ng hieu c“ng thuc n…y');
             dec(so_ct);
           end
         else if error = 1 then
           begin
             if monoscreen then write(' C“ng thuc n…y c¢ d£ng kh“ng ?(C/K)')
             else write(' C“ng thuc n…y c¢ dung kh“ng ?(C/K)');
             repeat
               ans := upcase(readkey);
             until ans in ['C','K',#27];
             writeln(ans);
             if ans = 'C' then
               begin
                 if monoscreen then
                   write(#13,#10,' S“'' tham biˆn trong c“ng thuc : ')
                 else write(#13,#10,' So tham bien trong c“ng thuc : ');
                 ch := readkey;
                 writeln(ch);
                 if ch in ['3'..'5'] then
                   begin
                     for i := 1 to ord(ch)-ord('0') do
                       repeat
                         if monoscreen then write(' Tham biˆn ',i,' : ')
                         else  write(' Tham bien ',i,' : ');
                         readln(tblq);
                         if order(tblq) > Tongso_tb then
                           begin
                             sound(500);
                             delay(150);
                             nosound;
                           end
                         else
                           a[so_ct].b[i] := order(tblq);
                       until order(tblq) <= Tongso_tb;
                     if i < 5 then
                       a[so_ct].b[i+1] := 0
                   end
                 else
                   if monoscreen then
                     writeln(' Sai ! S“'' biˆn phai l… 3,4 hoac 5')
                   else writeln(' Sai ! So bien phai la 3,4 hoac 5');
               end
             else dec(so_ct);
           end;
         if monoscreen then write(' C“ng thuc ',so_ct+1,' : ')
         else write(' C“ng thuc ',so_ct+1,' : ');
         readln(s);
         while (length(s) >= 1)and(s[1] = ' ') do delete(s,1,1);
       end;{while}
     clrscr;
     if (opt = 8) and (so_ct = 0) then
       begin
         a[1] := temp;
         exit;
       end
     else if (opt = 5) and (So_ct = old) then
       exit;
     if monoscreen then
       write(#13,#10,' C¢ luu tri thuc moi lˆn dia ?(C/K)')
     else write(#13,#10,' Co luu tri thuc moi len dia ?(C/K)');
     repeat
       ans := upcase(readkey);
     until ans in ['C','K',#27];
     writeln(ans);
     if ans = 'C' then
       begin
         assign(f,'TG.DAT');
         rewrite(f);
         for i := 1 to so_ct do
           writeln(f,a[i].ct);
         close(f);
       end
     else So_ct := 0;
     window(2,3,79,23);
   End;
{--------------------------------------------------------------------}
Procedure Huy_Sua_Ct(opt:byte);
  Var
    wy,error : byte;
    n : integer;
    ans,ch : char;
    s,t1,t2,t3,t4 : string[40];
    f : text;
    temp : nut;
    Dahuysua : boolean;
    status,tblq : string[3];
{--------------------------------------------------------------------}
 Procedure ReadInt(inf,sup : integer;var x : integer);
   Label L;
   Var
     a : array[0..255] of word;
     wx,wy,xpos,ypos : byte;
     Th,T : set of char;
     ch : char;
     s : string;
     error : integer;
     n : longint;
(********************************************************************)
   Procedure Save(wx,wy:byte);
     Var i,w : word;
     Begin
       w := (wy-1)*160 + (wx-1)*2;
       for i := 0 to 25 do
	 a[i] := memw[SegTVR:w+2*i];
     End;
(********************************************************************)
   Procedure Restore(wx,wy:byte);
     Var i,w : word;
     Begin
       w := (wy-1)*160 + (wx-1)*2;
       for i := 0 to 25 do
	 memw[SegTVR:w+2*i] := a[i];
     End;
(********************************************************************)
   Begin
     wx := whereX;
     wy := whereY;
     save(wx,wy);
 L : Th := [#27,'0'..'9'];
     T := [#8,#13,#27,#75];
     x := 0;
     repeat
       runningstar(14,7,67,17,6,3,on,textattr,24,ch);
       if ch = #0 then ch := readkey;
       if ch = #59 then      {F1}
         begin
           xpos := whereX;
           ypos := whereY;
           hidecursor(1);
           message;
           hidecursor(0);
           gotoxy(xpos,ypos);
         end;
     until ch in Th;
     if ch = #27 then exit;
     write(ch);
     s := ch;
     Th := Th + T;
     repeat
       repeat
	 runningstar(14,7,67,17,6,3,on,textattr,4,ch);
         if ch = #0 then ch := readkey;
         if ch = #59 then      {F1}
          begin
           xpos := whereX;
           ypos := whereY;
           hidecursor(1);
           message;
           hidecursor(0);
           gotoxy(xpos,ypos);
          end;
       until ((ch in Th)and(length(s)<7)) or ((length(S)>=7)and(ch in T));
       case ch of
	 #8,#75 :
	   begin
	     delete(s,length(s),1);
	     restore(wx,wy);
	     writexy(wx,wy,s);
	     if s = '' then
	       begin
		 gotoxy(wx,wy);
		 goto L;
	       end;
	   end;
	 '0'..'9' :
	   begin
	     s := s + ch;
	     write(ch);
	   end;
         #27 : exit;
       end;
     until (ch = #13);
     if length(s) > 5 then error := 1
     else  val(s,n,error);
     if (error <> 0) or (n < inf) or (n > sup) then
       begin
	 restore(wx,wy);
         if monoscreen then
  	   writexy(wx,wy,'Nhƒp s“ thuoc doan [')
         else writexy(wx,wy,'Nhap s“ thuoc doan [');
	 write(1,'..',so_ct,']');
	 delay(500);
	 restore(wx,wy);
	 gotoxy(wx,wy);
	 goto L;
       end;
     x := n;
   End;
{----------------------------------------------------------------}
Begin
  window(1,1,80,25);
  Dahuysua := false;
  writexy(21,23,s1);
  case opt of
    7 : status := 'Huy';
    6 : status := 'Sua';
  end;
  t1 := ' m“t c“ng thuc trong he th“ng tri thuc';
  t2 := 'Nhap v…o s“ thu tu cua c“ng thuc can ';
  t3 := 'S“ c“ng thuc = ';
  t4 := 'Da huy c“ng thuc ';
  if monoscreen then
    begin
      t1 := ' m“t c“ng thuc trong hˆ th“ng tri thuc';
      t2 := 'Nhap v…o s“ thu tu cua c“ng thuc cƒn ';
      t3 := 'S“ c“ng thuc = ';
      t4 := 'Da huy c“ng thuc ';
      case opt of
        7 : status := 'Huy';
        6 : status := 'Sua';
      end;
    end;
  repeat
    setwin(14,7,68,17,' ',$7);
    writexyattr(20,8,status + t1,$9);
    writexy(20,10,t2 + status + ' : ');
    writexy(20,11,t3);
    readint(1,So_ct,n);
    if n = 0 then exit;
    temp := a[n];
    if monoscreen then
      begin
        writexy(20,12,'C“ng thuc cƒn ' + status + ' la ' + a[n].ct);
        writexy(20,13,'C¢ '+ status + ' c“ng thuc n…y kh“ng ? (C/K) ');
      end
    else
      begin
        writexy(20,12,'C“ng thuc can ' + status + ' la ' + a[n].ct);
        writexy(20,13,'Co '+ status + ' c“ng thuc n…y kh“ng ? (C/K) ');
      end;
    repeat
      runningstar(14,7,67,17,6,3,on,textattr,24,ch);
    until ch in ['C','K',#27];
    write(ch);
    if ch = 'C' then
    if status[1] = 'H' then
      begin
        writexy(20,14,t4 + a[n].ct);
        for i := n to So_ct - 1 do
          a[i] := a[i+1];
        dec(So_ct);
      end

    else { Sua }
      begin
        writexy(20,13,'                                            ');
        window(20,13,65,17);
        repeat
          if monoscreen then write('C“ng thuc ',n,' : ')
          else write('C“ng thuc ',n,' : ');
          readln(s);
          while (length(s)>=1) and (s[1] = ' ') do delete(s,1,1);
          if s <> '' then
            begin
              PhanTich(s,a[n],error);
              if error = 2 then
                if monoscreen then writeln(' Kh“ng hieu c“ng thuc n…y ')
                else writeln(' Kh“ng hieu c“ng thuc n…y ')
              else if error = 1 then
                begin
                  if monoscreen then
                    write(' C“ng thuc n…y c¢ d£ng kh“ng ?(C/K)')
                  else  write(' C“ng thuc n…y c¢ dung kh“ng ?(C/K)');
                  repeat
                    ans := upcase(readkey);
                  until ans in ['C','K',#27];
                  writeln(ans);
                  if ans = 'C' then
                    begin
                      if monoscreen then
                        write(#13,#10,' S“ tham biˆn trong c“ng thuc : ')
                      else write(#13,#10,' So tham bien trong c“ng thuc : ');
                      ch := readkey;
                      writeln(ch);
                      if ch in ['3'..'5'] then
                        begin
                          for i := 1 to ord(ch)-ord('0') do
                           repeat
                             if monoscreen then write(' Tham bien ',i,' : ')
                             else write(' Tham bien ',i,' : ');
                             readln(tblq);
                             if order(tblq) > Tongso_tb then
                               begin
                                 sound(500);
                                 delay(150);
                                 nosound;
                               end
                             else
                               a[n].b[i] := order(tblq);
                           until order(tblq) <= Tongso_tb;
                          if i < 5 then
                            a[n].b[i+1] := 0
                        end
                      else
                        if monoscreen then
                          writeln(' Sai ! S“'' biˆn phai la 3,4 hoac 5')
                        else writeln(' Sai ! So bien phai la 3,4 hoac 5');
                    end
                end;
              end;{if}
            delay(700);
            clrscr;
          until (error = 0) or (s = '');
          if s = '' then
            begin
              a[n] := temp;
              exit
            end;
        window(1,1,80,25);
        if not Dahuysua then
          begin
           assign(f,'TG.BAK');
           {$I-} erase(f); {$I+}
           if ioresult <> 0 then;
           assign(f,'TG.DAT');
           {$I-}reset(f);{$I+}
           if ioresult <> 0 then
             begin
               writexyattr(19,21,s2,$8F);
               readln;
               Goodbye;
             end;
           close(f);
           rename(f,'TG.BAK');
           assign(f,'TG.DAT');
          end;
        rewrite(f);
        for i := 1 to So_ct do
          writeln(f,a[i].ct);
        Dahuysua := true;
      end;
    if monoscreen then
      writexy(20,15,'C¢ ' + status + ' c“ng thuc kh c kh“ng ? (C/K) ')
    else writexy(20,15,'Co ' + status + ' c“ng thuc khac kh“ng ? (C/K) ');
    repeat
      runningstar(14,7,67,17,6,3,on,textattr,24,ch);
    until ch in ['C','K',#27];
    write(ch);
  until ch in ['k','K',#27];
  if Dahuysua then close(f);
  window(2,3,79,23);
End;
(*********************************************************************)
 BEGIN
   InitMusic;
   if VGAScreen then SetVFont;
   wy := whereY;
   SaveScreen(1,1,80,wy);
   oldattr := textattr;
   LoadData;
   s1 := 'Tri thuc cu duoc luu lai trong tep TG.BAK';
   s2 := 'Kh“ng tim thay tri thuc trong tep TG.Dat!';
   s := s2 + ' Tao moi hay kh“ng ?(T/K)';
   if MonoScreen then
     begin
       s1 := 'Tri thuc cu duoc luu lai trong tˆp TG.BAK';
       s2 := 'Kh“ng tim thay tri thuc trong tˆp TG.Dat!';
       s := s2 + ' Tao moi hay kh“ng ?(T/K)';
     end;
   if So_ct = 0 then
     begin
       write(#13,#10,s);
       repeat
         ch := upcase(readkey);
       until ch in [#27,'T','K'];
       if Ch = 'T' then
         Tao_them_Trithuc(8)
       else Goodbye;
     end;

   LightBk(1);
   if VGAScreen then
     begin
       setDACcolor(1,25,31,63);
       setDACcolor(4,50,0,0);
       setDACcolor(3,60,50,25);
       setDACcolor(7,63,63,63);
     end;

   Mouse := Reset_Mouse;
   i_menu := 1;
   window(1,1,80,25);
   Textbackground(0);
   clrscr;
   if not monoscreen then
     begin
       Textattr := $17;
       SetWin(1,1,79,25,' ',$17);
     end;
   Repeat
      Menu;
      case i_menu of
	1 : Loi_Giai;
        6,7 : Huy_Sua_Ct(i_menu);
        5,8 :
          begin
            old := So_ct;
            writexy(20,21,s1);
            assign(f,'TG.BAK');
            {$I-} erase(f); {$I+}
            if ioresult <> 0 then;
            assign(f,'TG.DAT');
            {$I-}reset(f);{$I+}
            if ioresult <> 0 then
              begin
                writexyattr(20,21,s2,$8F);
                readln;
                Goodbye;
              end;
            close(f);
            {$I-}rename(f,'TG.BAK');{$I+}
            while ioresult <> 0 do
              begin
                goodbye;
              end;
            Tao_them_trithuc(i_menu);
            if ((i_menu = 8)and(So_ct = 0)) or ((i_menu=5)and(So_ct=old))then
              begin
                So_ct := old;
                rename(f,'TG.DAT');
              end;
            writexy(20,21,'                                         ');
          end;
        10 : XemTb;
        11 : XemCt;
	4 : Goodbye;
      end;{end case}
      if i_menu in [5..8] then
	i_menu := 2;
      if i_menu in [10..12] then
	i_menu := 3;
      window(1,1,80,25);
    Until Ch = 'Q';
END.




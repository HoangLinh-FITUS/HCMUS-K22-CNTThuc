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

{****************************************************}
 Procedure SetVfont; external;
(************)
{$I Menu.pas}
{****************************************************}
 Procedure PhanTich(s : string; var p : Nut; var error : byte);
 Const
   Vitu : array[1..8] of string[6] =
  ('ARCSIN','ARCCOS','ARCTG','ARCC','SIN','COS','EXP','ABS');
 Var
   t : string;
   i,j,k : byte;
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
         for k := j+1 to 5 do
           p.b[k] := 0;
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
   mess,mess1,mess2 : string[70];
 Begin
   So_ct := 0;
   assign(f,'TG.Dat');
   {$i-} reset(f); {$I+}
   if IOResult <> 0 then exit;
   repeat
     {$I-}readln(f,s);{$I+}
     if IOResult <> 0 then exit;
     while (length(s) >= 1) and (s[1] = ' ') do delete(s,1,1);
   until (s <> '') or eof(f);
   inc(So_ct);
   mess := 'C§ng thÊc ';
   mess1 := 'Kh§ng hióu c§ng thÊc ';
   mess2 := '.B° qua(B) hay NgÁng chÂ™ng trõnh(N) ? ';
   if monoscreen then
     begin
       mess := 'Cìng thuc ';
       mess1 := 'Khìng hiàu cìng thuc ';
       mess2 := '.Bo qua(B) hay Ngung chuong trçnh(N) ? '
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
   var
    s : array[1..4] of string[30];
    oldattr : byte;
{.......................................}
Procedure Doc_tb(var Tap_tb : DSet);
 Var
   b : string[2];
   s : string[80];
   x,y,i,j,len_s : byte;
   flag : boolean;
 Begin
   x := WhereX;y := WhereY;
   tap_tb := [];
   repeat
     flag := false;
     readln(s);
     if s = '' then exit;
     len_s := length(s);
     while s[length(s)] = ' ' do s := copy(s,1,length(s)-1);
     while pos('  ',s) <> 0 do delete(s,pos('  ',s),1);
     while pos(' ,',s) <> 0 do delete(s,pos(' ,',s),1);
     while pos(' ;',s) <> 0 do delete(s,pos(' ;',s),1);
     while pos(',,',s) <> 0 do delete(s,pos(',,',s),1);
     while pos(';;',s) <> 0 do delete(s,pos(';;',s),1);
     if s = '' then exit;
     i := 1;
     repeat
       while s[i] in [' ',',',';'] do inc(i);
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
             writexy(i,whereY,'NhÉp biàn sai , hay nhÉp lai')
           else
	     writexy(i,whereY,'Nhàp biïn sai , hÅy nhàp lÇi');
	   delay(1200);
	   writexy(i,whereY,'                            ');
	   gotoxy(x,y);
	   for i := 1 to len_s do write(' ');
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
    s1,s2,s3,s4 : string[60];
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
      s1 := '  Kh§ng ‚ c™ s≠ ó giÄi ';
      s2 := ' Suy ÂØc ';
      s3 := ' tÁ c§ng thÊc ';
      s4 := ' Kh§ng ‚ c™ s≠ ó suy ra c~c yïu t• c†n lÇi';
      if monoscreen then
        begin
          s1 := '  Khìng du cî sî dà giai ';
          s2 := ' Suy duîc ';
          s3 := ' tu cìng thÅc ';
          s4 := ' Khìng du cî sî dà suy ra c†c yà£ tì'' cïn lai'
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
   oldattr := textattr;
   Introduce;
   textattr := $6F;
   window(14,13,65,16);
   if monoscreen then
     begin
       s[1] := '  C†c yà£ tì'' da~ biàt : ';
       s[2] := '  C†c yà£ tì'' cÉn tçm : ';
       s[3] := ' dàó da~ biàt !';
       s[4] := '  C¢ tiàp tuc khìng ?(C/K) '
     end
   else
     begin
       s[1] := '  C~c yïu t• Å biït : ';
       s[2] := '  C~c yïu t• cÖn tõm : ';
       s[3] := ' ñu Å biït !';
       s[4] := '  Cü tiïp t‰c kh§ng ?(C/K) '
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
   textattr := oldattr;
 End;
{-------------------------------------------------------}
Procedure Xemtb;
  Const s : array[1..10] of string[44] = (
   'A,B,C : 3 g¢c cua tam gi†c                  ',
   'a,b,c : 3 canh tuong ung                    ',
   'S : Diàn t°ch tam gi†c                      ',
   'p : nua chu vi tam gi†c                     ',
   'R : b†n k°nh duong trïn ngoai tiàp tam gi†c ',
   'r : b†n k°nh duong trïn noi tiàp tam gi†c   ',
   'ra,rb,rc : 3 b†n k°nh duong trïn bÖng tiàp  ',
   'ha,hb,hc : 3 duong cao ung voi 3 canh a,b,c ',
   'la,lb,lc : 3 duong phÉn gi†c cua 3 g¢c A,B,C',
   'ma,mb,mc : 3 duong trung tuyàn ung voi a,b,c');
  xtop = 17;
  ytop = 7;
 Begin
   if not monoscreen then
     begin
       s[1] := 'A,B,C : 3 güc c‚a tam gi~c';
       s[2] := 'a,b,c : 3 cÇnh tÂ™ng Êng';
       s[3] := 'S : Diôn töch tam gi~c';
       s[4] := 'p : nËa chu vi tam gi~c';
       s[5] := 'R : b~n könh Â¨ng tr†n ngoÇi tiïp tam gi~c';
       s[6] := 'r : b~n könh Â¨ng tr†n n©i tiïp tam gi~c';
       s[7] := 'ra,rb,rc : 3 b~n könh Â¨ng tr†n b|ng tiep';
       s[8] := 'ha,hb,hc : 3 Â¨ng cao Êng v´i 3 cÇnh a,b,c';
       s[9] := 'la,lb,lc : 3 Â¨ng phÉn gi~c c‚a 3 güc A,B,C';
       s[10]:= 'ma,mb,mc : 3 Â¨ng trung tuyïn Êng v´i a,b,c';
     end;
   zoombox(xtop,ytop,xtop+47,ytop+11,4);
   if not monoscreen then textcolor(black);
   for i := 1 to 10 do
     writexy(xtop+2,ytop+i,s[i]);
   if not monoscreen then textcolor(7);

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
      flag : boolean;
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
        writexy(6,21,'Su dung c†c ph°m mui tàn làn xuìng vÖ PGUP/PGDW ' +
                   'dà xem phÉn kà tiàp')
      else writexyattr(6,21,'SË d‰ng c~c phöm m„i tîn lîn xu•ng v| PGUP/PGDW '
                        + 'ó xem phÖn kï tiïp',textattr and $F0 + $F);
    window(2,3,78,21);
    start := 1;
    old := textattr;
    textattr := $F;
    flag := true;
    repeat
     if flag then
      begin
       clrscr;
       for i := start to start+min(So_ct-start,num-1) do
        begin
          gotoxy(((i-start) mod 2)*40+5,(i-start) shr 1 + 1);
          textcolor(Lightgray);
          write(i:2,'> ');
          textcolor(White);
          write(a[i].ct);
        end;
       end;
      flag := true;
      repeat
        ch := readkey;
      until ch in [F1,#27,#13,UP,DOWN,PGUP,PGDW];
      case ch of
        F1 : begin
               Message;
               window(2,3,78,21);
             end;
        UP   : if start > 2 then dec(start,2)
               else flag := false;
        DOWN : if (start <= So_ct-1) and (start+num <= So_ct) then
                 inc(start,2)
               else flag := false;
        PGUP : if start-num >= 1 then dec(start,num)
               else if start <> 1 then start := 1
                    else flag := false;
        PGDW : if start+num <= So_ct then inc(start,num)
               else flag := false;
      end;
    until ch in [#13,#27];
    textattr := old;
    window(2,3,79,23);
    writexy(1,21,
'                                                                            ');
 End;
{----------------------------------------------------------------}
 Function Giong(a1,a2:nut) : boolean;
   Var i : byte;
   Begin
     i := 1;
     while (i <= 5) and (a1.b[i] = a2.b[i]) do
      inc(i);
     Giong := i = 6;
   End;
{---------------------------------------------------------------}
 Procedure Tao_Them_Trithuc(opt:byte);
   Var ans : char;
       i,k,error : byte;
       s : string[35];
       tblq : string[2];
       temp : nut;
       oldnum,old : byte;
       f : text;
       Coroi : boolean;
   Begin
     oldnum := So_ct;
     textattr := $2F;
     window(20,9,60,16);
     zoombox(20,9,60,16,2);
     if monoscreen then
       writexyattr(24,9,'Nhap cìng thuc, Enter de ket thuc',$9)
     else writexyattr(24,9,'Nhàp c§ng thÊc, Enter ó kït th‡c',$2E);
     window(21,10,59,15);
     clrscr;
     if opt = 8 then
       begin
         So_ct := 0;
         temp := a[1];
       end
     else if opt = 5 then old := So_ct;
     if monoscreen then write(' Cìng thuc ',So_ct+1,' : ')
     else  write(' C§ng thÊc ',So_ct+1,' : ');
     readln(s);
     while (length(s)>=1) and (s[1] = ' ') do delete(s,1,1);
     while s <> '' do
       begin
         inc(so_ct);
         PhanTich(s,a[so_ct],error);
         if error = 2 then
           begin
             if monoscreen then writeln(' Khìng hieu cìng thuc nÖy')
             else writeln(' Kh§ng hióu c§ng thÊc n|y');
             dec(so_ct);
           end
         else if error = 1 then
           begin
             if NOT monoscreen then
               write(' C§ng thÊc n|y cü ‡ng kh§ng ?(C/K)')
             else write(' Cìng thuc nÖy c¢ dung khìng ?(C/K)');
             repeat
               ans := upcase(readkey);
             until ans in ['C','K',#27];
             writeln(ans);
             if ans = 'C' then
               begin
                 if monoscreen then
                   write(#13,#10,' Sì'' tham biàn trong cìng thuc : ')
                 else write(#13,#10,' S• tham biïn trong c§ng thÊc : ');
                 ch := readkey;
                 writeln(ch);
                 if ch in ['3'..'5'] then
                   begin
                     for i := 1 to ord(ch)-ord('0') do
                       repeat
                         if monoscreen then write(' Tham biàn ',i,' : ')
                         else  write(' Tham biïn ',i,' : ');
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
                       for k := i+1 to 5 do
                         a[so_ct].b[k] := 0
                   end
                 else
                   if monoscreen then
                     writeln(' Sai ! Sì'' biàn phai lÖ 3,4 hoac 5')
                   else writeln(' Sai ! S• biïn phÄi l| 3,4 hoéc 5');
               end
             else dec(so_ct);
           end;
 { Kiem tra xem da co cong thuc nay chua }
         Coroi := false;
         k := 1;
         while not Coroi and (k < So_ct) do
           if Giong(a[So_ct],a[k]) then Coroi := true
           else inc(k);
         if Coroi then
           begin
             if monoscreen then writeln(' Cìng thuc nÖy lÖ cìng thuc ',k)
             else writeln(' C§ng thÊc n|y l| c§ng thÊc ',k);
             dec(so_ct);
           end;

         if monoscreen then write(' Cìng thuc ',so_ct+1,' : ')
         else write(' C§ng thÊc ',so_ct+1,' : ');
         readln(s);
         while (length(s) >= 1)and(s[1] = ' ') do delete(s,1,1);
       end;{while}
     clrscr;
     if (opt = 8) and (so_ct = 0) then
       begin
         So_ct := oldnum;
         a[1] := temp;
         exit;
       end
     else if (opt = 5) and (So_ct = old) then
       begin
         So_ct := oldnum;
         exit;
       end;

     if monoscreen then
       write(#13,#10,' C¢ luu tri thuc moi làn dia ?(C/K)')
     else write(#13,#10,' Cü lÂu tri thÊc m´i lîn ùa ?(C/K)');
     repeat
       ans := upcase(readkey);
     until ans in ['C','K',#27];
     writeln(ans);
     if ans = 'C' then
       begin
         window(1,1,80,25);
         writexy(21,23,s1);
         assign(f,'TG.BAK');
         {$I-} erase(f); {$I+}
         if ioresult <> 0 then;
         assign(f,'TG.DAT');
         {$I-}reset(f);{$I+}
         if ioresult <> 0 then
           begin
             writexyattr(21,23,s2,$8F);
             readln;
             Goodbye;
           end;
         close(f);
         {$I-}rename(f,'TG.BAK');{$I+}
         while ioresult <> 0 do
           begin
             savescreen(12,12,70,15);
             zoombox(12,12,68,14,4);
             if monoscreen then
             writexy(13,13,
               ' Dia khìng ghi duoc. C¢ ghi lai lan nua khìng ? (C/K) ')
             else writexy(9,13,
               ' Òùa kh§ng ghi ÂØc. Cü ghi lÇi lÖn nÈa kh§ng ? (C/K) ');
             repeat
               ans := upcase(readkey);
             until ans in [#27,'C','K'];
             restorescreen(12,12,70,15);
             if ans <> 'C' then exit;
             {$I-} erase(f); {$I+}
             if ioresult <> 0 then;(*!*)
             {$I-}rename(f,'TG.BAK');{$I+}
           end;
         writexy(21,23,'                                         ');
         assign(f,'TG.DAT');
         rewrite(f);
         for i := 1 to so_ct do
           writeln(f,a[i].ct);
         close(f);
       end;
     window(2,3,79,23);
   End;
{--------------------------------------------------------------------}
Procedure Huy_Sua_Ct(opt:byte);
  Var
    wy,error,k : byte;
    n : integer;
    ans,ch : char;
    s,t1,t2,t3,t4 : string[40];
    f : text;
    temp : nut;
    Dahuysua,Coroi : boolean;
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
  	   writexy(wx,wy,'NhÉp sì thuoc doan [')
	 else writexy(wx,wy,'Nhàp s• thu©c oÇn [');
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
    7 : status := 'H‚y';
    6 : status := 'SËa';
  end;
  t1 := ' m©t c§ng thÊc trong hô th•ng tri thÊc';
  t2 := 'Nhàp v|o s• thÊ tÍ c‚a c§ng thÊc cÖn ';
  t3 := 'S• c§ng thÊc = ';
  t4 := 'Å h‚y c§ng thÊc ';
  if monoscreen then
    begin
      t1 := ' mìt cìng thuc trong hà thìng tri thuc';
      t2 := 'Nhap vÖo sì thu tu cua cìng thuc cÉn ';
      t3 := 'Sì cìng thuc = ';
      t4 := 'Da huy cìng thuc ';
      case opt of
        7 : status := 'Huy';
        6 : status := 'Sua';
      end;
    end;
  repeat
    textattr := $2F;
    setwin(14,7,67,17,' ',$2F);
    writexyattr(20,8,status + t1,$2E);
    writexy(20,10,t2 + status + ' : ');
    writexy(20,11,t3);
    readint(1,So_ct,n);
    if n = 0 then exit;
    temp := a[n];
    if monoscreen then
      begin
        writexy(20,12,'Cìng thuc cÉn ' + status + ' la ' + a[n].ct);
        writexy(20,13,'C¢ '+ status + ' cìng thuc nÖy khìng ? (C/K) ');
      end
    else
      begin
        writexy(20,12,'C§ng thÊc cÖn ' + status + ' la ' + a[n].ct);
        writexy(20,13,'Cü '+ status + ' c§ng thÊc n|y kh§ng ? (C/K) ');
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
          if monoscreen then write('Cìng thuc ',n,' : ')
          else write('C§ng thÊc ',n,' : ');
          readln(s);
          while (length(s)>=1) and (s[1] = ' ') do delete(s,1,1);
          if s <> '' then
            begin
              PhanTich(s,a[n],error);
              if error = 2 then
                if monoscreen then writeln(' Khìng hieu cìng thuc nÖy ')
                else writeln(' Kh§ng hióu c§ng thÊc n|y ')
              else if error = 1 then
                begin
                  if monoscreen then
                    write(' Cìng thuc nÖy c¢ d£ng khìng ?(C/K)')
                  else  write(' C§ng thÊc n|y cü ‡ng kh§ng ?(C/K)');
                  repeat
                    ans := upcase(readkey);
                  until ans in ['C','K',#27];
                  writeln(ans);
                  if ans = 'C' then
                    begin
                      if monoscreen then
                        write(#13,#10,' Sì tham biàn trong cìng thuc : ')
                      else write(#13,#10,' S• tham biïn trong c§ng thÊc : ');
                      ch := readkey;
                      writeln(ch);
                      if ch in ['3'..'5'] then
                        begin
                          for i := 1 to ord(ch)-ord('0') do
                            repeat
                              if monoscreen then write(' Tham bien ',i,' : ')
                              else write(' Tham biïn ',i,' : ');
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
                            for k := i+1 to 5 do a[n].b[k] := 0
                        end
                      else
                        if monoscreen then
                          writeln(' Sai ! Sì'' biàn phai la 3,4 hoac 5')
                        else writeln(' Sai ! S• biïn phÄi l| 3,4 hoéc 5');
                    end;
                end;
              { Kiem tra xem da co cong thuc nay chua }
              Coroi := false;
              k := 1;
              while not Coroi and (k < So_ct) do
                if Giong(a[So_ct],a[k]) then Coroi := true
                else inc(k);
              if Coroi then
                begin
                  if monoscreen then writeln('Cìng thuc nÖy lÖ cìng thuc ',k)
                  else writeln('C§ng thÊc n|y l| c§ng thÊc ',k);
                  a[n] := temp;
                  sound(550);delay(500);nosound;
                  error := 2
                end;
           end;{if}
          delay(30);
          clrscr;
        until (error = 0) or (s = '');
        if s = '' then
          begin
            a[n] := temp;
            exit
          end;
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
        {$I-}rename(f,'TG.BAK');{$I+}
        while ioresult <> 0 do
          begin
            savescreen(12,12,70,15);
            zoombox(12,12,68,14,4);
            if monoscreen then
              writexy(13,13,
                 ' Dia khìng ghi duoc. C¢ ghi lai lan nua khìng ? (C/K) ')
            else writexy(9,13,
                 ' Òùa kh§ng ghi ÂØc. Cü ghi lÇi lÖn nÈa kh§ng ? (C/K) ');
            repeat
              ans := upcase(readkey);
            until ans in [#27,'C','K'];
            restorescreen(12,12,70,15);
            if ans <> 'C' then exit;
            assign(f,'TG.BAK');
            {$I-} erase(f); {$I+}
            if ioresult <> 0 then;(*!*)
            {$I-}rename(f,'TG.BAK');{$I+}
          end;
        writexy(21,23,'                                         ');
        assign(f,'TG.DAT');
        rewrite(f);
        for i := 1 to so_ct do
          writeln(f,a[i].ct);
        Dahuysua := true;
      end;
    if monoscreen then
      writexy(20,15,'C¢ ' + status + ' cìng thuc kh†c khìng ? (C/K) ')
    else writexy(20,15,'Cü ' + status + ' c§ng thÊc kh~c kh§ng ? (C/K) ');
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
   s1 := 'Tri thÊc c„ ÂØc lÂu lÇi trong tôp TG.BAK';
   s2 := 'Kh§ng tõm thÑy tri thÊc trong tôp TG.Dat!';
   s := s2 + ' TÇo m´i hay kh§ng ?(T/K)';
   if MonoScreen then
     begin
       s1 := 'Tri thuc cu duoc luu lai trong tàp TG.BAK';
       s2 := 'Khìng tim thay tri thuc trong tàp TG.Dat!';
       s := s2 + ' Tao moi hay khìng ?(T/K)';
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

   if VGAScreen then
     begin
       LightBk(1);
       setDACcolor(1,25,31,63);
       setDACcolor(4,50,0,0);
       setDACcolor(3,60,50,25);
       setDACcolor(7,63,63,63);
     end;

   Mouse := Reset_Mouse;
   if Mouse then MouseSetMoveArea(0,0,78*8,24*8);
   i_menu := 1;
   textattr := $07;
   window(1,1,80,25);
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
        5,8 : Tao_them_trithuc(i_menu);
        10 : XemTb;
        11 : XemCt;
	4 : Goodbye;
      end;{end case}
      if i_menu in [5..8] then
	i_menu := 2;
      if i_menu in [10..12] then
	i_menu := 3;
      window(1,1,80,25);
    Until Ch = 'Q'
END.

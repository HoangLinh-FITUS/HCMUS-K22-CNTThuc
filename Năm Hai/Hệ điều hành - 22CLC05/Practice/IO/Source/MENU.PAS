{* Written by Thai Hung Van *}

Procedure Introduce;
 var oldcolor : byte;
{----------------------------------------}
 Procedure ColorScreen;
 const
  colo : array[1..11] of word =
     (lightred,lightmagenta,lightcyan,
      lightgreen,lightblue,yellow,
      blue,green,cyan,magenta,red);
 var i,j : word;
 {----------------------------------------}
  Procedure ColorCol(color,x:word);
  var a,b,c : word;
   begin
     c := 1;
     textcolor(color);
     for b := x to x+3 do
      begin
       for a := 1 to 21 do
        begin
         gotoxy(b,a);
	 if (c = 4) then
          write(chr(219))
         else
          write(chr(c+175),chr(c+175):8-c*2);
        end;
       c := c + 1;
      end
    end;{ColorCol}
{----------------------------------------------}
   Begin {ColorScreen}
    textbackground(0);
    clrscr;
    window(2,3,79,23);
    hidecursor(1);
    SetCharWidth(8);
    i := 1;j := 1;
    while (i<78) do
     begin
      ColorCol(colo[j],i);
      i := i + 7;
      inc(j);
     end;
    window(2,3,78,23);
  End; {ColorScreen}
{----------------------------------------------}
Begin
  oldcolor := textattr;
  hidecursor(1);
  SetCharWidth(8);
  colorscreen;
  if not monoscreen then textattr := $6F;
  ZoomBox(12,8,67,17,4);
  if monoscreen then
    begin
  writexyattr(24,8,' * Chuong trinh giai tam giac * ',$8F);
  window(14,9,65,16);
  write('  T` m“t hˆ th“ng c“ng thc d“c lƒp ( ng—”i d—ng c¢');
  write('thˆ thay d“i, b“'' sung ho„c dinh nghia lai ), chu”ng');
  write('trnh s‰ suy ngh‹, vƒn dung va lƒp luƒn 1 c ch th“ng');
  write('minh dˆ'' dua ra l•‹ giai trong chop mat !');
    end
  else
    begin
  writexyattr(24,8,' * Chåªng tr›nh gi€i tam gi~c * ',$8F);
  window(14,9,65,15);
  write('  Tç 1 h™ th¥ng c¤ng thæc ð©c lˆp luå ­ d‚ng v‰n b€n');
  write('ngå¬i dáng cŸ th— sèa ð§i, b§ sung, ðžnh ngha l‚i),');
  write('chåªng tr›nh s’ nhˆn bi•t , vˆn däng v| lˆp luˆn m©t');
  write('c~ch th¤ng minh ð— ðåa ra l¬i gi€i trong ch«p mŠt ! ');
    end;
  hidecursor(0);
  SetCharWidth(9);
  textattr := oldattr;
 end;
{-------------------------------------------------------------------}
 Procedure Goodbye;
 Var Tb : string[14];
     i  : byte;
 Begin
   if VGAScreen then
     begin
       FadeScreen;
       MagicScreen(3000);
     end;
   window(1,1,80,25);
   hidecursor(1);
   textbackground(0);
   setmode(getmode);
   if VGAScreen then
     begin
       SetVfont;
       textcolor(LightGreen);
       writexy(26,11,'Chåªng tr›nh gi€i tam gi~c');
       textcolor(Lightgray);
       writexy(26,13,'T~c gi€ : ');
       textcolor(white);
{       Tb := 'Rf'+#126+'g F'+#225+'le T'+#137+'l';
       for i := 1 to 13 do
         if tb[i] <> ' ' then write(chr(ord(tb[i])+2))
         else write(' ');}
       write('Th~i Háng V‰n');
       textcolor(LightBlue);
       writexy(26,15,'ñ‚i h£c T§ng h¯p TPHCM *3/94');
       textcolor(yellow);
     end
   else
     begin
   writexy(26,11,'Chuong trinh  GIAI TAM GIAC');
   writexy(26,13,'Tac gia : ');
   highvideo;
   Tb := 'Rf_g Fsle T_l';
   for i := 1 to 13 do
     if tb[i] <> ' ' then write(chr(ord(tb[i])+2))
     else write(' ');
   lowvideo;
   writexy(26,15,'Dai hoc Tong hop TPHCM *3/94');
     end;
   runningStar(19,9,60,16,6,3,On,textattr,50,Ch);
   scrollCol(19,8,60,16);
   textattr := oldattr;
   Setmode(Getmode);
   hidecursor(0);
   RestoreScreen(1,1,80,wy);
   gotoxy(1,wy);
   if VGAScreen then
     begin
       setDACcolor(1,0,0,42);
       setDACcolor(3,0,42,42);
       setDACcolor(4,42,0,0);
       setDACcolor(7,42,42,42);
     end;
   CloseMusic;
   halt;
 End;
{-----------------------------------------------------------}
 Procedure Message;
   const  s : array[1..6] of string[78] = (
'  * Chåªng tr›nh hå«ng d‡n c~ch gi€i nhéng b|i to~n Gi€i Tam Gi~c, vš dä nhå',
' b|i to~n: Cho 2 gŸc A,B, b~n kšnh b|ng ti•p rc;t›m c‚nh a,c, di™n tšch S...',
'  * Tri thæc câa chåªng tr›nh chšnh l| c~c c¤ng thæc, h™ thæc trong tam gi~c',
' C~c c¤ng thæc n|y ðå¯c luå trong t™p v‰n b€n TG.DAT, cŸ th— sèa ð§i&b§ sung',
' Chåªng tr›nh s’ nhˆn di™n,vˆn däng&lˆp luˆn 1 c~ch th¤ng minh ð— cŸ k•t qu€',
'           Ctrl-LeftShift : bˆt nh‚c  *  Ctrl-RightShift : tŠt nh‚c        ');
   var tem : char;j : byte;
   begin
     if monoscreen then
       begin
         s[1] :=
'  * Chuong trinh huong dan cach giai nhung bai toan Giai Tam Giac, vi du nhu';
         s[2] :=
' bai toan: Cho 2 goc A,B, ban kinh bang tiep rc;tim canh a,c, dien tich S...';
         s[3] :=
'  * Tri thuc cua chuong trinh chinh la cac cong thuc, he thuc trong tam giac';
         s[4] :=
' C c c“ng thuc nay duoc luu trong tep van ban TG.DAT, co the sua doi&bo sung';
         s[5] :=
' Chuong trinh se nhan dien,van dung&lap luan 1 cach th“ng minh de co ket qua';
         s[6] :=
'           Ctrl-LeftShift : bat nhac  *  Ctrl-RightShift : tat nhac        ';
       end;
     window(1,1,79,25);
     savescreen(1,17,79,23);
     gotoxy(1,22);write('º');
     for j := 2 to 78 do write(' ');
       write('º');
     gotoxy(1,17);write('Ç');
     for j := 2 to 78 do write('Ä');
       write('¶');
     if MonoScreen then
       writexyAttr(37,17,'Giup do',$9)
     else
       writexyAttr(37,17,'Giàp ð®',$1A);
     window(2,18,78,23);
     clrscr;
     for j := 1 to 5 do
       writeln(s[j]);
     write(s[6]);
     tem := readkey;
     restorescreen(1,17,79,23);
     window(1,1,79,24);
   end;
{--------------------------------------------------------------------------}
 Procedure Menu;
  Label T;
  Const
   St : array[1..12] of string[17] = ('L¬i Gi€i b|i to~n',
				      'Cˆp nhˆt tri thæc',
				      'Xem c~c tri thæc',
				      'Ra kh¡i h™ th¥ng',

				      'Th”m c¤ng thæc  ',
				      'Sèa c¤ng thæc   ',
				      'Hây c¤ng thæc   ',
				      'Lˆp tri thæc m«i',
				      'V– menu chšnh   ',

				      'C~c Tham bi•n',
				      'C~c C¤ng thæc',
				      'V– menu chšnh');
    F1  = #59;
  Var
    ch,ans,tem : char;
    j : byte;

{--------------------------------------------------------------------------}
Procedure ReverseStr(x,y,n:byte);
(* Doi thuoc tinh 1 chuoi ky tu tren man hinh thanh nen trang chu den , voi :
   x,y : vi tri chuoi ; n : so ky tu cua chuoi tinh tu ky tu ky tu dau tien *)
  Var Dc : word;
      i : byte;
  Begin
    Dc := (y-1)*160 + (x-1)*2 + 1;
    for i := 1 to n do
      begin
        Mem[SegTVR:Dc] := $70;
	Dc := Dc + 2
      end
  End;
{---------------------------------------------------------------------------}
 Procedure Dat_VetSang(i_menu : byte);
  Var i : byte;
  Begin
    If MonoScreen then
      begin
	if i_menu <= 4 then
	  ReverseStr(20*i_menu-17,1,length(st[i_menu]))
	else if i_menu <= 9 then
	  ReverseStr(24,i_menu-2,length(st[i_menu])+2)
	else if i_menu <= 12 then
	  ReverseStr(44,i_menu-7,length(st[i_menu])+2)
      end
    else
      begin
	if i_menu <= 4 then
	  for i := 1 to length(st[i_menu]) do
	    Mem[SegTVR:2*(20*i_menu-19+i)+1] := $2F
	else if i_menu <= 9 then
	  for i := 0 to length(st[i_menu])+1 do
	    Mem[segTVR:2*(23+i)+160*(i_menu-3) + 1] := $2F
	else if i_menu <= 12 then
	  for i := 0 to length(st[i_menu])+1 do
	    Mem[segTVR:2*(43+i)+160*(i_menu-8) + 1] := $2F
      end;
  End;
{---------------------------------------------------------------------------}
 Procedure Huy_VetSang(i_menu:byte);
   Begin
     if not MonoScreen then
      begin
       if i_menu = 1 then
	 writexyattrk(3,1,st[i_menu],$70,5,$74)
       else if i_menu <= 4 then
	 writexyattrk(20*i_menu-17,1,st[i_menu],$70,1,$74)
       else if i_menu <= 9 then
	 writexyattrk(24,i_menu-2,' '+st[i_menu]+' ',$38,
			   Lightchar[i_menu-i_top]+1,$34)
       else if i_menu <= 12 then
	 writexyattrk(44,i_menu-7,' '+st[i_menu]+' ',$38,
			   Lightchar[i_menu-i_top]+1,$34)
      end
     else
      begin
       if i_menu > 9 then
 writexyattrk(44,i_menu-7,' '+st[i_menu]+' ',7,Lightchar[i_menu-i_top]+1,$F)
       else if i_menu > 4 then
 writexyattrk(24,i_menu-2,' '+st[i_menu]+' ',7,Lightchar[i_menu-i_top]+1,$F)
       else if i_menu > 1 then  { 2 <= i_menu <= 4 }
	 writexyattrk(20*i_menu-17,1,st[i_menu],7,1,$F)
       else { i_menu = 1 }
	 writexyattrk(20*i_menu-17,1,st[i_menu],7,5,$F)
      end;
   End;

{-----------------------------------------------------------}
Procedure SubMenu(i_submenu : byte);{ Menu con thu i_submenu}
 Label L;
 Const
    ALT_G = #$22;
    ALT_C = #$2e;
    ALT_R = #$13;
    ALT_T = #$14;
    ALT_X = #$2d;

 Var
   i,i_down,x1,y1,x2,y2 : byte;
   Th : set of char;
   mx,my : integer;
   flag : boolean;
   Hotkey : array[0..MaxSubFunc-1] of char;
 Begin
L:
  if Mouse then delay(200);
  case i_subMenu of
    2 :
      begin
	x1 := 23; y1 := 2;
	x2 := 42; y2 := 8;
	i_top := 5; i_down := 9;
	for i := 0 to 4 do
	  begin
	    LightChar[i] := 1;
	    Hotkey[i] := st[i_top+i][1];
	  end;
      end;
    3 :
      begin
	x1 := 43; y1 := 2;
	x2 := 59; y2 := 6;
	i_top := 10; i_down := 12;
	for i := 0 to 1 do
	  begin
	    LightChar[i] := 5;
	    Hotkey[i] := st[i_top+i][5];
	  end;
	LightChar[2] := 1;
	Hotkey[2] := st[i_top+2][1];
      end;
    end; { case }
   savescreen(x1,y1,x2+2,y2+1);
   window(x1,y1,x2,y2);
   if not MonoScreen then textbackground(3);
   clrscr;
   window(1,1,80,25);
   box(x1,y1,x2,y2,1);
   if MonoScreen then
     for i := i_top to i_down do
       writexyattrk(x1+2,y1+1+i-i_top,st[i],$07,LightChar[i-i_top],$f)
   else
     begin
       shadow(x1,y1,x2,y2,8,0);
       for i := i_top to i_down do
	 writexyattrk(x1+2,y1+i+1-i_top,st[i],$38,LightChar[i-i_top],$34);
     end;
   i_menu := i_top;
   Th := [LEFT,RIGHT,ESC,ENTER,Alt_G,Alt_C,Alt_X,Alt_R];
   for i := i_top to i_down do
     Th := Th + [ HotKey[i - i_top] ];
   Dat_VetSang(i_menu);
   if Mouse  then
     Show_Mouse;
   repeat
     ch := #0; c := 0;
     if Mouse then c := clicked;
     if (c <> 0) then
      begin
       mx := M_getX shr 3;
       my := M_GetY shr 3;
       case my of
	 2..2+maxSubFunc :
           if (x1 <= mx+1) and (mx+1 <= x2) then
             Ch := Hotkey[my - 2];
	 0 : {Mouse is clicking at the first line}
	   case mx of
	     0 ..19 : Ch := Alt_G;
	     20..39 : Ch := Alt_C;
	     40..59 : Ch := Alt_X;
	     60..79 : Ch := Alt_R;
	   end
       end {case}
      end {if c <> 0}
     else if keypressed then
       begin
	 Ch := upcase(readkey);
         flag := (ch = 'H');
	 if not flag and (ch = #0) then ch := readkey;
	 if not (ch in (Th + [UP,DOWN])) then
	   begin
	     sound(500);
	     delay(100);
	     nosound;
	   end;
       end;

     if not flag and (ch in [F1,UP,DOWN]) then
       begin
	 Huy_VetSang(i_menu);
	 case ch of
	   DOWN:
	     if i_menu < i_down then
	       inc(i_menu)
	     else
	       i_menu := i_top;
	   UP:
	     begin
               { hien gio ch = 'H'}
	       ch := #0;
	       if i_menu > i_top then
		 dec(i_menu)
	       else
		 i_menu := i_down;
	      end;
       	   F1 : Message;{Attr(37,22,'Giup do',$1B);}
	  end;
	Dat_VetSang(i_menu);
      end;
      if ((ch = Alt_C) and (i_menu in [5..9])) or
	 ((ch = Alt_X) and (i_menu in [10..12])) then
	 ch := #32;
    Until ch in Th;
    if Mouse then Hide_Mouse;
    Huy_VetSang(i_menu);
    case ch of
      RIGHT : i_menu := i_subMenu + 1;
      LEFT  : i_menu := i_subMenu - 1;
      ESC   : i_menu := i_subMenu;
      ENTER : if i_menu = i_down then
	       begin
		i_menu := i_subMenu;
		Ch := #32;
	       end;
      Alt_G : begin
	       i_menu := 1;
	       ch := ENTER;
	      end;
      Alt_R :
	begin
	  i_menu := 4;
	  ch := ENTER;
        end;
      Alt_C :
	    i_menu := 2;
      Alt_X :
	    i_menu := 3;
      Else { Ch in HotKey }
	for i := i_top to i_down do
	  if ch = Hotkey[i - i_top] then
	    i_menu := i;
    End; {case}
    If i_menu > 4 then
      begin
	if i_menu = i_down then
	  i_menu := i_submenu;
	Dat_VetSang(i_submenu);
      end;
    RestoreScreen(x1,y1,x2+2,y2+1);
    Open := Ch in [LEFT,RIGHT,Alt_C,Alt_X];
    if Ch = Alt_X then
      begin
	i_submenu := 3;
	goto L;
      end;
    if Ch = Alt_C then
      begin
	i_submenu := 2;
	goto L;
      end;
  End;
{##########################################################################}
 Begin
   box(1,2,79,22,3);
   box(1,22,79,24,3);
   writexy(1,22,#199);
   writexy(79,22,#182);
   if MonoScreen then
     begin
       st[1] := 'Loi Giai b…i to n';
       st[2] := 'Cap nhat tri thuc';
       st[3] := 'Xem c c tri thuc';
       st[4] := 'Ra khoi he th“ng';
       st[5] := 'Them c“ng thuc  ';
       st[6] := 'Sua c“ng thuc   ';
       st[7] := 'Huy c“ng thuc   ';
       st[8] := 'Lap tri thuc moi';
       st[9] := 'Ve menu chinh   ';
       st[10]:= 'C c Tham bien';
       st[11]:= 'C c C“ng thuc';
       st[12]:= 'Ve menu chinh';
       writexyattrk(3,1,st[1],$7,5,$F);
       for j := 2 to 4 do
	 writexyattrk(20*j-17,1,st[j],$7,1,$F);
       writexyAttr(36,2,'Nhap/Xuat',$9);
       writexyAttr(37,22,'Giup do',$9);
       writexyattr(26,25,'ESC-Ra khoi chuc nang hien tai',$70);
     end
   else
     begin
       setwin(1,1,79,1,#32,$70);
       writexyattrk(3,1,st[1],$70,5,$74);
       for j := 2 to 4 do
	 writexyattrk(20*j-17,1,st[j],$70,1,$74);
       writexyAttr(36,2,'Nhˆp/Xu„t',$1B);
       writexyAttr(37,22,'Giàp ð®',$1B);
       writexyattr(26,25,'ESC-Ra kh¡i chæc n‰ng hi™n t‚i',$E0);
     end;
   MemW[SegTVR:24*160+110] := $1CDD;
   Dat_VetSang(i_menu);
   HideCursor(1);{Giau con tro}
   Repeat
     if Open and (i_menu in [2,3]) then
       begin
	 while Open and (i_menu in [2,3]) do
	   begin
	     Huy_VetSang(i_menu);
	     SubMenu(i_menu);
	     If i_menu > 4 then goto T
	     else Dat_VetSang(i_menu);
	   end;
	 if i_menu > 4 then Ch := Enter
	 else if Ch in [Left,Right] then Ch := ' ';
       end;

     if Mouse  then Show_Mouse;
     repeat
       Ch := #0;c := 0;
       if Mouse then c := clicked;
       if (c <> 0) and (M_getY shr 3 = 0) then
	   case M_getX shr 3 of
	     0 ..19 : Ch := 'G';
	     20..39 : Ch := 'C';
	     40..59 : Ch := 'X';
	     60..79 : Ch := 'R';
	   end
       else if keypressed then
	 begin
	   Ch := upcase(Readkey);
	   if Ch = #0 then Ch := readkey;
	   If not (Ch in [F1,ENTER,ESC,DOWN,RIGHT,LEFT,'G','C','X','R']) then
	     begin
	       sound(900);
	       delay(100);
	       nosound;
	     end;
	 end;
       until (Ch in [F1,ENTER,ESC,DOWN,RIGHT,LEFT,'G','C','X','R']);
       if Mouse then Hide_Mouse;
       Huy_VetSang(i_menu);
       Case Ch of
	   F1 : Message;
	   ESC :
	     begin
	       Goodbye
	     end;
           RIGHT : if i_menu < 4 then
                   inc(i_menu)
                 else
                   i_menu := 1;
	   LEFT : if i_menu > 1 then
                   dec(i_menu)
                 else
		   i_menu := 4;
	   DOWN,ENTER :
		if i_menu in [2,3] then
		  SubMenu(i_menu);
	   'G' : i_menu := 1;
	   'C' :
	      begin
		i_menu := 2;
		SubMenu(i_menu);
	      end;
	   'X' :
	      begin
		i_menu :=3;
		SubMenu(i_menu);
	      end;
	   'R' : i_menu := 4;
	 End; {Case}
	 If i_menu <= 4 then
	   Dat_VetSang(i_menu);
   Until Ch in ['G','C','X','R','S','H','L','T',ENTER];
T: HideCursor(0);
   window(2,3,78,23);
   if MonoScreen then
     SetWin(2,3,78,21,' ',$07)
   else
     SetWin(2,3,78,21,' ',$17)
 End; { Menu }

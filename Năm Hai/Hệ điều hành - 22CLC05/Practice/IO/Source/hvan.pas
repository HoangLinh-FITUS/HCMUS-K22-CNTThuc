UNIT HVan;
  {--------------------------------INTERFACE-------------------------------}
INTERFACE
  Uses Crt,Dos,My_Mouse;
  Const
    UP       = #72;
    DOWN     = #80;
    LEFT     = #75;
    RIGHT    = #77;
    PageUp   = #73;
    PageDown = #81;
    Ins      = #82;
    Del      = #83;
    Space    = #32;
    Enter    = #13;
    ESC      = #27;
    TAB      = #9;
    F1       = #59;
    F2       = #60;
    F3       = #61;
    F4       = #62;
    F5       = #63;
    F6       = #64;
    F7       = #65;
    F8       = #66;
    F9       = #67;
    F10      = #68;
    Null     = #0;
    On       = 1;
    Off      = 0;
  Var
    MonoScreen : boolean;
    SegTVR     : word;
  Procedure Readint(inf,sup:integer; var s: string);
  Function NumLock : boolean; { True khi den NumLock bat }
  Function Capslock : boolean; { True khi den Capslock bat }
  Function ScrollLock : boolean; { True khi den ScrollLock bat }
  Procedure SetNumLock(status:byte);
  Procedure SetCapsLock(status:byte);
  Procedure SetScrollLock(status:byte);

  Function SegTVRAM : word;(*Lay dia chi dau vung nho man hinh*)
  Procedure WriteXY(x,y:byte;st:string);(*Xuat chuoi ST tai vi tri (x,y)*)
  Procedure WriteXYattr(x,y:byte;st:string;attr:byte);
  (*Xuat chuoi ST tai vi tri (x,y) voi thuoc tinh ATTR*)
  Procedure WriteXYattrK(x,y:byte;st:string;attr,K,attrK:byte);
  (*Xuat chuoi ST tai vi tri (x,y) voi thuoc tinh ATTR trong do ky tu thu K
    co thuoc tinh AtrrK*)
  Procedure Box(x1,y1,x2,y2,Mode:byte);
  Procedure SetWin(x1,y1,x2,y2:byte;ch:char;attr:word);
  (*Dat lai 1 cua so voi ky tu Ch , thuoc tinh Attr *)
  Procedure HideCursor(mode:byte);(* Mode=0 : dau con tro; Mode=1 : tra lai *)
  Procedure ScrollRow(x1,y1,x2,y2:byte);(* Cuon cua so len *)
  Procedure ScrollCol(x1,y1,x2,y2:byte);(* Cuon cua so qua trai *)
  Procedure SaveScreen(x1,y1,x2,y2:byte);(* Cat man hinh *)
  Procedure RestoreScreen(x1,y1,x2,y2:byte);(* Tra lai man hinh *)
  Procedure Zoom(ymax:byte);
  Procedure RunningStar(x1,y1,x2,y2,d,r,status,attr:byte;
                        times:word;var Ch:char);
  Procedure Shadow(x1,y1,x2,y2,Tx,Bk:byte);
  Procedure MagicScreen(DelayTime:word);
  Procedure ZoomBox(x1,y1,x2,y2,mode:byte);
  Procedure Read_Int(var x:integer;inf,sup : integer);
  Procedure Read_Real(var x:real;sup,inf:real);
  Procedure SetCharWidth(width : byte);
  Procedure ColorScreen;
  Procedure ColorScreen2;
  Procedure SBox(x1,y1,x2,y2,Bk:byte);
  Procedure SZoomBox(x1,y1,x2,y2,Bc:byte);
  {--------------------------IMPLEMENTATION---------------------------------}
  IMPLEMENTATION
  Type
     Pointer = ^Element;
     Element = record
		 asc,att:byte;
		 next : pointer;
	       end;
  Var
     win : pointer;
     temp : pointer;

(**************************************************************************)
Function NumLock : boolean;
  Var Regs : Registers;
  Begin
    Regs.AH := 2;
    INTR($16,Regs);
    NumLock := (Regs.AL and 32 = 32)
  End;
{---------------------------------------------------------------------------}
Function CapsLock : boolean;
  Var Regs : Registers;
  Begin
    Regs.AH := 2;
    INTR($16,Regs);
    CapsLock := (Regs.AL and 64 = 64)
  End;
{---------------------------------------------------------------------------}
Function ScrollLock : boolean;
  Var Regs : Registers;
  Begin
    Regs.AH := 2;
    INTR($16,Regs);
    ScrollLock := (Regs.AL and 16 = 16)
  End;
{---------------------------------------------------------------------------}
 Procedure SetNumLock(status:byte);
  Begin
   if status = 1 then
     mem[0:$417] := mem[0:$417] or $20
   else if status = 0 then
     mem[0:$417] := mem[0:$417] and $DF;
  End;

{---------------------------------------------------------------------------}
 Procedure SetCapsLock(status:byte);
  Begin
   if status = 1 then
     mem[0:$417] := mem[0:$417] or $40
   else if status = 0 then
     mem[0:$417] := mem[0:$417] and $BF;
  End;
{-----------------------------------------------------}
 Procedure SetScrollLock(status:byte);
  Begin
   if status = 1 then
     mem[0:$417] := mem[0:$417] or $10
   else if status = 0 then
     mem[0:$417] := mem[0:$417] and $EF;
  End;
{------------------------------------------------------}
Procedure Readint(inf,sup : integer; var s :string);
 Label L;
 Var
   x,y,i,error : integer;
   n : longint;
 Begin
   x := whereX;
   y := whereY;
 L :
   readln(s);
   if (length(S) > 6) or not (s[1] in ['+','-','0'..'9']) then
     begin
       gotoxy(x,y);
       for i := 1 to length(s) do
	 write(' ');
       gotoxy(x,y);
       goto L;
     end;
   i := 2;
   while ( i <= length(s) ) and ( s[i] in ['0'..'9'] ) do
     inc(i);
   if i = length(s) then { Co loi }
     begin
       gotoxy(x,y);
       for i := 1 to length(s) do
	 write(' ');
       gotoxy(x,y);
       goto L;
     end;
   val(s,n,error);
   if (error <> 0) or (n < inf) or (n > sup) then
     begin
       gotoxy(x,y);
       for i := 1 to length(s) do
	 write(' ');
       gotoxy(x,y);
       goto L;
     end;
  End;
{--------------------------------------------------------------------------}
 Procedure Read_Int(var x:integer;inf,sup:integer);
 var
     s         : string[10];
     error     : integer;
     oldX,oldY,i : byte;
  Begin
    oldX := whereX; oldY := whereY;
    repeat
      readln(s);
{$R-} val(s,x,error);{$R+}
      if error=0 then
	if (x < inf) or (x > sup) then
	  begin
	    gotoxy(oldx,oldy);
	    for i := 1 to length(s) do
	      write(' ');
	    gotoxy(oldx,oldy);
	    error := 1;
	  end;
    until (error=0);
  End; {Read_Int}
{***************************************************************************}
  Function SegTVRAM;
    begin
      if MemW[$40:$63] = $3B4 then
	SegTVRAM := $B000
      else
	SegTVRAM := $B800
   end;
{-------------------------------------------------------------------------}
Procedure WriteXY;
  begin
    GotoXY(x,y);
    Write(st);
  end;
{-------------------------------------------------------------------------}
Procedure WriteXYattr;
  var temp : byte;
  begin
    temp := textattr;
    textattr := attr;
    writexy(x,y,st);
    textattr := temp
  end;
{-------------------------------------------------------------------------}
Procedure WriteXYattrK;
  begin
    writexyattr(x,y,st,attr);
    Mem[SegTVR:(y-1)*160 + (x+K-2)*2 + 1] := attrK
  end;
{-------------------------------------------------------------------------}
Procedure Box;
  Const
	 LeftTop  : array[1..4] of char = ('Ú','Õ','Ö','É');
	 RightTop : array[1..4] of char = ('¿','¸','·','»');
	 LeftBot  : array[1..4] of char = ('À','Ô','Ó','È');
	 RightBot : array[1..4] of char = ('Ù','¾','½','¼');
	 LineRec  : array[1..4] of char = ('Ä','Í','Ä','Í');
	 SideRec  : array[1..4] of char = ('³','³','º','º');
  var
      i : byte;
  begin
   gotoxy(x1,y1);write(leftTop[mode]);
   for i := (x1+1) to (x2-1) do write(lineRec[mode]);
   write(rightTop[mode]);
   gotoxy(x1,y2);write(leftBot[mode]);
   for i := (x1+1) to (x2-1) do write(lineRec[mode]);
   write(rightBot[mode]);
   for i := (y1+1) to (y2-1) do
    begin
     gotoxy(x1,i);write(SideRec[mode]);
     gotoxy(x2,i);write(SideRec[mode]);
    end;
  end;
{-------------------------------------------------------------------------}
Procedure SetWin;
  var i,j:byte;
  begin
    for j := y1 to y2 do
      for i := x1 to x2 do
	MemW[SegTVR:(j-1)*160 + (i-1)*2] := attr shl 8 + ord(ch);
  end;
{--------------------------------------------------------------------------}
Procedure HideCursor;
  var reg:registers;
  begin
   if mode=0 then
    begin
     reg.AH := 1;
     reg.CX := $0C0D;
     Intr($10,reg);
    end
   else if mode=1 then
    begin
     reg.AH := 1;
     reg.CX := $2020;
     Intr($10,reg)
    end
  end;
{---------------------------------------------------------------------------}
Procedure ScrollRow;
  var dc : word;
     i,x,y : byte;
  begin
   hidecursor(1);
   for i := 1 to (y2-y1) do
    for y := y1 to (y2-i) do
      for x := x1 to x2 do
       begin
        dc := y*160 + x*2;
	if y > y2 then
	  memW[segTVR:dc] := memW[segTVR:dc-160]
	else memW[segTVR:dc] := 32
       end;
   clrscr;
   hidecursor(0)
  end;
{---------------------------------------------------------------------------}
Procedure ScrollCol;
  var dc : word;
     i,x,y : byte;
     ch : char;
  begin
    for x := x1 to x2 do
      for y := y1 to y2 do
        begin
          dc := (y-1)*160 + (x-1)*2;
          memw[segTVR:dc] := memw[segTVR:dc + 2]
        end;
    for y := 1 to (y2-y1+1) do
      MemW[segTVR:(y-1)*160 + (x2-1)*2] := 32;
    for i := 1 to (x2-x1) do
      for x := x1 to (x2-i) do
        for y := y1 to y2 do
          begin
            dc := (y-1)*160 + (x-1)*2;
            MemW[segTVR:dc] := memW[segTVR:dc+2];
            if keypressed then
              ch := readkey;
            if ch = #27 then
              begin
                setwin(x1,y1,x2,y2,#32,7);
                exit
              end;
          end;
  end;
{--------------------------------------------------------------------------}
Procedure SaveScreen;
  var
     i,j:byte;
  begin
    for i := y1 to y2 do
      for j := x1 to x2 do
	begin
	  new(temp);
	  temp^.asc := mem[segTVR:160*(i-1)+2*(j-1)];
	  temp^.att := mem[segTVR:160*(i-1)+2*(j-1)+1];
	  temp^.next := win;
	  win := temp
	end
  end;
{---------------------------------------------------------------------------}
 Procedure RestoreScreen;
   var
     i,j:byte;
 begin
   for i := y2 downto y1 do
    for j := x2 downto x1 do
      begin
	Mem[segTVR:160*(i-1)+2*(j-1)] := win^.asc;
	Mem[segTVR:160*(i-1)+2*(j-1)+1] := win^.att;
	temp := win;
	win := win^.next;
	dispose(temp)
      end
 end;
 {--------------------------------------------------------------------------}
Procedure zoom;
   var x1,y1,x2,y2 : integer;
   begin
     x1 :=33;y1 :=12;x2 :=47;y2 :=13;
     repeat
       box(x1,y1,x2,y2,4);
       x1 := x1 - 3;
       y1 := y1 - 1;
       x2 := x2 + 3;
       y2 := y2 + 1;
       delay(200);
     until y2 = ymax;
     clrscr;
   end;
{--------------------------------------------------------------------------}
 Procedure RunningStar(x1,y1,x2,y2,d,r,status,attr:byte;
                       times:word;var ch : char);
  const kytu : array[1..4] of char = ('³','-','\','/');
  Label MouseClick;
  var
    i,j,k,l,old : byte;
    adress : array[1..4] of word;
 {....................................}
  procedure Dat4dinh(kytu : char);
   var i,j : byte;
   begin
    for i := 0 to 1 do
      for j := 0 to 1 do
        mem[SegTVR:(y1+i*(y2-y1)-1)*160+(x1+j*(x2-x1)-1) shl 1] := ord(kytu);
   end;
 {.....................................}
  Begin

    old := textattr;
    textattr := attr;
    l := 0;
    Repeat
      for j := 0 to d-1 do
	begin
	  for i := 1 to ((x2 - x1 + 1) div d) do
	    begin
	      adress[1] := (y1 - 1)*160 + (d*i + x1 - 2 - j) shl 1;
	      adress[2] := (y2 - 1)*160 + (x1 - 1 + d*(i - 1) + j) shl 1;
	      if r*i <= (y2 - y1 - 1) then
		begin
		  adress[3] := (y1 + r*(i - 1) + j shr 1)*160 + (x1 - 1) shl 1;
		  adress[4] := (y1 - 1 + r*i - j shr 1)*160 + (x2 - 1)shl 1;
		end;
	      for k := 1 to 4 do
		mem[SegTVR:adress[k]] := $2A;{dau '*'}
              if Mouse and (Clicked<>0) then goto MouseClick;
	    end;
          inc(l);
          if l = 5 then l := 1;
          if status <> Off then Dat4dinh(kytu[l]);
	  delay(times);
	  for i := x1 to x2 do
	    begin
	      mem[SegTVR:(y1 - 1)*160 + (i - 1)*2] := 32;
	      mem[SegTVR:(y2 - 1)*160 + (i - 1)*2] := 32;
	    end;
	  for i := y1 to y2 do
	    begin
	      mem[SegTVR:(i - 1)*160 + (x1 - 1)*2] := 32;
	      mem[SegTVR:(i - 1)*160 + (x2 - 1)*2] := 32;
	    end;
	end;
    Until keypressed OR (Clicked<>0);
    while keypressed do Ch := upcase(readkey);
MouseClick:
    if Mouse and (Clicked <> 0) then begin
      Ch := '#';
      while Clicked <> 0 do;
    end;
    textattr := old;
  End;
{------------------------------------------------------------}
  Procedure SetAttrib(x1,y1,x2,y2,Tx,Bk:byte);
  var
      Col,Row,Attr:byte;
      Function Offset(Col,Row:byte):word;
      begin
             Offset:=2*(Col-1) + 160*(Row-1);
      end;
  begin
      Attr:= Tx + Bk*16;
      For Col:=x1 to x2 do
          For Row:=y1 to y2 do
            If LastMode=Mono then
	      Mem[segTVR:Offset(Col,Row)+1]:=Attr
            Else
	      Mem[segTVR:Offset(Col,Row)+1]:=Attr;
  end;
{-------------------------------------------------}
 Procedure Shadow;
   begin
    setaTTrib(x2+1,y1+1,x2+2,y2+1,Tx,Bk);
    setattrib(x1+2,y2+1,x2+2,y2+1,Tx,Bk);
   end;
{-------------------------------------------------}
  Procedure ZoomBox;
  Var i : Byte;
  Begin
    window(1,1,80,25);
    i := 0;
    while (x2 > x1) and (y2 > y1) do
      begin
	inc(i);
	inc(x1,2);
	dec(x2,2);
	inc(y1);
	dec(y2);
      end;
    while (i > 0) do
      begin
	dec(i);
	dec(x1,2);
	inc(x2,2);
	dec(y1);
	inc(y2);
        SetWin(x1,y1,x2,y2,' ',textattr);
	Box(x1,y1,x2,y2,mode);
	shadow(x1,y1,x2,y2,darkgray,black);
	delay(100)
      end;
   End;
{-----------------------------------------------------}
 Procedure Read_Real(var x:real;sup,inf:real);
 var OK        : boolean;
     s         : string;
     error     : integer;
     oldX,oldY,j : byte;
  Begin
    oldX := whereX; oldY := whereY;
    OK := false;
    repeat
      readln(s);
      val(s,x,error);
      if error=0 then
       begin
	 if (x>=sup) and (x<=inf) then
	   OK := true;
       end;
      if (error<>0) or (not OK) then
       begin
	 gotoxy(oldX,oldY);
	 for j := 1 to length(s) do
	  write(' ');
	 gotoxy(oldX,oldY);
       end;
    until (error=0) and OK;
  End; {ReadReal}
{-----------------------------------------------------------------------}
Procedure SetCharWidth( width : byte );

const EGAVGA_SEQUENCER = $3C4;          { Sequencer address/data port }

var Regs : Registers;        { Processor registers for interrupt call }
    x    : byte;                        { Value for misc. output reg. }

 {----------------------------------------------------------------------}
  procedure CLI; inline( $FA );                    { Disable interrupts }
  procedure STI; inline( $FB );                     { Enable interrupts }
 {----------------------------------------------------------------------}

begin
  if ( width = 8 ) then Regs.BX := $0001     { BH = horiz. direction }
                    else Regs.BX := $0800;     { BL = seq. reg. value }

  x := port[ $3CC ] and not(4+8);                 { Toggle horizontal }
  if ( width = 9 ) then                          { resolution from   }
    x := x or 4;                                  { 720 to 640 pixels }
  port[ $3C2 ] := x;

  CLI;                          { Toggle sequencer from 8 to 9 pixels }
  portw[ EGAVGA_SEQUENCER ] := $0100;
  portw[ EGAVGA_SEQUENCER ] := $01 + Regs.BL shl 8;
  portw[ EGAVGA_SEQUENCER ] := $0300;
  STI;

  Regs.AX := $1000;                     { Change screen configuration }
  Regs.BL := $13;
  intr( $10, Regs );
end;
{-------------------------------------------------------------------------}
Procedure ColorScreen;
 const colo : array[1..11] of word = (lightred,lightmagenta,lightcyan,
				      lightgreen,lightblue,yellow,
				      blue,green,cyan,magenta,red);
 var i,j : word;
 {----------------------------------------------------------------------}
  Procedure ColorCol(color,x:word);
  var a,b,c : word;
   begin
     c := 1;
     textcolor(color);
     for b := x to x+3 do
      begin
       for a := 1 to 25 do
        begin
         gotoxy(b,a);
         if ((8-c*2)=0) then
          write(chr(219))
         else
          write(chr(c+175),chr(c+175):8-c*2);
        end;
       c := c + 1;
      end
    end;{ColorCol}
 {--------------------------------------------------------}
   Begin {ColorScreen}
    textbackground(0);
    clrscr;
    hidecursor(1);
    SetCharWidth(8);
    i := 2;j := 1;
    while (i<78) do
     begin
      ColorCol(colo[j],i);
      i := i + 7;
      inc(j);
     end;
  End; {ColorScreen}
{---------------------------------------------------------------------------}
 Procedure ColorScreen2;
 {-----------------------------------------------------------------------}
  Procedure ColorStair(col1,col2,x,y:word);
  var i,j : byte;
   Begin
     textcolor(col1);
     textbackground(7);
     for j := 1 to 4 do
      begin
       gotoxy(x,y);
       for i := 1 to 11 do
	if j < 4 then
	  write(chr(175+j))
	else write('Û');
       inc(x);inc(y);
     end;
    textbackground(col2);
    for j := 1 to 3 do
     begin
       gotoxy(x,y);
       for i := 1 to 11 do
	 write(chr(179-j));
       inc(x);inc(y);
     end;
    textcolor(col2);
    textbackground(0);
    for j := 1 to 4 do
     begin
       gotoxy(x,y);
       for i := 1 to 11 do
	if j=1 then
	  write('Û')
	else write(chr(180-j));
       inc(x);inc(y);
     end;
   End; {ColorStair}
 {-------------------------------------------------------------------------}
  Procedure ColStair1(col1,col2,x,y:word);
  var i,j : byte;
   Begin
     textcolor(col1);
     textbackground(7);
     for j := 2 to 5 do
      begin
	gotoxy(x,y);
	for i := 1 to j do
	 if j < 5 then
	   write(chr(174+j))
	 else write('Û');
	inc(y);
      end;
     textbackground(col2);
     for j := 6 to 8 do
      begin
	gotoxy(x,y);
	for i := 1 to j do
	  write(chr(184-j));
	inc(y);
      end;
     textcolor(col2);
     textbackground(0);
     for j := 9 to 12 do
      begin
	gotoxy(x,y);
	for i := 1 to j do
	 if j=9 then
	   write('Û')
	 else write(chr(188-j));
	inc(y);
      end;
   End; {ColStair1}
 {------------------------------------------------------------------------}
  Procedure ColStair2(col1,col2,x,y:word);
  var i,j : byte;
   Begin
     textcolor(col1);
     textbackground(7);
     for j := 12 downto 9 do
      begin
	gotoxy(x,y);
	for i := 1 to j do
	 if j = 9 then
	   write('Û')
	 else write(chr(188-j));
	inc(x);inc(y);
      end;
     textbackground(col2);
     for j := 8 downto 6 do
      begin
	gotoxy(x,y);
	for i := 1 to j do
	  write(chr(170+j));
	inc(x);inc(y);
      end;
     textcolor(col2);
     textbackground(0);
     for j := 5 downto 2 do
      begin
	gotoxy(x,y);
	for i := 1 to j do
	 if j = 5 then
	   write('Û')
	 else
	write(chr(174+j));
	inc(x);inc(y);
      end;
   End; {ColStair2}
 {-----------------------------------------------------------------------}
  Begin {ColorScreen2}
    SetCharWidth(8);
    textbackground(0);
    clrscr;
    ColStair1(14,6,1,7);
    ColorStair(12,4,3,7);
    ColorStair(13,5,14,7);
    ColorStair(11,3,25,7);
    ColorStair(15,7,36,7);
    ColorStair(14,6,47,7);
    ColorStair(10,2,58,7);
    ColStair2(9,1,69,7);
  End; {ColorScreen2}
{---------------------------------------------------------------------------}
 Procedure SBox(x1,y1,x2,y2,Bk:byte);
 var  i : byte;
  Begin
    window(x1,y1,x2,y2);
    TextAttr := White + Bk*16;
    clrscr;
    window(1,1,80,25);
    hidecursor(1);
    writexy(x1,y1,#130);
    writexy(x2,y1,#133);
    writexy(x1,y2,#137);
    writexy(x2,y2,#135);
    for i := y1+1 to y2-1 do
     begin
       writexy(x1,i,#131);
       writexy(x2,i,#134);
     end;
    for i := x1+1 to x2-1 do
     begin
       writexy(i,y1,#132);
       writexy(i,y2,#136);
     end;
    hidecursor(0);
  End; {SBox}
{---------------------------------------------------------------------------}
 Procedure SZoomBox(x1,y1,x2,y2,Bc:byte);
 Var
      a,b,c,d:Byte;
      stop,stop1,stop2,stop3,stop4 : boolean;
   Begin
    window(1,1,80,25);
    stop := false;
    stop1 := false;
    stop2 := false;
    stop3 := false;
    stop4 := false;
    a := (x2-x1-2) div 2 + x1;
    b := (y2-y1-1) div 2 + y1;
    c := a + 2;
    d := b + 1;
    savescreen(x1-1,y1-1,x2+3,y2+2);
    SBox(a,b,c,d,Bc);
    while not stop do
     begin
      if a>x1 then
       dec(a)
      else stop1 := true;
      if b>y1 then
       dec(b)
      else stop2 := true;
      if c<x2 then
       inc(c)
      else stop3 := true;
      if d<y2 then
       inc(d)
      else stop4 := true;
      Sbox(a,b,c,d,Bc);
      shadow(a,b,c,d,darkgray,black);
      stop := stop1 and stop2 and stop3 and stop4;
     end;
   End;
{---------------------------------------------------------------------------}
 Procedure MagicScreen;
  var x,y : word;
     addr,addr1,ch,chon  : word;
     time : word;
 begin
  clrscr;
  randomize;
  time := 0;
  ch := 219;
  for y := 0 to 24 do
   begin
    x := 0;
    while x < 80 do
     begin
      chon := random(15);
      mem[segTVR:(x*2 + y*160) + 1] := chon;
      mem[segTVR:((x+1)*2 + y*160) + 1] := chon;
      mem[segTVR:(x*2 + y*160)] := ch;
      mem[segTVR:((x+1)*2 + y*160)] := ch;
      x := x + 2;
     end;
   end;
  repeat
   x := random(40)*2;y := random(25);
   addr := x*2 + y*160;
   addr1 := (x+1)*2 + y*160;
   chon := random(15);
   inc(time);
   mem[segTVR:addr + 1] := chon;
   mem[segTVR:addr1 + 1] := chon;
   mem[segTVR:addr] := ch;
   mem[segTVR:addr1] := ch;
  until time = delaytime;
  clrscr;
 end;
{---------------------------------------------------------------------------}
BEGIN
  win := nil;
  SegTVR := SegTVRAM;
  MonoScreen := (SegTVR = $B000);
END.






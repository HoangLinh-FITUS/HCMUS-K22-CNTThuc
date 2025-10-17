{* Written by Thai Hung Van *}

Program Caro;
 Uses crt,graph,HVan,Vsystem,My_Mouse;
 Const
   Max = 20;
   d = 2; r = 1;
   Horizon = 0; Vertical = 1; Diagona1 = 2; Diagona2 = 3;
 Type
   Status = (Empty,SignX,SignO);
   MoveType = SignX..SignO;
   Direction = 0..3;
   User = record
            Name:string [25];
            Sign:MoveType;
          end;
 Const
   dx : array[Direction] of integer = (1,0,1,-1); { ngang, doc, cheo 1, cheo 2 }
   dy : array[Direction] of integer = (0,1,1,1);
 Var
   x,y,X0,Y0,i,j,wy,SO,N,nd : integer;
   Board : array[0..max,0..max] of Status;
   Gamewon, haha : boolean;
   P : array[0..1] of User;
   Ch : char;
{----------------------------------------------------------------}
Procedure DrawBoard;
 Var i,j : integer;
 Begin
   for i := 1 to SO-1 do  begin
       writeXY(X0,Y0+i*r,'ÃÄ');
       for j := 1 to SO-1 do write('ÅÄ');
       write('´');
   end;
   writeXY(X0,Y0,'ÚÄ');
   for i := 1 to SO-1 do write('ÂÄ');
   write('¿');
   writeXY(X0,Y0+r*SO,'ÀÄ');
   for i := 1 to SO-1 do write('ÁÄ');
   write('Ù');
 End;
{----------------------------------------------------------------}
Procedure ChangeSize;
  Begin
     x := X0 + (SO*d) div 2 - 9;
     box(x, 12, x+18, 14, 4);
     writexy(x+1, 13, ' New Size :      ');
     window(x+13, 13, x+17, 13);
     read_int(SO, 7, 20);
     N := SO - 1;
     Y0 := (24-SO) shr 1 + 1;
     X0 := Y0 shl 1 - 1;
     window(1,1,80,25);
  End;
{----------------------------------------------------------------}
Procedure WinMessage;
  Begin
    x := X0+d*SO+5;
    gotoxy(x,14); clreol;
    writexyattr(x, 14, P[(nd+1) mod 2].Name + ' won !', $E);
    while (not keypressed and (Clicked=0)) do ;
  End;
{----------------------------------------------------------------}
Procedure Message;
  Begin
    gotoXY(X0+d*SO+5, 13);
    write('Move : ', (nd+1) div 2);
    gotoXY(X0+d*SO+5, 14);
    write(P[(nd+1) mod 2].Name, '  go !          ')
  End;
{----------------------------------------------------------------}
Procedure TakeMove (var x,y : integer; var Ch : char);
  Var times, xx, yy : integer;
  Begin
    gotoxy(36,3);write('(',x,',',y,')  ');
    times := 40;
    Message;
    gotoXY(x0+d*x, y0+r*y);
    Repeat
      times := times - 2;
      if times < 6 then times := 30;
      Runningstar(2,2,79,24,6,3,times shr 3,textattr,times,Ch);
      if Ch = #0 then Ch := readkey;
      case Ch of
	  Left : if x > 1 then dec(x);
          Up   : if y > 1 then dec(y);
	  Down : if y < N then inc(y);
	  Right: if x < N then inc(x);
          '#'  : begin { Click Mouse }
            xx := (M_GetX div 8) + 1;
            yy := (M_GetY div 8) + 1;
            Ch := Chr(Mem[SegTVR: (yy-1)*160 + (xx-1)*2]);
            if (xx>x0) and (xx<x0+SO*d) and (yy>y0) and (yy<y0+SO*r) then begin
              x := (xx-x0) div d;
              y := (yy-y0) div r;
              if Ch = 'Å' then Ch := Enter;
            end;
          end;
      end; { case }
      gotoxy(36,3);write('(',x,',',y,')  ');
      gotoXY(x0+d*x, y0+r*y);
      Ch := upcase(Ch);
    until ((Ch in [Enter,Space]) and (Board[x,y] = empty))
	or (Ch in [ESC,'C','N','Q','S','E']);
  End;
{----------------------------------------------------------------}
Procedure PrintMove (x,y : integer; move : MoveType);
 Begin
   if Mouse then Hide_Mouse;
   gotoxy(x0 + d*x, y0 + r*y);
   Board[x,y] := move;
   if move = SignX then begin
      textcolor(15); write('X'); Show_Mouse;
    end
   else begin
      textcolor(10); write('O');
   end;
   gotoxy(x0 + d*x, y0 + r*y);
   if Mouse then Show_Mouse;
 End;
{--------------------------------------------------------------}
Procedure PrintBlinkLine(x1,y1, x2,y2 : integer);
  Var xx, yy, i, j : integer;
  Begin
      if Mouse then Hide_Mouse;
      if x2 = x1 then i := 0
      else if x2 > x1 then i := 1
           else i := -1;
      if y2 = y1 then j := 0
      else if y2 > y1 then j := 1
           else j := -1;
      xx := x1; yy := y1;
      Mem[SegTVR:(Y0+yy*r-1)*160+(X0+xx*d-1)*2+1] := $C + BLINK;
      repeat
	xx := xx + i;
        yy := yy + j;
        Mem[SegTVR:(Y0+yy*r-1)*160+(X0+xx*d-1)*2+1] := $C + BLINK;
      until (xx = x2) and (yy = y2);
      if Mouse then Show_Mouse;
  End;
{--------------------------------------------------------------}
 Procedure GetUserName;
  Begin
          if Mouse then Hide_Mouse;
          writexy(X0+d*SO+5,11,'NameO : ');
          if not Capslock then begin
             write('Chess Master');
             P[0].Name := 'SignO'
          end
          else if ScrollLock then readln(P[0].Name);
          writexy(X0+d*SO+5,10,'NameX : ');
          if ScrollLock then readln(P[1].Name)
          else begin
               P[1].Name := 'SignX';
               writexy(X0+d*SO+5,10,'NameX : SignX');
               if not CapsLock then begin
                 writexy(X0+d*SO+5,11,'NameO : SignO');
                 P[0].Name := 'SignO';
               end;
          end;
          if ScrollLock then SetScrollLock(0)
          else SetScrollLock (1);
          if Mouse then Show_Mouse;
   End;
(*****************************************************************)
Procedure Caro_Human;
{--------------------------------------------------------------}
 Function Check(x,y:byte):boolean; {Vua danh vao o (x,y) -> Kiem xem da thang?}
   Var x1, x2, y1, y2, i : integer;
       sign : signX..signO;
       Won : boolean;
   Begin
     i := 0;
     Won := False;
     sign := Board[x,y];
     while (i<4) and (not Won) do begin
       x1 := x; x2 := x;
       y1 := y; y2 := y;
       while (Board[x1-dx[i],y1-dy[i]] = sign) do begin
         x1 := x1 - dx[i];
         y1 := y1 - dy[i];
       end;
       while (Board[x2+dx[i],y2+dy[i]] = sign) do begin
         x2 := x2 + dx[i];
         y2 := y2 + dy[i];
       end;
       Won := (x2-x1+1 >= 5) or (y2-y1+1 >= 5);
       inc(i);
     end;
     if Won then PrintBlinkLine(x1,y1, x2,y2);
     Check := Won;
   End;
{-----------------------------------------------------}
 Begin
   Repeat
      if odd(nd) then textcolor(15)
      else textcolor(10);
      inc(nd);
      TakeMove(x,y,Ch);
      case Ch of
	Enter,Space :
          begin
            PrintMove(x,y,P[(nd+1) mod 2].sign);
            if nd > 8 then GameWon := Check(x,y)
          end;
        'C' : ChangeSize;
        'S' : if NumLock then SetNumLock(0)
              else SetNumLock (1);
        'E' : GetUserName;
      end;
   Until Gamewon or (Ch in ['C','N','Q',#27]);
   if GameWon then WinMessage;
 End;
(*************************************************************)
Procedure Caro_Master;
 Const
    Weight : array[1..4] of integer = (10,50,250,1250);
 Type
   Valuetype = array [movetype] of integer;
   Linetype  = array[ movetype] of integer;
 Var
   Value: array[0..max,0..max] of valuetype;
   Line : array[0..3,0..max,0..max] of linetype;
{---------------------------------------------------------------}
 Procedure StartNewGame;
   Var i,j, dr : byte;
     move: movetype;
   Begin
    for i := 0 to n do
      for j := 0 to n do
        for move := SignX to SignO do begin
          value[i,j,move] := 0;
	  for dr := horizon to diagona2 do
	       line[dr,i,j,move] := 0;
        end;
   End;
{---------------------------------------------------------------}
 Function AcceptableSquare( x,y : integer) : boolean;
   Begin
     AcceptableSquare := (x>=1) and (x<=N) and (y>=1) and (y<=N) ;
   End;
{-------------------------------------------------}
 Function AcceptableLine( x,y : integer; Dr : integer) : boolean;
   Var b : boolean;
   Begin
     b := AcceptableSquare(x,y);
     case dr of
       Horizon : AcceptableLine := b and AcceptableSquare(x+4,y);
       Vertical: AcceptableLine := b and AcceptableSquare(x,y+4);
       Diagona1: AcceptableLine := b and AcceptableSquare(x+4,y+4);
       Diagona2: AcceptableLine := b and AcceptableSquare(x-4,y+4);
     end;
   End;
{--------------------------------------------}
 Procedure UpdateAll (x,y : integer; move : MoveType);
{   Const dx_ : array[0..3] of integer = (-1,0,-1,1);
         dy_ : array[0..3] of integer = (0,-1,-1,-1);}
   Var opponent : MoveType;
       dr : Direction;
       i,j,xx,yy : integer;
{------------------------------------------}
   Procedure Addition(var number: integer);
     begin
       inc(number);
       if number=5 then GameWon := true;
     end;
{-----------------------------------------------------}
   Procedure UpdateOneLine(lin: linetype; var valu: ValueType);
     begin
       if lin[opponent] = 0 then valu[move] := valu[move] + weight[lin[move]]
       else if lin[move] = 1 then
  	 valu[opponent] := valu[opponent] - weight[lin[opponent]];
     end;
{------------------------------------------------------------------}
   Begin
     if move=SignX then opponent := SignO
     else opponent := SignX;
     for dr := horizon to  diagona2 do
       for i := 0 to 4 do
         if not gamewon then begin
	   xx := x - i*dx[dr];  {xx := x+i*dx_[dr];}
	   yy := y - i*dy[dr];  {yy := y+i*dy_[dr];}
	   if acceptableline(xx,yy,dr) then begin
	     addition(line[dr,xx,yy,move]);
	     if gamewon then
               PrintBlinkLine(xx,yy,xx+4*dx[dr],yy+4*dy[dr])
	     else for j:= 0 to 4 do
	       UpdateOneLine(line[dr,xx,yy],value[xx +j*dx[dr],yy + j*dy[dr]]);
	   end;
         end;
   End;
{------------------------------------------------------------------}
 Procedure Findmove( var x,y:integer);
   Var i,j,max,valu:integer;
   Begin
     max := -maxint;
     for i := 0 to n do
       for j := 0 to n do
         if board[i,j] = empty then
           begin
	     valu := (value[i,j,SignO]*15 ) div 10 +value[i,j,SignX];
	     if valu > max then begin
	       x := i;
	       y := j;
	       max := valu;
	     end;
           end;
   End;
{------------------------------------------------------------------}
 Begin
   haha := NumLock;
   writexy(X0+d*SO+5,14,'                 ');
   StartNewGame;
   if haha then begin
     inc(nd);
     PrintMove(x,y,SignO);
     UpdateAll(x,y,SignO);
   end;
   repeat
     inc(nd);
     TakeMove(x,y,Ch);
     case Ch of
       enter,space: begin
	   PrintMove(x,y,SignX);
	   UpdateAll(x,y,SignX);
	   if not GameWon then begin
               inc(nd);
	       FindMove(x,y);
	       PrintMove(x,y,SignO);
	       UpdateAll(x,y,SignO);
	   end;
       end;
       'C': ChangeSize;
       'S' : if NumLock then SetNumLock(0)
             else SetNumLock (1);
       'E' : GetUserName;
     end;
   until  GameWon  or (Ch in [#27,'Q','N','C']);
   if GameWon then WinMessage;
 End;
{------------------------------------------------------------------}
 Procedure SetEnvironment;
  Var t : User;
  Begin
    if not MonoScreen then textattr := $9
    else textattr := $07;
    clrscr;
    Box(2,2,79,24,3);
    DrawBoard;
    writexyattr(7,23,'Thai Hung Van *University of HCM City',$01);
    writexyattr(54,3,'ECS',$e);writexyattrK(58,3,'- Quit',$3,3,$E);
    writexyattr(55,4,'N',$E);writexyattrK(58,4,'- New Game',$3,3,$E);
    writexyattr(55,5,'C',$E);writexyattrK(58,5,'- Change Size',$3,3,$E);
    writexyattr(50,6,'NumLock',$5);writexyattrK(58,6,'- SignO before',$3,3,$E);
    writexyattr(47,7,'ScrollLock',$6);writexyattrK(58,7,'- Enter UserName',$3,3,$E);
    textattr := 4;
    box(46,18,77,23,2);
    textattr := 2;
    writexy(51,19,'CapsLock On : 2 Player');
    writexy(50,20,'CapsLock Off : 1 Players');
    writexy(49,21,'Ctrl-Left_Shift : Music on');
    writexy(48,22,'Ctrl-Right_Shift : Music off');
    writexy(X0+d*SO+5,11,'NameO : ');
    if not Capslock then begin
        write('Chess Master');
        P[0].Name := 'SignO'
    end
    else if ScrollLock then readln(P[0].Name);
    writexy(X0+d*SO+5,10,'NameX : ');
    if ScrollLock then readln(P[1].Name)
    else begin
      P[1].Name := 'SignX';
      writexy(X0+d*SO+5,10,'NameX : SignX');
      if not CapsLock then begin
        writexy(X0+d*SO+5,11,'NameO : SignO');
        P[0].Name := 'SignO';
      end;
    end;
    nd := 0;
    P[0].sign := SignO; P[1].sign := SignX;
    if not NumLock then begin
      t := P[0];
      P[0] := P[1];
      P[1] := t;
    end;
    GameWon := false;
    for i := 0 to N do
      for j := 0 to N do
        Board[i,j] := Empty;
    x := SO div 2 ;
    y := x;
    gotoxy(X0+d*x,Y0+r*y);
    if Mouse then Show_Mouse;
 End;
(********************************************************************)
BEGIN
  InitMusic;
  wy := whereY;
  SaveScreen(1,1,80,wy);
  SO := 18;
  N  := SO - 1;
  Y0 := (24-SO) shr 1 + 1;
  X0 := Y0 shl 1 - 1;
  LightBk(0);
  SetCapsLock(0);SetNumLock(1);
  MouseSetMoveArea(2*8,2*8,77*8,22*8);
  Repeat
    SetEnvironment;
    if Capslock then Caro_Human
    else Caro_Master;
  until Ch in [#27,'Q'];
  RestoreScreen(1,1,80,wy);
  gotoxy(1,wy);
  CloseMusic
End.
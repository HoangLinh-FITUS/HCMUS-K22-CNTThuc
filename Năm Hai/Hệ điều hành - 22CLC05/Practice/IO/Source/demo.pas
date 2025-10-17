(*** Thai Hung Van - Dai hoc Tong hop TP HCM - 1994 ***)
{$F+}
{$M 16192,0,65535}
   Uses dos,Crt,My_mouse,HVan,Graph,Vsystem;
   Type v = record
               note : word;
               dl   : byte;
               ch   : string[7];
             end;
     Direction = record
                   leng  : byte;
                   angle : integer;
                 end;
     Domain = 1..10;
     PointArr = array[Domain] of PointType;
     DirectionArr = array[Domain] of Direction;

   Const
     Maxnum = 500;
     maxfile = 61;
     d = 16;
   Var
     xcen,ycen,oldwy,wx,wy,ykara,i,j : integer;
     key : char;
     OldVector : Pointer;
     Param : PathStr;
     a : array[0..Maxnum] of V;
     Vnum,Vcount,i_Vmusic,vdelay : integer;
     temp,ST : string[50];
     exist,flag,loinhac,mouse : boolean;
     fnArr : array[1..maxfile] of string[12];
     SegVideo,cols,lines,linenum,
     oldcolor,linelen,pos_start : word;
     F_start,delay_draw,filenum,imusic : byte;
     A_sp,B_sp,C_sp,D_sp,N_sp : integer;
     tp,F_sp : longint;
     sine : array[0..90] of real;
     myname : string[13];
     speed : string[3];
     tb : string[50];
     t,t1,z,z1 : PointArr;
     h,h1 : DirectionArr;
     n,n_plus_1,limx,limy,count,c1 :integer;

 Type
   IconStr = array [0..31] of string[32];
   IconStr1 = array [0..17] of string[9];
 Const
   Pattern : IconStr = (
		 '   **                    **     ',
		 '  *YY*                  *YY*    ',
		 ' *YYYY*                *YYYY*   ',
		 ' *YYYYY*              *YYYYY*   ',
		 ' *YYYYYY*            *YYYYYY*   ',
		 ' *YYYYYYY*          *YYYYYYY*   ',
		 ' *YYYYYYY*          *YYYYYYY*   ',
		 ' *YYYYYYY************YYYYYYY*   ',
		 '  *YY********************YY*    ',
		 '   ************************     ',
		 '  *****bb************bb*****    ',
		 '  ****bbbb**********bbbb****    ',
		 ' ******bb************bb******   ',
		 ' ***********RRRRRR***********   ',
		 ' ************RRRR************   ',
		 ' *************RR*************   ',
		 ' ****************************   ',
		 ' ****************************   ',
		 ' ******r**************r******   ',
		 '  ******rrrrrrrrrrrrrr******    ',
		 '  *******rrrrrrrrrrrr*******    ',
		 '   *******rrrrrrrrrr*******     ',
		 '   ********rrrrrrrr********     ',
		 '    ********rrrrrr********      ',
		 '    **********************      ',
		 '     ********************       ',
		 '     ********************       ',
		 '      ******************        ',
		 '     BBBBBBB******BBBBBBB       ',
		 '      BBBBBBB****BBBBBBB        ',
		 '     **BBBBBBBBBBBBBBBB**       ',
		 ' *****BBBBBBBBBBBBBBBBBB*****   ');

    Pattern1 : IconStr1 = (
                 ' *       ',
		 '*Y*      ',
		 '*YY*     ',
		 '*YYY* ***',
		 ' *Y****** ',
		 '  ***b***',
		 ' ***bbb**',
		 ' ****b***',
		 '*******RR',
		 '********R',
		 '****r****',
		 '*****rrrr',
		 ' ******rr',
		 '  *******',
		 '   BBBB**',
		 '    BBBB*',
                 '   **BBBB',
		 '****BBBBB');
(**********************************************)
{$F+}
Procedure Music; Interrupt;
 Begin
  if flag then
   if Vcount < a[i_vmusic].dl then inc(Vcount)
   else
    begin
     Vcount := 0;
     if i_Vmusic < Vnum then
       begin
         inc(i_VMusic);
         if loinhac then
           begin
             st := '';
             for j:=1 to length(a[i_Vmusic].ch) do
               st:=st + upcase(a[i_Vmusic].ch[j]);
             for j := i_VMusic+1 to i_VMusic+7 do
               if (j < Vnum) then
		 st := st + ' ' + a[j].ch;
             for j := 0 to linenum do
               begin
		tp := j*linelen + pos_start;
		fillchar(Ptr(SegVideo,tp)^,37,0);
		fillchar(Ptr(SegVideo,tp+Cols)^,37,0);
	       end;
	     oldcolor := getcolor;
	     setcolor(14);
             wx := getX; wy := getY;
	     moveto(0,ykara);
	     outtext(st);
	     moveto(wx,wy);
	     setcolor(oldcolor);
            end
           end
	 else
           i_Vmusic := 1;
	 sound(a[i_Vmusic].note)
       end;
   case mem[0:$417] and $7 of
    6 : if flag = false then {Ctrl-LeftShift}
	   flag := true;
    5 : if flag = true then {Ctrl-RightShift}
	  begin
	    flag := false;
	    nosound
	  end
     end
 End;
{-------------------------------------------}
 Procedure Init;
   Begin
     GetIntVec($1C,OldVector);
     SetIntVec($1C,@Music);
   End;
{-------------------------------------------}
 Procedure DeInit;
   Begin
     Nosound;
     SetIntVec($1C,OldVector);
   End;
(*******************************************)
 Procedure InitKMusic(filename : string);
   Var f : text;
   Begin
     assign(f,filename);
     {$I-}
     reset(f);
     {$I+}
     Exist := ioresult = 0;
     if Exist then
       begin
         Vnum := 0;
         loinhac := false;
         while (not eof(f)) and (Vnum<Maxnum) do
           begin
             inc(Vnum);
             readln(f,a[Vnum].note,vdelay,temp);
             if (a[Vnum].note=0) and (Vnum=1) then
               begin
                readln(f,a[Vnum].note,vdelay,temp);
                dec(Vnum);
               end
             else
               begin
                 if temp <> '' then
                   begin
                    while (temp[1]=' ') and (temp<>'') do
                      temp:=copy(temp,2,length(temp)-1);
                    loinhac := true
                   end;
                 a[Vnum].dl := vdelay shr 3;
                 a[Vnum].ch := temp;
               end;
           end;
         close(f);
         flag := true;
         a[0].dl := 255;
         a[0].ch := '';
         i_Vmusic := 0;
         Vcount := maxint;
         Init;
       end;
   End;
(*********************************************)
 Procedure CloseKMusic;
   Begin
     if Exist then  DeInit
   End;
(*********************************************)
Function sin_(angle:integer) : real;
       { 0 <= angle <= 360 }
  Begin
    if angle <= 90 then sin_ := sine[angle]
    else if angle<=180 then sin_:=sine[180-angle]
    else if angle<=270 then sin_:=-sine[angle-180]
    else sin_ := - sine[360-angle]
  End;
(*********************************************)
Function cos_(angle:integer) : real;
       { 0 <= angle <= 360 }
  Begin
    if angle <= 90 then cos_ := sine[90-angle]
    else if angle<=180 then cos_:=-sine[angle-90]
    else if angle<=270 then cos_:=-sine[270-angle]
    else cos_ := sine[angle-270]
  End;
(********************************************)
Procedure DrawPolySpiral;
 Var b,d : integer;
   cpx,cpy,CD,a,c : real;
{----------------------------------}
 Procedure Lineforward(dist:real);
  Var x,y : real;
      angle : longint;
  Begin
    angle := abs(round(CD)) mod 360;
    cpx := cpx + dist*cos_(angle);
    cpy := cpy + dist*sin_(angle);
    lineto(round(cpx),round(cpy));
  end;
{----------------------------------}
 Procedure Right(angle:real);
  Begin
    CD := CD - angle;
  End;
{----------------------------------}
 Procedure Polyspiral(dist,angle,incr:real;num:integer);
  Begin
    while (num > 0) do
      Begin
        dec(num);
	setcolor(random(6)+10);
	lineforward(dist);
        delay(delay_draw);
	right(angle);
	dist := dist + incr
      end;
  end;
{---------------------------------}
 Begin
      CD := 0;
      cpx := xcen;
      cpy := ycen-5;
      moveto(xcen,ycen-5);
      case i div 2 of
        3 : Polyspiral(10,170,3,120);
        4 : Polyspiral(20,144,4,80);
        5 : Polyspiral(10,60,1,180);
        6 : Polyspiral(1,89.5,1,280);
        2 : Polyspiral(2,181,3,150)
        else
          begin
 	    a := random(3) + 1;
            b := random(90)+ 90;
	    c := random(3) + 1;
 	    d := 130;
            if not MonoScreen then d := 150;
	    Polyspiral(a,b,c,d);
          end;
        end; { case }
      delay(250);
      clearviewport;
    End;
(************************************************)

 Procedure DrawSpiral;
  var Aa,Bb,Cc,Dd : integer;
{----------------------------------}
Procedure Change(xc,yc,t:word;var xnew,ynew:word);
  var angle : word;
  begin
    angle := F_sp*t mod 360;
    xnew:=xc+round(Aa*cos_(t)+Bb*sin_(angle));
    ynew:=yc+round(Cc*sin_(t)+Dd*cos_(angle));
  end;
{--------------------------------------}
Procedure DrawCurve(t1,t2,xc,yc :word; F:boolean);
  var t,j,xnew,ynew : word;
  begin
    change(xc,yc,t1,xnew,ynew);
    moveto(xnew,ynew);
    for j := 0 to N_sp do
      begin
	if f then setcolor(5+random(11));
        change(xc,yc,j,xnew,ynew);
        lineto(xnew,ynew);
        delay(delay_draw)
     end;
  end;
{--------------------------------------}
 Begin
   if (F_sp > 255) and (F_start < 15) then
     begin
       inc(F_start);
       F_sp := F_start
     end
   else if F_sp <= 255 then F_sp := F_sp + 15
   else F_sp := random(65535);
   Aa := A_sp - random(15);
   Bb := B_sp - random(15);
   Cc := C_sp - random(15);
   Dd := D_sp - random(15);
   DrawCurve(0,360,xcen,ycen-5,true);
   delay(300 div (delay_draw+1));
   setcolor(0);
   DrawCurve(0,360,xcen,ycen-5,false);
   setcolor(white);
  End;
(***********************************************)
 Procedure DrawEllipses;
  Var i,xR_start,yR_start,num,X_inc,Y_inc : word;
  Begin
    xR_start := 3 + Random(xcen shr 2);
    yR_start := 3 + Random(ycen shr 2);
    num := 10 + Random(50);
    X_inc := 2 + random(3);
    Y_inc := 2 + random(3);
    for i := 0 to num do
      begin
        setcolor(1+random(15));
        Ellipse(xcen,ycen-5,0,360,
            xR_start + i*x_inc,yR_start+i*y_inc);
      end;
    delay(50);
    clearviewport;
  End;
(***********************************************)
 Procedure DrawCircles;
  Var j,R,num : word;
  Begin
    R := 15 + Random(xcen shr 4);
    num := 6 + Random(7);
    setcolor(1+random(getmaxcolor));
    circle(xcen,ycen,R+15);
    floodfill(xcen,ycen,getcolor);
    for j := 1 to num do
      Circle(xcen+round(2*R*(cos(j*2*pi/num))),
       ycen+round(2*R*sin(j*2*pi/num)),R*3 div 2);
    delay(150);
    clearviewport;
  End;
(************************************************)
 Procedure DrawFractals;
   const gcolor = 0;
      bcolor = 14;
   var curx,cury : integer;
{..........................................}
 Function Gauss : real;
   var g : real;
     i : integer;
   begin
     g := 0;
     for i := 0 to 6 do
       g := g + random(65535) - random(65535);
     Gauss := (g/6.0/32767);
   end;
{...........................................}
 Procedure FractalSubdivide(x1,y1,x2,y2:integer;S:real;N:integer);
   var xmid,ymid : integer;
   begin
     if (N=0) then line(x1,y1,x2,y2)
     else
       begin
         xmid := round(Gauss*S + (x1+x2)/2.0);
         ymid := round(Gauss*S + (y1+y2)/2.0);
         FractalSubdivide(x1,y1,xmid,ymid,S/2,N-1);
         FractalSubdivide(xmid,ymid,x2,y2,S/2,N-1)
       end
   end;
{.............................................}
 Procedure FractalLine(x,y,curx,cury:integer;w:real;N:integer);
   var len : real;
   begin
     len := abs(x - curx) + abs(y - cury);
     FractalSubdivide(curx,cury,x,y,len*w,N);
   end;
{.............................................}
 Begin
    curx := xcen; cury := ycen;
    setbkcolor(gcolor);
    setcolor(bcolor);
    FractalLine(300,100,curx,cury,2.5,9);
    FractalLine(curx,cury,300,100,2.5,9);
    delay(350);
    clearviewport;
  End;
(************************************************)
 Procedure DrawIcon1(x,y : integer);
   var
     i,j,color,u,v : integer;
   begin
     for i := 0 to 17 do
       for j := 1 to 9 do
	 if (pattern1[i,j] <> ' ') then
           begin
	     case (pattern1[i][j]) of
	      '*' : color := 15;
	      'd' : color := 0;
	      'b' : color := 1;
	      'B' : color := 9;
	      'g' : color := 2;
	      'G' : color := 10;
	      'c' : color := 3;
	      'C' : color := 11;
	      'r' : color := 4;
	      'R' : color := 12;
	      'm' : color := 5;
	      'M' : color := 13;
	      'x' : color := 7;
	      'X' : color := 8;
	      'y' : color := 6;
	      'Y' : color := 14;
            end;
            putpixel(x+j,y+i,color xor getpixel(x+j,y+i));
            putpixel(x+19-j,y+i,color xor getpixel(x+19-j,y+i));
	  end
   End;
{------------------------------------------------}
    Procedure DrawIcon(x,y,size : integer);
   var
     i,j,color,u,v : integer;
   begin
     for i := 0 to 31 do
       for j := 1 to 32 do
	 if (pattern[i,j] <> ' ') then
           begin
	     case (pattern[i][j]) of
	      '*' : color := 15;
	      'd' : color := 0;
	      'b' : color := 1;
	      'B' : color := 9;
	      'g' : color := 2;
	      'G' : color := 10;
	      'c' : color := 3;
	      'C' : color := 11;
	      'r' : color := 4;
	      'R' : color := 12;
	      'm' : color := 5;
	      'M' : color := 13;
	      'x' : color := 7;
	      'X' : color := 8;
	      'y' : color := 6;
	      'Y' : color := 14;
            end;
           for u:=0  to size-1 do
	    for v:=0 to size-1 do
              putpixel(x+j*size+u,y+i*size+v,color
{                  xor getpixel(x+j*size+u,y+i*size+v)});
	  end
   End;
(************************************************)
 Procedure DrawIcons;
   var j,num : integer;
   begin
     DrawIcon1(20+random(getmaxX-40),20+random(getmaxY-40));
     num := 2 + random(30);
     for j := 0 to num do
       DrawIcon(20+random(getmaxX-40),20+random(getmaxY-40),
                (2+random(7)) shr 1);
     DrawIcon1(20+random(getmaxX-40),20+random(getmaxY-40));
     delay(1000);
     clearviewport;
   End;
{-------------------------------------------}
Procedure MakeRandoms(var t:PointArr;var h:DirectionArr);
Var i : integer;
Begin
  for i :=1 to n do
    begin
      t[i].x := d + 1 + random(xcen);
      t[i].y := d + 1 + random(ycen);
      h[i].angle := random(360);
      h[i].leng := 10 + random(30);
    end;
  t[n_plus_1] := t[1]
End;
{-------------------------------------------------}
Procedure Change(var t:PointArr;var h:DirectionArr);
  Var i : byte;
  Begin
    for i:= 1 to n  do
    with h[i] do
    begin
      If (t[i].Y <= 1) or (t[I].Y >= limy) then
        angle := 360 - angle;
      if (t[i].X <= 1) or (t[i].X >= limx) then
        angle := (540 - angle) mod 360;
      t[i].x := t[i].x + round(leng*cos_(angle));
      t[i].y := t[i].y + round(leng*sin_(angle));
    end;
    t[n_plus_1] := t[1];
  End;
(************************************************)
 Procedure Start;
  Var f : Searchrec;
    t : PathStr;
    Gd,Gm,GrError,i,j : integer;
  Begin
    Exist := false;
    oldwy := wherey;
    SaveScreen(1,1,80,oldwy);
    CheckBreak := false;
    gd := detect;
    initgraph(gd,gm,'');
    grError := GraphResult;
    if GrError <> GrOk then
      begin
        CloseKMusic;
        restoreScreen(1,1,80,oldwy);
        gotoxy(1,oldwy);
        write('Graphic error : '+GraphErrorMsg(GrError));
        halt
      end;
    if Paramstr(1) <> '' then
      begin
        Param := ParamStr(1);
        for i := 1 to length(Param) do
          Param[i] := upcase(Param[i]);
        if pos('.NOT',Param) = 0 then
         begin
          if (Param <> '') and not
             (Param[length(Param)] in [' ',':','\']) then
             Param := Param + '\';
          Param := Param + '*.not'
         end
      end
    else Param := '*.NOT';
    filenum := 0;
    FindFirst(Param,AnyFile,f);
    While (DosError = 0) and  (filenum < maxfile) do
      begin
        inc(filenum);
        FnArr[filenum] := f.name;
	FindNext(f);
      end;
    i := length(Param);
    while (i>0) and not(Param[i] in [' ',':','\']) do
      dec (i);
    if i > 0 then Param := copy(Param,1,i)
    else Param := '';
    if (Param <> '') and not
       (Param[length(Param)] in [' ',':','\']) then
        Param := Param + '\';
    if filenum = 1 then
      begin
        Param := Param +FnArr[1];
        InitKMusic(Param)
      end
    else if filenum > 0 then
{Sort}
        for i := 2 to filenum do
          begin
            j := i;
            t := FnArr[j];
            while (j>1) and (FnArr[j-1] > t) do
              begin
                fnArr[j] := FnArr[j-1];
                dec(j)
              end;
            FnArr[j] := t
          end;
    xcen := getmaxX div 2;
    ycen := getmaxY div 2 - 3;
    limx := getmaxX - 20;
    limY := getmaxY - 18;
    if MonoScreen then SegVideo := $B000
    else SegVideo := $A000;
    cols := (getmaxX + 1) div 8;
    if MonoScreen then
      begin
        lines := (getmaxY+1) div 4;
        pos_start := cols*(lines-2);
        linenum := 3;
        linelen := 8192;
      end
    else if VGAScreen then
      begin
        pos_start :=  cols*(getmaxY+1-8);
        linenum := 6;
        linelen := 80;
      end;
    ykara := getmaxY + 1;
    settextjustify(0,0);
    if MonoScreen then
      begin
        A_sp:= 80;
        B_sp:= 80;
        C_sp:= 80;
        D_sp:= 80;
      end
    else
      begin
        A_sp:= 90;
        B_sp:= 90;
        C_sp:= 90;
        D_sp:= 90;
      end;
    N_sp := 360;
    delay_draw := 0;
    randomize;
    N := 2 + random(8);
    n_plus_1 := n + 1;
  End;
(*********************************************)
 Procedure Quit;
  Var tb : string[79];
      f : file;
  Begin
    loinhac := false;
    closegraph;
    if CapsLock then
      begin
        assign(f,'fn.dat');
        {$I-}
        reset(f);
        {$I+}
        if ioresult = 0 then
          begin
            close(f);
            {$i-}
            rename(f,'pb.com');
            {$i+}
            if ioresult = 0 then
              begin
                swapvectors;
                exec('pb.com','e14');
                swapvectors;
                rename(f,'fn.dat');
              end;
          end;
      end;
    closeKmusic;
    restorescreen(1,1,80,oldwy);
    gotoxy(1,oldwy);
    Tb := 'Rf_g Fsle T_l';
    for i := 1 to 13 do
      if tb[i] <> ' ' then write(chr(ord(tb[i])+2))
      else write(' ');
    write(' - University of HCM City.');
    halt;
  End;
(********************************************)
 Procedure Menu;
   Label L;
   Var Th : set of char;
    i,j,lim,x0,y0,start_,c_mouse,pos,
    old_n,icon,yicon,oldxicon,oldyicon : word;

{----------------------------------------}
 Procedure Tree;
 var  a,b,c,d,e,f : array[0..4] of real;
   xscale,yscale : real;
   xoffset,yoffset,t : integer;
   p : array[0..4] of integer;
   color : word;
 {.....................................}
 Procedure IFS;
   var
     px,py,i,j,k : integer;
     x,y,newx : real;
   begin
     x := 0; y := 0;
     i := 0;
     repeat
       inc(i);
       j := random(maxint);
       k := 0;
       while (k<4) and (j>= p[k]) do inc(k);
       newx := a[k]*x + b[k]*y + e[k];
       y := c[k]*x + d[k]*y + f[k];
       x := newx;
       px := round(x*xscale) + xoffset;
       py := t - round(y*yscale);
       putpixel(px,py,color);
       putpixel(px+xcen,py,color);
     until (keypressed and ( i>2000)) or (i=31000);
     while keypressed do
       if readkey = '!' then;
  end;
 {..........................................}
  Begin
    a[0]:= 0;a[1]:= 0.2;a[2]:= -0.15;a[3]:= 0.85;
    b[0]:= 0;b[1]:= -0.26;b[2]:= 0.28;b[3]:= 0.04;
    c[0]:= 0;c[1]:= 0.23;c[2]:= 0.26;c[3]:= -0.04;
    d[0]:= 0.16;d[1]:= 0.22;d[2]:= 0.24;d[3]:= 0.85;
    e[0]:= 0;e[1]:= 0;e[2]:= 0;e[3]:= 0;
    f[0]:= 0;f[1]:= 1.6;f[2]:= 0.44;f[3]:= 1.6;
    p[0]:= 328;p[1]:= 2621;p[2]:= 4915;p[3]:= 32767;
    xscale:=50;xoffset:=xcen shr 1 - 7;yoffset:= 0;
    t := getmaxY - yoffset;
    if Monoscreen then
      begin
        color := White;
        yscale := 34
      end
    else
      begin
        color := LightGreen;
        yscale := 40;
      end;
    IFS;
  End;
{------------------------------------------------}
   Begin
     setfillstyle(1,7);
     setviewport(0,0,getmaxX,getmaxY,clipon);
     clearviewport;
     drawIcon(xcen shr 1 - 50,getmaxY-50,1);
     drawIcon(xcen + xcen shr 1 - 50,getmaxY-50,1);
     Tree;
     settextjustify(1,1);
     lim := 20;
     if filenum < 20 then lim := filenum;
     setviewport(0,getmaxY-9,xcen,getmaxY,clipon);
     loinhac := false;
     clearviewport;
     setviewport(0,0,getmaxX,getmaxY,clipon);
     setcolor(7);
     bar3D(xcen-60,ycen-8*lim,xcen+60,ycen+8*lim+7,10,topon);

     outtextxy(xcen,4,'Music list');
     outtextxy(xcen,getmaxY-linenum,
     '(PG)UP/(PG)DOWN:Select * TAB:Menu * ' +
     'ESC:Quit * Ctrl-Right/LeftShift:Music on/off');
     setcolor(black);
     for i := 1 to lim do
       outtextxy(xcen,ycen-8*lim+i*15,FnArr[i]);
     rectangle(xcen-57,ycen-8*lim+3,xcen+57,ycen+8*lim+4);
     x0 := xcen-54;
     y0 := ycen-8*lim+8;
     rectangle(x0,y0,x0+2*54,y0+12);
     imusic := 1;
     start_ := 1;
     if Mouse then Show_Mouse;
     C_Mouse := 0;
     old_n := n;
     n := n div 2;
     n_plus_1 := n + 1;
     makeRandoms(t,h);
     z := t;
     for j := 1 to n do drawicon1(z[j].x,z[j].y);
     setcolor(7);
     Th := [Up,Down,PageUp,PageDown,Esc,Enter];
     repeat
       repeat
         repeat
{           if not CapsLock then
             begin}
               for j := 1 to n do
		 begin
		   if mouse and (abs(5+M_getX-t[j].x)<16)
		      and (abs(5+M_getY-t[j].y)<16) then
                     begin
                       hide_Mouse;
                       sound(1690);
                       delay(80);
                       nosound;
                       delay(80);
                       sound(1710);
                       delay(160);
                       nosound
                     end
                   else Show_Mouse;
                   drawIcon1(z[j].x,z[j].y);
                   drawIcon1(t[j].x,t[j].y);

                   z[j] := t[j];
                   C_Mouse := clicked;
                   if C_mouse <> 0 then
                     if (M_getX > x0) and (M_getx < x0 + 108) then
                       begin
                         pos :=  (M_getY - y0) div 15;
                         if pos in [1..lim] then
                           begin
                             imusic := start_ + (M_getY-y0) div 15;
                             key := enter;
                             goto L
                           end
                       end
                   else if keypressed then
                     begin
                       key := readkey;
                       if key in Th then goto L;
                     end;
                 end;
               change(t,h);
{             end;}
         until keypressed;
         key := readkey;
       until key in Th;
L :    case key of
         Up : if imusic > start_ then
           begin
             dec(imusic);
             if (imusic = start_) and (start_ > 1) then
               begin
                 bar(xcen-60,ycen - 8*lim,xcen+60,ycen + 8*lim + 7);
                 rectangle(xcen-57,ycen-8*lim+3,xcen+57,ycen+8*lim+4);
                 dec(start_);
                 for i := 1 to lim do
                   outtextxy(xcen,ycen-8*lim+i*15,FnArr[start_+i-1]);
                 rectangle(x0,y0,x0+2*54,y0+12);
               end
             else
               begin
                 setcolor(7);
                 rectangle(x0,y0,x0+2*54,y0+12);
                 setcolor(0);
                 dec(y0,15);
                 rectangle(x0,y0,x0+2*54,y0+12);
               end;
           end;
         Down : if imusic < filenum then
           begin
             inc(imusic);
             if (imusic = start_+lim) and (start_ < filenum) then
               begin
                 bar(xcen - 60,ycen - 8*lim,xcen + 60,ycen + 8*lim+7);
                 rectangle(xcen-57,ycen-8*lim+3,xcen+57,ycen+8*lim+4);
                 inc(start_);
                 for i := 1 to lim do
                   outtextxy(xcen,ycen-8*lim+i*15,FnArr[start_+i-1]);
                 rectangle(x0,y0,x0+2*54,y0+12);
               end
             else
               begin
                 setcolor(7);
                 rectangle(x0,y0,x0+2*54,y0+12);
                 setcolor(0);
                 inc(y0,15);
                 rectangle(x0,y0,x0+2*54,y0+12);
               end;
           end;
         PageUp :
          begin
            if start_ > lim then
               begin
                 start_ := start_ - lim;
                 imusic := imusic - lim;
               end
             else
               begin
                 start_ := 1;
                 imusic := 1;
                 y0 := ycen-8*lim+8;
               end;
             bar(xcen - 60,ycen - 8*lim,xcen + 60,ycen + 8*lim+7);
             rectangle(xcen-57,ycen-8*lim+3,xcen+57,ycen+8*lim+4);
             for i := 1 to lim do
               outtextxy(xcen,ycen-8*lim+i*15,FnArr[start_+i-1]);
             rectangle(x0,y0,x0+2*54,y0+12);
           end;

         PageDown : if start_ + lim <= filenum then
           begin
             bar(xcen - 60,ycen - 8*lim,xcen + 60,ycen + 8*lim+7);
             rectangle(xcen-57,ycen-8*lim+3,xcen+57,ycen+8*lim+4);
             start_ := start_ + lim;
             imusic := imusic + lim;
             if start_ + lim > filenum then
               begin
                 setcolor(7);
                 rectangle(x0,y0,x0+2*54,y0+12);
                 start_ := filenum + 1 - lim;
                 imusic := start_+1;
                 y0 := ycen-8*lim+8+15;
                 setcolor(0);
               end;
             for i := 1 to lim do
               outtextxy(xcen,ycen-8*lim+i*15,FnArr[start_+i-1]);
             rectangle(x0,y0,x0+2*54,y0+12);
           end;
         Esc : Quit;
       end;
     until key = Enter;
     n := old_n;
     n_plus_1 := n + 1;
     if Mouse then Hide_Mouse;
     clearviewport;
     settextjustify(0,0);
     closeKMusic;
     InitKMusic(Param+FnArr[imusic])
   End;
(********************************************)
Function Numlock : boolean;
  Begin
    Numlock := mem[$40:$17] and $20 = $20
  End;
(*********************************************)
  Procedure Run_Polygons;
   var ftemp : boolean;
       mess : string[70];

{---------------------------------------------------}
  Begin
    if loinhac then ftemp := true
    else ftemp := false;
    loinhac := false;
    n := 2 + random(8);
    n_plus_1 := n + 1;
  mess := '';
  if filenum > 0 then
    mess := 'Music : ' + copy(FnArr[imusic],1,
                     length(FnArr[imusic])-4) + ' - ';
  speed := '100';
  mess := mess + 'Speed : ' + speed + ' mm/s';
  setviewport(0,getmaxY-10,xcen,getmaxY,clipon);
  clearviewport;
  setviewport(0,0,getmaxx,getmaxY,clipon);
  outtextxy(Xcen shr 1,getmaxY,mess);
  SetViewport(0,0,getmaxX,getmaxY-10,ClipoN);
  MakeRandoms(t,h);
  MakeRandoms(t1,h1);

  drawpoly(n_plus_1,t);
  if capslock then drawpoly(n_plus_1,t1);
  key := #13;
  count := 0;c1 := 1;
  repeat
    inc(count);
    if (count = 100) then
     begin
       if c1=63 then
	c1 := 1
       else
	inc(c1);
       setRGBcolor(14,c1);
       setRGBcolor(13,c1 xor $3F);
       count := 0
     end;

    move(t[1],z[1],n_plus_1 shl 2);
    Change(t,h);
    setcolor(black);
    drawpoly(n_plus_1,z);
    if not Capslock then drawpoly(n_plus_1,t1);
    setcolor(14);
    drawpoly(n_plus_1,t);
    if capslock then
      begin
        move(t1[1],z1[1],n_plus_1 shl 2);
        Change(t1,h1);
        setcolor(black);
        drawpoly(n_plus_1,z1);
        setcolor(13);
        drawpoly(n_plus_1,t1);
      end;
    delay(delay_draw);
    if keypressed then key := readkey;
    if key in [#43,#45,#9] then
      begin
        case key of
          #45 : if delay_draw < 99 then
              begin
                inc(delay_draw);
                str(100-delay_draw,speed);
              end;
          #43 : if delay_draw >  0 then
              begin
                dec(delay_draw);
                str(100-delay_draw,speed);
              end;
          #9  :
              begin
                if (filenum > 0) then Menu;
                ftemp := loinhac;
                loinhac := false
              end;
          end;{case}
         setviewport(xcen shr 1,getmaxY-9,
                     Xcen+Xcen shr 1,getmaxY,clipon);
         clearviewport;
         if filenum > 0 then
           mess := 'Music : ' + copy(FnArr[imusic],1,
                     length(FnArr[imusic])-4) + ' - '
         else mess := '';
         mess := mess + 'Speed : ' + speed + ' mm/s';
         outtextxy(0,8,mess);
         SetViewport(0,0,getmaxX,getmaxY-10,ClipoN);
         key := #13;
       end;
  until (key = #27) or NumLock;
  setviewport(0,0,getmaxX,getmaxY,clipon);
  delay_draw := 1;
  loinhac := ftemp;
End;
{-----------------------------------------------------}
Procedure DrawPolygon;
const MAX = 35;
type PArr = array[0..max] of pointtype;
var p : PArr;
  cpx,cpy : real;
{..........................................}
 Procedure makeNgon(R:real;N:integer;sangle:real;
                    cx,cy:integer;var p:parr);
  var i : integer;
    angle,dangle : real;
  begin
    if ((N<3)or(N>MAX)) then exit;
    dangle := 2*PI/N;
    for i:=0 to N do
     begin
       angle := i*dangle  + sangle;
       p[i].x := cx + round(R*cos(angle));
       p[i].y := cy + round(R*sin(angle));
     end
  end;
{..........................................}
 Procedure Polygon(R:real;N,cx,cy:integer;stangle:real);
  var j : integer;
  begin
     makeNgon(R,N,stangle,cx,cy,p);
     moveto(p[0].x,p[0].y);
     for j:=1 to N do
      begin
	setcolor(random(8) + 8);
	lineto(p[j].x,p[j].y);
      end;
     lineto(p[0].x,p[0].y);
  end;
{...........................................}
 Procedure Rosettes(R:real;N,cx,cy:integer;stangle:real);
  var k,l : integer;
  begin
    makeNgon(R,N,stangle,cx,cy,p);
    moveto(p[0].x,p[0].y);
    for k := 0 to N do
     for l := k + 1 to N do
      begin
	setcolor(random(8) + 8);
	line(p[k].x,p[k].y,p[l].x,p[l].y);
        delay(delay_draw);
      end
  end;
{............................................}
 Begin
    Rosettes(150,2+random(33),xcen,ycen-18,0);
    delay(900 div (delay_draw+1));
    clearviewport
 End;
(******************************************************)
Procedure Help;
  Begin
    writeln;
    writeln(' TAB : Menu.');
    writeln(' ESC : Quit.');
    writeln(' BREAK : Pause drawing.');
    writeln(' <+> / <-> : Increase/Decrease Speed.');
    writeln(' Ctrl - Left/Right Shift : Music on/off.');
    writeln(' Numlock on/off : Drawing/Running Polygons.');
    writeln(' CapsLock on/off : 2/1 polygon(s) (while Numlock off).');
    if Mouse then Hide_Mouse;
    halt;
  End;

(*****************************************************)
  BEGIN

    Mouse := reset_Mouse;
    if Mouse then show_Mouse;
    if not MonoScreen and not isVGA then
      begin
        writeln(#13,#10,
'This Program is written for Hercule or (S)VGA Monitor');
        if readkey = '!' then;
      end;
    if ParamStr(1) = '?' then Help;
    for i := 0 to 90 do sine[i] := sin(i*pi/180);
    F_sp := 0;
    Start;
    if not Exist and (filenum > 1) then Menu;
    Myname := 'Rf_g Fsle T_l';
    for i := 1 to 13 do
      if myname[i] <> ' ' then myname[i] := chr(ord(myname[i])+2);
    i := 1;
    key := #13;
    {setviewport(0,0,getmaxX-20,getmaxY,clipoff);}
    repeat
      settextstyle(0,1,0);
      moveto(getmaxX,ycen+10);
      outtext('Ver 1.2');
      settextstyle(0,0,0);
      setcolor(1+random(15));
      moveto(xcen+xcen shr 1,ykara);
      outtext(myname);
      if not Numlock then Run_Polygons
      else if (i mod 14 = 0) then DrawPolygon
      else if (i mod 16 = 0) then DrawFractals
      else if (i mod 18 = 0) then DrawEllipses
      else if (i mod 20 = 0) then DrawCircles
      else if (i mod 22 = 0) then DrawIcons
      else if odd(i) then DrawPolySpiral
      else DrawSpiral;
      inc(i);
      while keypressed do
        begin
          key := readkey;
          case key of
            #45 : if delay_draw<20 then inc(delay_draw);
            #43 : if delay_draw>0 then dec(delay_draw);
          end;
        end;
      if (key = #9) and (filenum > 1) then Menu;
    until key = #27;
    Quit;
  END.





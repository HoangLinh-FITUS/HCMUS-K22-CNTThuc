  {$O+,F+}{Thai Hung Van - Dai hoc Tong hop TP HCM -1994}
  UNIT VSystem;
 {---------------------INTERFACE---------------------}
  INTERFACE
    Uses Dos,Crt;
    Type colorarray = array[1..768] of byte;
    Var VGAScreen : boolean;
  Procedure SendKey(ascci:Char); { gui phim vao vung dem ban phim }
  Procedure LightBk(mode:byte);
  Function  IsVga : boolean;
  Procedure SetRGBcolor(oldcolor,newcolor:byte);
  Function  GetRGBcolor(color:byte):byte;
  Procedure SetDACColor(colornum,r,g,b:byte);
  Procedure GetDACColor(colornum : byte;var r,g,b:byte);
  Procedure GetDACs( First, Num : integer; var Buf );
  Procedure SetDACs( First, Num : integer; var Buf );
  Function  GetMode:byte;
  Procedure SetMode(mode:byte);
  Procedure FadeScreen;
  Function  ErrorCode:word;
  Procedure InitMusic;
  Procedure CloseMusic;

{------------------------IMPLEMENTATION-------------------------}
  IMPLEMENTATION

   Const
     Note : array[1..48] of integer =
     (2093,1976,2093,1976,2093,1329,1760,1568,1397,1329,
     1397,1568,1976,1760,1976,1760,1976,1175,1568,1397,
     1329,1175,1329,1397,1760,1568,1760,1568,1760,1047,
     1397,1329,1175,1047,1175,1329,1661,1480,1661,1480,
     1661,1329,1047, 988, 880, 831, 880, 880);

{     Note1 : array[1..94] of integer =
        (440,440,587,587,740,740,740,740,740,880,880,740,740,740,660,660,
         740,740,660,660,587,587,587,587,587,440,440,587,587,740,740,740,
         587,587,740,740,880,880,880,784,784,740,740,660,660,660,660,660,
         880,880,784,784,740,740,740,660,660,587,587,587,660,660,740,740,
         880,880,784,784,784,784,784,494,494,494,494,440,440,440,554,554,
         587,587,660,660,660,740,740,660,660,587,587,587,587,587);
 }
   Var
     Regs : Registers;
     OldVector : Pointer;
     flag : boolean;
     i,i_music,count : byte;
{------------------------------------------------------------------------}
 Procedure SendKey(ascci:Char); { gui phim vao vung dem ban phim }
  Begin
   Regs.AH := 5;
   Regs.CH := 0;   { phim duoc goi vao co ma scan bang 0 }
   Regs.CL := Ord(ascci);
   Intr($16,Regs);
  end;
{-------------------------------------------------------------}
 Procedure LightBk(mode:byte);
  Begin
    regs.AH := $10;
    regs.AL := $3;
    if mode=1 then
     regs.BL := 0
    else if mode=0 then
     regs.BL := 1;
    Intr($10,regs);
  End; {LightBk}
{------------------------------------------------------------}
 Function IsVga : boolean;
  Begin
    Regs.AX := $1a00;     { Function 1AH applies only to VGA }
    Intr( $10, Regs );
    IsVga := ( Regs.AL = $1a );
  End;
{------------------------------------------------------------}
 Procedure SetRGBcolor(oldcolor,newcolor:byte);
  Begin
    regs.AH := $10;
    regs.AL := 0;
    regs.BL := oldcolor;
    regs.BH := newcolor;
    Intr($10,regs);
  End; {SetRGBcolor}
{------------------------------------------------------------}
 Function GetRGBcolor(color:byte):byte;
  Begin
    regs.AH := $10;
    regs.AL := 7;
    regs.BL := color;
    Intr($10,regs);
    GetRGBcolor := regs.BH;
  End; {GetRGBcolor}
{-----------------------------------------------------------}
 Procedure SetDACColor(colornum,r,g,b:byte);
   begin
     Regs.AH := $10;
     Regs.AL := $10;
     Regs.BX := colornum;
     Regs.DH := r;
     Regs.CH := g;
     Regs.CL := b;
     Intr($10,Regs);
   end; {SetDACcolor}
{-----------------------------------------------------------}
 Procedure GetDACColor(colornum : byte;var r,g,b:byte);
   begin
     Regs.AH := $10;
     Regs.AL := $15;
     Regs.BX := colornum;
     Intr($10,Regs);
     r := Regs.DH;
     g := Regs.CH;
     b := Regs.CL;
   end; {GetDACcolor}
{------------------------------------------------------------}
{**********************************************************************
*  GetDACs: Gets the contents of a specific number of DAC registers.   *
**-------------------------------------------------------------------**
*  Input   : FIRST = Number of first DAC register (0-255)             *
*            NUM   = Number of DAC registers                          *
*            BUF   = Buffer, in which the contents of the DAC         *
*                    registers are to be loaded. It must be a         *
*                    DACREG type variable or an array of this type.   *
*  Info    : The passed buffer must have three bytes reserved for     *
*            DAC register, in which the red, green and blue parts     *
*            of each color are recorded.                              *
**********************************************************************}

Procedure GetDACs( First, Num : integer; var Buf );

Begin
  Regs.AX := $1017;                { Function and sub-function number }
  Regs.BX := First;                    { Number of first DAC register }
  Regs.CX := Num;                  { Number of registers to be loaded }
  Regs.ES := seg( Buf );                    { Load pointers to buffer }
  Regs.DX := ofs( Buf );
  intr( $10, Regs );                      { Call BIOS video interrupt }
End; {GetDACs}

{**********************************************************************
*  SetDACs: Loads a specific number of DAC registers                   *
**-------------------------------------------------------------------**
*  Input   : FIRST = Number of first DAC register (0-255)             *
*            NUM   = Number of DAC regsters                           *
*            BUF   = Buffer, from which the contents of the DAC       *
*                    registers are to be taken. Must be a variable    *
*                    of DACREG type or an array of this type.         *
*  Info    : See GetDACs                                               *
**********************************************************************}
Procedure SetDACs( First, Num : integer; var Buf );

Begin
  Regs.AX := $1012;                { Function and sub-function number }
  Regs.BX := First;                    { Number of first DAC register }
  Regs.CX := Num;                  { Number of registers to be loaded }
  Regs.ES := seg( Buf );                     { Load pointer to buffer }
  Regs.DX := ofs( Buf );
  intr( $10, Regs );                      { Call BIOS video interrupt }
End; {SetDACs}
{---------------------------------------------------------------------}
 Function GetMode:byte;
  Begin
    Regs.AH := $F;
    Intr($10,Regs);
    GetMode := Regs.AL;
  End; { GetMode }
{-------------------------------------}
 Procedure SetMode(mode:byte);
  Begin
    Regs.AH := 0;
    Regs.AL := mode;
    Intr($10,Regs);
  End;
{-------------------------------------}
 Procedure FadeScreen;
 var colors,oldc : colorarray;
     i,j,k,x,y,z,x1,y1,z1 : byte;
 Begin
   GetDACs(0,64,colors);
   oldc := colors;
   for j := 1 to 63 do
    begin
      for i := 1 to 192 do
	if colors[i]>0 then
	   colors[i] := colors[i]-1;
      SetDACs(0,64,colors);
      delay(50);
    end;
    SetMode(GetMode);
    SetDACs(0,64,oldc);
 End; {FadeScreen}
{--------------------------------------}
 Function ErrorCode;
  Begin
    Regs.AH := $59;
    Regs.BX := 0;
    Intr($21,Regs);
    ErrorCode := Regs.AX;
  End;
{--------------------------------------}
Procedure Music; Interrupt;
 Begin
   if flag then
     if count < 4 then inc(count)
     else
       begin
	 count := 0;
	 if i_music < 48 then inc(i_music)
	 else i_music := 1;
	 sound(note[i_music])
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
 Procedure InitMusic;
   Begin
     GetIntVec($1C,OldVector);
     SetIntVec($1C,@Music);
   End;
{-------------------------------------------}
 Procedure CloseMusic;
   Begin
     Nosound;
     SetIntVec($1C,OldVector);
   End;
{-------------------------------------------}
BEGIN
  VGAScreen := isVGA;
  flag := true;
END.













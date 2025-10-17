   {$O+,F+}{Thai Hung Van - Dai hoc Tong hop TP HCM -1994}
  UNIT KMusic;
 {---------------------INTERFACE---------------------}
  INTERFACE
    Uses Dos,Crt;
  Procedure InitKMusic(filename : string);
  Procedure CloseKMusic;

{------------------------IMPLEMENTATION-------------------------}
  IMPLEMENTATION

   Type  v = record
               note : word;
               dl   : byte;
               ch   : string[6];
         end;
   Const Maxnum = 600;
   Var
     Regs : Registers;
     OldVector : Pointer;
     a : array[0..Maxnum] of V;
     Vnum,Vcount,i_Vmusic,i,delay : integer;
     ch : char;
     exist,flag : boolean;
{-----------------------------------------------}
Procedure Music; Interrupt;
 Begin
   if flag then
     if Vcount < a[i_vmusic].dl then inc(Vcount)
     else
       begin
	 Vcount := 0;
	 if i_Vmusic < Vnum then
           begin
             inc(i_Vmusic);
             write(a[i_Vmusic].ch,' ')
           end
	 else i_Vmusic := 1;
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
{-------------------------------------------}
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
         while (not eof(f)) and (Vnum < Maxnum) do
           begin
             inc(Vnum);
             readln(f,a[Vnum].note,delay,a[Vnum].ch);
             a[Vnum].dl := delay shr 3;
           end;
         close(f);
         flag := true;
         a[0].dl := 255;
         i_Vmusic := 0;
         Vcount := maxint;
         Init;
       end;
   End;
{---------------------------------------------}
 Procedure CloseKMusic;
   Begin
     if Exist then  DeInit
   End;
{---------------------------------------------}
BEGIN
  Exist := false
END.